@isTest
public with sharing class VCC_BridgClientTest {
    @isTest
    public static void additionalSignersTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_BridgAdditionalSignersMock');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_BridgClient bridgClient = new VCC_BridgClient();
        VCC_BridgAdditionalSignersRQ rq = new VCC_BridgAdditionalSignersRQ('test', 'test');
        VCC_BridgAdditionalSignersRS rs;

        Test.startTest();
        rs = bridgClient.additionalSigners(rq);
        Test.stopTest();

        System.assert(rs != null, 'Expected non-null.');
    }
    @isTest
    public static void allergyTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_BridgAllergyMockResponse');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_BridgClient bridgClient = new VCC_BridgClient();
        VCC_BridgAllergyRQ rq = new VCC_BridgAllergyRQ('test', 'test');
        VCC_BridgAllergyRS rs;

        Test.startTest();
        rs = bridgClient.allergy(rq);
        Test.stopTest();

        System.assert(rs != null, 'Expected non-null.');
    }
    @isTest
    public static void appointmentsTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_AppointmentJsonExample');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_BridgClient bridgClient = new VCC_BridgClient();
        VCC_BridgAppointmentsRQ rq = new VCC_BridgAppointmentsRQ('test', 'test');
        VCC_BridgAppointmentsRS rs;

        Test.startTest();
        rs = bridgClient.appointments(rq);
        Test.stopTest();

        System.assert(rs != null, 'Expected non-null.');
    }
    @isTest
    public static void consultsTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_ConsultJsonExample');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_BridgClient bridgClient = new VCC_BridgClient();
        VCC_BridgConsultsRQ rq = new VCC_BridgConsultsRQ('test', 'test');
        VCC_BridgConsultsRS rs;

        Test.startTest();
        rs = bridgClient.consults(rq);
        Test.stopTest();

        System.assert(rs != null, 'Expected non-null.');
    }
    @isTest
    public static void flagsTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_FlagJsonExample');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_BridgClient bridgClient = new VCC_BridgClient();
        VCC_BridgFlagsRQ rq = new VCC_BridgFlagsRQ('test', 'test');
        VCC_BridgFlagsRS rs;

        Test.startTest();
        rs = bridgClient.flags(rq);
        Test.stopTest();

        System.assert(rs != null, 'Expected non-null.');
    }
    @isTest
    public static void immunizationTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_ImmunizationJsonExample');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_BridgClient bridgClient = new VCC_BridgClient();
        VCC_BridgImmunizationRQ rq = new VCC_BridgImmunizationRQ('test', 'test');
        VCC_BridgImmunizationRS rs;

        Test.startTest();
        rs = bridgClient.immunization(rq);
        Test.stopTest();

        System.assert(rs != null, 'Expected non-null.');
    }
    @isTest
    public static void labsTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_LabJsonExample');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_BridgClient bridgClient = new VCC_BridgClient();
        VCC_BridgLabsRQ rq = new VCC_BridgLabsRQ('test', 'test');
        VCC_BridgLabsRS rs;

        Test.startTest();
        rs = bridgClient.labs(rq);
        Test.stopTest();

        System.assert(rs != null, 'Expected non-null.');
    }
    @isTest
    public static void medsTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_MedicationJsonExample');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        Account account = new Account(Name = 'Unit Test');
        insert account;

        VCC_BridgClient bridgClient = new VCC_BridgClient();
        bridgClient.accountId = account.Id; // Todo: This dependency is so weird.  We need to revaluate the patterns of the BridgClient...
        VCC_BridgMedsRQ rq = new VCC_BridgMedsRQ('test', 'test');
        VCC_BridgMedsRS rs;

        Test.startTest();
        rs = bridgClient.meds(rq);
        Test.stopTest();

        System.assert(rs != null, 'Expected non-null.');
    }
    @isTest
    public static void notesTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('vccHistoricalProgressNotesMock');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_BridgClient bridgClient = new VCC_BridgClient();
        VCC_BridgNotesRQ rq = new VCC_BridgNotesRQ('test', 'test');
        VCC_BridgNotesRS rs;

        Test.startTest();
        rs = bridgClient.notes(rq);
        Test.stopTest();

        System.assert(rs != null, 'Expected non-null.');
    }
    @isTest
    public static void ordersTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_OrderJsonExample');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_BridgClient bridgClient = new VCC_BridgClient();
        VCC_BridgOrdersRQ rq = new VCC_BridgOrdersRQ('test', 'test');
        VCC_BridgOrdersRS rs;

        Test.startTest();
        rs = bridgClient.orders(rq);
        Test.stopTest();

        System.assert(rs != null, 'Expected non-null.');
    }
    @isTest
    public static void problemsTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_ProblemJsonExample');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_BridgClient bridgClient = new VCC_BridgClient();
        VCC_BridgProblemsRQ rq = new VCC_BridgProblemsRQ('test', 'test');
        VCC_BridgProblemsRS rs;

        Test.startTest();
        rs = bridgClient.problems(rq);
        Test.stopTest();

        System.assert(rs != null, 'Expected non-null.');
    }
    @isTest
    public static void radiologyExamsTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_RadiologyJsonExample');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_BridgClient bridgClient = new VCC_BridgClient();
        VCC_BridgRadiologyExamsRQ rq = new VCC_BridgRadiologyExamsRQ('test', 'test');
        VCC_BridgRadiologyExamsRS rs;

        Test.startTest();
        rs = bridgClient.radiologyExams(rq);
        Test.stopTest();

        System.assert(rs != null, 'Expected non-null.');
    }
    @isTest
    public static void visitsTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_BridgVisitMockResponse');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_BridgClient bridgClient = new VCC_BridgClient();
        VCC_BridgVisitsRQ rq = new VCC_BridgVisitsRQ('test', 'test');
        VCC_BridgVisitsRS rs;

        Test.startTest();
        rs = bridgClient.visits(rq);
        Test.stopTest();

        System.assert(rs != null, 'Expected non-null.');
    }
    @isTest
    public static void vitalsTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_BridgVitalsMock');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_BridgClient bridgClient = new VCC_BridgClient();
        VCC_BridgVitalsRQ rq = new VCC_BridgVitalsRQ('test', 'test');
        VCC_BridgVitalsRS rs;

        Test.startTest();
        rs = bridgClient.vitals(rq);
        Test.stopTest();

        System.assert(rs != null, 'Expected non-null.');
    }
}
