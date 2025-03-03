@isTest
public with sharing class VCC_BridgVitalsRSTest {
    @isTest
    public static void instantiationTest() {
        Test.startTest();
        System.assert(new VCC_BridgVitalsRS() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgVitalsRS.VitalsSite() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgVitalsRS.VitalsResults() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgVitalsRS.VitalsVitals() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgVitalsRS.VitalsVital() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgVitalsRS.VitalsEntered() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgVitalsRS.VitalsLocation() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgVitalsRS.VitalsTaken() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgVitalsRS.VitalsFacility() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgVitalsRS.VitalsMeasurements() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgVitalsRS.VitalsRemoved() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgVitalsRS.VitalsMeasurement() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgVitalsRS.VitalsQualifiers() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgVitalsRS.VitalsQualifier() != null, 'Instantiation failed.');
        Test.stopTest();
    }
}
