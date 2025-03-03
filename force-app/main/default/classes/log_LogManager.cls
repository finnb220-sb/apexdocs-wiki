@SuppressWarnings('PMD.ClassNamingConventions,PMD.AvoidGlobalModifier')
global class log_LogManager implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    private static final Integer DEFAULT_DAYS_TO_RETAIN_LOGS = (Integer) log_Settings__c.getOrgDefaults().Days__c;
    @TestVisible
    private Integer totalRecordsDeleted = 0;

    global log_LogManager() {
        System.debug(LoggingLevel.INFO, 'Empty constuctor.');
    }

    global Database.QueryLocator start(Database.BatchableContext batchableContext) {
        Datetime timestamp = DEFAULT_DAYS_TO_RETAIN_LOGS != null ? Datetime.now().addDays(-DEFAULT_DAYS_TO_RETAIN_LOGS) : Datetime.now().addDays(-7);
        Database.QueryLocator queryLocator = Database.getQueryLocator('SELECT Id FROM log_Log__c WHERE Timestamp__c <= :timestamp');
        return queryLocator;
    }

    global void execute(SchedulableContext schedulableContext) {
        Database.executeBatch(new log_LogManager());
    }

    global void execute(Database.BatchableContext batchableContext, List<log_Log__c> logs) {
        totalRecordsDeleted += logs.size();
        deleteLogs(logs);
    }

    @TestVisible
    private void deleteLogs(List<log_Log__c> logs) {
        log_LogService.deleteLogs(logs);
    }

    global void finish(Database.BatchableContext batchableContext) {
        log_LogService.log('log_LogManager', log_LogService.LogType.INFO, 'Purging of logs completed. Deleted logs older than ' + DEFAULT_DAYS_TO_RETAIN_LOGS + ' days old.');
        log_LogService.publish();
    }
}
