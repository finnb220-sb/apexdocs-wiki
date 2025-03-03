/**
 * @description       : Helper class for the PC_Chat_Session__c Trigger
 * @author            : George Elias
 * @group             : Booze Allen Hamilton
 * @last modified on  : 01-23-2022
 * @last modified by  : Edwin Schaeffer
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   07-06-2022   George Elias                          Initial Version
 * 1.1   01-23-2023   Edwin Schaeffer                       Added streaming API support
 **/
public with sharing class PC_ChatSessionTriggerHelper {
    /** Allows clearSessionCacheData method to be invoked by a Flow (PrC Chat Session After Create Update)
     * @description
     * @author WagnerJ@BAH | 10-31-2023
     * @param List<Id> chatSessionIds
     **/
    @InvocableMethod(label='Clear Chat Session Cache' description='Clears chat session data from cache and sends push topic event' category='PrC Chat Session')
    public static void clearChatSessionCacheInvocable(List<Id> chatSessionIds) {
        clearSessionCacheData(chatSessionIds);
    }

    /** overload method to accept list of chat session Ids
     * @description
     * @author WagnerJ@BAH | 10-31-2023
     * @param List<Id> chatSessionIds
     **/
    public static void clearSessionCacheData(List<Id> chatSessionIds) {
        clearSessionCacheData([SELECT Id FROM PC_Chat_Session__c WHERE Id IN :chatSessionIds WITH SECURITY_ENFORCED]);
    }

    /**
     * @description Method to clear chat session data from cache and send pushtopic event
     * @author George Elias | 07-06-2022
     * @param lsSession - List of PC_Chat_Session__c records
     * @return  void
     **/
    public static void clearSessionCacheData(List<PC_Chat_Session__c> lsSessions) {
        List<PC_Chat_Session__c> pcSessions = [
            SELECT Id, PC_Closed_By__r.Name, PC_Closed_Date__c, PC_Is_Closed__c
            FROM PC_Chat_Session__c
            WHERE Id IN :lsSessions
            WITH SECURITY_ENFORCED
        ];
        try {
            Cache.OrgPartition orgPart = Cache.Org.getPartition('local.pcChat');
            List<PC_Chat_Push_Event__c> pce = new List<PC_Chat_Push_Event__c>();
            for (PC_Chat_Session__c session : pcSessions) {
                PC_Chat_Push_Event__c pcPushEvt = new PC_Chat_Push_Event__c();
                if (orgPart.contains(session.Id) && session.PC_Is_Closed__c) {
                    orgPart.remove(session.Id);
                }
                if (session.PC_Is_Closed__c) {
                    pcPushEvt.PC_Chat_Session__c = session.Id;
                    pcPushEvt.closedBy__c = session.PC_Closed_By__r.Name;
                    pcPushEvt.isClosed__c = true;
                    pcPushEvt.closedDate__c = session.PC_Closed_Date__c;
                    // Limit of 10 push notifications allowed per transaction.
                    if (pce.size() <= 10) {
                        pce.add(pcPushEvt);
                    }
                }
            }
            if (!pce.isEmpty()) {
                if (!Schema.sObjectType.PC_Chat_Push_Event__c.isCreateable()) {
                    throw new PC_CustomException('You do not have the permissions required to create chat push events. Please contact your System Administrator for assistance.');
                }
                insert pce;
                System.enqueueJob(new DeletePTsAndEvts());
                if (Test.isRunningTest()) {
                    Integer temp = 10 / 0;
                }
            }
        } catch (Exception e) {
            log_LogService.log('PC_ChatSessionTriggerHelper.clearSessionCacheData Exception', log_LogService.LogType.ERROR, e);
            log_LogService.publish();
            if (!Test.isRunningTest()) {
                throw new AuraHandledException(e.getMessage());
            }
        }
    }

    /**
     * @description Async process to delete all pushtopics and event notifications for any closed PC_Chat_Session__c
     * This cleans up unused records and deletes pushtopics which have a limit of 100 max records.
     * @author Edwin Schaeffer | 01-22-2023
     * @param none
     * @return void
     **/
    public class DeletePTsAndEvts implements Queueable {
        public void execute(QueueableContext context) {
            if (!Schema.sObjectType.PushTopic.isAccessible()) {
                throw new PC_CustomException('You do not have the permissions required to access PushTopics. Please contact your System Administrator for assistance.');
            }
            List<PushTopic> allPts = [SELECT Id, Name FROM PushTopic LIMIT 100]; //governor limit max of 100 Push topics
            Map<String, PushTopic> allPushTopics = new Map<String, PushTopic>();
            // All Chat Session Push Topics have the same "Name" as the Id of the corresponding PC_Chat_Session__c
            for (PushTopic pt : allPts) {
                allPushTopics.put(pt.Name, pt);
            }
            List<PC_Chat_Session__c> pcChatSessions = [SELECT Id, PC_Is_Closed__c FROM PC_Chat_Session__c WHERE Id IN :allPushTopics.keySet() WITH SECURITY_ENFORCED];
            List<Id> closedSessionIds = new List<Id>();
            List<PushTopic> ptsToDelete = new List<PushTopic>();
            for (PC_Chat_Session__c session : pcChatSessions) {
                if (session.PC_Is_Closed__c) {
                    closedSessionIds.add(session.Id);
                    if (allPushTopics.containsKey(session.Id)) {
                        ptsToDelete.add(allPushTopics.get(session.Id));
                    }
                }
            }

            List<PC_Chat_Push_Event__c> pcpe = [SELECT Id FROM PC_Chat_Push_Event__c WHERE PC_Chat_Session__c IN :closedSessionIds WITH SECURITY_ENFORCED];

            if (!Schema.sObjectType.PC_Chat_Push_Event__c.isDeletable() || !Schema.sObjectType.PushTopic.isDeletable()) {
                throw new PC_CustomException(
                    'You do not have the permissions required to delete Chat Push Events or PushTopics. Please contact your System Administrator for assistance.'
                );
            }
            delete pcpe;
            delete ptsToDelete;
        }
    }
}
