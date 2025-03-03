/**
 * @description test implementation of the ABS_BatchExecutioner class
 * @see ABS_BatchExecutioner
 * @author BAH
 */
@IsTest
@TestVisible
public with sharing class VCC_BatchExecutionerTestImplementation extends ABS_BatchExecutioner {
    private static final String EXECUTIONER_NAME = 'VCC_BatchExecutionerTestImplementation';
    @TestVisible
    private static Boolean assertionHelper = false;

    @TestVisible
    private static final String HARDCODED_QUERY_STRING = 'SELECT Id FROM ACCOUNT LIMIT 10';

    @TestVisible
    private static final Map<String, Object> HARDCODED_BIND_VARS = new Map<String, Object>();

    /**
     * @description Constructor for the VCC_BatchExecutionerTestImplementation class
     */
    public VCC_BatchExecutionerTestImplementation() {
        super.executionerName = EXECUTIONER_NAME;
    }
    /**
     * @description Method to execute the batch
     * @param sobjects List<SObject>
     */
    public override void execute(List<SObject> sobjects) {
        if (sobjects == null || sobjects.isEmpty()) {
            throw new RuntimeException('sobjects is null');
        }

        assertionHelper = true;
    }
    /**
     * @description Method to get the Query Locator
     * @return String
     */
    public override String getQueryLocatorString() {
        return HARDCODED_QUERY_STRING;
    }
    /**
     * @description Method to get the bind variables
     * @return Map<String, Object>
     */
    public override Map<String, Object> getBindVariables() {
        return HARDCODED_BIND_VARS;
    }
    /**
     * @description Method to get the Query Locator
     * @param query String
     * @return Database.QueryLocator
     */
    public override Database.QueryLocator getQueryLocator(String query) {
        return Database.getQueryLocator(query);
    }
    /**
     * @description custom exception class for the test implementation
     */
    public class RuntimeException extends Exception {
    }
}
