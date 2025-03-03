/**
 * @description Provides searching and return of healthcare facilities.
 * @author Booz Allen Hamilton
 * @group Object - VCC_Progress_Note__c
 */
public with sharing class VCC_LookupController {
    @TestVisible
    private static VCC_HealthcareFacilitySelector healthcareFacilitySelector = new VCC_HealthcareFacilitySelector();
    @TestVisible
    private static VCC_ProgressNoteConfigSelector progressNoteConfigurationSelector = new VCC_ProgressNoteConfigSelector();

    /**
     * @description aura enabled search function
     * @param siteId site id to use when searching
     * @param searchParam parameters to use when searching
     * @param persona the persona of the current user
     *
     * @return `List<SObject>` generic list of information for the configuration and facilities
     */
    @AuraEnabled
    public static List<SObject> findRecords(String siteId, String searchParam, String persona) {
        VCC_Progress_Note_Configuration__mdt progressNoteConfiguration = progressNoteConfigurationSelector.selectByRecordTypeAPIName(
            persona
        );

        List<HealthcareFacility> healthcareFacilityList = new List<HealthcareFacility>();
        if (progressNoteConfiguration != null) {
            healthcareFacilitySelector.addSObjectFields(new List<SObjectField>{ HealthcareFacility.VCC_VISN__c });
            healthcareFacilityList = healthcareFacilitySelector.selectBySiteIdAndPersona(
                Integer.valueOf(siteId),
                VCC_String_Utilities.splitUnique(progressNoteConfiguration.VCC_Personas__c, ',')
            );
        }

        return healthcareFacilityList;
    }
}
