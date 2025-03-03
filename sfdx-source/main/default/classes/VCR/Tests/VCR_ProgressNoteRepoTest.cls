/**
 * @author Booz Allen Hamilton
 * @date 2/14/24
 * @description  Tests for VCR_ProgressNoteRepo class.
 * @group Depeche Code
 * @see VCR_ProgressNoteRepo
 *
 * NOTE: Suppressing warning for PMD.ApexUnitTestClassShouldHaveRunAs as there is no need to use System.RunAs for the
 *  Repository functional tests.
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest
public with sharing class VCR_ProgressNoteRepoTest {
    private static final String QUERY_STRING =
        'SELECT ID, VCC_Case_Metrics__c, VCC_Case__c ' +
        'FROM VCC_Progress_Note__c ' +
        'WHERE VCC_Case_Metrics__c = ' +
        null;
    /**
     * @description Build test data for use in test methods
     */
    @TestSetup
    private static void buildData() {
        Id caseRecTypeId = new VCR_CaseRepo().recordTypeConstant.fromDeveloperName('VCC_Clinical_Triage').Id;

        Id pnRecTypeId = new VCR_ProgressNoteRepo()
            .recordTypeConstant.fromDeveloperName('VCC_Clinical_Triage_Note_Progress_Note')
            .Id;
        //VCC_Progress_Note__c progNote = new VCC_Progress_Note__c(VCC_Case__c = testCase.Id, RecordTypeId = pnRecTypeId);

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

        Case testCase = (Case) VATEST_SObjectFactory.createSObject(
            new Case(RecordTypeId = caseRecTypeId, VCC_Case_Type__c = 'Symptom', ContactId = testContact.Id),
            true
        );

        VATEST_SObjectFactory.createSObject(
            new VCC_Progress_Note__c(
                VCC_Case__c = testCase.Id,
                RecordTypeId = pnRecTypeId,
                VCC_Caregiver_Name__c = 'Unit Test'
            ),
            true
        );
    }

    private static Case getSingleCaseRecord() {
        return [
            SELECT Id
            FROM Case
            LIMIT 1
        ];
    }

    private static VCC_Progress_Note__c getSingleProgressNoteRecord() {
        return [
            SELECT Id
            FROM VCC_Progress_Note__c
            LIMIT 1
        ];
    }

    /**
     * @description Test fetchById() for success path
     */
    @IsTest
    static void unitTestConstructorPositive() {
        Test.startTest();
        VCR_ProgressNoteRepo repo = new VCR_ProgressNoteRepo();
        Test.stopTest();
        Assert.isNotNull(repo, 'Expected constructor to properly instantiate a VCR_ProgressNoteRepo');
    }

    /**
     * @description Test fetching Progress Notes with Case ID for success path
     */
    @IsTest
    static void fetchProgressNoteFromCaseIdPositiveTest() {
        Case testCase = getSingleCaseRecord();
        VCC_Progress_Note__c progNote = getSingleProgressNoteRecord();
        Test.startTest();
        VCR_ProgressNoteRepo repo = new VCR_ProgressNoteRepo();
        List<VCC_Progress_Note__c> testPNotes = repo.fetchProgressNoteFromCaseId(testCase.Id);
        Test.stopTest();
        Assert.areEqual(progNote.Id, testPNotes[0].Id, 'Expected Progress Note IDs to match');
    }

    /**
     * @description method to create a test user
     * @return `User` returns a user to be used for testing
     */
    private static User createTestUser() {
        return new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
    }

    /**
     * @description method to create a test admin user
     * @return `User` returns a user to be used for testing
     */
    private static User createTestAdminUser() {
        return new VATEST_UserBuilder()
            .withUserProfile('System Administrator')
            .withPermissionSet('VAHC_Write_Clinical_Triage_Progress_Note')
            .withPermissionSet('VCC_Pharmacy_II_User')
            .withPermissionSet('VAHC_Standard_VCC_User')
            .withPermissionSet('VAHC_Write_Tier_II_Progress_Note')
            .withStandardData()
            .build(true);
    }

    @IsTest
    /**
     * @description functional test method to ensure initialization was successful
     */
    private static void funcEnsureCorrectDefaultInitialization() {
        User adminUser = createTestAdminUser();
        System.runAs(adminUser) {
            Test.startTest();
            VCR_ProgressNoteRepo pNoteRepo = new VCR_ProgressNoteRepo();
            Assert.isTrue(pNoteRepo != null, 'Expected class to be initialized.');
            Assert.isTrue(VCR_ProgressNoteRepo.patientService != null, 'Expected patientService to be initialized.');
            Test.stopTest();
        }

    }

    @IsTest
    /**
     * @description unit test checking that data is returned with mock data
     */
    private static void unitGetPNotesReturnsValidDataWhenMockedPositive() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCR_ProgressNoteRepo.patientService = mockPatientServiceStub(args, new VTC_DataModel());
        User vaVetUser = createTestUser();

        System.runAs(vaVetUser) {
            Test.startTest();
            //args is the arguments to pass to the provider, in this case the fake ICN
            VTC_DataModel pNoteDataModel = (VTC_DataModel) new VCR_ProgressNoteRepo().fetchNotes(args);
            Assert.isTrue(pNoteDataModel != null, 'Expected valid non-null model to be returned.');
            Test.stopTest();
        }
    }

    @IsTest
    /**
     * @description unit test checking that data is returned with mock data
     */
    private static void unitGetDirectivesReturnsValidDataWhenMockedPositive() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCR_ProgressNoteRepo.patientService = mockPatientServiceStub(args, new VTC_DataModel());
        User vaVetUser = createTestUser();

        System.runAs(vaVetUser) {
            Test.startTest();
            //args is the arguments to pass to the provider, in this case the fake ICN
            VTC_DataModel directivesDataModel = (VTC_DataModel) new VCR_ProgressNoteRepo().fetchDirectives(args);
            Assert.isNotNull(directivesDataModel, 'Expected valid non-null model to be returned.');
            Test.stopTest();
        }
    }
    /**
     * @description method to build VTC_PatientService stub
     * @param args The arguments to pass to the provider
     * @param returnValue the object to be returned
     * @return `VTC_PatientService`
     */
    private static VTC_PatientService mockPatientServiceStub(Map<String, Object> args, Object returnValue) {
        return (VTC_PatientService) new VATEST_StubBuilder(VTC_PatientService.class)
            .mockingMethodCall('call')
            .withParameterTypes(String.class, Map<String, Object>.class)
            .withParameterValues('get_notes', args)
            .returning(returnValue)
            .mockingMethodCall('call')
            .withParameterTypes(String.class, Map<String, Object>.class)
            .withParameterValues('get_directives', args)
            .returning(returnValue)
            .defineStub();
    }

    /**
     * @description Test getting the dynamic queryLocatorString.
     * Positve test case for getQueryLocatorString()
     * @see VCR_ProgressNoteRepo.getQueryLocatorString()
     */
    @IsTest
    static void unitTestGetQueryLocatorStringPositive() {
        User adminUser = createTestAdminUser();
        System.runAs(adminUser) {
            VCR_ProgressNoteRepo repo;
            String queryString;
            Test.startTest();
            repo = new VCR_ProgressNoteRepo();
            queryString = repo.getQueryLocatorString();
            Test.stopTest();
            Assert.areEqual(
                QUERY_STRING,
                queryString,
                'Expected the getQueryString() method to return the correct query string'
            );
        }
    }

    /**
     * @description Positve test case for updateProgressNotes()
     * @see VCR_ProgressNoteRepo.updateProgressNotes()
     */
    @IsTest
    static void unitTestUpdateProgressNotesPositive() {
        User adminUser = createTestAdminUser();
        System.runAs(adminUser) {
            List<VCC_Progress_Note__c> pnList = new List<VCC_Progress_Note__c>();
            User provider = (User) VATEST_UserFactory.createTestUser('VAVET Base Profile', true);
            String recordTypeId = new VCR_CaseRepo()
                .recordTypeConstant.fromDeveloperName('VCC_Vitrual_Clinic_Visit')
                .Id;
            List<Case> pnCases = (List<Case>) VATEST_SObjectFactory.createSObjects(
                new Case(OwnerId = provider.Id, RecordTypeId = recordTypeId),
                5,
                true
            );

            for (Integer count = 0; count < pnCases.size(); count++) {
                VCC_Progress_Note__c progressNote = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
                    new VCC_Progress_Note__c(
                        VCC_Case__c = pnCases[count].Id,
                        VCC_Progress_Note_Title_IEN__c = 'CM PNotes'
                    ),
                    true
                );
                pnList.add(progressNote);
            }

            List<VCC_Progress_Note__c> newList = new List<VCC_Progress_Note__c>();
            for (VCC_Progress_Note__c pnote : pnList) {
                VCC_Progress_Note__c newNote = new VCC_Progress_Note__c(
                    Id = pnote.Id,
                    VCC_Progress_Note_Title_IEN__c = 'PNotes Updated'
                );
                newList.add(newNote);
            }

            VCR_ProgressNoteRepo repo;
            Test.startTest();
            repo = new VCR_ProgressNoteRepo();
            List<Database.SaveResult> results = repo.updateProgressNotes(newList);
            Test.stopTest();

            List<VCC_Progress_Note__c> progressNotesList = [
                SELECT Id, VCC_Case_Metrics__c, VCC_Case__c
                FROM VCC_Progress_Note__c
                WHERE VCC_Progress_Note_Title_IEN__c = 'PNotes Updated'
            ];

            Assert.areEqual(results.size(), progressNotesList.size(), 'Expected 5 results returned');
        }
    }

    /**
     * @description Test getting the dynamic queryLocatorString.
     * Negative test case for updateProgressNotes()
     * @see VCR_ProgressNoteRepo.updateProgressNotes()
     */
    @IsTest
    static void unitTestUpdateProgressNotesNegative() {
        User adminUser = createTestAdminUser();
        System.runAs(adminUser) {
            List<VCC_Progress_Note__c> pnList = new List<VCC_Progress_Note__c>();
            User provider = (User) VATEST_UserFactory.createTestUser('VAVET Base Profile', true);
            String recordTypeId = new VCR_CaseRepo()
                .recordTypeConstant.fromDeveloperName('VCC_Vitrual_Clinic_Visit')
                .Id;
            List<Case> pnCases = (List<Case>) VATEST_SObjectFactory.createSObjects(
                new Case(OwnerId = provider.Id, RecordTypeId = recordTypeId),
                5,
                true
            );

            for (Integer count = 0; count < pnCases.size(); count++) {
                VCC_Progress_Note__c progressNote = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
                    new VCC_Progress_Note__c(
                        VCC_Case__c = pnCases[count].Id,
                        VCC_Progress_Note_Title_IEN__c = 'CM PNotes'
                    ),
                    true
                );
                pnList.add(progressNote);
            }

            for (Integer count = 0; count < pnList.size(); count++) {
                pnList[count].VCC_Progress_Note_Title_IEN__c = 'TOO LONG OF A VALUE FOR FIELD';
            }

            VCR_ProgressNoteRepo repo;
            List<Database.SaveResult> results;
            Boolean isExceptionThrown = false;
            Test.startTest();
            repo = new VCR_ProgressNoteRepo();
            try {
                results = repo.updateProgressNotes(pnList);
            } catch (Exception expectedException) {
                isExceptionThrown = true;
            }
            Test.stopTest();
            Assert.isNull(results, 'Expected the updateProgressNotes() method to not be called successfully');
            Assert.isTrue(isExceptionThrown, 'Expected the updateProgressNotes() method to throw a HandledException');
        }
    }

    /**
     * @description Test getting the dynamic queryLocator.
     * Positve test case for getQueryLocator()
     * @see VCR_ProgressNoteRepo.getQueryLocator()
     */
    @IsTest
    static void unitTestGetQueryLocatorPositive() {
        User adminUser = createTestAdminUser();
        System.runAs(adminUser) {
            VCR_ProgressNoteRepo repo;
            Database.QueryLocator queryLocator;
            Test.startTest();
            repo = new VCR_ProgressNoteRepo();
            queryLocator = repo.getQueryLocator(QUERY_STRING);
            Test.stopTest();
            Assert.areEqual(
                QUERY_STRING,
                queryLocator.getQuery(),
                'Expected the getQueryString() method to return the correct query string'
            );
        }
    }

    /**
     * @description Test getting the dynamic queryLocator.
     * Negative test case for getQueryLocator()
     * @see VCR_ProgressNoteRepo.getQueryLocator()
     */
    @IsTest
    static void unitTestGetQueryLocatorNegative() {
        User adminUser = createTestAdminUser();
        System.runAs(adminUser) {
            VCR_ProgressNoteRepo repo;
            Boolean isExceptionThrown = false;
            Database.QueryLocator queryLocator;
            Test.startTest();
            repo = new VCR_ProgressNoteRepo();
            try {
                queryLocator = repo.getQueryLocator(null);
            } catch (Exception expectedException) {
                isExceptionThrown = true;
            }
            Test.stopTest();
            Assert.isNull(queryLocator, 'Expected the getQueryLocator() method to not be called successfully');
            Assert.isTrue(isExceptionThrown, 'Expected the getQueryLocator() method to throw a HandledException');
        }
    }

    /**
     * @description unit test of fetching unsigned notes from case ID
     * @see VCR_ProgressNoteRepo.fetchUnsignedProgressNotesFromCaseId
     */
    @IsTest
    static void unitFetchUnsignedProgressNoteFromCaseIdPositiveTest() {
        Case testCase = getSingleCaseRecord();
        VCC_Progress_Note__c progNote = getSingleProgressNoteRecord();
        Test.startTest();
        VCR_ProgressNoteRepo repo = new VCR_ProgressNoteRepo();
        List<VCC_Progress_Note__c> testPNotes = repo.fetchUnsignedProgressNotesFromCaseId(testCase.Id);
        Test.stopTest();
        Assert.areEqual(progNote.Id, testPNotes[0].Id, 'Expected to find unsigned note on Case');
    }

    /**
     * @description functional test for inserting progress notes
     * @see VCR_ProgressNoteRepo.insertProgressNotesAllOrNoneFalse
     */
    @IsTest
    static void funcInsertProgressNotesAllOrNoneFalsePositive() {
        User adminUser = createTestAdminUser();
        System.runAs(adminUser) {
            User provider = (User) VATEST_UserFactory.createTestUser('VAVET Base Profile', true);
            String recordTypeId = new VCR_CaseRepo()
                .recordTypeConstant.fromDeveloperName('VCC_Vitrual_Clinic_Visit')
                .Id;
            List<Case> pnCases = (List<Case>) VATEST_SObjectFactory.createSObjects(
                new Case(OwnerId = provider.Id, RecordTypeId = recordTypeId),
                1,
                true
            );
            VCC_Progress_Note__c newNote = new VCC_Progress_Note__c(
                VCC_Case__c = pnCases[0].Id,
                VCC_Progress_Note_Title_IEN__c = 'CM PNotes'
            );

            List<VCC_Progress_Note__c> newList = new List<VCC_Progress_Note__c>();
            newList.add(newNote);

            VCR_ProgressNoteRepo repo;
            Test.startTest();
            repo = new VCR_ProgressNoteRepo(true);
            List<Database.SaveResult> results = repo.insertProgressNotesAllOrNoneFalse(newList);
            Test.stopTest();

            List<VCC_Progress_Note__c> progressNotesList = [
                SELECT Id, VCC_Case_Metrics__c, VCC_Case__c
                FROM VCC_Progress_Note__c
                WHERE VCC_Progress_Note_Title_IEN__c = 'CM PNotes'
            ];

            Assert.areEqual(
                results.size(),
                progressNotesList.size(),
                'Expected 1 progress note to be inserted, got a different result'
            );
        }
    }

    /**
     * @description functional test for inserting progress notes
     * @see VCR_ProgressNoteRepo.insertProgressNotesAllOrNoneFalseUnsafe
     * @justification this method uses doCreateUnsafe because TIERIII users do not currently have access to TIERI Notes in a normal
     * circumstance, but when creating a Note from FRR Task they should be able to create a TierI note
     */
    @IsTest
    static void funcInsertProgressNotesAllOrNoneFalseUnsafePositive() {
        User adminUser = createTestAdminUser();
        System.runAs(adminUser) {
            User provider = (User) VATEST_UserFactory.createTestUser('VAVET Base Profile', true);
            String recordTypeId = new VCR_CaseRepo()
                .recordTypeConstant.fromDeveloperName('VCC_Vitrual_Clinic_Visit')
                .Id;
            List<Case> pnCases = (List<Case>) VATEST_SObjectFactory.createSObjects(
                new Case(OwnerId = provider.Id, RecordTypeId = recordTypeId),
                1,
                true
            );
            VCC_Progress_Note__c newNote = new VCC_Progress_Note__c(
                VCC_Case__c = pnCases[0].Id,
                VCC_Progress_Note_Title_IEN__c = 'CM PNotes'
            );

            List<VCC_Progress_Note__c> newList = new List<VCC_Progress_Note__c>();
            newList.add(newNote);

            VCR_ProgressNoteRepo repo;
            Test.startTest();
            repo = new VCR_ProgressNoteRepo(true);
            List<Database.SaveResult> results = repo.insertProgressNotesAllOrNoneFalseUnsafe(newList);
            Test.stopTest();

            List<VCC_Progress_Note__c> progressNotesList = [
                SELECT Id, VCC_Case_Metrics__c, VCC_Case__c
                FROM VCC_Progress_Note__c
                WHERE VCC_Progress_Note_Title_IEN__c = 'CM PNotes'
            ];

            Assert.areEqual(
                results.size(),
                progressNotesList.size(),
                'Expected 1 progress note to be inserted, got a different result'
            );
        }
    }
}
