/**
 * @author Booz Allen Hamilton
 * @description Test class that allows for the deserialization of the JSON HTTP response body of VCC_DASCreateAddendumAndSignSuccessRS
 * @see VCC_DASCreateAddendumAndSignSuccessRS for class being tested
 */
@IsTest
private class VCC_DASCreateAddendumSignSuccessRSTest {
    @IsTest
    static void unitItConstructsPositive() {
        Test.startTest();
        try {
            Assert.isNotNull(new VCC_DASCreateAddendumAndSignSuccessRS(), 'Expected class to be Initialized.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void unitDeserializeSampleResposeSuccessPositive() {
        Test.startTest();
        String staticResourceName = 'VCC_DasCreateAddendumSignSuccess';
        String sampleJson = (new VCR_StaticResourceRepo()).fetchByName(staticResourceName)[0].Body.toString();

        try {
            VCC_DASCreateAddendumAndSignSuccessRS createAddendumSignSuccessRs = (VCC_DASCreateAddendumAndSignSuccessRS) JSON.deserializeStrict(
                sampleJson,
                VCC_DASCreateAddendumAndSignSuccessRS.class
            );
            Assert.areEqual(
                'Addendum Data Created',
                createAddendumSignSuccessRs.textTO.text,
                'Expected value in JSON "textTO.text" to be present in same named property on VCC_DASWriteNoteSignSuccessRS'
            );
            Assert.areEqual(
                'Ok addendumIen',
                createAddendumSignSuccessRs.textTO.addendumIen,
                'Expected value in JSON "textTO.addendumIen" to be present in same named'
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
