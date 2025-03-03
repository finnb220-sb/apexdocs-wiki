/**
 * @description Test class for the VCC_AppointmentUtilizationService.
 */
@IsTest
private with sharing class VCC_AppointmentUtilizationServiceTest {
    private static final VCC_AppointmentUtilizationService SYSTEM_UNDER_TEST;
    private static final User MOLLY_MIN_ACCESS;
    private static final User SYDNEY_SYS_ADMIN;

    private static final DateTime JAN_FIRST_2024;
    private static final VCC_DateRange ONE_WEEK_FROM_JAN_FIRST;

    private static final String RRULE_FOR_NEXT_180_DAYS = 'RRULE:FREQ=DAILY;INTERVAL=1;COUNT=180;';
    private static final VCC_TimeSlot EIGHT_HOUR_SLOT;

    static {
        JAN_FIRST_2024 = DateTime.newInstance(2024, 1, 1);
        ONE_WEEK_FROM_JAN_FIRST = new VCC_DateRange(JAN_FIRST_2024, JAN_FIRST_2024.addDays(7));
        MOLLY_MIN_ACCESS = VATEST_UserFactory.createMinAccessPersonaUser(false);
        MOLLY_MIN_ACCESS.TimeZoneSidKey = UserInfo.getTimeZone().getID();
        SYSTEM_UNDER_TEST = new VCC_AppointmentUtilizationService();
        SYDNEY_SYS_ADMIN = new VATEST_UserBuilder()
            .withUserProfile('System Administrator')
            .withStandardData()
            .setFields(User.TimeZoneSidKey, UserInfo.getTimeZone().getID())
            .withPermissionSet('VCC_VCV_Appointment_Viewer_Administrator')
            .build(true);
        EIGHT_HOUR_SLOT = new VCC_TimeSlot(JAN_FIRST_2024, JAN_FIRST_2024.addHours(8));
    }

    /**
     * @description Asserts that the repo method gets called when called 'getServiceTerritoryMemberKeyToAvailableTimeSlotMap'.
     */
    @IsTest
    private static void unitItCallsRepoMethodPositive() {
        VATEST_StubTuple shiftRepoStubTuple = (VATEST_StubTuple) new VATEST_StubBuilder(VCR_ShiftRepo.class)
            .mockingMethodCall('getConfirmedShiftsRelatedToServiceTerritoryMembersInDateRange')
            .withParameterTypes(VCC_DateRange.class, Set<Id>.class, Set<Id>.class)
            .withParameterValues(ONE_WEEK_FROM_JAN_FIRST, new Set<Id>(), new Set<Id>())
            .returning(new List<Shift>())
            .defineStubTuple();
        VCR_ResourceAbsenceRepo absenceRepoRepo = (VCR_ResourceAbsenceRepo) new VATEST_StubBuilder(
                VCR_ResourceAbsenceRepo.class
            )
            .mockingMethodCall('getAbsencesInDateRangeForServiceResourcesInList')
            .withParameterTypes(Set<Id>.class, VCC_DateRange.class)
            .withParameterValues(new Set<Id>(), ONE_WEEK_FROM_JAN_FIRST)
            .returning(new List<ResourceAbsence>())
            .defineStub();
        VTC_RepoFactory.reposByObjName.put('ResourceAbsence', absenceRepoRepo);
        VTC_RepoFactory.reposByObjName.put('Shift', (VCR_ShiftRepo) shiftRepoStubTuple.stubbedClass);
        Test.startTest();
        {
            System.runAs(MOLLY_MIN_ACCESS) {
                SYSTEM_UNDER_TEST.getServiceTerritoryMemberKeyToAvailableTimeSlotMap(
                    new List<ServiceTerritoryMember>(),
                    ONE_WEEK_FROM_JAN_FIRST
                );
            }
        }

        Assert.isTrue(
            shiftRepoStubTuple.assertAllMockedMethodsWereCalled(),
            'Expected getConfirmedShiftsRelatedToServiceTerritoryMembersInDateRange to be called.'
        );
    }

    /**
     * @description Asserts that given a List<ServiceTerritoryMember>, the service returns a map with a key for each  member passed in.
     */
    @IsTest
    private static void unitServiceReturnsAMapWithAKeyAndValueForEveryServTerMemberPositive() {
        VCC_DateRange oneWeekFromToday = new VCC_DateRange(JAN_FIRST_2024, JAN_FIRST_2024.addDays(7));
        ServiceTerritory territory = (ServiceTerritory) VATEST_SObjectFactory.createSObject(
            new ServiceTerritory(),
            false
        );
        //Create serviceTerritoryMembers
        List<ServiceTerritoryMember> members = VATEST_SObjectFactory.createSObjects(
            new ServiceTerritoryMember(ServiceTerritoryId = territory.Id),
            100,
            false
        );
        //Relate a unique Service Resource to each Service Territory Member
        Set<Id> mockedTerritoryIds = new Set<Id>();
        Set<Id> mockedResourceIds = new Set<Id>();
        for (ServiceTerritoryMember member : members) {
            member.ServiceResourceId = ((ServiceResource) VATEST_SObjectFactory.createSObject(
                    new ServiceResource(),
                    false
                ))
                .Id;
            mockedTerritoryIds.add(member.ServiceTerritoryId);
            mockedResourceIds.add(member.ServiceResourceId);
        }
        //Mock the repo to return an empty list. For this test we dont care about putting parsing shifts.
        VCR_ShiftRepo shiftRepo = (VCR_ShiftRepo) new VATEST_StubBuilder(VCR_ShiftRepo.class)
            .mockingMethodCall('getConfirmedShiftsRelatedToServiceTerritoryMembersInDateRange')
            .withParameterTypes(VCC_DateRange.class, Set<Id>.class, Set<Id>.class)
            .withParameterValues(oneWeekFromToday, mockedTerritoryIds, mockedResourceIds)
            .returning(new List<Shift>())
            .defineStub();
        VCR_ResourceAbsenceRepo absenceRepoRepo = (VCR_ResourceAbsenceRepo) new VATEST_StubBuilder(
                VCR_ResourceAbsenceRepo.class
            )
            .mockingMethodCall('getAbsencesInDateRangeForServiceResourcesInList')
            .withParameterTypes(Set<Id>.class, VCC_DateRange.class)
            .withParameterValues(mockedResourceIds, oneWeekFromToday)
            .returning(new List<ResourceAbsence>())
            .defineStub();
        VTC_RepoFactory.reposByObjName.put('ResourceAbsence', absenceRepoRepo);
        VTC_RepoFactory.reposByObjName.put('Shift', shiftRepo);
        VCC_AppointmentUtilizationService.operatingHoursHolidayService = (VCC_OperatingHoursHolidayService) new VATEST_StubBuilder(
                VCC_OperatingHoursHolidayService.class
            )
            .mockingMethodCall('getHolidayTimeSlotsForProvidersAndDates')
            .withParameterTypes(VCC_DateRange.class, List<ServiceTerritoryMember>.class)
            .withParameterValues(oneWeekFromToday, members)
            .returning(new Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection>())
            .defineStub();
        VCC_TerritoryMemberToTimeSlotMap result;
        Test.startTest();
        {
            System.runAs(MOLLY_MIN_ACCESS) {
                result = SYSTEM_UNDER_TEST.getServiceTerritoryMemberKeyToAvailableTimeSlotMap(
                    members,
                    oneWeekFromToday
                );
            }
        }
        Test.stopTest();
        Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> resultantMap = result.getMap();
        Assert.areEqual(
            members.size(),
            resultantMap.keySet().size(),
            'Expected there to be exactly one key for each ServiceTerritoryMember passed in.'
        );
        Boolean containsAllKeysAndValues = true;
        for (ServiceTerritoryMember memberPassedIn : members) {
            if (
                !resultantMap.containsKey(new VCC_TerritoryMemberKey(memberPassedIn)) &&
                resultantMap.get(new VCC_TerritoryMemberKey(memberPassedIn)) != null
            ) {
                containsAllKeysAndValues = false;
                break;
            }
        }
        Assert.isTrue(
            containsAllKeysAndValues,
            'Expected \'getServiceTerritoryMemberKeyToAvailableTimeSlotMap\' to return a map with keys and values for each member passed in.'
        );
    }

    /**
     * @description functional test that passes in an assorted list of Territory members and Shifts.
     * Asserts: Given each member has shifts for 5 days a week for an entire year, that will result in 5*52 time slots being added.
     * Asserts: Given the above, each shift being 8 hours long, and each hour being 60 minutes long,that will result in a total time calculation of 5*8*60*52 minutes of total available time. (124800 minutes or 2080 hours)
     */
    @IsTest
    private static void funcItAddsAllShiftsAndCalculatesPotentialTimesCorrectlyForEachMemberOnALeapYearNegative() {
        ServiceTerritory terr = (ServiceTerritory) VATEST_SObjectFactory.createSObject(new ServiceTerritory(), false);
        List<ServiceTerritoryMember> members = VATEST_SObjectFactory.createSObjects(
            new ServiceTerritoryMember(ServiceTerritoryId = terr.Id),
            5,
            false
        );

        //Mock our date range to be for a year
        DateTime mondayJanFirstNineAm = DateTime.newInstance(2024, 1, 1, 0, 0, 0);
        VCC_DateRange mockedDateRange = new VCC_DateRange(mondayJanFirstNineAm, mondayJanFirstNineAm.addDays(364));
        //RRule containing logic to repeat mon-friday, until jan 1, 2025
        String mondayThroughFriday8HoursShiftsUntilNextYear = 'RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,WE,FR,TH;UNTIL=20250101T000000Z;';

        List<Shift> shifts = new List<Shift>();
        Set<Id> mockedTerritoryIds = new Set<Id>();
        Set<Id> mockedResourceIds = new Set<Id>();
        for (ServiceTerritoryMember member : members) {
            member.ServiceResourceId = ((ServiceResource) VATEST_SObjectFactory.createSObject(
                    new ServiceResource(),
                    false
                ))
                .Id;
            //Since theres nothing stopping users from creating duplicate overlapping shifts....
            //Add two duplicate shifts to prove that overlapping shifts do not get counted twice;
            //Each member is working 9-5, 5 days a week for a year
            shifts.addAll(
                (List<Shift>) VATEST_SObjectFactory.createSObjects(
                    new Shift(
                        StartTime = mockedDateRange.startDateTime,
                        EndTime = mockedDateRange.startDateTime.addHours(8),
                        ServiceResourceId = member.ServiceResourceId,
                        ServiceTerritoryId = member.ServiceTerritoryId,
                        Type = 'Recurring',
                        //Monday through friday for 180 days
                        RecurrencePattern = mondayThroughFriday8HoursShiftsUntilNextYear,
                        RecurrenceEndDate = mondayJanFirstNineAm.addDays(365).date()
                    ),
                    2,
                    false
                )
            );
            mockedTerritoryIds.add(member.ServiceTerritoryId);
            mockedResourceIds.add(member.ServiceResourceId);
        }

        //Mock/Stub Shift repo
        VCR_ShiftRepo shiftRepo = (VCR_ShiftRepo) new VATEST_StubBuilder(VCR_ShiftRepo.class)
            .mockingMethodCall('getConfirmedShiftsRelatedToServiceTerritoryMembersInDateRange')
            .withParameterTypes(VCC_DateRange.class, Set<Id>.class, Set<Id>.class)
            .withParameterValues(mockedDateRange, mockedTerritoryIds, mockedResourceIds)
            .returning(shifts)
            .defineStub();
        //Mock/stub absence repo
        VCR_ResourceAbsenceRepo absenceRepoRepo = (VCR_ResourceAbsenceRepo) new VATEST_StubBuilder(
                VCR_ResourceAbsenceRepo.class
            )
            .mockingMethodCall('getAbsencesInDateRangeForServiceResourcesInList')
            .withParameterTypes(Set<Id>.class, VCC_DateRange.class)
            .withParameterValues(mockedResourceIds, mockedDateRange)
            .returning(new List<ResourceAbsence>())
            .defineStub();
        VTC_RepoFactory.reposByObjName.put('ResourceAbsence', absenceRepoRepo);
        VTC_RepoFactory.reposByObjName.put('Shift', shiftRepo);

        //Mock Operatinghours holiday service
        VCC_OperatingHoursHolidayService operatingHoursHolidayService = (VCC_OperatingHoursHolidayService) new VATEST_StubBuilder(
                VCC_OperatingHoursHolidayService.class
            )
            .mockingMethodCall('getHolidayTimeSlotsForProvidersAndDates')
            .withParameterTypes(VCC_DateRange.class, List<ServiceTerritoryMember>.class)
            .withParameterValues(mockedDateRange, members)
            .returning(new Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection>())
            .defineStub();
        VCC_AppointmentUtilizationService.operatingHoursHolidayService = operatingHoursHolidayService;
        Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> resultantMap;
        Test.startTest();
        {
            System.runAs(MOLLY_MIN_ACCESS) {
                resultantMap = SYSTEM_UNDER_TEST.getServiceTerritoryMemberKeyToAvailableTimeSlotMap(
                        members,
                        mockedDateRange
                    )
                    .getMap();
            }
        }
        Test.stopTest();
        for (VCC_TerritoryMemberKey key : resultantMap.keySet()) {
            VCC_TimeSlotCollection timeSlotsForCurrentMember = resultantMap.get(key);
            Assert.areEqual(
                5 * 52,
                timeSlotsForCurrentMember.size(),
                'Expected their to be 5 slots a week for all 52 weeks in the year.'
            );
            Assert.areEqual(
                5 * 8 * 60 * 52,
                timeSlotsForCurrentMember.getTimeInMinutes(),
                'Expected the time calculation to add up to 2080 hours or 124800 minutes. 5 shifts a week, each 8 hours long, each hour being 60 minutes, 52 weeks out of the year.'
            );
        }
    }

    /**
     * @description Given a person who works in two visn's (ServiceTerritory) with duplicate shifts
     * 2 shifts (Monday-Friday 9-5 at both VISN's), And an absence from Monday to Thursday.
     * Assert: Available time is counted for both VISN's and only for the remaining Friday Shift.
     * Assert: Only one time slot is in each of the Service TerritoryMembers collections
     * Assert: That the only time slot lands on the expected date (Friday)
     */
    @IsTest
    private static void funcItRemoveAbsencesNegative() {
        ServiceResource personWhoIsWorking = (ServiceResource) VATEST_SObjectFactory.createSObject(
            new ServiceResource()
        );

        List<ServiceTerritoryMember> members = VATEST_SObjectFactory.createSObjects(
            new ServiceTerritoryMember(
                ServiceResourceId = personWhoIsWorking.Id,
                ServiceTerritoryId = ((ServiceTerritory) VATEST_SObjectFactory.createSObject(new ServiceTerritory())).Id
            ),
            1,
            false
        );
        //Add another place they work at, just to make ensure both collections are effected.
        members.add(
            (ServiceTerritoryMember) VATEST_SObjectFactory.createSObject(
                new ServiceTerritoryMember(
                    ServiceResourceId = personWhoIsWorking.Id,
                    ServiceTerritoryId = ((ServiceTerritory) VATEST_SObjectFactory.createSObject(
                            new ServiceTerritory()
                        ))
                        .Id
                )
            )
        );
        List<Shift> mockedShifts = new List<Shift>();

        DateTime mondayJanFirst = DateTime.newInstanceGmt(2024, 1, 1, 9, 0, 0);
        VCC_DateRange mockedDateRange = new VCC_DateRange(mondayJanFirst, mondayJanFirst.addDays(6));
        String mondayThroughFriday8HoursShiftsUntilNextYear = 'RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,WE,FR,TH;UNTIL=20250101T000000Z;';
        Set<Id> mockedTerritoryIds = new Set<Id>();
        Set<Id> mockedResourceIds = new Set<Id>();
        for (ServiceTerritoryMember member : members) {
            mockedShifts.addAll(
                (List<Shift>) VATEST_SObjectFactory.createSObjects(
                    new Shift(
                        StartTime = mondayJanFirst,
                        EndTime = mondayJanFirst.addHours(8),
                        ServiceResourceId = member.ServiceResourceId,
                        ServiceTerritoryId = member.ServiceTerritoryId,
                        Type = 'Recurring',
                        //Monday through friday for 180 days
                        RecurrencePattern = mondayThroughFriday8HoursShiftsUntilNextYear,
                        RecurrenceEndDate = mondayJanFirst.addYears(1).date()
                    ),
                    1,
                    false
                )
            );
            mockedTerritoryIds.add(member.ServiceTerritoryId);
            mockedResourceIds.add(member.ServiceResourceId);
        }
        List<ResourceAbsence> mockedAbsences = new List<ResourceAbsence>{
            new ResourceAbsence(
                ResourceId = personWhoIsWorking.Id,
                Start = mondayJanFirst,
                End = mondayJanFirst.addDays(4)
            )
        };

        VCR_ShiftRepo shiftRepo = (VCR_ShiftRepo) new VATEST_StubBuilder(VCR_ShiftRepo.class)
            .mockingMethodCall('getConfirmedShiftsRelatedToServiceTerritoryMembersInDateRange')
            .withParameterTypes(VCC_DateRange.class, Set<Id>.class, Set<Id>.class)
            .withParameterValues(mockedDateRange, mockedTerritoryIds, mockedResourceIds)
            .returning(mockedShifts)
            .defineStub();

        VCR_ResourceAbsenceRepo absenceRepoRepo = (VCR_ResourceAbsenceRepo) new VATEST_StubBuilder(
                VCR_ResourceAbsenceRepo.class
            )
            .mockingMethodCall('getAbsencesInDateRangeForServiceResourcesInList')
            .withParameterTypes(Set<Id>.class, VCC_DateRange.class)
            .withParameterValues(mockedResourceIds, mockedDateRange)
            .returning(mockedAbsences)
            .defineStub();
        VTC_RepoFactory.reposByObjName.put('Shift', shiftRepo);

        VTC_RepoFactory.reposByObjName.put('ResourceAbsence', absenceRepoRepo);
        //Mock operating hours holiday service to not return anything
        VCC_OperatingHoursHolidayService operatingHoursHolidayService = (VCC_OperatingHoursHolidayService) new VATEST_StubBuilder(
                VCC_OperatingHoursHolidayService.class
            )
            .mockingMethodCall('getHolidayTimeSlotsForProvidersAndDates')
            .withParameterTypes(VCC_DateRange.class, List<ServiceTerritoryMember>.class)
            .withParameterValues(mockedDateRange, members)
            .returning(new Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection>())
            .defineStub();
        VCC_AppointmentUtilizationService.operatingHoursHolidayService = operatingHoursHolidayService;
        Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> resultantMap;
        Test.startTest();
        {
            System.runAs(MOLLY_MIN_ACCESS) {
                resultantMap = SYSTEM_UNDER_TEST.getServiceTerritoryMemberKeyToAvailableTimeSlotMap(
                        members,
                        mockedDateRange
                    )
                    .getMap();
            }
        }

        for (VCC_TimeSlotCollection currentCollection : resultantMap.values()) {
            Assert.areEqual(
                8 * 60,
                currentCollection.getTimeInMinutes(),
                'Expected the Monday through thursday absence to be removed from each collection.'
            );
            Assert.areEqual(1, currentCollection.size(), 'Expected all other days except one (Friday) to be removed.');
            Assert.areEqual(
                5,
                currentCollection.timeSlots.get(0).startDateTime.day(),
                'Expected all other days except one (Friday) to be removed.'
            );
        }
    }

    /**
     * @description Given a person who works monday through friday from jan1 2024 - jan 1 2025
     * Jan 1 9-5 being marked a holiday....
     * Assert: Available time is counted correctly and holiday jan 1 is removed.
     * Assert: Only one time slot is in the collection.
     * Assert: That the only time slot lands on the expected date Jan 2.
     */
    @IsTest
    private static void funcItRemovesHolidayPositive() {
        ServiceResource personWhoIsWorking = (ServiceResource) VATEST_SObjectFactory.createSObject(
            new ServiceResource()
        );

        List<ServiceTerritoryMember> members = VATEST_SObjectFactory.createSObjects(
            new ServiceTerritoryMember(
                ServiceResourceId = personWhoIsWorking.Id,
                ServiceTerritoryId = ((ServiceTerritory) VATEST_SObjectFactory.createSObject(new ServiceTerritory())).Id
            ),
            1,
            false
        );

        List<Shift> mockedShifts = new List<Shift>();

        DateTime mondayJanFirstNineAm = DateTime.newInstanceGmt(2024, 1, 1, 9, 0, 0);
        VCC_DateRange mockedDateRange = new VCC_DateRange(mondayJanFirstNineAm, mondayJanFirstNineAm.addDays(6));
        String mondayThroughFriday8HoursShiftsUntilNextYear = 'RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,WE,FR,TH;UNTIL=20250101T000000Z;';
        Set<Id> mockedTerritoryIds = new Set<Id>();
        Set<Id> mockedResourceIds = new Set<Id>();
        for (ServiceTerritoryMember member : members) {
            mockedShifts.addAll(
                (List<Shift>) VATEST_SObjectFactory.createSObjects(
                    new Shift(
                        StartTime = mondayJanFirstNineAm,
                        EndTime = mondayJanFirstNineAm.addHours(8),
                        ServiceResourceId = member.ServiceResourceId,
                        ServiceTerritoryId = member.ServiceTerritoryId,
                        Type = 'Recurring',
                        //Monday through friday for 180 days
                        RecurrencePattern = mondayThroughFriday8HoursShiftsUntilNextYear,
                        RecurrenceEndDate = mondayJanFirstNineAm.addYears(1).date()
                    ),
                    1,
                    false
                )
            );
            mockedTerritoryIds.add(member.ServiceTerritoryId);
            mockedResourceIds.add(member.ServiceResourceId);
        }

        //Mock shift repo to return shifts.
        VCR_ShiftRepo shiftRepo = (VCR_ShiftRepo) new VATEST_StubBuilder(VCR_ShiftRepo.class)
            .mockingMethodCall('getConfirmedShiftsRelatedToServiceTerritoryMembersInDateRange')
            .withParameterTypes(VCC_DateRange.class, Set<Id>.class, Set<Id>.class)
            .withParameterValues(mockedDateRange, mockedTerritoryIds, mockedResourceIds)
            .returning(mockedShifts)
            .defineStub();

        //Mock absence repo to return nothing.
        VCR_ResourceAbsenceRepo absenceRepoRepo = (VCR_ResourceAbsenceRepo) new VATEST_StubBuilder(
                VCR_ResourceAbsenceRepo.class
            )
            .mockingMethodCall('getAbsencesInDateRangeForServiceResourcesInList')
            .withParameterTypes(Set<Id>.class, VCC_DateRange.class)
            .withParameterValues(mockedResourceIds, mockedDateRange)
            .returning(new List<ResourceAbsence>())
            .defineStub();
        VTC_RepoFactory.reposByObjName.put('Shift', shiftRepo);
        VTC_RepoFactory.reposByObjName.put('ResourceAbsence', absenceRepoRepo);

        //Create  time slot that represents jan 1 as a holiday.
        VCC_TimeSlot holidayTimeSlot = new VCC_TimeSlot(mondayJanFirstNineAm, mondayJanFirstNineAm.addDays(4));
        VCC_TimeSlotCollection mockedTimeSlotCollection = new VCC_TimeSlotCollection();
        mockedTimeSlotCollection.add(holidayTimeSlot);
        //Mock the return response for the operating hours holiday service.
        Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> mockedTerritoryMemberKeyToHolidayTimeSlotMap = new Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection>{
            new VCC_TerritoryMemberKey(members.get(0)) => mockedTimeSlotCollection
        };
        VCC_OperatingHoursHolidayService operatingHoursHolidayService = (VCC_OperatingHoursHolidayService) new VATEST_StubBuilder(
                VCC_OperatingHoursHolidayService.class
            )
            .mockingMethodCall('getHolidayTimeSlotsForProvidersAndDates')
            .withParameterTypes(VCC_DateRange.class, List<ServiceTerritoryMember>.class)
            .withParameterValues(mockedDateRange, members)
            .returning(mockedTerritoryMemberKeyToHolidayTimeSlotMap)
            .defineStub();
        VCC_AppointmentUtilizationService.operatingHoursHolidayService = operatingHoursHolidayService;
        Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> resultantMap;
        Test.startTest();
        {
            System.runAs(MOLLY_MIN_ACCESS) {
                resultantMap = SYSTEM_UNDER_TEST.getServiceTerritoryMemberKeyToAvailableTimeSlotMap(
                        members,
                        mockedDateRange
                    )
                    .getMap();
            }
        }
        Assert.areEqual(
            1,
            resultantMap.size(),
            'Expected exactly one key and one value to be added to the resultant map.'
        );
        for (VCC_TimeSlotCollection currentCollection : resultantMap.values()) {
            Assert.areEqual(
                8 * 60,
                currentCollection.getTimeInMinutes(),
                'Expected the Monday through thursday absence to be removed from each collection.'
            );
            Assert.areEqual(1, currentCollection.size(), 'Expected all other days except one (Friday) to be removed.');
            Assert.areEqual(
                5,
                currentCollection.timeSlots.get(0).startDateTime.day(),
                'Expected all other days except one (Friday) to be removed.'
            );
        }
    }

    //Start functional integration tests for the whole service.

    /**
     * @description Given a day where all Mocked Service Territories work...
     * Assert: a record was created in  memory for each member passed in.
     * Assert: The Date is correct on the resultant records.
     * Assert: The Number of net slots is correct on each record.
     */
    @IsTest
    private static void intgnItCreatesUtilizationRecordsInMemoryPositive() {
        VCC_DateRange mockedDateRange = new VCC_DateRange(JAN_FIRST_2024, JAN_FIRST_2024.addHours(23).addMinutes(59));
        TestData mockedData = createData(true, mockedDateRange);

        List<VCC_Appointment_Utilization__c> resultantRecords;
        Test.startTest();
        {
            System.runAs(SYDNEY_SYS_ADMIN) {
                VCC_TerritoryMemberToTimeSlotMap territoryMemberKeyToTimeSlotMap = SYSTEM_UNDER_TEST.getServiceTerritoryMemberKeyToAvailableTimeSlotMap(
                    mockedData.members,
                    mockedDateRange
                );

                //Get ServiceAppointments
                VCC_TerritoryMemberToAppointmentsMap territoryMemberToCompletedAndNonCompletedAppointments = SYSTEM_UNDER_TEST.getTerritoryMemberToAppointmentsMap(
                    mockedData.mockedResourceIds,
                    mockedData.mockedTerritoryIds,
                    mockedDateRange
                );

                Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> terMemberKeyToTimeSlotCollectionMap = territoryMemberKeyToTimeSlotMap.getMap();

                resultantRecords = SYSTEM_UNDER_TEST.getResultantRecords(
                    terMemberKeyToTimeSlotCollectionMap,
                    territoryMemberToCompletedAndNonCompletedAppointments,
                    mockedDateRange
                );
            }
        }
        Assert.areEqual(
            10,
            resultantRecords.size(),
            'Expected to return exactly 1 record for each ServiceTerritoryMember passed in.'
        );

        Integer expectedTotalSlots = (8 * 2);

        Boolean correctDates = true;
        String incorrectDateMsg = 'Expected The date of each record to be equal to the start of the ranges date! Incorrect records:';

        Boolean correctTotalSlots = true;
        String incorrectTotalSlotsMsg = 'Expected The total number of slots for each utilization record. Incorrect records:';

        for (VCC_Appointment_Utilization__c record : resultantRecords) {
            if (record.VCC_Date__c.dayOfYear() != 1) {
                correctDates = false;
                incorrectDateMsg += '\n\t' + record;
            }
            if (record.VCC_Net_Available_Slots__c != expectedTotalSlots) {
                correctTotalSlots = false;
                incorrectTotalSlotsMsg += '\n\t' + record;
            }
        }
        Assert.isTrue(correctDates, incorrectDateMsg);
        Assert.isTrue(correctTotalSlots, incorrectTotalSlotsMsg);
    }

    /**
     * @description Given a day where all Mocked Service Territories are on holiday Feb 1 k...
     * Assert: a record was created in  memory for each member passed in.
     * Assert: The Date is correct on the resultant records.
     * Assert: The Number of net slots is correct on each record.
     */
    @IsTest
    private static void intgnItCreatesUtilizationRecordsInMemoryNegative() {
        VCC_DateRange mockedDateRange = new VCC_DateRange(
            JAN_FIRST_2024.addMonths(1),
            JAN_FIRST_2024.addMonths(1).addHours(23).addMinutes(59)
        );
        TestData mockedData = createData(true, mockedDateRange);

        List<VCC_Appointment_Utilization__c> resultantRecords;
        Test.startTest();
        {
            System.runAs(SYDNEY_SYS_ADMIN) {
                VCC_TerritoryMemberToTimeSlotMap territoryMemberKeyToTimeSlotMap = SYSTEM_UNDER_TEST.getServiceTerritoryMemberKeyToAvailableTimeSlotMap(
                    mockedData.members,
                    mockedDateRange
                );

                //Get ServiceAppointments
                VCC_TerritoryMemberToAppointmentsMap territoryMemberToCompletedAndNonCompletedAppointments = SYSTEM_UNDER_TEST.getTerritoryMemberToAppointmentsMap(
                    mockedData.mockedResourceIds,
                    mockedData.mockedTerritoryIds,
                    mockedDateRange
                );

                Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> terMemberKeyToTimeSlotCollectionMap = territoryMemberKeyToTimeSlotMap.getMap();

                resultantRecords = SYSTEM_UNDER_TEST.getResultantRecords(
                    terMemberKeyToTimeSlotCollectionMap,
                    territoryMemberToCompletedAndNonCompletedAppointments,
                    mockedDateRange
                );
            }
        }
        Assert.areEqual(
            0,
            resultantRecords.size(),
            'Expected to return exactly 0 records as none of the providers are working!'
        );
    }

    @IsTest
    private static void funcItTriesToCreateCorrectRecordsAndDeleteExistingPositive() {
        VCC_DateRange mockedDateRange = new VCC_DateRange(
            JAN_FIRST_2024.addMonths(1),
            JAN_FIRST_2024.addMonths(1).addHours(23).addMinutes(59)
        );
        TestData mockedData = createData(true, mockedDateRange);
        VATEST_StubTuple utilRepoTuple;
        System.runAs(SYDNEY_SYS_ADMIN) {
            //Do exactly what the tested method does so that we can mock the DML
            VCC_TerritoryMemberToTimeSlotMap territoryMemberKeyToTimeSlotMap = SYSTEM_UNDER_TEST.getServiceTerritoryMemberKeyToAvailableTimeSlotMap(
                mockedData.members,
                mockedDateRange
            );

            //Get
            VCC_TerritoryMemberToAppointmentsMap territoryMemberToCompletedAndNonCompletedAppointments = SYSTEM_UNDER_TEST.getTerritoryMemberToAppointmentsMap(
                mockedData.mockedResourceIds,
                mockedData.mockedTerritoryIds,
                mockedDateRange
            );

            Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> terMemberKeyToTimeSlotCollectionMap = territoryMemberKeyToTimeSlotMap.getMap();

            List<VCC_Appointment_Utilization__c> expectedRecords = SYSTEM_UNDER_TEST.getResultantRecords(
                terMemberKeyToTimeSlotCollectionMap,
                territoryMemberToCompletedAndNonCompletedAppointments,
                mockedDateRange
            );

            utilRepoTuple = new VATEST_StubBuilder(VCR_AppointmentUtilizationRepo.class)
                .mockingMethodCall('getAppointmentUtilizationRecordsWithinRangeRelatedToTerritoryMembers')
                .withParameterTypes(Set<id>.class, Set<Id>.class, VCC_DateRange.class)
                .withParameterValues(mockedData.mockedResourceIds, mockedData.mockedTerritoryIds, mockedDateRange)
                //Doing this just to assert that it gets called.
                .returning(new List<VCC_Appointment_Utilization__c>())
                .mockingMethodCall('doDelete')
                .withParameterTypes(List<SObject>.class)
                .withParameterValues(new List<VCC_Appointment_Utilization__c>())
                .returning()
                .mockingMethodCall('doCreate')
                .withParameterTypes(List<SObject>.class)
                .withParameterValues(expectedRecords)
                .returning()
                .defineStubTuple();
            VCC_AppointmentUtilizationService.appointmentUtilRepo = (VCR_AppointmentUtilizationRepo) utilRepoTuple.stubbedClass;
            Test.startTest();
            {
                SYSTEM_UNDER_TEST.calculateUtilizationForTerritoryMembersInRange(mockedData.members, mockedDateRange);
            }
        }
        Assert.isTrue(
            utilRepoTuple.assertAllMockedMethodsWereCalled(),
            'Expected all the mocked methods in the VCR_AppointmentUtilizationRepo to be called!'
        );
    }

    /**
     * @description Makes 1 Service resource tied to 100 Service Territories as Service Territory members.
     * They work the max of 180 days every day. While this is not life like, it gives us the opportunity to...
     * 1. Load test. Make sure our calculations dont time out, even in the synchronous limits.
     * 2. Ability to assert later in the tests that disqualifying slots are removed from EVERY territory member that they effected.
     * 3. Gives us the ability to not have to insert multiple users for multiple Service Resources.
     * 4. Given the complexity of the scheduler data model, there is something to be said about easy to understand assertions.
     *    @return `TestData` Returns an object with everything we need to mock and stub.
     *    @param doMock Boolean determining whether to set up the mocks for the caller.
     *    @param mockedDateRange `VCC_DateRange` Range parameter we are telling the mocks to expect.
     */
    private static TestData createData(Boolean doMock, VCC_DateRange mockedDateRange) {
        ServiceResource personWhoIsWorkingTheShift = (ServiceResource) VATEST_SObjectFactory.createSObject(
            new ServiceResource(Name = 'TestPerson', RelatedRecordId = SYDNEY_SYS_ADMIN.Id, IsActive = true),
            false
        );
        OperatingHours fakeOpHours = (OperatingHours) VATEST_SObjectFactory.createSObject(
            new OperatingHours(Name = 'Fake Operating hours'),
            false
        );

        Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> fakeHolidayMap = new Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection>();

        List<ServiceTerritory> placesInWhichTheyWork = (List<ServiceTerritory>) VATEST_SObjectFactory.createSObjects(
            new ServiceTerritory(Name = 'TestTerritory', IsActive = true, OperatingHoursId = fakeOpHours.Id),
            10,
            false
        );
        List<ResourceAbsence> absences = new List<ResourceAbsence>{
            (ResourceAbsence) VATEST_SObjectFactory.createSObject(
                new ResourceAbsence(
                    ResourceId = personWhoIsWorkingTheShift.Id,
                    Start = JAN_FIRST_2024.addDays(8),
                    End = JAN_FIRST_2024.addDays(9).addMinutes(-1)
                ),
                false
            )
        };
        List<ServiceTerritoryMember> members = new List<ServiceTerritoryMember>();
        List<Shift> shifts = new List<Shift>();
        Set<Id> mockedTerritoryIds = new Set<Id>();
        Set<Id> mockedResourceIds = new Set<Id>();
        VCC_TimeSlotCollection fakeFebFirstTimeSlot = new VCC_TimeSlotCollection();
        fakeFebFirstTimeSlot.add(new VCC_TimeSlot(JAN_FIRST_2024.addMonths(1), JAN_FIRST_2024.addMonths(1).addDays(1)));
        for (ServiceTerritory territory : placesInWhichTheyWork) {
            ServiceTerritoryMember member = (ServiceTerritoryMember) VATEST_SObjectFactory.createSObject(
                new ServiceTerritoryMember(
                    EffectiveStartDate = JAN_FIRST_2024,
                    EffectiveEndDate = JAN_FIRST_2024.addYears(3),
                    ServiceTerritoryId = territory.Id,
                    ServiceResourceId = personWhoIsWorkingTheShift.Id
                ),
                false
            );
            members.add(member);
            shifts.add(
                new Shift(
                    StartTime = JAN_FIRST_2024,
                    EndTime = JAN_FIRST_2024.addHours(8),
                    ServiceResourceId = personWhoIsWorkingTheShift.Id,
                    ServiceTerritoryId = territory.Id,
                    RecurrencePattern = RRULE_FOR_NEXT_180_DAYS,
                    RecurrenceEndDate = JAN_FIRST_2024.addDays(180).date(),
                    Status = 'Confirmed',
                    Type = 'Recurring'
                )
            );
            //Mock a holiday on feb first
            fakeHolidayMap.put(new VCC_TerritoryMemberKey(member), fakeFebFirstTimeSlot);

            mockedTerritoryIds.add(member.ServiceTerritoryId);
            mockedResourceIds.add(member.ServiceResourceId);
        }
        if (doMock) {
            VCR_ShiftRepo shiftRepo = (VCR_ShiftRepo) new VATEST_StubBuilder(VCR_ShiftRepo.class)
                .mockingMethodCall('getConfirmedShiftsRelatedToServiceTerritoryMembersInDateRange')
                .withParameterTypes(VCC_DateRange.class, Set<Id>.class, Set<Id>.class)
                .withParameterValues(mockedDateRange, mockedTerritoryIds, mockedResourceIds)
                .returning(shifts)
                .defineStub();
            //Mock/stub absence repo
            VCR_ResourceAbsenceRepo absenceRepoRepo = (VCR_ResourceAbsenceRepo) new VATEST_StubBuilder(
                    VCR_ResourceAbsenceRepo.class
                )
                .mockingMethodCall('getAbsencesInDateRangeForServiceResourcesInList')
                .withParameterTypes(Set<Id>.class, VCC_DateRange.class)
                .withParameterValues(mockedResourceIds, mockedDateRange)
                .returning(new List<ResourceAbsence>())
                .defineStub();

            //Mock OperatingHours holiday service
            VCC_AppointmentUtilizationService.operatingHoursHolidayService = (VCC_OperatingHoursHolidayService) new VATEST_StubBuilder(
                    VCC_OperatingHoursHolidayService.class
                )
                .mockingMethodCall('getHolidayTimeSlotsForProvidersAndDates')
                .withParameterTypes(VCC_DateRange.class, List<ServiceTerritoryMember>.class)
                .withParameterValues(mockedDateRange, members)
                .returning(fakeHolidayMap)
                .defineStub();
            VTC_RepoFactory.reposByObjName.put('ResourceAbsence', absenceRepoRepo);
            VTC_RepoFactory.reposByObjName.put('Shift', shiftRepo);
        }
        TestData tstData = new TestData();
        tstData.mockedTerritoryIds = mockedTerritoryIds;
        tstData.mockedResourceIds = mockedResourceIds;
        tstData.members = members;
        tstData.shifts = shifts;
        tstData.absences = absences;
        return tstData;
    }

    /**
     * @description inner utility class for mapping test data together for ease of mocking.
     */
    private class TestData {
        Set<Id> mockedTerritoryIds;
        Set<Id> mockedResourceIds;
        List<ServiceTerritoryMember> members;
        List<Shift> shifts;
        List<ResourceAbsence> absences;
        List<OperatingHoursHoliday> holidays;

        private TestData() {
            this.holidays = new List<OperatingHoursHoliday>();
        }
    }
}
