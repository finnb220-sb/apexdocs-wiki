/**
 * @description test class for PC_ExceptionUtils
 * @author      Booz Allen Hamilton
 * @see         PC_ExceptionUtils
 */
@IsTest
private with sharing class PC_ExceptionUtilsTest {
    private final static User FLP_USER;
    static {
        //mixed DML error workaround
        System.runAs(new User(Id = UserInfo.getUserId())) {
            FLP_USER = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet('PrC_FLP_Users')
                .build(true);
        }
    }

    /**
     * @description positive test of logAndThrowError with no caughtException parameter or saveLog parameter
     */
    @IsTest
    static void unitLogAndThrowErrorNoExceptionPositive() {
        String expectedErrorMessage = 'Expected Error';

        Test.startTest();

        System.runAs(FLP_USER) {
            try {
                PC_ExceptionUtils.logAndThrowError(expectedErrorMessage);
                Assert.fail(
                    'Expected the test to throw an Exception, but it did not. expectedErrorMessage: ' +
                    expectedErrorMessage
                );
            } catch (PC_CustomException caughtException) {
                Assert.areEqual(
                    expectedErrorMessage,
                    caughtException.getMessage(),
                    'Expected the thrown error message to be the same as the expectedErrorMessage, but it was not'
                );
            }
        }

        Test.stopTest();
    }

    /**
     * @description positive test of logAndThrowError with a saveLog parameter, but no caughtException parameter
     */
    @IsTest
    static void unitLogAndThrowErrorSaveLogPositive() {
        String expectedErrorMessage = 'Expected Error';

        Test.startTest();

        System.runAs(FLP_USER) {
            try {
                PC_ExceptionUtils.logAndThrowError(expectedErrorMessage, true);
                Assert.fail(
                    'Expected the test to throw an Exception, but it did not. expectedErrorMessage: ' +
                    expectedErrorMessage
                );
            } catch (PC_CustomException caughtException) {
                Assert.areEqual(
                    expectedErrorMessage,
                    caughtException.getMessage(),
                    'Expected the thrown error message to be the same as the expectedErrorMessage, but it was not'
                );
            }
        }

        Test.stopTest();
    }

    /**
     * @description positive test of logAndThrowError with a caughtException parameter, but no saveLog parameter
     */
    @IsTest
    static void unitLogAndThrowErrorWithExceptionPositive() {
        String expectedErrorMessage = 'Expected Error';
        PC_CustomException customException = new PC_CustomException();

        Test.startTest();

        System.runAs(FLP_USER) {
            try {
                PC_ExceptionUtils.logAndThrowError(expectedErrorMessage, customException);
                Assert.fail(
                    'Expected the test to throw an Exception, but it did not. expectedErrorMessage: ' +
                    expectedErrorMessage
                );
            } catch (PC_CustomException caughtException) {
                Assert.areEqual(
                    expectedErrorMessage,
                    caughtException.getMessage(),
                    'Expected the thrown error message to be the same as the expectedErrorMessage, but it was not'
                );
            }
        }

        Test.stopTest();
    }

    /**
     * @description positive test of logAndThrowError with a caughtException parameter, but no saveLog parameter that throws an illegal argument exception instead of a custom exception
     */
    @IsTest
    static void unitLogAndThrowIllegalArgumentExceptionPositive() {
        String expectedErrorMessage = 'Expected Error';

        Test.startTest();

        System.runAs(FLP_USER) {
            try {
                PC_ExceptionUtils.logAndThrowIllegalArgumentError(expectedErrorMessage);
                Assert.fail(
                    'Expected the test to throw an Exception, but it did not. expectedErrorMessage: ' +
                    expectedErrorMessage
                );
            } catch (IllegalArgumentException caughtException) {
                Assert.areEqual(
                    expectedErrorMessage,
                    caughtException.getMessage(),
                    'Expected the thrown error message to be the same as the expectedErrorMessage, but it was not'
                );
            }
        }

        Test.stopTest();
    }

    /**
     * @description positive test of logAndCreateAuraHandledException with a String error message Parameter, a caughtException parameter, but no saveLog parameter that throws an illegal argument exception instead of a custom exception
     */
    @IsTest
    static void unitLogAndCreateAuraHandledExceptionPositive() {
        String expectedErrorMessage = 'Expected Error';
        PC_CustomException customException = new PC_CustomException();

        Test.startTest();
        System.runAs(FLP_USER) {
            try {
                PC_ExceptionUtils.logAndCreateAuraHandledException(expectedErrorMessage, customException);
                Assert.areEqual(
                    'Expected Error',
                    expectedErrorMessage,
                    'Expected the test to return the expectedErrorMessage.'
                );
            } catch (AuraHandledException caughtException) {
                Assert.areEqual(
                    expectedErrorMessage,
                    caughtException.getMessage(),
                    'Expected the thrown error message to be the same as the expectedErrorMessage, but it was not'
                );
            }
        }

        Test.stopTest();
    }
}
