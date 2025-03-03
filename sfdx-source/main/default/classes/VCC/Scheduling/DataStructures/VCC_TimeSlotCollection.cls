/**
 * @description Custom Data structure for holding a sorted List<VCC_TimeSlot>.
 * Responsible for parsing Shifts into potential time slots, and calculating their total length.
 * Responsible for removing excluded date ranges and removing their total length.
 *
 * Used in calculating Virtual Clinic Visit Utilization
 *
 * @see VCC_DateRange
 * @see VCC_TimeSlot
 * @see VCC_AppointmentUtilizationService
 * @see VCC_TerritoryMemberToTimeSlotMap
 * @see VCC_RepeatingRule
 * @see VCC_TimeSlotCollectionTest
 *
 * Suppressing this warning given time constraints.
 */
public inherited sharing class VCC_TimeSlotCollection {
    @TestVisible
    private List<VCC_TimeSlot> timeSlots;
    @TestVisible
    private Long totalTimeMS;
    @TestVisible
    private Integer totalNumSlots;

    public List<String> shiftDescriptions;

    @TestVisible
    private static final String JAVA_SIMPLE_DATE_FORMATTING_STRING = 'M/d/yyyy, h:mm a';
    private static final String DASH_CHARACTER = '-';
    private static final String DESCRIPTION_SEPARATOR = ' AND ';

    /**
     * @description Arg-less constructor that instantiates a List<VCC_TimeSlot>.
     */
    public VCC_TimeSlotCollection() {
        this.totalTimeMS = 0;
        this.timeSlots = new List<VCC_TimeSlot>();
        this.totalNumSlots = 0;
        this.shiftDescriptions = new List<String>();
    }

    /**
     * @description Overloaded Constructor that takes a shift and adds it to the internal collection.
     * @param shift `Shift` Shift object that will be parsed into relevant time slots.
     */
    public VCC_TimeSlotCollection(Shift shift) {
        this();
        this.add(shift);
    }

    /**
     * @description Overloaded Constructor that takes a ServiceAppointment and adds it to the internal collection.
     * @param serviceAppointment `ServiceAppointment` Appointment object that will be normalized and parsed into VCC_TimeSlots
     */
    public VCC_TimeSlotCollection(ServiceAppointment serviceAppointment) {
        this();
        this.add(serviceAppointment);
    }

    /**
     * @description Size function so that we can determine how many elements are in the internal collection, without having direct access to it.
     * @return `Integer` returns the size of the internal collection.
     */
    public Integer size() {
        return this.timeSlots.size();
    }

    /**
     * @description Divides the totalTimeMS by 60000 to convert it to minutes.
     * 60000 is significant because there are 1000 ms in a second and 60 seconds in a minute. 60*1000 = 60000
     * @return `Long` returns a Number representing the total minutes of all time slots in the collection.
     */
    public Long getTimeInMinutes() {
        return this.totalTimeMS / 60000;
    }

    /**
     * @description Normalizes a Shift record into a VCC_TimeSlot object and tries to add it to the internal collection.
     * If the VCC_TimeSlot object is added to the collection, then we increment the total time of all Time slots in this collection.
     * @param shift `Shift` Shift we are to add to the collection.
     * @return `Boolean` returns true if the shift was successfully added. Returns false if the Shift is not added.
     * @see VCC_TimeSlot
     */
    public Boolean add(Shift shift) {
        if (shift == null || shift.StartTime == null || shift.EndTime == null) {
            return false;
        }
        return addShiftAndDescription(shift);
    }

    private Boolean addShiftAndDescription(Shift shift) {
        VCC_TimeSlot potentialTimeSlot = new VCC_TimeSlot(shift.StartTime, shift.EndTime);
        Boolean addedShift = this.add(potentialTimeSlot);
        if (addedShift) {
            this.addShiftDescription(shift);
        }
        return addedShift;
    }

    /**
     * @description  Add description from shift to our list of Descriptions.
     * @param shift Shift record that occurs within our time range.
     */
    private void addShiftDescription(Shift shift) {
        String shiftDescription = buildDescription(shift);
        this.shiftDescriptions.add(shiftDescription);
    }

    private String buildDescription(Shift shift) {
        return shift.StartTime.format(JAVA_SIMPLE_DATE_FORMATTING_STRING) +
            DASH_CHARACTER +
            shift.EndTime.format(JAVA_SIMPLE_DATE_FORMATTING_STRING);
    }
    /**
     * @description Concat the Shift descriptions previously added for all the Shift(s) that constitute this time range. In the large majority of cases,
     *  there is a single Shift in a given date range (day) but in cases where a Provider works a longer shift than normal or has an appointment in the
     *  middle of their day so they have two shifts (ie 8:00 - 12:00 pm, 1:00 pm - 5:00 pm).
     * @return String concatenating Shift Descriptions separating descriptions with ' AND ' constant. If the TimeSlotCollection is not attached to any
     *  Shift(s), then this will return the empty string.
     */
    public String concatDescriptions() {
        return String.join(this.shiftDescriptions, DESCRIPTION_SEPARATOR);
    }

    /**
     * @description Normalizes a ServiceAppointment record into a VCC_TimeSlot object and tries to add it to the internal collection.
     * If the VCC_TimeSlot object is added to the collection, then we increment the total time of all Time slots in this collection.
     * @param serviceAppointment `ServiceAppointment` Appointment we are to add to the collection.
     * @return `Boolean` returns true if the Appointment was successfully added. Returns false if the Appointment was a duplicate.
     * @see VCC_TimeSlot
     */
    public Boolean add(ServiceAppointment serviceAppointment) {
        if (
            serviceAppointment == null ||
            serviceAppointment.SchedStartTime == null ||
            serviceAppointment.SchedEndTime == null
        ) {
            return false;
        }
        VCC_TimeSlot potentialTimeSlot = new VCC_TimeSlot(
            serviceAppointment.SchedStartTime,
            serviceAppointment.SchedEndTime
        );
        return this.add(potentialTimeSlot);
    }

    /**
     * @description Add method for adding a TimeSlot to the collection.
     * Since this is a sorted list, we find the index to add the shift record at.
     * If the VCC_TimeSlot object is added to the collection, then we increment the total time of all Time slots in this collection.
     * @param timeSlotToAdd `VCC_TimeSlot` Shift we are to add to the collection.
     * @return `Boolean` returns true if successfully added Time slot else returns false if timeslot is not added.
     * @see VCC_TimeSlot
     */
    public Boolean add(VCC_TimeSlot timeSlotToAdd) {
        Integer index = this.findIndexToInsertBinarySearch(timeSlotToAdd);
        //If were adding this to the end of the list we don't need to check anything.
        if (index == this.size()) {
            this.timeSlots.add(timeSlotToAdd);
            this.totalTimeMS += timeSlotToAdd.getTimeInRange();
            return true;
        }

        //Else we need to do some checks on the existing time slot vs the one we're trying to add.
        return addTimeSlotAtIndex(timeSlotToAdd, index);
    }

    private Boolean addTimeSlotAtIndex(VCC_TimeSlot timeSlotToAdd, Integer index) {
        VCC_TimeSlot timeSlot = this.timeSlots.get(index);
        //Check for duplicate time ranges
        if (timeSlotToAdd.existsInsideOf(timeSlot)) {
            return false;
        }
        //Check if the two time slots are overlapping, if so adjust the overlapping one
        if (timeSlot.isOverlapping(timeSlotToAdd)) {
            //Take the oldest start date and the latest end date
            this.keepOldestStartAndLatestEnd(timeSlot, timeSlotToAdd);
            return true;
        }

        //Else
        //Add a net new time slot at the correct index.
        this.timeSlots.add(index, timeSlotToAdd);
        this.totalTimeMS += timeSlotToAdd.getTimeInRange();
        return true;
    }

    /**
     * @description Given two time slots, take the earliest startDateTime and the latest endDateTime between the two,
     * and set the startDateTime and endDateTime of the timeSlotToChange equal to these values and recalculate totalTimeInMS.
     * @param timeSlotToChange `VCC_TimeSlot` TimeSlot to effect, this one will be changed by reference.
     * @param timeSlotToCompare `VCC_TimeSlot`  Time to compare dateTimes with.
     */
    private void keepOldestStartAndLatestEnd(VCC_TimeSlot timeSlotToChange, VCC_TimeSlot timeSlotToCompare) {
        DateTime newStartDateTime = getOldestStartTime(timeSlotToChange, timeSlotToCompare);
        DateTime newEndDateTime = getLatestEndTime(timeSlotToChange, timeSlotToCompare);
        Long timeDiff = (newEndDateTime.getTime() - newStartDateTime.getTime()) - (timeSlotToChange.getTimeInRange());
        this.totalTimeMS += (timeDiff);
        timeSlotToChange.startDateTime = newStartDateTime;
        timeSlotToChange.endDateTime = newEndDateTime;
    }

    private Datetime getLatestEndTime(VCC_TimeSlot timeSlotToChange, VCC_TimeSlot timeSlotToCompare) {
        return (timeSlotToChange.endDateTime > timeSlotToCompare.endDateTime)
            ? timeSlotToChange.endDateTime
            : timeSlotToCompare.endDateTime;
    }

    private Datetime getOldestStartTime(VCC_TimeSlot timeSlotToChange, VCC_TimeSlot timeSlotToCompare) {
        return (timeSlotToChange.startDateTime < timeSlotToCompare.startDateTime)
            ? timeSlotToChange.startDateTime
            : timeSlotToCompare.startDateTime;
    }

    /**
     * @description Given a list of Time ranges that we want to exclude, find
     * remove all existing Time slots in the given ranges.
     * @param excludedSlots `List<VCC_TimeSlot>` List of Time slots that we want to filter out of the internal collection.
     */
    public void filterOutTimeSlots(List<VCC_TimeSlot> excludedSlots) {
        for (VCC_TimeSlot exclusionarySlot : excludedSlots) {
            Integer index = findIndexOfOverlappingTimeSlotBinarySearch(exclusionarySlot);
            if (index != -1) {
                this.findAndRemoveInvalidTimeSlots(exclusionarySlot);
            }
        }
    }

    /**
     * @description Given a date range, remove or correct all time slots that are in or overlapping
     * the date range.
     * @param exclusionarySlot `VCC_TimeSlot` Time range that we are filtering on.
     */
    private void findAndRemoveInvalidTimeSlots(VCC_TimeSlot exclusionarySlot) {
        //Iterate from back to front so we can remove in place.
        for (Integer index = this.size() - 1; index >= 0; index--) {
            VCC_TimeSlot currentTimeSlot = this.timeSlots.get(index);
            if (currentTimeSlot == exclusionarySlot || currentTimeSlot.existsInsideOf(exclusionarySlot)) {
                this.timeSlots.remove(index);
                this.totalTimeMS -= currentTimeSlot.getTimeInRange();
            } else if (exclusionarySlot.existsInsideOf(currentTimeSlot)) {
                this.timeSlots.add(new VCC_TimeSlot(exclusionarySlot.endDateTime, currentTimeSlot.endDateTime));
                currentTimeSlot.endDateTime = exclusionarySlot.startDateTime;
                this.totalTimeMS -= exclusionarySlot.getTimeInRange();
            } else if (currentTimeSlot.isOverlapping(exclusionarySlot)) {
                this.removeExcludedRangeFromCurrentTimeSlot(currentTimeSlot, exclusionarySlot);
            }
        }
    }

    /**
     * @description Removes the overlap from the exclusionarySlot from the currentTimeSlot, and recalculates the timeInMS.
     * @param currentTimeSlot `VCC_TimeSlot` Time slot that is effected by the exclusionarySlot e.g it overlaps.
     * @param exclusionarySlot `VCC_TimeSlot` exclusionary slot that overlaps the timeslot we are effecting.
     */
    private void removeExcludedRangeFromCurrentTimeSlot(VCC_TimeSlot currentTimeSlot, VCC_TimeSlot exclusionarySlot) {
        //Current time slot 9 - 5
        //Lunch break from 9 - 1pm
        // 1-5pm
        DateTime newStartDateTime = (currentTimeSlot.startDateTime < exclusionarySlot.startDateTime)
            ? currentTimeSlot.startDateTime
            : exclusionarySlot.endDateTime;

        DateTime newEndDateTime = (currentTimeSlot.endDateTime > exclusionarySlot.endDateTime)
            ? currentTimeSlot.endDateTime
            : exclusionarySlot.startDateTime;

        Long timeDiff = (newEndDateTime.getTime() - newStartDateTime.getTime()) - (currentTimeSlot.getTimeInRange());
        this.totalTimeMS += (timeDiff);
        currentTimeSlot.startDateTime = newStartDateTime;
        currentTimeSlot.endDateTime = newEndDateTime;
    }

    /**
     * @description Given that this list is always sorted, we can perform a binary search for overlapping timeslots.
     * @param timeSlotToFind `VCC_TimeSlot` A timeslot we want check for overlap against.
     *
     * @return `Integer` returns the index if there is an overlapping element. Else returns -1.
     */
    @TestVisible
    private Integer findIndexOfOverlappingTimeSlotBinarySearch(VCC_TimeSlot timeSlotToFind) {
        return binarySearch(timeSlotToFind, false);
    }

    /**
     * @description Given that this list is always sorted, we can perform a binary search on the internal collection to find the index to insert at.
     *
     * @param timeSlotToFind `VCC_TimeSlot` A timeslot we want check for insertion position.
     *
     * @return `Integer` returns the index if there is an overlapping element. Else returns -1.
     */
    @TestVisible
    private Integer findIndexToInsertBinarySearch(VCC_TimeSlot timeSlotToFind) {
        return binarySearch(timeSlotToFind, true);
    }

    /**
     * @description Divide and conquer, binary search algorithm for searching for a timeSlot.
     *
     * Given that this collection is sorted by startDateTime, instead of iterating through every element,
     * we can first check the element at middle index of the list.
     *
     * If the element at the middle index is equal to or overlaps what we are searching for, we return the middle index.
     * If the timeslot to find starts after the element in the middle index, we can exclude the left half of the array,
     * or conversely if the timeSlot to find starts before the middle index, we can exclude the right half of the array.
     *
     * Repeat this until either an element is found, or there are no more elements to search.
     *
     * TIME COMPLEXITY:
     * Given N being the number of elements in the collection....
     * This has a Time complexity of Log(N), linear approach is O(N) (iterating through every element)
     *
     * E.G. Given a collection of 50,000 elements....
     * Worst case, linear search would need to iterate 50,000 times.
     * Worst case binary search would need to iterate 16 times
     * @param timeSlotToFind Time slot we are searching for.
     * @param returnClosestIndex `Boolean` Determines whether this method returns the closest time slot based on startDateTime.
     * If true this returns the closest element if an exact match or overlapping time slot is not found.
     * If false we return -1 if no overlapping is found.
     *
     * @return `Integer` Index of what we are searching for.
     *
     */
    @TestVisible
    private Integer binarySearch(VCC_TimeSlot timeSlotToFind, Boolean returnClosestIndex) {
        //Find the index of the time slot nearest to the passed in one
        Integer low = 0;
        Integer high = this.size() - 1;
        while (low <= high) {
            //Find the middle index
            Integer mid = low + (high - low) / 2;
            VCC_TimeSlot timeSlotAtMiddleIndex = this.timeSlots.get(mid);
            if (timeSlotAtMiddleIndex == timeSlotToFind || timeSlotAtMiddleIndex.isOverlapping(timeSlotToFind)) {
                return mid;
            }
            //if the start date is before we can ignore the left half of the array.
            else if (timeSlotAtMiddleIndex.compareTo(timeSlotToFind) == -1) {
                low = mid + 1;
            }
            //Else ignore the right half of the array.
            else {
                high = mid - 1;
            }
        }

        return (returnClosestIndex) ? high + 1 : -1;
    }

    /**
     * @description Public getter for the internal Time slot collection.
     * @return `List<VCC_TimeSlot>` The internal collection of timeSlots.
     */
    public List<VCC_TimeSlot> getTimeSlots() {
        return this.timeSlots;
    }

    /**
     * @description Calculate the total # of slots given the slotDuration & the total time for all Slots.
     *  Formula = Total # of minutes in available slots / slotDuration
     *
     * @param slotDuration `Integer` represents default appointment slot duration for our related VISN
     * @return `Integer` returns the number of total slots.
     */
    public Integer calculateTotalNumSlots(Integer slotDuration) {
        this.totalNumSlots = Integer.valueOf(this.getTimeInMinutes() / slotDuration);
        return this.totalNumSlots;
    }
}
