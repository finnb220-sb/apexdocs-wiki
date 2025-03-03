@isTest
public with sharing class VCC_DASWriteNoteRSTest {
    @isTest
    public static void instantiationTest() {
        VCC_DASWriteNoteRS writeNoteRS = new VCC_DASWriteNoteRS();

        System.assert(writeNoteRS != null, 'Response did not instantiate as expected.');
        System.assert(writeNoteRS.noteResultTO != null, 'Response did not instantiate as expected.');
        System.assert(new VCC_DASWriteNoteRS.NoteResultTO() != null, 'Response did not instantiate as expected.');
    }
}
