/**
 * @author Booz Allen Hamilton
 * @description Test class that allows for the deserialization of the JSON HTTP response body of VCC_DASCreateAddendumAndSignFailureRS
 * @see VCC_DASCreateAddendumAndSignFailureRS for class being tested
 */
@IsTest
private class VCC_DASCreateAddendumSignFailureRSTest {
    @IsTest
    static void unitItConstructsPositive() {
        Test.startTest();
        try {
            Assert.isNotNull(new VCC_DASCreateAddendumAndSignFailureRS(), 'Expected class to be initialized.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void unitItCanBeUsedToDeserializeAddendumRespose1700Positive() {
        Test.startTest();
        String staticResourceName = 'VCC_DasCreateAddendumSignFailure1700';
        String sampleJson = (new VCR_StaticResourceRepo()).fetchByName(staticResourceName)[0].Body.toString();
        try {
            VCC_DASCreateAddendumAndSignFailureRS createAddendumSignFailure1700 = (VCC_DASCreateAddendumAndSignFailureRS) JSON.deserializeStrict(
                sampleJson,
                VCC_DASCreateAddendumAndSignFailureRS.class
            );

            Assert.areEqual(
                'OAUTH Fed Token is Empty or Invalid..Request Validation Failed, active false',
                createAddendumSignFailure1700.message,
                'Expected value from JSON tag "message" to be in the "message" property of VCC_DasCreateAddendumSignFailure1700.'
            );
            Assert.areEqual(
                '1700',
                createAddendumSignFailure1700.code,
                'Expected value from JSON tag "code" to be in the "code" property of VCC_DasCreateAddendumSignFailure1700.'
            );
            Assert.areEqual(
                'Invalid or expired oauth token',
                createAddendumSignFailure1700.description,
                'Expected value from JSON tag "description" to be in the "description" property of VCC_DasCreateAddendumSignFailure1700.'
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
    static void unitItCanBeUsedToDeserializeAddendumRespose1800Positive() {
        Test.startTest();
        String staticResourceName = 'VCC_DasCreateAddendumSignFailure1800';
        String sampleJson = (new VCR_StaticResourceRepo()).fetchByName(staticResourceName)[0].Body.toString();
        try {
            VCC_DASCreateAddendumAndSignFailureRS createAddendumSignFailure1800 = (VCC_DASCreateAddendumAndSignFailureRS) JSON.deserializeStrict(
                sampleJson,
                VCC_DASCreateAddendumAndSignFailureRS.class
            );
            Assert.areEqual(
                'OAUTH Fed Token is Empty or Invalid..Request Validation Failed, active false',
                createAddendumSignFailure1800.message,
                'Expected value from JSON tag "message" to be in the "message" property of VCC_DasCreateAddendumSignFailure1700.'
            );
            Assert.areEqual(
                '1800',
                createAddendumSignFailure1800.code,
                'Expected value from JSON tag "code" to be in the "code" property of VCC_DasCreateAddendumSignFailure1700.'
            );
            Assert.areEqual(
                'Invalid or expired oauth token',
                createAddendumSignFailure1800.description,
                'Expected value from JSON tag "description" to be in the "description" property of VCC_DasCreateAddendumSignFailure1700.'
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
