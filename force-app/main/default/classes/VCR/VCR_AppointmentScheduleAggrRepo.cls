/**
 * @description         : Class used to access Appointment Schedule Aggr object data via SOQL/DML
 * @author              : Booz Allen
 **/
public inherited sharing class VCR_AppointmentScheduleAggrRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for VCR_AppointmentScheduleAggrRepo. Calls super constructor which sets this.sObjectType to 'AppointmentSchedule Aggr'
     *  Adds additional defaultSelectFields
     */
    public VCR_AppointmentScheduleAggrRepo() {
        super(AppointmentScheduleAggr.SObjectType);
    }

    /**
     * @description public method retrieves a list of appointment schedule aggregate records.
     * @return List<AppointmentScheduleAggr> The list of appointment schedule aggregate records.
     */
    public List<AppointmentScheduleAggr> getAppointmentScheduleAggrAll() {
        String query = this.getAppointmentScheduleAggrAllQueryString();
        return this.fetch(query);
    }

    /**
     * @description public method used to form a SOQL query string to retrieve all appointment schedule aggregate records.
     * The query string is used to create a QueryLocator instance which can be used in methods that perform DML operations.
     * @return String of the SOQL query.
     */
    public String getAppointmentScheduleAggrAllQueryString() {
        String selectClause =
            'SELECT AppointmentDate,\n' +
            '        CreatedById,\n' +
            '        CreatedDate,\n' +
            '        Id,\n' +
            '        IsDeleted,\n' +
            '        LastModifiedById,\n' +
            '        LastModifiedDate,\n' +
            '        Name,\n' +
            '        ResourceUtilizationCount,\n' +
            '        ServiceResourceId,\n' +
            '        SystemModstamp,\n' +
            '        TotalResourceUtilization,\n' +
            '        UsageType,\n' +
            '        ServiceResource.RelatedRecordId,\n' +
            '        ServiceResource.RelatedRecord.Division';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE IsDeleted = false';
        String orderByClause = 'ORDER BY AppointmentDate DESC';
        return selectClause + ' ' + fromClause + ' ' + whereClause + ' ' + orderByClause;
    }

    /**
     * @description method is used to get a QueryLocator instance which can be used in methods that perform DML operations.
     * @param query The SOQL query to generate the QueryLocator with.
     * @return A QueryLocator instance that corresponds to the result of the query.
     */
    public Database.QueryLocator getQueryLocator(String query) {
        return Database.getQueryLocator(query);
    }
}
