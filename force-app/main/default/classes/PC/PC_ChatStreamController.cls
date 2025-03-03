/**
 * @description Class used in Flows (Trigger_Pushtopic_from_AgentWork & PC_Set_Presence_Channel) and pcChat LWC. Used to trigger and create pushtopics
 * @author      Booz Allen Hamilton
 */
public inherited sharing class PC_ChatStreamController {
    @TestVisible
    private final static String PC_SUPER_SCREEN_PUSH_TOPIC_NAME = 'pcSuperScreen';

    @TestVisible
    private final static Double PC_SUPER_SCREEN_PUSH_TOPIC_API_VERSION = 61.0;

    @TestVisible
    private final static String PC_SUPER_SCREEN_PUSH_TOPIC_NOTIFY_TYPE = 'Referenced';

    @TestVisible
    private final static String PC_SUPER_SCREEN_PUSH_TOPIC_QUERY = 'SELECT Id, CaseClosedJSON__c, CaseClosedStatus__c, GeneralDisabled__c, PatientSpecificDisabled__c, ConsultantsOnline__c,  HasPresence__c, NewCaseOwner__c, CaseClosedByName__c, MinCapacity__c, SkillName__c, OwnerId, NewOwnerTitle__c, NewOwnerCity__c, NewOwnerState__c, NewOwnerEmail__c, NewOwnerMediumPhotoUrl__c, NewOwnerDepartment__c FROM PC_AWPushEvent__c';

    /**
     * @description repository for PC_AWPushEvent__c object
     */
    @TestVisible
    private static PC_AWPushEventRepo awPushEventRepo {
        get {
            return awPushEventRepo = awPushEventRepo ?? new PC_AWPushEventRepo();
        }
        set;
    }

    /**
     * @description repository for User object
     */
    @TestVisible
    private static VCR_UserRepo userRepo {
        get {
            return userRepo = userRepo ?? new VCR_UserRepo();
        }
        set;
    }

    /**
     * @description repository for PushTopic object
     */
    @TestVisible
    private static VCR_PushTopicRepo pushTopicRepo {
        get {
            return pushTopicRepo = pushTopicRepo ?? new VCR_PushTopicRepo();
        }
        set;
    }

    /**
     * @description flow input wrapper for invoke Push Topic
     */
    public class InvokePushTopicFlowInput {
        @InvocableVariable
        public UserServicePresence userServicePresence;

        @InvocableVariable
        public AgentWork agentWork;

        @InvocableVariable
        public PC_Case__c pcCase;

        /**
         * @description holds the salesforce UserId of the specialist depending on triggering object (UserServicePresence or AgentWork)
         */
        public String specialistId {
            get {
                return userServicePresence?.UserId ?? agentWork?.UserId;
            }
            private set;
        }
    }

    /**
     * @description  Creates a PushTopic for a PrC Case's Chat Session and triggers a refresh of the FLP Homepage Speciality Availability table (PC SuperScreen) with a push event
     * @param inputs flow inputs containing a UserServicePresence record or an AgentWork and PrC Case record
     * @return       `List<PC_AWPushEvent__c>` list of AW Push Events that were upserted
     * @exception    DmlException upsert exception on AW Push Event created/changed
     */
    @InvocableMethod(
        label='Trigger PC SuperScreen Push Topic'
        description='Sends a PC AWPushEvent to trigger the PC SuperScreen Push Topic causing the Specialty Availability Matrix table to refresh its available skill and channel options'
        category='Provider Connect'
    )
    public static List<PC_AWPushEvent__c> invokePushTopic(List<InvokePushTopicFlowInput> inputs) {
        if (inputs == null) {
            throw new PC_CustomException('invokePushTopic input list cannot be null.');
        }

        try {
            Map<String, PC_ProviderConnectController.SkillStatus> skillStatusMap = createSkillStatusMap();

            //remove invalid inputs and generate neccessary maps for creating push events
            //--------------------------------------------//
            Set<String> specialistUserIdsQuerySet = new Set<String>();
            Set<String> allUserIdsQuerySet = new Set<String>();
            List<InvokePushTopicFlowInput> validInputs = new List<InvokePushTopicFlowInput>();
            for (InvokePushTopicFlowInput flowInput : inputs) {
                if (flowInput.specialistId == null) {
                    Logger.warn(
                        'Skipped over invokePushTopic flow input because neither UserServicePresence nor AgentWork had an associated UserId: ' +
                        String.valueOf(flowInput)
                    );
                    continue;
                }
                validInputs.add(flowInput);

                specialistUserIdsQuerySet.add(flowInput.specialistId);
                allUserIdsQuerySet.add(flowInput?.pcCase?.OwnerId);
                allUserIdsQuerySet.add(flowInput?.pcCase?.LastModifiedById);
            }
            allUserIdsQuerySet.addAll(specialistUserIdsQuerySet);

            Map<String, PC_AWPushEvent__c> ownerIdToMostRecentAWPushEventMap = getOwnerIdToMostRecentAWPushEventMap(
                specialistUserIdsQuerySet
            );
            Map<Id, User> sfIdToUserMap = getSfIdToUserMap(allUserIdsQuerySet);
            //--------------------------------------------//

            List<PC_AWPushEvent__c> awPushEventsToUpsert = new List<PC_AWPushEvent__c>();
            for (InvokePushTopicFlowInput flowInput : validInputs) {
                PC_AWPushEvent__c awPushEvent = ownerIdToMostRecentAWPushEventMap?.get(flowInput.specialistId) ??
                    new PC_AWPushEvent__c();

                PC_SuperScreenPushEvent superScreenPushEvent;
                if (flowInput.userServicePresence != null) {
                    superScreenPushEvent = new PC_SuperScreenPushEvent(flowInput.userServicePresence, awPushEvent);
                } else {
                    superScreenPushEvent = new PC_SuperScreenPushEvent(
                        flowInput.agentWork,
                        flowInput.pcCase,
                        awPushEvent
                    );
                }

                superScreenPushEvent.resetPushEventFields();

                //null values are handled in their respective setter methods
                superScreenPushEvent.setNewOwnerFields(sfIdToUserMap?.get(flowInput?.pcCase?.OwnerId));
                superScreenPushEvent.setCaseClosedFields(sfIdToUserMap?.get(flowInput?.pcCase?.LastModifiedById));
                superScreenPushEvent.setSpecialtyAvailabilityFields(
                    skillStatusMap?.get(superScreenPushEvent.specialty)
                );

                awPushEventsToUpsert.add(superScreenPushEvent.pushEvent);
            }

            PC_ChatStreamControllerSysHelper.performPushEventSystemUpsert(awPushEventsToUpsert);
            return awPushEventsToUpsert;
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description retrieves default skill status information from Provider Connect Controller getSkills method and compiles it in map form
     * @return      `Map<String, PC_ProviderConnectController.SkillStatus>` map of skill name to skill status
     */
    @TestVisible
    private static Map<String, PC_ProviderConnectController.SkillStatus> createSkillStatusMap() {
        Map<String, PC_ProviderConnectController.SkillStatus> skillStatusMap = new Map<String, PC_ProviderConnectController.SkillStatus>();

        //get list of current skills and their availability details
        List<PC_ProviderConnectController.SkillStatus> skillStatuses = PC_ProviderConnectController.getSkills() != null
            ? PC_ProviderConnectController.getSkills()
            : new List<PC_ProviderConnectController.SkillStatus>();

        for (PC_ProviderConnectController.SkillStatus skillStatus : skillStatuses) {
            skillStatusMap.put(skillStatus.skillName, skillStatus);
        }

        return skillStatusMap;
    }

    /**
     * @description generates a map of the most recently created AW Push Event record for each specialist user
     * @param specialistUserIds set of user specialist User Ids
     * @return                  `Map<String, PC_AWPushEvent__c>` Map of specialist user Id to most recent AW Push Event record they own
     * @exception               QueryException thrown when the AW Push Event query fails
     */
    @TestVisible
    private static Map<String, PC_AWPushEvent__c> getOwnerIdToMostRecentAWPushEventMap(Set<String> specialistUserIds) {
        Map<String, PC_AWPushEvent__c> ownerIdToMostRecentAWPushEventMap = new Map<String, PC_AWPushEvent__c>();

        try {
            for (PC_AWPushEvent__c awPushEvent : awPushEventRepo.getAWPushEventsByOwners(specialistUserIds)) {
                //only add first push event for each owner since they are in order of CreatedDate and we only want the most recently created one per user
                if (!ownerIdToMostRecentAWPushEventMap.containsKey(awPushEvent.OwnerId)) {
                    ownerIdToMostRecentAWPushEventMap.put(awPushEvent.OwnerId, awPushEvent);
                }
            }
        } catch (QueryException caughtException) {
            Logger.error(
                'An error occurred while querying for PC AWPush Event records in the getOwnerIdToMostRecentAWPushEventMap method',
                caughtException
            );
            throw new PC_CustomException(caughtException.getMessage());
        }

        return ownerIdToMostRecentAWPushEventMap;
    }

    /**
     * @description   get map of salesforce Ids to their respective salesforce user records
     * @param userIds Set of salesforce user Ids
     * @return        `Map<Id, User>` Map of Ids to salesforce user
     * @exception     QueryException thrown when the User query fails
     */
    @TestVisible
    private static Map<Id, User> getSfIdToUserMap(Set<String> userIds) {
        Map<Id, User> sfIdToUserMap = new Map<Id, User>();
        try {
            userIds.remove(null);
            sfIdToUserMap = new Map<Id, User>(userRepo.fetchUsersByIds(userIds));
        } catch (Exception caughtException) {
            Logger.error(
                'An error occurred while querying for User records in the getSfIdToUserMap method',
                caughtException
            );
            throw new PC_CustomException(caughtException.getMessage());
        }

        return sfIdToUserMap;
    }

    /**
     * @description Method to create Pushtopic to PC Super Screen (FLP Homepage specialty table) if not already created
     * @return      `PushTopic` the newly created (or pre-existing) PC Super Screen Push Topic
     * @exception   Exception thrown when the PushTopic query fails or PushTopic insert fails
     */
    @AuraEnabled
    public static PushTopic createSuperScreenPTs() {
        try {
            PushTopic superScreenPT = pushTopicRepo.getMostRecentPushTopicByName(PC_SUPER_SCREEN_PUSH_TOPIC_NAME);

            if (String.isBlank(superScreenPT?.Id)) {
                superScreenPT.Name = PC_SUPER_SCREEN_PUSH_TOPIC_NAME;
                superScreenPT.ApiVersion = PC_SUPER_SCREEN_PUSH_TOPIC_API_VERSION;
                superScreenPT.NotifyForOperationUndelete = false;
                superScreenPT.NotifyForOperationDelete = false;
                superScreenPT.NotifyForOperationCreate = true;
                superScreenPT.NotifyForOperationUpdate = true;
                superScreenPT.NotifyForFields = PC_SUPER_SCREEN_PUSH_TOPIC_NOTIFY_TYPE;
                superScreenPT.Query = PC_SUPER_SCREEN_PUSH_TOPIC_QUERY;

                pushTopicRepo.doCreate(superScreenPT);
            }

            return superScreenPT;
        } catch (Exception caughtException) {
            Logger.error('An error occurred during the execution of the createSuperScreenPTs method', caughtException);
            throw new PC_CustomException(caughtException.getMessage());
        } finally {
            Logger.saveLog();
        }
    }
}
