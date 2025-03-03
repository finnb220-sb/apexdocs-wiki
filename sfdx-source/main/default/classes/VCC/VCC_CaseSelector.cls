/**
 * VCC_CaseSelector
 * @description Selector for Cases.
 * @author Liberty
 * @date 12/21/2021
 */

public with sharing class VCC_CaseSelector extends fflib_SObjectSelector {
    private List<Schema.SObjectField> sObjectFields = new List<Schema.SObjectField>{
        Case.Id,
        Case.OwnerId,
        Case.AccountId,
        Case.ContactId,
        Case.Subject,
        Case.Status,
        Case.Description,
        Case.VCC_Caller_Relation__c,
        Case.VCC_Relation_Type_Other__c,
        Case.VCC_Caller_Name__c
    };

    public Schema.SObjectType getSObjectType() {
        return Case.SObjectType;
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

    public List<Case> selectById(Set<Id> ids) {
        return (List<Case>) selectSObjectsById(ids);
    }
}
