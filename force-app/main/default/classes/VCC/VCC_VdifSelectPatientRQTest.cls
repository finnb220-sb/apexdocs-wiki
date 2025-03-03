@isTest
public with sharing class VCC_VdifSelectPatientRQTest {
    @isTest
    public static void instantiationTest() {
        VCC_VdifSelectPatientRQ selectPatientEmptyRQ;
        VCC_VdifSelectPatientRQ selectPatientRequiredFieldsRQ;
        Exception unexpectedException;

        try {
            selectPatientEmptyRQ = new VCC_VdifSelectPatientRQ();
            selectPatientRequiredFieldsRQ = new VCC_VdifSelectPatientRQ('providerLoginSiteCode', 'providerName', 'providerUserId', 'patientLocalPid', 'patientLocalSiteId');
        } catch (Exception e) {
            unexpectedException = e;
        }

        System.assert(unexpectedException == null, 'An exception was thrown unexpectedly.');
        System.assert(selectPatientEmptyRQ != null, 'Request did not instantiate as expected.');
        System.assert(selectPatientRequiredFieldsRQ != null, 'Request did not instantiate as expected.');
    }

    @isTest
    public static void isValidTest() {
        VCC_VdifSelectPatientRQ selectPatientEmptyRQ = new VCC_VdifSelectPatientRQ();

        System.assert(selectPatientEmptyRQ.isValid() == false, 'Request is unexpectedly valid.');

        selectPatientEmptyRQ.providerLoginSiteCode = 'providerLoginSiteCode';
        selectPatientEmptyRQ.providerName = 'providerName';
        selectPatientEmptyRQ.providerUserId = 'providerUserId';
        selectPatientEmptyRQ.patientLocalPid = new List<String>{ 'patientLocalPid' };
        selectPatientEmptyRQ.patientLocalSiteId = 'patientLocalSiteId';

        System.assert(selectPatientEmptyRQ.isValid() == true, 'Request is unexpectedly invalid.');
    }
    @isTest
    public static void instantiationTestMultiplePid() {
        VCC_VdifSelectPatientRQ selectPatientEmptyRQ;
        VCC_VdifSelectPatientRQ selectPatientRequiredFieldsRQ;
        Exception unexpectedException;

        try {
            selectPatientEmptyRQ = new VCC_VdifSelectPatientRQ();
            selectPatientRequiredFieldsRQ = new VCC_VdifSelectPatientRQ(
                'providerLoginSiteCode',
                'providerName',
                'providerUserId',
                new List<String>{ 'patientLocalPid', 'patientLocalPid2' },
                'patientLocalSiteId'
            );
        } catch (Exception e) {
            unexpectedException = e;
        }

        System.assert(unexpectedException == null, 'An exception was thrown unexpectedly.');
        System.assert(selectPatientEmptyRQ != null, 'Request did not instantiate as expected.');
        System.assert(selectPatientRequiredFieldsRQ != null, 'Request did not instantiate as expected.');
    }
}
