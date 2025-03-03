@isTest
public with sharing class VCC_VdifSaveNoteAndEncounterRQTest {
    @isTest
    public static void instantiationTest() {
        VCC_VdifSaveNoteAndEncounterRQ saveNoteAndEncounterEmptyRQ;
        VCC_VdifSaveNoteAndEncounterRQ saveNoteAndEncounterRequiredFieldsRQ;
        VCC_VdifSaveNoteAndEncounterRQ saveNoteAndEncounterFromVdifParametersRQ;
        Exception unexpectedException;

        try {
            saveNoteAndEncounterEmptyRQ = new VCC_VdifSaveNoteAndEncounterRQ();
            saveNoteAndEncounterRequiredFieldsRQ = new VCC_VdifSaveNoteAndEncounterRQ(
                'providerLoginSiteCode',
                'providerUserId',
                'patientLocalPid',
                'patientLocalSiteId',
                'noteAndEncounterLocationIen',
                'noteAndEncounterNoteTitleIen',
                'noteAndEncounterServiceCategory',
                'noteAndEncounterProcedures',
                'noteAndEncounterDiagnoses'
            );
            VCC_VdifParameters vdifParameters = new VCC_VdifParameters();
            (new VCC_VdifParametersDomain()).fillParametersWithDummyData(vdifParameters);
            saveNoteAndEncounterFromVdifParametersRQ = new VCC_VdifSaveNoteAndEncounterRQ(vdifParameters);
        } catch (Exception e) {
            unexpectedException = e;
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }

        System.assert(unexpectedException == null, 'An exception was thrown unexpectedly.');
        System.assert(saveNoteAndEncounterEmptyRQ != null, 'Request did not instantiate as expected.');
        System.assert(saveNoteAndEncounterRequiredFieldsRQ != null, 'Request did not instantiate as expected.');
        System.assert(saveNoteAndEncounterFromVdifParametersRQ != null, 'Request did not instantiate as expected.');
    }

    @isTest
    public static void isValidTest() {
        VCC_VdifSaveNoteAndEncounterRQ saveNoteAndEncounterEmptyRQ = new VCC_VdifSaveNoteAndEncounterRQ();

        System.assert(saveNoteAndEncounterEmptyRQ.isValid() == false, 'Request is unexpectedly valid.');

        saveNoteAndEncounterEmptyRQ.providerLoginSiteCode = 'providerLoginSiteCode';
        saveNoteAndEncounterEmptyRQ.providerUserId = 'providerUserId';
        saveNoteAndEncounterEmptyRQ.patientLocalPid = 'patientLocalPid';
        saveNoteAndEncounterEmptyRQ.patientLocalSiteId = 'patientLocalSiteId';
        saveNoteAndEncounterEmptyRQ.noteAndEncounterLocationIen = 'noteAndEncounterLocationIen';
        saveNoteAndEncounterEmptyRQ.noteAndEncounterNoteTitleIen = 'noteAndEncounterNoteTitleIen';
        saveNoteAndEncounterEmptyRQ.noteAndEncounterServiceCategory = 'noteAndEncounterServiceCategory';
        saveNoteAndEncounterEmptyRQ.noteAndEncounterProcedures = 'noteAndEncounterProcedures';
        saveNoteAndEncounterEmptyRQ.noteAndEncounterDiagnoses = 'noteAndEncounterDiagnoses';

        System.assert(saveNoteAndEncounterEmptyRQ.isValid() == true, 'Request is unexpectedly invalid.');
    }
}
