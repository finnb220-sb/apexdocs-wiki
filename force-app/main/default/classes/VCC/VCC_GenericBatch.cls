/**
 * @description This class is a generic batch class that can be used to perform batch processing on any SObject.
 * It is designed to be used in conjunction with a class that implements the 'IExecutioner' interface.
 * The 'IExecutioner' interface is used to define the structure of classes that can perform execution operations on SObjects.
 * @author Booz Allen
 * @see ABS_BatchExecutioner
 * @see VCC_CaseMetricsLogic
 * @see VCR_CaseMetricsRepo
 * @see VCC_ServiceAppointmentMetrics
 *
 * @justification Because this is designed to be generic, it's possible that in the future, the class extending ABS_BatchExecutioner may require without sharing.
 * however since this generic batch will be the entry point, it's sharing rule here will override the ABS_BatchExecutioner extending concrete classes' sharing directive when more restrictive.
 */
public without sharing class VCC_GenericBatch implements Database.Batchable<SObject> {
    @TestVisible
    private String query;
    @TestVisible
    private Map<String, Object> bindVariables;
    @TestVisible
    private ABS_BatchExecutioner batchExecutioner;
    @TestVisible
    private String actionName;
    @TestVisible
    private Boolean isBatchDone = false;

    /**
     * @description Constructs an instance of VCC_GenericBatch.
     * This constructor substitutes the indexes in the provided query with the corresponding argument values.
     * @param executioner Represents an executioner instance that is tied to the batch job.
     */
    public VCC_GenericBatch(ABS_BatchExecutioner executioner) {
        if (executioner == null) {
            throw new HandledException('Executioner cannot be null');
        }
        this.batchExecutioner = executioner;
        this.query = executioner?.getQueryLocatorString();
        this.bindVariables = executioner?.getBindVariables();
        this.actionName = executioner?.executionerName;
        if (this.query == null) {
            throw new HandledException('Query cannot be null');
        }
    }

    /**
     * @description This method serves as the entry point of batch processing. It prepares a query locator with the specified query for batch processing.
     * @param batchableContext The context in which this batch job is running, provided by the system
     * @return Database.QueryLocator A query locator for the batch job
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return this.batchExecutioner.getQueryLocator(this.query);
    }

    /**
     * @description Executes a chunk of records within the batch.
     * @param batchableContext The context of the batch execution.
     * @param scope The list of SObjects to be processed in the batch.
     */
    public void execute(Database.BatchableContext batchableContext, List<SObject> scope) {
        this.batchExecutioner.execute(scope);
    }

    /**
     * @description Handles the actions to be taken upon completion of the batch job.
     * Primarily responsible for executing cleanup operations if any, logging the job completion,
     * and reporting the batch status through email.
     * @param batchableContext The context in which the batch job is executed. This provides methods for fetching interface methods that can be used.
     */
    public void finish(Database.BatchableContext batchableContext) {
        if (batchableContext == null) {
            throw new HandledException('BatchableContext cannot be null');
        }
        if (this.batchExecutioner.batchFinalizer != null) {
            this.batchExecutioner.batchFinalizer.finalize();
        }
        Logger.info('Batch job ' + actionName + ' completed successfully' + batchableContext?.getJobId());
        Logger.saveLog();
        this.isBatchDone = true;
    }
}
