@isTest
public with sharing class VCC_VdifSaveNoteAndEncounterRSTest {
    @isTest
    public static void instantiationTest() {
        VCC_VdifSaveNoteAndEncounterRS saveNoteAndEncounterRS = new VCC_VdifSaveNoteAndEncounterRS();

        System.assert(saveNoteAndEncounterRS != null, 'Response did not instantiate as expected.');
        System.assert(saveNoteAndEncounterRS.saveNoteAndEncounterTextTO != null, 'Response did not instantiate as expected.');
    }
}
