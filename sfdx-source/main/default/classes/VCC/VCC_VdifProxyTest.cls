@isTest
public with sharing class VCC_VdifProxyTest {
    public static final String USERNAME_PREFIX = 'VdifProxy_RN_User';
    @TestSetup
    static void makeData() {
        User runningUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VCC_Registered_Nurse', runningUser);
        runningUser.Username = USERNAME_PREFIX + runningUser.Username;
        update runningUser;
    }
    /**
     * @description Gets the running user for the test
     * @return      `User`
     */
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE Username LIKE :USERNAME_PREFIX + '%' LIMIT 1];
    }
    @isTest
    public static void getAdditionalSignersHappyTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_vdifGetAdditionalSignersMockResponse');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_VdifProxy vdifProxy = new VCC_VdifProxy();

        VCC_VdifGetAdditionalSignersRQ req = new VCC_VdifGetAdditionalSignersRQ('test', 'test', 'test', 'test', new List<String>{ 'test' });
        VCC_VdifGetAdditionalSignersRS res;
        Exception unexpectedException;
        System.runAs(getTestUser()) {
            Test.startTest();
            res = vdifProxy.getAdditionalSigners(req);
            Test.stopTest();
        }

        System.assert(unexpectedException == null, 'An exception was thrown unexpectedly.');
        System.assert(res.taggedTextArray != null, 'Response not deserialized as expected.');
    }

    @isTest
    public static void getAdditionalSignersTest() {
        VCC_Stub vdifClientStub = new VCC_Stub(VCC_VdifClient.class);
        VCC_VdifProxy vdifProxy = new VCC_VdifProxy();
        vdifProxy.setClientStub(vdifClientStub);
        vdifClientStub.setReturnValue('getAdditionalSigners', null);

        System.runAs(getTestUser()) {
            Test.startTest();
            vdifProxy.getAdditionalSigners(null);
            Test.stopTest();
        }
        vdifClientStub.assertInvoked('getAdditionalSigners');

        System.assert(true, 'Empty assert.');
    }
    @isTest
    public static void createAddendumTest() {
        VCC_Stub vdifClientStub = new VCC_Stub(VCC_VdifClient.class);
        VCC_VdifProxy vdifProxy = new VCC_VdifProxy();
        vdifProxy.setClientStub(vdifClientStub);
        vdifClientStub.setReturnValue('createAddendum', null);

        System.runAs(getTestUser()) {
            Test.startTest();
            vdifProxy.createAddendum(null);
            Test.stopTest();
        }
        vdifClientStub.assertInvoked('createAddendum');

        System.assert(true, 'Empty assert.');
    }
    @isTest
    public static void isValidEsigTest() {
        VCC_Stub vdifClientStub = new VCC_Stub(VCC_VdifClient.class);
        VCC_VdifProxy vdifProxy = new VCC_VdifProxy();
        vdifProxy.setClientStub(vdifClientStub);
        vdifClientStub.setReturnValue('isValidEsig', null);

        System.runAs(getTestUser()) {
            Test.startTest();
            vdifProxy.isValidEsig(null);
            Test.stopTest();
        }
        vdifClientStub.assertInvoked('isValidEsig');

        System.assert(true, 'Empty assert.');
    }
    @isTest
    public static void saveNoteAndEncounterTest() {
        VCC_Stub vdifClientStub = new VCC_Stub(VCC_VdifClient.class);
        VCC_VdifProxy vdifProxy = new VCC_VdifProxy();
        vdifProxy.setClientStub(vdifClientStub);
        vdifClientStub.setReturnValue('saveNoteAndEncounter', null);

        System.runAs(getTestUser()) {
            Test.startTest();
            vdifProxy.saveNoteAndEncounter(null);
            Test.stopTest();
        }
        vdifClientStub.assertInvoked('saveNoteAndEncounter');

        System.assert(true, 'Empty assert.');
    }
    @isTest
    public static void signNoteTest() {
        VCC_Stub vdifClientStub = new VCC_Stub(VCC_VdifClient.class);
        VCC_VdifProxy vdifProxy = new VCC_VdifProxy();
        vdifProxy.setClientStub(vdifClientStub);
        vdifClientStub.setReturnValue('signNote', null);

        System.runAs(getTestUser()) {
            Test.startTest();
            vdifProxy.signNote(null);
            Test.stopTest();
        }

        vdifClientStub.assertInvoked('signNote');

        System.assert(true, 'Empty assert.');
    }
    @isTest
    public static void writeNoteTest() {
        VCC_Stub vdifClientStub = new VCC_Stub(VCC_VdifClient.class);
        VCC_VdifProxy vdifProxy = new VCC_VdifProxy();
        vdifProxy.setClientStub(vdifClientStub);
        vdifClientStub.setReturnValue('writeNote', null);

        System.runAs(getTestUser()) {
            Test.startTest();
            vdifProxy.writeNote(null);
            Test.stopTest();
        }
        vdifClientStub.assertInvoked('writeNote');

        System.assert(true, 'Empty assert.');
    }
    @isTest
    public static void selectPatientTest() {
        VCC_Stub vdifClientStub = new VCC_Stub(VCC_VdifClient.class);
        VCC_VdifProxy vdifProxy = new VCC_VdifProxy();
        vdifProxy.setClientStub(vdifClientStub);
        vdifClientStub.setReturnValue('selectPatient', null);

        System.runAs(getTestUser()) {
            Test.startTest();
            vdifProxy.selectPatient(null);
            Test.stopTest();
        }
        vdifClientStub.assertInvoked('selectPatient');

        System.assert(true, 'Empty assert.');
    }
    @isTest
    public static void getProvidersBySiteTest() {
        VCC_Stub vdifClientStub = new VCC_Stub(VCC_VdifClient.class);
        VCC_VdifProxy vdifProxy = new VCC_VdifProxy();
        vdifProxy.setClientStub(vdifClientStub);
        vdifClientStub.setReturnValue('getProvidersBySite', null);

        System.runAs(getTestUser()) {
            Test.startTest();
            vdifProxy.getProvidersBySite(null);
            Test.stopTest();
        }
        vdifClientStub.assertInvoked('getProvidersBySite');

        System.assert(true, 'Empty assert.');
    }
}
