/**
 * @description A Selector class for VCC_Endpoint_Status_Code_Range__mdt.
 * This class extends fflib_SObjectSelector and includes functionality for querying and
 * manipulating VCC_Endpoint_Status_Code_Range__mdt records.
 */
public with sharing class VCC_EndpointStatusCodeRangeSelector extends fflib_SObjectSelector {
    private List<Schema.SObjectField> sObjectFields = new List<Schema.SObjectField>{
        VCC_Endpoint_Status_Code_Range__mdt.Id,
        VCC_Endpoint_Status_Code_Range__mdt.VCC_Endpoint__c,
        VCC_Endpoint_Status_Code_Range__mdt.VCC_Endpoint_Status_Code_Configuration__c.Id,
        VCC_Endpoint_Status_Code_Range__mdt.VCC_Status_Code_Range__c,
        VCC_Endpoint_Status_Code_Range__mdt.VCC_App_Name__c
    };
    /**
     * @description Returns a new instance of the selector for VCC_Endpoint_Status_Code_Range__mdt
     * Return the SObjectType for the selector.
     *
     * @return Schema.SObjectType of VCC_Endpoint_Status_Code_Range__mdt
     */
    public Schema.SObjectType getSObjectType() {
        return VCC_Endpoint_Status_Code_Range__mdt.SObjectType;
    }
    /**
     * @description Returns a list of VCC_Endpoint_Status_Code_Range__mdt records.
     * Return the list of fields to be selected.
     *
     * @return List of Schema.SObjectField.
     */
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
    /**
     * @description VCC_Endpoint_Status_Code_Range__mdt records by Ids.
     *
     * @param ids Set of Id representing VCC_Endpoint_Status_Code_Range__mdt record ids.
     * @return List of VCC_Endpoint_Status_Code_Range__mdt objects
     */
    public List<VCC_Endpoint_Status_Code_Range__mdt> selectById(Set<Id> ids) {
        return (List<VCC_Endpoint_Status_Code_Range__mdt>) selectSObjectsById(ids);
    }
    /**
     * @description VCC_Endpoint_Status_Code_Range__mdt by Endpoint Name.
     *
     * @param endpointName Name of the endpoint.
     * @return List of VCC_Endpoint_Status_Code_Range__mdt objects.
     */
    public List<VCC_Endpoint_Status_Code_Range__mdt> selectByEndpointName(String endpointName) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('VCC_Endpoint__r.DeveloperName = :endpointName');
        return Database.query(query.toSOQL());
    }
    /**
     * @description VCC_Endpoint_Status_Code_Range__mdt by Code and Endpoint.
     *
     * @param statusCode Integer representing status code.
     * @param endpointName Name of the endpoint.
     * @return List of VCC_Endpoint_Status_Code_Range__mdt objects.
     */
    public List<VCC_Endpoint_Status_Code_Range__mdt> selectByCodeAndEndpoint(Integer statusCode, String endpointName) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('VCC_Endpoint_Status_Code_Configuration__r.Id');
        query.setCondition(
            'VCC_Endpoint__r.DeveloperName = :endpointName ' +
                'AND VCC_App_Name__c = null ' +
                'AND VCC_Status_Code_Range__r.VCC_Status_Code_Lower_Bound__c <= :statusCode ' +
                'AND VCC_Status_Code_Range__r.VCC_Status_Code_Upper_Bound__c >= :statusCode'
        );
        return Database.query(query.toSOQL());
    }
    /**
     * @description Select VCC_Endpoint_Status_Code_Range__mdt by Code and App.
     *
     * @param statusCode Integer representing status code.
     * @param appName Name of the app.
     * @return List of VCC_Endpoint_Status_Code_Range__mdt objects.
     */
    public List<VCC_Endpoint_Status_Code_Range__mdt> selectByCodeAndApp(Integer statusCode, String appName) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('VCC_Endpoint_Status_Code_Configuration__r.Id');
        query.setCondition(
            'VCC_Endpoint__c = null ' +
                'AND VCC_App_Name__c = :appName ' +
                'AND VCC_Status_Code_Range__r.VCC_Status_Code_Lower_Bound__c <= :statusCode ' +
                'AND VCC_Status_Code_Range__r.VCC_Status_Code_Upper_Bound__c >= :statusCode'
        );
        return Database.query(query.toSOQL());
    }
    /**
     * @description Global VCC_Endpoint_Status_Code_Range__mdt by Code.
     *
     * @param statusCode Integer representing status code.
     * @return List of VCC_Endpoint_Status_Code_Range__mdt objects.
     */
    public List<VCC_Endpoint_Status_Code_Range__mdt> selectGlobalByCode(Integer statusCode) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('VCC_Endpoint_Status_Code_Configuration__r.Id');
        query.setCondition(
            'VCC_Endpoint__c = null ' +
                'AND VCC_App_Name__c = null ' +
                'AND VCC_Status_Code_Range__r.VCC_Status_Code_Lower_Bound__c <= :statusCode ' +
                'AND VCC_Status_Code_Range__r.VCC_Status_Code_Upper_Bound__c >= :statusCode'
        );
        return Database.query(query.toSOQL());
    }
}
