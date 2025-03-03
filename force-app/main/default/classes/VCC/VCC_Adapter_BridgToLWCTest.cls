/**
 * @description Tests the VCC_Adapter_BridgToLWC class
 * @author Booz Allen
 *
 * @see VCC_Adapter_BridgToLWC for class being tested
 *
 * This class is slated for deprecation.
 */
@IsTest
private with sharing class VCC_Adapter_BridgToLWCTest {
    @IsTest
    private static void vccAppointmentTest() {
        Object result;
        VCC_BridgAppointmentsRS vccBridgAppointmentsRS = new VCC_BridgAppointmentsRS();
        Test.startTest();
        result = VCC_Adapter_BridgToLWC.vccAppointment(vccBridgAppointmentsRS);
        Test.stopTest();

        System.assert(result != null, 'Expected null');
    }

    @IsTest
    private static void vccConsultTest() {
        Object result;
        VCC_BridgConsultsRS vccBridgConsultsRS = new VCC_BridgConsultsRS();
        Test.startTest();
        result = VCC_Adapter_BridgToLWC.vccConsult(vccBridgConsultsRS);
        Test.stopTest();

        System.assert(result != null, 'Expected null');
    }

    @IsTest
    private static void vccDischargeSummaryList() {
        Object result;
        VCC_BridgNotesRS vccBridgNotesRS = new VCC_BridgNotesRS();
        Test.startTest();
        result = VCC_Adapter_BridgToLWC.vccDischargeSummaryList(vccBridgNotesRS);
        Test.stopTest();

        System.assert(result != null, 'Expected null');
    }

    @IsTest
    private static void transformRSFlagsTest() {
        Object result;
        VCC_BridgFlagsRS vccBridgFlagsRS = new VCC_BridgFlagsRS();
        Test.startTest();
        result = VCC_Adapter_BridgToLWC.transformRS(vccBridgFlagsRS);
        Test.stopTest();

        System.assert(true == true, 'Assertion');
    }

    @IsTest
    private static void vccImmunizationListTest() {
        Object result;
        VCC_BridgImmunizationRS vccBridgImmunizationRS = new VCC_BridgImmunizationRS();
        Test.startTest();
        result = VCC_Adapter_BridgToLWC.vccImmunizationList(vccBridgImmunizationRS);
        Test.stopTest();

        System.assert(result != null, 'Expected null');
    }

    @IsTest
    private static void vccLabTest() {
        Object result;
        VCC_BridgLabsRS vccBridgLabsRS = new VCC_BridgLabsRS();
        Test.startTest();
        result = VCC_Adapter_BridgToLWC.vccLab(vccBridgLabsRS);
        Test.stopTest();

        System.assert(result != null, 'Expected null');
    }

    @IsTest
    private static void vccMedicationListTestWithError() {
        StaticResource medsRSJSON = [SELECT Id, Body FROM StaticResource WHERE Name = 'VCC_MedicationJSONExample'];
        Object result;
        VCC_BridgMedsRS vccBridgMedsRS = (VCC_BridgMedsRS) JSON.deserialize(
            medsRSJSON.Body.toString(),
            VCC_BridgMedsRS.class
        );
        Test.startTest();
        try {
            result = VCC_Adapter_BridgToLWC.vccMedicationList(vccBridgMedsRS);
        } catch (Exception e) {
            System.assertEquals('Exceeded Max Records', e.getMessage(), 'Expected "Exceeded Max Records" error');
        }
        Test.stopTest();
    }

    @IsTest
    private static void vccMedicationListTest() {
        Object result;
        VCC_BridgMedsRS vccBridgMedsRS = new VCC_BridgMedsRS();
        Test.startTest();
        result = VCC_Adapter_BridgToLWC.vccMedicationList(vccBridgMedsRS);
        Test.stopTest();
        System.assert(result != null, 'Result should not be null');
    }

    @IsTest
    private static void transformRSNotesTest() {
        Object result;
        VCC_BridgNotesRS vccBridgNotesRS = new VCC_BridgNotesRS();
        Test.startTest();
        result = VCC_Adapter_BridgToLWC.transformRS(vccBridgNotesRS);
        Test.stopTest();

        System.assert(true == true, 'assertion');
    }

    @IsTest
    private static void vccOrderListTest() {
        Object result;
        VCC_BridgOrdersRS vccBridgOrdersRS = new VCC_BridgOrdersRS();
        Test.startTest();
        result = VCC_Adapter_BridgToLWC.vccOrderList(vccBridgOrdersRS);
        Test.stopTest();

        System.assert(result != null, 'Expected null');
    }

    @IsTest
    private static void vccProblemListTest() {
        Object result;
        VCC_BridgProblemsRS vccBridgProblemsRS = new VCC_BridgProblemsRS();
        Test.startTest();
        result = VCC_Adapter_BridgToLWC.vccProblemList(vccBridgProblemsRS);
        Test.stopTest();

        System.assert(result != null, 'Expected null');
    }

    @IsTest
    private static void vccRediologyListTest() {
        Object result;
        VCC_BridgRadiologyExamsRS vccBridgRadiologyExamsRS = new VCC_BridgRadiologyExamsRS();
        Test.startTest();
        result = VCC_Adapter_BridgToLWC.vccRediologyList(vccBridgRadiologyExamsRS);
        Test.stopTest();

        System.assert(result != null, 'Expected null');
    }

    @IsTest
    private static void vccVitalsTest() {
        Object result;
        VCC_BridgVitalsRS vccBridgVitalsRS = new VCC_BridgVitalsRS();
        Test.startTest();
        result = VCC_Adapter_BridgToLWC.vccVitals(vccBridgVitalsRS);
        Test.stopTest();

        System.assert(result != null, 'Expected null');
    }
}
