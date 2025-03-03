public with sharing class VCC_ProgressNoteConfigSelector extends fflib_SObjectSelector {
    private List<Schema.SObjectField> sObjectFields = new List<Schema.SObjectField>{
        VCC_Progress_Note_Configuration__mdt.VCC_Creates_Encounter__c,
        VCC_Progress_Note_Configuration__mdt.VCC_Enable_Visit_Related_Tos__c,
        VCC_Progress_Note_Configuration__mdt.VCC_Enable_Primary_Diagnosis__c,
        VCC_Progress_Note_Configuration__mdt.VCC_Enable_Secondary_Diagnosis__c,
        VCC_Progress_Note_Configuration__mdt.VCC_Enable_Procedure_Code__c,
        VCC_Progress_Note_Configuration__mdt.VCC_Emphasized_Sections__c,
        VCC_Progress_Note_Configuration__mdt.VCC_Excluded_Page_Layout_Sections__c,
        VCC_Progress_Note_Configuration__mdt.VCC_Include_Layout_Spaces__c,
        VCC_Progress_Note_Configuration__mdt.VCC_Page_Layout_Name__c,
        VCC_Progress_Note_Configuration__mdt.VCC_Personas__c,
        VCC_Progress_Note_Configuration__mdt.VCC_Record_Type_API_Name__c,
        VCC_Progress_Note_Configuration__mdt.VCC_VistA_Note_Title__c
    };

    public Schema.SObjectType getSObjectType() {
        return VCC_Progress_Note_Configuration__mdt.SObjectType;
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

    public List<VCC_Progress_Note_Configuration__mdt> selectByIds(Set<Id> ids) {
        return (List<VCC_Progress_Note_Configuration__mdt>) selectSObjectsById(ids);
    }

    public VCC_Progress_Note_Configuration__mdt selectByRecordTypeAPIName(String recTypeName) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('VCC_Record_Type_API_Name__c = :recTypeName');
        List<VCC_Progress_Note_Configuration__mdt> configs = Database.query(query.toSOQL());
        return (configs != null && configs.size() == 1) ? configs[0] : null;
    }

    public VCC_Progress_Note_Configuration__mdt selectByName(String name) {
        return VCC_Progress_Note_Configuration__mdt.getInstance(name);
    }
}
