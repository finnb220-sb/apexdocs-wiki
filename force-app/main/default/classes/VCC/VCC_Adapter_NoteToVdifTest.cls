/**
 * @description Test class for VCC_Adapter_NoteToVdif
 * @justfication PMD.ApexUnitTestClassShouldHaveAsserts has been suppressed. 16 of the 18 unit test's asserts are in the helper method writeNoteAndAssertResults. The other 2 methods have asserts in their unit tests.
 **/
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
@IsTest
public with sharing class VCC_Adapter_NoteToVdifTest {
    /// Helper Methods and Variables
    private static final String VCC_RN_USER = 'VCC_Registered_Nurse';
    private static final String VCC_VCV_USER = 'VCC_Medical_Provider';
    private static final String VCC_MSA_USER = 'VCC_Advanced_Medical_Support_Assistant';
    private static final String VCC_PHARM_I_USER = 'VCC_Pharmacy_I';
    private static final String VCC_PHARM_II_USER = 'VCC_Pharmacy_II';
    private static final String VCC_PHARM_III_USER = 'VCC_Pharmacy_III';
    private static final String VCC_TELE_EC_MP_USER = 'TED_Medical_Provider_Group';
    private static final String VCC_TELE_EC_RN_USER = 'TED_Registered_Nurse_Group';
    private static final User VCC_ADMIN_USER = createAdminUser();

    /**
     * @description Creates test user based on permissionSet
     * @param permissionSet `String` - required permission set for persona
     * @return      `User`
     */
    private static User createTestUser(String permissionSet) {
        return (new VATEST_UserBuilder())
            .withStandardData()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSets(new Set<String>(new List<String>{ permissionSet, 'HealthCloudFoundation' }))
            .build(true);
    }

    /**
     * @description Creates Admin test user
     * @justification System admin is needed to create and insert the test account, contact, case, case share, addendum share, addendum and progress note records for the methods insertTestProgressNote and insertTestAddendumAndShare
     * @return      `User`
     */
    private static User createAdminUser() {
        return (new VATEST_UserBuilder())
            .withStandardData()
            .withUserProfile('System Administrator')
            .withPermissionSets(new Set<String>(new List<String>{ 'VCC_Registered_Nurse', 'HealthCloudFoundation' }))
            .build(true);
    }

    /**
     * @description Helper method to create write note mock response
     * @return      `StaticResourceCalloutMock`
     */
    private static StaticResourceCalloutMock getWriteNoteMock() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStatusCode(200);
        mock.setStaticResource('VCC_vdifWriteNoteMockResponse');
        return mock;
    }

    /**
     * @description Creates and inserts a test account, contact, case, case share, and progress note records
     * @param testUser `User` - user info for sharing
     * @param caseRecordType `String` -  case record type
     * @param progressNoteRecordType `String` - progress note record type
     * @return                       `VCC_Progress_Note__c`
     */
    public static VCC_Progress_Note__c insertTestProgressNote(
        User testUser,
        String caseRecordType,
        String progressNoteRecordType
    ) {
        Account testAccount = (Account) VATEST_SObjectFactory.createSObject(new Account(), null, true, false);

        Contact testContact = (Contact) VATEST_SObjectFactory.createSObject(
            new Contact(FirstName = 'Test', LastName = 'Test', User_ID__c = testUser.Id, AccountId = testAccount.Id),
            null,
            true,
            false
        );

        Case testCase = (Case) VATEST_SObjectFactory.createSObject(
            new Case(
                RecordTypeId = new VCR_CaseRepo().recordTypeConstant.fromDeveloperName(caseRecordType).Id,
                VCC_Caller_Relation__c = 'Self',
                ContactId = testContact.Id
            ),
            null,
            true,
            false
        );

        CaseShare testCaseShare = (CaseShare) VATEST_SObjectFactory.createSObject(
            new CaseShare(CaseId = testCase.Id, CaseAccessLevel = 'Edit', UserOrGroupId = testUser.Id),
            null,
            true,
            false
        );

        VCC_Progress_Note__c progressNote = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
            new VCC_Progress_Note__c(
                VCC_Case__r = testCase,
                VCC_Case__c = testCase.Id,
                VCC_Relative_Type__c = 'Self',
                VCC_Caller_Name_Text__c = 'test',
                VCC_Nurse_Summary__c = '\u1000',
                RecordTypeId = new VCR_ProgressNoteRepo()
                    .recordTypeConstant.fromDeveloperName(progressNoteRecordType)
                    .Id
            ),
            null,
            true,
            false
        );
        return progressNote;
    }

    /**
     * @description Helper method to create progress note parameters
     * @param progressNoteRecordType `String` - progress note record type
     * @return      `VCC_Adapter_NoteToVdif.Parameters`
     */
    private static VCC_Adapter_NoteToVdif.Parameters createParameters(String progressNoteRecordType) {
        VCC_Adapter_NoteToVdif.Parameters params = new VCC_Adapter_NoteToVdif.Parameters();
        params.progressNoteConfig = new VCC_ProgressNoteConfigSelector()
            .selectByRecordTypeApiName(progressNoteRecordType);
        params.noteAndEncounterParams = new VCC_Vdif_NoteAndEncounterParams();
        params.patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();

        params.noteAndEncounterParams.encounterString = 'test';
        params.patientAndProviderParams.providerName = 'test';
        params.patientAndProviderParams.providerLoginSiteCode = 'test';
        params.patientAndProviderParams.providerUserId = 'test';
        params.patientAndProviderParams.patientLocalPid = 699;
        params.noteAndEncounterParams.noteAndEncounterNoteTitleIen = 'test';
        return params;
    }

    /**
     * @description Helper method to create addendum mock response
     * @return      `StaticResourceCalloutMock`
     */
    private static StaticResourceCalloutMock getAddendumMock() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStatusCode(200);
        mock.setStaticResource('VCC_vdifCreateAddendumMockResponse');
        return mock;
    }

    /**
     * @description    Creates and inserts addendum and addendum share records
     * @param testUser `User` - user info for sharing
     * @return         `VCC_Addendum__c`
     */
    private static VCC_Addendum__c insertTestAddendumAndShare(User testUser) {
        VCC_Addendum__c addendum = (VCC_Addendum__c) VATEST_SObjectFactory.createSObject(
            new VCC_Addendum__c(VCC_Addendum__c = 'hello\u1000'),
            null,
            true,
            false
        );

        VCC_Addendum__Share addendumShare = (VCC_Addendum__Share) VATEST_SObjectFactory.createSObject(
            new VCC_Addendum__Share(ParentId = addendum.Id, AccessLevel = 'Edit', UserOrGroupId = testUser.Id),
            null,
            true,
            false
        );
        return addendum;
    }

    /**
     * @description Helper method to create addednum parameters
     * @return      `VCC_Adapter_NoteToVdif.Parameters`
     */
    private static VCC_Adapter_NoteToVdif.Parameters createAddendumParameters() {
        VCC_Adapter_NoteToVdif.Parameters params = new VCC_Adapter_NoteToVdif.Parameters();
        params.progressNoteConfig = new VCC_ProgressNoteConfigSelector().selectByRecordTypeApiName('VCC_Addendum__c');
        params.noteAndEncounterParams = new VCC_Vdif_NoteAndEncounterParams();
        params.patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();

        params.noteAndEncounterParams.itemId = 'test';
        params.noteAndEncounterParams.noteAndEncounterNoteTitleIen = 'tes';
        params.patientAndProviderParams.providerUserId = 'test';
        params.patientAndProviderParams.providerLoginSiteCode = 'test';
        return params;
    }

    /**
     * @description  Calls VCC_Adapter_NoteToVdif.writeNote and asserts results
     * @param params `VCC_Adapter_NoteToVdif.Parameters` - progress note or addendum parameters
     * @param testUser `User` - test user to run tests with
     */
    private static void writeNoteAndAssertResults(VCC_Adapter_NoteToVdif.Parameters params, User testUser) {
        System.runAs(testUser) {
            try {
                List<String> adapterOutputs = VCC_Adapter_NoteToVdif.writeNote(
                    new List<VCC_Adapter_NoteToVdif.Parameters>{ params }
                );
                Assert.isNotNull(adapterOutputs, 'Expected non-null return value.');
                Assert.isInstanceOfType(adapterOutputs, List<String>.class, 'Expected list of strings to be returned.');
                Assert.isNotNull(adapterOutputs.get(0), 'Expected one non-null value at index 0.');
            } catch (Exception thrownException) {
                Assert.fail(
                    'Unexpected exception thrown. Expected VCC_Adapter_NoteToVdif.writeNote to return a List of strings without errors. Received this error instead: ' +
                        thrownException.getMessage() +
                        thrownException.getStackTraceString()
                );
            }
        }
    }

    /// Unit Tests
    /**
     * @description Tests VCC_Adapter_NoteToVdif.writeNote for a progress note for RNs
     * @justification System admin is needed to create and insert the test account, contact, case, case share, and progress note records for the method insertTestProgressNote
     */
    @IsTest
    public static void unitWriteNoteRNPositive() {
        User rnUser = createTestUser(VCC_RN_USER);
        VCC_Adapter_NoteToVdif.Parameters params;
        VCC_Progress_Note__c progressNote;
        System.runAs(VCC_ADMIN_USER) {
            Test.setMock(HttpCalloutMock.class, getWriteNoteMock());
            progressNote = insertTestProgressNote(
                rnUser,
                'VCC_Clinical_Triage',
                'VCC_Clinical_Triage_Note_Progress_Note'
            );
            params = createParameters('VCC_Clinical_Triage_Note_Progress_Note');
        }
        Test.startTest();
        params.noteSObject = progressNote;
        writeNoteAndAssertResults(params, rnUser);
        Test.stopTest();
    }

    /**
     * @description Tests VCC_Adapter_NoteToVdif.writeNote for an addendum for RNs
     * @justification System admin is needed to create and insert the test addendum share and addendum records for the method insertTestAddendumAndShare
     */
    @IsTest
    public static void unitWriteNoteAddendumRNPositive() {
        User rnUser = createTestUser(VCC_RN_USER);
        VCC_Addendum__c addendum;
        VCC_Adapter_NoteToVdif.Parameters params;
        System.runAs(VCC_ADMIN_USER) {
            Test.setMock(HttpCalloutMock.class, getAddendumMock());
            addendum = insertTestAddendumAndShare(rnUser);
            params = createAddendumParameters();
        }
        Test.startTest();
        params.noteSObject = new VCC_Addendum__c(Id = addendum.Id);
        writeNoteAndAssertResults(params, rnUser);
        Test.stopTest();
    }

    /**
     * @description Tests VCC_Adapter_NoteToVdif.writeNote for a progress note for VCV MPs
     * @justification System admin is needed to create and insert the test account, contact, case, case share, and progress note records for the method insertTestProgressNote
     */
    @IsTest
    public static void unitWriteNoteVCVPositive() {
        User vcvUser = createTestUser(VCC_VCV_USER);
        VCC_Adapter_NoteToVdif.Parameters params;
        VCC_Progress_Note__c progressNote;
        System.runAs(VCC_ADMIN_USER) {
            Test.setMock(HttpCalloutMock.class, getWriteNoteMock());
            progressNote = insertTestProgressNote(
                vcvUser,
                'VCC_Vitrual_Clinic_Visit',
                'VCC_Virtual_Visit_Progress_Note'
            );
            params = createParameters('VCC_Virtual_Visit_Progress_Note');
        }
        Test.startTest();
        params.noteSObject = progressNote;
        writeNoteAndAssertResults(params, vcvUser);
        Test.stopTest();
    }

    /**
     * @description Tests VCC_Adapter_NoteToVdif.writeNote for an addendum for VCV MPs
     * @justification System admin is needed to create and insert the test addendum share and addendum records for the method insertTestAddendumAndShare
     */
    @IsTest
    public static void unitWriteNoteAddendumVCVPositive() {
        User vcvUser = createTestUser(VCC_VCV_USER);
        VCC_Addendum__c addendum;
        VCC_Adapter_NoteToVdif.Parameters params;
        System.runAs(VCC_ADMIN_USER) {
            Test.setMock(HttpCalloutMock.class, getAddendumMock());
            addendum = insertTestAddendumAndShare(vcvUser);
            params = createAddendumParameters();
        }
        Test.startTest();
        params.noteSObject = new VCC_Addendum__c(Id = addendum.Id);
        writeNoteAndAssertResults(params, vcvUser);
        Test.stopTest();
    }

    /**
     * @description Tests VCC_Adapter_NoteToVdif.writeNote for a progress note for MSAs
     * @justification System admin is needed to create and insert the test account, contact, case, case share, and progress note records for the method insertTestProgressNote
     */
    @IsTest
    public static void unitWriteNoteMSAPositive() {
        User msaUser = createTestUser(VCC_MSA_USER);
        VCC_Adapter_NoteToVdif.Parameters params;
        VCC_Progress_Note__c progressNote;
        System.runAs(VCC_ADMIN_USER) {
            Test.setMock(HttpCalloutMock.class, getWriteNoteMock());
            progressNote = insertTestProgressNote(msaUser, 'VCC_Administrative', 'VCC_Scheduling_Progress_Note');
            params = createParameters('VCC_Scheduling_Progress_Note');
        }
        Test.startTest();
        params.noteSObject = progressNote;
        writeNoteAndAssertResults(params, msaUser);
        Test.stopTest();
    }

    /**
     * @description Tests VCC_Adapter_NoteToVdif.writeNote for an addendum for MSAs
     * @justification System admin is needed to create and insert the test addendum share and addendum records for the method insertTestAddendumAndShare
     */
    @IsTest
    public static void unitWriteNoteAddendumMSAPositive() {
        User msaUser = createTestUser(VCC_MSA_USER);
        VCC_Addendum__c addendum;
        VCC_Adapter_NoteToVdif.Parameters params;
        System.runAs(VCC_ADMIN_USER) {
            Test.setMock(HttpCalloutMock.class, getAddendumMock());
            addendum = insertTestAddendumAndShare(msaUser);
            params = createAddendumParameters();
        }
        Test.startTest();
        params.noteSObject = new VCC_Addendum__c(Id = addendum.Id);
        writeNoteAndAssertResults(params, msaUser);
        Test.stopTest();
    }

    /**
     * @description Tests VCC_Adapter_NoteToVdif.writeNote for a progress note for Pharm I
     * @justification System admin is needed to create and insert the test account, contact, case, case share, and progress note records for the method insertTestProgressNote
     */
    @IsTest
    public static void unitWriteNotePharm1Positive() {
        User pharmIUser = createTestUser(VCC_PHARM_I_USER);
        VCC_Adapter_NoteToVdif.Parameters params;
        VCC_Progress_Note__c progressNote;
        System.runAs(VCC_ADMIN_USER) {
            Test.setMock(HttpCalloutMock.class, getWriteNoteMock());
            progressNote = insertTestProgressNote(pharmIUser, 'VCC_Pharmacy', 'VCC_Tier_I_Progress_Note');
            params = createParameters('VCC_Tier_I_Progress_Note');
        }
        Test.startTest();
        params.noteSObject = progressNote;
        writeNoteAndAssertResults(params, pharmIUser);
        Test.stopTest();
    }

    /**
     * @description Tests VCC_Adapter_NoteToVdif.writeNote for an addendum for Pharm I
     * @justification System admin is needed to create and insert the test addendum share and addendum records for the method insertTestAddendumAndShare
     */
    @IsTest
    public static void unitWriteNoteAddendumPharm1Positive() {
        User pharmIUser = createTestUser(VCC_PHARM_I_USER);
        VCC_Addendum__c addendum;
        VCC_Adapter_NoteToVdif.Parameters params;
        System.runAs(VCC_ADMIN_USER) {
            Test.setMock(HttpCalloutMock.class, getAddendumMock());
            addendum = insertTestAddendumAndShare(pharmIUser);
            params = createAddendumParameters();
        }
        Test.startTest();
        params.noteSObject = new VCC_Addendum__c(Id = addendum.Id);
        writeNoteAndAssertResults(params, pharmIUser);
        Test.stopTest();
    }

    /**
     * @description Tests VCC_Adapter_NoteToVdif.writeNote for a progress note for Pharm II
     * @justification System admin is needed to create and insert the test account, contact, case, case share, and progress note records for the method insertTestProgressNote
     */
    @IsTest
    public static void unitWriteNotePharm2Positive() {
        User pharmIIUser = createTestUser(VCC_PHARM_II_USER);
        VCC_Adapter_NoteToVdif.Parameters params;
        VCC_Progress_Note__c progressNote;
        System.runAs(VCC_ADMIN_USER) {
            Test.setMock(HttpCalloutMock.class, getWriteNoteMock());
            progressNote = insertTestProgressNote(pharmIIUser, 'VCC_Pharmacy', 'VCC_Tier_II_Progress_Note');
            params = createParameters('VCC_Tier_II_Progress_Note');
        }
        Test.startTest();
        params.noteSObject = progressNote;
        writeNoteAndAssertResults(params, pharmIIUser);
        Test.stopTest();
    }

    /**
     * @description Tests VCC_Adapter_NoteToVdif.writeNote for an addendum for Pharm II
     * @justification System admin is needed to create and insert the test addendum share and addendum records for the method insertTestAddendumAndShare
     */
    @IsTest
    public static void unitWriteNoteAddendumPharm2Positive() {
        User pharmIIUser = createTestUser(VCC_PHARM_II_USER);
        VCC_Addendum__c addendum;
        VCC_Adapter_NoteToVdif.Parameters params;
        System.runAs(VCC_ADMIN_USER) {
            Test.setMock(HttpCalloutMock.class, getAddendumMock());
            addendum = insertTestAddendumAndShare(pharmIIUser);
            params = createAddendumParameters();
        }
        Test.startTest();
        params.noteSObject = new VCC_Addendum__c(Id = addendum.Id);
        writeNoteAndAssertResults(params, pharmIIUser);
        Test.stopTest();
    }

    /**
     * @description Tests VCC_Adapter_NoteToVdif.writeNote for a progress note for Pharm III
     * @justification System admin is needed to create and insert the test account, contact, case, case share, and progress note records for the method insertTestProgressNote
     */
    @IsTest
    public static void unitWriteNotePharm3Positive() {
        User pharmIIIUser = createTestUser(VCC_PHARM_III_USER);
        VCC_Adapter_NoteToVdif.Parameters params;
        VCC_Progress_Note__c progressNote;
        System.runAs(VCC_ADMIN_USER) {
            Test.setMock(HttpCalloutMock.class, getWriteNoteMock());
            progressNote = insertTestProgressNote(pharmIIIUser, 'VCC_Pharmacy', 'VCC_Tier_III_Progress_Note');
            params = createParameters('VCC_Tier_III_Progress_Note');
        }
        Test.startTest();
        params.noteSObject = progressNote;
        writeNoteAndAssertResults(params, pharmIIIUser);
        Test.stopTest();
    }

    /**
     * @description Tests VCC_Adapter_NoteToVdif.writeNote for an addendum for Pharm III
     * @justification System admin is needed to create and insert the test addendum share and addendum records for the method insertTestAddendumAndShare
     */
    @IsTest
    public static void unitWriteNoteAddendumPharm3Positive() {
        User pharmIIIUser = createTestUser(VCC_PHARM_III_USER);
        VCC_Addendum__c addendum;
        VCC_Adapter_NoteToVdif.Parameters params;
        System.runAs(VCC_ADMIN_USER) {
            Test.setMock(HttpCalloutMock.class, getAddendumMock());
            addendum = insertTestAddendumAndShare(pharmIIIUser);
            params = createAddendumParameters();
        }
        Test.startTest();
        params.noteSObject = new VCC_Addendum__c(Id = addendum.Id);
        writeNoteAndAssertResults(params, pharmIIIUser);
        Test.stopTest();
    }

    /**
     * @description Tests VCC_Adapter_NoteToVdif.writeNote for a progress note for Tele-EC MP
     * @justification System admin is needed to create and insert the test account, contact, case, case share, and progress note records for the method insertTestProgressNote
     */
    @IsTest
    public static void unitWriteNoteTeleEcMPPositive() {
        User teleEcMpUser = createTestUser(VCC_TELE_EC_MP_USER);
        VCC_Adapter_NoteToVdif.Parameters params;
        VCC_Progress_Note__c progressNote;
        System.runAs(VCC_ADMIN_USER) {
            Test.setMock(HttpCalloutMock.class, getWriteNoteMock());
            progressNote = insertTestProgressNote(teleEcMpUser, 'Tele_Urgent_Care_2_8_Hours_Case', 'TUC_Virtual_Visit');
            params = createParameters('TUC_Virtual_Visit');
        }
        Test.startTest();
        params.noteSObject = progressNote;
        writeNoteAndAssertResults(params, teleEcMpUser);
        Test.stopTest();
    }

    /**
     * @description Tests VCC_Adapter_NoteToVdif.writeNote for an addendum for Tele-EC MP
     * @justification System admin is needed to create and insert the test addendum share and addendum records for the method insertTestAddendumAndShare
     */
    @IsTest
    public static void unitWriteNoteAddendumTeleEcMPPositive() {
        User teleEcMpUser = createTestUser(VCC_TELE_EC_MP_USER);
        VCC_Addendum__c addendum;
        VCC_Adapter_NoteToVdif.Parameters params;
        System.runAs(VCC_ADMIN_USER) {
            Test.setMock(HttpCalloutMock.class, getAddendumMock());
            addendum = insertTestAddendumAndShare(teleEcMpUser);
            params = createAddendumParameters();
        }
        Test.startTest();
        params.noteSObject = new VCC_Addendum__c(Id = addendum.Id);
        writeNoteAndAssertResults(params, teleEcMpUser);
        Test.stopTest();
    }

    /**
     * @description Tests VCC_Adapter_NoteToVdif.writeNote for a progress note for Tele-EC RN
     * @justification System admin is needed to create and insert the test account, contact, case, case share, and progress note records for the method insertTestProgressNote
     */
    @IsTest
    public static void unitWriteNoteTeleEcRNPositive() {
        User teleEcRnUser = createTestUser(VCC_TELE_EC_RN_USER);
        VCC_Adapter_NoteToVdif.Parameters params;
        VCC_Progress_Note__c progressNote;
        System.runAs(VCC_ADMIN_USER) {
            Test.setMock(HttpCalloutMock.class, getWriteNoteMock());
            progressNote = insertTestProgressNote(
                teleEcRnUser,
                'Tele_Urgent_Care_0_2_Hours',
                'TUC_Consultation_with_Triage_RN'
            );
            params = createParameters('TUC_Consultation_with_Triage_RN');
        }
        Test.startTest();
        params.noteSObject = progressNote;
        writeNoteAndAssertResults(params, teleEcRnUser);
        Test.stopTest();
    }

    /**
     * @description Tests VCC_Adapter_NoteToVdif.writeNote for an addendum for Tele-EC RN
     * @justification System admin is needed to create and insert the test addendum share and addendum records for the method insertTestAddendumAndShare
     */
    @IsTest
    public static void unitWriteNoteAddendumTeleEcRNPositive() {
        User teleEcRnUser = createTestUser(VCC_TELE_EC_RN_USER);
        VCC_Addendum__c addendum;
        VCC_Adapter_NoteToVdif.Parameters params;
        System.runAs(VCC_ADMIN_USER) {
            Test.setMock(HttpCalloutMock.class, getAddendumMock());
            addendum = insertTestAddendumAndShare(teleEcRnUser);
            params = createAddendumParameters();
        }
        Test.startTest();
        params.noteSObject = new VCC_Addendum__c(Id = addendum.Id);
        writeNoteAndAssertResults(params, teleEcRnUser);
        Test.stopTest();
    }

    /**
     * @description Tests VCC_Adapter_NoteToVdif.parseLWC
     * @justification System admin is needed to create and insert the test account, contact, case, case share, and progress note records for the method insertTestProgressNote
     */
    @IsTest
    public static void unitParseLWCPositive() {
        User vcvUser = createTestUser(VCC_VCV_USER);
        VCC_Progress_Note__c progressNote;
        System.runAs(VCC_ADMIN_USER) {
            progressNote = insertTestProgressNote(
                vcvUser,
                'VCC_Vitrual_Clinic_Visit',
                'VCC_Virtual_Visit_Progress_Note'
            );
        }
        System.runAs(vcvUser) {
            Test.startTest();
            try {
                List<String> result = VCC_Adapter_NoteToVdif.parseLWC(progressNote.Id, progressNote.RecordTypeId);
                Assert.isNotNull(result, 'Expected result string to not be null');
            } catch (Exception thrownException) {
                Assert.fail(
                    'Unexpected exception thrown. Expected VCC_Adapter_NoteToVdif.parseLWC to return a List of strings without errors. Received this error instead: ' +
                        thrownException.getMessage() +
                        thrownException.getStackTraceString()
                );
            }
            Test.stopTest();
        }
    }

    /**
     * @description Tests VCC_Adapter_NoteToVdif.parse overloaded DAS method
     * @justification System admin is needed to create and insert the test account, contact, case, case share, and progress note records for the method insertTestProgressNote
     */
    @IsTest
    public static void unitParseDasPositive() {
        User rnUser = createTestUser(VCC_RN_USER);
        VCC_Progress_Note__c progressNote;
        List<VCC_Progress_Note_Custom_Section__mdt> customSectionList;
        System.runAs(VCC_ADMIN_USER) {
            progressNote = insertTestProgressNote(
                rnUser,
                'VCC_Clinical_Triage',
                'VCC_Clinical_Triage_Note_Progress_Note'
            );
            customSectionList = new List<VCC_Progress_Note_Custom_Section__mdt>{};
        }
        System.runAs(rnUser) {
            Test.startTest();
            try {
                String result = VCC_Adapter_NoteToVdif.parse(
                    (SObject) progressNote,
                    (new VCC_ProgressNoteConfigSelector()
                        .selectByRecordTypeApiName('VCC_Clinical_Triage_Note_Progress_Note')),
                    customSectionList
                );
                Assert.isNotNull(result, 'Expected result string to not be null');
            } catch (Exception thrownException) {
                Assert.fail(
                    'Unexpected exception thrown. Expected VCC_Adapter_NoteToVdif.parse to return a string without errors. Received this error instead: ' +
                        thrownException.getMessage() +
                        thrownException.getStackTraceString()
                );
            }
            Test.stopTest();
        }
    }
}
