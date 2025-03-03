@isTest
public with sharing class VCC_BridgImmunizationRSTest {
    @isTest
    public static void instantiationTest() {
        Test.startTest();
        System.assert(new VCC_BridgImmunizationRS() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgImmunizationRS.ImmunizationClinicalData() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgImmunizationRS.Patients() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgImmunizationRS.ImmunizationClinicalDataPatient() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgImmunizationRS.ImmunizationEvents() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgImmunizationRS.ImmunizationEvent() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgImmunizationRS.ImmunizationSkinTestVisit() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgImmunizationRS.Comments() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgImmunizationRS.Diagnosis() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgImmunizationRS.SnomedCodes() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgImmunizationRS.IcdCodes() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgImmunizationRS.Remarks() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgImmunizationRS.DataSource() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgImmunizationRS.SoftwarePackage() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgImmunizationRS.ReactionObservationEvents() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgImmunizationRS.AdministeredImmunization() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgImmunizationRS.CdsImmunizationErrorSection() != null, 'Instantiation failed.');
        Test.stopTest();
    }

    @isTest
    public static void baseResponse() {
        VCC_BaseClient.BaseResponse base = new VCC_BaseClient.BaseResponse();
        VCC_BridgImmunizationRS bridg = new VCC_BridgImmunizationRS();
        bridg.clinicalData.requestId = 'Exceeded Max';

        bridg.isMaxRecordsError = false;
        base.httpResponse = new HttpResponse();
        base.httpResponse.setBody(json.serialize(bridg));

        Test.startTest();
        System.assert(bridg.isMaxRecordsError == false, ' Variable isMaxRecordsError  does not exist and is not instantiated');
        VCC_BridgImmunizationRS bridg2 = new VCC_BridgImmunizationRS(base);
        System.assertEquals(true, bridg2.isMaxRecordsError);
        Test.stopTest();
    }
}
