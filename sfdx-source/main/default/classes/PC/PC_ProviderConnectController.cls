/**
 * @description Class is responsible for providing data to multiple LWC components and Apex classes for Provider Connect.
 * @author      Booz Allen Hamilton
 * @since       2022
 * @see         PC_ProviderConnectControllerHelper
 * @see         PC_ProviderConnectControllerSystemHelper
 * @see         PC_PrcUserRepo
 * @see         PC_ServiceResourceSkillRepo
 * @see         PC_UserServicePresenceRepo
 * @see         PC_AgentWorkRepo
 * @see         PC_ChatSessionRepo
 * @see         PC_SpecialistUnavailabilityRepo
 * @see         PC_PrcCaseRepo
 * @see         PC_CustomException
 * @see         PC_ChatController
 **/
public with sharing class PC_ProviderConnectController {
    public static Boolean hasNDTH = PC_PrcConfigSettingsUtility.ndthRoutingEnabled;
    public static final String CONTEXTTYPE = 'lwc';

    /**
     * @description repository for PC User object
     */
    @TestVisible
    private static PC_PrcUserRepo prcUserRepo {
        get {
            return prcUserRepo = prcUserRepo ?? new PC_PrcUserRepo();
        }
        set;
    }

    /**
     * @description repository for Agent Work object
     */
    @TestVisible
    private static PC_AgentWorkRepo agentWorkRepo {
        get {
            return agentWorkRepo = agentWorkRepo ?? new PC_AgentWorkRepo();
        }
        set;
    }

    /**
     * @description repository for Service Resource Skill junction object
     */
    @TestVisible
    private static PC_ServiceResourceSkillRepo serviceResourceSkillRepo {
        get {
            return serviceResourceSkillRepo = serviceResourceSkillRepo ?? new PC_ServiceResourceSkillRepo();
        }
        set;
    }

    /**
     * @description repository for User Service Presence object
     */
    @TestVisible
    private static PC_UserServicePresenceRepo userPresenceRepo {
        get {
            return userPresenceRepo = userPresenceRepo ?? new PC_UserServicePresenceRepo();
        }
        set;
    }

    /**
     * @description repository for PC Chat Session object
     */
    @TestVisible
    private static PC_ChatSessionRepo pcChatSessionRepo {
        get {
            return pcChatSessionRepo = pcChatSessionRepo ?? new PC_ChatSessionRepo();
        }
        set;
    }

    /**
     * @description repository for custom PC Case object
     */
    @TestVisible
    private static PC_PrcCaseRepo prcCaseRepo {
        get {
            return prcCaseRepo = prcCaseRepo ?? new PC_PrcCaseRepo();
        }
        set;
    }

    /**
     * @description repository for PC Specialist Unavailability object
     */
    @TestVisible
    private static PC_SpecialistUnavailabilityRepo pcSpecialistUnavailabilityRepo {
        get {
            return pcSpecialistUnavailabilityRepo = pcSpecialistUnavailabilityRepo ??
                new PC_SpecialistUnavailabilityRepo();
        }
        set;
    }

    /**
     * @description Skill Status wrapper
     **/
    public class SkillStatus {
        @AuraEnabled
        public String skillName;
        @AuraEnabled
        public Boolean hasPresence;
        @AuraEnabled
        public Decimal minCapacity;
        @AuraEnabled
        public List<Case> openCases;
        @AuraEnabled
        public Integer consultantsOnline;
        @AuraEnabled
        public Boolean patientSpecificDisabled;
        @AuraEnabled
        public Boolean generalDisabled;
    }

    /**
     * @description Method to fetch revelant specialities and specialist presence data
     * @return  List<SkillStatus> - A list containing Specialist statuses
     **/
    public static List<SkillStatus> getSkills() {
        return getSkills('');
    }

    /**
     * @description Method to fetch revelant specialities and specialist presence data
     * @author John Meyer | 10-29-2021 , George Elias | 07-06-2022
     * @param context context for this apex method call to determine if user errors messages should be thrown for toast display
     * @return  List<SkillStatus> - A list containing Specialist Skill statuses
     **/
    @AuraEnabled
    public static List<SkillStatus> getSkills(String context) {
        try {
            List<SkillStatus> returnedStatusData;
            List<UserServicePresence> presences = userPresenceRepo.getCurrentUserServicePresence();
            List<PC_AgentWorkRepo.AgentWorkCapacityWrapper> agentWorks = agentWorkRepo.getAgentWorkCapacity();

            //General info gathering
            List<ServiceResourceSkill> relevantSkillsGeneral = serviceResourceSkillRepo.getServiceResourceSkills();

            returnedStatusData = PC_ProviderConnectControllerHelper.getSkillAvailability(
                relevantSkillsGeneral,
                presences,
                agentWorks
            );

            //Patient Specific info gathering: this is executed only if NDTH routhing is set to true in the org
            if (hasNDTH && CONTEXTTYPE.equalsIgnoreCase(context)) {
                List<ServiceResourceSkill> relevantSkillPatientSpecificList = PC_ProviderConnectControllerHelper.getRelevantSkillPatientSpecific();

                List<SkillStatus> patientSpecificAvailability = PC_ProviderConnectControllerHelper.getSkillAvailability(
                    relevantSkillPatientSpecificList,
                    presences,
                    agentWorks
                );

                //calling Consolidate logic to combine return statuses into 1 list
                returnedStatusData = PC_ProviderConnectControllerHelper.consolidateStatusTypes(
                    returnedStatusData,
                    patientSpecificAvailability
                );
            }
            return returnedStatusData;
        } catch (Exception caughtException) {
            throw PC_ExceptionUtils.logAndCreateAuraHandledException(caughtException.getMessage(), caughtException);
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description    Overloaded method to creates a Provider Connect Case (without a person account specified)
     * @param skill    String containing the name of the selected specialty
     * @param details  String of additional case details
     * @param channel  String of the channel selected (Chat, Teams, Phone)
     * @param callback String value of the callback number
     * @return         `PC_Case__c` the created PrC Case record
     */
    public static PC_Case__c createCase(String skill, String details, String channel, String callback) {
        PC_Case__c newCase = new PC_Case__c(
            Specialty__c = skill,
            Case_Details__c = details,
            Channel__c = channel,
            Callback_Number__c = callback,
            Patient_Account__c = null,
            PC_General_Question__c = false
        );
        return createCaseNew(newCase);
    }

    /**
     * @description            Creates a Provider Connect Case
     * @param newCase          New PC_Case record with populated fields populated from user selections (includes: Specialty, Case Details, Channel, Callback Number, Patient Account, and General Question)
     * @return                 `PC_Case__c` the created PrC Case record
     * @exception              Exception DMLException from PrC Case insertion, PC_CustomException thrown due to unavailability, Exceptions from getSkills
     */
    @AuraEnabled
    public static PC_Case__c createCaseNew(PC_Case__c newCase) {
        try {
            newCase.RecordTypeId = prcCaseRepo.recordTypeConstant.fromDeveloperName('Provider_Connect_Case').Id;
            newCase.Subject__c = newCase.Channel__c + ' - ' + UserInfo.getName();
            newCase.Status__c = 'Open';
            newCase.Callback_Number__c = newCase.Channel__c == 'Phone' ? newCase.Callback_Number__c : null;

            SkillStatus desiredSkillStatus = new SkillStatus();
            List<SkillStatus> lsSkillStatus = getSkills();
            for (SkillStatus sStatus : lsSkillStatus) {
                if (sStatus.skillName == newCase.Specialty__c) {
                    desiredSkillStatus = sStatus;
                    break;
                }
            }

            PC_ProviderConnectControllerHelper.checkUnavailableValue(
                desiredSkillStatus,
                newCase?.PC_General_Question__c
            );

            // ES - Salesforce has a known issue to fail when routing to an agent during a deployment test in the flow PC_Remind_Specialist_To_Cases. This is for mitigation to that.
            newCase.isRunningTest_DO_NOT_USE__c = Test.isRunningTest();
            prcCaseRepo.doCreate(newCase);

            return newCase;
        } catch (Exception caughtException) {
            throw PC_ExceptionUtils.logAndCreateAuraHandledException(caughtException.getMessage(), caughtException);
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description Method to get the assigned specialist of the case
     * @param caseId - String value of the ProviderConnect Case
     * @return Map<String,Object> - Map containing the agent information as 'agent' and PC_Chat_Session__c record Id as 'chatId'
     **/
    @AuraEnabled
    public static Map<String, Object> getAssignedAgent(String caseId) {
        if (String.isBlank(caseId)) {
            throw new PC_CustomException('Case Id cannot be blank.');
        }
        Map<String, Object> returnMap = new Map<String, String>();

        try {
            AgentWork agentWorkRecord = agentWorkRepo.getAgentWorkByCaseId(caseId);
            if (agentWorkRecord != null) {
                returnMap = PC_ProviderConnectControllerHelper.getAgentInfoMap(agentWorkRecord);
            }

            return returnMap;
        } catch (Exception caughtException) {
            throw PC_ExceptionUtils.logAndCreateAuraHandledException(caughtException.getMessage(), caughtException);
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description Method to cancel the specified case
     * @param caseId - String value of the ProviderConnect Case
     **/
    @AuraEnabled
    public static void cancelCaseRoutingError(String caseId) {
        if (String.isBlank(caseId)) {
            throw new PC_CustomException('Provided PC Case Id cannot be blank.');
        }

        try {
            PC_Case__c pcCaseToCancel = (PC_Case__c) prcCaseRepo.fetchById(caseId, new Set<String>{ 'Closed__c' });
            if (pcCaseToCancel.Closed__c) {
                throw new PC_CustomException('This case is already closed. Please refresh the page.');
            }
            pcCaseToCancel.Status__c = 'Cancelled';
            pcCaseToCancel.Specialist_Notes__c = 'Cancelled Reason:\nDouble booked';

            prcCaseRepo.doUpdate(pcCaseToCancel);
        } catch (Exception caughtException) {
            throw PC_ExceptionUtils.logAndCreateAuraHandledException(caughtException.getMessage(), caughtException);
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description Method to Pause/Unpause chat. Sets the user presence to pause work/resume through OmniChannel
     * @param workspaceCaseIds - List of case Ids that are open in all tabs in the workspace.
     * @param message - String value of the message to be sent to the chat
     * @return Boolean
     **/
    @AuraEnabled
    public static Boolean togglePauseChat(List<Id> workspaceCaseIds, String message) {
        List<PC_Chat_Session__c> chatSessions = pcChatSessionRepo.fetchOpenPcChatSessionByPrcCaseIds(
            new Set<Id>(workspaceCaseIds)
        );
        Set<Id> sessionIdSet = new Set<Id>();
        for (PC_Chat_Session__c session : chatSessions) {
            sessionIdSet.add(session.Id);
        }
        if (!sessionIdSet.isEmpty()) {
            PC_ChatController.saveChatterMessageList(sessionIdSet, '-*- ' + UserInfo.getName() + ' ' + message);
        }
        Flow.Interview.PC_Pause_and_Unpause_Users aFlow = new Flow.Interview.PC_Pause_and_Unpause_Users(
            new Map<String, Object>()
        );
        aFlow.start();
        return true;
    }
    /**
     * @description Method to check if the User is Paused. If the User navigates away from the page, this helps to set their current status.
     * @return Boolean
     **/
    @AuraEnabled
    public static Boolean isUserPaused() {
        Boolean isPaused = null;
        List<UserServicePresence> uspList = userPresenceRepo.getCurrentUserServicePresenceForRunningUser();
        if (!uspList.isEmpty()) {
            if (uspList[0]?.ServicePresenceStatus?.DeveloperName == 'PC_Wrap_Up') {
                isPaused = true;
            } else if (uspList[0]?.ServicePresenceStatus?.DeveloperName == 'PC_Available_Provider_Connect') {
                isPaused = false;
            }
        }
        return isPaused;
    }

    /**
     * @description Method to create PC Specialist Unavailability record. This denotes that no specialists were available.
     * @param speciality - String value of the speciality
     * @return PC_Specialist_Unavailability__c - The PC_Specialist_Unavailability__c record created
     **/
    @AuraEnabled
    public static PC_Specialist_Unavailability__c createPcSpecialistUnavailability(String speciality) {
        try {
            Id userId = UserInfo.getUserId();
            Id currentLocation = null;
            String division = null;
            List<PC_User__c> pcUserList = prcUserRepo.fetchPrcUserByUserIdWithSelectFields(
                userId,
                new Set<String>{ 'Current_Location__c', 'User_ID__r.Division' }
            );
            if (!pcUserList.isEmpty()) {
                currentLocation = pcUserList[0].Current_Location__c;
                division = pcUserList[0].User_ID__r.Division;
            }
            PC_Specialist_Unavailability__c psu = new PC_Specialist_Unavailability__c(
                PC_Specialty__c = speciality,
                PC_VISN__c = division,
                FLP_Current_Location__c = currentLocation
            );
            pcSpecialistUnavailabilityRepo.insertPCSpecialistUnavailability(psu);
            return psu;
        } catch (Exception caughtException) {
            throw PC_ExceptionUtils.logAndCreateAuraHandledException(caughtException.getMessage(), caughtException);
        } finally {
            Logger.saveLog();
        }
    }
}
