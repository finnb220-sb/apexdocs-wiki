/**
 * @description Helper class for PC_ProviderConnectController that contains methods to facilitate Specialist Availability calculation and Skill list creation
 * @author      Booz Allen Hamilton
 * @since       2025
 * @see         PC_ProviderConnectController
 * @see         VCR_UserRepo
 * @see         PC_PrcUserRepo
 * @see         PC_NDTHClinicalServicesRepo
 * @see         PC_NDTHHostLocationRepo
 * @see         PC_NDTHServiceLocationRepo
 * @see         PC_ServiceResourceSkillRepo
 * @see         PC_ChatSessionRepo
 * @see         PC_PrcCaseRepo
 * @see         PC_CustomException
 */
public with sharing class PC_ProviderConnectControllerHelper {
    public static final String CHAT_SKILL = 'Chat';
    public static final String VISN_SKILL = 'VISN';

    /**
     * @description Repository for PC User object
     */
    @TestVisible
    private static PC_PrcUserRepo prcUserRepo {
        get {
            return prcUserRepo = prcUserRepo ?? new PC_PrcUserRepo();
        }
        set;
    }

    /**
     * @description Repository for NDTH Clinical Services object
     */
    @TestVisible
    private static PC_NDTHClinicalServicesRepo ndthClinicalServicesRepo {
        get {
            return ndthClinicalServicesRepo = ndthClinicalServicesRepo ?? new PC_NDTHClinicalServicesRepo();
        }
        set;
    }

    /**
     * @description Repository for NDTH Host Locations object
     */
    @TestVisible
    private static PC_NDTHHostLocationRepo ndthHostLocationRepo {
        get {
            return ndthHostLocationRepo = ndthHostLocationRepo ?? new PC_NDTHHostLocationRepo();
        }
        set;
    }

    /**
     * @description Repository for NDTH Service Locations object
     */
    @TestVisible
    private static PC_NDTHServiceLocationRepo ndthServiceLocationRepo {
        get {
            return ndthServiceLocationRepo = ndthServiceLocationRepo ?? new PC_NDTHServiceLocationRepo();
        }
        set;
    }

    /**
     * @description Repository for Service Resource Skill junction object
     */
    @TestVisible
    private static PC_ServiceResourceSkillRepo serviceResourceSkillRepo {
        get {
            return serviceResourceSkillRepo = serviceResourceSkillRepo ?? new PC_ServiceResourceSkillRepo();
        }
        set;
    }

    /**
     * @description Repository for custom PC Case object
     */
    @TestVisible
    private static PC_PrcCaseRepo prcCaseRepo {
        get {
            return prcCaseRepo = prcCaseRepo ?? new PC_PrcCaseRepo();
        }
        set;
    }

    /**
     * @description Repository for PC Chat Session object
     */
    @TestVisible
    private static PC_ChatSessionRepo pcChatSessionRepo {
        get {
            return pcChatSessionRepo = pcChatSessionRepo ?? new PC_ChatSessionRepo();
        }
        set;
    }

    /**
     * @description Repository for User object
     */
    @TestVisible
    private static VCR_UserRepo userRepo {
        get {
            return userRepo = userRepo ?? new VCR_UserRepo();
        }
        set;
    }

    /**
     * @description    Method to calculate revelant specialities and specialist presence data
     * @param    relevantSkillsList    List of Service Resource Skill (aka Specialities)
     * @param    presences    List of User Service Presence that are related to the Skills
     * @param    agentWorks    List of Agent Works (aka Cases)
     * @return  List<PC_ProviderConnectController.SkillStatus> - A List containing specialist SkillStatuses
     **/
    public static List<PC_ProviderConnectController.SkillStatus> getSkillAvailability(
        List<ServiceResourceSkill> relevantSkillsList,
        List<UserServicePresence> presences,
        List<PC_AgentWorkRepo.AgentWorkCapacityWrapper> agentWorks
    ) {
        Map<String, Boolean> skillsAndPresence = new Map<String, Boolean>();
        Map<String, Set<Id>> skillsAndUsers = new Map<String, Set<Id>>();
        Map<String, Set<Id>> skillsAndOnlineUsers = new Map<String, Set<Id>>();

        for (ServiceResourceSkill srSkill : relevantSkillsList) {
            skillsAndPresence.put(srSkill.Skill.MasterLabel, false);
            skillsAndOnlineUsers.put(srSkill.Skill.MasterLabel, new Set<Id>());
            skillsAndUsers.put(srSkill.Skill.MasterLabel, new Set<Id>());
        }

        // agentCapacity contains a list of user IDs and each one's total capacity.
        Map<Id, Decimal> agentCapacity = new Map<Id, Decimal>();
        for (PC_AgentWorkRepo.AgentWorkCapacityWrapper work : agentWorks) {
            agentCapacity.put(work.userId, work.totalCapacity);
        }

        //skillsAndUsers contains a list of skills, each with a list of users whose skill level for that skill is >= minumumSkillLevel.
        for (ServiceResourceSkill srSkill : relevantSkillsList) {
            skillsAndUsers.get(srSkill.Skill.MasterLabel).add(srSkill.ServiceResource.RelatedRecordId);
        }

        //skillsAndPresence contains a list of skills and whether or not there is a presence for each skill.
        for (UserServicePresence presence : presences) {
            for (String skill : skillsAndUsers.keySet()) {
                skillsAndPresence.put(
                    skill,
                    skillsAndPresence.get(skill) || skillsAndUsers.get(skill).contains(presence.UserId)
                );
                if (skillsAndUsers.get(skill).contains(presence.UserId)) {
                    skillsAndOnlineUsers.get(skill).add(presence.UserId);
                }
            }
        }

        return generateSkillsList(skillsAndPresence, skillsAndOnlineUsers, agentCapacity);
    }

    /**
     * @description    Method to build Skills (wrapper) with Specialist type and their availabilities, info needed to drive the lwc
     * @param    skillsAndPresence   Map that holds Skills to the current Presence boolean
     * @param    skillsAndOnlineUsers  Map that holds Skills to the Set of Ids of the Users who are Online
     * @param    agentCapacity   Map that holds the Agent Id to their corresponding capacity value
     * @return  List<PC_ProviderConnectController.SkillStatus> - A List containing specialist SkillStatuses to be utilized by the lwc
     **/

    public static List<PC_ProviderConnectController.SkillStatus> generateSkillsList(
        Map<String, Boolean> skillsAndPresence,
        Map<String, Set<Id>> skillsAndOnlineUsers,
        Map<Id, Decimal> agentCapacity
    ) {
        // Send back a list of statuses for each skill that contains the maximum capacity for each skill and whether or not the
        // button for each channel should be enabled.
        List<PC_ProviderConnectController.SkillStatus> statuses = new List<PC_ProviderConnectController.SkillStatus>();

        Map<String, Map<String, Boolean>> skillsAndChannelPresence = getChannelPresence(
            skillsAndOnlineUsers,
            agentCapacity
        );

        for (String skill : skillsAndPresence.keySet()) {
            if (skill == CHAT_SKILL || skill.contains(VISN_SKILL)) {
                continue;
            }

            PC_ProviderConnectController.SkillStatus status = new PC_ProviderConnectController.SkillStatus();
            status.skillName = skill;
            status.hasPresence = skillsAndPresence.get(skill);
            status.minCapacity = PC_ProviderConnectControllerHelper.getMinCapacity(
                skillsAndOnlineUsers.get(skill),
                agentCapacity
            );

            Boolean isSkillDisabled =
                !status.hasPresence || !(status.hasPresence && skillsAndChannelPresence.get(skill).get('Chat'));

            if (status.minCapacity >= 20.0) {
                status.patientSpecificDisabled = true;
                status.generalDisabled = true;
            } else {
                status.patientSpecificDisabled = PC_ProviderConnectController.hasNDTH ? isSkillDisabled : true;
                status.generalDisabled = isSkillDisabled;
            }

            status.consultantsOnline = skillsAndOnlineUsers.get(skill).size();

            statuses.add(status);
        }
        return statuses;
    }

    /**
     * @description    Method to consolidate Statuses for both General and Patient Specific in order to return a single list to lwc
     * @param    generalStatuses    List of SkillStatus (wrapper) for General Skills
     * @param    patientSpecificStatuses     List of SkillStatus (wrapper) for Patient Specific Skills
     * @return  List<PC_ProviderConnectController.SkillStatus> - A List containing Specialist's statuses
     */
    public static List<PC_ProviderConnectController.SkillStatus> consolidateStatusTypes(
        List<PC_ProviderConnectController.SkillStatus> generalStatuses,
        List<PC_ProviderConnectController.SkillStatus> patientSpecificStatuses
    ) {
        Map<String, PC_ProviderConnectController.SkillStatus> consolidatedSkillStatusMap = new Map<String, PC_ProviderConnectController.SkillStatus>();

        for (PC_ProviderConnectController.SkillStatus eaGeneralSkill : generalStatuses) {
            eaGeneralSkill.patientSpecificDisabled = true;
            consolidatedSkillStatusMap.put(eaGeneralSkill.skillName, eaGeneralSkill);
        }

        for (PC_ProviderConnectController.SkillStatus eaPatientSpecificSkill : patientSpecificStatuses) {
            if (!consolidatedSkillStatusMap.containsKey(eaPatientSpecificSkill.skillName)) {
                consolidatedSkillStatusMap.put(eaPatientSpecificSkill.skillName, eaPatientSpecificSkill);
            }
            consolidatedSkillStatusMap.get(eaPatientSpecificSkill.skillName)
                .patientSpecificDisabled = eaPatientSpecificSkill.patientSpecificDisabled;
        }

        return consolidatedSkillStatusMap.values();
    }

    /**
     * @description    Method to calculate revelant skills for Patient Specific scenarios
     * @return List<ServiceResourceSkill> List of Service Resource Skills that relate to the Patient Specific Users
     */
    public static List<ServiceResourceSkill> getRelevantSkillPatientSpecific() {
        List<PC_User__c> pcUserQueryResult = prcUserRepo.fetchPrcUserByUserId(UserInfo.getUserId());

        Id runningUserLocationId = pcUserQueryResult.isEmpty() ? null : pcUserQueryResult[0]?.Current_Location__c;

        if (String.isBlank(runningUserLocationId)) {
            throw new PC_CustomException(
                'No location detected for the current user. Please update your current location and try again.'
            );
        }

        Set<Id> setOfNDTHsServicingUserLocation = ndthServiceLocationRepo.getNDTHsIdSetFromLocation(
            runningUserLocationId
        );

        Set<String> setOfSkillsAvailableUnderNDTHs = ndthClinicalServicesRepo.getSpecialtiesForNDTHs(
            setOfNDTHsServicingUserLocation
        );

        Set<Id> setOfSpecialistLocationsAvailableUnderNDTHs = ndthHostLocationRepo.getSpecialistLocationIdsForNDTHs(
            setOfNDTHsServicingUserLocation
        );

        return serviceResourceSkillRepo.getServiceResourceSkillsNDTHRouting(
            setOfSkillsAvailableUnderNDTHs,
            setOfSpecialistLocationsAvailableUnderNDTHs
        );
    }

    /**
     * @description   Gets the available capacity for a list of specialist (agent) users for a specific specialty (skill) to determine which channel options to disable on the UI for that specialty.
     * Each channel requires a different capacity from an agent (Chat = 5) so this calculates the least busy (least amount of currently assigned cases) specialist by capacity and returns their total capacity to determine which channels to display as available.
     * For example, if the least busy specialist only has one Chat case assigned, they would have a remaining 15 capacity of their 20 max total so only Chat options would be available as options.
     * NOTE: Capacity is planned for deprecation - All specialists will only handle one case at a time regardless of channel type in the future
     * @param userIds  User ids of specialist (agent) users
     * @param agentCapacity Holds a capacity weight value that the specialist (agent) is already handling (currently, max is 20 set by Omni Channel rules)
     * @return Decimal the lowest total capacity of all specialist (agents) in the provided set
     */
    public static Decimal getMinCapacity(Set<Id> userIds, Map<Id, Decimal> agentCapacity) {
        Decimal min = 20.0;
        for (Id userId : userIds) {
            Decimal cap = agentCapacity.containsKey(userId) ? agentCapacity.get(userId) : 0;
            if (cap < min) {
                min = cap;
            }
        }
        return min;
    }

    /**
     * @description   Generates a map of skill to channel presence types for determination of which skills/channels to disable in the UI.
     * @param skillsAndUsers Map of skills to the specialist (agent) users with those skills
     * @param agentCapacity  Map of specilist (agent) omni-channel capacity for each user
     * @return               `Map<String, Map<String, Boolean>>`  map of skill to presence for each channel type (chat)
     */
    public static Map<String, Map<String, Boolean>> getChannelPresence(
        Map<String, Set<Id>> skillsAndUsers,
        Map<Id, Decimal> agentCapacity
    ) {
        Map<String, Map<String, Boolean>> skillsAndChannelPresence = new Map<String, Map<String, Boolean>>();

        for (String skill : skillsAndUsers.keySet()) {
            skillsAndChannelPresence.put(skill, new Map<String, Boolean>{ CHAT_SKILL => false });
            for (Id userId : skillsAndUsers.get(skill)) {
                Decimal cap = agentCapacity.containsKey(userId) ? agentCapacity.get(userId) : 0;

                if (
                    cap == 0 &&
                    skillsAndUsers.containsKey(CHAT_SKILL) &&
                    skillsAndUsers.get(CHAT_SKILL).contains(userId)
                ) {
                    skillsAndChannelPresence.get(skill).put(CHAT_SKILL, true);
                }
            }
        }

        return skillsAndChannelPresence;
    }

    /**
     * @description    Method to get the assigned specialist of the case
     * @param agentWorkRec   String value of the ProviderConnect Case
     * @return Map<String,Object> - Map containing the agent information as 'agent' and PC_Chat_Session__c record Id as 'chatId'
     **/
    public static Map<String, Object> getAgentInfoMap(AgentWork agentWorkRec) {
        //Check if same user, will throw error if share record already exist
        if (agentWorkRec.UserId != UserInfo.getUserId()) {
            //Grant access to the FLP. Access is removed when case is routed to agent since agent is the new owner of the record
            PC_ProviderConnectControllerSystemHelper.createPcCaseShareForUser(
                agentWorkRec.WorkItemId,
                UserInfo.getUserId()
            );
        }

        String chatId = null;
        PC_Case__c pcCase = (PC_Case__c) prcCaseRepo.fetchById(
            agentWorkRec.WorkItemId,
            new Set<String>{ 'Id', 'Channel__c' }
        );
        if (pcCase != null) {
            PC_Chat_Session__c chatSession = ((List<PC_Chat_Session__c>) pcChatSessionRepo.fetchPcChatSessionByPrcCaseId(
                    agentWorkRec.WorkItemId
                ))
                ?.get(0);
            chatId = chatSession.Id;
            createNewChatCache(chatId);
        }

        User agent = (User) userRepo.fetchById(
            agentWorkRec.UserId,
            new Set<String>{
                'Id',
                'Name',
                'MediumPhotoUrl',
                'Email',
                'Street',
                'City',
                'State',
                'PostalCode',
                'Title',
                'Department',
                'Division'
            }
        );

        return new Map<String, Object>{ 'agent' => agent, 'chatId' => chatId };
    }

    /**
     * @description   Creates a new org partition cache for a PC Chat Session
     * @param chatSessionId   SF Id of the PC Chat Session record
     */
    @TestVisible
    private static void createNewChatCache(String chatSessionId) {
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.pcChat');
        orgPart.put(chatSessionId, new PC_CacheResults());
    }

    /**
     * @description    Method to determine if the The Specialist the User selected is Available
     * @param desiredSkillStatus   Status(wrapper) of the PrC Case to be created
     * @param isGeneralCase   Boolean value of the PrC Case's isGeneral field, used to determine which disabled field to pull Avaiability from
     * @return isUnavailable   Boolean to denotes if the Specialist is Avaiable or not
     */
    public static Boolean checkUnavailableValue(
        PC_ProviderConnectController.SkillStatus desiredSkillStatus,
        Boolean isGeneralCase
    ) {
        Boolean isGeneralUnavailable = desiredSkillStatus?.generalDisabled ?? false;
        Boolean isPatientSpecificUnavailable = desiredSkillStatus?.patientSpecificDisabled ?? false;

        Boolean isUnavailable = isGeneralCase ? isGeneralUnavailable : isPatientSpecificUnavailable;

        if (isUnavailable) {
            throw new PC_CustomException(System.Label.PC_Specialist_No_Longer_Available);
        }

        return isUnavailable;
    }
}
