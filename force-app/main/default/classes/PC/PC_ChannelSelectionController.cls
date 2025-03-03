/**
 * @description Class is responsible for providing data to multiple LWC components and Apex classes for Provider Connect.
 * @author      Booz Allen Hamilton
 * @justification for complexity violations: This class's code was extracted directly from the PC_ProviderConnectController class and its related component is slated for deprecation in the foreseeable future. Refactoring this class would require resources' time that would be better spent elsewhere considering its future.
 */
public with sharing class PC_ChannelSelectionController {
    private final static String PC_CHAT_SKILL = 'PC_Chat';
    private final static String PC_PHONE_SKILL = 'PC_Phone';
    private final static String PC_TEAMS_SKILL = 'PC_Teams';
    private final static Integer BASE_SKILL_LEVEL = 1;

    /**
     * @description repository for Service Resource object
     */
    @TestVisible
    private static PC_ServiceResourceRepo serviceResourceRepo {
        get {
            return serviceResourceRepo = serviceResourceRepo ?? new PC_ServiceResourceRepo();
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
     * @description repository for Skill object
     */
    @TestVisible
    private static VCR_SkillRepo skillRepo {
        get {
            return skillRepo = skillRepo ?? new VCR_SkillRepo();
        }
        set;
    }

    /**
     * @description AvailableChannels wrapper
     **/
    public class AvailableChannels {
        @AuraEnabled
        public Boolean chat;
        @AuraEnabled
        public Boolean teams;
        @AuraEnabled
        public Boolean phone;
    }

    /**
     * @description Method to get the running user's current channel availability
     * @return AvailableChannels - Wrapper class used to store availability for each channel
     **/
    @AuraEnabled(cacheable=true)
    public static AvailableChannels getChannelAvailability() {
        try {
            List<String> lsChannelNames = new List<String>{ PC_PHONE_SKILL, PC_TEAMS_SKILL, PC_CHAT_SKILL };
            List<ServiceResource> lsSR = serviceResourceRepo.getServiceResourcesRunningUser();
            List<ServiceResourceSkill> lsSRS = serviceResourceSkillRepo.getServiceResourceSkillsExcluding(
                lsChannelNames
            );
            if (lsSR.isEmpty() || lsSRS.isEmpty()) {
                throw new PC_CustomException(
                    'You currently do not have a specialty assigned. Please contact your manager.'
                );
            }
            AvailableChannels availChannel = new AvailableChannels();
            availChannel.chat = false;
            availChannel.phone = false;
            availChannel.teams = false;

            for (
                ServiceResourceSkill channelServiceResourceSkill : serviceResourceSkillRepo.getServiceResourceSkillsIncluding(
                    lsChannelNames
                )
            ) {
                availChannel.teams = channelServiceResourceSkill.Skill.DeveloperName == PC_TEAMS_SKILL
                    ? true
                    : availChannel.teams;
                availChannel.chat = channelServiceResourceSkill.Skill.DeveloperName == PC_CHAT_SKILL
                    ? true
                    : availChannel.chat;
                availChannel.phone = channelServiceResourceSkill.Skill.DeveloperName == PC_PHONE_SKILL
                    ? true
                    : availChannel.phone;
            }

            return availChannel;
        } catch (PC_CustomException caughtCustomException) {
            Logger.info(
                'A problem occurred with PC_ChannelSelectionController.getChannelAvailability for user: ' +
                UserInfo.getName()
            );
            Logger.error(caughtCustomException.getMessage(), caughtCustomException);
            Logger.saveLog();
            throw createAuraHandledException(caughtCustomException.getMessage());
        } catch (QueryException caughtQueryException) {
            Logger.info(
                'A problem occurred with PC_ChannelSelectionController.getChannelAvailability for user: ' +
                UserInfo.getName()
            );
            Logger.error(caughtQueryException.getMessage(), caughtQueryException);
            Logger.saveLog();
            throw createAuraHandledException(caughtQueryException.getMessage());
        } catch (Exception caughtException) {
            Logger.info(
                'A problem occurred with PC_ChannelSelectionController.getChannelAvailability for user: ' +
                UserInfo.getName()
            );
            Logger.error(caughtException.getMessage(), caughtException);
            Logger.saveLog();
            throw createAuraHandledException(caughtException.getMessage());
        }
    }

    /**
     * @description Method to set the running user's channel availability
     * @param channel - String value of channel to change availability
     * @param channelAvailable - Boolean value of new channel availability
     * @return String - String containing message for user
     **/
    @AuraEnabled
    public static String setChannelAvailability(String channel, Boolean channelAvailable) {
        try {
            List<UserServicePresence> presence = userPresenceRepo.getCurrentUserServicePresenceForRunningUser();

            if (presence.size() > 0) {
                return 'Please log out of Omni-Channel before changing channel availability.';
            }

            if (!channelAvailable) {
                List<ServiceResourceSkill> srsList = serviceResourceSkillRepo.getServiceResourceSkillsByLabel(channel);

                PC_ChannelSelectionControllerSysHelper.performServiceResourceSkillSystemDelete(srsList);
            } else {
                Skill channelSkill = skillRepo.getSkillByLabel(channel);
                List<ServiceResourceSkill> srsList = new List<ServiceResourceSkill>();

                for (
                    ServiceResource runningUserServiceResource : serviceResourceRepo.getServiceResourcesRunningUser()
                ) {
                    srsList.add(
                        new ServiceResourceSkill(
                            SkillId = channelSkill.Id,
                            ServiceResourceId = runningUserServiceResource.Id,
                            EffectiveStartDate = Date.today(),
                            SkillLevel = BASE_SKILL_LEVEL
                        )
                    );
                }

                PC_ChannelSelectionControllerSysHelper.performServiceResourceSkillSystemInsert(srsList);
            }

            return 'success';
        } catch (DmlException caughtDMLException) {
            Logger.info(
                'A problem occurred with PC_ChannelSelectionController.setChannelAvailability for user: ' +
                    UserInfo.getName() +
                    ' with inputs: channel=' +
                    channel +
                    ' and channelAvailable=' +
                    channelAvailable
            );
            Logger.error(caughtDMLException.getMessage(), caughtDMLException);
            Logger.saveLog();
            throw createAuraHandledException(caughtDMLException.getMessage());
        } catch (QueryException caughtQueryException) {
            Logger.info(
                'A problem occurred with PC_ChannelSelectionController.setChannelAvailability for user: ' +
                    UserInfo.getName() +
                    ' with inputs: channel=' +
                    channel +
                    ' and channelAvailable=' +
                    channelAvailable
            );
            Logger.error(caughtQueryException.getMessage(), caughtQueryException);
            Logger.saveLog();
            throw createAuraHandledException(caughtQueryException.getMessage());
        } catch (Exception caughtException) {
            Logger.error(caughtException.getMessage(), caughtException);
            Logger.saveLog();
            throw createAuraHandledException(caughtException.getMessage());
        }
    }

    /**
     * @description            creates an AuraHandledException to throw while also using setMessage so that a detailed error message is shown in debug logsrather than "Script-thrown exception"
     * @param exceptionMessage The exception message to display to the use on the LWC (and in debug error logs)
     * @return                 `AuraHandledException` the generated AuraHandledException to throw
     */
    private static AuraHandledException createAuraHandledException(String exceptionMessage) {
        AuraHandledException auraExceptionToThrow = new AuraHandledException(exceptionMessage);
        auraExceptionToThrow.setMessage(exceptionMessage);
        return auraExceptionToThrow;
    }
}
