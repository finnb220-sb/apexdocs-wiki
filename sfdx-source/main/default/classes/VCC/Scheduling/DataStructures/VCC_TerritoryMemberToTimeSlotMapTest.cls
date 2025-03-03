/**
 * @description Test class for VCC_TerritoryMemberToTimeSlotMap.
 * @see VCC_TerritoryMemberToTimeSlotMap
 */
@IsTest
private with sharing class VCC_TerritoryMemberToTimeSlotMapTest {
    private static VCC_TerritoryMemberToTimeSlotMap systemUnderTest;

    private static final User MOLLY_MIN_ACCESS;

    private static final Shift EIGHT_HOUR_SHIFT;
    private static final DateTime JANUARY_FIRST_2024;

    static {
        //We want to be able to have the beginning of the year.
        JANUARY_FIRST_2024 = DateTime.newInstanceGmt(2024, 1, 1);
        EIGHT_HOUR_SHIFT = new Shift(StartTime = JANUARY_FIRST_2024, EndTime = JANUARY_FIRST_2024.addHours(8));
        MOLLY_MIN_ACCESS = VATEST_UserFactory.createMinAccessPersonaUser(false);
        MOLLY_MIN_ACCESS.TimeZoneSidKey = 'GMT';
    }

    /**
     * @description Asserts that the constructor throws an error when passed a null argument.
     */
    @IsTest
    static void unitConstructorThrowsErrorWhenPassedNullInputNegative() {
        String errorMessage;
        try {
            System.runAs(MOLLY_MIN_ACCESS) {
                systemUnderTest = new VCC_TerritoryMemberToTimeSlotMap(null);
            }
            Assert.fail('Expected an exception to be thrown when null input is passed to the constructor.');
        } catch (VCC_TerritoryMemberToTimeSlotMap.InvalidCalculationStateException invalidArgumentPassedToConstructor) {
            errorMessage = invalidArgumentPassedToConstructor.getMessage();
        }
        Assert.areEqual(
            VCC_TerritoryMemberToTimeSlotMap.NULL_PASSED_TO_CONSTRUCTOR,
            errorMessage,
            'Expected exception message to be set by constant member, \'NULL_PASSED_TO_CONSTRUCTOR\'.'
        );
    }

    /**
     * @description Tests the logic in the constructor.
     * Assert: Constructor creates a key and a value for each service territory member, in the internal map.
     * Assert: Constructor adds each ServiceTerritoryMembers' resource Id to the internal Set<Id> resourceIds.
     * Assert: Constructor adds each ServiceTerritoryMembers' ServiceTerritory Id to the internal Set<Id> territoryIds.
     */
    @IsTest
    static void unitConstructorPositive() {
        List<ServiceTerritoryMember> members = createTerritoryMembers(10);

        System.runAs(MOLLY_MIN_ACCESS) {
            systemUnderTest = new VCC_TerritoryMemberToTimeSlotMap(members);
        }
        Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> resultantMap = systemUnderTest.getMap();

        Boolean allMembersInstantiated = true;
        for (ServiceTerritoryMember member : members) {
            VCC_TerritoryMemberKey key = new VCC_TerritoryMemberKey(member);
            if (!resultantMap.containsKey(key) || resultantMap.get(key) == null) {
                allMembersInstantiated = false;
                break;
            }
        }
        Assert.isTrue(
            allMembersInstantiated,
            'Expected constructor to create a key and a value for each Service Territory Member.'
        );
        Assert.areEqual(
            members.size(),
            systemUnderTest.relatedResourceIds.size(),
            'Expected resourceId to be added to internal collection for each ServiceTerritoryMember passed into the constructor.'
        );
        Assert.areEqual(
            members.size(),
            systemUnderTest.relatedTerritoryIds.size(),
            'Expected ServiceTerritoryId to be added to internal collection for each ServiceTerritoryMember passed into the constructor.'
        );
    }

    /**
     * @description Asserts that adding to the internal map via \'addShiftToResultantMap\' normalizes a shift into a VCC_TimeSlot with no change to the underlying data.
     */
    @IsTest
    private static void unitItAddsShiftToInternalMapPositive() {
        List<ServiceTerritoryMember> members = createTerritoryMembers(1);
        ServiceTerritoryMember personWhoIsWorkingTheShift = members.get(0);
        VCC_TerritoryMemberKey key = new VCC_TerritoryMemberKey(personWhoIsWorkingTheShift);
        systemUnderTest = new VCC_TerritoryMemberToTimeSlotMap(members);

        Shift shiftToAdd = (Shift) VATEST_SObjectFactory.createSObject(
            new Shift(
                StartTime = EIGHT_HOUR_SHIFT.StartTime,
                EndTime = EIGHT_HOUR_SHIFT.EndTime,
                ServiceResourceId = personWhoIsWorkingTheShift.ServiceResourceId,
                ServiceTerritoryId = personWhoIsWorkingTheShift.ServiceTerritoryId
            )
        );
        System.runAs(MOLLY_MIN_ACCESS) {
            Test.startTest();
            systemUnderTest.putAllShiftsIntoResultantMap(
                new List<Shift>{ shiftToAdd },
                new VCC_DateRange(JANUARY_FIRST_2024, JANUARY_FIRST_2024.addHours(8))
            );
            Test.stopTest();
        }
        Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> resultantMap = systemUnderTest.getMap();
        VCC_TimeSlotCollection collectionInQuestion = resultantMap.get(key);
        Assert.areEqual(1, collectionInQuestion.size(), 'Expected only one shift to be added.');
        VCC_TimeSlot timeSlotInQuestion = collectionInQuestion.timeSlots.get(0);
        Assert.areEqual(
            shiftToAdd.StartTime,
            timeSlotInQuestion.startDateTime,
            'Expected there to be no change in start time to the slot when adding it to the map.'
        );
        Assert.areEqual(
            shiftToAdd.EndTime,
            timeSlotInQuestion.endDateTime,
            'Expected there to be no change in end time to the slot when adding it to the map. '
        );
    }

    /**
     * @description Asserts that the addShiftToResultantMap() method throws an error when there is no key for an expected ServiceTerritoryMember
     */
    @IsTest
    private static void unitItThrowsExceptionWheyKeyIsNotInMapNegative() {
        List<ServiceTerritoryMember> members = createTerritoryMembers(1);
        ServiceTerritoryMember personWhoIsWorkingTheShift = members.get(0);
        VCC_TerritoryMemberKey key = new VCC_TerritoryMemberKey(personWhoIsWorkingTheShift);
        systemUnderTest = new VCC_TerritoryMemberToTimeSlotMap(new List<ServiceTerritoryMember>());
        Shift shiftToAdd = (Shift) VATEST_SObjectFactory.createSObject(
            new Shift(
                StartTime = EIGHT_HOUR_SHIFT.StartTime,
                EndTime = EIGHT_HOUR_SHIFT.EndTime,
                ServiceResourceId = personWhoIsWorkingTheShift.ServiceResourceId,
                ServiceTerritoryId = personWhoIsWorkingTheShift.ServiceTerritoryId
            )
        );
        String errorMsg;
        System.runAs(MOLLY_MIN_ACCESS) {
            Test.startTest();
            try {
                systemUnderTest.addShiftToResultantMap(key, shiftToAdd);
                Assert.fail('Expected an exception to be thrown when trying to add to a null map.');
            } catch (VCC_TerritoryMemberToTimeSlotMap.InvalidCalculationStateException invalidStateException) {
                errorMsg = invalidStateException.getMessage();
            }
            Test.stopTest();
        }
        Assert.areEqual(
            VCC_TerritoryMemberToTimeSlotMap.NO_MEMBER_KEY_MSG,
            errorMsg,
            'Expected the error message of the exception to be set by internal constant \'NO_MEMBER_KEY_MSG\'.'
        );
    }

    /**
     * @description Asserts that the tested method throws an error when there is a shift with an invalid date range passed in.
     * I have no idea how this could happen as there are built in validations on the SObject but, better to test for it than not.
     */
    @IsTest
    private static void unitItThrowsExceptionWhenDateRangeOfShiftIsInvalidNegative() {
        List<ServiceTerritoryMember> members = createTerritoryMembers(1);
        ServiceTerritoryMember personWhoIsWorkingTheShift = members.get(0);
        VCC_TerritoryMemberKey key = new VCC_TerritoryMemberKey(personWhoIsWorkingTheShift);
        systemUnderTest = new VCC_TerritoryMemberToTimeSlotMap(
            new List<ServiceTerritoryMember>{ personWhoIsWorkingTheShift }
        );
        Shift shiftToAdd = (Shift) VATEST_SObjectFactory.createSObject(
            new Shift(
                StartTime = EIGHT_HOUR_SHIFT.EndTime,
                EndTime = EIGHT_HOUR_SHIFT.StartTime,
                ServiceResourceId = personWhoIsWorkingTheShift.ServiceResourceId,
                ServiceTerritoryId = personWhoIsWorkingTheShift.ServiceTerritoryId
            )
        );
        String errorMsg;
        Test.startTest();
        {
            System.runAs(MOLLY_MIN_ACCESS) {
                try {
                    systemUnderTest.addShiftToResultantMap(key, shiftToAdd);
                    Assert.fail('Expected an exception to be thrown when a Shift has an invalid date range.');
                } catch (VCC_TerritoryMemberToTimeSlotMap.InvalidCalculationStateException invalidStateException) {
                    errorMsg = invalidStateException.getMessage();
                }
            }
        }
        Test.stopTest();
        Assert.isTrue(
            errorMsg.contains(VCC_TerritoryMemberToTimeSlotMap.UNEXPECTED_EXCEPTION_MSG),
            'Expected the error message of the exception to contain string from internal constant \'UNEXPECTED_EXCEPTION_MSG\'.'
        );
        Assert.isTrue(
            errorMsg.contains(key.toString()),
            'Expected the error message of the exception to contain the VCC_TerritoryMemberKey passed to the method.'
        );
        Assert.isTrue(
            errorMsg.contains(VCC_DateRange.INVALID_START_END_DATE_MSG),
            'Expected the error message of the exception to contain the error message of the actual exception thrown.`VCC_DateRange.INVALID_START_END_DATE_MSG` '
        );
    }

    /**
     * @description Given a shift that extrapolates out past a leap year day...
     * Assert: Total Number of timeslots added to collection are correct.
     * Assert: The shift existing on the leap year day is added. Feb 29th
     * Assert: The time calculation is correct for the given date range.
     */
    @IsTest
    private static void funcItAddsExtrapolatedOutShiftsInRangeDuringLeapYearNegative() {
        List<ServiceTerritoryMember> members = createTerritoryMembers(1);
        ServiceTerritoryMember personWhoIsWorkingTheShift = members.get(0);
        VCC_TerritoryMemberKey key = new VCC_TerritoryMemberKey(personWhoIsWorkingTheShift);
        systemUnderTest = new VCC_TerritoryMemberToTimeSlotMap(members);
        DateTime feb28thOfLeapYear = DateTime.newInstanceGmt(2024, 2, 28, 9, 0, 0);
        DateTime endOfRecurrence = feb28thOfLeapYear.addHours(8).addDays(3);
        VCC_DateRange range = new VCC_DateRange(feb28thOfLeapYear, endOfRecurrence);
        String repeatingRule = 'RRULE:FREQ=DAILY;INTERVAL=1;COUNT=5;';
        Shift recurringShift = (Shift) VATEST_SObjectFactory.createSObject(
            new Shift(
                StartTime = feb28thOfLeapYear,
                EndTime = feb28thOfLeapYear.addHours(8),
                ServiceResourceId = personWhoIsWorkingTheShift.ServiceResourceId,
                ServiceTerritoryId = personWhoIsWorkingTheShift.ServiceTerritoryId,
                RecurrencePattern = repeatingRule,
                RecurrenceEndDate = endOfRecurrence.date(),
                Type = 'Recurring'
            )
        );
        Test.startTest();
        {
            System.runAs(MOLLY_MIN_ACCESS) {
                systemUnderTest.addRecurringShiftsToResultantMap(key, recurringShift, range);
            }
        }
        Test.stopTest();
        Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> resultantMap = systemUnderTest.getMap();
        VCC_TimeSlotCollection collectionInQuestion = resultantMap.get(key);
        Assert.areEqual(
            3,
            collectionInQuestion.size(),
            'Expected add Recurring shifts to parse and add exactly 3 time slots.'
        );
        Assert.areEqual(
            3 * 8 * 60,
            collectionInQuestion.getTimeInMinutes(),
            'Expected the collection to add 3, 8 hour shifts to the VCC_TimeSlotCollection Object.'
        );
        Assert.areEqual(
            Date.newInstance(2024, 2, 29),
            collectionInQuestion.timeSlots.get(1).startDateTime.date(),
            'Expected the Extrapolated shifts to be able to account for leap years.'
        );
    }

    /**
     * @description Given a date range that is a year long and a Shift that should extrapolate out a year....
     * Assert: 365 time slots are added to the internal collection
     * Assert: the correct amount of total time is calculated. 365 days * (8hours per day * 60 minutes per hour)
     */
    @IsTest
    private static void funcItAddsAllExtrapolatedShiftsInRangePositive() {
        List<ServiceTerritoryMember> members = createTerritoryMembers(1);
        ServiceTerritoryMember personWhoIsWorkingTheShift = members.get(0);
        VCC_TerritoryMemberKey key = new VCC_TerritoryMemberKey(personWhoIsWorkingTheShift);
        systemUnderTest = new VCC_TerritoryMemberToTimeSlotMap(members);

        DateTime endOfRecurrence = JANUARY_FIRST_2024.addHours(8).addDays(365);
        VCC_DateRange range = new VCC_DateRange(JANUARY_FIRST_2024, endOfRecurrence);
        String repeatingRule = 'RRULE:FREQ=DAILY;INTERVAL=1;COUNT=365;';
        List<Shift> recurringShifts = (List<Shift>) VATEST_SObjectFactory.createSObjects(
            new Shift(
                StartTime = JANUARY_FIRST_2024,
                EndTime = JANUARY_FIRST_2024.addHours(8),
                ServiceResourceId = personWhoIsWorkingTheShift.ServiceResourceId,
                ServiceTerritoryId = personWhoIsWorkingTheShift.ServiceTerritoryId,
                RecurrencePattern = repeatingRule,
                RecurrenceEndDate = endOfRecurrence.date(),
                Type = 'Recurring'
            ),
            1,
            false
        );
        Test.startTest();
        {
            System.runAs(MOLLY_MIN_ACCESS) {
                systemUnderTest.putAllShiftsIntoResultantMap(recurringShifts, range);
            }
        }
        Test.stopTest();
        Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> resultantMap = systemUnderTest.getMap();
        VCC_TimeSlotCollection collectionInQuestion = resultantMap.get(key);
        Assert.areEqual(
            365,
            collectionInQuestion.size(),
            'Expected add Recurring shifts to parse and add exactly 365 time slots.'
        );
        Assert.areEqual(
            365 * 8 * 60,
            collectionInQuestion.getTimeInMinutes(),
            'Expected the collection to add 365, 8 hour shifts to the VCC_TimeSlotCollection Object.'
        );
    }

    /**
     * @description Given a Shift with excluded dates that are in the given range, May 28th and 29th 2024..
     * Assert: These shifts are not added to the collection.
     * Assert: The time elapsed during these excluded dates is not added to the calculation of total time.
     */
    @IsTest
    private static void funcItAddsAllExtrapolatedShiftsInRangeWithExcludedDatesNegative() {
        //Construct members
        List<ServiceTerritoryMember> members = createTerritoryMembers(1);
        ServiceTerritoryMember personWhoIsWorkingTheShift = members.get(0);

        //Build Date Range and RRule
        DateTime startRange = DateTime.newInstance(2024, 5, 1);
        String next180DaysExceptMay28AndMay292024 = 'RRULE:FREQ=DAILY;INTERVAL=1;COUNT=180;||EXDATE;VALUE=DATE:20240528,20240529';
        DateTime endOfRecurrence = startRange.addHours(8).addDays(180);

        //Create the shift in the date range with the tested RRule
        List<Shift> recurringShifts = (List<Shift>) VATEST_SObjectFactory.createSObjects(
            new Shift(
                StartTime = startRange,
                EndTime = startRange.addHours(8),
                ServiceResourceId = personWhoIsWorkingTheShift.ServiceResourceId,
                ServiceTerritoryId = personWhoIsWorkingTheShift.ServiceTerritoryId,
                RecurrencePattern = next180DaysExceptMay28AndMay292024,
                RecurrenceEndDate = endOfRecurrence.date(),
                Type = 'Recurring'
            ),
            1,
            false
        );
        //Instantiate SUT
        systemUnderTest = new VCC_TerritoryMemberToTimeSlotMap(members);
        Test.startTest();
        {
            System.runAs(MOLLY_MIN_ACCESS) {
                systemUnderTest.putAllShiftsIntoResultantMap(
                    recurringShifts,
                    new VCC_DateRange(startRange, endOfRecurrence)
                );
            }
        }

        //Build the key to get the collection we added to.
        VCC_TerritoryMemberKey key = new VCC_TerritoryMemberKey(personWhoIsWorkingTheShift);

        DateTime may28 = DateTime.newInstance(2024, 5, 28);
        DateTime may29 = DateTime.newInstance(2024, 5, 28);

        Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> resultantMap = systemUnderTest.getMap();
        VCC_TimeSlotCollection collectionInQuestion = resultantMap.get(key);
        Boolean includesExcludedDates = false;
        for (VCC_TimeSlot curTimeSlot : collectionInQuestion.timeSlots) {
            if (curTimeSlot.startDateTime.date() == may28.date() || curTimeSlot.startDateTime.date() == may29.date()) {
                includesExcludedDates = true;
                break;
            }
        }
        Assert.isFalse(includesExcludedDates, 'Expected May 28th and May 29th, 2024 to be excluded.');
        Assert.areEqual(
            178 * 8 * 60,
            collectionInQuestion.getTimeInMinutes(),
            'Expected in a 180 day date range, with two days excluded, the time in minutes to be equal to 178 Days * (8hours * 60Minutes).'
        );
    }

    /**
     * @description Asserts that an error is thrown when passing a null list into the putAllShiftsIntoResultantMap method.
     */
    @IsTest
    private static void unitItThrowsAnErrorWhenTryingToAddNullShiftsNegative() {
        systemUnderTest = new VCC_TerritoryMemberToTimeSlotMap(new List<ServiceTerritoryMember>());
        String errorMessage;
        Test.startTest();
        {
            System.runAs(MOLLY_MIN_ACCESS) {
                try {
                    systemUnderTest.putAllShiftsIntoResultantMap(null, null);
                    Assert.fail('Expected an exception to be thrown');
                } catch (VCC_TerritoryMemberToTimeSlotMap.InvalidCalculationStateException invalidCalculationState) {
                    errorMessage = invalidCalculationState.getMessage();
                }
            }
        }
        Assert.isTrue(
            errorMessage.contains(VCC_TerritoryMemberToTimeSlotMap.NULL_SHIFT_MSG),
            'Expected the error thrown to contain the predefined \'NULL_SHIFT_MSG\' constant.'
        );
    }

    /**
     * @description private helper method for creating test data.
     * @param count count of TerritoryMembers we want to create
     *
     * @return `List<ServiceTerritoryMember>` List of STM's that we are using to test.
     */
    private static List<ServiceTerritoryMember> createTerritoryMembers(Integer count) {
        List<ServiceTerritoryMember> members = new List<ServiceTerritoryMember>();
        for (Integer counter = 0; counter < count; counter++) {
            ServiceResource resource = (ServiceResource) VATEST_SObjectFactory.createSObject(
                new ServiceResource(),
                false
            );
            ServiceTerritory territory = (ServiceTerritory) VATEST_SObjectFactory.createSObject(
                new ServiceTerritory(),
                false
            );
            members.add(
                (ServiceTerritoryMember) VATEST_SObjectFactory.createSObject(
                    new ServiceTerritoryMember(ServiceResourceId = resource.Id, ServiceTerritoryId = territory.Id),
                    false
                )
            );
        }
        return members;
    }
}
