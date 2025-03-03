@isTest
public with sharing class VCC_DASSignNoteRQTest {
    @isTest
    public static void instantiationTest() {
        VCC_DASSignNoteRQ signNoteEmptyRQ;

        try {
            signNoteEmptyRQ = new VCC_DASSignNoteRQ();
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }

        Assert.isNotNull(signNoteEmptyRQ, 'Expected non-null value.');
    }

    @isTest
    public static void isValidTest() {
        VCC_DASSignNoteRQ signNoteEmptyRQ = new VCC_DASSignNoteRQ();

        Assert.areEqual(false, signNoteEmptyRQ.isValid(), 'Expected false.');

        signNoteEmptyRQ.esig = 'esig';
        signNoteEmptyRQ.providerLoginSiteCode = 'providerLoginSiteCode';
        signNoteEmptyRQ.providerName = 'providerName';
        signNoteEmptyRQ.providerUserId = 'providerUserId';
        signNoteEmptyRQ.noteIEN = 'noteIEN';

        Assert.areEqual(true, signNoteEmptyRQ.isValid(), 'Expected true.');
    }
}
