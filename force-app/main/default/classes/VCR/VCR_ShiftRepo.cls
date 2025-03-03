/**
 * @description Repo class to contain CRUD operations for the shift object.
 * @see VTC_BaseRepo
 */
public inherited sharing class VCR_ShiftRepo extends VTC_BaseRepo {
    /**
     * @description Constructor. Sets the internal sObjectType and adds default fields for the repo to be used in queries.
     * @see VTC_BaseRepo
     */
    public VCR_ShiftRepo() {
        super(Shift.SObjectType);
        this.defaultSelectFields.addAll(
            new Set<String>{
                'StartTime',
                'EndTime',
                'ServiceResourceId',
                'ServiceTerritoryId',
                'Status',
                'RecurrenceStartDate',
                'RecurrenceEndDate',
                'RecurrencePattern',
                'Type'
            }
        );
    }

    /**
     * @description Method that queries on shift records and filters results based on a given Date range and by ServiceResourceId and ServiceTerritoryId
     * @param  range `VCC_DateRange`  The date range that the caller of this method needs shifts to be filtered on.
     * @param  territoryIds `Set<Id>` Collection of Id's of the ServiceTerritory that the assigned shifts are at.
     * @param resourceIds `Set<Id>` Collection of Id's of the ServiceResources that are assigned the shifts.
     * @return `List<Shift>` Returns a List of Shift records that are of Status 'Confirmed', within the range and are assigned to one of the Service resources passed into this method.
     */
    public List<Shift> getConfirmedShiftsRelatedToServiceTerritoryMembersInDateRange(
        VCC_DateRange range,
        Set<Id> territoryIds,
        Set<Id> resourceIds
    ) {
        //For a shift to be in range it needs to...
        //Have a StartTime in range OR Have a recurring shift that is in the range.
        String whereClause = ' WHERE ( (StartTime >= :startDateTime AND StartTime <=: endDateTime) OR (RecurrenceStartDate <=: endDate AND RecurrenceEndDate >=:startDate ) ) AND ServiceTerritoryID IN: territoryIds AND ServiceResourceID IN: resourceIds AND Status = \'Confirmed\' ORDER BY StartTime ASC';

        String queryStr = String.join(
            new List<String>{
                this.calculateSelectClause(this.defaultSelectFields),
                this.calculateFromClause(),
                whereClause
            },
            ' '
        );
        Map<String, Object> bindParams = new Map<String, Object>{
            'startDateTime' => range.startDateTime,
            'endDateTime' => range.endDateTime,
            'startDate' => range.startDateTime.date(),
            'endDate' => range.endDateTime.date(),
            'territoryIds' => territoryIds,
            'resourceIds' => resourceIds
        };
        return this.fetch(queryStr, bindParams);
    }
}
