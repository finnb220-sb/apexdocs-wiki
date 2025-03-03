@isTest
public with sharing class VCC_VdifCreateAddendumRQTest {
    @isTest
    public static void instantiationTest() {
        Exception unexpectedException;
        VCC_VdifCreateAddendumRQ createAddendumRQEmpty;
        VCC_VdifCreateAddendumRQ createAddendumRQRequiredFields;
        VCC_VdifCreateAddendumRQ createAddendumRQFromVdifParameters;
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_Util.addPermSetGroupToUser('VAHC_Super_User', testuser);
        System.runAs(testuser) {
            Test.startTest();
            try {
                createAddendumRQEmpty = new VCC_VdifCreateAddendumRQ();
                createAddendumRQRequiredFields = new VCC_VdifCreateAddendumRQ('test', 'test', 'test', 'test', 'test');
                VCC_VdifParameters vdifParameters = new VCC_VdifParameters();
                (new VCC_VdifParametersDomain()).fillParametersWithDummyData(vdifParameters);
                createAddendumRQFromVdifParameters = new VCC_VdifCreateAddendumRQ(vdifParameters);
            } catch (Exception e) {
                unexpectedException = e;
            }
            Test.stopTest();
        }

        System.assert(unexpectedException == null, 'An exception was thrown unexpectedly.');
        System.assert(createAddendumRQEmpty != null, 'Request failed to instantiate.');
        System.assert(createAddendumRQRequiredFields != null, 'Request failed to instantiate.');
        System.assert(createAddendumRQFromVdifParameters != null, 'Request failed to instantiate.');
    }

    @isTest
    public static void isValidTest() {
        VCC_VdifCreateAddendumRQ createAddendumRQ;
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_Util.addPermSetGroupToUser('VAHC_Super_User', testuser);
        System.runAs(testuser) {
            createAddendumRQ = new VCC_VdifCreateAddendumRQ();
        }

        System.assert(createAddendumRQ.isValid() == false, 'Request unexpectedly valid.');

        createAddendumRQ.itemId = 'test';
        createAddendumRQ.type = 'test';
        createAddendumRQ.criteria = 'test';
        createAddendumRQ.providerLoginSiteCode = 'test';
        createAddendumRQ.providerUserId = 'test';

        System.assert(createAddendumRQ.isValid() == true, 'Request unexpectedly invalid.');
    }
}
