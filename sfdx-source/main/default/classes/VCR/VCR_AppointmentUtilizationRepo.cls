/**
 * @description         : Class used to access Appointment Utilization object data via SOQL/DML
 * @author              : Booz Allen
 **/
public inherited sharing class VCR_AppointmentUtilizationRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for VCR_AppointmentUtilizationRepo. Calls super constructor which sets this.sObjectType to 'VCC_Appointment Utilization'
     *  Adds additional defaultSelectFields
     */
    public VCR_AppointmentUtilizationRepo() {
        super(VCC_Appointment_Utilization__c.SObjectType);
    }

    /**
     * @description method is used to create an `VCC_Appointment_Utilization__c` record in Salesforce.
     * It will insert the record into the Salesforce database and return the record.
     * @param record An instance of `VCC_Appointment_Utilization__c` which represents the appointment utilization record to be created.
     * @return Returns the instance of `VCC_Appointment_Utilization__c` which represents the created appointment utilization record.
     */
    public VCC_Appointment_Utilization__c createAppointmentUtilizationRecord(VCC_Appointment_Utilization__c record) {
        this.doCreate(record);
        return record;
    }

    /**
     * @description function updates a record in the 'VCC_Appointment_Utilization__c' object
     * and returns the updated record.
     * @param record The 'VCC_Appointment_Utilization__c' record to be updated.
     * @return Returns the updated 'VCC_Appointment_Utilization__c' record.
     * @throws DmlException If an error occurs during the DML operation.
     */
    public VCC_Appointment_Utilization__c updateAppointmentUtilizationRecord(VCC_Appointment_Utilization__c record) {
        this.doUpdate(record);
        return record;
    }

    /**
     * @description method retrieves a list of appointment utilization records from the VCC_Appointment_Utilization__c object.
     * Only records that are not deleted are retrieved.
     * The returned records are ordered in descending order by VCC_Date__c.
     * @return A list of VCC_Appointment_Utilization__c custom object records.
     */
    public List<VCC_Appointment_Utilization__c> getAppointmentUtilizationRecords() {
        String selectClause = getQueryString();
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE IsDeleted = false';
        String orderByClause = 'ORDER BY VCC_Date__c DESC';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' ' + orderByClause;
        return this.fetch(query);
    }

    /**
     * @description method retrieves a list of appointment utilization records within the
     * specified date range from the VCC_Appointment_Utilization__c object.
     * Only records that are not deleted and have a VCC_Date__c value
     * between the start and end dates (inclusive) are retrieved.
     * The returned records are ordered in descending order by VCC_Date__c.
     * @param startDate The start date of the range for which to retrieve records.
     * @param endDate The end date of the range for which to retrieve records.
     * @return A list of VCC_Appointment_Utilization__c custom object records.
     */
    public List<VCC_Appointment_Utilization__c> getAppointmentUtilizationWithinRange(Date startDate, Date endDate) {
        String selectClause = getQueryString();
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE IsDeleted = false AND VCC_Date__c >= :startDate AND VCC_Date__c <= :endDate';
        String orderByClause = 'ORDER BY VCC_Date__c DESC';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' ' + orderByClause;
        Map<String, Object> bindParams = new Map<String, Object>{ 'startDate' => startDate, 'endDate' => endDate };
        return this.fetch(query, bindParams);
    }

    /**
     * @description method attempts to either insert or update a list of VCC_Appointment_Utilization__c records.
     * If a record already exists in the database, it updates; otherwise, it inserts a new one.
     * When any record fails to be upserted, that record is added to a list of failed records which is then returned by the method.
     * All encountered errors during the upsert operation are logged.
     * @param records - The list of VCC_Appointment_Utilization__c records to be upserted.
     * @return {List<VCC_Appointment_Utilization__c>} Return a list of VCC_Appointment_Utilization__c records which failed to be upserted.
     */
    public List<VCC_Appointment_Utilization__c> upsertAppointmentUtilizationRecords(
        List<VCC_Appointment_Utilization__c> records
    ) {
        this.allOrNone = false;
        Database.UpsertResult[] results = this.doUpsert(records);
        List<VCC_Appointment_Utilization__c> failedUpsertRecords = new List<VCC_Appointment_Utilization__c>();
        if (results != null && results.size() > 0) {
            for (Database.UpsertResult result : results) {
                if (!result.isSuccess()) {
                    for (Database.Error error : result.getErrors()) {
                        Logger.debug('Error: ' + error.getMessage());
                    }
                    failedUpsertRecords.add(records[results.indexOf(result)]);
                }
            }
            Logger.saveLog();
        }
        return failedUpsertRecords;
    }

    /**
     * @description this method retrieves a list of appointment utilization records within the
     * specified date range from the VCC_Appointment_Utilization__c object and are related to one of the resourceIDs
     * passed into the method AND one of the territoryIds passed into the method.
     * @param resourceIds `Set<Id>` Collection of Id's of the ServiceResources that are related to the targeted Utilization records.
     * @param territoryIds `Set<Id>` Collection of Id's of the ServiceTerritories that are related to the targeted Utilization records.
     * @param range `VCC_DateRange` The date range that the caller of this method needs to filter on..
     * @return A list of VCC_Appointment_Utilization__c records within range and related to the ID's passed in.
     */
    public List<VCC_Appointment_Utilization__c> getAppointmentUtilizationRecordsWithinRangeRelatedToTerritoryMembers(
        Set<Id> resourceIds,
        Set<Id> territoryIds,
        VCC_DateRange range
    ) {
        String whereClause = 'WHERE IsDeleted = false AND VCC_Date__c >= :startDate AND VCC_Date__c <= :endDate AND VCC_Service_Resource__c IN: resourceIds AND VCC_Service_Territory__c IN :territoryIds';
        String queryStr = String.join(
            new List<String>{
                this.calculateSelectClause(this.defaultSelectFields),
                this.calculateFromClause(),
                whereClause
            },
            ' '
        );
        Map<String, Object> bindParams = new Map<String, Object>{
            'startDate' => range.startDateTime.date(),
            'endDate' => range.endDateTime.date(),
            'resourceIds' => resourceIds,
            'territoryIds' => territoryIds
        };
        return this.fetch(queryStr, bindParams);
    }

    /**
     * @description method calculates the SELECT clause for the SOQL query.
     * @return {String} The FROM clause for the SOQL query.
     */
    @TestVisible
    private String getQueryString() {
        return 'SELECT CreatedById,\n' +
            '        CreatedDate,\n' +
            '        Id,\n' +
            '        IsDeleted,\n' +
            '        LastActivityDate,\n' +
            '        LastModifiedById,\n' +
            '        LastModifiedDate,\n' +
            '        Name,\n' +
            '        OwnerId,\n' +
            '        SystemModstamp,\n' +
            '        VCC_Count_of_Available_Appointment_Slots__c,\n' +
            '        VCC_Count_of_Used_Appointment_Slots__c,\n' +
            '        VCC_Date__c,\n' +
            '        VCC_Provider__c,\n' +
            '        VCC_VISN__c';
    }
}
