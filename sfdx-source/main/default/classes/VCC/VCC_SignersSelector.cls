public with sharing class VCC_SignersSelector extends fflib_SObjectSelector {
    private List<Schema.SObjectField> sObjectFields = new List<Schema.SObjectField>{
        VCC_Signers__c.Id,
        VCC_Signers__c.Name,
        VCC_Signers__c.VCC_Title__c,
        VCC_Signers__c.VCC_Role__c,
        VCC_Signers__c.VCC_Location__c,
        VCC_Signers__c.VCC_DUZ__c
    };

    public Schema.SObjectType getSObjectType() {
        return VCC_Signers__c.SObjectType;
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

    public List<VCC_Signers__c> selectSignersByAddendumId(Id addendumId) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('VCC_Addendum__c =: addendumId');

        return Database.query(query.toSOQL());
    }

    public List<VCC_Signers__c> selectSignersByProgressNoteId(Id progressNoteId) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('VCC_Progress_Note__c =: progressNoteId');

        return Database.query(query.toSOQL());
    }
}
