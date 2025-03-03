/**
 * @description Helper class for PC_ChannelSelectionController that holds all code that needs to be run in system mode, without sharing
 * @author      Booz Allen Hamilton
 * @since       2024
 * @see         PC_ChannelSelectionController
 * @justification PrC Specialists require deleting/inserting ServiceResourceSkill records for the three channel skills ('Chat', 'Phone', 'Teams') in setChannelAvailability, but they only have Read Only sharing for the parent ServiceResources so system mode DML is required (see VCR_ServiceResourceSkillRepo for more detailed justification)
 */
public without sharing class PC_ChannelSelectionControllerSysHelper {
    /**
     * @description repository for Service Resource Skill junction object, with allowUnsafe = TRUE
     */
    @TestVisible
    private static PC_ServiceResourceSkillRepo serviceResourceSkillRepo {
        get {
            return serviceResourceSkillRepo = serviceResourceSkillRepo ?? new PC_ServiceResourceSkillRepo(true);
        }
        set;
    }

    /**
     * @description         Inserts a list of ServiceResourceSkill records in system context
     * @param srsInsertList List of ServiceResourceSkill records to insert
     */
    public static void performServiceResourceSkillSystemInsert(List<ServiceResourceSkill> srsInsertList) {
        serviceResourceSkillRepo.performCreateUnsafe(srsInsertList);
    }

    /**
     * @description         Deletes a list of ServiceResourceSkill records in system context
     * @param srsDeleteList List of ServiceResourceSkill records to delete
     */
    public static void performServiceResourceSkillSystemDelete(List<ServiceResourceSkill> srsDeleteList) {
        serviceResourceSkillRepo.performDeleteUnsafe(srsDeleteList);
    }
}
