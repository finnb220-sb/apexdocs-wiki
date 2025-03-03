/**
 * @description Test Class for VCC_DateRange class.
 * @see VCC_DateRange
 */
@IsTest
private class VCC_DateRangeTest {
    private static VCC_DateRange systemUnderTest;
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
    static void unitConstructorSetsInternalPropertiesPositive() {
        DateTime expectedStartDateTime = System.now();
        DateTime expectedEndDateTime = expectedStartDateTime.addHours(8);

        Test.startTest();
        systemUnderTest = new VCC_DateRange(expectedStartDateTime, expectedEndDateTime);
        test.stopTest();
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
     * @description Asserts that when two dates are overlapping e.g. they share time in common, then isOverlapping returns true;
     *
     */
    @IsTest
    static void unitIsOverlappingPositive() {
        DateTime startRange = System.now();

        VCC_DateRange firstSlot = new VCC_DateRange(startRange, startRange.addHours(8));
        VCC_DateRange secondSlot = new VCC_DateRange(startRange.addHours(-1), startRange.addHours(7));
        Assert.isTrue(
            firstSlot.isOverlapping(secondSlot),
            'Expected isOverlapping to return true as, the two ranges are overlapping.'
        );
        Assert.isTrue(
            secondSlot.isOverlapping(firstSlot),
            'Expected isOverlapping to return true as, the two ranges are overlapping.'
        );
    }

    /**
     * @description Asserts that when two dates are not overlapping e.g. they share time no time common, then isOverlapping returns false;
     *
     */
    @IsTest
    static void unitIsOverlappingNegative() {
        DateTime startRange = System.now();

        VCC_DateRange firstSlot = new VCC_DateRange(startRange, startRange.addHours(8));
        VCC_DateRange secondSlot = new VCC_DateRange(startRange.addDays(-1), startRange.addDays(-1).addHours(8));
        Assert.isFalse(
            firstSlot.isOverlapping(secondSlot),
            'Expected isOverlapping to return false as, the two ranges are not overlapping.'
        );
        Assert.isFalse(
            secondSlot.isOverlapping(firstSlot),
            'Expected isOverlapping to return true as, the two ranges are not overlapping.'
        );
    }

    /**
     * @description Asserts that when one date range is inside of another date range, existsInsideOf returns true.
     */
    @IsTest
    static void unitExistsInsideOfPositive() {
        DateTime startDateTime = System.now();
        VCC_DateRange encasingTimeSlot = new VCC_DateRange(startDateTime, startDateTime.addHours(8));
        VCC_DateRange smallerTimeSlot = new VCC_DateRange(startDateTime.addHours(1), startDateTime.addHours(2));
        Assert.isTrue(
            smallerTimeSlot.existsInsideOf(encasingTimeSlot),
            'Expected existsInsideOf to return true as, ' +
                JSON.serializePretty(smallerTimeSlot) +
                ' exists in ' +
                JSON.serializePretty(encasingTimeSlot)
        );
    }

    /**
     * @description Asserts when a null argument is passed to the constructor, an exception is thrown.
     */
    @IsTest
    static void unitItThrowsExceptionWhenArgumentIsNull() {
        DateTime startDateTime;
        DateTime endDateTime = System.now();
        String message;
        try {
            new VCC_DateRange(startDateTime, endDateTime);
            Assert.fail('Expected an exception to be thrown');
        } catch (VCC_DateRange.InvalidDateRangeException dateRangeException) {
            message = dateRangeException.getMessage();
        }
        Assert.areEqual(
            VCC_DateRange.NULL_ARG_MSG,
            message,
            'Expected Exception message to be set by VCC_DateRange constant \'NULLARGMSG\'.'
        );
    }

    /**
     * @description Asserts that an error is thrown when trying to instantiate a date range where the startDateTime is after the endDateTime.
     */
    @IsTest
    static void unitItThrowsExceptionWhenEndDateIsBeforeStartDateNegative() {
        DateTime startDateTime = System.now().addDays(10);
        DateTime endDateTime = System.now();
        String message;
        try {
            new VCC_DateRange(startDateTime, endDateTime);
            Assert.fail('Expected an exception to be thrown');
        } catch (VCC_DateRange.InvalidDateRangeException dateRangeException) {
            message = dateRangeException.getMessage();
        }
        Assert.isTrue(
            message.contains(VCC_DateRange.INVALID_START_END_DATE_MSG),
            'Expected Exception message to be set by VCC_DateRange constant \'INVALID_START_END_DATE_MSG\'.'
        );
    }
}
