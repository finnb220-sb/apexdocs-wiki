/**
 * @description Test class for the VCC_ExceptionUtils
 * @see VCC_ExceptionUtils
 */
@IsTest
private class VCC_ExceptionUtilsTest {
    @IsTest
    static void unitItSetsMessageFromAnExceptionPositive() {
        String expectedExceptionString = 'Oh no an exception!';
        AuraHandledException resultantException;
        Test.startTest();
        System.runAs(VATEST_UserFactory.createMinAccessPersonaUser(false)) {
            resultantException = VCC_ExceptionUtils.createAuraHandledException(
                new VCC_InvalidArgumentException(expectedExceptionString)
            );
        }
        Test.stopTest();

        Assert.areEqual(
            expectedExceptionString,
            resultantException.getMessage(),
            'Expected resultant Exception\'s message to be set by the exception passed in.'
        );
    }
    @IsTest
    static void unitItSetsMessageFromAStringPositive() {
        String expectedExceptionString = 'Oh no an exception!';
        AuraHandledException resultantException;
        Test.startTest();
        System.runAs(VATEST_UserFactory.createMinAccessPersonaUser(false)) {
            resultantException = VCC_ExceptionUtils.createAuraHandledException(expectedExceptionString);
        }
        Test.stopTest();

        Assert.areEqual(
            expectedExceptionString,
            resultantException.getMessage(),
            'Expected resultant Exception\'s message to be set by the String passed in.'
        );
    }
    @IsTest
    static void unitItSetsMessageFromAPrefixStringAnExceptionAndAPostfixStringPositive() {
        String prefix = 'Oh';
        String exceptionMessage = 'no an exception';
        String postfix = '!';
        String expectedExceptionString = prefix + exceptionMessage + postfix;
        AuraHandledException resultantException;
        Test.startTest();
        System.runAs(VATEST_UserFactory.createMinAccessPersonaUser(false)) {
            resultantException = VCC_ExceptionUtils.createAuraHandledException(
                prefix,
                new VCC_InvalidArgumentException(exceptionMessage),
                postfix
            );
        }
        Test.stopTest();

        Assert.areEqual(
            expectedExceptionString,
            resultantException.getMessage(),
            'Expected resultant Exception\'s message to be a concatenation of the three arguments passed in.'
        );
    }

    @isTest
    static void unitCreateAuraExceptionWithMessageFromMapPositive() {
        Map<String, String> cmdMap = new Map<String, String>{ 'VTC_AuthException' => 'testCommand' };
        AuraHandledException resultantException;
        Test.startTest();
        System.runAs(VATEST_UserFactory.createMinAccessPersonaUser(false)) {
            resultantException = VCC_ExceptionUtils.createAuraHandledException(
                new VTC_AuthException(),
                cmdMap,
                'default'
            );
        }
        Test.stopTest();

        Assert.areEqual(
            resultantException.getMessage(),
            'testCommand',
            'Expected resultant Exception\'s message to be set by the exception passed in from map.'
        );
    }
}
