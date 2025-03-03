/**
 * @description Test class for VCC_DASServiceEndpoint
 * @author      Booz Allen
 * @see         VCC_DASServiceEndpoint
 */
@IsTest
public class VCC_DASServiceEndpointTest {
    @TestVisible
    private static VATEST_MockedMethod getMockedMethodGetEndpoint() {
        return new VATEST_MockedMethod(
            new VATEST_MethodSignature('getEndpoint', new List<System.Type>{ VCC_DAS.Endpoint.class })
        );
    }

    @IsTest
    private static void unitGetEndpointUnmappedEndpointNegative() {
        Test.startTest();
        try {
            VCC_DAS.SERVICES.ENDPOINT.getEndpoint(null);
            Assert.fail('Expected an exception.');
        } catch (VCC_DASServiceEndpoint.UnmappedEndpointException thrownException) {
            Assert.isTrue(
                thrownException.getMessage().contains(VCC_DAS.SERVICES.ENDPOINT.UNMAPPED_ENDPOINT),
                'Expected exception to contain that value.'
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitGetEndpointBadConfigNegative() {
        VCC_DAS.SERVICES.ENDPOINT.endpointToServiceNameMap.put(VCC_DAS.Endpoint.IS_VALID_ESIG, '_badConfig');
        Test.startTest();
        try {
            VCC_DAS.SERVICES.ENDPOINT.getEndpoint(VCC_DAS.Endpoint.IS_VALID_ESIG);
            Assert.fail('Expected an exception.');
        } catch (VCC_DASServiceEndpoint.BadConfigurationException thrownException) {
            Assert.isTrue(
                thrownException.getMessage().contains(VCC_DAS.SERVICES.ENDPOINT.BAD_CONFIGURATION),
                'Expected exception to contain bad configuration value.'
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitGetEndpointIsValidEsigPositive() {
        Test.startTest();
        try {
            Assert.isNotNull(
                VCC_DAS.SERVICES.ENDPOINT.getEndpoint(VCC_DAS.Endpoint.IS_VALID_ESIG),
                'Expected non-null value.'
            );
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception: ' + thrownException.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitGetEndpointSelectPatientPositive() {
        Test.startTest();
        try {
            Assert.isNotNull(
                VCC_DAS.SERVICES.ENDPOINT.getEndpoint(VCC_DAS.Endpoint.SELECT_PATIENT),
                'Expected non-null value.'
            );
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception: ' + thrownException.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitGetEndpointWriteNotePositive() {
        Test.startTest();
        try {
            Assert.isNotNull(
                VCC_DAS.SERVICES.ENDPOINT.getEndpoint(VCC_DAS.Endpoint.WRITE_NOTE),
                'Expected non-null value.'
            );
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception: ' + thrownException.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitGetEndpointSignNotePositive() {
        Test.startTest();
        try {
            Assert.isNotNull(
                VCC_DAS.SERVICES.ENDPOINT.getEndpoint(VCC_DAS.Endpoint.SIGN_NOTE),
                'Expected non-null value.'
            );
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception: ' + thrownException.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitGetEndpointGetAdditionalSignersPositive() {
        Test.startTest();
        try {
            Assert.isNotNull(
                VCC_DAS.SERVICES.ENDPOINT.getEndpoint(VCC_DAS.Endpoint.GET_ADDITIONAL_SIGNERS),
                'Expected non-null value.'
            );
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception: ' + thrownException.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitGetEndpointCreateAddendumPositive() {
        Test.startTest();
        try {
            Assert.isNotNull(
                VCC_DAS.SERVICES.ENDPOINT.getEndpoint(VCC_DAS.Endpoint.CREATE_ADDENDUM),
                'Expected non-null value.'
            );
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception: ' + thrownException.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitGetEndpointSaveNoteAndEncounterPositive() {
        Test.startTest();
        try {
            Assert.isNotNull(
                VCC_DAS.SERVICES.ENDPOINT.getEndpoint(VCC_DAS.Endpoint.SAVE_NOTE_AND_ENCOUNTER),
                'Expected non-null value.'
            );
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception: ' + thrownException.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void unitGetEndpointWriteAndSignPositive() {
        Test.startTest();
        try {
            Assert.isNotNull(
                VCC_DAS.SERVICES.ENDPOINT.getEndpoint(VCC_DAS.Endpoint.WRITE_NOTE_AND_SIGN),
                'Expected WRITE_NOTE_AND_SIGN endpoint enum to not be null.'
            );
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception: ' + thrownException.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void unitGetEndpointCreateAddendumAndSignPositive() {
        Test.startTest();
        try {
            Assert.isNotNull(
                VCC_DAS.SERVICES.ENDPOINT.getEndpoint(VCC_DAS.Endpoint.CREATE_ADDENDUM_AND_SIGN),
                'Expected CREATE_ADDENDUM_AND_SIGN endpoint enum to not be null.'
            );
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception: ' + thrownException.getMessage());
        }
        Test.stopTest();
    }
}
