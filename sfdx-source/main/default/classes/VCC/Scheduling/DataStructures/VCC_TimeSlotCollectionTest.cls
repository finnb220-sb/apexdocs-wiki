/**
 * @description Test class for the VCC_TimeSlotCollection class.
 * @see VCC_TimeSlotCollection
 * @see VCC_TimeSlot
 * @see VCC_AppointmentUtilizationService
 */
@IsTest
private with sharing class VCC_TimeSlotCollectionTest {
    private static VCC_TimeSlotCollection systemUnderTest;
    private static final User MOLLY_MIN_ACCESS;
    private static final DateTime START_RANGE;
    private static final VCC_TimeSlot EIGHT_HOUR_SLOT;

    static {
        START_RANGE = DateTime.newInstanceGmt(2024, 1, 1);
        EIGHT_HOUR_SLOT = new VCC_TimeSlot(START_RANGE, START_RANGE.addHours(8));
        MOLLY_MIN_ACCESS = VATEST_UserFactory.createMinAccessPersonaUser(false);
        MOLLY_MIN_ACCESS.TimeZoneSidKey = UserInfo.getTimeZone().getID();
    }

    /**
     * @description Tests argument-less constructor.
     * Asserts: The Internal collection timeSlots is instantiated.
     * Asserts: the totalTimeInMs is set to 0
     */
    @IsTest
    private static void unitArglessConstructorSetsInternalVariablesPositive() {
        System.runAs(MOLLY_MIN_ACCESS) {
            systemUnderTest = new VCC_TimeSlotCollection();
        }
        Assert.areEqual(
            0,
            systemUnderTest.timeSlots.size(),
            'Expected the argument-less constructor to instantiate the timeSlots set.'
        );
        Assert.areEqual(
            0,
            systemUnderTest.totalTimeMS,
            'Expected totalTimeMS to be set to 0 upon object instantiation.'
        );
    }

    /**
     * @description Asserts that the overloaded constructor that takes a Shift, calls
     * argument-less constructor.
     */
    @IsTest
    private static void unitConstructorSetsInternalVariablesWhenPassedAnArgumentPositive() {
        System.runAs(MOLLY_MIN_ACCESS) {
            systemUnderTest = new VCC_TimeSlotCollection(new Shift());
        }
        Assert.areEqual(
            0,
            systemUnderTest.timeSlots.size(),
            'Expected the constructor instantiate the timeSlots List.'
        );
        Assert.areEqual(
            0,
            systemUnderTest.totalTimeMS,
            'Expected totalTimeMS to be set to 0 upon object instantiation.'
        );
    }

    /**
     * @description Asserts the constructor adds the Shift to the internal collection.
     */
    @IsTest
    private static void unitConstructorAddsShiftToInternalCollectionPositive() {
        System.runAs(MOLLY_MIN_ACCESS) {
            systemUnderTest = new VCC_TimeSlotCollection(
                new Shift(StartTime = EIGHT_HOUR_SLOT.startDateTime, EndTime = EIGHT_HOUR_SLOT.endDateTime)
            );
        }

        Assert.areEqual(
            1,
            systemUnderTest.timeSlots.size(),
            'Expected the  constructor to add the shift to the timeSlot list.'
        );
        Assert.areEqual(
            EIGHT_HOUR_SLOT,
            systemUnderTest.timeSlots.get(0),
            'Expected the TimeSlot added to be identical to the one passed to the constructor.'
        );
        Assert.areEqual(
            EIGHT_HOUR_SLOT.getTimeInRange(),
            systemUnderTest.totalTimeMS,
            'Expected totalTimeMS to be equal to the ms in an 8 hour time slot.'
        );
        Assert.areEqual(1, systemUnderTest.shiftDescriptions.size(), 'Expected shiftDescriptions to be populated');
        String expectedShiftDescription =
            EIGHT_HOUR_SLOT.startDateTime.format(VCC_TimeSlotCollection.JAVA_SIMPLE_DATE_FORMATTING_STRING) +
            '-' +
            EIGHT_HOUR_SLOT.endDateTime.format(VCC_TimeSlotCollection.JAVA_SIMPLE_DATE_FORMATTING_STRING);
        Assert.areEqual(
            expectedShiftDescription,
            systemUnderTest.concatDescriptions(),
            'Expected there to be a single Description when concatenating descriptions'
        );
    }

    /**
     * @description Tests that the add function corrects the internal time slots when adding Time slots that overlap.
     * Asserts: The time calculation is equal to the expected value.
     * Asserts: The Add function corrects existing time slots as opposed to adding overlapping ones.
     */
    @IsTest
    private static void unitAddCorrectlyAdjustOverlappingTimeSlotsNegative() {
        // 8 hour or 480 minute shift
        Shift overlappedShift = (Shift) VATEST_SObjectFactory.createSObject(
            new Shift(StartTime = START_RANGE, EndTime = START_RANGE.addHours(8)),
            false
        );
        //Overlapping shift, only 1 hour or 60 minutes should be added.
        Shift overlappingShift = (Shift) VATEST_SObjectFactory.createSObject(
            new Shift(StartTime = START_RANGE.addHours(-1), EndTime = START_RANGE.addHours(8)),
            false
        );
        //exists inside of shiftA & B should not be added to the collection
        Shift shiftExistingInsideOf = (Shift) VATEST_SObjectFactory.createSObject(
            new Shift(StartTime = START_RANGE.addHours(2), EndTime = START_RANGE.addHours(7)),
            false
        );

        //Exists before should be added an additional 480
        Shift shiftExistingBeforeOthers = (Shift) VATEST_SObjectFactory.createSObject(
            new Shift(StartTime = START_RANGE.addDays(-1), EndTime = START_RANGE.addDays(-1).addHours(8)),
            false
        );
        System.runAs(MOLLY_MIN_ACCESS) {
            systemUnderTest = new VCC_TimeSlotCollection(overlappedShift);
            systemUnderTest.add(overlappingShift);
            systemUnderTest.add(shiftExistingInsideOf);
            systemUnderTest.add(shiftExistingBeforeOthers);
        }

        Long expectedTotal = 1020; //ShiftA 480+ shiftE 480+ 60Shiftb
        Assert.areEqual(
            expectedTotal,
            systemUnderTest.getTimeInMinutes(),
            'Expected totalTime in minutes to be incremented to 1020. 560 minutes for a 9 hour shift and 480 for an 8 hour shift.'
        );
        Assert.areEqual(
            2,
            systemUnderTest.size(),
            'Expected add to adjust overlapping time slots and to not add time slots that are already existing'
        );
        Assert.isFalse(
            systemUnderTest.timeSlots.contains(new VCC_TimeSlot(overlappedShift.StartTime, overlappedShift.EndTime)),
            'Expected Shift start and end times to be revised to match start and end times of ' + overlappingShift + '.'
        );
        Assert.isTrue(
            systemUnderTest.timeSlots.contains(new VCC_TimeSlot(overlappingShift.StartTime, overlappingShift.EndTime)),
            'Expected overlapping shift to placed into collection.'
        );
        Assert.isTrue(
            systemUnderTest.timeSlots.contains(
                new VCC_TimeSlot(shiftExistingBeforeOthers.StartTime, shiftExistingBeforeOthers.EndTime)
            ),
            'Expected the shift that has no overlap with the others that were added to the collection, to be added.'
        );
    }

    /**
     * @description Adds time slots and asserts that their time is correctly calculated by VCC_TimeSlotCollection.
     */
    @IsTest
    private static void unitAddCorrectlyAddsTimePositive() {
        systemUnderTest = new VCC_TimeSlotCollection();
        Long expectedTime = 0;
        System.runAs(MOLLY_MIN_ACCESS) {
            for (Integer counter = 100; counter > 0; counter--) {
                VCC_TimeSlot timeSlot = new VCC_TimeSlot(
                    START_RANGE.addDays(counter),
                    START_RANGE.addDays(counter).addHours(8)
                );
                expectedTime += timeSlot.getTimeInRange();
                systemUnderTest.add(timeSlot);
            }
        }
        Assert.areEqual(
            expectedTime,
            systemUnderTest.totalTimeMS,
            'Expected total time to be the sum of the ranges of all time slots added.'
        );
    }

    /**
     * @description Asserts that no matter the order in which we add time slots, this collection is ALWAYS sorted.
     */
    @IsTest
    private static void unitCollectionIsSortedNegative() {
        systemUnderTest = new VCC_TimeSlotCollection();
        //Test the worst case of opposite sort order.
        System.runAs(MOLLY_MIN_ACCESS) {
            for (Integer counter = 100; counter > 0; counter--) {
                systemUnderTest.add(
                    new VCC_TimeSlot(
                        EIGHT_HOUR_SLOT.startDateTime.addDays(counter),
                        EIGHT_HOUR_SLOT.endDateTime.addDays(counter)
                    )
                );
            }
        }
        List<VCC_TimeSlot> manuallySortedTimeSlots = new List<VCC_TimeSlot>(systemUnderTest.timeSlots);
        manuallySortedTimeSlots.sort();
        Boolean allAreInSameOrder = true;
        for (Integer counter; counter < systemUnderTest.size(); counter++) {
            if (manuallySortedTimeSlots.get(counter) != systemUnderTest.timeSlots.get(counter)) {
                allAreInSameOrder = false;
                break;
            }
        }
        Assert.isTrue(
            allAreInSameOrder,
            'Expected the internal timeSlots collection to stay sorted without having to explicitly call .sort()'
        );
    }

    /**
     * @description Creates 100 duplicate shifts, and tries to add them all to
     * the VCC_TimeSlotCollection object. Asserts that only 1 is added.
     */
    @IsTest
    private static void unitItDoesNotAddDuplicateSlotsNegative() {
        List<Shift> shifts = (List<Shift>) VATEST_SObjectFactory.createSObjects(
            new Shift(StartTime = START_RANGE, EndTime = START_RANGE.addHours(8)),
            100,
            false
        );
        systemUnderTest = new VCC_TimeSlotCollection();
        System.runAs(MOLLY_MIN_ACCESS) {
            Test.startTest();
            for (Shift curShift : shifts) {
                systemUnderTest.add(curShift);
            }
        }
        Test.stopTest();
        Assert.areEqual(1, systemUnderTest.size(), 'Expected collection to not add duplicate timeslots');
    }

    /**
     * @description Asserts that when passing in a time slot that exactly matches one in the internal collection to the filterOutTimeSlots method,
     * that it is matching time slot is removed.
     */
    @IsTest
    private static void unitFilterOutTimeSlotsCorrectlyRemovesTimeSlotWhenTheyAreEquivalentPositive() {
        systemUnderTest = new VCC_TimeSlotCollection();
        List<VCC_TimeSlot> excludedTimeSlots = new List<VCC_TimeSlot>{ EIGHT_HOUR_SLOT };
        VCC_TimeSlot timeSlotTomorrow = new VCC_TimeSlot(START_RANGE.addDays(1), START_RANGE.addDays(1).addHours(8));
        systemUnderTest.add(EIGHT_HOUR_SLOT);
        systemUnderTest.add(timeSlotTomorrow);
        System.runAs(MOLLY_MIN_ACCESS) {
            Test.startTest();
            systemUnderTest.filterOutTimeSlots(excludedTimeSlots);
            Test.stopTest();
        }
        Assert.areEqual(
            1,
            systemUnderTest.size(),
            'Expected time slot to be removed when calling \'filterOutTimeSlots\' with a collection including a timeSlot that encompasses the timeslots inside the object.'
        );
        Assert.areEqual(
            timeSlotTomorrow.getTimeInRange(),
            systemUnderTest.totalTimeMS,
            'Expected the TotalTimeinMS to be equal to the only VCC_TimeSlot left inside the collection.'
        );
    }

    /**
     * @description Asserts that when passing in a time slot that overlaps time slots in the internal collection, that they are removed.
     */
    @IsTest
    private static void unitFilterOutTimeSlotsCorrectlyRemovesTimeSlotTimeSlotExistsInExclusionRangePositive() {
        systemUnderTest = new VCC_TimeSlotCollection();
        List<VCC_TimeSlot> excludedTimeSlots = new List<VCC_TimeSlot>{
            new VCC_TimeSlot(START_RANGE, START_RANGE.addDays(8))
        };
        VCC_TimeSlot timeSlotTomorrow = new VCC_TimeSlot(START_RANGE.addDays(1), START_RANGE.addDays(1).addHours(8));
        systemUnderTest.add(new VCC_TimeSlot(START_RANGE.addHours(1), START_RANGE.addHours(7)));
        systemUnderTest.add(timeSlotTomorrow);
        System.runAs(MOLLY_MIN_ACCESS) {
            Test.startTest();
            systemUnderTest.filterOutTimeSlots(excludedTimeSlots);
            Test.stopTest();
        }
        Assert.areEqual(0, systemUnderTest.totalTimeMS, 'Expected the TotalTimeinMS to be reset to 0');

        Assert.areEqual(
            0,
            systemUnderTest.size(),
            'Expected time slot to be removed when calling \'filterOutTimeSlots\' with a collection including a timeSlot existing in the current object.'
        );
    }

    /**
     * @description Asserts that passing in an excluded time slot that exists inside of a time slot in the internal collection to the filterOutTimeSlots method,
     * that the effected time in the slot is removed, and the time slot is split into the remaining available parts.
     */
    @IsTest
    private static void unitFilterOutTimeSlotsCorrectlyRemovesTimeWhenExclusionaryTimeSlotInsideCurrentPositive() {
        //Exclusionary TimeSlot 12 - 1 pm
        //Current TimeSlot 8 am - 5 pm
        //Expect 2 TimeSlots 8 am - 12 pm, 1 pm - 5 pm & a reduction in TimeSlot minutes by 60
        systemUnderTest = new VCC_TimeSlotCollection();
        systemUnderTest.add(EIGHT_HOUR_SLOT);
        List<VCC_TimeSlot> excludedSlots = new List<VCC_TimeSlot>();
        excludedSlots.add(new VCC_TimeSlot(START_RANGE.addHours(4), START_RANGE.addHours(5)));
        Long prevTotalTimeMins = systemUnderTest.getTimeInMinutes();
        System.runAs(MOLLY_MIN_ACCESS) {
            Test.startTest();
            systemUnderTest.filterOutTimeSlots(excludedSlots);
            Test.stopTest();
        }
        Assert.areEqual(
            2,
            systemUnderTest.timeSlots.size(),
            'Expected an additional TimeSlot to be added for time after Exclusionary Slot'
        );
        Assert.areEqual(
            prevTotalTimeMins - 60,
            systemUnderTest.getTimeInMinutes(),
            'Expected Total Time to be reduced by 1 hour for Exclusionary TimeSlot'
        );
    }

    /**
     * @description Asserts that the exclusionary time slot removes all overlapping time in existing times slots
     * when passed into the filterOutTimeSlots method
     */
    @IsTest
    private static void unitFilterOutTimeSlotsCorrectlyRemovesTimeWhenCurrentTimeSlotOverlapsExclusionaryTimeSlotPositive() {
        //Current time slot 9 - 5
        //Exclusionary time slot (dr appt) from 9 - 1pm
        //1-5pm
        //Expect Current TimeSlot to be reduced to a single timeslot: 1-5 pm and a reduction in TimeSlot minutes to 4 * 60 = 240
        systemUnderTest = new VCC_TimeSlotCollection();
        systemUnderTest.add(new VCC_TimeSlot(START_RANGE, START_RANGE.addHours(8)));
        List<VCC_TimeSlot> excludedSlots = new List<VCC_TimeSlot>();
        excludedSlots.add(new VCC_TimeSlot(START_RANGE.addMinutes(-1), START_RANGE.addHours(4)));
        System.runAs(MOLLY_MIN_ACCESS) {
            Test.startTest();
            systemUnderTest.filterOutTimeSlots(excludedSlots);
            Test.stopTest();
        }
        Assert.areEqual(
            1,
            systemUnderTest.timeSlots.size(),
            'Expected existing TimeSlot to be modified when calling \'filterOutTimeSlots\' including a TimeSlot that overlaps an existing TimeSlot'
        );
        Assert.areEqual(
            240,
            systemUnderTest.getTimeInMinutes(),
            'Expected TotalTimeInMS to be reduced to 4 hours for Exclusionary TimeSlot that overlaps existing TimeSlot'
        );
    }

    /**
     * @description Asserts that passing in an excluded time slot that exists inside of a time slot in the internal collection to the filterOutTimeSlots method,
     * that the effected time in the slot is removed, and the time slot is split into the remaining available parts.
     */
    @IsTest
    private static void unitFilterOutTimeSlotsCorrectlyRemovesTimeWhenCurrentTimeSlotOverlapsExclusionaryTimeSlotStartTimePositive() {
        //Current time slot 8 - 12
        //Exclusionary time slot (dr appt) from 9 - 1 pm
        //8-9 am
        //Expect Current TimeSlot to be reduced to a single timeslot: 8-9 am and a reduction in TimeSlot minutes to 1 * 60 = 60
        systemUnderTest = new VCC_TimeSlotCollection();
        systemUnderTest.add(new VCC_TimeSlot(START_RANGE, START_RANGE.addHours(4)));
        List<VCC_TimeSlot> excludedSlots = new List<VCC_TimeSlot>();
        excludedSlots.add(new VCC_TimeSlot(START_RANGE.addHours(1), START_RANGE.addHours(5)));
        System.runAs(MOLLY_MIN_ACCESS) {
            Test.startTest();
            systemUnderTest.filterOutTimeSlots(excludedSlots);
            Test.stopTest();
        }
        Assert.areEqual(
            1,
            systemUnderTest.timeSlots.size(),
            'Expected existing TimeSlot to be modified when calling \'filterOutTimeSlots\' including a TimeSlot that overlaps an existing TimeSlot'
        );
        Assert.areEqual(
            60,
            systemUnderTest.getTimeInMinutes(),
            'Expected TotalTimeInMS to be reduced by 59 minutes for Exclusionary TimeSlot that overlaps existing TimeSlot'
        );
    }

    /**
     * @description Asserts binary search returns the correct index when the the overlapping time slot is first in the list.
     */
    @IsTest
    private static void unitBinarySearchReturnsCorrectIndexEarlyDatePositive() {
        systemUnderTest = new VCC_TimeSlotCollection();
        for (Integer counter = 1; counter < 1000; counter++) {
            systemUnderTest.timeSlots.add(
                new VCC_TimeSlot(START_RANGE.addDays(counter), START_RANGE.addDays(counter).addHours(8))
            );
        }
        Integer expectedIndex = 0;
        VCC_TimeSlot timeSlotOverlapping = new VCC_TimeSlot(
            START_RANGE.addDays(expectedIndex + 1).addHours(1),
            START_RANGE.addDays(expectedIndex + 1).addHours(7)
        );
        Integer result;
        System.runAs(MOLLY_MIN_ACCESS) {
            result = systemUnderTest.findIndexOfOverlappingTimeSlotBinarySearch(timeSlotOverlapping);
        }
        Assert.areEqual(expectedIndex, result, 'Expected Binary search to find the overlapping time slot.');
    }

    /**
     * @description Asserts binary Search returns the correct index when it is exactly half way through the array.
     */
    @IsTest
    private static void unitBinarySearchReturnsCorrectIndexMidDatePositive() {
        systemUnderTest = new VCC_TimeSlotCollection();
        for (Integer counter = 1; counter < 1000; counter++) {
            systemUnderTest.timeSlots.add(
                new VCC_TimeSlot(START_RANGE.addDays(counter), START_RANGE.addDays(counter).addHours(8))
            );
        }
        Integer expectedIndex = 500;
        VCC_TimeSlot timeSlotOverlapping = new VCC_TimeSlot(
            START_RANGE.addDays(expectedIndex + 1).addHours(-1),
            START_RANGE.addDays(expectedIndex + 1).addHours(7)
        );

        Integer result;
        System.runAs(MOLLY_MIN_ACCESS) {
            result = systemUnderTest.binarySearch(timeSlotOverlapping, true);
        }
        Assert.areEqual(
            expectedIndex,
            result,
            'Expected Binary search to find the overlapping time slot when the TimeSlot were looking for overlaps.'
        );
    }

    /**
     * @description Asserts that binary Search returns the correct index when it is in the top half of the array.
     */
    @IsTest
    private static void unitBinarySearchReturnsCorrectIndexLateDatePositive() {
        systemUnderTest = new VCC_TimeSlotCollection();
        for (Integer counter = 1; counter < 1000; counter++) {
            systemUnderTest.timeSlots.add(
                new VCC_TimeSlot(START_RANGE.addDays(counter), START_RANGE.addDays(counter).addHours(8))
            );
        }

        Integer expectedIndex = 742;
        VCC_TimeSlot timeSlotOverlapping = new VCC_TimeSlot(
            START_RANGE.addDays(expectedIndex + 1).addHours(-1),
            START_RANGE.addDays(expectedIndex + 1).addHours(7)
        );

        Integer result;
        System.runAs(MOLLY_MIN_ACCESS) {
            result = systemUnderTest.binarySearch(timeSlotOverlapping, true);
        }
        Assert.areEqual(
            expectedIndex,
            result,
            'Expected Binary search to find the overlapping time slot when the TimeSlot were looking for overlaps.'
        );
    }

    /**
     * @description Asserts that our findIndexOfOverlapping returns -1 when there is no overlapping Time slot.
     */
    @IsTest
    private static void unitBinarySearchReturnsNegativeOneWhenNothingOverlapsFoundNegative() {
        systemUnderTest = new VCC_TimeSlotCollection();
        for (Integer counter = 1; counter < 1000; counter++) {
            systemUnderTest.timeSlots.add(
                new VCC_TimeSlot(START_RANGE.addDays(counter), START_RANGE.addDays(counter).addHours(8))
            );
        }

        Integer expectedIndex = -1;
        VCC_TimeSlot timeSlotToFind = new VCC_TimeSlot(
            START_RANGE.addDays(expectedIndex).addHours(-1),
            START_RANGE.addDays(expectedIndex).addHours(7)
        );
        Integer result;
        System.runAs(MOLLY_MIN_ACCESS) {
            result = systemUnderTest.findIndexOfOverlappingTimeSlotBinarySearch(timeSlotToFind);
        }
        Assert.areEqual(
            expectedIndex,
            result,
            'Expected Binary search to return -1 when there is no overlapping timeslot.'
        );
    }

    /**
     * @description Asserts that our findIndexOfOverlapping returns the closest index when there is no overlapping Time slot.
     */
    @IsTest
    private static void unitBinarySearchReturnsClosestIndexWhenNothingOverlapsFoundNegative() {
        systemUnderTest = new VCC_TimeSlotCollection();
        //Second to Last slot
        Integer expectedIndex = 997;
        for (Integer counter = 1; counter < 1000; counter++) {
            if (counter == expectedIndex + 1) {
                continue;
            }
            systemUnderTest.timeSlots.add(
                new VCC_TimeSlot(START_RANGE.addDays(counter), START_RANGE.addDays(counter).addHours(8))
            );
        }

        VCC_TimeSlot timeSlotToinsert = new VCC_TimeSlot(
            START_RANGE.addDays(expectedIndex + 1),
            START_RANGE.addDays(expectedIndex + 1).addHours(8)
        );
        Integer result;
        System.runAs(MOLLY_MIN_ACCESS) {
            result = systemUnderTest.findIndexToInsertBinarySearch(timeSlotToinsert);
        }
        Assert.areEqual(
            expectedIndex,
            result,
            'Expected Binary search to return ' + expectedIndex + ' when there is no directly overlapping time slot.'
        );
    }

    /**
     * @description Asserts that the overloaded constructor can safely handle null input
     */
    @IsTest
    private static void unitAServiceAppointmentOverloadedConstructorNegative() {
        ServiceAppointment mockAppointment;
        Test.startTest();
        {
            System.runAs(MOLLY_MIN_ACCESS) {
                systemUnderTest = new VCC_TimeSlotCollection(mockAppointment);
            }
        }
        Test.stopTest();
        Assert.areEqual(
            0,
            systemUnderTest.getTimeInMinutes(),
            'Expected the time calculation to be equal to zero even if the appointment passed into the constructor was null!'
        );
        Assert.areEqual(
            0,
            systemUnderTest.size(),
            'Expected the internal Collection to be instantiated regardless of whether the appointment passed in was null!'
        );
    }

    /**
     * @description Asserts that the overloaded constructor calls the add method.
     */
    @IsTest
    private static void unitServiceAppointmentOverloadedConstructorPositive() {
        Integer timeOfAppt = 62;
        ServiceAppointment mockAppointment = new ServiceAppointment(
            SchedStartTime = START_RANGE,
            SchedEndTime = START_RANGE.addMinutes(timeOfAppt)
        );
        Test.startTest();
        {
            System.runAs(MOLLY_MIN_ACCESS) {
                systemUnderTest = new VCC_TimeSlotCollection(mockAppointment);
            }
        }
        Test.stopTest();
        Assert.areEqual(
            timeOfAppt,
            systemUnderTest.getTimeInMinutes(),
            'Expected the time calculation to be equal to the time of the appointment!'
        );
        Assert.areEqual(
            1,
            systemUnderTest.size(),
            'Expected only one VCC_TimeSlot to be added when adding one Service Appointment!'
        );
    }

    /**
     * @description Tests that the add shift description adds descriptions for the Shifts being added
     * when there are multiple Shift(s) in a given day for a given resource.
     * Asserts: The concat functionality correctly combines
     */
    @IsTest
    private static void unitAddMultipleShiftDescriptionsPositive() {
        // 4 hour shift
        Shift overlappedShift = (Shift) VATEST_SObjectFactory.createSObject(
            new Shift(StartTime = START_RANGE, EndTime = START_RANGE.addHours(4)),
            false
        );
        //Overlapping shift, only 1 hour or 60 minutes should be added.
        Shift overlappingShift = (Shift) VATEST_SObjectFactory.createSObject(
            new Shift(StartTime = START_RANGE.addHours(-1), EndTime = START_RANGE.addHours(4)),
            false
        );
        //exists inside of shiftA & B should not be added to the collection
        Shift shiftExistingInsideOf = (Shift) VATEST_SObjectFactory.createSObject(
            new Shift(StartTime = START_RANGE.addHours(1), EndTime = START_RANGE.addHours(2)),
            false
        );

        Shift shiftExistingBeforeOthers = (Shift) VATEST_SObjectFactory.createSObject(
            new Shift(StartTime = START_RANGE.addDays(-1), EndTime = START_RANGE.addDays(-1).addHours(8)),
            false
        );
        String combinedShiftDescriptions = '';
        System.runAs(MOLLY_MIN_ACCESS) {
            systemUnderTest = new VCC_TimeSlotCollection(overlappedShift);
            systemUnderTest.add(overlappingShift);
            systemUnderTest.add(shiftExistingInsideOf);
            systemUnderTest.add(shiftExistingBeforeOthers);
            combinedShiftDescriptions = systemUnderTest.concatDescriptions();
        }

        Assert.areEqual(
            3,
            systemUnderTest.shiftDescriptions.size(),
            'Expected only 3 Shift Descriptions to be preserved since one was inside the other shifts and one is an overlapping time slot'
        );

        String expectedShiftDescriptions =
            overlappedShift.StartTime.format(VCC_TimeSlotCollection.JAVA_SIMPLE_DATE_FORMATTING_STRING) +
            '-' +
            overlappedShift.EndTime.format(VCC_TimeSlotCollection.JAVA_SIMPLE_DATE_FORMATTING_STRING) +
            ' AND ' +
            overlappingShift.StartTime.format(VCC_TimeSlotCollection.JAVA_SIMPLE_DATE_FORMATTING_STRING) +
            '-' +
            overlappingShift.EndTime.format(VCC_TimeSlotCollection.JAVA_SIMPLE_DATE_FORMATTING_STRING) +
            ' AND ' +
            shiftExistingBeforeOthers.StartTime.format(VCC_TimeSlotCollection.JAVA_SIMPLE_DATE_FORMATTING_STRING) +
            '-' +
            shiftExistingBeforeOthers.EndTime.format(VCC_TimeSlotCollection.JAVA_SIMPLE_DATE_FORMATTING_STRING);

        Assert.areEqual(
            expectedShiftDescriptions,
            combinedShiftDescriptions,
            'Expected only Shift Descriptions to be combined with AND keyword between them'
        );
    }
}
