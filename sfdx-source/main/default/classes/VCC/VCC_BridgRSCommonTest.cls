@isTest
public with sharing class VCC_BridgRSCommonTest {
    @isTest
    public static void instantiationTest() {
        Test.startTest();
        System.assert(new VCC_BridgRSCommon.HL72PersonIdentifier() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRSCommon.HL72PersonName() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRSCommon.HL72EntityIdentifier() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRSCommon.HL72CodedElementLite() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRSCommon.HL72FacilityIdentifier() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRSCommon.HL72OrganizationIdentifier() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRSCommon.VACode() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRSCommon.PointInTime() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRSCommon.ProviderType() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRSCommon.TimeInterval() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRSCommon.ProvidersType() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRSCommon.PatientLite() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRSCommon.PractitionerLite() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRSCommon.HospitalLocation() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRSCommon.Institution() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRSCommon.RequestedResolvedIdentifiers() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRSCommon.RequestedExcludedIdentifiers() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRSCommon.ResultantIdentifiers() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRSCommon.FpdsError() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRSCommon.FpdsErrorSection() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRSCommon.CdsError() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRSCommon.CdsErrorSection() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRSCommon.PathwaysError() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRSCommon.PathwaysErrorSection() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRSCommon.Errors() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRSCommon.FatalErrors() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRSCommon.Warnings() != null, 'Instantiation failed.');
        Test.stopTest();
    }
}
