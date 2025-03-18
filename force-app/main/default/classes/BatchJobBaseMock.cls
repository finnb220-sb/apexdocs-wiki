/**
 * Name: BatchJobBaseMock
 * @author brendafinn
 * @date 11/16/21
 * 
 * @description Mock sub-class of BatchJobBase for unit tests
 *
 * @group Batch Framework
 * @see BatchJobBase
 * @see BatchJobBaseTest
 */
@IsTest
global class BatchJobBaseMock extends BatchJobBase
        implements Database.Batchable<SObject>, Database.Stateful, Schedulable {

    public static Boolean blnExecuteInvoked = false;

    // Return a descriptive name for this batch class
    override global String getJobName() {
        return 'Test Batch Class';
    }

    // Return the query to execute when batch job is started
    override global String getQueryString() {
        if (blnReturnInvalidQuery) {
            return 'SELECT InvalidFieldName FROM Account';
        } else {
            return 'SELECT Id FROM Account';
        }
    }

    // Process chunk of records - called from execute(BatchableContext, List<SObject> scope)
    override global void execute() {
        if (blnThrowException) {
            throw new BatchTestException('Test Exception');
        }
        blnExecuteInvoked = true;
    }

    override global String getClassName() {
        return 'BatchJobBaseMock';
    }

    @TestVisible private Boolean blnThrowException = false;
    @TestVisible private Boolean blnReturnInvalidQuery = false;
    public class BatchTestException extends Exception {}
}
