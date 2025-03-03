/**
 * VCC_TrainingModeDataTemplateSelector
 * @description Selector for Training Mode Template static resources.
 * @author Liberty
 * @date 12/9/2021
 *
 */

public with sharing class VCC_TrainingModeDataTemplateSelector extends fflib_SObjectSelector {
    private List<Schema.SObjectField> sObjectFields = new List<Schema.SObjectField>{ StaticResource.Id, StaticResource.Name, StaticResource.Body };

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
        return (List<StaticResource>) selectSObjectsById(ids);
    }

    public List<StaticResource> selectAll() {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Name LIKE \'VCC_TrainingTemplate%\'');
        return (List<StaticResource>) Database.query(query.toSOQL());
    }
}
