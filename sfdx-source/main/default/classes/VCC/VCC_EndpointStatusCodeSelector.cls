/**
 * @description - Class is responsible for querying Salesforce Metadata objects
 * 'VCC_Endpoint_Status_Code__mdt' in different ways based on the use case.
 * Note: This class extends from the fflib_SObjectSelector which provides a base template for creating selector classes.
 */
public with sharing class VCC_EndpointStatusCodeSelector extends fflib_SObjectSelector {
    private List<Schema.SObjectField> sObjectFields = new List<Schema.SObjectField>{
        VCC_Endpoint_Status_Code__mdt.Id,
        VCC_Endpoint_Status_Code__mdt.VCC_Endpoint__c,
        VCC_Endpoint_Status_Code__mdt.VCC_Endpoint_Status_Code_Configuration__c,
        VCC_Endpoint_Status_Code__mdt.VCC_Status_Code__c
    };
    /**
     * @description the SObjectType of 'VCC_Endpoint_Status_Code__mdt' object
     *
     * @return Schema.SObjectType : the SObjectType of 'VCC_Endpoint_Status_Code__mdt'``
     */
    public Schema.SObjectType getSObjectType() {
        return VCC_Endpoint_Status_Code__mdt.SObjectType;
    }
    /**
     * @description the list of fields that we want to select in the SOQL query.
     *
     * @return List<Schema.SObjectField> : list of fields that we want to select in the SOQL query.
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return this.sObjectFields;
    }
    /**
     * @description fields to current SObjectField list only if they are not already in the list.
     *
     * @param sObjectFields - list of fields to be added
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
     * @description list of `VCC_Endpoint_Status_Code__mdt` records by given Ids.
     *
     * @param ids Set of record Ids
     * @return List of `VCC_Endpoint_Status_Code__mdt` records
     */
    public List<VCC_Endpoint_Status_Code__mdt> selectById(Set<Id> ids) {
        return (List<VCC_Endpoint_Status_Code__mdt>) selectSObjectsById(ids);
    }
    /**
     * @description `VCC_Endpoint_Status_Code__mdt` records by endpoint name.
     *
     * @param endpointName endpoint developer name
     * @return List of `VCC_Endpoint_Status_Code__mdt` records
     */
    public List<VCC_Endpoint_Status_Code__mdt> selectByEndpointName(String endpointName) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('VCC_Endpoint__r.DeveloperName = :endpointName');
        return Database.query(query.toSOQL());
    }
    /**
     * @description `VCC_Endpoint_Status_Code__mdt` records by endpoint name and status code.
     *
     * @param statusCode The status code
     * @param endpointName endpoint developer name
     * @return List of `VCC_Endpoint_Status_Code__mdt` records
     */
    public List<VCC_Endpoint_Status_Code__mdt> selectByCodeAndEndpoint(Integer statusCode, String endpointName) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('VCC_Endpoint_Status_Code_Configuration__r.Id');
        query.setCondition('VCC_Endpoint__r.DeveloperName = :endpointName ' + 'AND VCC_App_Name__c = null ' + 'AND VCC_Status_Code__r.VCC_Status_Code__c = :statusCode');
        return Database.query(query.toSOQL());
    }
    /**
     * @description Retrieves `VCC_Endpoint_Status_Code__mdt` records by application name and status code.
     *
     * @param statusCode Application status code
     * @param appName Application name
     * @return List of `VCC_Endpoint_Status_Code__mdt` records
     */
    public List<VCC_Endpoint_Status_Code__mdt> selectByCodeAndApp(Integer statusCode, String appName) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('VCC_Endpoint_Status_Code_Configuration__r.Id');
        query.setCondition('VCC_Endpoint__c = null ' + 'AND VCC_App_Name__c = :appName ' + 'AND VCC_Status_Code__r.VCC_Status_Code__c = :statusCode');
        return Database.query(query.toSOQL());
    }
    /**
     * @description global `VCC_Endpoint_Status_Code__mdt` records by status code.
     *
     * @param statusCode The status code
     * @return List of global `VCC_Endpoint_Status_Code__mdt` records
     */

    public List<VCC_Endpoint_Status_Code__mdt> selectGlobalByCode(Integer statusCode) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('VCC_Endpoint_Status_Code_Configuration__r.Id');
        query.setCondition('VCC_Endpoint__c = null ' + 'AND VCC_App_Name__c = null ' + 'AND VCC_Status_Code__r.VCC_Status_Code__c = :statusCode');
        return Database.query(query.toSOQL());
    }
}
