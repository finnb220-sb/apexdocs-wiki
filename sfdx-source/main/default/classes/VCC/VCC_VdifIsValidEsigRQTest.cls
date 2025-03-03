@isTest
public with sharing class VCC_VdifIsValidEsigRQTest {
    @isTest
    public static void instantiationTest() {
        VCC_VdifIsValidEsigRQ isValidEsigRQEmpty;
        VCC_VdifIsValidEsigRQ isValidEsigRQRequiredFields;
        VCC_VdifIsValidEsigRQ isValidEsigRQFromVdifProvider;
        VCC_VdifIsValidEsigRQ isValidEsigRQFromVdifParameters;
        Exception unexpectedException;

        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            try {
                isValidEsigRQEmpty = new VCC_VdifIsValidEsigRQ();
                isValidEsigRQRequiredFields = new VCC_VdifIsValidEsigRQ('test', 'test', 'test', 'test');
                isValidEsigRQFromVdifProvider = new VCC_VdifIsValidEsigRQ(new VCC_VdifProvider());
                VCC_VdifParameters vdifParameters = new VCC_VdifParameters();
                (new VCC_VdifParametersDomain()).fillParametersWithDummyData(vdifParameters);
                isValidEsigRQFromVdifParameters = new VCC_VdifIsValidEsigRQ(vdifParameters);
            } catch (Exception e) {
                unexpectedException = e;
                System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            }
        }

        System.assert(unexpectedException == null, 'An exception was thrown unexpectedly.');
        System.assert(isValidEsigRQEmpty != null, 'Request did not instantiate properly.');
        System.assert(isValidEsigRQRequiredFields != null, 'Request did not instantiate properly.');
        System.assert(isValidEsigRQFromVdifProvider != null, 'Request did not instantiate properly.');
        System.assert(isValidEsigRQFromVdifParameters != null, 'Request did not instantiate properly.');
    }

    @isTest
    public static void isValidTest() {
        VCC_VdifIsValidEsigRQ isValidEsigRQEmpty;
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            isValidEsigRQEmpty = new VCC_VdifIsValidEsigRQ();
        }

        System.assert(isValidEsigRQEmpty.isValid() == false, 'Request is unexpectedly valid.');

        isValidEsigRQEmpty.providerLoginSiteCode = 'test';
        isValidEsigRQEmpty.providerName = 'test';
        isValidEsigRQEmpty.providerUserId = 'test';
        isValidEsigRQEmpty.criteria = 'test';

        System.assert(isValidEsigRQEmpty.isValid() == true, 'Request is unexpectedly invalid.');
    }
}
