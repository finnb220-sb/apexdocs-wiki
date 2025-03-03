/**
 * VCC_TrainingModeDataSelector
 * @description Selector for VCC_Training_Mode_Data__c.
 * @author Liberty
 * @date 12/8/2021
 */
public with sharing class VCC_TrainingModeDataSelector extends fflib_SObjectSelector {
    private List<Schema.SObjectField> sObjectFields = new List<Schema.SObjectField>{
        VCC_Training_Mode_Data__c.Id,
        VCC_Training_Mode_Data__c.Account__c,
        VCC_Training_Mode_Data__c.Data__c,
        VCC_Training_Mode_Data__c.Name,
        VCC_Training_Mode_Data__c.Type__c
    };

    public Schema.SObjectType getSObjectType() {
        return VCC_Training_Mode_Data__c.SObjectType;
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

    public List<VCC_Training_Mode_Data__c> selectById(Set<Id> ids) {
        return (List<VCC_Training_Mode_Data__c>) selectSObjectsById(ids);
    }

    public List<VCC_Training_Mode_Data__c> selectByAccountId(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Account__c IN :accountIds');
        return (List<VCC_Training_Mode_Data__c>) Database.query(query.toSOQL());
    }

    public List<VCC_Training_Mode_Data__c> selectByAccountIdAndType(Id accountId, String type) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Account__c = :accountId AND Type__c = :type');
        return (List<VCC_Training_Mode_Data__c>) Database.query(query.toSOQL());
    }

    public List<VCC_Training_Mode_Data__c> selectMasterByAccountIdAndType(String accountId, String type) {
        // We need to use the AccountSelector because it includes the Name field.  We could add a PersonAccountSelector, but VCC_AccountSelector was already available.
        Account account = new VCC_AccountSelector().selectById(new Set<Id>{ accountId })[0];
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Account__r.Is_Training_Account__c = TRUE AND Type__c = :type AND Account__r.FirstName LIKE \'%' + account.Name.split(' ')[0] + '%\'');
        return (List<VCC_Training_Mode_Data__c>) Database.query(query.toSOQL());
    }
}
