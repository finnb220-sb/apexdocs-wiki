/**
 * @author Booz Allen Hamilton
 * @description DAS-related metadata retrieval class.
 */
public with sharing class VCC_DASServiceMetadata {
    @SuppressWarnings('PMD.ApexCRUDViolation') //supressing ApexCRUDViolation because USER_MODE
    /**
     * @description Gets progress note (and addendum) configuration from metadata.
     * @param recordTypeApiName `String`
     * @return `VCC_Progress_Note_Configuration_mdt`
     */
    public VCC_Progress_Note_Configuration__mdt getConfiguration(String recordTypeApiName) {
        return [
            SELECT
                VCC_Creates_Encounter__c,
                VCC_Emphasized_Sections__c,
                VCC_Enable_Primary_Diagnosis__c,
                VCC_Enable_Procedure_Code__c,
                VCC_Enable_Secondary_Diagnosis__c,
                VCC_Enable_Visit_Related_Tos__c,
                VCC_Excluded_Page_Layout_Sections__c,
                VCC_Include_Layout_Spaces__c,
                VCC_Page_Layout_Name__c,
                VCC_Personas__c,
                VCC_Record_Type_API_Name__c,
                VCC_Require_Primary_Diagnosis__c,
                VCC_Require_Procedure_Code__c,
                VCC_Require_Secondary_Diagnosis__c,
                VCC_VistA_Note_Title__c
            FROM VCC_Progress_Note_Configuration__mdt
            WHERE VCC_Record_Type_API_Name__c = :recordTypeApiName
            WITH USER_MODE
            LIMIT 1
        ];
    }

    @SuppressWarnings('PMD.ApexCRUDViolation') //supressing ApexCRUDViolation because USER_MODE
    /**
     * @description Gets progress note (and addendum) custom sections from metadata.
     * @param parentConfiguration `VCC_Progress_Note_Configuration__mdt` parent to the custom sections
     * @return `List<VCC_Progress_Note_Custom_Section__mdt>`
     */
    public List<VCC_Progress_Note_Custom_Section__mdt> getCustomSections(
        VCC_Progress_Note_Configuration__mdt parentConfiguration
    ) {
        return [
            SELECT Id, MasterLabel, VCC_Display_Section_Name__c, VCC_Fields__c, VCC_Progress_Note_Configuration__c
            FROM VCC_Progress_Note_Custom_Section__mdt
            WHERE VCC_Progress_Note_Configuration__c = :parentConfiguration.Id
            WITH USER_MODE
            LIMIT 20
        ];
    }

    @SuppressWarnings('PMD.ApexCRUDViolation') //supressing ApexCRUDViolation because USER_MODE
    public VCC_Site_Specific_Configuration__mdt getSiteSpecificConfiguration(Integer siteId, String orgType) {
        return [
            SELECT
                Id,
                DeveloperName,
                MasterLabel,
                VCC_SiteID__c,
                VCC_VISN__c,
                VCC_VistA_Environment__c,
                VCC_VistA_Integration__c
            FROM VCC_Site_Specific_Configuration__mdt
            WHERE VCC_VistA_Environment__c = :orgType AND VCC_SiteID__c = :siteId
            WITH USER_MODE
            LIMIT 1
        ];
    }

    @SuppressWarnings('PMD.ApexCRUDViolation') //supressing ApexCRUDViolation because USER_MODE
    public VCC_Org_Settings__mdt getOrgSettings() {
        return [
            SELECT Id, DeveloperName, MasterLabel, Enable_SSO_Mocking__c, vccIntegrationUser__c, vccOrgId__c, vccType__c
            FROM VCC_Org_Settings__mdt
            WHERE vccOrgId__c = :UserInfo.getOrganizationId()
            WITH USER_MODE
            LIMIT 1
        ];
    }
}
