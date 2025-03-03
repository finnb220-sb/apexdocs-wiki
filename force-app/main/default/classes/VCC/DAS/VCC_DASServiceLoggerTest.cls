@IsTest
public with sharing class VCC_DASServiceLoggerTest {
    @IsTest
    static void debugTest() {
        Test.startTest();
        try {
            VCC_DAS.SERVICES.LOGGER.debug('test');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void errorTest() {
        Test.startTest();
        try {
            VCC_DAS.SERVICES.LOGGER.error('test', new AuraHandledException('test'));
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void errorTestButNotAnError() {
        Test.startTest();
        try {
            VCC_DAS.SERVICES.LOGGER.error('test', (Object) 1);
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void saveLogTest() {
        Test.startTest();
        try {
            VCC_DAS.SERVICES.LOGGER.saveLog();
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void getTransactionIdTest() {
        Test.startTest();
        try {
            Assert.isNotNull(VCC_DAS.SERVICES.LOGGER.getTransactionId(), 'Expected non-null transaction id');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
}
