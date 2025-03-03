/**
 * @description Test class for the VCC_DASFlowConsolidatedEndpointResult class
 * @see VCC_DASFlowConsolidatedEndpointResult
 * @author Booz Allen Hamilton
 * @since 05/09/2024 - CCCM-31251
 */

@IsTest
private with sharing class VCC_DASFlowConsolidatedEndpointResulTest {
    private static User getTestUser() {
        return (new VATEST_UserBuilder())
            .withStandardData()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSets(
                new Set<String>{
                    'HealthCloudFoundation',
                    'VAHC_Read_Progress_Notes',
                    'VAHC_RN_Standard_VCC_User',
                    'VAHC_RN_User',
                    'VAHC_Write_Clinical_Triage_Progress_Note',
                    'VAHC_Standard_VCC_User',
                    'VCC_DAS'
                }
            )
            .build(true);
    }

    private static void assertIsNonErrorState(VCC_DASFlowConsolidatedEndpointResult dasFlowConsolidatedEndpointResult) {
        Assert.isFalse(dasFlowConsolidatedEndpointResult.isError, 'Expected "isError" property to be false.');
        Assert.isNull(
            dasFlowConsolidatedEndpointResult.errorCode,
            'Expected value in "errorCode" property to transfer to flow result class'
        );
        Assert.isNull(
            dasFlowConsolidatedEndpointResult.errorMessage,
            'Expected value in "errorMessage" property to transfer to flow result class'
        );
        Assert.isNull(
            dasFlowConsolidatedEndpointResult.errorDescription,
            'Expected value in "errorDescription" property to transfer to flow result class'
        );
    }

    private static void assertIsErrorStateNullException(
        VCC_DASFlowConsolidatedEndpointResult dasFlowConsolidatedEndpointResult
    ) {
        Assert.isTrue(dasFlowConsolidatedEndpointResult.isError, 'Expected "isError" property to be true.');
        Assert.isNull(
            dasFlowConsolidatedEndpointResult.errorDescription,
            'Expected value in "errorDescription" to be null'
        );
        Assert.isNull(
            dasFlowConsolidatedEndpointResult.errorCode,
            'Expected value in "errorCode" property to transfer to flow result class'
        );
        Assert.isNull(
            dasFlowConsolidatedEndpointResult.errorMessage,
            'Expected value in "errorMessage" property to transfer to flow result class'
        );
        Assert.isNull(
            dasFlowConsolidatedEndpointResult.noteOrAddendumIen,
            'Expected value in "noteOrAddendumIen" property to transfer to flow result class'
        );
        Assert.isNull(
            dasFlowConsolidatedEndpointResult.text,
            'Expected value in "text" property to transfer to flow result class'
        );
    }

    @IsTest
    static void unitConstructorNoArgPositive() {
        System.runAs(getTestUser()) {
            Test.startTest();
            Assert.isNotNull(
                new VCC_DasFlowConsolidatedEndpointResult(),
                'Expected to find an instance of VCC_DasFlowConsolidatedEndpointResult constructed with no-args.'
            );
            Test.stopTest();
        }
    }

    @IsTest
    static void unitOtherExceptionConstructorPositive() {
        System.runAs(getTestUser()) {
            Test.startTest();
            IllegalArgumentException someOtherException = new IllegalArgumentException('test');
            VCC_DASFlowConsolidatedEndpointResult dasFlowConsolidatedEndpointResult = new VCC_DASFlowConsolidatedEndpointResult(
                someOtherException
            );
            Assert.isTrue(dasFlowConsolidatedEndpointResult.isError, 'Expected "isError" property to be true.');
            Assert.isTrue(
                dasFlowConsolidatedEndpointResult.errorDescription.contains(someOtherException.getMessage()),
                'Expected value in "errorDescription" to contain return value from Exception.getMessage()'
            );
            Assert.isNull(
                dasFlowConsolidatedEndpointResult.errorCode,
                'Expected value in "errorCode" property to transfer to flow result class'
            );
            Assert.isNull(
                dasFlowConsolidatedEndpointResult.errorMessage,
                'Expected value in "errorMessage" property to transfer to flow result class'
            );
            Assert.isNull(
                dasFlowConsolidatedEndpointResult.noteOrAddendumIen,
                'Expected value in "noteOrAddendumIen" property to transfer to flow result class'
            );
            Assert.isNull(
                dasFlowConsolidatedEndpointResult.text,
                'Expected value in "text" property to transfer to flow result class'
            );
            Test.stopTest();
        }
    }

    @IsTest
    static void unitOtherExceptionNullConstructorPositive() {
        System.runAs(getTestUser()) {
            Test.startTest();
            IllegalArgumentException someOtherException;
            VCC_DASFlowConsolidatedEndpointResult dasFlowConsolidatedEndpointResult = new VCC_DASFlowConsolidatedEndpointResult(
                someOtherException
            );
            assertIsErrorStateNullException(dasFlowConsolidatedEndpointResult);
            Assert.isTrue(
                true,
                'Tautological assert to get around copado codescan PMD.ApexUnitTestClassShouldHaveAsserts.'
            );
            Test.stopTest();
        }
    }

    @IsTest
    static void unitConsolidatedExceptionConstructorPositive() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_DASCreateAddendumAndSignFailureRS createAddendumAndSignFailureRs = new VCC_DASCreateAddendumAndSignFailureRS();
            createAddendumAndSignFailureRs.description = 'test';
            VCC_DASConsolidatedEndpointException consolidatedEndpointException = new VCC_DASConsolidatedEndpointException(
                createAddendumAndSignFailureRs
            );
            consolidatedEndpointException.errorCode = 'test error code';
            consolidatedEndpointException.errorMessage = 'test error message';
            consolidatedEndpointException.noteOrAddendumIen = 'test ien';
            VCC_DASFlowConsolidatedEndpointResult dasFlowConsolidatedEndpointResult = new VCC_DASFlowConsolidatedEndpointResult(
                consolidatedEndpointException
            );
            Assert.isTrue(dasFlowConsolidatedEndpointResult.isError, 'Expected "isError" property to be true.');
            Assert.areEqual(
                consolidatedEndpointException.errorCode,
                dasFlowConsolidatedEndpointResult.errorCode,
                'Expected value in "errorCode" property to transfer to flow result class'
            );
            Assert.areEqual(
                consolidatedEndpointException.errorMessage,
                dasFlowConsolidatedEndpointResult.errorMessage,
                'Expected value in "errorMessage" property to transfer to flow result class'
            );
            Assert.isTrue(
                dasFlowConsolidatedEndpointResult.errorDescription.contains(createAddendumAndSignFailureRs.description),
                'Expected value in "errorDescription" to contain description from response'
            );
            Assert.areEqual(
                consolidatedEndpointException.noteOrAddendumIen,
                dasFlowConsolidatedEndpointResult.noteOrAddendumIen,
                'Expected value in "noteOrAddendumIen" property to transfer to flow result class'
            );
            Assert.isNull(
                dasFlowConsolidatedEndpointResult.text,
                'Expected value in "text" property to transfer to flow result class'
            );
            Test.stopTest();
        }
    }

    @IsTest
    static void unitConsolidatedExceptionConstructorEmptyNegative() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_DASConsolidatedEndpointException consolidatedEndpointException = new VCC_DASConsolidatedEndpointException();
            VCC_DASFlowConsolidatedEndpointResult dasFlowConsolidatedEndpointResult = new VCC_DASFlowConsolidatedEndpointResult(
                consolidatedEndpointException
            );
            Assert.isTrue(dasFlowConsolidatedEndpointResult.isError, 'Expected "isError" property to be true.');
            Assert.isNull(
                dasFlowConsolidatedEndpointResult.errorCode,
                'Expected value in "errorCode" property to transfer to flow result class'
            );
            Assert.isNull(
                dasFlowConsolidatedEndpointResult.errorMessage,
                'Expected value in "errorMessage" property to transfer to flow result class'
            );
            Assert.areEqual(
                consolidatedEndpointException.getMessage(),
                dasFlowConsolidatedEndpointResult.errorDescription,
                'Expected value in "errorDescription" property to transfer to flow result class'
            );
            Assert.isNull(
                dasFlowConsolidatedEndpointResult.noteOrAddendumIen,
                'Expected value in "noteOrAddendumIen" property to transfer to flow result class'
            );
            Assert.isNull(
                dasFlowConsolidatedEndpointResult.text,
                'Expected value in "text" property to transfer to flow result class'
            );
            Test.stopTest();
        }
    }

    @IsTest
    static void unitConsolidatedExceptionConstructorNullNegative() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_DASConsolidatedEndpointException consolidatedEndpointException;
            VCC_DASFlowConsolidatedEndpointResult dasFlowConsolidatedEndpointResult = new VCC_DASFlowConsolidatedEndpointResult(
                consolidatedEndpointException
            );
            assertIsErrorStateNullException(dasFlowConsolidatedEndpointResult);
            Assert.isTrue(
                true,
                'Tautological assert to get around copado codescan PMD.ApexUnitTestClassShouldHaveAsserts.'
            );
            Test.stopTest();
        }
    }

    @IsTest
    static void unitWriteNoteAndSignConstructorPositive() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_DASWriteNoteSignSuccessRS writeNoteAndSignSuccessRs = new VCC_DASWriteNoteSignSuccessRS();
            writeNoteAndSignSuccessRs.textTO.text = 'OK';
            writeNoteAndSignSuccessRs.textTO.noteIen = 'Ok noteIen';
            VCC_DASFlowConsolidatedEndpointResult dasFlowConsolidatedEndpointResult = new VCC_DASFlowConsolidatedEndpointResult(
                writeNoteAndSignSuccessRs
            );
            assertIsNonErrorState(dasFlowConsolidatedEndpointResult);
            Assert.areEqual(
                writeNoteAndSignSuccessRs.textTO.text,
                dasFlowConsolidatedEndpointResult.text,
                'Expected value in "text" property to transfer to flow result class'
            );
            Assert.areEqual(
                writeNoteAndSignSuccessRs.textTO.noteIen,
                dasFlowConsolidatedEndpointResult.noteOrAddendumIen,
                'Expected value in "noteOrAddendumIen" property to transfer to flow result class'
            );
            Test.stopTest();
        }
    }

    @IsTest
    static void unitWriteNoteAndSignConstructorEmptyNegative() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_DASWriteNoteSignSuccessRS writeNoteAndSignSuccessRs = new VCC_DASWriteNoteSignSuccessRS();
            VCC_DASFlowConsolidatedEndpointResult dasFlowConsolidatedEndpointResult = new VCC_DASFlowConsolidatedEndpointResult(
                writeNoteAndSignSuccessRs
            );
            assertIsNonErrorState(dasFlowConsolidatedEndpointResult);
            Assert.isNull(
                dasFlowConsolidatedEndpointResult.noteOrAddendumIen,
                'Expected value in "noteOrAddendumIen" property to transfer to flow result class'
            );
            Assert.isNull(
                dasFlowConsolidatedEndpointResult.text,
                'Expected value in "text" property to transfer to flow result class'
            );
            Test.stopTest();
        }
    }

    @IsTest
    static void unitWriteNoteAndSignConstructorNullNegative() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_DASWriteNoteSignSuccessRS writeNoteAndSignSuccessRs;
            VCC_DASFlowConsolidatedEndpointResult dasFlowConsolidatedEndpointResult = new VCC_DASFlowConsolidatedEndpointResult(
                writeNoteAndSignSuccessRs
            );
            assertIsNonErrorState(dasFlowConsolidatedEndpointResult);
            Assert.isNull(
                dasFlowConsolidatedEndpointResult.noteOrAddendumIen,
                'Expected value in "noteOrAddendumIen" property to transfer to flow result class'
            );
            Assert.isNull(
                dasFlowConsolidatedEndpointResult.text,
                'Expected value in "text" property to transfer to flow result class'
            );
            Test.stopTest();
        }
    }

    @IsTest
    static void unitCreateAddendumAndSignConstructorPositive() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_DASCreateAddendumAndSignSuccessRS createAddendumAndSignSuccessRs = new VCC_DASCreateAddendumAndSignSuccessRS();
            createAddendumAndSignSuccessRs.textTO.text = 'OK';
            createAddendumAndSignSuccessRs.textTO.addendumIen = 'OK addendumIen';
            VCC_DASFlowConsolidatedEndpointResult dasFlowConsolidatedEndpointResult = new VCC_DASFlowConsolidatedEndpointResult(
                createAddendumAndSignSuccessRs
            );
            assertIsNonErrorState(dasFlowConsolidatedEndpointResult);
            Assert.areEqual(
                createAddendumAndSignSuccessRs.textTO.text,
                dasFlowConsolidatedEndpointResult.text,
                'Expected value in "text" property to transfer to flow result class'
            );
            Assert.areEqual(
                createAddendumAndSignSuccessRs.textTO.addendumIen,
                dasFlowConsolidatedEndpointResult.noteOrAddendumIen,
                'Expected value in "noteOrAddendumIen" property to transfer to flow result class'
            );
            Test.stopTest();
        }
    }

    @IsTest
    static void unitCreateAddendumAndSignConstructorEmptyNegative() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_DASCreateAddendumAndSignSuccessRS createAddendumAndSignSuccessRs = new VCC_DASCreateAddendumAndSignSuccessRS();
            VCC_DASFlowConsolidatedEndpointResult dasFlowConsolidatedEndpointResult = new VCC_DASFlowConsolidatedEndpointResult(
                createAddendumAndSignSuccessRs
            );
            assertIsNonErrorState(dasFlowConsolidatedEndpointResult);
            Assert.isNull(
                dasFlowConsolidatedEndpointResult.noteOrAddendumIen,
                'Expected value in "noteOrAddendumIen" property to transfer to flow result class'
            );
            Assert.isNull(
                dasFlowConsolidatedEndpointResult.text,
                'Expected value in "text" property to transfer to flow result class'
            );
            Test.stopTest();
        }
    }

    @IsTest
    static void unitCreateAddendumAndSignConstructorNullNegative() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_DASCreateAddendumAndSignSuccessRS createAddendumAndSignSuccessRs;
            VCC_DASFlowConsolidatedEndpointResult dasFlowConsolidatedEndpointResult = new VCC_DASFlowConsolidatedEndpointResult(
                createAddendumAndSignSuccessRs
            );
            assertIsNonErrorState(dasFlowConsolidatedEndpointResult);
            Assert.isNull(
                dasFlowConsolidatedEndpointResult.noteOrAddendumIen,
                'Expected value in "noteOrAddendumIen" property to transfer to flow result class'
            );
            Assert.isNull(
                dasFlowConsolidatedEndpointResult.text,
                'Expected value in "text" property to transfer to flow result class'
            );
            Test.stopTest();
        }
    }
}
