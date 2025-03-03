@isTest
public with sharing class VCC_BridgProxyTest {
    @isTest
    public static void additionalSignersTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_BridgAdditionalSignersMock');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_BridgProxy bridgProxy = new VCC_BridgProxy();

        VCC_BridgAdditionalSignersRQ rq = new VCC_BridgAdditionalSignersRQ('test', 'test');
        VCC_BridgAdditionalSignersRS rs;

        Test.startTest();
        rs = bridgProxy.additionalSigners(rq);
        Test.stopTest();

        System.assert(rs != null, 'Expected non-null.');
    }
    @isTest
    public static void allergyTest() {
        VCC_BridgProxy bridgProxy = new VCC_BridgProxy();
        VCC_Stub clientStub = new VCC_Stub(VCC_BridgClient.class);
        bridgProxy.setClientStub(clientStub);

        clientStub.setReturnValue('allergy', new VCC_BridgAllergyRS());

        Test.startTest();
        bridgProxy.allergy(null);
        Test.stopTest();

        clientStub.assertInvoked('allergy');

        System.assert(true, 'Empty assert.');
    }
    @isTest
    public static void appointmentsTest() {
        VCC_BridgProxy bridgProxy = new VCC_BridgProxy();
        VCC_Stub clientStub = new VCC_Stub(VCC_BridgClient.class);
        bridgProxy.setClientStub(clientStub);

        clientStub.setReturnValue('appointments', new VCC_BridgAppointmentsRS());

        Test.startTest();
        bridgProxy.appointments(null);
        Test.stopTest();

        clientStub.assertInvoked('appointments');

        System.assert(true, 'Empty assert.');
    }
    @isTest
    public static void consultsTest() {
        VCC_BridgProxy bridgProxy = new VCC_BridgProxy();
        VCC_Stub clientStub = new VCC_Stub(VCC_BridgClient.class);
        bridgProxy.setClientStub(clientStub);

        clientStub.setReturnValue('consults', new VCC_BridgConsultsRS());

        Test.startTest();
        bridgProxy.consults(null);
        Test.stopTest();

        clientStub.assertInvoked('consults');

        System.assert(true, 'Empty assert.');
    }
    @isTest
    public static void flagsTest() {
        VCC_BridgProxy bridgProxy = new VCC_BridgProxy();
        VCC_Stub clientStub = new VCC_Stub(VCC_BridgClient.class);
        bridgProxy.setClientStub(clientStub);

        clientStub.setReturnValue('flags', new VCC_BridgFlagsRS());

        Test.startTest();
        bridgProxy.flags(null);
        Test.stopTest();

        clientStub.assertInvoked('flags');

        System.assert(true, 'Empty assert.');
    }
    @isTest
    public static void immunizationTest() {
        VCC_BridgProxy bridgProxy = new VCC_BridgProxy();
        VCC_Stub clientStub = new VCC_Stub(VCC_BridgClient.class);
        bridgProxy.setClientStub(clientStub);

        clientStub.setReturnValue('immunization', new VCC_BridgImmunizationRS());

        Test.startTest();
        bridgProxy.immunization(null);
        Test.stopTest();

        clientStub.assertInvoked('immunization');

        System.assert(true, 'Empty assert.');
    }
    @isTest
    public static void labsTest() {
        VCC_BridgProxy bridgProxy = new VCC_BridgProxy();
        VCC_Stub clientStub = new VCC_Stub(VCC_BridgClient.class);
        bridgProxy.setClientStub(clientStub);

        clientStub.setReturnValue('labs', new VCC_BridgLabsRS());

        Test.startTest();
        bridgProxy.labs(null);
        Test.stopTest();

        clientStub.assertInvoked('labs');

        System.assert(true, 'Empty assert.');
    }
    @isTest
    public static void medsTest() {
        VCC_BridgProxy bridgProxy = new VCC_BridgProxy();
        VCC_Stub clientStub = new VCC_Stub(VCC_BridgClient.class);
        bridgProxy.setClientStub(clientStub);

        clientStub.setReturnValue('meds', new VCC_BridgMedsRS());

        Test.startTest();
        bridgProxy.meds(null);
        Test.stopTest();

        clientStub.assertInvoked('meds');

        System.assert(true, 'Empty assert.');
    }
    @isTest
    public static void notesTest() {
        VCC_BridgProxy bridgProxy = new VCC_BridgProxy();
        VCC_Stub clientStub = new VCC_Stub(VCC_BridgClient.class);
        bridgProxy.setClientStub(clientStub);

        clientStub.setReturnValue('notes', new VCC_BridgNotesRS());

        Test.startTest();
        bridgProxy.notes(null);
        Test.stopTest();

        clientStub.assertInvoked('notes');

        System.assert(true, 'Empty assert.');
    }
    @isTest
    public static void ordersTest() {
        VCC_BridgProxy bridgProxy = new VCC_BridgProxy();
        VCC_Stub clientStub = new VCC_Stub(VCC_BridgClient.class);
        bridgProxy.setClientStub(clientStub);

        clientStub.setReturnValue('orders', new VCC_BridgOrdersRS());

        Test.startTest();
        bridgProxy.orders(null);
        Test.stopTest();

        clientStub.assertInvoked('orders');

        System.assert(true, 'Empty assert.');
    }
    @isTest
    public static void problemsTest() {
        VCC_BridgProxy bridgProxy = new VCC_BridgProxy();
        VCC_Stub clientStub = new VCC_Stub(VCC_BridgClient.class);
        bridgProxy.setClientStub(clientStub);

        clientStub.setReturnValue('problems', new VCC_BridgProblemsRS());

        Test.startTest();
        bridgProxy.problems(null);
        Test.stopTest();

        clientStub.assertInvoked('problems');

        System.assert(true, 'Empty assert.');
    }
    @isTest
    public static void radiologyExamsTest() {
        VCC_BridgProxy bridgProxy = new VCC_BridgProxy();
        VCC_Stub clientStub = new VCC_Stub(VCC_BridgClient.class);
        bridgProxy.setClientStub(clientStub);

        clientStub.setReturnValue('radiologyExams', new VCC_BridgRadiologyExamsRS());

        Test.startTest();
        bridgProxy.radiologyExams(null);
        Test.stopTest();

        clientStub.assertInvoked('radiologyExams');

        System.assert(true, 'Empty assert.');
    }
    @isTest
    public static void visitsTest() {
        VCC_BridgProxy bridgProxy = new VCC_BridgProxy();
        VCC_Stub clientStub = new VCC_Stub(VCC_BridgClient.class);
        bridgProxy.setClientStub(clientStub);

        clientStub.setReturnValue('visits', new VCC_BridgVisitsRS());

        Test.startTest();
        bridgProxy.visits(null);
        Test.stopTest();

        clientStub.assertInvoked('visits');

        System.assert(true, 'Empty assert.');
    }
    @isTest
    public static void vitalsTest() {
        VCC_BridgProxy bridgProxy = new VCC_BridgProxy();
        VCC_Stub clientStub = new VCC_Stub(VCC_BridgClient.class);
        bridgProxy.setClientStub(clientStub);

        clientStub.setReturnValue('vitals', new VCC_BridgVitalsRS());

        Test.startTest();
        bridgProxy.vitals(null);
        Test.stopTest();

        clientStub.assertInvoked('vitals');

        System.assert(true, 'Empty assert.');
    }
}
