@isTest
private class VCC_DASFlowSelectPatientTest {
    @IsTest
    static void resultConstructorTest() {
        Test.startTest();
        try {
            List<VCC_DASSelectPatientRS> selectPatientRS = new List<VCC_DASSelectPatientRS>();
            VCC_DASFlowSelectPatient.Result flowSelectPatientResult = new VCC_DASFlowSelectPatient.Result(
                selectPatientRS
            );
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void requestConstructorTest() {
        Test.startTest();
        try {
            VCC_DASFlowSelectPatient.Request flowSelectPatientRequest = new VCC_DASFlowSelectPatient.Request();
            Assert.isNotNull(flowSelectPatientRequest, 'Expected non-null values');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void unitSelectPatientPositive() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;

        apiStub.setReturnValue('selectPatient', new List<VCC_DASSelectPatientRS>());
        Test.startTest();
        try {
            VCC_DASFlowSelectPatient.Request flowSelectPatientRequest = new VCC_DASFlowSelectPatient.Request();
            flowSelectPatientRequest.providerLoginSiteCode = '123';
            List<VCC_DASFlowSelectPatient.Result> flowSelectPatientResult = VCC_DASFlowSelectPatient.selectPatient(
                new List<VCC_DASFlowSelectPatient.Request>{ flowSelectPatientRequest }
            );
            Assert.isNotNull(flowSelectPatientResult, 'Expected non-null value.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();

        apiStub.assertInvoked('selectPatient');
    }

    @IsTest
    static void unitSelectPatientDasExceptionNegative() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;

        apiStub.setException('selectPatient', new VCC_DASServiceApi.ApiServiceException('test'));

        Test.startTest();
        try {
            VCC_DASFlowSelectPatient.Request flowSelectPatientRequest = new VCC_DASFlowSelectPatient.Request();
            flowSelectPatientRequest.providerLoginSiteCode = '123';
            VCC_DASFlowSelectPatient.selectPatient(
                new List<VCC_DASFlowSelectPatient.Request>{ flowSelectPatientRequest }
            );
            Assert.fail('Expected an exception.');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, VCC_DASException.class, 'Expected a VCC_DASException');
        }
        Test.stopTest();
    }

    @IsTest
    static void unitSelectPatientOtherExceptionNegative() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;

        apiStub.setException('selectPatient', new NullPointerException());

        Test.startTest();
        try {
            VCC_DASFlowSelectPatient.Request flowSelectPatientRequest = new VCC_DASFlowSelectPatient.Request();
            flowSelectPatientRequest.providerLoginSiteCode = '123';
            VCC_DASFlowSelectPatient.selectPatient(
                new List<VCC_DASFlowSelectPatient.Request>{ flowSelectPatientRequest }
            );
            Assert.fail('Expected an exception.');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, VCC_DASException.class, 'Expected a VCC_DASException');
        }
        Test.stopTest();
    }
}
