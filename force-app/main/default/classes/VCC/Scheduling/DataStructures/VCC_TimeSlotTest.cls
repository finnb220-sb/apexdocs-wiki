/**
 * @description Test class for the VCC_TimeSlot class.
 * @see VCC_TimeSlot
 * @see VCC_TimeSlotCollection
 */
@IsTest
private class VCC_TimeSlotTest {
    private static VCC_TimeSlot systemUnderTest;
    private static final User MOLLY_MIN_ACCESS;

    static {
        MOLLY_MIN_ACCESS = VATEST_UserFactory.createMinAccessPersonaUser(false);
        MOLLY_MIN_ACCESS.TimeZoneSidKey = UserInfo.getTimeZone().getID();
    }

    /**
     * @description Asserts that the properties passed into the constructor
     * set the internal properties of the object.
     */
    @IsTest
    private static void unitConstructorSetsInternalPropertiesPositive() {
        DateTime expectedStartDateTime = System.now();
        DateTime expectedEndDateTime = expectedStartDateTime.addHours(8);
        System.runAs(MOLLY_MIN_ACCESS) {
            Test.startTest();
            systemUnderTest = new VCC_TimeSlot(expectedStartDateTime, expectedEndDateTime);
            test.stopTest();
        }
        Assert.areEqual(
            systemUnderTest.startDateTime,
            expectedStartDateTime,
            'Expected constructor to set the internal \'startDateTime\' property equal to the argument passed into it.'
        );
        Assert.areEqual(
            systemUnderTest.endDateTime,
            expectedEndDateTime,
            'Expected constructor to set the internal \'endDateTime\' property equal to the argument passed into it.'
        );
    }

    /**
     * @description Asserts that when two VCC_TimeSlot's have the same
     * StartDateTime and endDateTime they are considered equal to each other.
     */
    @IsTest
    private static void unitItComparesOnInternalPropertiesPositive() {
        DateTime expectedStartDateTime = System.now();
        DateTime expectedEndDateTime = expectedStartDateTime.addHours(8);
        systemUnderTest = new VCC_TimeSlot(expectedStartDateTime, expectedEndDateTime);
        VCC_TimeSlot identicalTimeSlotByValueNotReference = new VCC_TimeSlot(
            expectedStartDateTime,
            expectedEndDateTime
        );
        Boolean result;
        System.runAs(MOLLY_MIN_ACCESS) {
            Test.startTest();
            result = systemUnderTest.equals(identicalTimeSlotByValueNotReference);
            Test.stopTest();
        }
        Assert.isTrue(
            result,
            'Expected equals Method to return true when two VCC_TimeSlots have the same start and end time properties.'
        );
    }

    /**
     * @description Asserts that when two VCC_TimeSlot's have different
     * StartDateTime or endDateTime they are considered not equal to each other.
     */
    @IsTest
    private static void unitItComparesOnInternalPropertiesNegative() {
        DateTime expectedStartDateTime = System.now();
        DateTime expectedEndDateTime = expectedStartDateTime.addHours(8);
        systemUnderTest = new VCC_TimeSlot(expectedStartDateTime, expectedEndDateTime);
        VCC_TimeSlot differentStartTime = new VCC_TimeSlot(expectedStartDateTime.addHours(1), expectedEndDateTime);
        VCC_TimeSlot differentEndTime = new VCC_TimeSlot(expectedStartDateTime, expectedEndDateTime.addHours(-1));
        VCC_TimeSlot differentStartAndEnd = new VCC_TimeSlot(
            expectedStartDateTime.addHours(1),
            expectedEndDateTime.addHours(-1)
        );
        Boolean startTimeDiffResult;
        Boolean endTimeDiffResult;
        Boolean bothDiffResult;
        System.runAs(MOLLY_MIN_ACCESS) {
            Test.startTest();
            startTimeDiffResult = systemUnderTest.equals(differentStartTime);
            endTimeDiffResult = systemUnderTest.equals(differentEndTime);
            bothDiffResult = systemUnderTest.equals(differentStartAndEnd);
            Test.stopTest();
        }
        Assert.isFalse(
            startTimeDiffResult,
            'Expected equals method to return false when two VCC_TimeSlots have a different startTime property.'
        );
        Assert.isFalse(
            endTimeDiffResult,
            'Expected equals method to return false when two VCC_TimeSlots have a different endTime property.'
        );
        Assert.isFalse(
            bothDiffResult,
            'Expected equals method to return false when two VCC_TimeSlots have a different endTime and startTime properties.'
        );
    }

    /**
     * @description Asserts that when a VCC_TimeSlot is compared to a different object,
     * No matter their similarities, they are not considered equal.
     */
    @IsTest
    private static void unitItComparesOnInternalTypeNegative() {
        DateTime expectedStartDateTime = System.now();
        DateTime expectedEndDateTime = expectedStartDateTime.addHours(8);
        systemUnderTest = new VCC_TimeSlot(expectedStartDateTime, expectedEndDateTime);
        Shift notTheSameType = new Shift(StartTime = expectedStartDateTime, EndTime = expectedEndDateTime);
        Boolean result;
        Test.startTest();
        System.runAs(MOLLY_MIN_ACCESS) {
            result = systemUnderTest.equals(notTheSameType);
        }
        test.stopTest();
        Assert.isFalse(
            result,
            'Expected equals Method to return false when two objects of different types are compared.'
        );
    }

    /**
     * @description Asserts that the custom defined hashcode method is deterministic based on StartDateTime
     * and endDateTime. It does this by running the hashCode method 50,000 times and adding each iteration
     * to a set collection. If any of the 50,000 differ from one another, the set collection will be larger
     * than size of 1. 50,000 is chosen as it is about at our limit of what we can calculate in any given run.
     * 200 providers each working 5 days a week, 48 weeks out of the year. 200 * 5 * 48 = 48000
     */
    @IsTest
    private static void unitHashCodeIsDeterministicPositive() {
        DateTime expectedStartDateTime = System.now();
        DateTime expectedEndDateTime = expectedStartDateTime.addHours(8);
        systemUnderTest = new VCC_TimeSlot(expectedStartDateTime, expectedEndDateTime);
        Set<Integer> hashCodes = new Set<Integer>();
        System.runAs(MOLLY_MIN_ACCESS) {
            Test.startTest();
            for (Integer counter = 0; counter < 50000; counter++) {
                hashCodes.add(systemUnderTest.hashCode());
            }
            Test.stopTest();
        }
        Assert.areEqual(1, hashCodes.size(), 'Expected Hashcode function to never return a different value.');
    }

    /**
     * @description Tests the compare to function enables sorting of a List<VCC_TimeSlot> by
     * startDate Ascending. (Most recent dates first)
     */
    @IsTest
    private static void unitItSortsPositive() {
        List<VCC_TimeSlot> timeSlotList = new List<VCC_TimeSlot>();
        DateTime startRange = System.now();
        VCC_TimeSlot secondSlot = new VCC_TimeSlot(startRange, startRange.addHours(8));

        VCC_TimeSlot firstSlot = new VCC_TimeSlot(
            secondSlot.startDateTime.addDays(-1),
            secondSlot.endDateTime.addDays(-1)
        );
        System.runAs(MOLLY_MIN_ACCESS) {
            Test.startTest();
            timeSlotList.add(secondSlot);
            timeSlotList.add(firstSlot);
            timeSlotList.sort();
        }
        Test.stopTest();
        Assert.areEqual(timeSlotList.get(0), firstSlot, 'Expected First slot to be placed first.');
        Assert.areEqual(timeSlotList.get(1), secondSlot, 'Expected Second slot to be placed last.');
    }
}
