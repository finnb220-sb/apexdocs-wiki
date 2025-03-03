@IsTest
public with sharing class VCC_LogServiceTest {
    // Force change
    public class LogServiceTestException extends Exception {
    }

    @IsTest
    private static void logString() {
        Test.startTest();
        VCC_LogService.log('Unit Test', VCC_LogService.VCC_LogType.INFO, 'Unit test string');
        VCC_LogService.log('Unit Test', VCC_LogService.VCC_LogType.INFO, '');
        VCC_LogService.log('Unit Test', VCC_LogService.VCC_LogType.INFO, 'Unit test with correlation id', 'ABC123');
        Test.stopTest();
    }

    @IsTest
    private static void logException() {
        Test.startTest();
        VCC_LogService.log('Unit Test Exception', VCC_LogService.VCC_LogType.INFO, new LogServiceTestException());
        VCC_LogService.log('Unit Test Exception', VCC_LogService.VCC_LogType.INFO, new LogServiceTestException(), 'ABC123');
        Test.stopTest();
    }

    @IsTest
    private static void logObject() {
        Test.startTest();
        VCC_LogManager logManager = new VCC_LogManager();
        VCC_LogService.log('Unit Test Object', VCC_LogService.VCC_LogType.INFO, logManager);
        VCC_LogService.log('Unit Test Object', VCC_LogService.VCC_LogType.INFO, new List<Object>{ new Account() });
        VCC_LogService.log('Unit Test', VCC_LogService.VCC_LogType.INFO, new List<Object>{ new Account() }, 'ABC123');
        Test.stopTest();
    }

    @IsTest
    private static void deleteLogs() {
        Test.startTest();
        VCC_LogService.deleteLogs(new List<VCC_Log__c>());
        Test.stopTest();
    }

    @IsTest
    private static void insertLogs() {
        Test.startTest();
        List<VCC_Log_Event__e> logList = new List<VCC_Log_Event__e>();
        VCC_Log_Event__e log = new VCC_Log_Event__e();
        log.Log_Name__c = 'Unit test';
        log.Message__c = 'hello';
        log.Timestamp__c = Datetime.now();
        log.Log_Type__c = VCC_LogService.VCC_LogType.INFO.name();
        log.Username__c = UserInfo.getUserName();
        log.Message__c = 'hello';
        log.Correlation_Id__c = '12345';
        logList.add(log);

        VCC_LogService.insertLogs(logList);
        Test.stopTest();
    }

    @IsTest
    private static void publish() {
        Test.startTest();
        VCC_LogService.publish();
        Test.stopTest();
    }
}
