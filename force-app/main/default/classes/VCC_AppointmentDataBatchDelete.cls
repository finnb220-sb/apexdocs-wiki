/**
 * @description Batch class to delete VCC_Appointment and VCC_AppointmentRequest records.
 * Actual appointment data is stored in VISTA and re-loaded in Salesforce when user views a patient.
 * We are deleting these 'temporary' records in Salesforce to keep the data and system clean.
 * @author Booz Allen Hamilton
 * @see VCR_AppointmentRepo
 * @see VCR_AppointmentRequestRepo
 * @see VCR_AsyncApexJobRepo
 * @see VCC_AppointmentDataBatchDeleteTest
 *
 * @justification EmptyStatementBlock - No argument constructor used for newInstance method with Callable Interface.
 * @justification ExcessiveParameterList - Added batch size from custom metadata to avoid hardcoding.
 */
@SuppressWarnings('PMD.EmptyStatementBlock, PMD.ExcessiveParameterList')
public class VCC_AppointmentDataBatchDelete implements Database.Batchable<SObject>, Database.Stateful, Callable {
    /**
     * @description List of object names for Batch class to process.
     * First object name will be removed and processed until list is empty.
     */
    private List<String> objectNames;

    /**
     * @description Selected object from objectNames list.
     * It is selected in the start method with .remove().
     */
    private String targetObject;

    /**
     * @description Used to calculate DateTime for LastModifiedDate < (DateTime minus numberOfHours).
     * Ex. Records where LastModified is more than 24 hours ago.
     */
    private Integer numberOfHours;

    /**
     * @description Used to calculate Date for LastModifiedDate < (Date minus numberOfDays).
     * Ex. Records where LastModified is more than 7 days ago.
     */
    private Integer numberOfDays;

    /**
     * @description Value from custom metadata to set batch size when calling executeBatch method.
     */
    private Integer batchSize;

    @TestVisible
    /**
     * @description Integer to count and log how many records were successfully deleted.
     * With Database.Stateful, the total is logged in the finish method.
     */
    private Integer recordCount = 0;

    /**
     * @description Empty constructor when used with callable for .newInstance().
     * This is implemented from the schedulable class.
     * @see VCC_AppointmentDataSchedulable
     */
    public VCC_AppointmentDataBatchDelete() {
    }

    /**
     * @description Constructor that takes a list of Strings and processes the first one on the list.
     * @param objectNames - List of API object names, constructor takes the first name from the list and assigns to targetObject.
     * Start method runs a batch class for the target object.
     * If there are more objects in the list, the finish method will start a new batch instance.
     * This constructor is called from the .call method and the finish method.
     * @param numberOfHours - Integer that will be used in batch class to calculate a DateTime.
     * @param numberOfDays - Integer that will be used in batch class to calculate a Date.
     * @param batchSize - Integer to set batchSize in executeBatch method.
     */
    public VCC_AppointmentDataBatchDelete(
        List<String> objectNames,
        Integer numberOfHours,
        Integer numberOfDays,
        Integer batchSize
    ) {
        this.objectNames = objectNames;
        // get the first one on the list
        this.targetObject = objectNames.remove(0);
        this.numberOfHours = numberOfHours;
        this.numberOfDays = numberOfDays;
        this.batchSize = batchSize;
    }

    /**
     * @description Required call method to implement Callable, from VCC_AppointmentDataSchedulable.
     * Using Callable, so that when the job is scheduled, there are no hard dependencies
     * to the classes referenced in this class such as the repos.
     * @param action - Standard string parameter for Callable.
     * @param params - Standard Map<String, Object> parameter for Callable.
     * Parameters that will be included and set from VCC_AppointmentDataSchedulable include:
     *      objectNames
     *      numberOfHours
     *      numberOfDays
     *      batchSize
     * @return `Object` Return format of Callable is Object.
     * This will be the job id of the batch job.
     */
    public Object call(String action, Map<String, Object> params) {
        if (action == 'executeNewBatchJob') {
            return executeNewBatchJob(
                (List<String>) params.get('objectNames'),
                (Integer) params.get('numberOfHours'),
                (Integer) params.get('numberOfDays'),
                (Integer) params.get('batchSize')
            );
        } else {
            throw new AppointmentDataBatchDeleteException('Unknown action in call method: ' + action);
        }
    }

    /**
     * @description Method to call Database.executeBatch.
     * Called from: schedulable -> call method or finish method of batch.
     * @param objectNames - List of API object names to process in the batch class.
     * @param numberOfHours - Integer that will be used in batch class to calculate a DateTime.
     * @param numberOfDays - Integer that will be used in batch class to calculate a Date.
     * @param batchSize - Integer to set batchSize in executeBatch method.
     * @return `String` Returns job Id of batch job or error message.
     */
    public String executeNewBatchJob(
        List<String> objectNames,
        Integer numberOfHours,
        Integer numberOfDays,
        Integer batchSize
    ) {
        try {
            VCC_AppointmentDataBatchDelete deleteApptDataJob = new VCC_AppointmentDataBatchDelete(
                objectNames,
                numberOfHours,
                numberOfDays,
                batchSize
            );
            Id batchJobId = Database.executeBatch(deleteApptDataJob, batchSize);
            return batchJobId;
        } catch (Exception error) {
            String errorMessage = 'Error starting batch: ' + error.getMessage();
            Logger.error(errorMessage);
            return errorMessage;
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description Repo factory to manage Appointment, AppointmentRequest, and AsyncApexJob repos
     * @see VCR_AppointmentRepo
     * @see VCR_AppointmentRequestRepo
     * @see VCR_AsyncApexJobRepo
     */
    private static VTC_RepoFactory memorizedRepoFactory {
        get {
            return VTC_RepoFactory.repoFactory;
        }
    }

    /**
     * @description Required start method for Batchable, uses repo in system mode to get list of records.
     * @param bc - Object to track the progress of the batch job.
     * @return `Database.queryLocator` Returns a list of either VCC_Appointment__c or VCC_AppointmentRequest__c records.
     * @see VCR_AppointmentRepo
     * @see VCR_AppointmentRequestRepo
     */
    public Database.queryLocator start(Database.BatchableContext bc) {
        DateTime now = Datetime.now();
        DateTime dateTimeHoursAgo = now.addHours(-numberOfHours);
        Date dateDaysAgo = now.date().addDays(-numberOfDays);
        Logger.info('DateTime hoursAgo: ' + dateTimeHoursAgo + ' | Date daysAgo: ' + dateDaysAgo);
        try {
            switch on targetObject {
                when 'VCC_Appointment__c' {
                    VCR_AppointmentRepo appointmentRepo = (VCR_AppointmentRepo) memorizedRepoFactory.createRepo(
                        VCC_Appointment__c.SObjectType,
                        'VCR_AppointmentRepo'
                    );
                    return appointmentRepo.getQueryLocator(
                        appointmentRepo.getStaleApptQueryString(dateTimeHoursAgo),
                        new Map<String, Object>{ 'dateTimeHoursAgo' => dateTimeHoursAgo }
                    );
                }
                when 'VCC_AppointmentRequest__c' {
                    VCR_AppointmentRequestRepo appointmentRequestRepo = (VCR_AppointmentRequestRepo) memorizedRepoFactory.createRepo(
                        VCC_AppointmentRequest__c.SObjectType,
                        'VCR_AppointmentRequestRepo'
                    );
                    return appointmentRequestRepo.getQueryLocator(
                        appointmentRequestRepo.getStaleApptReqQueryString(dateTimeHoursAgo, dateDaysAgo),
                        new Map<String, Object>{ 'dateTimeHoursAgo' => dateTimeHoursAgo, 'dateDaysAgo' => dateDaysAgo }
                    );
                }
                when else {
                    Logger.error('Unknown object for batch class: ' + targetObject);
                    throw new AppointmentDataBatchDeleteException('Unknown object for batch class: ' + targetObject);
                }
            }
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description Use the repo classes to perform the delete operation.
     * Base repo returns an array of DeleteResult for success/error.
     * Passes the results to a method to log any errors.
     * @param bc - Object to track the progress of the batch job.
     * @param recordsToDelete - List of sObjects returned from start method via the repos.
     * @see VCR_AppointmentRepo
     * @see VCR_AppointmentRequestRepo
     */
    public void execute(Database.BatchableContext bc, List<SObject> recordsToDelete) {
        Database.DeleteResult[] deleteResults;
        switch on targetObject {
            when 'VCC_Appointment__c' {
                VCR_AppointmentRepo appointmentRepo = (VCR_AppointmentRepo) memorizedRepoFactory.createRepo(
                    VCC_Appointment__c.SObjectType,
                    'VCR_AppointmentRepo'
                );
                deleteResults = appointmentRepo.doDelete(recordsToDelete);
            }
            when 'VCC_AppointmentRequest__c' {
                VCR_AppointmentRequestRepo appointmentRequestRepo = (VCR_AppointmentRequestRepo) memorizedRepoFactory.createRepo(
                    VCC_AppointmentRequest__c.SObjectType,
                    'VCR_AppointmentRequestRepo'
                );
                deleteResults = appointmentRequestRepo.doDelete(recordsToDelete);
            }
        }
        try {
            processResults(deleteResults);
        } finally {
            Logger.saveLog();
        }
    }

    @TestVisible
    /**
     * @description Method to evaluate results for success or errors.
     * It tallies the records that were successfully deleted to log the total at the end
     * and logs any errors.
     * A simulated DeleteResult is used for testing.
     * @param deleteResults - Results returned from base repo for delete operation.
     * For any DeleteResult where isSuccess is False, get the error(s) and log them.
     */
    private void processResults(List<Database.DeleteResult> deleteResults) {
        for (Database.DeleteResult result : deleteResults) {
            if (result.isSuccess()) {
                this.recordCount = this.recordCount + 1;
            } else {
                for (Database.Error err : result.getErrors()) {
                    String logMsg = 'Error deleting recordId: ' + result.getId() + '\n';
                    logMsg += err.getMessage();
                    Logger.error(logMsg);
                }
            }
        }
    }

    /**
     * @description Finish method for batch class.
     * Uses repo to get results of the AsyncApexJob and logs the result.
     * Checks the objectNames list from constructor.
     * If there are more objects on the list, it start a new instance of the batch class.
     * @param bc - Object to track the progress of the batch job.
     * @see VCR_AsyncApexJobRepo
     */
    public void finish(Database.BatchableContext bc) {
        VCR_AsyncApexJobRepo asyncApexJobRepo = (VCR_AsyncApexJobRepo) memorizedRepoFactory.createRepo(
            AsyncApexJob.SObjectType,
            'VCR_AsyncApexJobRepo'
        );
        AsyncApexJob job = asyncApexJobRepo.getAsyncApexJobById(bc.getJobId());

        String logMsg = 'VCC_DeleteAppointmentDataBatch Job Summary: \n' + '{0} {1} {2} {3} {4} {5}';
        // prettier-ignore
        List<Object> logDetails = new List<Object>{
            'AsyncApexJobID: ' + job.Id + '\n',
            'JobItemsProcessed: ' + job.JobItemsProcessed + '\n',
            'Object: ' + this.targetObject + '\n',
            '# of Records Deleted: ' + this.recordCount + '\n',
            '# of Errors: ' + job.NumberOfErrors + '\n',
            'Error Message: ' + job.ExtendedStatus
        };
        Logger.info(String.format(logMsg, logDetails));
        Logger.saveLog();

        // if there are more objects on the list, start another batch job
        if (!this.objectNames.isEmpty()) {
            executeNewBatchJob(this.objectNames, this.numberOfHours, this.numberOfDays, this.batchSize);
        }
    }

    /**
     * @description Custom Exception to be thrown in start method
     * when there is anything besides the expected object names.
     */
    @TestVisible
    public class AppointmentDataBatchDeleteException extends Exception {
    }
}
