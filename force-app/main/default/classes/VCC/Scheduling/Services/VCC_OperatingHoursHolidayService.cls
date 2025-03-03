/**
 * @author Booz Allen Hamilton
 * @since 5/10/24
 * @description Service for manipulating OperatingHoursHoliday records retrieved from the repo
 *
 * @see VCC_OperatingHoursHolidayServiceTest
 * @see VCR_OperatingHoursHolidayRepo
 *
 */
public with sharing class VCC_OperatingHoursHolidayService {
    @TestVisible
    private final Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> serviceTerritoryMemberKeyToTimeSlotMap;
    private final Map<Id, OperatingHoursWithRelatedData> operatingHoursWithRelatedDataByIds;

    @TestVisible
    private static VCR_OperatingHoursHolidayRepo memoizedOpHoursHolidayRepo;

    @TestVisible
    private static VCR_OperatingHoursHolidayRepo opHoursHolidayRepo {
        get {
            if (memoizedOpHoursHolidayRepo == null) {
                memoizedOpHoursHolidayRepo = new VCR_OperatingHoursHolidayRepo();
            }
            return memoizedOpHoursHolidayRepo;
        }
        private set;
    }

    /**
     * @description Takes a list of ServiceTerritoryMember records.
     * For each record, we instantiate a related VCC_TimeSlotCollection object to hold their excluded times slots and
     * store the ServiceTerritoryMembers' ServiceResourceId and ServiceTerritoryId so that they are easily accessible
     * to filter queries by.
     *
     */
    public VCC_OperatingHoursHolidayService() {
        this.operatingHoursWithRelatedDataByIds = new Map<Id, OperatingHoursWithRelatedData>();
        this.serviceTerritoryMemberKeyToTimeSlotMap = new Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection>();
    }

    private void buildMemberMap(List<ServiceTerritoryMember> members) {
        if (members == null || members.isEmpty()) {
            return;
        }
        for (ServiceTerritoryMember currMember : members) {
            this.serviceTerritoryMemberKeyToTimeSlotMap.put(
                new VCC_TerritoryMemberKey(currMember),
                new VCC_TimeSlotCollection()
            );
            OperatingHoursWithRelatedData data = this.operatingHoursWithRelatedDataByIds.get(
                currMember.OperatingHoursId
            );
            if (data == null) {
                // first ServiceTerritoryMember for a VISN with this OperatingHours - add it to map
                data = new OperatingHoursWithRelatedData(this, currMember);
                this.operatingHoursWithRelatedDataByIds.put(currMember.OperatingHoursId, data);
            }
            data.addRelatedResources(currMember);
        }
    }

    /**
     * @description Retrieve TimeSlots for all Holidays that fall within the given date range for our list of
     *      ServiceTerritoryMembers (junction between Providers and VISNs).
     *
     * @param dateRange Wrapper for start & end dates for querying operating hours holiday data
     * @param members List<ServiceTerritoryMember> List of service Territory Members we care about.
     *
     * @return `Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection>` Map of TimeSlots for Holidays that fall within the given
     *      date range for configured providers & VISNs to be excluded
     */
    public Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> getHolidayTimeSlotsForProvidersAndDates(
        VCC_DateRange dateRange,
        List<ServiceTerritoryMember> members
    ) {
        this.buildMemberMap(members);
        if (dateRange == null) {
            return serviceTerritoryMemberKeyToTimeSlotMap;
        }

        List<OperatingHoursHoliday> operatingHoursHolidays = opHoursHolidayRepo.fetchHolidaysForVISNOperatingHours(
            this.operatingHoursWithRelatedDataByIds.keySet()
        );
        // if there are no holidays in the given date range for the list of providers, return an empty list of TimeSlots now
        if (operatingHoursHolidays == null || operatingHoursHolidays.isEmpty()) {
            return serviceTerritoryMemberKeyToTimeSlotMap;
        }

        Map<Id, List<OperatingHoursHoliday>> holidaysByOpHoursId = new Map<Id, List<OperatingHoursHoliday>>();
        for (OperatingHoursHoliday holiday : operatingHoursHolidays) {
            if (holidaysByOpHoursId.get(holiday.OperatingHoursId) == null) {
                holidaysByOpHoursId.put(holiday.OperatingHoursId, new List<OperatingHoursHoliday>());
            }
            holidaysByOpHoursId.get(holiday.OperatingHoursId).add(holiday);
        }

        VCC_HolidayServiceHelper holidayHelper = new VCC_HolidayServiceHelper();
        for (Id opHoursId : holidaysByOpHoursId.keySet()) {
            OperatingHoursWithRelatedData data = operatingHoursWithRelatedDataByIds.get(opHoursId);
            for (OperatingHoursHoliday opHoursHoliday : holidaysByOpHoursId.get(opHoursId)) {
                if (!opHoursHoliday.Holiday.IsRecurrence) {
                    // not a recurring holiday - just create TimeSlot, & add to map.
                    this.processNonRecurringHoliday(opHoursHoliday, data, dateRange);
                } else {
                    // recurring holiday
                    this.processRecurringHoliday(holidayHelper, opHoursHoliday, data, dateRange);
                }
            }
            // update map keyed off ServiceTerritoryMemberKey
        }
        return serviceTerritoryMemberKeyToTimeSlotMap;
    }

    /**
     * @description Process the Recurring Holiday opoHoursHoliday and add it to operatingHoursWithRelatedData iff any of its dates
     *  fall in the dateRange.
     *  NOTE: Suppressing warning about excessive parameter list due to tight deadline to complete Utilization service. Will add
     *      an item to Tech Debt spreadsheet to revisit & address
     *
     * @param holidayHelper `VCC_HolidayServiceHelper` Instance of helper class to process recurring holiday
     * @param opHoursHoliday `OperatingHoursHoliday` Instance of recurring holiday to process
     * @param operatingHoursWithRelatedData `OperatingHoursWithRelatedData` Instance containing all related data to the Operating Hours Holiday
     * @param dateRange `VCC_DateRange` containing start & end date to limit search for Holiday instances
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    private void processRecurringHoliday(
        VCC_HolidayServiceHelper holidayHelper,
        OperatingHoursHoliday opHoursHoliday,
        OperatingHoursWithRelatedData operatingHoursWithRelatedData,
        VCC_DateRange dateRange
    ) {
        for (
            Date holidayDateInstance : holidayHelper.getHolidayInstancesWithinDateRange(
                opHoursHoliday.Holiday,
                dateRange.startDateTime.dateGMT(),
                dateRange.endDateTime.dateGMT()
            )
        ) {
            operatingHoursWithRelatedData.addOperatingHoursHoliday(holidayDateInstance);
        }
    }

    /**
     * @description Process a Non-Recurring Holiday to determine if it falls within the given dateRange
     *
     * @param opHoursHoliday Instance of Operating Hours Holiday to review/process
     * @param operatingHoursWithRelatedData Contains all related data to opHoursHoliday
     * @param dateRange Contains startTime & endTime to limit data returned to only those holidays within
     *  the related start & end dates
     */
    private void processNonRecurringHoliday(
        OperatingHoursHoliday opHoursHoliday,
        OperatingHoursWithRelatedData operatingHoursWithRelatedData,
        VCC_DateRange dateRange
    ) {
        if (
            opHoursHoliday.Holiday.ActivityDate >= dateRange.startDateTime.dateGMT() &&
            opHoursHoliday.Holiday.ActivityDate <= dateRange.endDateTime.dateGMT()
        ) {
            if (opHoursHoliday.Holiday.IsAllDay) {
                operatingHoursWithRelatedData.addOperatingHoursHoliday(opHoursHoliday.Holiday.ActivityDate);
            } else {
                operatingHoursWithRelatedData.addOperatingHoursHoliday(
                    convertToDateTimeInstance(opHoursHoliday, opHoursHoliday.Holiday.StartTimeInMinutes),
                    convertToDateTimeInstance(opHoursHoliday, opHoursHoliday.Holiday.EndTimeInMinutes)
                );
            }
        }
    }

    /**
     * @description Convert the given holiday instance into a DateTime instance offsetting holidayInstance time (start of day) by minutesToAdd
     *
     * @param opHoursHoliday OperatingHoursHoliday instance to update
     * @param minutesToAdd Number of minutes to add to start of holidayInstance day
     *
     * @return `Datetime` Converted Datetime with minutesToAdd added to start of holidayInstance day
     */
    private Datetime convertToDateTimeInstance(OperatingHoursHoliday opHoursHoliday, Integer minutesToAdd) {
        Datetime value = Datetime.newInstanceGMT(opHoursHoliday.Holiday.ActivityDate, Time.newInstance(0, 0, 0, 0))
            .addMinutes(minutesToAdd);
        return value;
    }

    /**
     * @description Helper class to contain the data for a given OperatingHours - tracks all Holidays, Providers and VISNs
     *  associated with OperatingHours.
     */
    public class OperatingHoursWithRelatedData {
        public VCC_OperatingHoursHolidayService holidayService;
        public Id opHoursId;
        public List<VCC_TerritoryMemberKey> territoryMemberKeys;

        /**
         * @description Create a new instance of this helper class for given ServiceTerritoryMember and current
         *  instance of VCC_OperatingHoursHolidayService
         *
         * @param holidayService instance of parent class `VCC_OperatingHoursHolidayService`
         * @param currMember current ServiceTerritoryMember (junction of ServiceResource (Provider) and ServiceTerritory (VISN)) that
         *  that also specifies the OperatingHours to use
         */
        public OperatingHoursWithRelatedData(
            VCC_OperatingHoursHolidayService holidayService,
            ServiceTerritoryMember currMember
        ) {
            this.holidayService = holidayService;
            // initialize our map - we need to be able to get the set of TerritoryMembers (Resources) for a given Territory easily
            this.territoryMemberKeys = new List<VCC_TerritoryMemberKey>();
            this.opHoursId = currMember.OperatingHoursId;
            this.addRelatedResources(currMember);
        }

        /**
         * @description For each ServiceTerritoryMember being processed that uses our OperatingHours, create & add a
         *  VCC_TerritoryMemberKey to our list (VCC_TerritoryMemberKey makes a unique key from ServiceResource & ServiceTerritory)
         *
         * @param currMember `ServiceTerritoryMember` that uses our OperatingHours and needs to have Holidays tracked.
         */
        public void addRelatedResources(ServiceTerritoryMember currMember) {
            this.territoryMemberKeys.add(
                new VCC_TerritoryMemberKey(currMember.ServiceResourceId, currMember.ServiceTerritoryId)
            );
        }

        /**
         * @description Add Holiday to each ServiceTerritoryMember for use in calculating utilization. This will ensure
         *  that these Holiday hours are excluded.
         *
         * @param holidayToAdd `Date` Date of Holiday associated with our OperatingHours - assumption is that it is an all day holiday
         */
        public void addOperatingHoursHoliday(Date holidayToAdd) {
            // add Holiday Time Slot to each ServiceTerritoryMember TimeSlotCollection
            this.addOperatingHoursHoliday(
                Datetime.newInstanceGmt(holidayToAdd, Time.newInstance(0, 0, 0, 0)),
                Datetime.newInstanceGmt(holidayToAdd.addDays(1), Time.newInstance(0, 0, 0, 0))
            );
        }

        /**
         * @description Overloaded method to take Datetime for start & end of Holiday. Other version invokes this defaulting to an all-day
         *  Holiday from midnight to midnight. This will ensure that these Holiday hours are excluded.
         *
         * @param holidayToAddStartTime `Datetime` Datetime of Holiday associated with our OperatingHours starts
         * @param holidayToAddEndTime `Datetime` Datetime that our Holiday associated with our OperatingHours ends
         */
        public void addOperatingHoursHoliday(Datetime holidayToAddStartTime, Datetime holidayToAddEndTime) {
            // add Holiday Time Slot to each ServiceTerritoryMember TimeSlotCollection
            for (VCC_TerritoryMemberKey currKey : this.territoryMemberKeys) {
                VCC_TimeSlotCollection timeSlotCollection = this.holidayService.serviceTerritoryMemberKeyToTimeSlotMap.get(
                    currKey
                );
                timeSlotCollection.add(new VCC_TimeSlot(holidayToAddStartTime, holidayToAddEndTime));
            }
        }
    }
}
