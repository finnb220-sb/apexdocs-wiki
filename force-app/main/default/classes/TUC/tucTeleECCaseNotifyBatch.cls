/**
 * Tele EC Case Notifier
 *
 * This Scheduled Batch class retrives all urgent cases via SOQL
 * and will create platform event(s) if those cases are assigned
 * to the queue for longer than 5 minutes. This class reschedules
 * itself upon completion
 *
 * @param - intervalInMinutes: integer value that determines when
 * 							   the next run of this batch class
 * 							   will occur in minutes after completion
 * @param - continueBatch: boolean value that will enable/disable
 * 						   the job to reschedule itself
 * @return - void
 */
global with sharing class tucTeleECCaseNotifyBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful {
    @TestVisible
    Integer intervalInMinutes = 1;
    @TestVisible
    Boolean continueBatch = true;

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select id, CaseNumber, TUC_Assigned_VISN__c, Status, TUC_Wait_Time__c from case where Case_Record_Type_Name__c like \'Tele_Urgent%\' and VCC_Owner_Queue_type__c = \'le_Emergency_Care_0_2_Hours\'';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Case> cases) {
        tucTeleECCaseNotifyBatchHelper.checkCasesToNotify(cases);
    }

    global void finish(Database.BatchableContext BC) {
        if (continueBatch) {
            system.scheduleBatch(new tucTeleECCaseNotifyBatch(), 'TeleECCaseMonitor' + Datetime.now(), intervalInMinutes);
        }
    }
}
