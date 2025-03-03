/**
 * @description Repository class for the VCC_Clinic_Group__c object
 * @author Booz Allen Hamilton
 * @since 4/26/2024
 * @see VCC_ClinicGroupSearchController
 */
public with sharing class VCR_ClinicGroupRepo {
    /**
     * @description patient service memoization
     */
    public static VTC_PatientService patientService {
        get {
            return patientService = patientService ?? new VTC_PatientService();
        }
        set;
    }

    /**
     * @description performs va-teams-core-chro callout to /svas/clinicGroups to search for clinic groups
     * Given a String "groupName", this method will perform an API callout and return a list of clinic groups whose name starts with that string.
     * Org must have a ZD_ApplicationConfiguration metadata for 'search_clinic_groups' and the specified app name.
     * @param siteId The Site Id of the VistA instance/Facility where the Clinic Group is based
     * @param groupName The name of the Clinic Group
     * @param applicationName The ZD_Application name
     * @return `VTC_RecordModel`
     */
    public VTC_RecordModel searchClinicGroups(String siteId, String groupName, String applicationName) {
        return (VTC_RecordModel) patientService.call(
            'search_clinic_groups',
            this.mapSearchClinicGroupsArgs(siteId, groupName, applicationName)
        );
    }

    /**
     * @description performs va-teams-core-chro callout to /sas/clinicGroup.
     * Provides the clinic group and its clinic iens contained within (as opposed to just the group name and ien from searchClinicGroups)
     * Org must have a ZD_ApplicationConfiguration metadata for 'get_clinic_group' and the specified app name.
     * @param siteId The Site Id of the VistA instance/Facility where the Clinic Group is based
     * @param groupIen The ien of the clinic group
     * @param applicationName The ZD_Application name
     * @return `VTC_RecordModel`
     */
    public VTC_RecordModel getClinicGroupByIen(String siteId, String groupIen, String applicationName) {
        return (VTC_RecordModel) patientService.call(
            'get_clinic_group',
            this.mapGetClinicGroupArgs(siteId, groupIen, applicationName)
        );
    }

    @TestVisible
    private Map<String, Object> mapGetClinicGroupArgs(String siteId, String groupIen, String applicationName) {
        return new Map<String, Object>{ 'siteId' => siteId, 'groupIen' => groupIen, 'application' => applicationName };
    }

    @TestVisible
    private Map<String, Object> mapSearchClinicGroupsArgs(String siteId, String groupName, String applicationName) {
        return new Map<String, Object>{
            'siteId' => siteId,
            'searchString' => groupName,
            'application' => applicationName
        };
    }
}
