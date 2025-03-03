@isTest
public with sharing class VCC_VdifWriteNoteRQTest {
    @isTest
    public static void instantiationTest() {
        VCC_VdifWriteNoteRQ writeNoteEmptyRQ;
        VCC_VdifWriteNoteRQ writeNoteRequiredFieldsRQ;
        VCC_VdifWriteNoteRQ writeNoteVdifParametersRQ;
        Exception unexpectedException;

        try {
            writeNoteEmptyRQ = new VCC_VdifWriteNoteRQ();
            writeNoteRequiredFieldsRQ = new VCC_VdifWriteNoteRQ(
                'encounterString',
                'text',
                'providerName',
                'providerLoginSiteCode',
                'providerUserId',
                'patientLocalPid',
                'titleIEN'
            );
            VCC_VdifParameters vdifParameters = new VCC_VdifParameters();
            (new VCC_VdifParametersDomain()).fillParametersWithDummyData(vdifParameters);
            writeNoteVdifParametersRQ = new VCC_VdifWriteNoteRQ(vdifParameters);
        } catch (Exception e) {
            unexpectedException = e;
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }

        System.assert(unexpectedException == null, 'An exception was thrown unexpectedly.');
        System.assert(writeNoteEmptyRQ != null, 'Request did not instantiate as expected.');
        System.assert(writeNoteRequiredFieldsRQ != null, 'Request did not instantiate as expected.');
    }

    @isTest
    public static void isValidTest() {
        VCC_VdifWriteNoteRQ writeNoteEmptyRQ = new VCC_VdifWriteNoteRQ();

        System.assert(writeNoteEmptyRQ.isValid() == false, 'Request is unexpectedly valid.');

        writeNoteEmptyRQ.encounterString = 'encounterString';
        writeNoteEmptyRQ.text = 'text';
        writeNoteEmptyRQ.providerName = 'providerName';
        writeNoteEmptyRQ.providerLoginSiteCode = 'providerLoginSiteCode';
        writeNoteEmptyRQ.providerUserId = 'providerUserId';
        writeNoteEmptyRQ.patientLocalPid = 'patientLocalPid';
        writeNoteEmptyRQ.titleIEN = 'titleIEN';

        System.assert(writeNoteEmptyRQ.isValid() == true, 'Request is unexpectedly invalid.');
    }
}
