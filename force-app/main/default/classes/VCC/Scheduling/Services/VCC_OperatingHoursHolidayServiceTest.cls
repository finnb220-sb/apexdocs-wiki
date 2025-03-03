/**
 * @author Booz Allen Hamilton
 * @since 5/13/24
 * @description Unit tests for VCC_OperatingHoursHolidayService apex class
 *
 * NOTE: Suppressing PMD CyclomaticComplexity warning due to this being a unit test and issue is with
 *  creating test data with its dependencies
 *  Suppressing Description must have text due to false positives.
 *
 * @see VCC_OperatingHoursHolidayService
 */
@IsTest
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.DescriptionMustHaveText')
private class VCC_OperatingHoursHolidayServiceTest {
    final static User VCC_VCV_APPT_VIEW_ADMIN_USER;
    static {
        VCC_VCV_APPT_VIEW_ADMIN_USER = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSet('VCC_VCV_Appointment_Viewer_Administrator')
            .withStandardData()
            .build(true);
    }

    /**
     * @description Test data structure for creating OperatingHoursHoliday and its related (dependent) data
     */
    public class TestOperatingHoursHolidayData {
        public List<Holiday> holidays;
        public List<ServiceResource> providers;
        public List<ServiceTerritory> visns;
        public List<OperatingHours> opHours;
        public List<OperatingHoursHoliday> opHoursHolidays;
        public Date startDate;
        public Date endDate;
        public Boolean blnIsRecurring;

        /**
         * @description `List<ServiceTerritoryMember>` List of ServiceTerritoryMembers for our list of ServiceResources
         *  and ServiceTerritories
         */
        public List<ServiceTerritoryMember> serviceTerritoryMembers;

        /**
         * @description `Set<Id>` Set of SF record Ids for OperatingHours record(s) related to our OperatingHoursHoliday records
         *
         */
        public Set<Id> opHoursIds {
            public get {
                Set<Id> ids = new Set<Id>();
                for (OperatingHours record : this.opHours) {
                    ids.add(record.Id);
                }
                return ids;
            }
            private set;
        }
        /**
         * @description `VCC_DateRange` used when searching for our OperatingHoursHoliday test records
         */
        public VCC_DateRange dateRange {
            public get {
                return new VCC_DateRange(startDate, endDate);
            }
            private set;
        }

        /**
         * @description `VCC_TerritoryMemberKey` dynamically build & return a VCC_TerritoryMemberKey based on our
         *  Provider (ServiceResource) and VISN (ServiceTerritory) for use in tests
         */
        public VCC_TerritoryMemberKey territoryMemberKey {
            get {
                return new VCC_TerritoryMemberKey(providers[0].Id, visns[0].Id);
            }
            private set;
        }

        /**
         * @description Create an instance of our test data with given default values
         *
         * @param blnIsRecurring true if we are creating recurring holidays, false otherwise
         * @param startDate Start date for searching for Holidays in tests
         * @param endDate End date for searching for Holidays in tests
         */
        public TestOperatingHoursHolidayData(Boolean blnIsRecurring, Date startDate, Date endDate) {
            this.blnIsRecurring = blnIsRecurring;
            this.startDate = startDate;
            this.endDate = endDate;
        }

        /**
         * @description Default Constructor
         */
        public TestOperatingHoursHolidayData() {
            this.blnIsRecurring = true; // default to true
            this.startDate = Date.today(); // default to today
            this.endDate = Date.today().addDays(60); // default to 2 months from now
        }
    }

    // This is NOT TestSetup as we are not inserting data into the database and the testSetup annotation does not retain
    // values of static variables across test methods so it is less efficient
    private static TestOperatingHoursHolidayData buildTestData() {
        return buildTestData(new TestOperatingHoursHolidayData(), true);
    }

    private static TestOperatingHoursHolidayData buildTestData(TestOperatingHoursHolidayData testData) {
        return buildTestData(testData, false);
    }

    @SuppressWarnings('PMD.CognitiveComplexity, PMD.CyclomaticComplexity')
    private static TestOperatingHoursHolidayData buildTestData(
        TestOperatingHoursHolidayData testData,
        Boolean blnPerfTest
    ) {
        testData.holidays = new List<Holiday>();
        Integer numRecords = blnPerfTest ? 12 : 1;
        List<String> monthNames = new List<String>{
            'January',
            'February',
            'March',
            'April',
            'May',
            'June',
            'July',
            'August',
            'September',
            'October',
            'November',
            'December'
        };
        for (Integer month = 0; month < numRecords; month++) {
            Holiday firstOfTheMonthHoliday = new Holiday();
            if (testData.blnIsRecurring) {
                firstOfTheMonthHoliday.IsRecurrence = true;
                firstOfTheMonthHoliday.IsAllDay = true;
                firstOfTheMonthHoliday.RecurrenceStartDate = Date.newInstance(2024, (blnPerfTest ? (month + 1) : 8), 1);
                firstOfTheMonthHoliday.RecurrenceType = 'RecursYearly';
                firstOfTheMonthHoliday.RecurrenceDayOfMonth = 1;
                firstOfTheMonthHoliday.RecurrenceMonthOfYear = (blnPerfTest ? monthNames[month] : 'August');
                firstOfTheMonthHoliday.ActivityDate = firstOfTheMonthHoliday.RecurrenceStartDate;
            } else {
                firstOfTheMonthHoliday.IsRecurrence = false;
                firstOfTheMonthHoliday.IsAllDay = true;
                firstOfTheMonthHoliday.ActivityDate = Date.newInstance(2024, (blnPerfTest ? (month + 1) : 8), 1);
            }
            testData.holidays.add((Holiday) VATEST_SObjectFactory.createSObject(firstOfTheMonthHoliday));
        }

        testData.opHours = new List<OperatingHours>();
        numRecords = blnPerfTest ? 10 : 1;
        for (Integer idx = 0; idx < numRecords; idx++) {
            testData.opHours.add(
                (OperatingHours) VATEST_SObjectFactory.createSObject(
                    new OperatingHours(Name = 'VISN ' + idx + 1 + ' Operating Hours', VCC_VISN__c = 'VISN ' + idx + 1)
                )
            );
        }

        testData.opHoursHolidays = new List<OperatingHoursHoliday>();
        // Each operatingHours has all 12 Holidays so that is a total of 10 * 12 = 120 OperatingHoursHoliday records
        for (OperatingHours opHours : testData.opHours) {
            for (Holiday holiday : testData.holidays) {
                OperatingHoursHoliday testVisnOpHoursHoliday = (OperatingHoursHoliday) VATEST_SObjectFactory.createSObject(
                    new OperatingHoursHoliday(
                        HolidayId = holiday.Id,
                        Holiday = holiday,
                        OperatingHoursId = opHours.Id,
                        OperatingHours = opHours
                    )
                );
                testData.opHoursHolidays.add(testVisnOpHoursHoliday);
            }
        }

        testData.visns = new List<ServiceTerritory>();
        Integer visnNum = 1;
        // create 20 VISNs, assigning 2 to each OperatingHours for performance test
        numRecords = blnPerfTest ? 2 : 1;
        for (Integer idx = 0; idx < numRecords; idx++) {
            for (OperatingHours opHours : testData.opHours) {
                // 10 records
                testData.visns.add(
                    (ServiceTerritory) VATEST_SObjectFactory.createSObject(
                        new ServiceTerritory(Name = 'VISN ' + visnNum++, OperatingHoursId = opHours.Id)
                    )
                );
            }
        }

        // Create 10 Providers per VISN so 100 if running performance test
        testData.providers = new List<ServiceResource>();
        numRecords = blnPerfTest ? 100 : 1;
        for (Integer idx = 0; idx < numRecords; idx++) {
            testData.providers.add(
                (ServiceResource) VATEST_SObjectFactory.createSObject(
                    new ServiceResource(IsActive = true, Name = 'Provider ' + (idx + 1))
                )
            );
        }

        testData.serviceTerritoryMembers = new List<ServiceTerritoryMember>();
        for (ServiceTerritory visn : testData.visns) {
            // 20 VISNs
            Integer providerIdx = 0;
            numRecords = (blnPerfTest ? 5 : 1);
            for (Integer idx = 0; idx < numRecords; idx++) {
                // add 5 providers to each VISN
                testData.serviceTerritoryMembers.add(
                    (ServiceTerritoryMember) VATEST_SObjectFactory.createSObject(
                        new ServiceTerritoryMember(
                            ServiceTerritoryId = visn.Id,
                            ServiceResourceId = testData.providers[providerIdx++].Id,
                            OperatingHoursId = visn.OperatingHoursId
                        )
                    )
                );
            }
        }

        VCC_OperatingHoursHolidayService.memoizedOpHoursHolidayRepo = (VCR_OperatingHoursHolidayRepo) new VATEST_StubBuilder(
                VCR_OperatingHoursHolidayRepo.class
            )
            .mockingMethodCall('fetchHolidaysForVISNOperatingHours')
            .withParameterTypes(Set<Id>.class)
            .withParameterValues(testData.opHoursIds)
            .returning(testData.opHoursHolidays)
            .defineStub();

        return testData;
    }

    /**
     * @description Test constructor - create an instance of VCC_OperatingHoursHolidayService
     */
    @IsTest
    static void unitItCreatesInstancePositive() {
        Test.startTest();
        VCC_OperatingHoursHolidayService hoursHolidayService;
        System.runAs(VCC_VCV_APPT_VIEW_ADMIN_USER) {
            hoursHolidayService = new VCC_OperatingHoursHolidayService();
        }
        Test.stopTest();
        Assert.isNotNull(hoursHolidayService, 'Expected a valid VCC_OperatingHoursHolidayService to be constructed.');
    }

    /**
     * @description Test initialization of memoized repo
     */
    @IsTest
    static void unitRepoInitPositive() {
        Test.startTest();
        System.runAs(VCC_VCV_APPT_VIEW_ADMIN_USER) {
            Assert.isNotNull(
                VCC_OperatingHoursHolidayService.opHoursHolidayRepo,
                'Expected OperatingHoursHoliday Repo to be initialized.'
            );
            Assert.areEqual(
                VCC_OperatingHoursHolidayService.opHoursHolidayRepo,
                VCC_OperatingHoursHolidayService.memoizedOpHoursHolidayRepo,
                'Expected memoizedOpHoursHolidayRepo to be initialized to opHoursHolidayRepo.'
            );
        }
        Test.stopTest();
    }

    /**
     * @description Test fetching of Operating Hours Holidays when input argument(s) are null
     *  Negative path - make sure invalid input is handled gracefully
     */
    @IsTest
    static void unitGetHolidayTimeSlotsForNullDateArgNegative() {
        Test.startTest();
        VCC_OperatingHoursHolidayService hoursHolidayService;
        Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> timeSlotsByKey;
        System.runAs(VCC_VCV_APPT_VIEW_ADMIN_USER) {
            hoursHolidayService = new VCC_OperatingHoursHolidayService();
            timeSlotsByKey = hoursHolidayService.getHolidayTimeSlotsForProvidersAndDates(null, null);
        }
        Test.stopTest();
        Assert.isNotNull(
            timeSlotsByKey,
            'Expected an empty Map of VCC_TimeSlotCollections, not a null value, for invalid VCC_DateRange input arguments.'
        );
    }

    /**
     * @description Test fetching of Operating Hours Holidays when ServiceTerritoryMembers is empty
     *  Negative path - make sure invalid input is handled gracefully
     */
    @IsTest
    static void unitConstructForEmptyServiceTerritoryMembersNegative() {
        Test.startTest();
        VCC_OperatingHoursHolidayService hoursHolidayService;
        System.runAs(VCC_VCV_APPT_VIEW_ADMIN_USER) {
            hoursHolidayService = new VCC_OperatingHoursHolidayService();
        }
        Test.stopTest();
        Assert.isNotNull(
            hoursHolidayService.serviceTerritoryMemberKeyToTimeSlotMap,
            'Expected map of ServiceTerritoryMemberKey to TimeSlot to be initialized & empty but not null as no ServiceTerritoryMember values are provided.'
        );
    }

    /**
     * @description Test fetching of Operating Hours Holidays when there are no Holidays for the given set of arguments
     *  Negative path - make sure no results are handled gracefully
     */
    @IsTest
    static void unitGetHolidayTimeSlotsForProvidersAndDatesNoDataFoundNegative() {
        TestOperatingHoursHolidayData testData = buildTestData();
        Test.startTest();
        VCC_OperatingHoursHolidayService hoursHolidayService;
        Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> timeSlotsByKey;
        System.runAs(VCC_VCV_APPT_VIEW_ADMIN_USER) {
            hoursHolidayService = new VCC_OperatingHoursHolidayService();
            timeSlotsByKey = hoursHolidayService.getHolidayTimeSlotsForProvidersAndDates(
                testData.dateRange,
                testData.serviceTerritoryMembers
            );
        }
        Test.stopTest();
        Assert.isNotNull(
            timeSlotsByKey,
            'Expected an empty map, not a null value, of VCC_TimeSlotCollections when there is no data for given arguments.'
        );
    }

    /**
     * @description Test fetching of Operating Hours Holidays when there are Holidays for the given set of arguments
     *  Happy path
     */
    @IsTest
    static void unitGetHolidayTimeSlotsForVisnsAndDatesPositive() {
        TestOperatingHoursHolidayData testData = buildTestData(
            new TestOperatingHoursHolidayData(true, Date.newInstance(2024, 7, 1), Date.newInstance(2024, 9, 1))
        );

        Test.startTest();
        VCC_OperatingHoursHolidayService hoursHolidayService;
        Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> timeSlotsByTerritoryMemberKeys;
        System.runAs(VCC_VCV_APPT_VIEW_ADMIN_USER) {
            hoursHolidayService = new VCC_OperatingHoursHolidayService();
            timeSlotsByTerritoryMemberKeys = hoursHolidayService.getHolidayTimeSlotsForProvidersAndDates(
                testData.dateRange,
                testData.serviceTerritoryMembers
            );
        }
        Test.stopTest();
        Assert.areEqual(
            1,
            timeSlotsByTerritoryMemberKeys.size(),
            'Expected a valid map of TimeSlotCollection values by VCC_TerritoryMemberKey for our OperatingHoursHoliday and test VISN'
        );

        Assert.areEqual(
            testData.opHoursHolidays[0].Holiday.ActivityDate,
            timeSlotsByTerritoryMemberKeys.get(testData.territoryMemberKey).timeSlots[0].startDateTime.dateGMT(),
            'Expected a valid map of VCC_TimeSlotCollections by VCC_TerritoryMemberKey for given ServiceTerritoryMember, Recurring OperatingHoursHoliday and test VISN'
        );
    }

    /**
     * @description Test fetching of Operating Hours Holidays when there are non-Recurring
     *     Holidays for the given set of arguments
     *  Happy path
     */
    @IsTest
    static void unitGetNonRecurringHolidayTimeSlotsForProvidersAndDatesPositive() {
        TestOperatingHoursHolidayData testData = buildTestData(
            new TestOperatingHoursHolidayData(false, Date.newInstance(2024, 7, 1), Date.newInstance(2024, 9, 1))
        );

        Test.startTest();
        VCC_OperatingHoursHolidayService hoursHolidayService;
        Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> timeSlotsByTerritoryMemberKeys;
        System.runAs(VCC_VCV_APPT_VIEW_ADMIN_USER) {
            hoursHolidayService = new VCC_OperatingHoursHolidayService();
            timeSlotsByTerritoryMemberKeys = hoursHolidayService.getHolidayTimeSlotsForProvidersAndDates(
                testData.dateRange,
                testData.serviceTerritoryMembers
            );
        }

        Test.stopTest();
        Assert.isNotNull(
            timeSlotsByTerritoryMemberKeys.get(testData.territoryMemberKey),
            'Expected a valid VCC_TimeSlotCollection to be returned for our ServiceTerritoryMember, OperatingHoursHoliday and test VISN'
        );

        Assert.areEqual(
            testData.opHoursHolidays[0].Holiday.ActivityDate,
            timeSlotsByTerritoryMemberKeys.get(testData.territoryMemberKey).timeSlots[0].startDateTime.dateGMT(),
            'Expected a valid map of VCC_TimeSlotCollections by VCC_TerritoryMemberKey for given ServiceTerritoryMember, OperatingHoursHoliday and test VISN'
        );
    }

    /**
     * @description Test fetching of Operating Hours Holidays when there are Holidays for the given set of arguments
     *      when Holiday falls on Start & End Dates
     *  Happy path
     */
    @IsTest
    static void unitGetHolidayTimeSlotsForProvidersAndEdgeDatesPositive() {
        TestOperatingHoursHolidayData testData = buildTestData(
            new TestOperatingHoursHolidayData(true, Date.newInstance(2024, 8, 1), Date.newInstance(2024, 8, 1))
        );
        Test.startTest();
        VCC_OperatingHoursHolidayService hoursHolidayService;
        Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> timeSlotsByTerritoryMemberKeys;
        System.runAs(VCC_VCV_APPT_VIEW_ADMIN_USER) {
            hoursHolidayService = new VCC_OperatingHoursHolidayService();
            timeSlotsByTerritoryMemberKeys = hoursHolidayService.getHolidayTimeSlotsForProvidersAndDates(
                testData.dateRange,
                testData.serviceTerritoryMembers
            );
        }
        Test.stopTest();
        Assert.areEqual(
            1,
            timeSlotsByTerritoryMemberKeys.size(),
            'Expected a valid map of TimeSlotCollection for our OperatingHoursHoliday, Test VISN & Start / End Dates that are the Holiday date'
        );

        Assert.areEqual(
            testData.opHoursHolidays[0].Holiday.ActivityDate,
            timeSlotsByTerritoryMemberKeys.get(testData.territoryMemberKey).timeSlots[0].startDateTime.dateGMT(),
            'Expected a valid map of VCC_TimeSlotCollections by VCC_TerritoryMemberKey  when Start & End Date match the date of the Holiday'
        );
    }

    /**
     * @description Performance test service
     */
    @IsTest
    static void perfGetHolidayTimeSlotsPositive() {
        TestOperatingHoursHolidayData testData = buildTestData(
            new TestOperatingHoursHolidayData(true, Date.newInstance(2024, 1, 1), Date.newInstance(2024, 6, 1)),
            true
        );

        Test.startTest();
        VCC_OperatingHoursHolidayService hoursHolidayService;
        Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> timeSlotsByTerritoryMemberKeys;
        System.runAs(VCC_VCV_APPT_VIEW_ADMIN_USER) {
            hoursHolidayService = new VCC_OperatingHoursHolidayService();
            timeSlotsByTerritoryMemberKeys = hoursHolidayService.getHolidayTimeSlotsForProvidersAndDates(
                testData.dateRange,
                testData.serviceTerritoryMembers
            );
        }
        Test.stopTest();
        // we created 20 VISNs and 5 Providers per VISN so that should be 100 TerritoryMemberKeys
        Assert.areEqual(
            100,
            timeSlotsByTerritoryMemberKeys.size(),
            'Expected a valid map of TimeSlotCollection for our OperatingHoursHoliday, Test VISN & Start / End Dates that are the Holiday date'
        );

        // now lets check holidays returned for a particular Provider & VISN
        ServiceResource provider = testData.providers[0];
        ServiceTerritory visn = testData.visns[0];
        VCC_TerritoryMemberKey key = new VCC_TerritoryMemberKey(provider.Id, visn.Id);
        VCC_TimeSlotCollection timeSlotCollection = timeSlotsByTerritoryMemberKeys.get(key);
        Assert.areEqual(
            6,
            timeSlotCollection.size(),
            'Expected 6 Holidays to be returned for our ServiceTerritoryMember for January - June with Holidays occurring every 1st of the month.'
        );
    }
}
