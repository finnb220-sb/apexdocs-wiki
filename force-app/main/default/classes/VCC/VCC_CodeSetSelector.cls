public with sharing class VCC_CodeSetSelector extends fflib_SObjectSelector {
    private List<Schema.SObjectField> sObjectFields = new List<Schema.SObjectField>{
        CodeSet.Id,
        CodeSet.Code,
        CodeSet.CodeSetType,
        CodeSet.CodeDescription,
        CodeSet.VCC_Description__c
    };

    public Schema.SObjectType getSObjectType() {
        return CodeSet.SObjectType;
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

    public List<CodeSet> selectByIds(Set<Id> ids) {
        return (List<CodeSet>) selectSObjectsById(ids);
    }
}
