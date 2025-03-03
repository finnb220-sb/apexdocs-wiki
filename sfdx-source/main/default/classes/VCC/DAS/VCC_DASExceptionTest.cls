@isTest
public with sharing class VCC_DASExceptionTest {
    private class TestDasException extends VCC_DASException {
    }

    @IsTest
    static void withCauseTest() {
        VCC_DASStub loggerStub = new VCC_DASStub(VCC_DASServiceLogger.class);
        VCC_DAS.SERVICES.loggerService = (VCC_DASServiceLogger) loggerStub.instance;
        loggerStub.setReturnValue('error', null);
        loggerStub.setReturnValue('saveLog', null);
        loggerStub.setReturnValue('getTransactionId', 'test');

        String txid = VCC_DAS.SERVICES.LOGGER.getTransactionId();
        String exceptionMessage = 'test';
        AuraHandledException cause = new AuraHandledException(exceptionMessage);

        Test.startTest();
        TestDasException dasException = new TestDasException(cause);
        Assert.isTrue(dasException.getCause() === cause, 'Expected exact equality for exception cause.');
        Assert.isTrue(
            dasException.getMessage().contains(cause.getMessage()),
            'Expected VCC_DASException to contain the cause message.'
        );
        Assert.isTrue(
            dasException.getMessage().contains(txid),
            'Expected VCC_DASException to contain the transaction Id.'
        );
        loggerStub.assertInvoked('error');
        loggerStub.assertInvoked('saveLog');
        loggerStub.assertInvoked('getTransactionId');
        Test.stopTest();
    }

    @IsTest
    static void withStringTest() {
        VCC_DASStub loggerStub = new VCC_DASStub(VCC_DASServiceLogger.class);
        VCC_DAS.SERVICES.loggerService = (VCC_DASServiceLogger) loggerStub.instance;
        loggerStub.setReturnValue('error', null);
        loggerStub.setReturnValue('saveLog', null);
        loggerStub.setReturnValue('getTransactionId', 'test');

        String txid = VCC_DAS.SERVICES.LOGGER.getTransactionId();
        String exceptionMessage = 'test';

        Test.startTest();
        TestDasException dasException = new TestDasException(exceptionMessage);
        Assert.isTrue(
            dasException.getMessage().contains(exceptionMessage),
            'Expected VCC_DASException to contain the causes message.'
        );
        Assert.isTrue(
            dasException.getMessage().contains(txid),
            'Expected VCC_DASException to contain the transaction Id.'
        );
        loggerStub.assertInvoked('error');
        loggerStub.assertInvoked('saveLog');
        loggerStub.assertInvoked('getTransactionId');
        Test.stopTest();
    }
}
