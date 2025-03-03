/**
 * @description This is the 'ABS_BatchExecutioner' abstract class which is used to define the structure of classes that can perform execution operations on SObjects.
 * @author BAH
 * @see VCC_GenericBatch
 */
public abstract class ABS_BatchExecutioner {
    public ABS_BatchFinalizer batchFinalizer;
    public String executionerName;
    /**
     * @description This method is used to execute necessary operations on a list of SObjects.
     * @param sObjects A list of SObjects on which the execution operation will be performed.
     */
    public abstract void execute(List<SObject> sObjects);

    /**
     * @description This method retrieves a QueryLocator that is used to locate and handle records in Salesforce.
     * @return String that represents the query locator.
     */
    public abstract String getQueryLocatorString();

    /**
     * @description This method retrieves the bind variables that are used in the query.
     * @return Map<String,Object> A map of bind variables to be used in the query.
     */
    public abstract Map<String, Object> getBindVariables();

    /**
     * @description This method retrieves the query locator that is used to locate and handle records in Salesforce.
     * @param query The query to be used in the query locator.
     * @return Database.QueryLocator A query locator for the batch job.
     */
    public abstract Database.QueryLocator getQueryLocator(String query);

    /**
     * @description This method is an implementation of the ABS_BatchFinalizer interface
     * @param batchFinalizer instantiation of the ABS_BatchFinalizer
     */
    public virtual void setBatchFinalizer(ABS_BatchFinalizer batchFinalizer) {
        this.batchFinalizer = batchFinalizer;
    }
}
