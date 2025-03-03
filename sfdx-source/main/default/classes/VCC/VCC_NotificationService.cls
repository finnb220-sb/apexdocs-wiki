/**
 * @description VCC_NotificationService implements a way to use LogEntries to kick off automated emails based on the status of external services.
 * Currently, this is only implemented for the MPI integration VetRetrieve callout
 */
public with sharing class VCC_NotificationService {
    public static final String NEBULA_EXCEPTION_TYPE_MPI_DOWN = 'MPI_DOWN';
    public static final Integer HOURS_SINCE_LAST_EMAIL_LIMIT = 1;
    /**
     * @description notifyOnRemoteSystemDown Primary method called by other code to kickoff the automated Remote System Down emails
     * @param message the message returned from the external system
     */
    public static void notifyOnRemoteSystemDown(String message) {
        List<LogEntry__c> logEntriesToday = [
            SELECT Id, Message__c, ExceptionMessage__c, ExceptionType__c, CreatedDate
            FROM LogEntry__c
            WHERE ExceptionType__c = :NEBULA_EXCEPTION_TYPE_MPI_DOWN AND CreatedDate = TODAY
            WITH USER_MODE
            ORDER BY CreatedDate DESC
        ];
        //Get hours since last email message
        Long hoursSinceLastEmail = !logEntriesToday.isEmpty() ? getHoursSinceLastEmail(logEntriesToday) : 24;

        if (hoursSinceLastEmail >= HOURS_SINCE_LAST_EMAIL_LIMIT || System.Test.isRunningTest()) {
            Logger__c logObj = new Logger__c();
            if (Logger__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isCreateable() == true) {
                insert LogObj;
                LogEntry__c logEntry = new LogEntry__c();
                logEntry.ApexClassName__c = 'VCC_lwc_utils';
                logEntry.ApexMethodName__c = 'retrieveVetInfo';
                logEntry.ExceptionType__c = NEBULA_EXCEPTION_TYPE_MPI_DOWN;
                logEntry.ExceptionStackTrace__c = message;
                logEntry.Message__c = message;
                logEntry.ExceptionMessage__c = 'MPI Down Error';
                logEntry.Logger__c = logObj.Id;

                createLogEntry(logEntry);
            }
        }
    }
    /**
     * @description getHoursSinceLastEmail gets the hours since the last external service down email has been sent.
     * @param logEntriesToday is the log entries that have been created today for downed External Services
     * @return the hours since the last external service down email has been sent
     */
    public static Long getHoursSinceLastEmail(List<LogEntry__c> logEntriesToday) {
        Long dt1Long = logEntriesToday[0].CreatedDate.getTime();
        Long dt2Long = DateTime.now().getTime();
        Long milliseconds = dt2Long - dt1Long;
        Long seconds = milliseconds / 1000;
        Long minutes = seconds / 60;
        Long hours = minutes / 60;
        return hours;
    }
    /**
     * @description createLogEntry creates the LogEntry
     * @param logEntry The LogEntry to create that will kick off the automated email
     */
    public static void createLogEntry(LogEntry__c logEntry) {
        if (LogEntry__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isCreateable() == true) {
            insert logEntry;
        }
    }
}
