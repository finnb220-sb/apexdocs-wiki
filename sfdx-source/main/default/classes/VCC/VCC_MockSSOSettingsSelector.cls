public with sharing class VCC_MockSSOSettingsSelector extends fflib_SObjectSelector {
    private List<Schema.SObjectField> sObjectFields = new List<Schema.SObjectField>{
        VCC_Mock_SSO_Settings__c.Id,
        VCC_Mock_SSO_Settings__c.SetupOwnerId,
        VCC_Mock_SSO_Settings__c.VCC_DUZ__c,
        VCC_Mock_SSO_Settings__c.VCC_VistA_Instance__c,
        VCC_Mock_SSO_Settings__c.VCC_SSO_Token__c
    };

    public Schema.SObjectType getSObjectType() {
        return VCC_Mock_SSO_Settings__c.SObjectType;
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

    public List<VCC_Mock_SSO_Settings__c> selectByIds(Set<Id> ids) {
        return (List<VCC_Mock_SSO_Settings__c>) selectSObjectsById(ids);
    }

    public VCC_Mock_SSO_Settings__c selectByUserId(Id userId) {
        VCC_Mock_SSO_Settings__c mockSSOSetting;
        if (userId.getSObjectType() == User.SObjectType) {
            mockSSOSetting = VCC_Mock_SSO_Settings__c.getInstance(userId);
        }
        return (mockSSOSetting?.Id != null) ? mockSSOSetting : null;
    }

    public VCC_Mock_SSO_Settings__c selectByProfileId(Id profileId) {
        VCC_Mock_SSO_Settings__c mockSSOSetting;
        if (profileId.getSObjectType() == Profile.SObjectType) {
            mockSSOSetting = VCC_Mock_SSO_Settings__c.getInstance(profileId);
        }
        return (mockSSOSetting?.Id != null) ? mockSSOSetting : null;
    }

    public VCC_Mock_SSO_Settings__c selectOrgDefault() {
        VCC_Mock_SSO_Settings__c mockSSOSetting = VCC_Mock_SSO_Settings__c.getOrgDefaults();
        return (mockSSOSetting?.Id != null) ? mockSSOSetting : null;
    }
}
