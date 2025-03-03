public with sharing class VCC_ProgressNoteSelector extends fflib_SObjectSelector {
    private List<Schema.SObjectField> sObjectFields = new List<Schema.SObjectField>{
        VCC_Progress_Note__c.Id,
        VCC_Progress_Note__c.VCC_Patient_ICN__c,
        VCC_Progress_Note__c.RecordTypeId,
        VCC_Progress_Note__c.VCC_Case__c
    };

    public Schema.SObjectType getSObjectType() {
        return VCC_Progress_Note__c.SObjectType;
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

    public List<VCC_Progress_Note__c> selectByIds(Set<Id> ids) {
        return (List<VCC_Progress_Note__c>) selectSObjectsById(ids);
    }
}
