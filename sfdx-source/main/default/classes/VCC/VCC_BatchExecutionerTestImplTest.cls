/**
 * @description Test class for the VCC_BatchExecutionerTestImpl class
 * @author BAH
 * @see VCC_BatchExecutionerTestImplementation
 */
@IsTest
private class VCC_BatchExecutionerTestImplTest {
    /**
     * @description test method for the execute method
     * Positive test case
     * @see ABS_BatchExecutioner.execute
     */
    @IsTest
    static void unitTestExecuteMethodPositive() {
        // given a list of sObjects
        List<Account> accList = VATEST_SObjectFactory.createSObjects(new Account(), 5);
        // when I execute the execute method
        VCC_BatchExecutionerTestImplementation unitUnderTest = new VCC_BatchExecutionerTestImplementation();
        Test.startTest();
        unitUnderTest.execute(accList);
        Test.stopTest();
        // then I expect
        Assert.isTrue(
            VCC_BatchExecutionerTestImplementation.assertionHelper,
            'Expected the assertionHelper to be set on this class after the execute method runs without issue.'
        );
    }
    /**
     * @description test method for the execute method
     * Negative test case
     * @see ABS_BatchExecutioner.execute
     */
    @IsTest
    static void unitTestExecutionMethodWithNoInputNegativeThrows() {
        // no givens / no data
        VCC_BatchExecutionerTestImplementation unitUnderTest = new VCC_BatchExecutionerTestImplementation();
        Boolean didCatchCorrectException = false;
        Test.startTest();
        try {
            unitUnderTest.execute(null);
        } catch (VCC_BatchExecutionerTestImplementation.RuntimeException caughtException) {
            if (caughtException.getMessage().containsIgnoreCase('sobjects is null')) {
                didCatchCorrectException = true;
            }
        }
        Test.stopTest();
        Assert.isTrue(
            didCatchCorrectException,
            'Expected to receive a RuntimeException when execute method is called with null or no params.'
        );
    }
    /**
     * @description test method for the getQueryLocatorString method
     * Positive test case
     * @see ABS_BatchExecutioner.getQueryLocatorString
     */
    @IsTest
    static void unitTestGetQueryLocatorStringPositive() {
        VCC_BatchExecutionerTestImplementation unitUnderTest = new VCC_BatchExecutionerTestImplementation();
        Test.startTest();
        String testResult = unitUnderTest.getQueryLocatorString();
        Test.stopTest();

        Assert.areEqual(
            testResult,
            VCC_BatchExecutionerTestImplementation.HARDCODED_QUERY_STRING,
            'Expected the hardcoded string to be returned by getQueryString()'
        );
    }
    /**
     * @description test method for the getBindVariables method
     * Positive test case
     * @see ABS_BatchExecutioner.getBindVariables
     */
    @IsTest
    static void unitTestGetBindVariablesPositive() {
        VCC_BatchExecutionerTestImplementation unitUnderTest = new VCC_BatchExecutionerTestImplementation();
        Test.startTest();
        Map<String, Object> testResults = unitUnderTest.getBindVariables();
        Test.stopTest();

        Assert.isTrue(testResults.keySet().isEmpty(), 'Expected to get a blank map back from the getBindVars method');
    }
    /**
     * @description test method for the getQueryLocator method
     * Positive test case
     * @see ABS_BatchExecutioner.getQueryLocator
     */
    @IsTest
    static void funcTestGetQueryLocatorPositive() {
        VCC_BatchExecutionerTestImplementation unitUnderTest = new VCC_BatchExecutionerTestImplementation();
        Test.startTest();
        Database.QueryLocator testResults = unitUnderTest.getQueryLocator(
            VCC_BatchExecutionerTestImplementation.HARDCODED_QUERY_STRING
        );
        Test.stopTest();

        Assert.areEqual(
            testResults.getQuery(),
            VCC_BatchExecutionerTestImplementation.HARDCODED_QUERY_STRING,
            'expected the query locator object to return the query in was input'
        );
    }
}
