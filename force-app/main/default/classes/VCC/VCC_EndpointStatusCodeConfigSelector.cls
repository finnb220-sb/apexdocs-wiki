/**
 * @description This class is responsible for selecting VCC_Endpoint_Status_Code_Configuration metadata configurations
 */
public with sharing class VCC_EndpointStatusCodeConfigSelector extends fflib_SObjectSelector {
    // Define a list of fields on the metadata configuration
    private List<Schema.SObjectField> sObjectFields = new List<Schema.SObjectField>{
        VCC_Endpoint_Status_Code_Configuration__mdt.Id,
        VCC_Endpoint_Status_Code_Configuration__mdt.VCC_Illustration_Variant__c,
        VCC_Endpoint_Status_Code_Configuration__mdt.VCC_Message__c,
        VCC_Endpoint_Status_Code_Configuration__mdt.VCC_SubMessage__c,
        VCC_Endpoint_Status_Code_Configuration__mdt.VCC_Type__c
    };

    /**
     * @description Returns the SObjectType for the metadata configuration
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return VCC_Endpoint_Status_Code_Configuration__mdt.SObjectType;
    }

    /**
     * @description Returns the list of SObjectFields for the metadata configuration
     * @return List of SObjectFields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return this.sObjectFields;
    }

    /**
     * @description Add the given list of SObjectFields to the class field list if they are not already present
     * @param sObjectFields List of SObjectFields to be added
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
     * @description Selects the list of VCC_Endpoint_Status_Code_Configuration__mdt records by their IDs
     * @param ids Set of IDs for the records to be selected
     * @return List of VCC_Endpoint_Status_Code_Configuration__mdt records
     */
    public List<VCC_Endpoint_Status_Code_Configuration__mdt> selectById(Set<Id> ids) {
        return (List<VCC_Endpoint_Status_Code_Configuration__mdt>) selectSObjectsById(ids);
    }
}
