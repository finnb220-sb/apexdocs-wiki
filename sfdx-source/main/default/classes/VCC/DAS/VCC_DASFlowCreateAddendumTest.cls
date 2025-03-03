/**
 * @description Test class for VCC_DASFlowCreateAddendum
 * @author Booz Allen Hamilton
 * @see `VCC_DASFlowCreateAddendum`
 */
@isTest
private class VCC_DASFlowCreateAddendumTest {
    @IsTest
    static void unitResultConstructorPositive() {
        VCC_DASCreateAddendumRS createAddendumRs = new VCC_DASCreateAddendumRS();
        createAddendumRs.textTO.fault.message = 'faultMessage';
        createAddendumRs.textTO.text = 'text';

        Test.startTest();
        VCC_DASFlowCreateAddendum.Result flowCreateAddendumRequest = new VCC_DASFlowCreateAddendum.Result(
            createAddendumRs
        );
        Assert.isNotNull(flowCreateAddendumRequest, 'Expected non-null value.');
        Assert.areEqual('faultMessage', flowCreateAddendumRequest.faultMessage, 'Expected correct string value.');
        Assert.areEqual('text', flowCreateAddendumRequest.text, 'Expected correct string value');
        Test.stopTest();
    }

    @IsTest
    static void unitRequestConstructorPositive() {
        Test.startTest();
        Assert.isNotNull(new VCC_DASFlowCreateAddendum.Request(), 'Expected non-null value');
        Test.stopTest();
    }

    @IsTest
    static void unitCreateAddendumPositive() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DASStub parserStub = new VCC_DASStub(VCC_DASServiceParser.class);

        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;
        VCC_DAS.SERVICES.parserService = (VCC_DASServiceParser) parserStub.instance;

        apiStub.setReturnValue('createAddendum', new VCC_DASCreateAddendumRS());
        parserStub.setReturnValue('parse', 'returnValue');

        Test.startTest();
        VCC_DASFlowCreateAddendum.Request flowCreateAddendumRequest = new VCC_DASFlowCreateAddendum.Request();
        flowCreateAddendumRequest.providerLoginSiteCode = '123';
        VCC_DASFlowCreateAddendum.Result flowCreateAddendumResult = VCC_DASFlowCreateAddendum.createAddendum(
            new List<VCC_DASFlowCreateAddendum.Request>{ flowCreateAddendumRequest }
        )[0];
        Assert.isNotNull(flowCreateAddendumResult, 'Expected non-null value.');
        Test.stopTest();

        apiStub.assertInvoked('createAddendum');
        parserStub.assertInvoked('parse');
    }

    @IsTest
    static void unitCreateAddendumDasExceptionNegative() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DASStub parserStub = new VCC_DASStub(VCC_DASServiceParser.class);

        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;
        VCC_DAS.SERVICES.parserService = (VCC_DASServiceParser) parserStub.instance;

        apiStub.setException('createAddendum', new VCC_DASServiceApi.ApiServiceException('test'));
        parserStub.setReturnValue('parse', 'returnValue');

        Test.startTest();
        try {
            VCC_DASFlowCreateAddendum.Request flowCreateAddendumRequest = new VCC_DASFlowCreateAddendum.Request();
            flowCreateAddendumRequest.providerLoginSiteCode = '123';
            VCC_DASFlowCreateAddendum.createAddendum(
                new List<VCC_DASFlowCreateAddendum.Request>{ flowCreateAddendumRequest }
            );
            Assert.fail('Expected an exception.');
        } catch (VCC_DASException dasException) {
            Assert.isTrue(true, 'Exception caught. Test passes.');
        }
        Test.stopTest();

        apiStub.assertInvoked('createAddendum');
        parserStub.assertInvoked('parse');
    }

    @IsTest
    static void unitCreateAddendumOtherExceptionNegative() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DASStub parserStub = new VCC_DASStub(VCC_DASServiceParser.class);

        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;
        VCC_DAS.SERVICES.parserService = (VCC_DASServiceParser) parserStub.instance;

        apiStub.setException('createAddendum', new NullPointerException());
        parserStub.setReturnValue('parse', 'returnValue');

        Test.startTest();
        try {
            VCC_DASFlowCreateAddendum.Request flowCreateAddendumRequest = new VCC_DASFlowCreateAddendum.Request();
            flowCreateAddendumRequest.providerLoginSiteCode = '123';
            VCC_DASFlowCreateAddendum.createAddendum(
                new List<VCC_DASFlowCreateAddendum.Request>{ flowCreateAddendumRequest }
            );
            Assert.fail('Expected an exception.');
        } catch (VCC_DASException dasException) {
            Assert.isTrue(true, 'Exception caught. Test passes.');
        }
        Test.stopTest();

        apiStub.assertInvoked('createAddendum');
        parserStub.assertInvoked('parse');
    }
}
