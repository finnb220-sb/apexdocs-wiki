/**
 * @author Booz Allen Hamilton
 * @date 2/14/24
 * @description  Tests for VCC_lwc_utilsUnitTests class.
 *
 *  NOTE: Suppressing warning for PMD.ApexUnitTestClassShouldHaveRunAs as there is no need to use System.RunAs for the
 *  Repository functional tests.
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@isTest
private class VCC_lwc_utilsUnitTests {
    /**
     * @description Test VCC_lwc_utils.getICN() with Account Id passed in
     */
    @isTest
    static void unitTestGetICNWhenRecordIdIsFromAnAccountPositive() {
        Account expected = (Account) VATEST_SObjectFactory.createSObject(new Account(VCC_MVI_External_Id__pc = 'blah'));
        VCR_AccountRepo stubAccountRepository = (VCR_AccountRepo) new VATEST_StubBuilder(VCR_AccountRepo.class)
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(expected.Id, new Set<String>{ 'VCC_MVI_External_Id__pc' })
            .returning(expected)
            .defineStub();
        VCC_LWCSObjectRepos.memoizedAccountRepo = stubAccountRepository;
        Test.startTest();
        String mviId = VCC_lwc_utils.getICN(expected.Id);
        Test.stopTest();
        Assert.areEqual(expected.VCC_MVI_External_Id__pc, mviId, 'Expected MVI Id values to match, but they were different');
    }

    /**
     * @description Test VCC_lwc_utils.getICN() with Contact Id passed in
     */
    @isTest
    static void unitTestGetICNWhenRecordIdIsFromAContactPositive() {
        Contact expected = (Contact) VATEST_SObjectFactory.createSObject(new Contact(VCC_MVI_External_Id__c = 'blah'));
        VCR_ContactRepo stubContactRepository = (VCR_ContactRepo) new VATEST_StubBuilder(VCR_ContactRepo.class)
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(expected.Id, new Set<String>{ 'VCC_MVI_External_Id__c' })
            .returning(expected)
            .defineStub();
        VCC_LWCSObjectRepos.memoizedContactRepo = stubContactRepository;
        Test.startTest();
        String mviId = VCC_lwc_utils.getICN(expected.Id);
        Test.stopTest();
        Assert.areEqual(expected.VCC_MVI_External_Id__c, mviId, 'Expected MVI Id values to match, but they were different');
    }

    /**
     * @description Test VCC_lwc_utils.getICN() with Case Id passed in
     */
    @isTest
    static void unitTestGetICNWhenRecordIdIsFromACasePositive() {
        Contact con = (Contact) VATEST_SObjectFactory.createSObject(new Contact(VCC_MVI_External_Id__c = 'blah'));
        Case expected = (Case) VATEST_SObjectFactory.createSObject(new Case(ContactId = con.Id));
        VCR_CaseRepo stubCaseRepository = (VCR_CaseRepo) new VATEST_StubBuilder(VCR_CaseRepo.class)
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(expected.Id, new Set<String>{ 'Contact.VCC_MVI_External_Id__c' })
            .returning(expected)
            .defineStub();
        VCC_LWCSObjectRepos.memoizedCaseRepo = stubCaseRepository;
        Test.startTest();
        String mviId = VCC_lwc_utils.getICN(expected.Id);
        Test.stopTest();
        Assert.areEqual(expected.Contact.VCC_MVI_External_Id__c, mviId, 'Expected MVI Id values to match, but they were different');
    }

    /**
     * @description Test VCC_lwc_utils.getICN() with Progress Note Id passed in
     */
    @isTest
    static void unitTestGetICNWhenRecordIdIsFromAProgressNotePositive() {
        Contact con = (Contact) VATEST_SObjectFactory.createSObject(new Contact(VCC_MVI_External_Id__c = 'blah'));
        Case cse = (Case) VATEST_SObjectFactory.createSObject(new Case(ContactId = con.Id));
        VCC_Progress_Note__c expected = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(new VCC_Progress_Note__c(VCC_Case__c = cse.Id));
        VCR_ProgressNoteRepo stubProgressNoteRepository = (VCR_ProgressNoteRepo) new VATEST_StubBuilder(VCR_ProgressNoteRepo.class)
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(expected.Id, new Set<String>{ 'VCC_Case__r.Contact.VCC_MVI_External_Id__c' })
            .returning(expected)
            .defineStub();
        VCC_LWCSObjectRepos.memoizedProgressNoteRepo = stubProgressNoteRepository;
        Test.startTest();
        String mviId = VCC_lwc_utils.getICN(expected.Id);
        Test.stopTest();
        Assert.areEqual(expected.VCC_Case__r.Contact.VCC_MVI_External_Id__c, mviId, 'Expected MVI Id values to match, but they were different');
    }

    /**
     * @description Test VCC_lwc_utils.getICN() with Task Id passed in
     */
    @isTest
    static void unitTestGetICNWhenRecordIdIsFromATaskPositive() {
        Contact con = (Contact) VATEST_SObjectFactory.createSObject(new Contact(VCC_MVI_External_Id__c = 'blah'));
        Task expected = (Task) VATEST_SObjectFactory.createSObject(new Task(WhoId = con.Id, Description = 'Test Task'));
        VCR_TaskRepo stubTaskRepository = (VCR_TaskRepo) new VATEST_StubBuilder(VCR_TaskRepo.class)
            .mockingMethodCall('fetchById', Id.class)
            .withParameterValues(expected.Id)
            .returning(expected)
            .defineStub();
        VCR_ContactRepo stubContactRepository = (VCR_ContactRepo) new VATEST_StubBuilder(VCR_ContactRepo.class)
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(con.Id, new Set<String>{ 'VCC_MVI_External_Id__c' })
            .returning(con)
            .defineStub();
        VCC_LWCSObjectRepos.memoizedTaskRepo = stubTaskRepository;
        VCC_LWCSObjectRepos.memoizedContactRepo = stubContactRepository;
        Test.startTest();
        String mviId = VCC_lwc_utils.getICN(con.Id);
        Test.stopTest();
        Assert.areEqual(con.VCC_MVI_External_Id__c, mviId, 'Expected MVI Id values to match, but they were different');
    }

    /**
     * @description Test VCC_lwc_utils.getICN() with null Id passed in
     */
    @isTest
    static void unitTestGetICNWhenRecordIdIsNull() {
        Test.startTest();
        String mviId = VCC_lwc_utils.getICN(null);
        Test.stopTest();
        Assert.isNull(mviId, 'Expected mviId to be null, but it was not null');
    }
}
