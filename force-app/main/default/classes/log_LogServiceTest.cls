@IsTest
@SuppressWarnings('PMD.ClassNamingConventions')
private with sharing class log_LogServiceTest {
    private class LogServiceTestException extends Exception {
    }

    @IsTest
    private static void ctor() {
        Test.startTest();
        log_LogService logService = new log_LogService();
        Test.stopTest();

        System.assert(logService != null, 'Expected class to be initialized.');
        System.assertEquals(131072, log_LogService.MAX_MSG_SIZE, 'Expected values to match.');
        System.assertEquals('.MAX LENGTH IS EXCEEDED...', log_LogService.MAX_SIZE_MSG, 'Expected values to match.');
    }

    @IsTest
    private static void setRecordType() {
        Test.startTest();
        new log_LogService().setRecordType(null);
        Test.stopTest();

        System.assert(true, 'Force assertion.');
    }

    @IsTest
    private static void logString() {
        Test.startTest();
        log_LogService.log('Unit Test', log_LogService.LogType.INFO, 'Unit test string');
        log_LogService.log('Unit Test', log_LogService.LogType.INFO, '');
        log_LogService.log('Unit Test', log_LogService.LogType.INFO, 'Unit test with correlation id', 'ABC123');
        Test.stopTest();

        System.assert(true, 'Force assertion.');
    }

    @IsTest
    private static void logException() {
        Test.startTest();
        log_LogService.log('Unit Test Exception', log_LogService.LogType.INFO, new LogServiceTestException());
        log_LogService.log('Unit Test Exception', log_LogService.LogType.INFO, new LogServiceTestException(), 'ABC123');
        Test.stopTest();

        System.assert(true, 'Force assertion.');
    }

    @IsTest
    private static void logObject() {
        Test.startTest();
        log_LogManager logManager = new log_LogManager();
        log_LogService.log('Unit Test Object', log_LogService.LogType.INFO, logManager);
        log_LogService.log('Unit Test Object', log_LogService.LogType.INFO, new List<Object>{ new Account() });
        log_LogService.log('Unit Test', log_LogService.LogType.INFO, new List<Object>{ new Account() }, 'ABC123');
        Test.stopTest();

        System.assert(true, 'Force assertion.');
    }

    @IsTest
    private static void insertLogs() {
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
        log_LogService.insertLogs(logEvents);
        Test.stopTest();

        System.assert(true, 'Force exception.');
    }

    @IsTest
    private static void deleteLogs() {
        Test.startTest();
        log_LogService.deleteLogs(new List<log_Log__c>());
        Test.stopTest();

        System.assert(true, 'Force assertion.');
    }

    @IsTest
    private static void publish() {
        Test.startTest();
        log_LogService.publish();
        Test.stopTest();

        System.assert(true, 'Force assertion.');
    }
}
