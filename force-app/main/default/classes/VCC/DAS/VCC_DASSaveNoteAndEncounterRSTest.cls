@isTest
public with sharing class VCC_DASSaveNoteAndEncounterRSTest {
    @isTest
    public static void instantiationTest() {
        VCC_DASSaveNoteAndEncounterRS saveNoteAndEncounterRS = new VCC_DASSaveNoteAndEncounterRS();

        System.assert(saveNoteAndEncounterRS != null, 'Response did not instantiate as expected.');
        System.assert(saveNoteAndEncounterRS.textTO != null, 'Response did not instantiate as expected.');
    }
}
