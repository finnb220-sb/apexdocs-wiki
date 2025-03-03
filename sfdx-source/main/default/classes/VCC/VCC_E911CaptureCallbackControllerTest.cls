/**
 * @author Booz Allen
 * @date 04/2024
 * @description Test Class for the VCC_E911CaptureCallbackController methods
 */
@isTest
public with sharing class VCC_E911CaptureCallbackControllerTest {
    private static final String SUCCESS_MESSAGE = 'Success';
    private static final String SURFACED_ON_INVALID_OBJECT_ERROR = 'ERROR: This component is not on a Case, Progress Note, Account, or Home Page';
    private static final String UPSERT_FAILED_ERROR = 'ERROR: Saving the records failed';
    private static final String CALLBACKNUMBER = '555-555-1234';
    private static final String RECORD_TYPE_CASE = 'Case';
    private static final String RECORD_TYPE_ACCOUNT = 'Account';
    private static final String RECORD_TYPE_PROGRESS_NOTE = 'VCC_Progress_Note__c';
    private static final String RECORD_TYPE_HOME = 'Home';
    private static final String RECORD_TYPE_TEST = 'Test';

    @TestSetup
    /**
     * @description Test Setup method to create and configure test users
     */
    public static void makeData() {
        //make the test user
        VATEST_UserBuilder testUserBuilder = new VATEST_UserBuilder();
        User testUser1 = testUserBuilder.withUserProfile('VAVET Base Profile').withStandardData().build(true);
        VATEST_PermissionSetRepo repo = new VATEST_PermissionSetRepo();
        //fetch and assign permission sets
        Id e911permSetId = repo.fetchPermissionSetIdByName('VCC_VAHC_E911_User');
        Id standardPermSetId = repo.fetchPermissionSetIdByName('VAHC_Standard_VCC_User');
        repo.assignPermSetToUser(testUser1, e911permSetId);
        repo.assignPermSetToUser(testUser1, standardPermSetId);
    }

    /**
     * @description Helper method to retrieve users
     * @return User - user to be used for testing
     */
    private static User getTestUser() {
        return [
            SELECT Id, Title
            FROM User
            WHERE Email LIKE 'Testuser@test.example.com%'
            LIMIT 1
        ];
    }
    /**
     * @description Test for retrieving the contact id from the passed in contact id
     */
    @isTest
    public static void testGetContactIdFromAccountId() {
        Id fakeAccountId = VATEST_IdFactory.get(Account.sObjectType);
        Id fakeContactId = VATEST_IdFactory.get(Contact.sObjectType);
        Contact tempContact = new Contact(Id = fakeContactId);

        VCR_ContactRepo stubContactRepo = (VCR_ContactRepo) new VATEST_StubBuilder(VCR_ContactRepo.class)
            .mockingMethodCall('getContactFromAccountId', String.class)
            .withParameterValues(fakeAccountId)
            .returning(new List<Contact>{ tempContact })
            .defineStub();

        VCC_E911CaptureCallbackController.memoizedContactRepo = stubContactRepo;

        Id testResult;
        User testUser = getTestUser();
        Test.startTest();
        System.runAs(testUser) {
            testResult = VCC_E911CaptureCallbackController.getContactIdFromAccountId(fakeAccountId);
        }
        Test.stopTest();

        Assert.areEqual(testResult, fakeContactId, 'Mock should have returned the test contact Id');
    }
    /**
     * @description Test for getting an  E911 record with the correct associated account/contact id passed in
     */
    @isTest
    public static void testGetE911MetricsRecordPositive() {
        Id fakeContactId = VATEST_IdFactory.get(Contact.sObjectType);
        VCC_e911_Metrics__c testMetric = (VCC_e911_Metrics__c) VATEST_SObjectFactory.createSObject(
            new VCC_e911_Metrics__c(VCC_Patient_Account__c = fakeContactId)
        );

        VCR_E911MetricsRepo stubE911MetricsRepo = (VCR_E911MetricsRepo) new VATEST_StubBuilder(
                VCR_E911MetricsRepo.class
            )
            .mockingMethodCall('getE911MetricsByContactId', String.class)
            .withParameterValues(fakeContactId)
            .returning(new List<VCC_e911_Metrics__c>{ testMetric })
            .defineStub();

        VCC_E911CaptureCallbackController.memoizedE911MetricsRepo = stubE911MetricsRepo;

        VCC_e911_Metrics__c testResult;
        User testUser = getTestUser();
        Test.startTest();
        System.runAs(testUser) {
            testResult = VCC_E911CaptureCallbackController.getE911MetricsRecord(fakeContactId);
        }
        Test.stopTest();

        Assert.isNotNull(testResult, 'Record was search returned null, expecting record to be retrieved');
        Assert.areEqual(
            testResult.VCC_Patient_Account__c,
            testMetric.VCC_Patient_Account__c,
            'Result record and test record do not match'
        );
    }
    /**
     * @description Negative Test for getting an E911 record
     */
    @isTest
    public static void testGetE911MetricsRecordNegative() {
        Id fakeContactId = VATEST_IdFactory.get(Contact.sObjectType);
        VCC_e911_Metrics__c testResult;
        User testUser = getTestUser();
        Test.startTest();
        System.runAs(testUser) {
            testResult = VCC_E911CaptureCallbackController.getE911MetricsRecord(fakeContactId);
        }
        Test.stopTest();

        Assert.isNull(testResult, 'Record should be null');
    }
    /**
     * @description Test for getting an E911 record with the correct e911metric id passed in
     */
    @isTest
    public static void testGetE911MetricsRecordByIdPositive() {
        Id fakeContactId = VATEST_IdFactory.get(Contact.sObjectType);
        VCC_e911_Metrics__c testMetric = (VCC_e911_Metrics__c) VATEST_SObjectFactory.createSObject(
            new VCC_e911_Metrics__c(VCC_Patient_Account__c = fakeContactId)
        );

        VCR_E911MetricsRepo stubE911MetricsRepo = (VCR_E911MetricsRepo) new VATEST_StubBuilder(
                VCR_E911MetricsRepo.class
            )
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(testMetric.Id, new Set<String>{ 'Id', 'VCC_Non_Address__c', 'VCC_Active__c' })
            .returning(testMetric)
            .defineStub();

        VCC_E911CaptureCallbackController.memoizedE911MetricsRepo = stubE911MetricsRepo;

        VCC_e911_Metrics__c testResult;
        User testUser = getTestUser();
        Test.startTest();
        System.runAs(testUser) {
            testResult = VCC_E911CaptureCallbackController.getE911MetricsRecordById(testMetric.Id);
        }
        Test.stopTest();

        Assert.isNotNull(testResult, 'Record was search returned null, expecting record to be retrieved');
        Assert.areEqual(testResult.Id, testMetric.Id, 'Result record and test record do not match');
    }
    /**
     * @description Test to determine if VCC_E911_Disable__mdt has any records
     */
    @IsTest
    static void testGetDoesDisableCustomMetadataExistPositive() {
        Boolean result;
        Test.startTest();
        result = VCC_E911CaptureCallbackController.isE911Enabled();
        Test.stopTest();
        Assert.areEqual(false, result, 'Should have found zero records');
    }
    /**
     * @description helper method to build stubs and test objects
     * @return A list of Ids. Should contain a Case, Account, and Progress Note ID in that order
     */
    static List<String> buildStubsAndObjects() {
        //Account repo and Stub
        Account testAccount = (Account) VATEST_SObjectFactory.createSObject(new Account());
        VCR_AccountRepo stubAccountRepository = (VCR_AccountRepo) new VATEST_StubBuilder(VCR_AccountRepo.class)
            .mockingMethodCall('fetchById', Id.class)
            .withParameterValues(testAccount.Id)
            .returning(testAccount)
            .defineStub();
        VCC_E911CaptureCallbackController.memoizedAccountRepo = stubAccountRepository;
        //Contact repo and Stub
        Contact testContact = (Contact) VATEST_SObjectFactory.createSObject(new Contact(AccountId = testAccount.Id));
        VCR_ContactRepo stubContactRepository = (VCR_ContactRepo) new VATEST_StubBuilder(VCR_ContactRepo.class)
            .mockingMethodCall('getContactFromAccountId', String.class)
            .withParameterValues(testAccount.Id)
            .returning(new List<Contact>{ testContact })
            .defineStub();
        VCC_E911CaptureCallbackController.memoizedContactRepo = stubContactRepository;
        //Case repo and Stub
        Case testCase = (Case) VATEST_SObjectFactory.createSObject(
            new Case(ContactId = testContact.Id, AccountId = testAccount.Id)
        );
        VCR_CaseRepo stubCaseRepository = (VCR_CaseRepo) new VATEST_StubBuilder(VCR_CaseRepo.class)
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(testCase.Id, new Set<String>{ 'ContactId', 'Id', 'VCC_Progress_Note__c' })
            .returning(testCase)
            .defineStub();
        VCC_E911CaptureCallbackController.memoizedCaseRepo = stubCaseRepository;
        //progress note repo and Stub
        VCC_Progress_Note__c pNote = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
            new VCC_Progress_Note__c(VCC_Case__c = testCase.Id)
        );
        VCR_ProgressNoteRepo stubProgressNoteRepo = (VCR_ProgressNoteRepo) new VATEST_StubBuilder(
                VCR_ProgressNoteRepo.class
            )
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(pNote.Id, new Set<String>{ 'Id', 'VCC_Case__c' })
            .returning(pNote)
            .defineStub();
        VCC_E911CaptureCallbackController.memoizedProgressNoteRepo = stubProgressNoteRepo;
        //E911 Metric repo and Stub
        VCC_e911_Metrics__c testMetric = (VCC_e911_Metrics__c) VATEST_SObjectFactory.createSObject(
            new VCC_e911_Metrics__c(
                VCC_Patient_Account__c = testContact.Id,
                VCC_e911_Case__c = testCase.Id,
                VCC_e911_Progress_Note__c = pNote.Id
            )
        );
        VCR_E911MetricsRepo stubE911MetricsRepo = (VCR_E911MetricsRepo) new VATEST_StubBuilder(
                VCR_E911MetricsRepo.class
            )
            .mockingMethodCall('getE911MetricsByContactId', String.class)
            .withParameterValues(testContact.Id)
            .returning(new List<VCC_e911_Metrics__c>{ testMetric })
            .mockingMethodCall('doUpsert', SObject.class)
            .withParameterValues(testMetric)
            .returning(
                (Database.UpsertResult) JSON.deserialize(
                    '{"success":true,"errors":[],"id":"' + testMetric.Id + '"}',
                    Database.UpsertResult.class
                )
            )
            .defineStub();
        VCC_E911CaptureCallbackController.memoizedE911MetricsRepo = stubE911MetricsRepo;
        //VCR_bsConfigurationsAssignedUserRepo repo and stub
        User testUser = getTestUser();
        cnx__Connects_Configuration_Assignment__c testBSConfig = (cnx__Connects_Configuration_Assignment__c) VATEST_SObjectFactory.createSObject(
            new cnx__Connects_Configuration_Assignment__c(cnx__Assigned_User__c = testUser.Id)
        );
        VCR_bsConfigurationsAssignedUserRepo stubBSCAURepo = (VCR_bsConfigurationsAssignedUserRepo) new VATEST_StubBuilder(
                VCR_bsConfigurationsAssignedUserRepo.class
            )
            .mockingMethodCall('fetchAssociatedUser', String.class)
            .withParameterValues(testUser.Id)
            .returning(new List<cnx__Connects_Configuration_Assignment__c>{ testBSConfig })
            .defineStub();
        VCC_E911CaptureCallbackController.memoizedBSConfigRepo = stubBSCAURepo;
        List<String> idList = new List<String>{ testCase.Id, testAccount.Id, pNote.Id };
        return idList;
    }
    /**
     * @description helper method to build stubs and test objects for negative test cases
     * @return A list of Ids. Should contain a Case, Account, and Progress Note ID in that order
     */
    static List<String> buildStubsAndObjectsNegative() {
        //Account repo and Stub
        Account testAccount = (Account) VATEST_SObjectFactory.createSObject(new Account());
        VCR_AccountRepo stubAccountRepository = (VCR_AccountRepo) new VATEST_StubBuilder(VCR_AccountRepo.class)
            .mockingMethodCall('fetchById', Id.class)
            .withParameterValues(testAccount.Id)
            .returning(testAccount)
            .defineStub();
        VCC_E911CaptureCallbackController.memoizedAccountRepo = stubAccountRepository;
        //Contact repo and Stub
        Contact testContact = (Contact) VATEST_SObjectFactory.createSObject(new Contact(AccountId = testAccount.Id));
        VCR_ContactRepo stubContactRepository = (VCR_ContactRepo) new VATEST_StubBuilder(VCR_ContactRepo.class)
            .mockingMethodCall('getContactFromAccountId', String.class)
            .withParameterValues(testAccount.Id)
            .returning(new List<Contact>{ testContact })
            .defineStub();
        VCC_E911CaptureCallbackController.memoizedContactRepo = stubContactRepository;
        //Case repo and Stub
        Case testCase = (Case) VATEST_SObjectFactory.createSObject(
            new Case(ContactId = testContact.Id, AccountId = testAccount.Id)
        );
        VCR_CaseRepo stubCaseRepository = (VCR_CaseRepo) new VATEST_StubBuilder(VCR_CaseRepo.class)
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(testCase.Id, new Set<String>{ 'ContactId', 'Id', 'VCC_Progress_Note__c' })
            .returning(testCase)
            .defineStub();
        VCC_E911CaptureCallbackController.memoizedCaseRepo = stubCaseRepository;
        //progress note repo and Stub
        VCC_Progress_Note__c pNote = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
            new VCC_Progress_Note__c(VCC_Case__c = testCase.Id)
        );
        VCR_ProgressNoteRepo stubProgressNoteRepo = (VCR_ProgressNoteRepo) new VATEST_StubBuilder(
                VCR_ProgressNoteRepo.class
            )
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(pNote.Id, new Set<String>{ 'Id', 'VCC_Case__c' })
            .returning(pNote)
            .defineStub();
        VCC_E911CaptureCallbackController.memoizedProgressNoteRepo = stubProgressNoteRepo;
        //E911 Metric repo and Stub
        VCC_e911_Metrics__c testMetric = (VCC_e911_Metrics__c) VATEST_SObjectFactory.createSObject(
            new VCC_e911_Metrics__c(
                VCC_Patient_Account__c = testContact.Id,
                VCC_e911_Case__c = testCase.Id,
                VCC_e911_Progress_Note__c = pNote.Id
            )
        );
        VCR_E911MetricsRepo stubE911MetricsRepo = (VCR_E911MetricsRepo) new VATEST_StubBuilder(
                VCR_E911MetricsRepo.class
            )
            .mockingMethodCall('getE911MetricsByContactId', String.class)
            .withParameterValues(testContact.Id)
            .returning(new List<VCC_e911_Metrics__c>{ testMetric })
            .mockingMethodCall('doUpsert', SObject.class)
            .withParameterValues(testMetric)
            .returning(
                (Database.UpsertResult) JSON.deserialize(
                    '{"success":false,"errors":[{"message":"test error","statusCode":"00"}]}',
                    Database.UpsertResult.class
                )
            )
            .defineStub();
        VCC_E911CaptureCallbackController.memoizedE911MetricsRepo = stubE911MetricsRepo;

        List<String> idList = new List<String>{ testCase.Id, testAccount.Id, pNote.Id };
        return idList;
    }
    /**
     * @description Test for retrieving and updating the e911 metrics record when invoked from Case
     */
    @IsTest
    public static void testhandleE911MetricsCasePositive() {
        List<String> listOfIDs = buildStubsAndObjects();

        String testResult;
        User testUser = getTestUser();
        Test.startTest();
        System.runAs(testUser) {
            testResult = VCC_E911CaptureCallbackController.queryE911Record(
                RECORD_TYPE_CASE,
                listOfIDs[0],
                CALLBACKNUMBER
            );
        }
        Test.stopTest();
        Assert.isNotNull(testResult, 'Record should have been returned and edited');
        Assert.isFalse(testResult.startsWith('ERROR:'), 'Record was queried and updated');
    }
    /**
     * @description Test for mocking a failed upsert of e911 record when invoked from Case
     */
    @IsTest
    public static void testhandleE911MetricsCaseNegative() {
        List<String> listOfIDs = buildStubsAndObjectsNegative();

        String testResult;
        User testUser = getTestUser();
        Test.startTest();
        System.runAs(testUser) {
            testResult = VCC_E911CaptureCallbackController.queryE911Record(
                RECORD_TYPE_CASE,
                listOfIDs[0],
                CALLBACKNUMBER
            );
        }
        Test.stopTest();
        Assert.isNotNull(testResult, 'Should have returned fail message');
        Assert.areEqual(testResult, UPSERT_FAILED_ERROR, 'Record should not have been found');
    }

    /**
     * @description Test for retrieving and updating the e911 metrics record when invoked from Account
     */
    @IsTest
    public static void testhandleE911MetricsAccountPositive() {
        List<String> listOfIDs = buildStubsAndObjects();

        String testResult;
        User testUser = getTestUser();
        Test.startTest();
        System.runAs(testUser) {
            testResult = VCC_E911CaptureCallbackController.queryE911Record(
                RECORD_TYPE_ACCOUNT,
                listOfIDs[1],
                CALLBACKNUMBER
            );
        }
        Test.stopTest();
        Assert.isNotNull(testResult, 'Record should have been returned and edited');
        Assert.isFalse(testResult.startsWith('ERROR:'), 'Record was queried and updated');
    }
    /**
     * @description Test for mocking a failed upsert of e911 record when invoked from Case
     */

    @IsTest
    public static void testhandleE911MetricsAccountNegative() {
        List<String> listOfIDs = buildStubsAndObjectsNegative();

        String testResult;
        User testUser = getTestUser();
        Test.startTest();
        System.runAs(testUser) {
            testResult = VCC_E911CaptureCallbackController.queryE911Record(
                RECORD_TYPE_ACCOUNT,
                listOfIDs[1],
                CALLBACKNUMBER
            );
        }
        Test.stopTest();
        Assert.isNotNull(testResult, 'Should have returned fail message');
        Assert.areEqual(testResult, UPSERT_FAILED_ERROR, 'Record should not have been found');
    }

    /**
     * @description Test for retrieving and updating the e911 metrics record when invoked from Progress Note
     */
    @IsTest
    public static void testhandleE911MetricsProgressNotePositive() {
        List<String> listOfIDs = buildStubsAndObjects();
        String testResult;
        User testUser = getTestUser();
        Test.startTest();
        System.runAs(testUser) {
            testResult = VCC_E911CaptureCallbackController.queryE911Record(
                RECORD_TYPE_PROGRESS_NOTE,
                listOfIDs[2],
                CALLBACKNUMBER
            );
        }
        Test.stopTest();
        Assert.isNotNull(testResult, 'Record should have been returned and edited');
        Assert.isFalse(testResult.startsWith('ERROR:'), 'Record was queried and updated');
    }

    @IsTest
    /**
     * @description Negative Test for retrieving and updating the e911 metrics record when invoked from Progress Note
     */
    public static void testhandleE911MetricsProgressNoteNegative() {
        List<String> listOfIDs = buildStubsAndObjectsNegative();

        String testResult;
        User testUser = getTestUser();
        Test.startTest();
        System.runAs(testUser) {
            testResult = VCC_E911CaptureCallbackController.queryE911Record(
                RECORD_TYPE_PROGRESS_NOTE,
                listOfIDs[2],
                CALLBACKNUMBER
            );
        }
        Test.stopTest();
        Assert.isNotNull(testResult, 'Record should have been returned and edited');
        Assert.areEqual(testResult, UPSERT_FAILED_ERROR, 'Record was queried and updated');
    }

    /**
     * @description Test for retrieving and updating the e911 metrics record when invoked from Home
     */
    @IsTest
    public static void testhandleE911MetricsHomePositive() {
        String testResult;
        User testUser = getTestUser();
        Test.startTest();
        System.runAs(testUser) {
            testResult = VCC_E911CaptureCallbackController.queryE911Record(null, null, CALLBACKNUMBER);
        }
        Test.stopTest();
        Assert.isNotNull(testResult, 'Record should have been returned and edited');
        Assert.isFalse(testResult.startsWith('ERROR:'), 'Record was queried and updated');
    }
    /**
     * @description Negative test case
     */
    @IsTest
    public static void testhandleE911MetricsNegative() {
        buildStubsAndObjects();
        String testResult;
        User testUser = getTestUser();
        Test.startTest();
        System.runAs(testUser) {
            testResult = VCC_E911CaptureCallbackController.queryE911Record(RECORD_TYPE_TEST, null, CALLBACKNUMBER);
        }
        Test.stopTest();
        Assert.isNotNull(testResult, 'Record should have NOT been returned and edited');
        Assert.areEqual(testResult, SURFACED_ON_INVALID_OBJECT_ERROR, 'Record was NOT queried and updated');
    }
    /**
     * @description Positive Test for getBSConfigAssignedUserRecord method
     */
    @IsTest
    public static void testgetBSConfigAssignedUserRecordPositive() {
        buildStubsAndObjects();
        Boolean testResult;
        User testUser = getTestUser();
        Test.startTest();
        System.runAs(testUser) {
            testResult = VCC_E911CaptureCallbackController.getBSConfigAssignedUserRecord();
        }
        Test.stopTest();
        Assert.isTrue(testResult, 'Record should have been found');
    }
    /**
     * @description Negative Test for getBSConfigAssignedUserRecord method
     */
    @IsTest
    public static void testgetBSConfigAssignedUserRecordNegative() {
        Boolean testResult;
        User testUser = getTestUser();
        Test.startTest();
        System.runAs(testUser) {
            testResult = VCC_E911CaptureCallbackController.getBSConfigAssignedUserRecord();
        }
        Test.stopTest();
        Assert.isFalse(testResult, 'Record should Not have been found');
    }
    /**
     * @description Test for getCustomSettingsValue method
     */
    @IsTest
    static void testGetCustomSettingsValue() {
        Boolean testResult;
        VAHC_E911_Settings__c e911Setting = new VAHC_E911_Settings__c();
        e911Setting.Name = 'Test Name';
        e911Setting.Allow_BS_Callout__c = true;
        insert e911Setting;
        User testUser = getTestUser();
        Test.startTest();
        System.runAs(testUser) {
            testResult = VCC_E911CaptureCallbackController.getCustomSettingsValue();
        }
        Test.stopTest();
        Assert.isTrue(testResult, 'Method should return true');
    }
    /**
     * @description Negative Test for getCustomSettingsValue method
     */
    @IsTest
    static void testGetCustomSettingsValueNegative() {
        Boolean testResult;
        User testUser = getTestUser();
        Test.startTest();
        System.runAs(testUser) {
            testResult = VCC_E911CaptureCallbackController.getCustomSettingsValue();
        }
        Test.stopTest();
        Assert.isFalse(testResult, 'Method should return false');
    }
    /**
     * @description Test for Case Repo within the controller
     */
    @IsTest
    static void testCaseRepo() {
        VCR_CaseRepo testResult;
        User testUser = getTestUser();
        Test.startTest();
        System.runAs(testUser) {
            testResult = VCC_E911CaptureCallbackController.caseRepo;
        }
        Test.stopTest();

        Assert.isNotNull(testResult, 'Record should not be null');
    }
    /**
     * @description Test for Account Repo within the controller
     */
    @IsTest
    static void testAccountRepo() {
        VCR_AccountRepo testResult;
        User testUser = getTestUser();
        Test.startTest();
        System.runAs(testUser) {
            testResult = VCC_E911CaptureCallbackController.accountRepo;
        }
        Test.stopTest();

        Assert.isNotNull(testResult, 'Record should not be null');
    }
    /**
     * @description Test for Progress Note Repo within the controller
     */
    @IsTest
    static void testPNoteRepo() {
        VCR_ProgressNoteRepo testResult;
        User testUser = getTestUser();
        Test.startTest();
        System.runAs(testUser) {
            testResult = VCC_E911CaptureCallbackController.pnRepo;
        }
        Test.stopTest();

        Assert.isNotNull(testResult, 'Record should not be null');
    }
    /**
     * @description Test for Contact Repo within the controller
     */
    @IsTest
    static void testContactRepo() {
        VCR_ContactRepo testResult;
        User testUser = getTestUser();
        Test.startTest();
        System.runAs(testUser) {
            testResult = VCC_E911CaptureCallbackController.contactRepo;
        }
        Test.stopTest();

        Assert.isNotNull(testResult, 'Record should not be null');
    }

    /**
     * @description Test for VCR_bsConfigurationsAssignedUserRepo Repo within the controller
     */
    @IsTest
    static void testbsConfigurationsAssignedUserRepoRepo() {
        VCR_bsConfigurationsAssignedUserRepo testResult;
        User testUser = getTestUser();
        Test.startTest();
        System.runAs(testUser) {
            testResult = VCC_E911CaptureCallbackController.bsCAURepo;
        }
        Test.stopTest();

        Assert.isNotNull(testResult, 'Record should not be null');
    }
}
