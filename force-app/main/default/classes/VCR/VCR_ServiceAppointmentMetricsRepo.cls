/**
 * @description       : This is a repository class that is used to fetch or put data related to Service Appointment Metrics custom object.
 * @author BAH
 * @see VCC_ServiceAppointmentMetrics
 * @see VCC_Service_Appointment_Metrics__c
 */
public inherited sharing class VCR_ServiceAppointmentMetricsRepo extends VTC_BaseRepo {
    private static final Set<String> DEFAULT_FIELDS = new Set<String>{
        'Case__c',
        'Case_Metrics__c',
        'CreatedById',
        'CreatedDate',
        'Id',
        'IsDeleted',
        'LastModifiedById',
        'LastModifiedDate',
        'Name',
        'Service_Appointment__c'
    };
    /**
     * @description constructor
     */
    public VCR_ServiceAppointmentMetricsRepo() {
        super(VCC_Service_Appointment_Metrics__c.SObjectType);
        this.defaultSelectFields.addAll(DEFAULT_FIELDS);
    }

    /**
     * @description       : This method is used to fetch the Service Appointment Metrics record by the Service Appointment record id.
     * @param recordId     : Record id to be used in the where clause.
     * @return VCC_Service_Appointment_Metrics__c : Service Appointment Metrics record.
     */
    public VCC_Service_Appointment_Metrics__c getServiceAppointmentMetricsByServiceAppointmentId(String recordId) {
        return this.getServiceAppointmentMetricsByField('Service_Appointment__c', recordId);
    }

    /**
     * @description       : This method is used to upsert the Service Appointment Metrics record.
     * @param serviceAppointmentMetrics : List of Service Appointment Metrics records to be upserted.
     * @return List<Database.UpsertResult> : List of upsert results.
     */
    public List<Database.UpsertResult> upsertServiceAppointmentMetrics(
        List<VCC_Service_Appointment_Metrics__c> serviceAppointmentMetrics
    ) {
        return this.doUpsert(serviceAppointmentMetrics);
    }

    /**
     * @description       : This method is used to fetch the Service Appointment Metrics record by the field name and record id.
     * @param fieldName    : Field name to be used in the where clause.
     * @param recordId     : Record id to be used in the where clause.
     * @return VCC_Service_Appointment_Metrics__c : Service Appointment Metrics record.
     */
    @TestVisible
    private VCC_Service_Appointment_Metrics__c getServiceAppointmentMetricsByField(String fieldName, Id recordId) {
        String selectClause = calculateSelectClause();
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE ' + fieldName + ' = :recordId';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause;
        Map<String, Object> params = new Map<String, Object>{ 'recordId' => recordId };
        return (VCC_Service_Appointment_Metrics__c) this.fetch(query, params).get(0);
    }

    /**
     * @description       : This method is used to calculate the select clause for the object.
     * @return String      : Select clause for the object.
     */
    @TestVisible
    private static String calculateSelectClause() {
        List<String> fieldNames = new List<String>();
        fieldNames.addAll(DEFAULT_FIELDS);
        List<String> fieldNamesList = new List<String>();
        for (String fieldName : fieldNames) {
            fieldNamesList.add(fieldName);
        }
        return 'SELECT ' + String.join(fieldNamesList, ', ');
    }
}
