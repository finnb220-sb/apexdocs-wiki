/**
 * @description Test class VCC_DASFlowIsValidEsig
 * @author Booz Allen Hamilton
 * @see `VCC_DASFlowIsValidEsig`
 */
@isTest
private class VCC_DASFlowIsValidEsigTest {
    @IsTest
    static void unitResultConstructorPositive() {
        Test.startTest();
        VCC_DASIsValidEsigRS isValidEsigRs = new VCC_DASIsValidEsigRS();
        Assert.isNotNull(new VCC_DASFlowIsValidEsig.Result(isValidEsigRs), 'Expected a non-null value');
        Test.stopTest();
    }

    @IsTest
    static void unitRequestConstructorPositive() {
        Test.startTest();
        VCC_DASFlowIsValidEsig.Request flowIsValidEsigRequest = new VCC_DASFlowIsValidEsig.Request();
        Assert.isNotNull(flowIsValidEsigRequest, 'Expected a non-null value');
        Test.stopTest();
    }

    @IsTest
    static void unitIsValidEsigPositive() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;

        apiStub.setReturnValue('isValidEsig', new VCC_DASIsValidEsigRS());

        Test.startTest();
        try {
            VCC_DASFlowIsValidEsig.Request flowIsValidEsigRequest = new VCC_DASFlowIsValidEsig.Request();
            flowIsValidEsigRequest.providerLoginSiteCode = '123';
            VCC_DASFlowIsValidEsig.Result flowIsValidEsigResult = VCC_DASFlowIsValidEsig.isValidEsig(
                new List<VCC_DASFlowIsValidEsig.Request>{ flowIsValidEsigRequest }
            )[0];
            Assert.isNotNull(flowIsValidEsigResult, 'Expected non-null value.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();

        apiStub.assertInvoked('isValidEsig');
    }

    @IsTest
    static void unitIsValidEsigDasExceptionNegative() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;

        apiStub.setException('isValidEsig', new VCC_DASServiceApi.ApiServiceException('test'));

        Test.startTest();
        try {
            VCC_DASFlowIsValidEsig.Request flowIsValidEsigRequest = new VCC_DASFlowIsValidEsig.Request();
            flowIsValidEsigRequest.providerLoginSiteCode = '123';
            VCC_DASFlowIsValidEsig.isValidEsig(new List<VCC_DASFlowIsValidEsig.Request>{ flowIsValidEsigRequest });
            Assert.fail('Expected an exception.');
        } catch (VCC_DASException dasException) {
            Assert.isTrue(true, 'Expected VCC_DASException exception but observed a different exception.');
        }
        Test.stopTest();
    }

    @IsTest
    static void unitIsValidEsigOtherExceptionNegative() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;

        apiStub.setException('isValidEsig', new NullPointerException());

        Test.startTest();
        try {
            VCC_DASFlowIsValidEsig.Request flowIsValidEsigRequest = new VCC_DASFlowIsValidEsig.Request();
            flowIsValidEsigRequest.providerLoginSiteCode = '123';
            VCC_DASFlowIsValidEsig.isValidEsig(new List<VCC_DASFlowIsValidEsig.Request>{ flowIsValidEsigRequest });
            Assert.fail('Expected an exception.');
        } catch (VCC_DASException dasException) {
            Assert.isTrue(true, 'Expected VCC_DASException exception but observed a different exception.');
        }
        Test.stopTest();
    }
}
