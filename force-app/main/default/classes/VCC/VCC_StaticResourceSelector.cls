public with sharing class VCC_StaticResourceSelector extends fflib_SObjectSelector {
    private List<Schema.SObjectField> sObjectFields = new List<Schema.SObjectField>{ StaticResource.Id, StaticResource.Body, StaticResource.Name };

    public Schema.SObjectType getSObjectType() {
        return StaticResource.SObjectType;
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

    public List<StaticResource> selectById(Set<Id> ids) {
        if (ids == null || ids.isEmpty()) {
            throw new VCC_InternalException('You must provide 1 or more ids to select static resources by id.');
        }
        return (List<StaticResource>) selectSObjectsById(ids);
    }

    public List<StaticResource> selectByName(String name) {
        return this.selectByName(new Set<String>{ name });
    }

    public List<StaticResource> selectByName(Set<String> names) {
        if (names == null || names.isEmpty()) {
            throw new VCC_InternalException('You must provide 1 or more names to select static resources by name.');
        }

        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Name IN :names');
        return (List<StaticResource>) Database.query(query.toSOQL());
    }
}
