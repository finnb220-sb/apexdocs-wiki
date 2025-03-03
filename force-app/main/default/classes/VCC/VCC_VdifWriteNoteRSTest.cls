@isTest
public with sharing class VCC_VdifWriteNoteRSTest {
    @isTest
    public static void instantiationTest() {
        VCC_VdifWriteNoteRS writeNoteRS = new VCC_VdifWriteNoteRS();

        System.assert(writeNoteRS != null, 'Response did not instantiate as expected.');
        System.assert(writeNoteRS.noteResultTO != null, 'Response did not instantiate as expected.');
        System.assert(new VCC_VdifWriteNoteRS.NoteResultTO() != null, 'Response did not instantiate as expected.');
    }
}
