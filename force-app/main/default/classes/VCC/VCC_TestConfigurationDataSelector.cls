public with sharing class VCC_TestConfigurationDataSelector extends fflib_SObjectSelector {
    private List<Schema.SObjectField> sObjectFields = new List<Schema.SObjectField>{
        VCC_Test_Configuration_Data__c.Id,
        VCC_Test_Configuration_Data__c.RecordTypeId,
        VCC_Test_Configuration_Data__c.VCC_Account_Id__c,
        VCC_Test_Configuration_Data__c.VCC_Addendum_IEN__c,
        VCC_Test_Configuration_Data__c.VCC_Additional_Signer_IEN__c,
        VCC_Test_Configuration_Data__c.VCC_Diagnosis_Codes__c,
        VCC_Test_Configuration_Data__c.VCC_ICN__c,
        VCC_Test_Configuration_Data__c.VCC_Location_IEN__c,
        VCC_Test_Configuration_Data__c.VCC_Note_Text__c,
        VCC_Test_Configuration_Data__c.VCC_Note_Title_IEN__c,
        VCC_Test_Configuration_Data__c.VCC_Note_Title_IEN_For_Encounter__c,
        VCC_Test_Configuration_Data__c.VCC_Org_Type__c,
        VCC_Test_Configuration_Data__c.VCC_Procedure_Codes__c,
        VCC_Test_Configuration_Data__c.VCC_Service__c,
        VCC_Test_Configuration_Data__c.VCC_Site_Code__c,
        VCC_Test_Configuration_Data__c.VCC_Visit_Related_Tos__c,
        VCC_Test_Configuration_Data__c.VCC_VISN__c
    };

    public Schema.SObjectType getSObjectType() {
        return VCC_Test_Configuration_Data__c.SObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return this.sObjectFields;
    }

    public void addSObjectFields(List<Schema.SObjectField> sObjectFields) {
        if (sObjectFields != null && !sObjectFields.isEmpty()) {
            for (Schema.SObjectField field : sObjectFields) {
                if (!this.sObjectFields.contains(field)) {
                    this.sObjectFields.add(field);
                }
            }
        }
    }

    public List<VCC_Test_Configuration_Data__c> selectVdifTestPatientData(List<String> sites) {
        Id recordTypeId = VCC_Test_Configuration_Data__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Vdif_Test_Patient').getRecordTypeId();
        String orgType = (new VCC_OrgSettingsSelector()).selectByOrgId(UserInfo.getOrganizationId()).vccType__c;

        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('VCC_Site_Code__c IN :sites AND RecordTypeId = :recordTypeId AND VCC_Org_Type__c = :orgType');
        query.setOrdering('VCC_Service__c', fflib_QueryFactory.SortOrder.DESCENDING);

        return Database.query(query.toSOQL());
    }

    public List<VCC_Test_Configuration_Data__c> selectVdifTestPatientDataByServiceAndSite(String site, String service) {
        Id recordTypeId = VCC_Test_Configuration_Data__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Vdif_Test_Patient').getRecordTypeId();
        String orgType = (new VCC_OrgSettingsSelector()).selectByOrgId(UserInfo.getOrganizationId()).vccType__c;

        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('VCC_Site_Code__c = :site AND RecordTypeId =:recordTypeId AND VCC_Org_Type__c =:orgType AND VCC_Service__c = :service');

        return Database.query(query.toSOQL());
    }
}
