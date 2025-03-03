/**
 * @author  Booz Allen Hamilton
 * @date 2/12/2024
 *
 * @description  VCC_LogManager class deletes old log files and implements Database.Batchable and Schedulable interface methods
 */
global with sharing class VCC_LogManager implements Database.Batchable<SObject>, Schedulable {
    private static final Integer DEFAULT_DAYS_TO_RETAIN_LOGS = 7;

    global VCC_LogManager() {
    }

    global Database.QueryLocator start(Database.BatchableContext batchableContext) {
        Datetime timestamp = Datetime.now().addDays(-DEFAULT_DAYS_TO_RETAIN_LOGS);
        Database.QueryLocator queryLocator = Database.getQueryLocator('SELECT Id FROM VCC_Log__c WHERE Timestamp__c <= :timestamp');
        return queryLocator;
    }

    global void execute(SchedulableContext schedulableContext) {
        Database.executeBatch(new VCC_LogManager());
    }

    global void execute(Database.BatchableContext batchableContext, List<VCC_Log__c> logs) {
        deleteLogs(logs);
    }

    @TestVisible
    private void deleteLogs(List<VCC_Log__c> logs) {
        VCC_LogService.deleteLogs(logs);
    }

    global void finish(Database.BatchableContext batchableContext) {
        VCC_LogService.log('VCC_LogManager', VCC_LogService.VCC_LogType.INFO, 'Purging of logs completed. Deleted logs older than ' + DEFAULT_DAYS_TO_RETAIN_LOGS + ' days old.');
        VCC_LogService.publish();
    }
}
