/**
 * @author Brenda Finn 
 * @date on 2021-11-10
 *
 * @description Provides common variables, methods and handling for all Batch Jobs.
 *  Subclasses must add following to class declaration even though the implementation is provided in this class
 *  `implements Database.Batchable<sObject>, Schedulable`
 *  Subclasses must provide implementation for these abstract methods
 *  `global String getJobName()` - for logging purposes - return the name of Job (ie Account Batch)
 *  `global String getQueryString()` - return a string with the query to be executed (no dynamic variables)
 *  `global String getEmailGroupName()` - return the name of the Group that specifies users who should receive emails
 *  `global void execute(List<SObject> scope)` - Actually perform processing on scope
 *  `global void handleException(Exception exc)` - handle exception
 *
 * @group Batch Framework
 * @see BatchJobBaseMock
 * @see BatchJobBaseTest
 * @see BatchJobConstants
 * @see BatchJobSchedulingMgr
 */
global abstract with sharing class BatchJobBase implements Database.Stateful {
    /** @description Number of records successfully processed **/
    global Integer numSuccesses;
    /** @description Number of records that errored out **/
    global Integer numErrors {get {return errors.size();} private set;}
    /** @description List of error message string for troubleshooting & logging **/
    global List<String> errors;
    /** @description Batch Job configuration specifying batch size and other details **/
    global Batch_Job_Config__mdt config;

    /**
     * @description Construct our batch job, initializing our success, error counts and error messages
     */
    global BatchJobBase() {
        this.numErrors = 0;
        this.numSuccesses = 0;
        this.errors = new List<String>();
    }

    /**
     * @description Set our configuration to details in ourConfig record
     *
     * @param ourConfig instance of Batch Job Config metadata containing configuration details such as batch size, schedule, query filters.
     */
    global void setConfig(Batch_Job_Config__mdt ourConfig) {
        this.config = ourConfig;
    }

    /**
     * @description Run this job using given cronSchedule
     *
     * @param cronSchedule String representing schedule to run this batch job on
     */
    global void setup(String cronSchedule) {
        setup(this, cronSchedule);
    }

    /**
     * @description Setup the job specified (batch) to run on the schedule specified by the `cronSchedule`
     *
     * @param batch instance of job to run on cronSchedule
     * @param cronSchedule String representing schedule to run job on
     */
    global static void setup(BatchJobBase batch, String cronSchedule) {
        String jobName = batch.getJobName() + ' (' + cronSchedule + ')';
        System.debug('======> jobName = ' + jobName + ', cronSchedule = ' + cronSchedule);
        if (Test.isRunningTest()) {
            batch.execute(null);
        } else {
            System.schedule(jobName, cronSchedule, (System.Schedulable)batch);
        }
    }

    /**
     * @description Run the job at designated date and time
     *
     * @param jobName - Unique name of job
     * @param batch - Instance of a batch class to run now
     */
    global static void manual(String jobName, BatchJobBase batch) {
        Datetime dt = System.now().addMinutes(1);
        String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
        System.schedule(jobName, timeForScheduler, (System.Schedulable)batch);
    }

    /**
     * @description Execute scheduled job
     *
     * @param sc - context of job
     */
    global void execute(SchedulableContext sc) {
        Database.executeBatch((Database.Batchable<SObject>)this, this.config.Batch_Size__c == null ?
                100 : Integer.valueOf(this.config.Batch_Size__c));
    }

    /******************************** BATCHABLE INTERFACE ********************************/

    //Execution of batch apex operation
    /**
     * @description Get the list of records to process in this job. To build query, we call our
     * getQueryString() method which is defined within sub-classes.
     *
     * @param bc - context for current batch job
     *
     * @return QueryLocator - containing the records to be processed in chunks (default size is 200 records)
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('======> ' + getJobName() + ' query:' + getQueryString());
        try {
            System.debug('=====> Returning records ' + Database.query(getQueryString()));
        } catch (Exception exc) {
            System.debug('=====> exc = ' + exc.getMessage() + ', StackTrace = ' + exc.getStackTraceString());
        }
        return Database.getQueryLocator(getQueryString());
    }

    /**
     * @description Executes the next chunk of records
     *
     * @param bc - context for this batch job
     * @param scope -list of records to be processed
     */
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        try {
            records = scope;
            execute();
        }
        catch (Exception exc) {
            handleException(exc);
        }
    }

    /**
     * @description Once all the records have been processed for this batch execution, perform any final processing.
     * Right now, for this job, it involves preparing summary text of the job results, logging that message
     * and sending out a status email with the summary text to interested parties. The recipients are defined by a Group.
     *
     * @param bc - batch context
     */
    global void finish(Database.BatchableContext bc) {
        // Call logErrors method to prepare and log the summary message
        String messageBody = logErrors();

        if (doSendFinishEmail()) {
            sendStatusEmail(messageBody);
        }
        // TODO: Use Process Log Framework
        System.debug(LoggingLevel.ERROR, '======> ' + getJobName() + 'Job ran at : ' + System.now() + '\n' +
                'Successful Records Updated : '+ numSuccesses + '\n Number of Failed Records : ' + numErrors);

        finish(); // handle any batch-specific processing
    }

    /**
     * @description Create a summary message that is logged as a debug statement
     *
     * @return string - the message body
     */
    private String logErrors() {
        String messageBody = '\n\nThe nightly ' + getJobName() + ' has finished.';
        messageBody       += '\nThere were ' + numSuccesses + ' successful records processed and ' + errors.size() + ' errors during processing.';
        messageBody       += '\nPlease see below for any error details.\n\n';

        for (String error : errors) {
            messageBody+= error + '\n\n';
        }
        messageBody+= 'Thank you!';
        System.debug(LoggingLevel.ERROR , messageBody);

        return messageBody;
    }

    /**
     * @description Send the status email to members of a Group
     *
     * @param messageBody - the message body
     */
    protected void sendStatusEmail(String messageBody) {
        List<String> idList          = new List<String>();
        List<String> mailToAddresses = new List<String>();

        String groupName = getEmailGroupName();
        for (GroupMember gm : [SELECT (SELECT UserOrGroupId FROM GroupMembers) FROM Group WHERE DeveloperName = :groupName].GroupMembers) {
            idList.add(gm.UserOrGroupId);
        }
        System.debug('===> Ids of group members: ' + idList);

        for(User u :  [SELECT Email FROM User WHERE Id IN :idList AND IsActive = TRUE]) {
            mailToAddresses.add(u.Email);
        }
        System.debug('======> Email recipients: ' + mailToAddresses);

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(mailToAddresses);
        mail.setSubject(getJobName() + ' completed ' + Date.today().format());
        mail.setPlainTextBody(messageBody);
        System.debug('======> EMAIL ' + mail);

        MessagingServiceImpl.sendEmail( mail );
    }
    /****************************** END BATCHABLE INTERFACE ******************************/

    /**
     * @description For record that successfully processed, increase the batch success count
     *
     * @param record - SObject record that successfully processed in the batch
     */
    virtual global void markRecordAsSuccess(SObject record) {
        numSuccesses++;
    }

    /**
    * @description For record that failed to process, add the error to the errors list and update the numErrors in the batch job
     *
     * @param recordInError - SObject record that threw an error when processed in the batch
     * @param dbErrors - List of Database.Error
     */
    virtual global void markRecordAsError(SObject recordInError, List<Database.Error> dbErrors) {
        String errorMsg = 'There was an error processing record ' + JSON.serializePretty(recordInError);
        for (Database.Error error : dbErrors) {
            errorMsg += error + ' ';
        }
        markRecordAsError(recordInError, errorMsg);
    }

    /**
     * @description For record that failed to process, write the error to the errors list and update the numErrors in the batch job
     *
     * @param record - SObject record that threw an error when processed in the batch
     * @param errorMsg - string that details the error for the failed record
     */
    virtual global void markRecordAsError(SObject record, String errorMsg) {
        System.debug('======> ' + errorMsg);
        errors.add(errorMsg);
        // TODO: Use Process Log Framework
    }

    /**
     * @description Manually filter the records further by only processing records with Ids in recordIds.
     *  The default version assumes the recordIds are of the same SObject being processed. If this is not the
     *  case, sub-classes should override this method.
     *
     * @param recordIds set of Ids to limit processing set to
     *
     * @return list of records to process - for use in calling manuallyProcessRecords()
     */
    virtual global List<SObject> manuallyFilterRecords(Set<Id> recordIds) {
        String query = getQueryString();
        System.debug('====> query = ' + query);
        List<Id> recordIdLst = new List<Id>(recordIds);
        if (query.containsIgnoreCase(' WHERE ')) {
            query += ' AND ';
        } else {
            query += ' WHERE ';
        }
        String recordIdFilter = ' Id IN (\'' + String.join(recordIdLst, '\',\'') + '\')';
        query += recordIdFilter;
        System.debug('====> UPDATED query = ' + query);
        return Database.query(query);
    }

    /**
     * @description Provides a way to process a given set of records rather than executing batch query
     *  To get set of eligible records, use manuallyFilterRecords
     *
     * @param records list of records to process manually
     */
    virtual global void manuallyProcessRecords(List<SObject> records) {
        this.execute(null, records);
    }

    /**
     * @description Method to be implemented by sub-classes to get job name
     *
     * @return string - a descriptive name for this batch class
     */
    abstract global String getJobName();

    /**
     * @description Method to be implemented by sub-classes to get Apex Class Name
     *     for use in finding config record
     *
     * @return string - this batch class name
     */
    abstract  global String getClassName();

    /**
     * @description Method to be implemented by sub-classes to get query string
     *
     * @return string - the query to execute when batch job is started
     */
    abstract global String getQueryString();

    /**
     * @description Process chunk of records - called from execute(BatchableContext, List<SObject> scope)
     */
    abstract global void execute();

    /**
     * @description Handle exception thrown during processing. For now - this is in sub-classes but
     * there may be some core/base functionality we can pull out to this class
     *
     * @param exc - generic exception
     */
    virtual global void handleException(Exception exc) {
        String errorMsg = 'There was an exception thrown processing this set of records : ' + JSON.serializePretty(records) +
                '. Exception = ' + exc + ', StackTrace = ' + exc.getStackTraceString() +
                ', Cause = ' + exc.getCause();
        System.debug('======> ' + errorMsg);
        errors.add(errorMsg);
    }

    /**
     * @description If there is additional processing to be done after the email is sent, it can be done in this method.
     * This is called by the Batchable finish() method. Provide a no-op version
     */
    virtual global void finish() {}

    /**
     * @description Return the name of the Group whose members receive status email. Defaults to Email Groupis sent, it can be done in this method.
     *
     * @return string - name of the email Group message should be sent to
     */
    virtual global String getEmailGroupName() {
        return this.config.Status_Email_Group_Name__c;
    }

    /**
     * @description If true, we send a status email on finish, if false, we do not. Defaults to true
     *
     * @return boolean
     */
    virtual global Boolean doSendFinishEmail() {return true; }

    // List of records in current chunk being processed. Accessible in subclasses
    @TestVisible protected List<SObject> records;
}
