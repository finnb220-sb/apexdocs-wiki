/**
 * @description test class for VCR_PushTopicRepo.
 * @author      Booz Allen
 * @since       2024
 * @see         VCR_PushTopicRepo
 */
@IsTest
private class VCR_PushTopicRepoTest {
    private final static User SPECIALIST_USER;
    static {
        //mixed DML error workaround
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            SPECIALIST_USER = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet('PrC_Specialist_Users')
                .build(true);
        }
    }

    @TestSetup
    static void makeData() {
        PushTopic newSuperScreenPT = new PushTopic(
            Name = 'pcSuperScreenTest',
            ApiVersion = 61.0,
            NotifyForOperationUndelete = false,
            NotifyForOperationDelete = false,
            NotifyForOperationCreate = true,
            NotifyForOperationUpdate = true,
            NotifyForFields = 'Referenced'
        );
        newSuperScreenPT.Query = 'SELECT Id, CaseClosedJSON__c, CaseClosedStatus__c FROM PC_AWPushEvent__c';

        insert newSuperScreenPT;
    }

    /**
     * @description positive test of getMostRecentPushTopicByName to ensure that the correct push topic record is returned when provided its name
     */
    @IsTest
    private static void funcGetMostRecentPushTopicByNamePositive() {
        // Test data setup
        VCR_PushTopicRepo repo = new VCR_PushTopicRepo();

        PushTopic expectedPushTopic = [SELECT Id FROM PushTopic WHERE Name = 'pcSuperScreenTest' LIMIT 1];

        // Actual test
        Test.startTest();

        PushTopic result;
        System.runAs(SPECIALIST_USER) {
            result = repo.getMostRecentPushTopicByName('pcSuperScreenTest');
        }

        Test.stopTest();

        // Asserts
        Assert.areEqual(
            expectedPushTopic.Id,
            result.Id,
            'Expected getMostRecentPushTopicByName to return the pcSuperScreenTest Push Topic record created in setup, but a different push topic was returned.'
        );
    }
}
