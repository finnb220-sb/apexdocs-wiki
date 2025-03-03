/**
 * @author Booz Allen Hamilton
 * @since 5/10/24
 * @description Repository for OperatingHoursHoliday standard object
 *
 * @see VCR_OperatingHoursHolidayRepoTest
 */
public inherited sharing class VCR_OperatingHoursHolidayRepo extends VTC_BaseRepo {
    /**
     * @description Constructor - create a new instance of this repo to handle CRUD for our Sobject
     */
    public VCR_OperatingHoursHolidayRepo() {
        super(OperatingHoursHoliday.SObjectType);
        this.defaultSelectFields.addAll(
            new Set<String>{
                'OperatingHoursId',
                'HolidayId',
                'Holiday.ActivityDate',
                'OperatingHours.VCC_VISN__c',
                'OperatingHours.TimeZone'
            }
        );
    }

    /**
     * @description Fetch & return a list of OperatingHoursHoliday records for the given set of related OperatingHours Ids. If
     *  no results are found, return an empty list
     *
     * @param relatedOpHoursIds `Set<Id>` Contains OperatingHours Ids to look for related Holidays
     *
     * @return `List<OperatingHoursHoliday>` Return list of matching OperatingHoursHoliday records, empty if none found
     */
    public List<OperatingHoursHoliday> fetchHolidaysForVISNOperatingHours(Set<Id> relatedOpHoursIds) {
        if (relatedOpHoursIds == null || relatedOpHoursIds.isEmpty()) {
            return new List<OperatingHoursHoliday>();
        }

        Set<String> additionalFields = new Set<String>{
            'Holiday.IsRecurrence',
            'Holiday.IsAllDay',
            'Holiday.StartTimeInMinutes',
            'Holiday.EndTimeInMinutes',
            'Holiday.RecurrenceInstance',
            'Holiday.RecurrenceStartDate',
            'Holiday.RecurrenceType',
            'Holiday.RecurrenceInterval',
            'Holiday.RecurrenceInstance',
            'Holiday.RecurrenceDayOfMonth',
            'Holiday.RecurrenceEndDateOnly',
            'Holiday.RecurrenceDayOfWeekMask',
            'Holiday.RecurrenceMonthOfYear'
        };
        additionalFields.addAll(this.defaultSelectFields);

        String selectClause = this.calculateSelectClause(additionalFields);
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE OperatingHoursId IN :relatedOpHoursIds';
        String orderByClause = 'ORDER BY OperatingHoursId';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' ' + orderByClause;
        return this.fetch(query, new Map<String, Object>{ 'relatedOpHoursIds' => relatedOpHoursIds });
    }
}
