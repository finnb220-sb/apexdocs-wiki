@isTest
public with sharing class VCC_DASSaveNoteAndEncounterRQTest {
    @isTest
    public static void instantiationTest() {
        VCC_DASSaveNoteAndEncounterRQ saveNoteAndEncounterEmptyRQ;

        try {
            saveNoteAndEncounterEmptyRQ = new VCC_DASSaveNoteAndEncounterRQ();
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }

        Assert.isNotNull(saveNoteAndEncounterEmptyRQ, 'Request did not instantiate as expected.');
    }

    @isTest
    public static void isValidTest() {
        VCC_DASSaveNoteAndEncounterRQ saveNoteAndEncounterEmptyRQ = new VCC_DASSaveNoteAndEncounterRQ();

        Assert.areEqual(false, saveNoteAndEncounterEmptyRQ.isValid());

        saveNoteAndEncounterEmptyRQ.providerUserId = 'test';
        saveNoteAndEncounterEmptyRQ.patientName = 'test';
        saveNoteAndEncounterEmptyRQ.patientLocalPid = 'test';
        saveNoteAndEncounterEmptyRQ.patientLocalSiteId = 'test';
        saveNoteAndEncounterEmptyRQ.noteAndEncounterLocationIen = 'test';
        saveNoteAndEncounterEmptyRQ.noteAndEncounterNoteTitleIen = 'test';
        saveNoteAndEncounterEmptyRQ.noteAndEncounterServiceCategory = 'test';

        Assert.areEqual(true, saveNoteAndEncounterEmptyRQ.isValid());
    }
}
