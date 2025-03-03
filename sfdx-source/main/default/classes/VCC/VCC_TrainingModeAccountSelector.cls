public with sharing class VCC_TrainingModeAccountSelector extends VCC_AccountSelector {
    public VCC_TrainingModeAccountSelector() {
        this.addSObjectFields(new List<Schema.SObjectField>{ Account.Is_Training_Account__c });
    }

    public List<Account> selectTrainingAccountsByOwnerIdWithCases(Set<Id> ownerIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('OwnerId IN :ownerIds AND Is_Training_Account__c = TRUE');
        new VCC_CaseSelector().addQueryFactorySubselect(query, 'Cases');
        return (List<Account>) Database.query(query.toSOQL());
    }

    public List<Account> selectMasterTrainingModeAccounts() {
        fflib_QueryFactory query = newQueryFactory();
        //query.setCondition('Is_Training_Account_Master__c = TRUE');
        return (List<Account>) Database.query(query.toSOQL());
    }
}
