public with sharing class VCC_HealthcareFacilitySelector extends fflib_SObjectSelector {
    private List<Schema.SObjectField> sObjectFields = new List<Schema.SObjectField>{
        HealthcareFacility.Id,
        HealthcareFacility.Name,
        HealthcareFacility.VCC_Site_Id__c,
        HealthcareFacility.VCC_Personas__c
    };

    public Schema.SObjectType getSObjectType() {
        return HealthcareFacility.SObjectType;
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

    public List<HealthcareFacility> selectByIds(Set<Id> ids) {
        return (List<HealthcareFacility>) selectSObjectsById(ids);
    }

    /**
     * @param siteId Three digit site ID.
     * @param personas Set of personas to filter by.
     * @return  `List<HealthcareFacility>` containing the results.
     */
    public List<HealthcareFacility> selectBySiteIdAndPersona(Integer siteId, Set<String> personas) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('VCC_Site_Id__c = :siteId AND VCC_Personas__c IN :personas');
        return Database.query(query.toSOQL());
    }
}
