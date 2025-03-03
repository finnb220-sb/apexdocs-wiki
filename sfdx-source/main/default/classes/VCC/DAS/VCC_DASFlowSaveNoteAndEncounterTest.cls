@isTest
private class VCC_DASFlowSaveNoteAndEncounterTest {
    @IsTest
    static void resultConstructorTest() {
        VCC_DASStub encounterStub = new VCC_DASStub(VCC_DASServiceEncounter.class);
        VCC_DAS.SERVICES.encounterService = (VCC_DASServiceEncounter) encounterStub.instance;

        encounterStub.setReturnValue('getAndReturnEncounterStringOrReturnErrorMessage', '');

        Test.startTest();
        try {
            VCC_DASSaveNoteAndEncounterRS saveNoteAndEncounterRs = new VCC_DASSaveNoteAndEncounterRS();
            VCC_DASFlowSaveNoteAndEncounter.Result flowSaveNoteAndEncounterResult = new VCC_DASFlowSaveNoteAndEncounter.Result(
                saveNoteAndEncounterRs
            );
            Assert.isNotNull(
                flowSaveNoteAndEncounterResult,
                'Expected flowSaveNoteAndEncounterResult to be constructed successfully and be a non-null value.'
            );
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();

        encounterStub.assertInvoked('getAndReturnEncounterStringOrReturnErrorMessage');
    }

    @IsTest
    static void requestConstructorTest() {
        Test.startTest();
        try {
            VCC_DASFlowSaveNoteAndEncounter.Request flowSaveNoteAndEncounterRequest = new VCC_DASFlowSaveNoteAndEncounter.Request();
            Assert.isNotNull(flowSaveNoteAndEncounterRequest, 'Expected non-null values');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void unitSaveNoteAndEncounterTestPositive() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DASStub encounterStub = new VCC_DASStub(VCC_DASServiceEncounter.class);
        VCC_DASStub utilitiesStub = new VCC_DASStub(VCC_DASServiceUtilities.class);
        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;
        VCC_DAS.SERVICES.encounterService = (VCC_DASServiceEncounter) encounterStub.instance;
        VCC_DAS.SERVICES.utilitiesService = (VCC_DASServiceUtilities) utilitiesStub.instance;

        encounterStub.setReturnValue('getAndReturnEncounterStringOrReturnErrorMessage', '');
        encounterStub.setReturnValue('getEncounterServiceCategory', '');
        utilitiesStub.setReturnValue('getProviderDuz', '');
        encounterStub.setReturnValue('createProcedureString', '');
        encounterStub.setReturnValue('createDiagnosisString', '');
        apiStub.setReturnValue('saveNoteAndEncounter', new VCC_DASSaveNoteAndEncounterRS());

        Test.startTest();
        try {
            VCC_DASFlowSaveNoteAndEncounter.Request flowSaveNoteAndEncounterRequest = new VCC_DASFlowSaveNoteAndEncounter.Request();
            flowSaveNoteAndEncounterRequest.patientLocalSiteId = '123';
            VCC_DASFlowSaveNoteAndEncounter.Result flowSaveNoteAndEncounterResult = VCC_DASFlowSaveNoteAndEncounter.saveNoteAndEncounter(
                new List<VCC_DASFlowSaveNoteAndEncounter.Request>{ flowSaveNoteAndEncounterRequest }
            )[0];
            Assert.isNotNull(flowSaveNoteAndEncounterResult, 'Expected non-null value.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();

        apiStub.assertInvoked('saveNoteAndEncounter');
        encounterStub.assertInvoked('getAndReturnEncounterStringOrReturnErrorMessage');
        encounterStub.assertInvoked('getEncounterServiceCategory');
        utilitiesStub.assertInvoked('getProviderDuz');
        encounterStub.assertInvoked('createProcedureString');
        encounterStub.assertInvoked('createDiagnosisString');
    }

    @IsTest
    static void unitSaveNoteAndEncounterTestDasExceptionNegative() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DASStub encounterStub = new VCC_DASStub(VCC_DASServiceEncounter.class);
        VCC_DASStub utilitiesStub = new VCC_DASStub(VCC_DASServiceUtilities.class);
        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;
        VCC_DAS.SERVICES.encounterService = (VCC_DASServiceEncounter) encounterStub.instance;
        VCC_DAS.SERVICES.utilitiesService = (VCC_DASServiceUtilities) utilitiesStub.instance;

        encounterStub.setReturnValue('getAndReturnEncounterStringOrReturnErrorMessage', '');
        encounterStub.setReturnValue('getEncounterServiceCategory', '');
        utilitiesStub.setReturnValue('getProviderDuz', '');
        encounterStub.setReturnValue('createProcedureString', '');
        encounterStub.setReturnValue('createDiagnosisString', '');
        apiStub.setException('saveNoteAndEncounter', new VCC_DASServiceApi.ApiServiceException('test'));

        Test.startTest();
        try {
            VCC_DASFlowSaveNoteAndEncounter.Request flowSaveNoteAndEncounterRequest = new VCC_DASFlowSaveNoteAndEncounter.Request();
            flowSaveNoteAndEncounterRequest.patientLocalSiteId = '123';
            VCC_DASFlowSaveNoteAndEncounter.saveNoteAndEncounter(
                new List<VCC_DASFlowSaveNoteAndEncounter.Request>{ flowSaveNoteAndEncounterRequest }
            );
            Assert.fail('Expected an exception.');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, VCC_DASException.class, 'Expected a VCC_DASException');
        }
        Test.stopTest();

        encounterStub.assertNotInvoked('getAndReturnEncounterStringOrReturnErrorMessage');
        encounterStub.assertInvoked('getEncounterServiceCategory');
        utilitiesStub.assertInvoked('getProviderDuz');
        encounterStub.assertInvoked('createProcedureString');
        encounterStub.assertInvoked('createDiagnosisString');
    }

    @IsTest
    static void unitSaveNoteAndEncounterTestOtherExceptionNegative() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DASStub encounterStub = new VCC_DASStub(VCC_DASServiceEncounter.class);
        VCC_DASStub utilitiesStub = new VCC_DASStub(VCC_DASServiceUtilities.class);
        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;
        VCC_DAS.SERVICES.encounterService = (VCC_DASServiceEncounter) encounterStub.instance;
        VCC_DAS.SERVICES.utilitiesService = (VCC_DASServiceUtilities) utilitiesStub.instance;

        encounterStub.setReturnValue('getAndReturnEncounterStringOrReturnErrorMessage', '');
        encounterStub.setReturnValue('getEncounterServiceCategory', '');
        utilitiesStub.setReturnValue('getProviderDuz', '');
        encounterStub.setReturnValue('createProcedureString', '');
        encounterStub.setReturnValue('createDiagnosisString', '');
        apiStub.setException('saveNoteAndEncounter', new NullPointerException());

        Test.startTest();
        try {
            VCC_DASFlowSaveNoteAndEncounter.Request flowSaveNoteAndEncounterRequest = new VCC_DASFlowSaveNoteAndEncounter.Request();
            flowSaveNoteAndEncounterRequest.patientLocalSiteId = '123';
            VCC_DASFlowSaveNoteAndEncounter.saveNoteAndEncounter(
                new List<VCC_DASFlowSaveNoteAndEncounter.Request>{ flowSaveNoteAndEncounterRequest }
            );
            Assert.fail('Expected an exception.');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, VCC_DASException.class, 'Expected a VCC_DASException');
        }
        Test.stopTest();

        encounterStub.assertNotInvoked('getAndReturnEncounterStringOrReturnErrorMessage');
        encounterStub.assertInvoked('getEncounterServiceCategory');
        utilitiesStub.assertInvoked('getProviderDuz');
        encounterStub.assertInvoked('createProcedureString');
        encounterStub.assertInvoked('createDiagnosisString');
    }
}
