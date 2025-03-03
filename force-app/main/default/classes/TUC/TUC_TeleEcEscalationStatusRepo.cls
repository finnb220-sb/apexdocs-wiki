/**
 * @author Booz Allen
 * @description This repository is for the Tele_EC_Escalation_Status__c object database operations
 */
public with sharing class TUC_TeleEcEscalationStatusRepo extends VTC_BaseRepo {
    /**
     * @description Constructor method for the E911 Repo
     */
    public TUC_TeleEcEscalationStatusRepo() {
        super(Tele_EC_Escalation_Status__c.sObjectType);
    }

    /**
     * @description Retrieves a list of Tele Ec Escalation Statuses with a specified query
     * @param providedVISN - the visn being queried
     * @param queueType - the type of queue being queried
     * @return  `List<Tele_EC_Escalation_Status__c>` - list of Escalation Statuses
     */
    public List<Tele_EC_Escalation_Status__c> getEscalationStatusWithVisnAndQueueType(
        String providedVISN,
        String queueType
    ) {
        String selectClause = 'Select Id,TUC_Status_Type__c,TUC_Status_Datetime__c,TUC_VISN__c,TUC_Is_Current_Status__c,TUC_Queue_Type__c,TUC_Pause_Reason__c';
        String fromClause = 'From Tele_EC_Escalation_Status__c';
        String whereClause =
            'Where TUC_Is_Current_Status__c = True AND TUC_VISN__c = \'' +
            providedVISN +
            '\' AND TUC_Queue_Type__c = \'' +
            queueType +
            '\'';
        String queryString = selectClause + ' ' + fromClause + ' ' + whereClause;
        return this.fetch(
            queryString,
            new Map<String, Object>{ 'providedVISN' => providedVISN, 'queueType' => queueType }
        );
    }
}
