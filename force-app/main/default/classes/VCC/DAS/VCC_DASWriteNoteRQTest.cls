@isTest
public with sharing class VCC_DASWriteNoteRQTest {
    @isTest
    public static void instantiationTest() {
        VCC_DASWriteNoteRQ writeNoteEmptyRQ;
        Exception unexpectedException;

        try {
            writeNoteEmptyRQ = new VCC_DASWriteNoteRQ();
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage());
        }

        Assert.isNotNull(writeNoteEmptyRQ, 'Expected non-null value.');
    }

    @isTest
    public static void isValidTest() {
        VCC_DASWriteNoteRQ writeNoteEmptyRQ = new VCC_DASWriteNoteRQ();

        Assert.areEqual(false, writeNoteEmptyRQ.isValid(), 'Expected false.');

        writeNoteEmptyRQ.encounterString = 'test';
        writeNoteEmptyRQ.text = 'test';
        writeNoteEmptyRQ.providerUserId = 'test';
        writeNoteEmptyRQ.patientLocalPid = 'test';
        writeNoteEmptyRQ.patientName = 'test';
        writeNoteEmptyRQ.patientLocalSiteId = 'test';
        writeNoteEmptyRQ.titleIEN = 'test';
        writeNoteEmptyRQ.authorDUZ = 'test';

        Assert.areEqual(true, writeNoteEmptyRQ.isValid(), 'Expected true.');
    }
}
