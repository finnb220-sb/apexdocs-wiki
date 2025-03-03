/**
 * @description Collection object that wraps a Map of Service Territory Members to their respective potential Time slots.
 * Used for calculating Utilization per ServiceTerritoryMember.
 * @see VCC_AppointmentUtilizationService
 * @see VCC_TerritoryMemberKey
 * @see VCC_TimeSlotCollection
 * @see VCC_TimeSlot
 * @see VCC_DateRange
 * @see VCC_RepeatingRule
 */
public inherited sharing class VCC_TerritoryMemberToTimeSlotMap {
    public Set<Id> relatedResourceIds;
    public Set<Id> relatedTerritoryIds;

    private final Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> serviceTerritoryMemberKeyToConfirmedTimeSlotMap;

    //CONSTANTS FOR HOLDING ERROR MESSAGES
    @TestVisible
    private static final String NO_MEMBER_KEY_MSG = 'Null Pointer thrown. Expected the serviceTerritoryMemberToAvailableTimeSlotMap to contain Service Territory Member Key.';

    @TestVisible
    private static final String UNEXPECTED_EXCEPTION_MSG = 'Unexpected error occurred when adding shift to time slot collection for ';

    @TestVisible
    private static final String NULL_SHIFT_MSG = 'Null List of Shifts passed to putAllShiftsIntoResultantMap method';

    @TestVisible
    private static final String NULL_PASSED_TO_CONSTRUCTOR = 'Null argument passed to constructor. Cannot instantiate list without List<ServiceTerritoryMember>';

    /**
     * @description  Takes a list of ServiceTerritoryMember records.
     * For each Record, we instantiate a related VCC_TimeSlotCollection object to hold their available times slots and
     * store the ServiceTerritoryMembers' ServiceResourceId and ServiceTerritoryId so that they are easily accessible
     * to filter queries by.
     * @param members `List<ServiceTerritoryMember>` List of Service territory Members that we need to base the collection around.
     */
    public VCC_TerritoryMemberToTimeSlotMap(List<ServiceTerritoryMember> members) {
        if (members == null) {
            throw new InvalidCalculationStateException(NULL_PASSED_TO_CONSTRUCTOR);
        }

        this.serviceTerritoryMemberKeyToConfirmedTimeSlotMap = new Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection>();
        this.relatedResourceIds = new Set<Id>();
        this.relatedTerritoryIds = new Set<Id>();
        for (ServiceTerritoryMember curMember : members) {
            this.serviceTerritoryMemberKeyToConfirmedTimeSlotMap.put(
                new VCC_TerritoryMemberKey(curMember),
                new VCC_TimeSlotCollection()
            );
            this.relatedResourceIds.add(curMember.ServiceResourceId);
            this.relatedTerritoryIds.add(curMember.ServiceTerritoryId);
        }
    }

    /**
     * @description Given a List of shifts, this extrapolates out any recurring shifts and places them
     * in the relevant ServiceTerritoryMembers VCC_TimeSlotCollection.
     * @param confirmedShiftsInRange `List<Shift>` A List of shifts currently in scope for a given date range.
     * @param range `VCC_DateRange` A date range that we are calculating utilization for.
     * @see VCC_DateRange
     * @see VCC_TimeSlot
     * @see VCC_TimeSlotCollection
     * @see VCC_TerritoryMemberKey
     * @see VCC_RepeatingRule
     */
    public void putAllShiftsIntoResultantMap(List<Shift> confirmedShiftsInRange, VCC_DateRange range) {
        if (confirmedShiftsInRange == null) {
            throw new InvalidCalculationStateException(NULL_SHIFT_MSG);
        }

        for (Shift curShift : confirmedShiftsInRange) {
            VCC_TerritoryMemberKey curMemberKey = new VCC_TerritoryMemberKey(
                curShift.ServiceResourceId,
                curShift.ServiceTerritoryId
            );
            //It is possible for a shift to be both in range and recurring. so in that case we need to add it, and all its extrapolated dates.
            if (curShift.StartTime >= range.startDateTime && curShift.StartTime <= range.endDateTime) {
                this.addShiftToResultantMap(curMemberKey, curShift);
            }
            if (curShift.Type == 'Recurring') {
                this.addRecurringShiftsToResultantMap(curMemberKey, curShift, range);
            }
        }
    }

    /**
     * @description Method that extrapolates out a recurring shift into potential time slots so that we can include them in VCV utilization calculations.
     * @param curMemberKey `VCC_TerritoryMemberKey` Territory Member that is assigned the shift.
     * @param curShift `Shift` Recurring shift  that we need to extrapolate out.
     * @param range `VCC_DateRange` Date range that we are currently concerned with.
     * @see VCC_RepeatingRule
     * @see VCC_DateRange
     * @see VCC_TerritoryMemberKey
     */
    @TestVisible
    private void addRecurringShiftsToResultantMap(
        VCC_TerritoryMemberKey curMemberKey,
        Shift curShift,
        VCC_DateRange range
    ) {
        VCC_RepeatingRule repeatingRule = new VCC_RepeatingRule(
            curShift.RecurrencePattern,
            curShift.StartTime,
            curShift.RecurrenceEndDate
        );
        Set<Date> extrapolatedDates = repeatingRule.calculateFutureOccurrences();

        for (Date futureOccurrence : extrapolatedDates) {
            if (
                futureOccurrence >= range.startDateTime.date() &&
                futureOccurrence < range.endDateTime.date() &&
                curShift.StartTime.time() >= range.startDateTime.time()
            ) {
                Shift extrapolatedShift = new Shift(
                    StartTime = DateTime.newInstance(futureOccurrence, curShift.StartTime.time()),
                    EndTime = DateTime.newInstance(futureOccurrence, curShift.EndTime.time())
                );
                this.addShiftToResultantMap(curMemberKey, extrapolatedShift);
            }
        }
    }

    /**
     * @description Getter for the internal map. In theory not needed but,
     * I prefer this syntax over VCC_TerritoryMemberToTimeSlotMap.serviceTerritoryMemberKeyToConfirmedTimeSlotMap
     * @return `Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection>` returns a map of ServiceTerritoryMember to TimeSlot collection.
     */
    public Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> getMap() {
        return this.serviceTerritoryMemberKeyToConfirmedTimeSlotMap;
    }

    /**
     * @description Adds a shift to the VCC_TimeSlotCollection related to the ServiceTerritoryMember passed in.
     * @param currentMember Current Territory member that we are adding a Timeslot to.
     * @param curShift Shift that needs to be normalized and added to the internal, resultant map.
     * @throws InvalidCalculationStateException Throws an exception if the map passed in does not contain a key for the current member.
     * We are expecting at this point that every ServiceTerritoryMember has a related VCC_TimeSlotCollection.
     */
    @TestVisible
    private void addShiftToResultantMap(VCC_TerritoryMemberKey currentMember, Shift curShift) {
        try {
            this.serviceTerritoryMemberKeyToConfirmedTimeSlotMap.get(currentMember).add(curShift);
        } catch (NullPointerException npe) {
            throw new InvalidCalculationStateException(NO_MEMBER_KEY_MSG);
        } catch (Exception anyOtherException) {
            throw new InvalidCalculationStateException(
                UNEXPECTED_EXCEPTION_MSG + currentMember + '.\n' + anyOtherException.getMessage()
            );
        }
    }

    /**
     * @description Custom exception thrown when an Invalid state occurs such as a Missing Territory Member Key in our internal `serviceTerritoryMemberKeyToConfirmedTimeSlotMap`.
     * Ignoring class naming conventions as this is an inner class, and does not need a prefix.
     */
    public class InvalidCalculationStateException extends Exception {
    }
}
