public with sharing class VCC_LoincCodeSelector extends fflib_SObjectSelector {
    private List<Schema.SObjectField> sObjectFields = new List<Schema.SObjectField>{
        VCC_Loinc__mdt.DeveloperName,
        VCC_Loinc__mdt.VCC_Loinc_Code__c,
        VCC_Loinc__mdt.VCC_Loinc_Component_Name__c,
        VCC_Loinc__mdt.VCC_Loinc_Shortname__c
    };

    public Schema.SObjectType getSObjectType() {
        return VCC_Loinc__mdt.SObjectType;
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

    public List<VCC_Loinc__mdt> selectAll() {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('DeveloperName  != null');
        return (List<VCC_Loinc__mdt>) Database.query(query.toSOQL());
    }
}
