/**
 * @description Test class that allows for the deserialization of the JSON HTTP response body of VCC_DASWriteNoteSignSuccessRS
 * @author Booz Allen Hamilton
 * @see VCC_DASWriteNoteSignSuccessRS for class being tested
 */
@IsTest
private class VCC_DASWriteNoteSignSuccessRSTest {
    @IsTest
    static void unitItConstructsPositive() {
        Test.startTest();
        try {
            Assert.isNotNull(
                new VCC_DASWriteNoteSignSuccessRS(),
                'Expected VCC_DASWriteNoteAndSignSuccessRS class to be Initialized.'
            );
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void unitItCanBeUsedToDeserializeSampleResposeSuccessPositive() {
        Test.startTest();
        String staticResourceName = 'VCC_DasWriteNoteAndSignSuccess';
        String sampleJson = (new VCR_StaticResourceRepo()).fetchByName(staticResourceName)[0].Body.toString();
        try {
            VCC_DASWriteNoteSignSuccessRS writeNoteSignSuccessRs = (VCC_DASWriteNoteSignSuccessRS) JSON.deserializeStrict(
                sampleJson,
                VCC_DASWriteNoteSignSuccessRS.class
            );
            Assert.areEqual(
                'OK',
                writeNoteSignSuccessRs.textTO.text,
                'Expected value in JSON "textTO.text" to be present in same named property on VCC_DASWriteNoteSignSuccessRS'
            );
            Assert.areEqual(
                'Ok noteIen',
                writeNoteSignSuccessRs.textTO.noteIen,
                'Expected value in JSON "textTO.noteIen" to be present in same named property on VCC_DASWriteNoteSignSuccessRS'
            );
        } catch (Exception thrownException) {
            Assert.fail(
                'Expected no exception, instead found ' +
                    thrownException.getTypeName() +
                    '\n' +
                    thrownException.getStackTraceString()
            );
        }
        Test.stopTest();
    }
}
