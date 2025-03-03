@IsTest
public with sharing class VCC_DASProgressNoteControllerTest {
    @IsTest
    static void validateEsigTest() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;

        apiStub.setReturnValue('isValidEsig', new VCC_DASIsValidEsigRS());

        VCC_DASProgressNoteController.ActionParams params = new VCC_DASProgressNoteController.ActionParams();
        params.actionName = 'ValidateEsig';
        params.patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
        params.patientAndProviderParams.providerLoginSiteCode = '123';

        Test.startTest();
        try {
            VCC_DASProgressNoteController.progressNoteAction(
                new List<VCC_DASProgressNoteController.ActionParams>{ params }
            );
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void writeNoteTest() {
        VCC_DASProgressNoteController.ActionParams params = new VCC_DASProgressNoteController.ActionParams();
        params.actionName = 'WriteNote';
        params.patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
        params.patientAndProviderParams.providerLoginSiteCode = '123';

        Test.startTest();
        try {
            List<String> resultStringList = VCC_DASProgressNoteController.progressNoteAction(
                new List<VCC_DASProgressNoteController.ActionParams>{ params }
            );
            Assert.areEqual(1, resultStringList.size(), 'Expected one item in list.');
            Assert.areEqual('', resultStringList[0], 'Expected an empty string.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void createAddendumTest() {
        VCC_DASProgressNoteController.ActionParams params = new VCC_DASProgressNoteController.ActionParams();
        params.actionName = 'CreateAddendum';
        params.patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
        params.patientAndProviderParams.providerLoginSiteCode = '123';

        Test.startTest();
        try {
            List<String> resultStringList = VCC_DASProgressNoteController.progressNoteAction(
                new List<VCC_DASProgressNoteController.ActionParams>{ params }
            );
            Assert.areEqual(1, resultStringList.size(), 'Expected one item in list.');
            Assert.areEqual('', resultStringList[0], 'Expected an empty string.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void getNoteTextTest() {
        VCC_DASProgressNoteController.ActionParams params = new VCC_DASProgressNoteController.ActionParams();
        params.actionName = 'GetNoteText';
        params.patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
        params.patientAndProviderParams.providerLoginSiteCode = '123';

        Test.startTest();
        try {
            List<String> resultStringList = VCC_DASProgressNoteController.progressNoteAction(
                new List<VCC_DASProgressNoteController.ActionParams>{ params }
            );
            Assert.areEqual(1, resultStringList.size(), 'Expected one item in list.');
            Assert.areEqual('', resultStringList[0], 'Expected an empty string.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void createEncounterTest() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DASStub encounterStub = new VCC_DASStub(VCC_DASServiceEncounter.class);
        VCC_DASStub utilitiesStub = new VCC_DASStub(VCC_DASServiceUtilities.class);

        VCC_DAS.SERVICES.utilitiesService = (VCC_DASServiceUtilities) utilitiesStub.instance;
        VCC_DAS.SERVICES.encounterService = (VCC_DASServiceEncounter) encounterStub.instance;
        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;

        encounterStub.setReturnValue('getEncounterServiceCategory', null);
        encounterStub.setReturnValue('createProcedureString', null);
        encounterStub.setReturnValue('createDiagnosisString', null);
        encounterStub.setReturnValue('getAndReturnEncounterStringOrReturnErrorMessage', null);
        utilitiesStub.setReturnValue('getProviderDuz', null);

        apiStub.setReturnValue('saveNoteAndEncounter', new VCC_DASSaveNoteAndEncounterRS());

        VCC_DASProgressNoteController.ActionParams params = new VCC_DASProgressNoteController.ActionParams();
        params.actionName = 'CreateEncounter';
        params.patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
        params.patientAndProviderParams.patientLocalSiteId = '123';

        Test.startTest();
        try {
            VCC_DASProgressNoteController.progressNoteAction(
                new List<VCC_DASProgressNoteController.ActionParams>{ params }
            );
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void getEncounterStringTest() {
        VCC_DASStub encounterStub = new VCC_DASStub(VCC_DASServiceEncounter.class);

        VCC_DAS.SERVICES.encounterService = (VCC_DASServiceEncounter) encounterStub.instance;

        encounterStub.setReturnValue('generateEncounterString', null);

        VCC_DASProgressNoteController.ActionParams params = new VCC_DASProgressNoteController.ActionParams();
        params.actionName = 'GetEncounterString';
        params.patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
        params.patientAndProviderParams.providerLoginSiteCode = '123';

        Test.startTest();
        try {
            VCC_DASProgressNoteController.progressNoteAction(
                new List<VCC_DASProgressNoteController.ActionParams>{ params }
            );
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void signNoteTest() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;

        apiStub.setReturnValue('signNote', new VCC_DASSignNoteRS());

        VCC_DASProgressNoteController.ActionParams params = new VCC_DASProgressNoteController.ActionParams();
        params.actionName = 'SignNote';
        params.patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
        params.patientAndProviderParams.providerLoginSiteCode = '123';

        Test.startTest();
        try {
            VCC_DASProgressNoteController.progressNoteAction(
                new List<VCC_DASProgressNoteController.ActionParams>{ params }
            );
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void addSignersTest() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;

        apiStub.setReturnValue('getAdditionalSigners', new VCC_DASGetAdditionalSignersRS());

        Case testCase = new Case();
        insert testCase;

        VCC_Progress_Note__c progressNote = new VCC_Progress_Note__c(VCC_Case__c = testCase.Id);
        insert progressNote;

        VCC_DASProgressNoteController.ActionParams params = new VCC_DASProgressNoteController.ActionParams();
        params.actionName = 'AddSigners';
        params.noteAndEncounterParams = new VCC_Vdif_NoteAndEncounterParams();
        params.patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
        params.patientAndProviderParams.providerLoginSiteCode = '123';
        params.pnRecord = progressNote;

        VCC_VDIFResponseParser.ProviderTO provider = new VCC_VDIFResponseParser.ProviderTO();
        provider.duz = 'test';
        provider.loginSiteCode = '123';
        provider.providername = 'abc';

        params.noteAndEncounterParams.supplementalParameters = JSON.serialize(
            new List<VCC_VDIFResponseParser.ProviderTO>{ provider }
        );

        Test.startTest();
        try {
            VCC_DASProgressNoteController.progressNoteAction(
                new List<VCC_DASProgressNoteController.ActionParams>{ params }
            );
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void selectPatientTest() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;

        apiStub.setReturnValue('selectPatient', new List<VCC_DASSelectPatientRS>{ new VCC_DASSelectPatientRS() });

        VCC_DASProgressNoteController.ActionParams params = new VCC_DASProgressNoteController.ActionParams();
        params.actionName = 'GetVisitRelatedTos';
        params.patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
        params.patientAndProviderParams.providerLoginSiteCode = '123';

        Test.startTest();
        try {
            VCC_DASProgressNoteController.progressNoteAction(
                new List<VCC_DASProgressNoteController.ActionParams>{ params }
            );
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }
}
