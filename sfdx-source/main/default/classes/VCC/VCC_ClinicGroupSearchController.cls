/**
 * @description VCC_ClinicGroupSearchController is responsible for returning queried VCC_Clinic_Group__c records to the vccClinicGroupLookup lwc
 * @author Booz Allen Hamilton
 * @since 5/1/2024
 * @see VCR_ClinicGroupRepo
 * @see VCC_ClinicGroupSearchControllerTest
 */
public with sharing class VCC_ClinicGroupSearchController {
    @TestVisible
    private static final String VAHC_APPLICATION_NAME = 'VAHC';

    /**
     * @description setting the clinicGroupRepo to query VCC_Clinic_Group__c records
     */
    @TestVisible
    private static VCR_ClinicGroupRepo clinicGroupRepo {
        get {
            return clinicGroupRepo = clinicGroupRepo ?? new VCR_ClinicGroupRepo();
        }
        private set;
    }

    /**
     * @description searchClinicGroups is the entry point for the lwc to search Clinic Groups
     * @param siteId The facility station id that represents the facility/VISN Id
     * @param groupName The name of the group to search for
     * @return          `List<VTC_Record>`
     */
    @AuraEnabled(Cacheable=true)
    public static List<VTC_Record> searchClinicGroups(String siteId, String groupName) {
        return clinicGroupRepo.searchClinicGroups(siteId, groupName, VAHC_APPLICATION_NAME)?.records;
    }

    /**
     * @description searchClinicGroups is the entry point for the lwc to search Clinic Groups
     * @param siteId The facility station id that represents the facility/VISN Id
     * @param groupIen the ien of the clinic group you want
     * @return          `List<VTC_Record>`
     */
    @AuraEnabled
    public static VTC_Record getClinicGroup(String siteId, String groupIen) {
        return clinicGroupRepo.getClinicGroupByIen(siteId, groupIen, VAHC_APPLICATION_NAME)?.records?.get(0);
    }
}
