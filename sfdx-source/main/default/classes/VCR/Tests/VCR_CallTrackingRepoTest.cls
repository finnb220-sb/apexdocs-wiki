/**
 * @author Booz Allen Hamilton
 * @description Tests for VCR_CallTrackingRepo class.
 * @see VCR_CallTrackingRepo
 */
@IsTest
public with sharing class VCR_CallTrackingRepoTest {
    private static final String VAVET_BASE_PROFILE = 'VAVET Base Profile';
    private static final String VCC_MEDICAL_PROVIDER = 'VCC_Medical_Provider';
    private static final String VCC_INT_TEST = 'VCC Integration Test Utility User';
    private static final String VCC_MP_VIEWER = 'VAHC VCV Appointment Viewer Medical Provider';
    private static final String USER_FIRST_NAME = 'CallTrackingTest';

    /**@description Create Test User for CallTrackingRepoTests
     */
    @TestSetup
    static void makeData() {
        new VATEST_UserBuilder()
            .withUserProfile(VAVET_BASE_PROFILE)
            .withStandardData()
            .setFields(User.TimeZoneSidKey, UserInfo.getTimeZone().getID())
            .setFields(User.FirstName, USER_FIRST_NAME)
            .withPermissionSet(VCC_MEDICAL_PROVIDER)
            .withPermissionSet(VCC_INT_TEST)
            .withPermissionSet(VCC_MP_VIEWER)
            .build(true);
    }
    /**
     * @description Create Test Data for CallTrackingRepoTests
     * @param insertCallTrackingRecords Boolean for positive and negative tests
     * @return Id of Progress Note
     */
    public static Id createTestData(Boolean insertCallTrackingRecords) {
        VATEST_SObjectFactory.createSObject(
            new Account(
                FirstName = 'Testly',
                LastName = 'Person Accounted',
                RecordTypeId = new VCR_AccountRepo().recordTypeConstant.fromDeveloperName('PersonAccount').Id
            ),
            true
        );

        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        update testContact;

        Id caseRecTypeId = new VCR_CaseRepo().recordTypeConstant.fromDeveloperName('VCC_Vitrual_Clinic_Visit').Id;

        Case testCase = (Case) VATEST_SObjectFactory.createSObject(
            new Case(RecordTypeId = caseRecTypeId, VCC_Case_Type__c = 'VCV', ContactId = testContact.Id),
            true
        );

        VCC_Progress_Note__c testProgressNote = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
            new VCC_Progress_Note__c(
                VCC_Case__c = testCase.id,
                VCC_Caregiver_Name__c = 'Care Giver',
                VCC_Additional_Comments__c = 'Note1',
                VCC_Relative_Type__c = 'Self'
            ),
            true
        );

        if (insertCallTrackingRecords) {
            VATEST_SObjectFactory.createSObject(
                new VCC_Call_Tracking__c(
                    VCC_Progress_Note__c = testProgressNote.Id,
                    VCC_Call_Date_Time__c = Datetime.now(),
                    CreatedDate = Datetime.now()
                ),
                true
            );
        }

        return testProgressNote.Id;
    }

    /**
     * @description Test fetchById() for success path
     */
    @IsTest
    static void unitTestConstructorPositive() {
        User testUser = [SELECT Id FROM User WHERE FirstName = :USER_FIRST_NAME LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            VCR_CallTrackingRepo repo = new VCR_CallTrackingRepo();
            Assert.isNotNull(repo, 'Expected constructor to properly instantiate a VCR_CallTrackingRepo');
            Test.stopTest();
        }
    }

    /**
     * @description Test retrieving contact when given a list of ICNs positive
     */
    @IsTest
    static void funcGetCallTrackingListPositive() {
        User testUser = [SELECT Id FROM User WHERE FirstName = :USER_FIRST_NAME LIMIT 1];
        System.runAs(testUser) {
            Id testProgressNoteId = createTestData(true);
            Test.startTest();
            VCR_CallTrackingRepo callTrackingRepo = new VCR_CallTrackingRepo();
            List<VCC_Call_Tracking__c> results = callTrackingRepo.fetchCallTrackingList(testProgressNoteId);
            Assert.areEqual(1, results.size(), 'Expected to receive one record but returned: ' + results.size());
            Test.stopTest();
        }
    }

    /**
     * @description Test retrieving contact when given a list of ICNs positive
     */
    @IsTest
    static void funcGetCallTrackingListNegative() {
        User testUser = [SELECT Id FROM User WHERE FirstName = :USER_FIRST_NAME LIMIT 1];
        System.runAs(testUser) {
            Id testProgressNoteId = createTestData(false);
            Test.startTest();
            VCR_CallTrackingRepo callTrackingRepo = new VCR_CallTrackingRepo();
            List<VCC_Call_Tracking__c> results = callTrackingRepo.fetchCallTrackingList(testProgressNoteId);
            Assert.areEqual(0, results.size(), 'Expected to receive no records but observed: ' + results.size());
            Test.stopTest();
        }
    }
}
