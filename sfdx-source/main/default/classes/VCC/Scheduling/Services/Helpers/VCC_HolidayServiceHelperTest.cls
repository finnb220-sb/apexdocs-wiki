/**
 * @author Booz Allen Hamilton
 * @since 5/20/24
 * @description Unit Tests for VCC_HolidayServiceHelper
 * @see VCC_HolidayServiceHelper
 */
@IsTest
private with sharing class VCC_HolidayServiceHelperTest {
    private static Datetime currentDatetime = Datetime.now();
    private static final User SYSTEM_ADMIN_USER;
    private static final User SCHEDULING_USER;
    static {
        SYSTEM_ADMIN_USER = new VATEST_UserBuilder()
            .withUserProfile('System Administrator')
            .withStandardData()
            .build(true);

        SCHEDULING_USER = new VATEST_UserBuilder()
            .withPermissionSet('VAHC_Scheduling_User')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
    }
    /**
     * @description Test recurring holiday for Monthly Nth
     */
    @IsTest
    static void unitRecurringMonthlyNthPositive() {
        Holiday monthlyNthHoliday;
        System.runAs(SYSTEM_ADMIN_USER) {
            monthlyNthHoliday = new Holiday(
                Name = 'Last Friday of the Month Holiday',
                RecurrenceType = 'RecursMonthlyNth',
                RecurrenceStartDate = Date.newInstance(2024, 1, 26),
                ActivityDate = Date.newInstance(2024, 1, 26),
                RecurrenceDayOfWeekMask = 32,
                RecurrenceInstance = 'Last',
                RecurrenceInterval = 1,
                IsRecurrence = true,
                IsAllDay = true
            );
        }

        System.runAs(SCHEDULING_USER) {
            Test.startTest();
            VCC_HolidayServiceHelper instance = new VCC_HolidayServiceHelper();
            List<Date> holidayInstances = instance.getHolidayInstancesWithinDateRange(
                monthlyNthHoliday,
                Date.newInstance(2024, 1, 1),
                Date.newInstance(2025, 1, 1)
            );
            Assert.areEqual(
                12,
                holidayInstances.size(),
                'Expected 1 "Last Friday of the Month Holiday" to be returned for every month of year for a total of 12 in a year.'
            );
            Test.stopTest();
        }
    }

    /**
     * @description Test recurring holiday for Yearly holidays on the 25th of September
     */
    @IsTest
    static void unitChristmasRecurringYearlyPositive() {
        Holiday yearlyNthHoliday;
        System.runAs(SYSTEM_ADMIN_USER) {
            yearlyNthHoliday = new Holiday(
                Name = 'Christmas Day',
                RecurrenceType = 'RecursYearly',
                RecurrenceStartDate = Date.newInstance(2024, 12, 25),
                ActivityDate = Date.newInstance(2024, 12, 25),
                RecurrenceDayOfMonth = 25,
                RecurrenceMonthOfYear = 'December',
                IsRecurrence = true,
                IsAllDay = true
            );
        }

        System.runAs(SCHEDULING_USER) {
            Date xMasDay2024 = Date.newInstance(2024, 12, 25);

            Test.startTest();
            VCC_HolidayServiceHelper instance = new VCC_HolidayServiceHelper();
            List<Date> holidayInstances = instance.getHolidayInstancesWithinDateRange(
                yearlyNthHoliday,
                Date.newInstance(2024, 1, 1),
                Date.newInstance(2025, 1, 1)
            );
            Assert.areEqual(1, holidayInstances.size(), 'Expected 1 Christmas day in a one year date range!');
            Date result = holidayInstances.get(0);
            Assert.areEqual(
                xMasDay2024,
                result,
                'Expected Holiday to recur on the 25th of December 2024, Christmas Day.'
            );
            Test.stopTest();
        }
    }

    /**
     * @description Test recurring holiday MLK Day, that occurs every 3rd Monday of January every year.
     */
    @IsTest
    static void unitMLKDayEvery3rdMondayOfJanuaryYearlyPositive() {
        Holiday yearlyNthHoliday;
        System.runAs(SYSTEM_ADMIN_USER) {
            yearlyNthHoliday = new Holiday(
                Name = 'Martin Luther King Day',
                RecurrenceType = 'RecursYearlyNth',
                RecurrenceStartDate = Date.newInstance(2022, 1, 17),
                ActivityDate = Date.newInstance(2022, 1, 17),
                RecurrenceDayOfWeekMask = 2,
                RecurrenceInstance = 'Third',
                RecurrenceMonthOfYear = 'January',
                IsRecurrence = true,
                IsAllDay = true
            );
        }

        System.runAs(SCHEDULING_USER) {
            Date mlkDay2023 = Date.newInstance(2023, 1, 16);
            Test.startTest();
            VCC_HolidayServiceHelper instance = new VCC_HolidayServiceHelper();
            List<Date> holidayInstances = instance.getHolidayInstancesWithinDateRange(
                yearlyNthHoliday,
                Date.newInstance(2023, 1, 1),
                Date.newInstance(2024, 1, 1)
            );
            Assert.areEqual(1, holidayInstances.size(), 'Expected One MLK Day one year date range!');
            Date result = holidayInstances.get(0);
            Assert.areEqual(
                mlkDay2023,
                result,
                'Expected Holiday to recur on Monday January 16th, Martin Luther King Jr, Day.'
            );
            Test.stopTest();
        }
    }

    /**
     * @description Test recurring holiday for Monthly
     */
    @IsTest
    static void unitRecurringMonthlyPositive() {
        Holiday monthlyHoliday;
        System.runAs(SYSTEM_ADMIN_USER) {
            monthlyHoliday = new Holiday(
                Name = '15th of the Month Holiday',
                RecurrenceType = 'RecursMonthly',
                RecurrenceStartDate = Date.newInstance(2024, 1, 15),
                ActivityDate = Date.newInstance(2024, 1, 15),
                RecurrenceDayOfMonth = 15,
                IsRecurrence = true,
                IsAllDay = true
            );
        }

        System.runAs(SCHEDULING_USER) {
            Test.startTest();
            VCC_HolidayServiceHelper instance = new VCC_HolidayServiceHelper();
            List<Date> holidayInstances = instance.getHolidayInstancesWithinDateRange(
                monthlyHoliday,
                Date.newInstance(2024, 1, 1),
                Date.newInstance(2025, 1, 1)
            );
            Assert.areEqual(
                12,
                holidayInstances.size(),
                'Expected 1 "15th of the Month Holiday" to be returned for every month of the year for a total of 12.'
            );
            Test.stopTest();
        }
    }

    /**
     * @description Test recurring holiday for Weekly cadence
     */
    @IsTest
    static void unitRecurringWeeklyPositive() {
        Holiday weeklyHoliday;
        System.runAs(SYSTEM_ADMIN_USER) {
            weeklyHoliday = new Holiday(
                Name = 'Altered Week Schedule - Fridays Off',
                RecurrenceType = 'RecursWeekly',
                RecurrenceStartDate = Date.newInstance(2024, 1, 5),
                ActivityDate = Date.newInstance(2024, 1, 5),
                RecurrenceInterval = 1,
                RecurrenceDayOfWeekMask = 32,
                IsRecurrence = true,
                IsAllDay = true
            );
        }

        System.runAs(SCHEDULING_USER) {
            Test.startTest();
            VCC_HolidayServiceHelper instance = new VCC_HolidayServiceHelper();
            List<Date> holidayInstances = instance.getHolidayInstancesWithinDateRange(
                weeklyHoliday,
                Date.newInstance(2024, 1, 1),
                Date.newInstance(2025, 1, 1)
            );
            Assert.areEqual(
                52,
                holidayInstances.size(),
                'Expected 1 "Altered Week Schedule - Fridays Off" to be returned for every week of the year for a total of 52.'
            );
            Test.stopTest();
        }
    }

    /**
     * @description Test recurring holiday for Daily cadence
     */
    @IsTest
    static void unitRecurringDailyPositive() {
        Holiday dailyHoliday;
        System.runAs(SYSTEM_ADMIN_USER) {
            dailyHoliday = new Holiday(
                Name = 'Winter Holiday Break - Offices Closed',
                RecurrenceType = 'RecursDaily',
                RecurrenceStartDate = Date.newInstance(2024, 12, 20),
                RecurrenceEndDateOnly = Date.newInstance(2025, 1, 3),
                ActivityDate = Date.newInstance(2024, 12, 20),
                RecurrenceInterval = 1,
                IsRecurrence = true,
                IsAllDay = true
            );
        }

        System.runAs(SCHEDULING_USER) {
            Test.startTest();
            VCC_HolidayServiceHelper instance = new VCC_HolidayServiceHelper();
            List<Date> holidayInstances = instance.getHolidayInstancesWithinDateRange(
                dailyHoliday,
                Date.newInstance(2024, 1, 1),
                Date.newInstance(2025, 1, 6)
            );
            Assert.areEqual(
                15,
                holidayInstances.size(),
                'Expected 15 "Winter Holiday Break - Offices Closed" to be returned, 1 for each day over break 12/20/24 - 1/3/2025.'
            );
            Test.stopTest();
        }
    }

    /**
     * @description - Sets up a holiday and checks if today is that holiday
     */
    @IsTest
    static void unitHolidayCheckPositive() {
        Holiday newHoliday;
        System.runAs(SYSTEM_ADMIN_USER) {
            VATEST_SObjectFactory.createSObject(
                newHoliday = (Holiday) new Holiday(Name = 'Test Holiday', ActivityDate = currentDatetime.date()),
                true
            );
        }

        System.runAs(SCHEDULING_USER) {
            Test.startTest();
            VCC_HolidayServiceHelper instance = new VCC_HolidayServiceHelper();
            Boolean isTodayHoliday = instance.calculateIfTodayIsHoliday(newHoliday);
            Assert.isTrue(isTodayHoliday, 'Expected isTodayHoliday to be True, but was False.');
            Test.stopTest();
        }
    }

    /**
     * @description - Sets up a recurring holiday and checks if today is that holiday
     */
    @IsTest
    static void unitRecurringHolidayCheckPositive() {
        Date currentDateLastYear = currentDatetime.date().addYears(-1);
        Holiday newHoliday;
        System.runAs(SYSTEM_ADMIN_USER) {
            VATEST_SObjectFactory.createSObject(
                newHoliday = (Holiday) new Holiday(
                    Name = 'Test Holiday',
                    ActivityDate = currentDateLastYear, //set this to last year
                    isRecurrence = true,
                    RecurrenceStartDate = currentDateLastYear,
                    RecurrenceDayOfMonth = currentDatetime.day(),
                    RecurrenceMonthOfYear = currentDateTime.format('MMMM'),
                    RecurrenceType = 'RecursYearly'
                ),
                true
            );
        }

        System.runAs(SCHEDULING_USER) {
            Test.startTest();
            VCC_HolidayServiceHelper instance = new VCC_HolidayServiceHelper();
            Boolean isTodayHoliday = instance.calculateIfTodayIsHoliday(newHoliday);
            Assert.isTrue(isTodayHoliday, 'Expected isTodayHoliday to be True, but was False.');
            Test.stopTest();
        }
    }
}
