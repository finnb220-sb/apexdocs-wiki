/**
 * @description test class for VCC_DASConsolidatedEndpointException
 * @author Booz Allen Hamilton
 * @since 04/18/2024 - added in CCCM-31253
 * @see VCC_DASConsolidatedEndpointException
 */
@IsTest
private class VCC_DASConsolidatedEndpointExceptionTest {
    @IsTest
    static void unitCreateAddendumAndSignConstructor() {
        VCC_DASCreateAddendumAndSignFailureRS createAddendumAndSignFailureRs = new VCC_DASCreateAddendumAndSignFailureRS();
        createAddendumAndSignFailureRs.code = 'some code';
        createAddendumAndSignFailureRs.description = 'some description';
        createAddendumAndSignFailureRs.message = 'some message';
        createAddendumAndSignFailureRs.addendumIen = 'some addendum ien';
        Test.startTest();
        try {
            VCC_DASConsolidatedEndpointException consolidatedEndpointException = new VCC_DASConsolidatedEndpointException(
                createAddendumAndSignFailureRs
            );
            Assert.areEqual(
                VCC_DASConsolidatedEndpointException.DAS_Type.ADDENDUM,
                consolidatedEndpointException.type,
                'Expected \'type\' property to be ADDENDUM'
            );
            Assert.areEqual(
                createAddendumAndSignFailureRs.code,
                consolidatedEndpointException.errorCode,
                'Expected "code" property from VCC_DASCreateAddendumAndSignFailureRS to be copied into the "errorCode" property on VCC_DASConsolidatedEndpointException'
            );
            Assert.areEqual(
                createAddendumAndSignFailureRs.message,
                consolidatedEndpointException.errorMessage,
                'Expected "message" property from VCC_DASCreateAddendumAndSignFailureRS to be copied into the "errorMessage" property on VCC_DASConsolidatedEndpointException'
            );
            Assert.areEqual(
                createAddendumAndSignFailureRs.addendumIen,
                consolidatedEndpointException.noteOrAddendumIen,
                'Expected "addendum" property from VCC_DASCreateAddendumAndSignFailureRS to be copied into the "noteOrAddendumIen" property on VCC_DASConsolidatedEndpointException'
            );
            Assert.areEqual(
                createAddendumAndSignFailureRs.description,
                consolidatedEndpointException.errorDescription,
                'Expected "description" property from VCC_DASCreateAddendumAndSignFailureRS to be copied into the "errorDescription" property on VCC_DASConsolidatedEndpointException'
            );
            Assert.isTrue(
                consolidatedEndpointException.getMessage().contains(createAddendumAndSignFailureRs.description),
                'Expected exception message to contain the "description" property on VCC_DASCreateAddendumAndSignFailureRS'
            );
        } catch (Exception thrownException) {
            Assert.fail(
                'Expected no exception, but instead found: ' +
                    thrownException.getTypeName() +
                    '\n' +
                    thrownException.getStackTraceString()
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void unitWriteNoteAndSignConstructor() {
        VCC_DASWriteNoteSignFailureRS writeNoteAndSignFailureRs = new VCC_DASWriteNoteSignFailureRS();
        writeNoteAndSignFailureRs.code = 'some code';
        writeNoteAndSignFailureRs.description = 'some description';
        writeNoteAndSignFailureRs.message = 'some message';
        writeNoteAndSignFailureRs.noteIen = 'some note ien';
        Test.startTest();
        try {
            VCC_DASConsolidatedEndpointException consolidatedEndpointException = new VCC_DASConsolidatedEndpointException(
                writeNoteAndSignFailureRs
            );
            Assert.areEqual(
                VCC_DASConsolidatedEndpointException.DAS_Type.NOTE,
                consolidatedEndpointException.type,
                'Expected \'type\' property to be NOTE'
            );
            Assert.areEqual(
                writeNoteAndSignFailureRs.code,
                consolidatedEndpointException.errorCode,
                'Expected "code" property from VCC_DASWriteNoteSignFailureRS to be copied into the "errorCode" property on VCC_DASConsolidatedEndpointException'
            );
            Assert.areEqual(
                writeNoteAndSignFailureRs.message,
                consolidatedEndpointException.errorMessage,
                'Expected "message" property from VCC_DASWriteNoteSignFailureRS to be copied into the "errorMessage" property on VCC_DASConsolidatedEndpointException'
            );
            Assert.areEqual(
                writeNoteAndSignFailureRs.noteIen,
                consolidatedEndpointException.noteOrAddendumIen,
                'Expected "addendum" property from VCC_DASWriteNoteSignFailureRS to be copied into the "noteOrAddendumIen" property on VCC_DASConsolidatedEndpointException'
            );
            Assert.areEqual(
                writeNoteAndSignFailureRs.description,
                consolidatedEndpointException.errorDescription,
                'Expected "description" property from VCC_DASWriteNoteSignFailureRS to be copied into the "errorDescription" property on VCC_DASConsolidatedEndpointException'
            );
            Assert.isTrue(
                consolidatedEndpointException.getMessage().contains(writeNoteAndSignFailureRs.description),
                'Expected exception message to contain the "description" property on VCC_DASWriteNoteSignFailureRS'
            );
        } catch (Exception thrownException) {
            Assert.fail(
                'Expected no exception, but instead found: ' +
                    thrownException.getTypeName() +
                    '\n' +
                    thrownException.getStackTraceString()
            );
        }
        Test.stopTest();
    }
}
