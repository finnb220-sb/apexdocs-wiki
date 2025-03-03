@isTest
public with sharing class VCC_VdifGetProvidersBySiteRQTest {
    @isTest
    public static void instantiationTest() {
        VCC_VdifGetProvidersBySiteRQ getProvidersBySiteRQEmpty;
        VCC_VdifGetProvidersBySiteRQ getProvidersBySiteRQRequiredFields;
        Exception unexpectedException;
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            try {
                getProvidersBySiteRQEmpty = new VCC_VdifGetProvidersBySiteRQ();
                getProvidersBySiteRQRequiredFields = new VCC_VdifGetProvidersBySiteRQ('test', 'test', 'test');
            } catch (Exception e) {
                unexpectedException = e;
                System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            }
        }

        System.assert(unexpectedException == null, 'An exception was thrown unexpectedly.');
        System.assert(getProvidersBySiteRQEmpty != null, 'An exception was thrown unexpectedly.');
        System.assert(getProvidersBySiteRQRequiredFields != null, 'An exception was thrown unexpectedly.');
    }

    @isTest
    public static void isValidTest() {
        VCC_VdifGetProvidersBySiteRQ getProvidersBySiteRQ;
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            getProvidersBySiteRQ = new VCC_VdifGetProvidersBySiteRQ();
        }

        System.assert(getProvidersBySiteRQ.isValid() == false, 'Request unexpectedly valid.');

        getProvidersBySiteRQ.providerLoginSiteCode = 'test';
        getProvidersBySiteRQ.providerName = 'test';
        getProvidersBySiteRQ.providerUserId = 'test';

        System.assert(getProvidersBySiteRQ.isValid() == true, 'Request unexpectedly invalid.');
    }

    @isTest
    public static void constructorWithVdifParams() {
        VCC_VdifGetProvidersBySiteRQ getProvidersBySiteRQ;
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        VCC_VdifParameters params = new VCC_VdifParameters();
        System.runAs(testuser) {
            getProvidersBySiteRQ = new VCC_VdifGetProvidersBySiteRQ(params);
        }

        System.assert(getProvidersBySiteRQ.isValid() == false, 'Request unexpectedly valid.');

        getProvidersBySiteRQ.providerLoginSiteCode = 'test';
        getProvidersBySiteRQ.providerName = 'test';
        getProvidersBySiteRQ.providerUserId = 'test';

        System.assert(getProvidersBySiteRQ.isValid() == true, 'Request unexpectedly invalid.');
    }
}
