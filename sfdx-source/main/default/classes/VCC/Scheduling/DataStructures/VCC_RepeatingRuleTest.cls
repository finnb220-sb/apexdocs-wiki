/**
 * @description Test class for VCC_RepeatingRuleClass
 * @see VCC_RepeatingRule
 */
@IsTest
@SuppressWarnings('PMD.CyclomaticComplexity, PMD.CognitiveComplexity')
private with sharing class VCC_RepeatingRuleTest {
    private static final DateTime JAN_FIRST_2024;
    private static final User MOLLY_MIN_ACCESS;

    static {
        JAN_FIRST_2024 = DateTime.newInstance(2024, 1, 1).addHours(9);
        MOLLY_MIN_ACCESS = VATEST_UserFactory.createMinAccessPersonaUser(false);
        MOLLY_MIN_ACCESS.TimeZoneSidKey = UserInfo.getTimeZone().getID();
    }

    /**
     * @description constructor unit test
     */
    @IsTest
    private static void unitConstructorPositive() {
        String rruleText = 'RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=FR,TH,SU,SA,MO;UNTIL=20241108T000000Z';
        Datetime startDateTime = DateTime.newInstance(2024, 11, 2, 11, 0, 0);
        Datetime endDateTime = DateTime.newInstance(2024, 11, 9, 5, 0, 0);
        System.runAs(MOLLY_MIN_ACCESS) {
            try {
                VCC_RepeatingRule repeatingRule = new VCC_RepeatingRule(rruleText, startDateTime, endDateTime);
                Set<VCC_RepeatingRule.RFC5545DayOfWeek> expected = new Set<VCC_RepeatingRule.RFC5545DayOfWeek>();

                expected.add(VCC_RepeatingRule.RFC5545DayOfWeek.SA);
                expected.add(VCC_RepeatingRule.RFC5545DayOfWeek.SU);
                expected.add(VCC_RepeatingRule.RFC5545DayOfWeek.MO);
                expected.add(VCC_RepeatingRule.RFC5545DayOfWeek.TH);
                expected.add(VCC_RepeatingRule.RFC5545DayOfWeek.FR);

                Assert.areEqual(
                    expected.toString(),
                    repeatingRule.repeatOnDaysOfWeek.toString(),
                    'Expected repeatOnDaysOfWeek to match the value the VCC_RepeatingRule was initialized (SA, SU, MO, TH, FR) with but instead observed different value'
                );
                Assert.areEqual(
                    startDateTime,
                    repeatingRule.startDatetime,
                    'Expected start time to match the value the VCC_RepeatingRule was initialized (11 AM) with but instead observed different value.'
                );
                Assert.areEqual(
                    endDateTime,
                    repeatingRule.endDatetime,
                    'Expected end time to match the value the VCC_RepeatingRule was initialized (12 AM) with but instead observed different value.'
                );
                Assert.areEqual(
                    VCC_RepeatingRule.RFC5545Frequency.WEEKLY,
                    repeatingRule.frequency,
                    'Expected frequency to match the value the VCC_RepeatingRule was initialized (WEEKLY) with but instead observed different value.'
                );

                Assert.areEqual(
                    Date.newInstance(2024, 11, 8),
                    repeatingRule.until,
                    'Expected until date to match the value the VCC_RepeatingRule was initialized (11/08/2024) with but instead observed different value.'
                );
                Assert.areEqual(
                    1,
                    repeatingRule.interval,
                    'Expected interval to match the value the VCC_RepeatingRule was initialized (1) with but instead observed different value'
                );
                Assert.isNull(
                    repeatingRule.count,
                    'Expected count to match the value the VCC_RepeatingRule was initialized (null) with but instead observed different value'
                );
                Assert.areEqual(
                    0,
                    repeatingRule.byMonthDay,
                    'Expected byMonthDay to match the value the VCC_RepeatingRule was initialized (null) with but instead observed different value'
                );
                Assert.areEqual(
                    0,
                    repeatingRule.monthOffset,
                    'Expected monthOffset to match the value the VCC_RepeatingRule was initialized (null) with but instead observed different value'
                );
                Assert.areEqual(
                    0,
                    repeatingRule.relativeOccurrence,
                    'Expected relativeOccurrence to match the value the VCC_RepeatingRule was initialized (null) with but instead observed different value'
                );
                Assert.areEqual(
                    new Set<Date>(),
                    repeatingRule.exclusionDates,
                    'Expected exclusionDates  to match the value the VCC_RepeatingRule was initialized (empty set) with but instead observed different value'
                );
            } catch (Exception thrownException) {
                Assert.fail(
                    'Unexpected exception thrown. Expected VCC_RepeatingRule attributes to be initialized correctly. Received this exception instead:  ' +
                    thrownException.toString()
                );
            }
        }
    }

    /**
     * @description extractDaysOfWeek unit test
     * rruleText is 'RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=FR,TH,SU,SA,MO;UNTIL=20241108T000000Z';
     */
    @IsTest
    private static void unitExtractDaysOfWeekPositive() {
        Datetime startDateTime = DateTime.newInstance(2024, 11, 2, 11, 0, 0);
        System.runAs(MOLLY_MIN_ACCESS) {
            try {
                Set<VCC_RepeatingRule.RFC5545DayOfWeek> result = VCC_RepeatingRule.extractDaysOfWeek(
                    'FR,TH,SU,SA,MO',
                    startDateTime
                );
                Set<VCC_RepeatingRule.RFC5545DayOfWeek> expected = new Set<VCC_RepeatingRule.RFC5545DayOfWeek>();
                expected.add(VCC_RepeatingRule.RFC5545DayOfWeek.SA);
                expected.add(VCC_RepeatingRule.RFC5545DayOfWeek.SU);
                expected.add(VCC_RepeatingRule.RFC5545DayOfWeek.MO);
                expected.add(VCC_RepeatingRule.RFC5545DayOfWeek.TH);
                expected.add(VCC_RepeatingRule.RFC5545DayOfWeek.FR);

                Assert.areEqual(
                    expected.toString(),
                    result.toString(),
                    'Expected result to have order of SA, SU, MO, TH, FR'
                );
            } catch (Exception thrownException) {
                Assert.fail(
                    'Unexpected exception thrown. Expected extractDaysOfWeek result to be equal to {SA,SU,MO,TH,FR}. Received this exception instead: ' +
                    thrownException.toString()
                );
            }
        }
    }

    /**
     * @description sortDaysOfWeek positive unit test
     * rruleText is 'RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=SU,MO,TU,WE,TH,FR;UNTIL=20241013T000000Z';
     * Start date (Sunday) and the first BYDAY (Sunday) are the same. BYDAY is in order.
     */
    @IsTest
    private static void unitSortDaysOfWeekOrderedPositive() {
        Datetime startDatetime = DateTime.newInstance(2024, 10, 6, 7, 0, 0);
        System.runAs(MOLLY_MIN_ACCESS) {
            try {
                List<String> result = VCC_RepeatingRule.sortDaysOfWeek('SU,MO,TU,WE,TH,FR', startDateTime);
                List<String> expected = new List<String>{ 'SU', 'MO', 'TU', 'WE', 'TH', 'FR' };
                Assert.areEqual(expected, result, 'Expected result list to have order of {SU, MO, TU, WE, TH, FR}.');
            } catch (Exception thrownException) {
                Assert.fail(
                    'Unexpected exception thrown. Expected sortDaysOfWeek result to be equal to {SU,MO,TU,WE,TH,FR}. Received this exception instead: ' +
                    thrownException.toString()
                );
            }
        }
    }

    /**
     * @description sortDaysOfWeek positive unit test
     * rruleText is 'RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=TH;UNTIL=20241017T000000Z'
     * BYDAY contains one value for Thursday while the start date is on a friday.
     */
    @IsTest
    private static void unitSortDaysOfWeekOneElementInListPositive() {
        Datetime startDatetime = DateTime.newInstance(2024, 10, 11, 7, 0, 0);
        System.runAs(MOLLY_MIN_ACCESS) {
            try {
                List<String> result = VCC_RepeatingRule.sortDaysOfWeek('TH', startDateTime);
                List<String> expected = new List<String>{ 'TH' };
                Assert.areEqual(expected, result, 'Expected result list to be {TH}');
            } catch (Exception thrownException) {
                Assert.fail(
                    'Unexpected exception thrown. Expected sortDaysOfWeek result to be equal to {TH}. Received this exception instead: ' +
                    thrownException.toString()
                );
            }
        }
    }

    /**
     * @description sortDaysOfWeek positive unit test
     * rruleText is 'RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=SU,SA,TH,WE;UNTIL=20241020T000000Z'
     * Start date (Wednesday) is after the first BYDAY (Sunday). BYDAYS are not in order.
     */
    @IsTest
    private static void unitSortDaysOfWeekUnorderedPositive() {
        Datetime startDatetime = DateTime.newInstance(2024, 10, 16, 7, 0, 0);
        System.runAs(MOLLY_MIN_ACCESS) {
            try {
                List<String> result = VCC_RepeatingRule.sortDaysOfWeek('SU,SA,TH,WE', startDateTime);
                List<String> expected = new List<String>{ 'WE', 'TH', 'SA', 'SU' };
                Assert.areEqual(expected, result, 'Expected result lists to be {WE,TH,SA,SU}.');
            } catch (Exception thrownException) {
                Assert.fail(
                    'Unexpected exception thrown. Expected sortDaysOfWeek result to be equal to {WE,TH,SA,SU}. Received this exception instead: ' +
                    thrownException.toString()
                );
            }
        }
    }

    /**
     * @description sortDaysOfWeek positive unit test
     * rruleText is 'RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,WE,TU,FR;UNTIL=20241004T000000Z'
     * Start date (Monday) is the same day as the first BYDAY (Monday). BYDAYS are not in order.
     */
    @IsTest
    private static void unitSortDaysOfWeekUnorderedPositive2() {
        Datetime startDatetime = DateTime.newInstance(2024, 9, 30, 7, 0, 0);
        System.runAs(MOLLY_MIN_ACCESS) {
            try {
                List<String> result = VCC_RepeatingRule.sortDaysOfWeek('MO,WE,TU,FR', startDateTime);
                List<String> expected = new List<String>{ 'MO', 'TU', 'WE', 'FR' };
                Assert.areEqual(expected, result, 'Expected result list to be {MO,TU,WE,FR}.');
            } catch (Exception thrownException) {
                Assert.fail(
                    'Unexpected exception thrown. Expected sortDaysOfWeek result to be equal to {MO,TU,WE,FR}. Received this exception instead: ' +
                    thrownException.toString()
                );
            }
        }
    }

    /**
     * @description sortDaysOfWeek positive unit test
     * rruleText is 'RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=WE,MO,SU,FR,TH;UNTIL=20241024T000000Z'
     * Start date (Wednesday) is before the first BYDAY (Friday). BYDAYS are not in order.
     */
    @IsTest
    private static void unitSortDaysOfWeekUnorderedPositive3() {
        Datetime startDatetime = DateTime.newInstance(2024, 10, 18, 7, 0, 0);
        System.runAs(MOLLY_MIN_ACCESS) {
            try {
                List<String> result = VCC_RepeatingRule.sortDaysOfWeek('WE,MO,SU,FR,TH', startDateTime);
                List<String> expected = new List<String>{ 'FR', 'SU', 'MO', 'WE', 'TH' };
                Assert.areEqual(expected, result, 'Expected result list to be {FR,SU,MO,WE,TH}.');
            } catch (Exception thrownException) {
                Assert.fail(
                    'Unexpected exception thrown. Expected sortDaysOfWeek result to be equal to {FR,SU,MO,WE,TH}. Received this exception instead: ' +
                    thrownException.toString()
                );
            }
        }
    }

    /**
     * @description sortDaysOfWeek negative unit test
     * rruleText is 'RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=;UNTIL=20241004T000000Z'.
     * BYDAY is blank. Start day is Monday.
     */
    @IsTest
    private static void unitSortDaysOfWeekBlankNegative() {
        Datetime startDatetime = DateTime.newInstance(2024, 9, 30, 7, 0, 0);
        System.runAs(MOLLY_MIN_ACCESS) {
            try {
                List<String> result = VCC_RepeatingRule.sortDaysOfWeek('', startDateTime);
                List<String> expected = new List<String>();
                Assert.areEqual(expected, result, 'Expected result list to be empty list.');
            } catch (Exception thrownException) {
                Assert.fail(
                    'Unexpected exception thrown. Expected sortDaysOfWeek result to be an empty list. Received this exception instead: ' +
                    thrownException.toString()
                );
            }
        }
    }

    /**
     * @description sortDaysOfWeek negative unit test
     * rruleText is 'RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=;UNTIL=20241004T000000Z'.
     * BYDAY is null. Start day is Monday.
     */
    @IsTest
    private static void unitSortDaysOfWeekNullNegative() {
        Datetime startDatetime = DateTime.newInstance(2024, 9, 30, 7, 0, 0);
        System.runAs(MOLLY_MIN_ACCESS) {
            try {
                String test = null;
                List<String> result = VCC_RepeatingRule.sortDaysOfWeek(test, startDateTime);
                List<String> expected = new List<String>();
                Assert.areEqual(expected, result, 'Expected result list to be an empty list.');
            } catch (Exception thrownException) {
                Assert.fail(
                    'Unexpected exception thrown. Expected sortDaysOfWeek result to be an empty list. Received this exception instead: ' +
                    thrownException.toString()
                );
            }
        }
    }

    /**
     * @description sortDaysOfWeek negative unit test
     * rruleText is 'RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,WE,TU,FR,,,SU;UNTIL=20241004T000000Z'.
     * BYDAY contains some blank elements and is not in order. Start day is Monday.
     */
    @IsTest
    private static void unitSortDaysOfWeekSomeBlanksUnorderedNegative() {
        Datetime startDatetime = DateTime.newInstance(2024, 9, 30, 7, 0, 0);
        System.runAs(MOLLY_MIN_ACCESS) {
            try {
                List<String> result = VCC_RepeatingRule.sortDaysOfWeek('MO,WE,TU,FR,,,SU', startDateTime);
                List<String> expected = new List<String>{ 'MO', 'TU', 'WE', 'FR', '', '', 'SU' };
                Assert.areEqual(expected, result, 'Expected result lists to be {MO,TU,WE,FR, , ,SU}.');
            } catch (Exception thrownException) {
                Assert.fail(
                    'Unexpected exception thrown. Expected sortDaysOfWeek result to be equal to {MO,TU,WE,FR, , ,SU}. Received this exception instead: ' +
                    thrownException.toString()
                );
            }
        }
    }

    /**
     * @description sortDaysOfWeek negative unit test
     * rruleText is 'RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,TH,FR, , ,SU;UNTIL=20241004T000000Z'.
     * BYDAY contains some blank elements and is in order. Start day is Monday.
     */
    @IsTest
    private static void unitSortDaysOfWeekSomeBlanksOrderedNegative() {
        Datetime startDatetime = DateTime.newInstance(2024, 9, 30, 7, 0, 0);
        System.runAs(MOLLY_MIN_ACCESS) {
            try {
                List<String> result = VCC_RepeatingRule.sortDaysOfWeek('MO,TU,TH,FR, , ,SU', startDateTime);
                List<String> expected = new List<String>{ 'MO', 'TU', 'TH', 'FR', ' ', ' ', 'SU' };
                Assert.areEqual(expected, result, 'Expected result list to be equal to {MO,TU,TH,FR, , ,SU}.');
            } catch (Exception thrownException) {
                Assert.fail(
                    'Unexpected exception thrown. Expected sortDaysOfWeek result to be equal to {MO,TU,TH,FR, , ,SU}. Received this exception instead: ' +
                    thrownException.toString()
                );
            }
        }
    }

    @IsTest
    private static void unitConstructorShouldGuardAgainstInvalidRules() {
        String errorMessage;
        String invalidRRule = 'This Text is not a valid RRule.';
        String expectedErrorMessage = 'Invalid RRULE: ' + invalidRRule;
        try {
            new VCC_RepeatingRule(invalidRRule, JAN_FIRST_2024, JAN_FIRST_2024.addDays(1));
            Assert.fail('Expected constructor to guard against invalid RRule text.');
        } catch (IllegalArgumentException invalidArgException) {
            errorMessage = invalidArgException.getMessage();
        }
        Assert.areEqual(
            expectedErrorMessage,
            errorMessage,
            'Expected the exception message to include the RRule text and \'Invalid RRULE: \'.'
        );
    }

    @IsTest
    private static void unitEveryDayInOneYearPositive() {
        Datetime testStart = JAN_FIRST_2024;
        Datetime testEnd = JAN_FIRST_2024.addYears(1);
        String rruleUntil = getRruleUntil(testEnd.date());
        String rruleText = 'RRULE:FREQ=DAILY;INTERVAL=1;UNTIL=' + rruleUntil;

        Set<Date> futureOccurrences = runTestAndMakeGeneralAssertions(rruleText, testStart, testEnd);
        Assert.areEqual(366, futureOccurrences.size(), 'Expected every day in year! 2024 is a leap year so that = 366');
        Boolean areAllInThisYear = true;
        String errorMessage = 'Expected occurrences to be within this year! Invalid occurrences : ';
        for (Date occurrence : futureOccurrences) {
            if (occurrence.year() != 2024) {
                areAllInThisYear = false;
                errorMessage += '\n' + occurrence;
            }
        }
        Assert.isTrue(areAllInThisYear, errorMessage);
    }

    @IsTest
    private static void unitCountMonthlyOnThirtyFirstNegative() {
        // Repeats every 31st of the month.
        Datetime testStart = JAN_FIRST_2024;
        Datetime testEnd = JAN_FIRST_2024.addYears(1);
        String rruleText = 'RRULE:FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=31;COUNT=12;';

        Set<Date> futureOccurrences = runTestAndMakeGeneralAssertions(rruleText, testStart, testEnd);
        Boolean areAllOn31st = true;
        String errorMessage = 'Expected occurrences to only be on 31st of months! Invalid occurrences : ';
        for (Date occurrence : futureOccurrences) {
            if (occurrence.day() != 31) {
                areAllOn31st = false;
                errorMessage += '\n' + occurrence;
            }
        }
        Assert.isTrue(areAllOn31st, errorMessage);
        Assert.areEqual(7, futureOccurrences.size(), 'Expected there to be 7 future occurrences.');
    }

    @IsTest
    private static void unitMonthlyUntilOnThirtyFirstNegative() {
        // Repeats every 31st of the month.
        Datetime testStart = JAN_FIRST_2024;
        Datetime testEnd = JAN_FIRST_2024.addYears(1);

        String rruleUntil = getRruleUntil(testEnd.date());
        String rruleText = 'RRULE:FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=31;UNTIL=' + rruleUntil;

        Set<Date> futureOccurrences = runTestAndMakeGeneralAssertions(rruleText, testStart, testEnd);
        Boolean areAllOn31st = true;
        String errorMessage = 'Expected occurrences to only be on 31st of months! Invalid occurrences : ';
        for (Date occurrence : futureOccurrences) {
            if (occurrence.day() != 31) {
                areAllOn31st = false;
                errorMessage += '\n' + occurrence;
            }
        }
        Assert.isTrue(areAllOn31st, errorMessage);
        Assert.areEqual(7, futureOccurrences.size(), 'Expected 7 since there are 7 months in 2024 with a 31st date.');
    }

    @IsTest
    private static void unitEveryTwoDaysPositive() {
        // Repeats every 2 days until 12/31/2024.
        Datetime testStart = JAN_FIRST_2024;
        Datetime testEnd = JAN_FIRST_2024.addYears(1);
        String rruleUntil = getRruleUntil(testEnd.date());

        String rruleText = 'RRULE:FREQ=DAILY;INTERVAL=2;UNTIL=' + rruleUntil;
        Set<Date> futureOccurrences = runTestAndMakeGeneralAssertions(rruleText, testStart, testEnd);

        Assert.areEqual((365 / 2) + 1, futureOccurrences.size(), 'Expected 365/2 + the last day = 183');
        Integer iterativeLastDay = -1;
        Boolean isValid = true;
        String errorMessage = 'Expected occurrences to only be every 2 days! Invalid occurrences : ';

        for (Date occurrence : futureOccurrences) {
            if (iterativeLastDay + 2 != occurrence.dayOfYear()) {
                isValid = false;
                errorMessage += occurrence;
            }
            iterativeLastDay = occurrence.dayOfYear();
        }
        Assert.isTrue(isValid, errorMessage);
    }

    @IsTest
    private static void unitEveryTwoDaysTenTimesPositive() {
        // Repeats every 2 days until 12/31/2024.
        Datetime testStart = JAN_FIRST_2024;
        Datetime testEnd = JAN_FIRST_2024.addDays(19);

        String rruleText = 'RRULE:FREQ=DAILY;INTERVAL=2;COUNT=10;';
        Set<Date> futureOccurrences = runTestAndMakeGeneralAssertions(rruleText, testStart, testEnd);

        Assert.areEqual(10, futureOccurrences.size(), 'Expected 10 since the COUNT in the RRULE was 10.');
        Integer iterativeLastDay = -1;
        Boolean isValid = true;
        String errorMessage = 'Expected occurrences to only be every 2 days! Invalid occurrences : ';

        for (Date occurrence : futureOccurrences) {
            if (iterativeLastDay + 2 != occurrence.dayOfYear()) {
                isValid = false;
                errorMessage += occurrence;
            }
            iterativeLastDay = occurrence.dayOfYear();
        }
        Assert.isTrue(isValid, errorMessage);
    }

    @IsTest
    private static void unitMonTueWedForOneYearPositive() {
        Datetime testStart = JAN_FIRST_2024;
        Datetime testEnd = JAN_FIRST_2024.addYears(1);

        String rruleUntil = getRruleUntil(testEnd.date());
        String rruleText = 'RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,WE;UNTIL=' + rruleUntil;
        Set<Date> futureOccurrences = runTestAndMakeGeneralAssertions(rruleText, testStart, testEnd);

        Assert.areEqual(
            53 + 53 + 52,
            futureOccurrences.size(),
            'Expected 158 as there are 53 mondays, 53 tuesdays and 52 wednesdays in 2024.'
        );
        Boolean isValid = true;
        String errorMessage = 'Expected occurrences to only be every 2 days! Invalid occurrences : ';

        for (Date occurrence : futureOccurrences) {
            Integer dayOfWeekAsInt = getDayOfWeekAsInteger(occurrence);
            //If its not between monday or Wednesday  1st and 3rd days of the week....
            if (!(dayOfWeekAsInt >= 1 && dayOfWeekAsInt <= 3)) {
                isValid = false;
                errorMessage += occurrence;
            }
        }
        Assert.isTrue(isValid, errorMessage);
    }

    @IsTest
    private static void unitEverySecondFridayEveryTwoMonthsForOneYearPositive() {
        Datetime testStart = JAN_FIRST_2024;
        Datetime testEnd = JAN_FIRST_2024.addYears(1);

        String rruleUntil = getRruleUntil(testEnd.date());
        String rruleText = 'RRULE:FREQ=MONTHLY;INTERVAL=2;BYSETPOS=2;BYDAY=FR;UNTIL=' + rruleUntil;
        Set<Date> futureOccurrences = runTestAndMakeGeneralAssertions(rruleText, testStart, testEnd);

        Assert.areEqual(6, futureOccurrences.size(), 'Expected = 6 months in the year of the year to be targeted.');
        Boolean isValid = true;
        String errorMessage = 'Expected occurrences to only be on every second Friday days! Invalid occurrences : ';

        for (Date occurrence : futureOccurrences) {
            Integer dayOfWeekAsInt = getDayOfWeekAsInteger(occurrence);
            if (dayOfWeekAsInt != 5) {
                isValid = false;
                errorMessage += '\n' + occurrence;
            }
        }
        Assert.isTrue(isValid, errorMessage);
    }

    @IsTest
    private static void unitEverySecondFridayEveryTwoMonthsForTwoTimesPositive() {
        Datetime testStart = JAN_FIRST_2024;
        Datetime testEnd = JAN_FIRST_2024.addYears(1);

        String rruleText = 'RRULE:FREQ=MONTHLY;INTERVAL=2;BYSETPOS=2;BYDAY=FR;COUNT=2;';
        Set<Date> futureOccurrences = runTestAndMakeGeneralAssertions(rruleText, testStart, testEnd);

        Assert.areEqual(2, futureOccurrences.size(), 'Expected = 2 months in the year of the year to be targeted.');
        Boolean isValid = true;
        String errorMessage = 'Expected occurrences to only be on the first friday Friday every other month! Invalid occurrences : ';

        for (Date occurrence : futureOccurrences) {
            Integer dayOfWeekAsInt = getDayOfWeekAsInteger(occurrence);
            if (dayOfWeekAsInt != 5) {
                isValid = false;
                errorMessage += '\n' + occurrence;
            }
        }
        Assert.isTrue(isValid, errorMessage);
    }

    @IsTest
    private static void unitEveryLastWedEveryTwoMonthsForTwoTimesPositive() {
        Datetime testStart = JAN_FIRST_2024;
        Datetime testEnd = JAN_FIRST_2024.addYears(1);

        String rruleText = 'RRULE:FREQ=MONTHLY;INTERVAL=2;BYSETPOS=-1;BYDAY=WE;COUNT=2;';
        Set<Date> futureOccurrences = runTestAndMakeGeneralAssertions(rruleText, testStart, testEnd);

        Assert.areEqual(2, futureOccurrences.size(), 'Expected = 2 months in the year of the year to be targeted.');
        Boolean isValid = true;
        String errorMessage = 'Expected occurrences to only be on the last Wednesday every other month! Invalid occurrences : ';

        for (Date occurrence : futureOccurrences) {
            Integer dayOfWeekAsInt = getDayOfWeekAsInteger(occurrence);
            if (dayOfWeekAsInt != 3 && occurrence.day() < 24) {
                isValid = false;
                errorMessage += '\n' + occurrence;
            }
        }
        Assert.isTrue(isValid, errorMessage);
    }

    @IsTest
    private static void unitEveryTwentyFifthOfTheMonthForOneYearPositive() {
        Datetime testStart = JAN_FIRST_2024;
        Datetime testEnd = JAN_FIRST_2024.addYears(1);

        String rruleUntil = getRruleUntil(testEnd.date());
        String rruleText = 'RRULE:FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=25;UNTIL=' + rruleUntil;
        Set<Date> futureOccurrences = runTestAndMakeGeneralAssertions(rruleText, testStart, testEnd);

        Assert.areEqual(12, futureOccurrences.size(), 'Expected one 25th date per month');
        Boolean isValid = true;
        String errorMessage = 'Expected occurrences to be on the 25th of the month! Invalid occurrences : ';

        for (Date occurrence : futureOccurrences) {
            if (occurrence.day() != 25) {
                isValid = false;
                errorMessage += occurrence;
            }
        }
        Assert.isTrue(isValid, errorMessage);
    }

    @IsTest
    private static void unitNextSaturdayOneTimePositive() {
        Datetime testStart = JAN_FIRST_2024;
        Datetime testEnd = JAN_FIRST_2024.addDays(6);

        String rruleText = 'RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=SA;COUNT=1;';
        Set<Date> futureOccurrences = runTestAndMakeGeneralAssertions(rruleText, testStart, testEnd);

        Assert.areEqual(1, futureOccurrences.size(), 'Expected one Saturday.');
        Boolean isValid = true;
        String errorMessage = 'Expected occurrences to only be on Saturdays! Invalid occurrences : ';

        for (Date occurrence : futureOccurrences) {
            if (occurrence.day() != 6) {
                isValid = false;
                errorMessage += occurrence;
            }
        }
        Assert.isTrue(isValid, errorMessage);
    }

    @IsTest
    private static void unitEverySevenDaysForFiveTimesPositive() {
        Datetime testStart = JAN_FIRST_2024;
        Datetime testEnd = JAN_FIRST_2024.addDays(29);

        String rruleText = 'RRULE:FREQ=DAILY;INTERVAL=7;COUNT=5;';
        Set<Date> futureOccurrences = runTestAndMakeGeneralAssertions(rruleText, testStart, testEnd);

        Assert.areEqual(5, futureOccurrences.size(), 'Expected 5 since the Count was 5.');
        Boolean isValid = true;
        String errorMessage = 'Expected occurrences to only be every 7 days! Invalid occurrences : ';

        for (Date occurrence : futureOccurrences) {
            if (Math.mod(occurrence.dayOfYear() - 1, 7) != 0) {
                isValid = false;
                errorMessage += occurrence;
            }
        }
        Assert.isTrue(isValid, errorMessage);
    }
    @IsTest
    private static void unitEveryTwentyOneDays3TimesWithTwoDatesExcludedPositive() {
        Datetime testStart = JAN_FIRST_2024;
        Datetime testEnd = JAN_FIRST_2024.addDays(43);

        String rruleText = 'RRULE:FREQ=DAILY;INTERVAL=21;COUNT=3;||EXDATE;VALUE=DATE:20240101,20240212';
        Set<Date> futureOccurrences = runTestAndMakeGeneralAssertions(rruleText, testStart, testEnd);

        Assert.areEqual(
            1,
            futureOccurrences.size(),
            'Expected one date since, two of the dates are excluded and the COUNT=3.'
        );
        Boolean isValid = true;
        String errorMessage = 'Expected occurrences to only be every 21 days with Jan 1st and Feb 12 excluded! Invalid occurrences : ';

        for (Date occurrence : futureOccurrences) {
            if (!occurrence.equals(Date.newInstance(2024, 1, 22))) {
                isValid = false;
                errorMessage += occurrence;
            }
        }
        Assert.isTrue(isValid, errorMessage);
    }

    private static Set<Date> runTestAndMakeGeneralAssertions(String rruleText, Datetime testStart, Datetime testEnd) {
        VCC_RepeatingRule repeatingRule;
        Set<Date> futureOccurrences;
        System.runAs(MOLLY_MIN_ACCESS) {
            Test.startTest();
            {
                repeatingRule = new VCC_RepeatingRule(rruleText, testStart, testEnd);
                futureOccurrences = repeatingRule.calculateFutureOccurrences();
            }
            Test.stopTest();
        }

        makeGeneralRRuleAssertions(rruleText, repeatingRule);
        return futureOccurrences;
    }

    private static String getRruleUntil(Date rruleDate) {
        String rruleMonth = String.valueOf(rruleDate.month()).leftPad(2, '0');
        String rruleDay = String.valueOf(rruleDate.day() - 1).leftPad(2, '0');
        String rruleUntil = String.valueOf(rruleDate.year()) + rruleMonth + rruleDay + 'T000000Z;';
        return rruleUntil;
    }

    private static void makeGeneralRRuleAssertions(String rruleText, VCC_RepeatingRule repeatingRule) {
        Assert.areEqual(
            getRRuleFrequency(rruleText),
            String.valueOf(repeatingRule.frequency),
            'Expected the parser to produce the same frequency output as the brute force extraction method below'
        );
        Assert.areEqual(
            getRRuleUntilDate(rruleText),
            repeatingRule.until,
            'Expected the parser to produce the same until date as the brute force extraction method below'
        );
        Assert.areEqual(
            getRRuleInterval(rruleText),
            repeatingRule.interval,
            'Expected the parser to produce the same interval value as the brute force extraction method below'
        );

        Assert.areEqual(
            getRRuleCount(rruleText),
            repeatingRule.count,
            'Expected the parser to produce the same count value as the brute force extraction method below'
        );
        Assert.isTrue(
            byDayHasProperDays(rruleText, repeatingRule),
            'Expected the parser to produce the same byDay values as the brute force extraction method below'
        );

        Assert.areEqual(
            getRRuleByMonthDay(rruleText),
            repeatingRule.byMonthDay,
            'Expected the parser to produce the same month day value as the brute force extraction method below'
        );
        Assert.areEqual(
            getRRuleBySetPos(rruleText),
            repeatingRule.relativeOccurrence,
            'Expected the parser to produce the same set pos value as the brute force extraction method below'
        );

        Assert.isTrue(
            getRRuleExpDates(rruleText, repeatingRule),
            'Expected the parser to produce the same getRRuleExpDates values as the brute force extraction method below'
        );
    }
    // Private helper methods. Brute force approach
    // FREQ
    private static String getRRuleFrequency(String rruleText) {
        rruleText = rruleText.substringAfter('RRULE:');
        String[] parts = rruleText.split(';');
        for (String part : parts) {
            if (part.startsWith('FREQ=')) {
                return part.substringAfter('FREQ=');
            }
        }
        return null;
    }

    // UNTIL
    private static Datetime getRRuleUntilDate(String rruleText) {
        String[] parts = rruleText.split(';');
        for (String part : parts) {
            if (part.startsWith('UNTIL=')) {
                part = part.substringAfter('UNTIL=');

                return VCC_RepeatingRule.parseRFC5545DateToApexDate(part);
            }
        }
        return null;
    }

    // INTERVAL
    private static Integer getRRuleInterval(String rruleText) {
        String[] parts = rruleText.split(';');
        for (String part : parts) {
            if (part.startsWith('INTERVAL=')) {
                return Integer.valueOf(part.substringAfter('INTERVAL='));
            }
        }
        return null;
    }

    // COUNT
    private static Integer getRRuleCount(String rruleText) {
        String[] parts = rruleText.split(';');
        for (String part : parts) {
            if (part.startsWith('COUNT=')) {
                return Integer.valueOf(part.substringAfter('COUNT='));
            }
        }
        return null;
    }

    // BYDAY
    private static Boolean byDayHasProperDays(String rruleText, VCC_RepeatingRule rrule) {
        if (rruleText.contains('BYDAY=') == false) {
            return true;
        }
        String[] parts = rruleText.split(';');

        Set<String> parsedDays = new Set<String>{};
        for (VCC_RepeatingRule.RFC5545DayOfWeek dayOfWeek : rrule.repeatOnDaysOfWeek) {
            parsedDays.add(String.valueOf(dayOfWeek));
        }

        for (String part : parts) {
            if (part.startsWith('BYDAY=')) {
                String[] days = part.substringAfter('BYDAY=').split(',');
                for (String day : days) {
                    if (!parsedDays.contains(day)) {
                        return false;
                    }
                }
                return true;
            }
        }
        return false;
    }

    // BYMONTHDAY
    private static Integer getRRuleByMonthDay(String rruleText) {
        String[] parts = rruleText.split(';');
        for (String part : parts) {
            if (part.startsWith('BYMONTHDAY=')) {
                return Integer.valueOf(part.substringAfter('BYMONTHDAY='));
            }
        }
        return 0;
    }

    // BYSETPOS
    private static Integer getRRuleBySetPos(String rruleText) {
        String[] parts = rruleText.split(';');
        for (String part : parts) {
            if (part.startsWith('BYSETPOS=')) {
                return Integer.valueOf(part.substringAfter('BYSETPOS='));
            }
        }
        return 0;
    }

    // VALUE
    private static Boolean getRRuleExpDates(String rruleText, VCC_RepeatingRule rrule) {
        if (rruleText.contains('EXDATE=') == false) {
            return true;
        }
        String[] parts = rruleText.split(';');
        Set<Date> parsedDays = new Set<Date>(rrule.exclusionDates);

        for (String part : parts) {
            if (part.startsWith('VALUE=DATE:')) {
                String[] days = part.substringAfter('VALUE=DATE:').split(',');
                for (String day : days) {
                    if (!parsedDays.contains(VCC_RepeatingRule.parseRFC5545DateToApexDate(day))) {
                        return false;
                    }
                }
                return true;
            }
        }
        return false;
    }

    //private helper method for assertions
    private static Integer getDayOfWeekAsInteger(Date dateToExamine) {
        Date beginningOfWeek = dateToExamine.toStartofWeek();
        return beginningOfWeek.daysBetween(dateToExamine);
    }
}
