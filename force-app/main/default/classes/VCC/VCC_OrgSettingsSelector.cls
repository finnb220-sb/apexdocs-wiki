/**
 * VCC_OrgSettingsSelector
 * @description Common selector for VCC_Org_Settings__mdt.
 * @author Liberty
 * @date 12/1/2021
 */
public with sharing class VCC_OrgSettingsSelector extends fflib_SObjectSelector {
    private List<Schema.SObjectField> sObjectFields = new List<Schema.SObjectField>{
        VCC_Org_Settings__mdt.Id,
        VCC_Org_Settings__mdt.DeveloperName,
        VCC_Org_Settings__mdt.Enable_SSO_Mocking__c,
        VCC_Org_Settings__mdt.Label,
        VCC_Org_Settings__mdt.Language,
        VCC_Org_Settings__mdt.MasterLabel,
        VCC_Org_Settings__mdt.NamespacePrefix,
        VCC_Org_Settings__mdt.QualifiedApiName,
        VCC_Org_Settings__mdt.vccIntegrationUser__c,
        VCC_Org_Settings__mdt.vccOrgId__c,
        VCC_Org_Settings__mdt.vccType__c
    };

    public Schema.SObjectType getSObjectType() {
        return VCC_Org_Settings__mdt.SObjectType;
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

    public List<VCC_Org_Settings__mdt> selectById(Set<Id> ids) {
        return (List<VCC_Org_Settings__mdt>) selectSObjectsById(ids);
    }

    public VCC_Org_Settings__mdt selectByOrgId(String orgId) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('vccOrgId__c = :orgId');

        List<VCC_Org_Settings__mdt> orgSettings = (List<VCC_Org_Settings__mdt>) Database.query(query.toSOQL());
        return (orgSettings != null && !orgSettings.isEmpty()) ? orgSettings[0] : null;
    }
}
