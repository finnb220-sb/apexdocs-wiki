/**
 * @description       : Class used as a controller for pcOmniChannelSupervisor LWC
 * @author            : George Elias
 * @group             : Booze Allen Hamilton
 * @last modified on  : 07-06-2022
 * @last modified by  : George Elias
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   07-06-2022   George Elias                          Initial Version
 **/
public with sharing class PC_ManagerController {
    /**
     * @description       : Wrapper class used to return data to LWC
     * @author            : George Elias
     * */
    @TestVisible
    public class AgentHistory {
        @AuraEnabled
        public String agentName;
        @AuraEnabled
        public String agentId;
        @AuraEnabled
        public String agentImage;
        @AuraEnabled
        public String currentStatus = 'Offline';
        @AuraEnabled
        public Decimal currentCapacity = 0;
        @AuraEnabled
        public List<UserServicePresence> historicStatuses = new List<UserServicePresence>();
        @AuraEnabled
        public List<PC_Case__c> openCases = new List<PC_Case__c>();
        @AuraEnabled
        public List<PC_Case__c> allCases = new List<PC_Case__c>();
    }

    /**
     * @description Method to fetch historical case and presence data of PC specialist
     * @author George Elias | 07-06-2022
     * @return  List<AgentHistory> - List of AgenHistory wrapper class
     **/
    @AuraEnabled
    public static List<AgentHistory> getAgentHistory() {
        try {
            List<AgentHistory> returnList = new List<AgentHistory>();
            Id pcRtId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByName()
                .get('Provider Connect Resource')
                .getRecordTypeId();
            List<String> lsUserIds = new List<String>();
            for (ServiceResource sr : [
                SELECT RelatedRecordId
                FROM ServiceResource
                WHERE RecordTypeId = :pcRtId
                WITH SECURITY_ENFORCED
            ]) {
                lsUserIds.add(sr.RelatedRecordId);
            }

            if (lsUserIds.size() == 0) {
                throw new PC_CustomException('No Provider Connect specialists found.');
            }

            Map<Id, User> mpUsers = new Map<Id, User>(
                [SELECT Id, Name, MediumPhotoUrl FROM User WHERE Id IN :lsUserIds WITH SECURITY_ENFORCED ORDER BY Name]
            );
            Map<String, List<UserServicePresence>> mpUserPresence = new Map<String, List<UserServicePresence>>();
            for (UserServicePresence usp : [
                SELECT
                    UserId,
                    User.Name,
                    ServicePresenceStatus.MasterLabel,
                    StatusStartDate,
                    ConfiguredCapacity,
                    StatusEndDate,
                    IsAway,
                    IdleDuration,
                    AtCapacityDuration,
                    AverageCapacity,
                    IsCurrentState,
                    StatusDuration,
                    PC_Specialty__c,
                    PC_Teams_Channel__c,
                    PC_Chat_Channel__c,
                    PC_Phone_Channel__c
                FROM UserServicePresence
                WHERE UserId IN :lsUserIds AND StatusStartDate = LAST_N_DAYS:30
                WITH SECURITY_ENFORCED
                ORDER BY IsCurrentState DESC, CreatedDate DESC
            ]) {
                if (mpUserPresence.containsKey(usp.UserId)) {
                    mpUserPresence.get(usp.UserId).add(usp);
                } else {
                    mpUserPresence.put(usp.UserId, new List<UserServicePresence>{ usp });
                }
            }

            Map<String, List<PC_Case__c>> mpOpenCases = new Map<String, List<PC_Case__c>>();
            Map<String, List<PC_Case__c>> mpAllCases = new Map<String, List<PC_Case__c>>();
            for (PC_Case__c c : [
                SELECT Id, Name, CreatedDate, Specialty__c, Channel__c, Status__c, OwnerId, Closed__c, Closed_Date__c
                FROM PC_Case__c
                WHERE RecordType.DeveloperName = 'Provider_Connect_Case' AND CreatedDate = LAST_N_DAYS:30
                ORDER BY Name DESC
            ]) {
                if (c.Closed__c == false) {
                    if (mpOpenCases.containsKey(c.OwnerId)) {
                        mpOpenCases.get(c.OwnerId).add(c);
                    } else {
                        mpOpenCases.put(c.OwnerId, new List<PC_Case__c>{ c });
                    }
                }
                if (mpAllCases.containsKey(c.OwnerId)) {
                    mpAllCases.get(c.OwnerId).add(c);
                } else {
                    mpAllCases.put(c.OwnerId, new List<PC_Case__c>{ c });
                }
            }

            List<AgentWork> lsAW = [
                SELECT UserId, Status, CapacityWeight
                FROM AgentWork
                WHERE Status = 'Opened'
                WITH SECURITY_ENFORCED
            ];

            if (Test.isRunningTest()) {
                User specialist = [
                    SELECT Id
                    FROM User
                    WHERE LastName = 'Test PC Manager'
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];

                ServiceChannel sc = [
                    SELECT Id
                    FROM ServiceChannel
                    WHERE DeveloperName = 'PC_Chat_Service'
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];

                PC_Case__c c = [SELECT Id FROM PC_Case__c WITH SECURITY_ENFORCED LIMIT 1];
                lsAW.add(
                    new AgentWork(
                        UserID = specialist.Id,
                        WorkItemId = c.Id,
                        ServiceChannelId = sc.Id,
                        CapacityWeight = 5
                    )
                );
            }

            Map<String, Decimal> mpAgentCapacity = new Map<String, Decimal>();
            for (AgentWork aw : lsAW) {
                if (mpAgentCapacity.containsKey(aw.UserId)) {
                    mpAgentCapacity.put(aw.UserId, mpAgentCapacity.get(aw.UserId) + aw.CapacityWeight);
                } else {
                    mpAgentCapacity.put(aw.UserId, aw.CapacityWeight);
                }
            }

            for (String userId : mpUsers.keySet()) {
                AgentHistory ag = new AgentHistory();
                ag.agentId = userId;
                ag.agentName = mpUsers.get(userId).Name;
                ag.agentImage = mpUsers.get(userId).MediumPhotoUrl;

                if (mpUserPresence.containsKey(userId)) {
                    ag.currentStatus = mpUserPresence.get(userId)[0].IsCurrentState == true
                        ? mpUserPresence.get(userId)[0].ServicePresenceStatus.MasterLabel.split(' - ')[0]
                        : 'Offline';
                    ag.historicStatuses = mpUserPresence.get(userId);
                }
                if (mpAllCases.containsKey(userId)) {
                    ag.allCases = mpAllCases.get(userId);
                }
                if (mpOpenCases.containsKey(userId)) {
                    ag.openCases = mpOpenCases.get(userId);
                }

                if (mpAgentCapacity.containsKey(userId)) {
                    ag.currentCapacity = (mpAgentCapacity.get(userId) / 20) * 100;
                }
                returnList.add(ag);
            }

            return returnList;
        } catch (Exception e) {
            log_LogService.log('PC_ManagerController.getAgentHistory Exception', log_LogService.LogType.ERROR, e);
            log_LogService.publish();
            throw new AuraHandledException(e.getMessage());
        }
    }
}
