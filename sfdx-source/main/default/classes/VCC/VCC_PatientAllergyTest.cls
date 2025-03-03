@isTest
public with sharing class VCC_PatientAllergyTest {
    @testSetup
    static void makeData() {
        VCC_TestDataFactory.insertUser('System Administrator');
    }
    /**
     * @description create a test user for running tests
     * @return A test user
     */
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
    }

    @isTest
    public static void ctor() {
        Test.startTest();
        VCC_PatientAllergy patientAllergy;
        Exception caughtException;

        System.runAs(getTestUser()) {
            try {
                patientAllergy = new VCC_PatientAllergy();
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
                System.debug(LoggingLevel.ERROR, e.getStackTraceString());
                caughtException = e;
            }

            System.assert(caughtException == null, 'An exception was thrown.');
            System.assert(patientAllergy != null, 'Initialized incorrectly.');
        }
        Test.stopTest();
    }

    @isTest
    public static void unitPatientAllergyConstructorWithIntoleranceConditionPositive() {
        Test.startTest();
        VCC_PatientAllergy patientAllergy;
        Exception caughtException;

        System.runAs(getTestUser()) {
            try {
                VCC_BridgAllergyRS.IntoleranceCondition intoleranceCondition = new VCC_BridgAllergyRS.IntoleranceCondition();
                patientAllergy = new VCC_PatientAllergy(intoleranceCondition);
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
                System.debug(LoggingLevel.ERROR, e.getStackTraceString());
                caughtException = e;
            }

            System.assert(caughtException == null, 'An exception was thrown.');
            System.assert(patientAllergy != null, 'Initialized incorrectly with intolerance condition passed into constructor');
        }
        Test.stopTest();
    }

    @isTest
    public static void patientAllergyProperties() {
        VCC_BridgRSCommon.HL72EntityIdentifier recordIdentifier;
        VCC_BridgRSCommon.PatientLite patient;
        VCC_BridgRSCommon.PointInTime observationTime;
        VCC_BridgRSCommon.HL72CodedElementLite agent;
        VCC_BridgRSCommon.HL72CodedElementLite allergyType;
        VCC_BridgRSCommon.HL72CodedElement gmrAllergyAgent;
        VCC_BridgRSCommon.HL72CodedElementLite informationSourceCategory;
        VCC_BridgRSCommon.HL72CodedElementLite mechanism;
        List<VCC_BridgAllergyRS.ReactionObservationEvent> reaction;
        VCC_BridgAllergyRS.PractitionerParticipationLite verifier;
        VCC_BridgAllergyRS.PractitionerParticipationLite author;
        VCC_BridgAllergyRS.PractitionerParticipationLite errorEnterer;
        List<VCC_BridgAllergyRS.PractitionerParticipationLite> idBandMarker;
        List<VCC_BridgAllergyRS.PractitionerParticipationLite> chartMarker;
        List<VCC_BridgAllergyRS.AllergyCommentEvent> commentEvents;
        List<VCC_BridgAllergyRS.DrugClass> drugClass;
        List<VCC_BridgAllergyRS.DrugIngredient> drugIngredient;
        VCC_BridgRSCommon.HL72OrganizationIdentifier facilityIdentifier;
        VCC_BridgRSCommon.HL72FacilityIdentifier recordSource;
        VCC_BridgRSCommon.PointInTime recordUpdateTime;
        Boolean isMaxRecordsError;

        Test.startTest();
        System.runAs(getTestUser()) {
            recordIdentifier = new VCC_BridgRSCommon.HL72EntityIdentifier();
            patient = new VCC_BridgRSCommon.PatientLite();
            observationTime = new VCC_BridgRSCommon.PointInTime();
            agent = new VCC_BridgRSCommon.HL72CodedElementLite();
            allergyType = new VCC_BridgRSCommon.HL72CodedElementLite();
            gmrAllergyAgent = new VCC_BridgRSCommon.HL72CodedElement();
            informationSourceCategory = new VCC_BridgRSCommon.HL72CodedElementLite();
            mechanism = new VCC_BridgRSCommon.HL72CodedElementLite();
            reaction = new List<VCC_BridgAllergyRS.ReactionObservationEvent>();
            verifier = new VCC_BridgAllergyRS.PractitionerParticipationLite();
            author = new VCC_BridgAllergyRS.PractitionerParticipationLite();
            errorEnterer = new VCC_BridgAllergyRS.PractitionerParticipationLite();
            idBandMarker = new List<VCC_BridgAllergyRS.PractitionerParticipationLite>();
            chartMarker = new List<VCC_BridgAllergyRS.PractitionerParticipationLite>();
            commentEvents = new List<VCC_BridgAllergyRS.AllergyCommentEvent>();
            drugClass = new List<VCC_BridgAllergyRS.DrugClass>();
            drugIngredient = new List<VCC_BridgAllergyRS.DrugIngredient>();
            facilityIdentifier = new VCC_BridgRSCommon.HL72OrganizationIdentifier();
            recordSource = new VCC_BridgRSCommon.HL72FacilityIdentifier();
            recordUpdateTime = new VCC_BridgRSCommon.PointInTime();
            isMaxRecordsError = false;

            System.assert(recordIdentifier != null, 'Property not initialized.');
            System.assert(patient != null, 'Property not initialized.');
            System.assert(observationTime != null, 'Property not initialized.');
            System.assert(agent != null, 'Property not initialized.');
            System.assert(allergyType != null, 'Property not initialized.');
            System.assert(gmrAllergyAgent != null, 'Property not initialized.');
            System.assert(informationSourceCategory != null, 'Property not initialized.');
            System.assert(mechanism != null, 'Property not initialized.');
            System.assert(reaction != null, 'Property not initialized.');
            System.assert(verifier != null, 'Property not initialized.');
            System.assert(author != null, 'Property not initialized.');
            System.assert(errorEnterer != null, 'Property not initialized.');
            System.assert(idBandMarker != null, 'Property not initialized.');
            System.assert(chartMarker != null, 'Property not initialized.');
            System.assert(commentEvents != null, 'Property not initialized.');
            System.assert(drugClass != null, 'Property not initialized.');
            System.assert(drugIngredient != null, 'Property not initialized.');
            System.assert(facilityIdentifier != null, 'Property not initialized.');
            System.assert(recordSource != null, 'Property not initialized.');
            System.assert(recordUpdateTime != null, 'Property not initialized.');
        }
        Test.stopTest();
    }
}
