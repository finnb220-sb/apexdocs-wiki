/**
 * @description Test class for PC_ChatSessionRepo.
 * @author      Booz Allen
 * @since       2024
 * @see         PC_ChatSessionRepo
 */
@IsTest
private class PC_ChatSessionRepoTest {
    private final static User FLP_USER;
    static {
        //mixed DML error workaround
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            FLP_USER = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet('PrC_FLP_Users')
                .build(true);
        }
    }

    @testSetup
    private static void testSetup() {
        System.runAs(FLP_USER) {
            PC_Case__c prcCase = (PC_Case__c) VATEST_SObjectFactory.createSObject(
                new PC_Case__c(
                    RecordTypeId = Schema.SObjectType.PC_Case__c.getRecordTypeInfosByDeveloperName()
                        .get('Provider_Connect_Case')
                        .getRecordTypeId(),
                    Status__c = 'Open',
                    Channel__c = 'Chat',
                    Specialty__c = 'Cardiology',
                    isRunningTest_DO_NOT_USE__c = true
                ),
                true
            );

            VATEST_SObjectFactory.createSObject(
                new PC_Chat_Session__c(Provider_Connect_Case__c = prcCase.Id, PC_Is_Closed__c = false),
                true
            );
        }
    }

    @IsTest
    static void unitTestConstructorPositive() {
        Test.startTest();
        PC_ChatSessionRepo repo;
        System.runAs(FLP_USER) {
            repo = new PC_ChatSessionRepo();
        }
        Test.stopTest();

        Assert.isNotNull(repo, 'Expected constructor to properly instantiate a PC_ChatSessionRepo class object');
        Assert.isTrue(
            String.valueOf(repo).containsIgnoreCase('VTC_BaseRepo.sObjectType=PC_Chat_Session__c'),
            'Expected the SObject type to be PC_Chat_Session__c'
        );
    }

    /**
     * @description positive test for fetchPcChatSessionByPrcCaseId method to ensure that a PC Chat Session related to a PC Case is appropriately returned when provided the PC Case's ID
     */
    @IsTest
    private static void funcFetchPcChatSessionByPrcCaseIdTestPositive() {
        // Test data setup
        User runAsUser = FLP_USER;

        PC_Case__c prcCase = [SELECT Id FROM PC_Case__c LIMIT 1];

        VATEST_SObjectFactory.createSObject(
            new PC_Case__Share(
                ParentId = prcCase.Id,
                UserOrGroupId = runAsUser.Id,
                RowCause = 'Manual',
                AccessLevel = 'Read'
            ),
            true
        );

        PC_Chat_Session__c chatSession = [SELECT Id FROM PC_Chat_Session__c LIMIT 1];

        VATEST_SObjectFactory.createSObject(
            new PC_Chat_Session__Share(
                ParentId = chatSession.Id,
                UserOrGroupId = runAsUser.Id,
                RowCause = 'Manual',
                AccessLevel = 'Read'
            ),
            true
        );

        PC_ChatSessionRepo repo = new PC_ChatSessionRepo();

        // Actual test
        Test.startTest();

        List<PC_Chat_Session__c> results;
        System.runAs(runAsUser) {
            results = repo.fetchPcChatSessionByPrcCaseId(prcCase.Id);
        }

        Test.stopTest();

        // Asserts
        Assert.areEqual(1, results.size(), 'Expected one chat session record to be returned for the case');
    }

    /**
     * @description positive test for fetchOpenPcChatSessionByPrcCaseIds method to ensure that all open PC Chat Sessions related to a PC Case are appropriately returned when provided the PC Case's ID
     */
    @IsTest
    private static void funcFetchOpenPcChatSessionByPrcCaseIdsTestPositive() {
        // Test data setup
        User runAsUser = FLP_USER;

        PC_Case__c prcCase = [SELECT Id FROM PC_Case__c LIMIT 1];

        VATEST_SObjectFactory.createSObject(
            new PC_Case__Share(
                ParentId = prcCase.Id,
                UserOrGroupId = runAsUser.Id,
                RowCause = 'Manual',
                AccessLevel = 'Read'
            ),
            true
        );

        PC_Chat_Session__c chatSession = [SELECT Id FROM PC_Chat_Session__c LIMIT 1];

        VATEST_SObjectFactory.createSObject(
            new PC_Chat_Session__Share(
                ParentId = chatSession.Id,
                UserOrGroupId = runAsUser.Id,
                RowCause = 'Manual',
                AccessLevel = 'Read'
            ),
            true
        );

        PC_ChatSessionRepo repo = new PC_ChatSessionRepo();

        // Actual test
        Test.startTest();

        List<PC_Chat_Session__c> results;
        System.runAs(runAsUser) {
            results = repo.fetchOpenPcChatSessionByPrcCaseIds(new Set<Id>{ prcCase.Id });
        }

        Test.stopTest();

        // Asserts
        Assert.areEqual(1, results.size(), 'Expected one chat session record to be returned for the case');
    }
}
