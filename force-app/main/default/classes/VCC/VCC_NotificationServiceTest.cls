@isTest
class VCC_NotificationServiceTest {
    @testSetup
    static void makeData() {
        VCC_TestDataFactory.insertUser('System Administrator');
    }
    /**
     * @description create a test user for running tests
     * @return A test user
     **/
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
    }
    @isTest
    static void testNotifyOnRemoteSystemDown() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_NotificationService.notifyOnRemoteSystemDown('Test');
            VCC_NotificationService.notifyOnRemoteSystemDown('Test');
            Test.stopTest();
            List<LogEntry__c> logEntriesMPIDown = [
                SELECT Id, Message__c, ExceptionMessage__c, ExceptionType__c, CreatedDate
                FROM LogEntry__c
                WHERE ExceptionType__c = :VCC_NotificationService.NEBULA_EXCEPTION_TYPE_MPI_DOWN AND CreatedDate = TODAY
            ];

            System.assert.areequal(logEntriesMPIDown.size(), 2);
        }
    }
}
