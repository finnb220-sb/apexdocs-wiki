@isTest
public with sharing class VCC_VdifSignNoteRQTest {
    @isTest
    public static void instantiationTest() {
        VCC_VdifSignNoteRQ signNoteEmptyRQ;
        VCC_VdifSignNoteRQ signNoteRequiredFieldsRQ;
        VCC_VdifSignNoteRQ signNoteVdifParametersRQ;
        Exception unexpectedException;

        try {
            signNoteEmptyRQ = new VCC_VdifSignNoteRQ();
            signNoteRequiredFieldsRQ = new VCC_VdifSignNoteRQ('esig', 'providerLoginSiteCode', 'providerName', 'providerUserId', 'noteIEN', 'userDUZ');
            VCC_VdifParameters vdifParameters = new VCC_VdifParameters();
            (new VCC_VdifParametersDomain()).fillParametersWithDummyData(vdifParameters);
            signNoteVdifParametersRQ = new VCC_VdifSignNoteRQ(vdifParameters);
        } catch (Exception e) {
            unexpectedException = e;
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }

        System.assert(unexpectedException == null, 'An exception was thrown unexpectedly.');
        System.assert(signNoteEmptyRQ != null, 'Request did not instantiate as expected.');
        System.assert(signNoteRequiredFieldsRQ != null, 'Request did not instantiate as expected.');
        System.assert(signNoteVdifParametersRQ != null, 'Request did not instantiate as expected.');
    }

    @isTest
    public static void isValidTest() {
        VCC_VdifSignNoteRQ signNoteEmptyRQ = new VCC_VdifSignNoteRQ();

        System.assert(signNoteEmptyRQ.isValid() == false, 'Request is unexpectedly valid.');

        signNoteEmptyRQ.esig = 'esig';
        signNoteEmptyRQ.providerLoginSiteCode = 'providerLoginSiteCode';
        signNoteEmptyRQ.providerName = 'providerName';
        signNoteEmptyRQ.providerUserId = 'providerUserId';
        signNoteEmptyRQ.noteIEN = 'noteIEN';
        signNoteEmptyRQ.userDUZ = 'userDUZ';

        System.assert(signNoteEmptyRQ.isValid() == true, 'Request is unexpectedly invalid.');
    }
}
