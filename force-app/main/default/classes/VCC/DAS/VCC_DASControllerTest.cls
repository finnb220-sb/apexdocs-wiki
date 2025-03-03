@IsTest
public with sharing class VCC_DASControllerTest {
    @IsTest
    static void getSiteIntegrationTypeTestHappy() {
        VCC_DASStub metadataStub = new VCC_DASStub(VCC_DASServiceMetadata.class);
        VCC_DAS.SERVICES.metadataService = (VCC_DASServiceMetadata) metadataStub.instance;

        String testIntegrationType = 'DAS';

        VCC_Org_Settings__mdt testOrgSettings = new VCC_Org_Settings__mdt(vccType__c = 'SOME VALUE');
        VCC_Site_Specific_Configuration__mdt testSiteConfiguration = new VCC_Site_Specific_Configuration__mdt(
            VCC_VistA_Integration__c = testIntegrationType
        );

        metadataStub.setReturnValue('getOrgSettings', testOrgSettings);
        metadataStub.setReturnValue('getSiteSpecificConfiguration', testSiteConfiguration);

        Test.startTest();
        try {
            String integrationType = VCC_DASController.getSiteIntegrationType(123);
            Assert.areEqual(testIntegrationType, integrationType, 'Expected correct IntegrationType value.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();

        metadataStub.assertInvoked('getOrgSettings');
        metadataStub.assertInvoked('getSiteSpecificConfiguration');
    }

    @IsTest
    static void getSiteIntegrationTypeTestSadDasException() {
        VCC_DASStub metadataStub = new VCC_DASStub(VCC_DASServiceMetadata.class);
        VCC_DAS.SERVICES.metadataService = (VCC_DASServiceMetadata) metadataStub.instance;

        String testIntegrationType = 'DAS';

        VCC_Org_Settings__mdt testOrgSettings = new VCC_Org_Settings__mdt(vccType__c = 'SOME VALUE');
        VCC_Site_Specific_Configuration__mdt testSiteConfiguration = new VCC_Site_Specific_Configuration__mdt(
            VCC_VistA_Integration__c = testIntegrationType
        );

        metadataStub.setException('getOrgSettings', new VCC_DASController.GetSiteIntegrationTypeException());
        metadataStub.setReturnValue('getSiteSpecificConfiguration', testSiteConfiguration);

        Test.startTest();
        try {
            String integrationType = VCC_DASController.getSiteIntegrationType(123);
            Assert.fail('Expected an exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, VCC_DASException.class, 'Expected VCC_DASException');
        }
        Test.stopTest();

        metadataStub.assertInvoked('getOrgSettings');
        metadataStub.assertNotInvoked('getSiteSpecificConfiguration');
    }

    @IsTest
    static void getSiteIntegrationTypeTestSadOtherException() {
        VCC_DASStub metadataStub = new VCC_DASStub(VCC_DASServiceMetadata.class);
        VCC_DAS.SERVICES.metadataService = (VCC_DASServiceMetadata) metadataStub.instance;

        String testIntegrationType = 'DAS';

        VCC_Org_Settings__mdt testOrgSettings = new VCC_Org_Settings__mdt(vccType__c = 'SOME VALUE');
        VCC_Site_Specific_Configuration__mdt testSiteConfiguration = new VCC_Site_Specific_Configuration__mdt(
            VCC_VistA_Integration__c = testIntegrationType
        );

        metadataStub.setException('getOrgSettings', new NullPointerException());
        metadataStub.setReturnValue('getSiteSpecificConfiguration', testSiteConfiguration);

        Test.startTest();
        try {
            String integrationType = VCC_DASController.getSiteIntegrationType(123);
            Assert.fail('Expected an exception');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, VCC_DASException.class, 'Expected VCC_DASException');
        }
        Test.stopTest();

        metadataStub.assertInvoked('getOrgSettings');
        metadataStub.assertNotInvoked('getSiteSpecificConfiguration');
    }

    @IsTest
    static void unitSelectPatientPositive() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;

        List<VCC_DASSelectPatientRS> selectPatientRsList = new List<VCC_DASSelectPatientRS>();
        VCC_DASSelectPatientRS selectPatientRs = new VCC_DASSelectPatientRS();
        selectPatientRs.patientTO = new VCC_DASSelectPatientRS.PatientTO();
        selectPatientRsList.add(selectPatientRs);

        apiStub.setReturnValue('selectPatient', selectPatientRsList);

        VCC_DASController.SelectPatientInput selectPatientInput = new VCC_DASController.SelectPatientInput();
        selectPatientInput.providerLoginSiteCode = '123';

        Test.startTest();
        try {
            VCC_DASController.selectPatient(selectPatientInput);
        } catch (Exception thrownException) {
            Assert.fail(
                'Unexpected exception: ' + thrownException.getMessage() + thrownException.getStackTraceString()
            );
        }
        Test.stopTest();

        apiStub.assertInvoked('selectPatient');
    }

    @IsTest
    static void unitSelectPatientDasExceptionNegative() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;

        apiStub.setException('selectPatient', new VCC_DASController.SelectPatientException('test'));

        VCC_DASController.SelectPatientInput selectPatientInput = new VCC_DASController.SelectPatientInput();
        selectPatientInput.providerLoginSiteCode = '123';

        Test.startTest();
        try {
            VCC_DASController.selectPatient(selectPatientInput);
            Assert.fail('Expected and exception');
        } catch (VCC_DASException dasException) {
            Assert.isTrue(true, 'Caught exception. Test passes.');
        }
        Test.stopTest();

        apiStub.assertInvoked('selectPatient');
    }

    @IsTest
    static void unitSelectPatientOtherExceptionNegative() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;

        apiStub.setException('selectPatient', new NullPointerException());

        VCC_DASController.SelectPatientInput selectPatientInput = new VCC_DASController.SelectPatientInput();
        selectPatientInput.providerLoginSiteCode = '123';

        Test.startTest();
        try {
            VCC_DASController.selectPatient(selectPatientInput);
            Assert.fail('Expected and exception');
        } catch (VCC_DASException dasException) {
            Assert.isTrue(true, 'Caught exception. Test passes.');
        }
        Test.stopTest();

        apiStub.assertInvoked('selectPatient');
    }
}
