@isTest
public with sharing class VCC_DASSelectPatientRQTest {
    @isTest
    public static void instantiationTest() {
        VCC_DASSelectPatientRQ selectPatientEmptyRQ;
        VCC_DASSelectPatientRQ selectPatientRequiredFieldsRQ;
        Exception unexpectedException;

        try {
            selectPatientEmptyRQ = new VCC_DASSelectPatientRQ();
            selectPatientRequiredFieldsRQ = new VCC_DASSelectPatientRQ(
                'providerLoginSiteCode',
                'providerName',
                'providerUserId',
                'patientLocalPid',
                'patientLocalSiteId'
            );
        } catch (Exception e) {
            unexpectedException = e;
        }

        Assert.isTrue(unexpectedException == null, 'An exception was thrown unexpectedly.');
        Assert.isTrue(selectPatientEmptyRQ != null, 'Request did not instantiate as expected.');
        Assert.isTrue(selectPatientRequiredFieldsRQ != null, 'Request did not instantiate as expected.');
    }

    @isTest
    public static void isValidTest() {
        VCC_DASSelectPatientRQ selectPatientEmptyRQ = new VCC_DASSelectPatientRQ();

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
        VCC_DASSelectPatientRQ selectPatientEmptyRQ;
        VCC_DASSelectPatientRQ selectPatientRequiredFieldsRQ;
        Exception unexpectedException;

        try {
            selectPatientEmptyRQ = new VCC_DASSelectPatientRQ();
            selectPatientRequiredFieldsRQ = new VCC_DASSelectPatientRQ(
                'providerLoginSiteCode',
                'providerName',
                'providerUserId',
                new List<String>{ 'patientLocalPid', 'patientLocalPid2' },
                'patientLocalSiteId'
            );
        } catch (Exception e) {
            unexpectedException = e;
        }

        Assert.isTrue(unexpectedException == null, 'An exception was thrown unexpectedly.');
        Assert.isTrue(selectPatientEmptyRQ != null, 'Request did not instantiate as expected.');
        Assert.isTrue(selectPatientRequiredFieldsRQ != null, 'Request did not instantiate as expected.');
    }
}
