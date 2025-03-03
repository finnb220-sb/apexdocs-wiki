/**
 * @author Booz Allen Hamilton
 * @since 5/14/24
 * @description Repository for all CRUD operations for the OperatingHours object
 *
 * @see VCC_OperatingHoursHolidayService
 */
public inherited sharing class VCR_OperatingHoursRepo extends VTC_BaseRepo {
    /**
     * @description Create an instance of a Repository for handling CRUD calls for OperatingHours object
     */
    public VCR_OperatingHoursRepo() {
        super(OperatingHours.SObjectType);
        this.defaultSelectFields.addAll(new Set<String>{ 'VCC_VISN__c', 'TimeZone', 'Name' });
    }

    /**
     * @description Fetch all OperatingHours records along with the relevant Timeslots for the given Provider VISN
     *
     * @param providerVisn String representing the Provider VISN to retrieve Operating Hours

     * @return
     */
    public List<OperatingHours> fetchOperatingHoursWithTimeSlots(String providerVisn) {
        String queryString = this.calculateSelectClause(this.defaultSelectFields);
        queryString += ', (SELECT Id, DayOfWeek, StartTime, EndTime, VCC_VISN__c, TUC_Schedule_Settings__c, Type FROM TimeSlots WHERE VCC_VISN__c=:timeSlotProviderVisn)';
        queryString += ' ' + this.calculateFromClause();
        queryString += ' WHERE VCC_VISN__c=:providerVisn';
        queryString += ' ORDER BY VCC_VISN__c';
        return (List<OperatingHours>) this.fetch(
            queryString,
            new Map<String, Object>{ 'timeSlotProviderVisn' => providerVisn, 'providerVisn' => providerVisn }
        );
    }

    /**
     * @description Fetch all OperatingHours records along with the relevant Timeslots for the given Provider VISN List
     *
     * @param providerVisnList List<String> A list of Strings representing the Provider VISNs to retrieve Operating Hours
     * @param opHourType String that corresponds to VCC_Operating_Hours_Type__c, indicating which subset of Operating Hours to retrieve
     * @return List<OperatingHours> all Operating Hours that are applicable to the provided list of VISNs
     */
    public List<OperatingHours> fetchMultipleOperatingHoursWithTimeSlotsByType(
        List<String> providerVisnList,
        String opHourType
    ) {
        if (providerVisnList == null || providerVisnList.isEmpty()) {
            return new List<OperatingHours>();
        }

        String queryString = this.calculateSelectClause(this.defaultSelectFields);
        queryString += ', (SELECT Id, DayOfWeek, StartTime, EndTime, VCC_VISN__c, TUC_Schedule_Settings__c, Type FROM TimeSlots WHERE VCC_VISN__c IN: timeSlotProviderVisns)';
        queryString += ' ' + this.calculateFromClause();
        queryString += ' WHERE VCC_VISN__c IN: providerVisns AND VCC_Operating_Hours_Type__c =: opHourType';
        queryString += ' ORDER BY VCC_VISN__c';
        return (List<OperatingHours>) this.fetch(
            queryString,
            new Map<String, Object>{
                'timeSlotProviderVisns' => providerVisnList,
                'providerVisns' => providerVisnList,
                'opHourType' => opHourType
            }
        );
    }
}
