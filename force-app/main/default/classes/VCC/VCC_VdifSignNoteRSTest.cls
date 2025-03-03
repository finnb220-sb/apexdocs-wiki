@isTest
public with sharing class VCC_VdifSignNoteRSTest {
    @isTest
    public static void instantiationTest() {
        VCC_VdifSignNoteRS signNoteRS = new VCC_VdifSignNoteRS();

        System.assert(signNoteRS != null, 'Response did not instantiate as expected.');
        System.assert(signNoteRS.signNoteTextTO != null, 'Response did not instantiate as expected.');
    }
}
