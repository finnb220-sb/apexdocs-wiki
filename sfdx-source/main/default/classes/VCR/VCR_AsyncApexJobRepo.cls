/**
 * @description         : Class used to interact with the AsyncApexJob object in Salesforce
 * @author              : Booz Allen
 **/
public inherited sharing class VCR_AsyncApexJobRepo extends VTC_BaseRepo {
    /**
     * @description Constructor that initializes the VCR_AsyncApexJobRepo object by calling the constructor of the parent class
     *              and passing the AsyncApexJob.SObjectType as the sObject type.
     */
    public VCR_AsyncApexJobRepo() {
        super(AsyncApexJob.SObjectType);
    }

    /**
     * @description method returns the AsyncApexJob with the given Job ID.
     * It constructs a SOQL query using the provided Job ID and fetches the corresponding AsyncApexJob.
     * If a job with the given ID doesn't exist or can't be retrieved due to an exception, it logs the error message.
     * @param jobId A String that represents the ID of the job to be fetched.
     * @return The AsyncApexJob with a matching ID.
     * @throws Exception Exceptions encountered when executing the SOQL query are caught
     * and their messages are logged. In case of an exception, this method may return null.
     */
    public AsyncApexJob getAsyncApexJobById(String jobId) {
        List<AsyncApexJob> jobs;
        String selectClause = this.getQueryString();
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE Id = :jobId';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause;
        Map<String, Object> bindParams = new Map<String, Object>();
        bindParams.put('jobId', jobId);
        jobs = (List<AsyncApexJob>) this.fetch(query, bindParams);
        return jobs.isEmpty() ? null : jobs.get(0);
    }
    private String getQueryString() {
        return 'SELECT ApexClassId,\n' +
            '   CompletedDate,\n' +
            '    CreatedById,\n' +
            '    CreatedDate,\n' +
            '    CronTriggerId,\n' +
            '    ExtendedStatus,\n' +
            '    Id,\n' +
            '    JobItemsProcessed,\n' +
            '    JobType,\n' +
            '    LastProcessed,\n' +
            '    LastProcessedOffset,\n' +
            '    MethodName,\n' +
            '    NumberOfErrors,\n' +
            '    ParentJobId,\n' +
            '    Status,\n' +
            '    TotalJobItems,\n' +
            '    CreatedBy.Email';
    }
}
