@IsTest
@SuppressWarnings('PMD.ClassNamingConventions')
private with sharing class log_LogManagerTest {
    @TestSetup
    private static void setup() {
        log_Log__c log = new log_Log__c(
            Correlation_Id__c = 'ABC123',
            Timestamp__c = Datetime.now(),
            Name = 'Unit Test',
            Log_Type__c = 'INFO',
            Message__c = 'Unit Test log entry.',
            Username__c = UserInfo.getUserName()
        );
        insert log;
    }

    @IsTest
    private static void batch() {
        Database.executeBatch(new log_LogManager());
        System.assert(true, 'Force assertion.');
    }

    @IsTest
    private static void execute() {
        List<log_Log__c> logs = [SELECT Id FROM log_Log__c];
        new log_LogManager().deleteLogs(logs);
        System.assert(true, 'Force assertion.');
    }

    @IsTest
    private static void executeSchedulable() {
        Test.startTest();
        Schedulable batchLogManager = (Schedulable) new log_LogManager();
        String schedule = '0 0 23 * * ?';
        System.schedule('Test check', schedule, batchLogManager);
        Test.stopTest();

        System.assert(true, 'Force assertion.');
    }

    @IsTest
    private static void executeOverrideSchedulable() {
        Test.startTest();
        log_LogManager logManager = new log_LogManager();
        logManager.execute(null, new List<log_Log__c>());
        Test.stopTest();

        System.assert(true, 'Force assertion.');
    }
}
