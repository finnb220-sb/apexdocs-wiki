@IsTest
private with sharing class VCC_LogEventDomainTest {
    @IsTest
    private static void ctor() {
        Test.startTest();
        VCC_LogEventDomain logEventDomain = new VCC_LogEventDomain(new List<VCC_Log_Event__e>());
        Test.stopTest();

        System.assert(logEventDomain != null, 'Expected class to be initialized.');
    }

    @IsTest
    private static void construct() {
        Test.startTest();
        VCC_LogEventDomain logEventDomain = (VCC_LogEventDomain) new VCC_LogEventDomain.Constructor().construct(new List<VCC_Log_Event__e>());
        Test.stopTest();

        System.assert(logEventDomain != null, 'Expected class to be initialized.');
    }

    @IsTest
    private static void onAfterInsert() {
        Test.startTest();
        new VCC_LogEventDomain(new List<VCC_Log_Event__e>()).onAfterInsert();
        Test.stopTest();
    }

    @IsTest
    private static void insertLogs() {
        Test.startTest();
        VCC_Log_Event__e logEvent = new VCC_Log_Event__e();
        EventBus.publish(logEvent);
        Test.stopTest();
    }
}
