@IsTest
public with sharing class VCC_LogManagerTest {
    @TestSetup
    private static void setup() {
        VCC_Log__c log = new VCC_Log__c(
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
    public static void batch_Test() {
        Database.executeBatch(new VCC_LogManager());
    }

    @IsTest
    public static void execute_Test() {
        List<VCC_Log__c> logs = [SELECT Id FROM VCC_Log__c];
        new VCC_LogManager().deleteLogs(logs);
    }

    @IsTest
    public static void execute_Schedulable_Test() {
        Test.startTest();
        VCC_LogManager batchLogManager = new VCC_LogManager();
        String schedule = '0 0 23 * * ?';
        System.schedule('Test check', schedule, batchLogManager);
        Test.stopTest();
    }

    @IsTest
    public static void executeoverride_Schedulable_Test() {
        Test.startTest();
        VCC_LogManager logManager = new VCC_LogManager();
        logManager.execute(null, new List<VCC_Log__c>());
        Test.stopTest();
    }
}
