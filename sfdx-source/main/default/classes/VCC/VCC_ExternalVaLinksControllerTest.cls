/**
 * @description - test repo inits
 */
@IsTest
public class VCC_ExternalVaLinksControllerTest {
    public static final DateTime TESTING_DATETIME = System.now();

    @IsTest
    private static void funcAllRepoInit() {
        //Building Test User
        User testUser = getTestUser();

        Test.startTest();
        System.runAs(testUser) {
            VCC_ExternalVaLinksController.contactRepo = null;
            VCC_ExternalVaLinksController.caseRepo = null;
            VCC_ExternalVaLinksController.externalVaLinksRepo = null;
            VCC_ExternalVaLinksController.taskRepo = null;
            VCC_ExternalVaLinksController.userUIEventRepo = null;
            VCC_ExternalVaLinksController.e911CustomSetRepo = null;
        }
        Test.stopTest();

        Assert.isNotNull(VCC_ExternalVaLinksController.contactRepo, 'Init of contact repo failed; Expected a non-null');
        Assert.isNotNull(VCC_ExternalVaLinksController.caseRepo, 'Init of case repo failed; Expected a non-null');
        Assert.isNotNull(
            VCC_ExternalVaLinksController.externalVaLinksRepo,
            'Init of external va links repo failed; Expected a non-null'
        );
        Assert.isNotNull(VCC_ExternalVaLinksController.taskRepo, 'Init of task repo failed; Expected a non-null');
        Assert.isNotNull(
            VCC_ExternalVaLinksController.userUIEventRepo,
            'Init of user UI event repo failed; Expected a non-null'
        );
        Assert.isNotNull(
            VCC_ExternalVaLinksController.e911CustomSetRepo,
            'Init of e911 custom settings repo failed; Expected a non-null'
        );
    }

    /**
     * @description - test the retrieval of links for when crm user is true
     */
    @IsTest
    private static void unitTestGetLinksCRMUserPositive() {
        //Building Test User
        VATEST_UserBuilder testUserBuilder = new VATEST_UserBuilder();
        User testUser = testUserBuilder.withUserProfile('VAVET Base Profile')
            .withStandardData()
            .withPermissionSet('VCC_Registered_Nurse')
            .build(true);

        //Building Repo Stubs
        VCR_ExternalVaLinksRepo mockRepo = (VCR_ExternalVaLinksRepo) new VATEST_StubBuilder(
                VCR_ExternalVaLinksRepo.class
            )
            .mockingMethodCall('getVALinksFromAudience', List<String>.class, Integer.class)
            .withParameterValues(new List<String>{ 'ALL', 'VCC' }, 10)
            .returning(
                new List<External_VA_Link__mdt>{
                    new External_VA_Link__mdt(Audience__c = 'All', DeveloperName = 'Test_Link1', Label = 'Test Link 1'),
                    new External_VA_Link__mdt(Audience__c = 'VCC', DeveloperName = 'Test_Link2', Label = 'Test Link 2')
                }
            )
            .defineStub();

        List<External_VA_Link__mdt> result = new List<External_VA_Link__mdt>();
        VCC_ExternalVaLinksController.memoizedExternalVaLinksRepo = mockRepo;
        Test.startTest();
        System.runAs(testUser) {
            result = VCC_ExternalVaLinksController.getLinks(true);
        }
        Test.stopTest();
        Assert.areEqual(result.size(), 2, 'Expected two links');
    }

    /**
     * @description - test the retrieval of links for when crm user is false
     */
    @IsTest
    private static void unitTestGetLinksNonCRMUserPositive() {
        //Building Test User
        VATEST_UserBuilder testUserBuilder = new VATEST_UserBuilder();
        User testUser = testUserBuilder.withUserProfile('VAVET Base Profile')
            .withStandardData()
            .withPermissionSet('TED_Medical_Provider_Group')
            .build(true);

        //Building Repo Stubs
        VCR_ExternalVaLinksRepo mockRepo = (VCR_ExternalVaLinksRepo) new VATEST_StubBuilder(
                VCR_ExternalVaLinksRepo.class
            )
            .mockingMethodCall('getVALinksFromAudience', List<String>.class, Integer.class)
            .withParameterValues(new List<String>{ 'ALL', 'TUC' }, 10)
            .returning(
                new List<External_VA_Link__mdt>{
                    new External_VA_Link__mdt(Audience__c = 'All', DeveloperName = 'Test_Link1', Label = 'Test Link 1'),
                    new External_VA_Link__mdt(Audience__c = 'TUC', DeveloperName = 'Test_Link2', Label = 'Test Link 2')
                }
            )
            .defineStub();

        List<External_VA_Link__mdt> result = new List<External_VA_Link__mdt>();
        VCC_ExternalVaLinksController.memoizedExternalVaLinksRepo = mockRepo;
        Test.startTest();
        System.runAs(testUser) {
            result = VCC_ExternalVaLinksController.getLinks(false);
        }
        Test.stopTest();

        Assert.areEqual(
            VCC_ExternalVaLinksController.externalVaLinksRepo,
            mockRepo,
            'Expected repo to be set to mock repo'
        );
        Assert.areEqual(result.size(), 2, 'Expected two links from repo call');
    }
    /**
     * @description helper method to set up test user
     * @return `user` to be set up
     */
    private static user getTestUser() {
        //Building Test User
        VATEST_UserBuilder testUserBuilder = new VATEST_UserBuilder();
        User testUser = testUserBuilder.withUserProfile('VAVET Base Profile')
            .withStandardData()
            .setFields(User.Division, 'VISN 1')
            .withPermissionSet('TED_Medical_Provider_Group')
            .build(true);
        testUser.TimeZoneSidKey = UserInfo.getTimeZone().getID();
        update testUser;
        return testUser;
    }
    /**
     * @description helper method to build case repo
     * @param testCase need this Case ID for mocked method
     * @return 'mockCaseRepo' the mockCaseRepo
     */
    private static VCR_CaseRepo buildCaseRepo(Case testCase) {
        VCR_CaseRepo mockCaseRepo = (VCR_CaseRepo) new VATEST_StubBuilder(VCR_CaseRepo.class)
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class, Set<String>.class)
            .withParameterValues(testCase.Id, new Set<String>{ 'TUC_Assigned_Facility__c', 'ContactId' })
            .returning(new Case())
            .defineStub();
        return mockCaseRepo;
    }
    /**
     * @description helper method to build progressNote repo
     * @param testProgressNote need this ProgressNote Id for mocked method
     * @return 'mockProgressNoteRepo' the mockProgressNoteRepo
     */
    private static VCR_ProgressNoteRepo buildProgressNoteRepo(VCC_Progress_Note__c testProgressNote) {
        VCR_ProgressNoteRepo mockProgressNoteRepo = (VCR_ProgressNoteRepo) new VATEST_StubBuilder(
                VCR_ProgressNoteRepo.class
            )
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class, Set<String>.class)
            .withParameterValues(testProgressNote.Id, new Set<String>{ 'VCC_Case__r.ContactId' })
            .returning(new VCC_Progress_Note__c())
            .defineStub();
        return mockProgressNoteRepo;
    }
    /**
     * @description helper method to build contact repo
     * @param testContact contact for mockrepo to return
     * @param fakeAccountId Id to pass into mocked method
     * @return the mockContactRepo
     */
    private static VCR_ContactRepo buildContactRepo(Contact testContact, ID fakeAccountId) {
        VCR_ContactRepo mockContactRepo = (VCR_ContactRepo) new VATEST_StubBuilder(VCR_ContactRepo.class)
            .mockingMethodCall('getContactFromAccountId', String.class)
            .withParameterValues(fakeAccountId)
            .returning(new List<Contact>{ testContact })
            .defineStub();
        return mockContactRepo;
    }
    /**
     * @description helper method to build helper class stub.
     * @param testUserUIEvent User_UI_Event__c passed in for stub
     * @return the stub to be returned
     */
    private static VCC_ExternalVaLinksControllerHelper buildVCCExternalVaLinksControllerHelperMock(
        User_UI_Event__c testUserUIEvent
    ) {
        return (VCC_ExternalVaLinksControllerHelper) new VATEST_StubBuilder(VCC_ExternalVaLinksControllerHelper.class)
            .mockingMethodCall('createUserUIEventRecord')
            .withParameterTypes()
            .returning(testUserUIEvent)
            .defineStub();
    }
    /**
     * @description helper method to build UserUIEvent
     * @param testUser test user to be passed in
     * @return a UserUIEvent
     */
    private static User_UI_Event__c buildUserUIEvent(User testUser) {
        VCC_ExternalVaLinksControllerHelper.testingDatetime = TESTING_DATETIME;
        User_UI_Event__c testUserUIEvent = new User_UI_Event__c();
        testUserUIEvent.UserUI_Time_e911_Link_was_Clicked__c = TESTING_DATETIME;
        testUserUIEvent.UserUI_Provider_s_VISN__c = '1';
        testUserUIEvent.UserUI_Provider_s_Name__c = testUser.Id;

        return testUserUIEvent;
    }
    /**
     * @description helper method to build UserUIEventRepo
     * @param testUserUIEvent object used for mocked method
     * @return `VCR_UserUIEventRepo`
     */
    private static VCR_UserUIEventRepo buildUserUIEventRepoMock(User_UI_Event__c testUserUIEvent) {
        return (VCR_UserUIEventRepo) new VATEST_StubBuilder(VCR_UserUIEventRepo.class)
            .mockingMethodCall('doCreate', SObject.class)
            .withParameterValues(testUserUIEvent)
            .returning(
                (Database.SaveResult) JSON.deserialize('{"success":true,"errors":[]}', Database.SaveResult.class)
            )
            .defineStub();
    }

    /**
     * @description unit test for creating a UserUIEvent
     */
    @IsTest
    static void unitTestHelperCreateUIEventRecordPositive() {
        User testUser = getTestUser();
        VCC_ExternalVaLinksControllerHelper unitUnderTest = new VCC_ExternalVaLinksControllerHelper();
        User_UI_Event__c result;
        Test.startTest();
        System.runAs(testUser) {
            result = unitUnderTest.createUserUIEventRecord();
        }
        Test.stopTest();
        Assert.isTrue(
            result.UserUI_Time_e911_Link_was_Clicked__c.hour() == TESTING_DATETIME.hour(),
            'Expecting the created time to be within the same hour as now.'
        );
        Assert.isNotNull(result.UserUI_Provider_s_VISN__c, 'Expecting the VISN to be set');
        Assert.areEqual(
            result.UserUI_Provider_s_Name__c,
            testUser.Id,
            'Expecting the provider name to be the same as the test user'
        );
    }

    /**
     * @description - tests createUserUIe911Record from a TUC user on case
     * Should only ever be invoked by a TUC user realistically
     */
    @IsTest
    private static void funcCreateUserUIe911RecordMPCasePositive() {
        // Building Test User
        User testUser = getTestUser();

        // Get a testCase
        Case testCase = (Case) VATEST_SObjectFactory.createSObject(new Case());

        // Building Repo Stubs
        VCR_CaseRepo mockCaseRepo = buildCaseRepo(testCase);

        // User UI Event
        user_UI_Event__c testUserUIEvent = buildUserUIEvent(testUser);

        //helper repo
        VCC_ExternalVaLinksControllerHelper mockHelperRepo = buildVCCExternalVaLinksControllerHelperMock(
            testUserUIEvent
        );

        // additional field setting - might have to do this later.
        testUserUIEvent.UserUI_Case_Link_was_Clicked_On__c = testCase.Id;
        testUserUIEvent.UserUI_Patient_s_Facility__c = testCase.TUC_Assigned_Facility__c;
        testUserUIEvent.UserUI_Patient_s_Name__c = testCase.ContactId;

        //UserUIEventRepo stub
        VCR_UserUIEventRepo stubUserUIEventRepo = buildUserUIEventRepoMock(testUserUIEvent);

        // Controller Dependency Injection
        VCC_ExternalVaLinksController.memoizedCaseRepo = mockCaseRepo;
        VCC_ExternalVaLinksController.memoizedUserUIEventRepo = stubUserUIEventRepo;
        VCC_ExternalVaLinksController.helperInstanceRepo = mockHelperRepo;

        String result;
        Test.startTest();
        System.runAs(testUser) {
            result = VCC_ExternalVaLinksController.createUserUIe911Record('Case', testCase.Id);
        }
        Test.stopTest();

        Assert.areEqual(result, 'Success', 'Expected creation of user ui e911 record from case to be successful');
    }
    /**
     * @description - tests createUserUIe911Record from a TUC user on Progress Note
     * Should only ever be invoked by a TUC user
     */
    @IsTest
    private static void unitCreateUserUIe911RecordRNProgressNotePositive() {
        //Building Test User
        User testUser = getTestUser();

        //Get a test ProgressNote
        VCC_Progress_Note__c testProgressNote = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
            new VCC_Progress_Note__c()
        );

        //Building repo stubs
        VCR_ProgressNoteRepo mockProgressNoteRepo = buildProgressNoteRepo(testProgressNote);

        // User UI Event
        user_UI_Event__c testUserUIEvent = buildUserUIEvent(testUser);

        //helper repo
        VCC_ExternalVaLinksControllerHelper mockHelperRepo = buildVCCExternalVaLinksControllerHelperMock(
            testUserUIEvent
        );

        // additional field setting
        testUserUIEvent.UserUI_Patient_s_Name__c = testProgressNote.VCC_Case__r?.ContactId; //maybe?

        //UserUIEventRepo stub
        VCR_UserUIEventRepo stubUserUIEventRepo = buildUserUIEventRepoMock(testUserUIEvent);

        // Controller Dependency Injection
        VCC_ExternalVaLinksController.memoizedProgressNoteRepo = mockProgressNoteRepo;
        VCC_ExternalVaLinksController.memoizedUserUIEventRepo = stubUserUIEventRepo;
        VCC_ExternalVaLinksController.helperInstanceRepo = mockHelperRepo;

        String result;
        Test.startTest();
        System.runAs(testUser) {
            result = VCC_ExternalVaLinksController.createUserUIe911Record('VCC_Progress_Note__c', testProgressNote.Id);
        }
        Test.stopTest();

        Assert.areEqual(
            result,
            'Success',
            'Expected creation of user ui e911 record from Progress Note to be successful'
        );
    }

    /**
     * @description - tests createUserUIe911Record from a TUC user on account
     * Should only ever be invoked by a TUC user realistically
     */
    @IsTest
    private static void unitCreateUserUIe911RecordRNAccPositive() {
        //Building Test User
        User testUser = getTestUser();

        //Building Repo Stubs
        Id fakeAccountId = VATEST_IdFactory.get(Account.sObjectType);
        Contact testContact = (Contact) VATEST_SObjectFactory.createSObject(new Contact(AccountId = fakeAccountId));
        VCR_ContactRepo mockContactRepo = buildContactRepo(testContact, fakeAccountId);

        // User UI Event
        User_UI_Event__c testUserUIEvent = buildUserUIEvent(testUser);

        //additional field setting
        testUserUIEvent.UserUI_Patient_s_Name__c = testContact.Id;

        //UserUIEventRepo stub
        VCR_UserUIEventRepo stubUserUIEventRepo = buildUserUIEventRepoMock(testUserUIEvent);

        // Controller Dependency Injection
        VCC_ExternalVaLinksController.memoizedContactRepo = mockContactRepo;
        VCC_ExternalVaLinksController.memoizedUserUIEventRepo = stubUserUIEventRepo;

        String result;
        Test.startTest();
        System.runAs(testUser) {
            result = VCC_ExternalVaLinksController.createUserUIe911Record('Account', fakeAccountId);
        }
        Test.stopTest();

        Assert.areEqual(result, 'Success', 'Expected creation of user ui e911 record from account to be successful');
    }

    /**
     * @description - tests createUserUIe911Record from a TUC user on other type of page/sObject type
     * Should only ever be invoked by a TUC user realistically
     */
    @IsTest
    private static void unitCreateUserUIe911RecordRNOtherNegative() {
        //Building Test User
        VATEST_UserBuilder testUserBuilder = new VATEST_UserBuilder();
        User testUser = testUserBuilder.withUserProfile('VAVET Base Profile')
            .withStandardData()
            .withPermissionSet('TED_Registered_Nurse_Group')
            .build(true);

        Id fakeAccountId = VATEST_IdFactory.get(Account.sObjectType);

        String result;
        Test.startTest();
        System.runAs(testUser) {
            result = VCC_ExternalVaLinksController.createUserUIe911Record('Other', fakeAccountId);
        }
        Test.stopTest();

        Assert.areEqual(
            result,
            'This component is not on a Case, Progress Note, or Account Page',
            'Was not supposed to go into Case or Success blocks'
        );
    }

    /**
     * @description This method is a positive test for getting active custom settings value
     */
    @IsTest
    public static void unitGetE911ActiveCustomSettingPositive() {
        VATEST_UserBuilder testUserBuilder = new VATEST_UserBuilder();
        User testUser = testUserBuilder
            .withPermissionSet('VCC_VAHC_E911_User')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);

        VCR_VAHCe911CustomSettingRepo stubRepo = (VCR_VAHCe911CustomSettingRepo) new VATEST_StubBuilder(
                VCR_VAHCe911CustomSettingRepo.class
            )
            .mockingMethodCall('getAlle911CustomSettingsRecords')
            .withParameterTypes()
            .returning(new List<VAHC_E911_Settings__c>{ new VAHC_E911_Settings__c(e911_Enabled__c = true) })
            .defineStub();

        VCC_ExternalVaLinksController.memoized911CustomSetRepo = stubRepo;
        Boolean res;
        Test.startTest();
        System.runAs(testUser) {
            res = VCC_ExternalVaLinksController.getE911ActiveCustomSetting();
        }
        Test.stopTest();

        Assert.areEqual(res, true, 'Expected setting to be true but was not');
    }

    /**
     * @description Test for retrieving the e911 active custom setting when enabled is false
     */
    @IsTest
    public static void unitGetE911InactiveCustomSettingPositive() {
        VATEST_UserBuilder testUserBuilder = new VATEST_UserBuilder();
        User testUser = testUserBuilder
            .withPermissionSet('VCC_VAHC_E911_User')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);

        VCR_VAHCe911CustomSettingRepo stubRepo = (VCR_VAHCe911CustomSettingRepo) new VATEST_StubBuilder(
                VCR_VAHCe911CustomSettingRepo.class
            )
            .mockingMethodCall('getAlle911CustomSettingsRecords')
            .withParameterTypes()
            .returning(new List<VAHC_E911_Settings__c>{ new VAHC_E911_Settings__c(e911_Enabled__c = false) })
            .defineStub();

        VCC_ExternalVaLinksController.memoized911CustomSetRepo = stubRepo;
        Boolean res;
        Test.startTest();
        System.runAs(testUser) {
            res = VCC_ExternalVaLinksController.getE911ActiveCustomSetting();
        }
        Test.stopTest();

        Assert.areEqual(res, false, 'Expected setting to be false but was not');
    }

    /**
     * @description This method tests the creating of a task when invoked from Case
     */
    @IsTest
    static void unitTestCreateTaskE911Case() {
        //Building Test User
        VATEST_UserBuilder testUserBuilder = new VATEST_UserBuilder();
        User testUser = testUserBuilder.withUserProfile('VAVET Base Profile')
            .withStandardData()
            .withPermissionSet('TED_Medical_Provider_Group')
            .build(true);

        //Building Repo Stubs
        Id fakeCaseId = VATEST_IdFactory.get(Case.sObjectType);
        VCR_CaseRepo mockCaseRepo = (VCR_CaseRepo) new VATEST_StubBuilder(VCR_CaseRepo.class)
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class, Set<String>.class)
            .withParameterValues(fakeCaseId, new Set<String>{ 'ContactId' })
            .returning(new Case())
            .defineStub();
        VCC_ExternalVaLinksController.memoizedCaseRepo = mockCaseRepo;
        String result;

        Test.startTest();
        System.runAs(testUser) {
            result = VCC_ExternalVaLinksController.createTaske911('Case', fakeCaseId);
        }
        Test.stopTest();
        Assert.areEqual('Success', result, 'Method should return Success');
    }

    /**
     * @description This method tests the creating of a task when invoked from Account
     */
    @IsTest
    static void unitTestCreateTaskE911Account() {
        //Building Test User
        VATEST_UserBuilder testUserBuilder = new VATEST_UserBuilder();
        User testUser = testUserBuilder.withUserProfile('VAVET Base Profile')
            .withStandardData()
            .withPermissionSet('TED_Medical_Provider_Group')
            .build(true);

        //Building Repo Stubs
        Id fakeAccountId = VATEST_IdFactory.get(Account.sObjectType);
        VCR_ContactRepo mockContactRepo = (VCR_ContactRepo) new VATEST_StubBuilder(VCR_ContactRepo.class)
            .mockingMethodCall('getContactFromAccountId', String.class)
            .withParameterValues(fakeAccountId)
            .returning(new List<Contact>{ new Contact(AccountId = fakeAccountId) })
            .defineStub();

        VCC_ExternalVaLinksController.memoizedContactRepo = mockContactRepo;
        String result;

        Test.startTest();
        System.runAs(testUser) {
            result = VCC_ExternalVaLinksController.createTaske911('Account', fakeAccountId);
        }
        Test.stopTest();
        Assert.areEqual('Success', result, 'Method should return Success');
    }

    /**
     * @description This method test the creating of a task when invoked from Progress Note
     */
    @IsTest
    static void unitTestCreateTaskE911ProgressNote() {
        //Building Test User
        VATEST_UserBuilder testUserBuilder = new VATEST_UserBuilder();
        User testUser = testUserBuilder.withUserProfile('VAVET Base Profile')
            .withStandardData()
            .withPermissionSet('TED_Medical_Provider_Group')
            .build(true);

        //Building Repo Stubs
        //Account repo and Stub
        Account testAccount = (Account) VATEST_SObjectFactory.createSObject(new Account());
        VCR_AccountRepo stubAccountRepository = (VCR_AccountRepo) new VATEST_StubBuilder(VCR_AccountRepo.class)
            .mockingMethodCall('fetchById', Id.class)
            .withParameterValues(testAccount.Id)
            .returning(testAccount)
            .defineStub();
        VCC_ExternalVaLinksController.memoizedAccountRepo = stubAccountRepository;
        //Contact repo and Stub
        Contact testContact = (Contact) VATEST_SObjectFactory.createSObject(new Contact(AccountId = testAccount.Id));
        VCR_ContactRepo stubContactRepository = (VCR_ContactRepo) new VATEST_StubBuilder(VCR_ContactRepo.class)
            .mockingMethodCall('getContactFromAccountId', String.class)
            .withParameterValues(testAccount.Id)
            .returning(new List<Contact>{ testContact })
            .defineStub();
        VCC_ExternalVaLinksController.memoizedContactRepo = stubContactRepository;
        //Case repo and Stub
        Case testCase = (Case) VATEST_SObjectFactory.createSObject(
            new Case(ContactId = testContact.Id, AccountId = testAccount.Id)
        );
        VCR_CaseRepo stubCaseRepository = (VCR_CaseRepo) new VATEST_StubBuilder(VCR_CaseRepo.class)
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(testCase.Id, new Set<String>{ 'ContactId', 'Id', 'VCC_Progress_Note__c' })
            .returning(testCase)
            .defineStub();
        VCC_ExternalVaLinksController.memoizedCaseRepo = stubCaseRepository;
        //progress note repo and Stub
        VCC_Progress_Note__c pNote = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
            new VCC_Progress_Note__c(VCC_Case__c = testCase.Id)
        );
        VCR_ProgressNoteRepo stubProgressNoteRepo = (VCR_ProgressNoteRepo) new VATEST_StubBuilder(
                VCR_ProgressNoteRepo.class
            )
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class, Set<String>.class)
            .withParameterValues(pNote.Id, new Set<String>{ 'VCC_Case__r.ContactId', 'VCC_Case__r.Id' })
            .returning(pNote)
            .defineStub();
        VCC_ExternalVaLinksController.memoizedProgressNoteRepo = stubProgressNoteRepo;

        String result;
        Test.startTest();
        System.runAs(testUser) {
            result = VCC_ExternalVaLinksController.createTaske911('VCC_Progress_Note__c', pNote.Id);
        }
        Test.stopTest();
        Assert.areEqual('Success', result, 'Method should return Success');
    }

    /**
     * @description This method tests the creating of a task when invoked from Account
     */
    @IsTest
    static void unitTestCreateTaskE911Negative() {
        //Building Test User
        VATEST_UserBuilder testUserBuilder = new VATEST_UserBuilder();
        User testUser = testUserBuilder.withUserProfile('VAVET Base Profile')
            .withStandardData()
            .withPermissionSet('TED_Medical_Provider_Group')
            .build(true);

        //Building Repo Stubs
        Id fakeAccountId = VATEST_IdFactory.get(Account.sObjectType);
        VCR_ContactRepo mockContactRepo = (VCR_ContactRepo) new VATEST_StubBuilder(VCR_ContactRepo.class)
            .mockingMethodCall('getContactFromAccountId', String.class)
            .withParameterValues(fakeAccountId)
            .returning(new List<Contact>{ new Contact(AccountId = fakeAccountId) })
            .defineStub();

        VCC_ExternalVaLinksController.memoizedContactRepo = mockContactRepo;
        String result;

        Test.startTest();
        System.runAs(testUser) {
            result = VCC_ExternalVaLinksController.createTaske911('Test', fakeAccountId);
        }
        Test.stopTest();
        Assert.areEqual(
            'This component is not on a Case, Progress Note, or Account Page',
            result,
            'Method should return message telling user not Case or Account'
        );
    }
}
