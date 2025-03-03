@isTest
public with sharing class VCC_BridgAdditionalSignersRSTest {
    @isTest
    public static void instantiationTest() {
        Test.startTest();
        System.assert(new VCC_BridgAdditionalSignersRS() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgAdditionalSignersRS.Errors() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgAdditionalSignersRS.FatalErrors() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgAdditionalSignersRS.Warnings() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgAdditionalSignersRS.AdditionalSignersStatus() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgAdditionalSignersRS.ClinicalDocumentSigner() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgAdditionalSignersRS.ClinicalDocumentSigners() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgAdditionalSignersRS.AdditionalSigners() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgAdditionalSignersRS.AdditionalSigner() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgAdditionalSignersRS.ManagedPractitionerParticipationLite() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgAdditionalSignersRS(new VCC_BaseClient.BaseResponse()) != null, 'Instantiation failed.');
        Test.stopTest();
    }
}
