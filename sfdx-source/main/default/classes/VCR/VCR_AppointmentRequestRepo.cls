/**
 * @description VCR_AppointmentRequestRepo is a repository class used for VCC_AppointmentRequest__c records.
 * @author Booz Allen Hamilton
 * @justification allowUnsafe is set to true to allow SYSTEM_MODE querying of VCC_AppointmentRequest__c records. Due to a race condition between the share records persisting when Appointment Requests are committed to the database, and a query we are running immediately after
 * Appointment Requests are committed, the user was intermittently receiving zero results in the query. Using a query run in SYSTEM_MODE solves this issue by returning the records no matter what. Context: Our solution involves persisting external Appointment Request records
 * to the VCC_AppointmentRequest__c object upon patient load as a caching mechanism. For the duration of the user's session on the patient record, the Scheduling components will use this internal data to reduce the need for repetitive (and time consuming) callouts.
 *
 * getQueryLocator also uses SYSTEM_MODE to query VCC_AppointmentRequest__c records for the scheduled batch class.
 * The user that schedules the job will be System Admin but may not have all necessary object and field access.
 * Using a query run in SYSTEM_MODE solves this issue for the batch class to run successfully,
 * without having to grant additional permissions to the user that would not be needed beyond batch class.
 */
public inherited sharing class VCR_AppointmentRequestRepo extends VTC_BaseRepo {
    /**
     * @description Constructor for VCR_AppointmentRequestRepo. Allow unsafe set to true to allow for query of VCC_AppointmentRequest__c records in SYSTEM_MODE. Please see justification at the top of the class.
     */
    public VCR_AppointmentRequestRepo() {
        super(VCC_AppointmentRequest__c.sObjectType, true);
    }

    /**
     * @description Returns a string to be used in getQueryLocatorWithBinds.
     * @param dateTimeHoursAgo - DateTime value to compare records based on LastModifiedDate for Appointment Requests with Status that is not closed.
     * @param dateDaysAgo - Date value to compare records based on LastModifiedDate for Closed Appointment Requests.
     * @return `String` - Query string for VCC_AppointmentRequest__c records that includes a filter for
     * LastModifiedDate in the WHERE clause.
     * @see VCC_AppointmentDataBatchDelete
     */
    public String getStaleApptReqQueryString(DateTime dateTimeHoursAgo, Date dateDaysAgo) {
        if (dateTimeHoursAgo == null || dateDaysAgo == null) {
            return null;
        } else {
            String selectClause = this.calculateSelectClause(this.defaultSelectFields);
            String fromClause = this.calculateFromClause();
            String whereClause =
                ' WHERE ' +
                '(VCC_Current_Status__c != \'Closed\' AND LastModifiedDate < :dateTimeHoursAgo )' +
                ' OR ' +
                '(VCC_Current_Status__c = \'Closed\' AND LastModifiedDate < :dateDaysAgo )';
            return selectClause + ' ' + fromClause + ' ' + whereClause;
        }
    }

    /**
     * @description Used from a scheduled batch class to clean up old/stale data.
     * Running user that schedules the batch class will be System Admin but
     * will not have all object/record/field access.
     * Do query in System Mode, so that permissions do not need to be granted to running user
     * that would not be required outside of the batch class.
     * @param query - Query string returned from getStaleApptReqQueryString.
     * @param bindParams - Map with the DateTime and Date values to filter records based on LastModifiedDate.
     * @return Database.QueryLocator - List of <VCC_AppointmentRequest__c> records to return to start method of batch class.
     * These will be the old/stale records that meet criteria based on LastModifiedDate,
     * and will get deleted in the execute method of the batch class.
     * @see VCC_AppointmentDataSchedulable
     * @see VCC_AppointmentDataBatchDelete
     */
    public Database.QueryLocator getQueryLocator(String query, Map<String, Object> bindParams) {
        if ([SELECT Name, Id FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].Name != 'System Administrator') {
            throw new HandledException('Only System Administrators can run this query');
        }
        if (String.isBlank(query) || bindParams == null || bindParams.isEmpty()) {
            return null;
        } else {
            return Database.getQueryLocatorWithBinds(query, bindParams, AccessLevel.SYSTEM_MODE);
        }
    }
}
