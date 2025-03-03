/**
 * @description Repo class that contains secure CRUD operations for the ServiceAppointment object.
 * @author Booz Allen
 * @see VTC_BaseRepo
 * @see VTC_RepoFactory
 */
public virtual inherited sharing class VCR_ServiceAppointmentRepo extends VTC_BaseRepo {
    /**
     * @description Arg-less Constructor for this repo that sets the sObjectType to Serviceappointment and adds default fieldsl.
     *
     */
    public VCR_ServiceAppointmentRepo() {
        super(ServiceAppointment.SObjectType);
        this.defaultSelectFields.addAll(
            new Set<String>{
                'RecordType.Name',
                'StatusCategory',
                'ServiceTerritoryId',
                'SchedStartTime',
                'SchedEndTime',
                'Cancelled_Date__c',
                'Status'
            }
        );
    }

    /**
     * @description Method for getting Service appointments related to Service Teritory members, within a certain Time frame.
     * @param resourceIds `Set<Id>` Set of Service Resources to filter the query by.
     * @param territoryIds `Set<Id>` Set of Service Territory's to filter the query by,
     * @param range `VCC_DateRange` A date range to filter the query by.
     *
     * @return `List<ServiceAppointment>` List of appointments that overlap the date range and
     * are worked by and worked at one of the Id's passed in.
     */
    public List<ServiceAppointment> getServiceAppointmentsRelatedToTerritoryMembersInRange(
        Set<Id> resourceIds,
        Set<Id> territoryIds,
        VCC_DateRange range
    ) {
        String whereClause =
            ' WHERE SchedStartTime >= :startDateTime AND SchedStartTime <=: endDateTime' +
            ' AND ServiceTerritoryID IN: territoryIds' +
            ' AND ID IN (SELECT ServiceAppointmentId FROM AssignedResource Where ServiceResourceId IN: resourceIds)' +
            ' AND SchedStartTime != null AND SchedEndTime != null' +
            ' ORDER BY SchedStartTime ASC';

        //Add a sub query so that we can query on related assigned resources.
        String assignedResourcesSubQuery = ', (SELECT ServiceResourceId FROM ServiceResources ) ';
        String queryStr = String.join(
            new List<String>{
                this.calculateSelectClause(this.defaultSelectFields),
                assignedResourcesSubQuery,
                this.calculateFromClause(),
                whereClause
            },
            ' '
        );
        Map<String, Object> bindParams = new Map<String, Object>{
            'resourceIds' => resourceIds,
            'territoryIds' => territoryIds,
            'startDateTime' => range.startDateTime,
            'endDateTime' => range.endDateTime
        };
        return fetch(queryStr, bindParams);
    }

    /**
     * @description SOQL query for ServiceAppointment with field recordtype name.
     * @param queryString String SOQL query
     * @return Database.QueryLocator
     */
    public Database.QueryLocator getQueryLocatorForServiceAppointments(String queryString) {
        return Database.getQueryLocator(queryString);
    }

    /**
     * @description SOQL query for ServiceAppointment with field recordtype name.
     * @return String SOQL query
     */
    public String getQueryStringForServiceAppointments() {
        return 'SELECT Id, Case__c,CreatedDate, (SELECT Id, ParentId, Case_Record_Type_Name__c FROM Cases__r WHERE ' +
            'Case_Record_Type_Name__c = \'VCC_Vitrual_Clinic_Visit\'),(SELECT Id, Case_Metrics__c,Case__c,Service_Appointment__c ' +
            'FROM Service_Appointment_Metrics__r LIMIT 1) FROM ServiceAppointment ORDER BY CreatedDate ASC';
    }
}
