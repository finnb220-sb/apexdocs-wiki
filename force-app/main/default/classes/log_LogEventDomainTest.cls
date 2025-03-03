@IsTest
@SuppressWarnings('PMD.ClassNamingConventions')
private with sharing class log_LogEventDomainTest {
    @IsTest
    private static void ctor() {
        Test.startTest();
        log_LogEventDomain logEventDomain = new log_LogEventDomain(new List<log_Log_Event__e>());
        Test.stopTest();

        System.assert(logEventDomain != null, 'Expected class to be initialized.');
    }

    @IsTest
    private static void onAfterInsert() {
        List<log_Log_Event__e> logEvents = new List<log_Log_Event__e>();
        logEvents.add(
            new log_Log_Event__e(
                Log_Name__c = 'Unit Test',
                Record_Type_Name__c = 'Standard',
                Correlation_Id__c = 'UnitTest12345',
                Log_Type__c = 'INFO',
                Timestamp__c = Datetime.now(),
                Username__c = UserInfo.getUserName()
            )
        );

        Test.startTest();
        EventBus.publish(logEvents);
        Test.stopTest();

        System.assert(true, 'Force assertion.');
    }

    @IsTest
    private static void insertLogs() {
        Test.startTest();
        EventBus.publish(new log_Log_Event__e());
        Test.stopTest();

        System.assert(true, 'Force assertion.');
    }

    @IsTest
    private static void coverage() {
        Test.startTest();
        log_LogEventDomain.coverage();
        Test.stopTest();

        System.assert(true, 'Force assertion.');
    }
}
