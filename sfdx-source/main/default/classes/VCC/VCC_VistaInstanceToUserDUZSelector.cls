public with sharing class VCC_VistaInstanceToUserDUZSelector extends fflib_SObjectSelector {
    private List<Schema.SObjectField> sObjectFields = new List<Schema.SObjectField>{
        IAM_SSOi_Vista_Instance_to_User_DUZ__c.Id,
        IAM_SSOi_Vista_Instance_to_User_DUZ__c.DUZ__c,
        IAM_SSOi_Vista_Instance_to_User_DUZ__c.User_Id__c,
        IAM_SSOi_Vista_Instance_to_User_DUZ__c.VistA_Instance__c
    };

    public Schema.SObjectType getSObjectType() {
        return IAM_SSOi_Vista_Instance_to_User_DUZ__c.SObjectType;
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

    public List<IAM_SSOi_Vista_Instance_to_User_DUZ__c> selectByIds(Set<Id> ids) {
        return (List<IAM_SSOi_Vista_Instance_to_User_DUZ__c>) selectSObjectsById(ids);
    }

    public List<IAM_SSOi_Vista_Instance_to_User_DUZ__c> selectByUserId(Id userId) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('User_Id__c = :userId');
        return (List<IAM_SSOi_Vista_Instance_to_User_DUZ__c>) Database.query(query.toSOQL());
    }

    public IAM_SSOi_Vista_Instance_to_User_DUZ__c selectByUserIdAndVistaInstance(Id userId, String vistaInstance) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('User_Id__c = :userId AND VistA_Instance__c = :vistaInstance AND (NOT Name LIKE \'mockSSO%\')');
        List<IAM_SSOi_Vista_Instance_to_User_DUZ__c> vistaToUserDuzs = (List<IAM_SSOi_Vista_Instance_to_User_DUZ__c>) Database.query(query.toSOQL());
        return (vistaToUserDuzs != null && !vistaToUserDuzs.isEmpty()) ? vistaToUserDuzs[0] : null;
    }

    public IAM_SSOi_Vista_Instance_to_User_DUZ__c selectByName(String name) {
        return IAM_SSOi_Vista_Instance_to_User_DUZ__c.getInstance(name);
    }
}
