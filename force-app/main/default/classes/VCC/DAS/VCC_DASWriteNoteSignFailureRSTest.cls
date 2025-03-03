/**
 * @description Test class that allows for the deserialization of the JSON HTTP response body of VCC_DASCreateAddendumAndSignFailureRS
 * @author Booz Allen Hamilton
 * @see VCC_DASWriteNoteSignFailureRS for class being tested
 */
@IsTest
private class VCC_DASWriteNoteSignFailureRSTest {
    @IsTest
    static void unitItConstructsPositive() {
        Test.startTest();
        try {
            Assert.isNotNull(
                new VCC_DASWriteNoteSignFailureRS(),
                'Expected VCC_DASWriteNoteAndSignFailureRS class to be initialized.'
            );
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void unitItCanBeUsedToDeserializeSampleRespose1600Positive() {
        Test.startTest();
        String staticResourceName = 'VCC_DasWriteNoteAndSign1600';
        String sampleJson = (new VCR_StaticResourceRepo()).fetchByName(staticResourceName)[0].Body.toString();
        try {
            VCC_DASWriteNoteSignFailureRS writeNoteAndSignFailureRs = (VCC_DASWriteNoteSignFailureRS) JSON.deserializeStrict(
                sampleJson,
                VCC_DASWriteNoteSignFailureRS.class
            );
            Assert.areEqual(
                ': user not authorized to sign You may not SIGN this UNSIGNED CCC: CLINICAL.',
                writeNoteAndSignFailureRs.message,
                'Expected value from JSON tag "message" to be in the "message" property of VCC_DASWriteNoteSignFailureRS.'
            );
            Assert.areEqual(
                '1600',
                writeNoteAndSignFailureRs.code,
                'Expected value from JSON tag "code" to be in the "code" property of VCC_DASWriteNoteSignFailureRS.'
            );
            Assert.areEqual(
                'Sign Note Error',
                writeNoteAndSignFailureRs.description,
                'Expected value from JSON tag "description" to be in the "description" property of VCC_DASWriteNoteSignFailureRS.'
            );
            Assert.areEqual(
                '5307266',
                writeNoteAndSignFailureRs.noteIen,
                'Expected value from JSON tag "noteIen" to be in the "noteIen" property of VCC_DASWriteNoteSignFailureRS.'
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

    @IsTest
    static void unitItCanBeUsedToDeserializeSampleRespose1000Positive() {
        Test.startTest();
        String staticResourceName = 'VCC_DasWriteNoteAndSign1000';
        String sampleJson = (new VCR_StaticResourceRepo()).fetchByName(staticResourceName)[0].Body.toString();
        try {
            VCC_DASWriteNoteSignFailureRS writeNoteAndSignFailureRs = (VCC_DASWriteNoteSignFailureRS) JSON.deserializeStrict(
                sampleJson,
                VCC_DASWriteNoteSignFailureRS.class
            );
            Assert.areEqual(
                '071 OAUTH Fed Token is Empty or Invalid..Request Validation Failed, active false',
                writeNoteAndSignFailureRs.message,
                'Expected value from JSON tag "message" to be in the "message" property of VCC_DASWriteNoteSignFailureRS.'
            );
            Assert.areEqual(
                '1000',
                writeNoteAndSignFailureRs.code,
                'Expected value from JSON tag "code" to be in the "code" property of VCC_DASWriteNoteSignFailureRS.'
            );
            Assert.areEqual(
                'Invalid or expired oauth token',
                writeNoteAndSignFailureRs.description,
                'Expected value from JSON tag "description" to be in the "description" property of VCC_DASWriteNoteSignFailureRS.'
            );
            Assert.isNull(
                writeNoteAndSignFailureRs.noteIen,
                'Expected "noteIen" property of VCC_DASWriteNoteSignFailureRS.to be null.'
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
