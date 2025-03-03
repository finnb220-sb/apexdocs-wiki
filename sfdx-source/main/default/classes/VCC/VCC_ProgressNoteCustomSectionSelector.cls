/**
 * @description This class is used to build selector queries against the VCC_Progress_Note_Custom_Section__mdt metadata type
 *
 * @techdebt This class uses ffsLib. It should be refactored to use Repositories.
 */
public with sharing class VCC_ProgressNoteCustomSectionSelector extends fflib_SObjectSelector {
    /**
     * In the FFSLib framework, the sObjectFields property is used to define the fields that are queried in the SELECT statement.
     * @note SOQL can only sort against fields included in the query. A bug was raised about sorting not working correctly
     * in VAHC sign progress notes. The code listed the 'DeveloperName' as the sorting field, but it was not included here.
     *
     * This is final. Though unintuitive, collections can be final, but their contents can be mutated.
     */
    private final List<Schema.SObjectField> sObjectFields = new List<Schema.SObjectField>{
        VCC_Progress_Note_Custom_Section__mdt.Id,
        VCC_Progress_Note_Custom_Section__mdt.MasterLabel,
        VCC_Progress_Note_Custom_Section__mdt.VCC_Display_Section_Name__c,
        VCC_Progress_Note_Custom_Section__mdt.VCC_Fields__c,
        VCC_Progress_Note_Custom_Section__mdt.VCC_Progress_Note_Configuration__c,
        VCC_Progress_Note_Custom_Section__mdt.VCC_Sort_Order__c
    };

    /**
     * @description Returns the SObjectType of the metadata type
     * @return the SObjectType of the metadata type, in this case VCC_Progress_Note_Custom_Section__mdt
     *
     * Note: I would hate ffslib less if I could just define this as a constant.
     */
    public Schema.SObjectType getSObjectType() {
        return VCC_Progress_Note_Custom_Section__mdt.SObjectType;
    }

    /**
     * @description Gets the order by field name.
     * NOTE: this only works if the field returned here is also in the sObjectFields list.
     * @return      `String` The field name to order by.
     */
    public override String getOrderBy() {
        return 'VCC_Sort_Order__c';
    }

    /**
     * @description Returns the list of fields queried in the SELECT statement.
     * @return List<Schema.sObjectField> The list of fields queried in the SELECT statement.
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return this.sObjectFields;
    }

    /**
     * @description Adds a list of fields to the sObjectFields list.
     * @note The sObjectFields list above is not final, because this method mutates it.
     * @param sObjectFields List<Schema.sObjectField> The list of fields to add to the sObjectFields list.
     */
    public void addSObjectFields(List<Schema.SObjectField> sObjectFields) {
        if (sObjectFields != null && !sObjectFields.isEmpty()) {
            for (Schema.SObjectField field : sObjectFields) {
                if (!this.sObjectFields.contains(field)) {
                    this.sObjectFields.add(field);
                }
            }
        }
    }

    /**
     * @description Selects a list of VCC_Progress_Note_Custom_Section__mdt records by their Ids.
     * @param ids Set<Id> The set of Ids to select.
     *
     * @return List<VCC_Progress_Note_Custom_Section__mdt> The list of VCC_Progress_Note_Custom_Section__mdt records.
     */
    public List<VCC_Progress_Note_Custom_Section__mdt> selectByIds(Set<Id> ids) {
        return (List<VCC_Progress_Note_Custom_Section__mdt>) selectSObjectsById(ids);
    }

    /**
     * @description Selects a list of VCC_Progress_Note_Custom_Section__mdt records by their parent configuration Id.
     * @param configId Id The Id of the parent configuration.
     *
     * @return List<VCC_Progress_Note_Custom_Section__mdt> The list of VCC_Progress_Note_Custom_Section__mdt records.
     */
    public List<VCC_Progress_Note_Custom_Section__mdt> selectByParentConfigId(Id configId) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('VCC_Progress_Note_Configuration__c = :configId');
        List<VCC_Progress_Note_Custom_Section__mdt> configs = Database.query(query.toSOQL());
        return configs;
    }
}
