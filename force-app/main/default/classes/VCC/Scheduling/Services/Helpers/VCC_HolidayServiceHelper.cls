/**
 * @author Booz Allen Hamilton
 * @since 5/13/24
 * @description VCC_HolidayServiceHelper - provides utility method(s) for parsing out next instance(s) of a
 *      Holiday within a Start/End date range for use in generating Utilization records.
 *      See here for source of code: https://salesforce.stackexchange.com/questions/158547/recurring-holidays-exclude-holidays-between-two-dates
 * @example
 *  `Holiday recurringHoliday = [SELECT Id, Name, RecurrenceStartDate, RecurrenceType, RecurrenceInstance, RecurrenceInterval, RecurrenceDayOfMonth,
 *      RecurrenceEndDateOnly, RecurrenceDayOfWeekMask, RecurrenceMonthOfYear, IsRecurrence, IsAllDay
 *      FROM Holiday
 *      WHERE IsRecurrence = TRUE LIMIT 1]; // populate with a Holiday record to find
 *  Date startDate = Date.newInstance(2024, 1, 1); // look from start of year 2024
 *  Date endDate = Date.newInstance(2024, 12, 31); // to end of year
 *  VCC_HolidayServiceHelper helper = new VCC_HolidayServiceHelper();
 * List<Date> holidayInstances = helper.getHolidayInstancesWithinDateRange(recurringHoliday, startDate, endDate);
 * // Process holidayInstances
 *  `
 * @see VCC_OperatingHoursHolidayService
 *
 * Suppressing warnings given time constraints.
 */
@SuppressWarnings('PMD.CognitiveComplexity, PMD.CyclomaticComplexity')
public with sharing class VCC_HolidayServiceHelper {
    // Map that returns day of week from dayOfWeekMask on Holiday: 1 =  1 - Sunday, 2 = 2 Monday, 4 = 3 Tuesday, /8 = 4 Wednesday, 16 = 5 Thursday, 32 = 6 Friday, 64 = 7 Saturday
    private static final Map<Integer, Integer> BIT_MASK_TO_DAY_OF_WEEK = new Map<Integer, Integer>{
        1 => 1,
        2 => 2,
        4 => 3,
        8 => 4,
        16 => 5,
        32 => 6,
        64 => 7
    };

    // Map that returns an Integer representation of month String // getMonthMap()
    private static final Map<String, Integer> MONTH_NAME_TO_NUMBER = new Map<String, Integer>{
        'January' => 1,
        'February' => 2,
        'March' => 3,
        'April' => 4,
        'May' => 5,
        'June' => 6,
        'July' => 7,
        'August' => 8,
        'September' => 9,
        'October' => 10,
        'November' => 11,
        'December' => 12
    };

    // Map that returns Integer representation of week number string getWeekMap()
    private static final Map<String, Integer> WEEK_NUMBER_STRING_TO_NUMBER = new Map<String, Integer>{
        'First' => 1,
        'Second' => 2,
        'Third' => 3,
        'Fourth' => 4,
        'Fifth' => 5
    };

    // createDayOfWeekMap()
    private static final Map<String, Integer> DAY_OF_WEEK_NAME_TO_NUMBER = new Map<String, Integer>{
        'Sunday' => 1,
        'Monday' => 2,
        'Tuesday' => 3,
        'Wednesday' => 4,
        'Thursday' => 5,
        'Friday' => 6,
        'Saturday' => 7
    };

    /**
     * @description Main entry point to use for this class
     *
     * @param recurringHoliday Holiday record to parse and return Date(s) if any that fall within startDate & endDate. Assumption
     *  is that it is a recurring holiday
     * @param startDate `Date` (inclusive) to search for Holiday instances after
     * @param endDate `Date` (inclusive) to search for Holiday instances before
     *
     * @return `List<Date>` list of Dates that fall within startDate & endDate of recurringHoliday
     */

    public List<Date> getHolidayInstancesWithinDateRange(Holiday recurringHoliday, Date startDate, Date endDate) {
        List<Date> dates = new List<Date>();
        if (recurringHoliday.RecurrenceType == 'RecursYearlyNth') {
            dates = getYearlyNthHoliday(recurringHoliday, startDate, endDate);
        } else if (recurringHoliday.RecurrenceType == 'RecursYearly') {
            dates = getYearlyHoliday(recurringHoliday, startDate, endDate);
        } else if (recurringHoliday.RecurrenceType == 'RecursMonthlyNth') {
            dates = getMonthlyNthHoliday(recurringHoliday, startDate, endDate);
        } else if (recurringHoliday.RecurrenceType == 'RecursMonthly') {
            dates = getMonthlyHoliday(recurringHoliday, startDate, endDate);
        } else if (recurringHoliday.RecurrenceType == 'RecursWeekly') {
            dates = getWeeklyHoliday(recurringHoliday, startDate, endDate);
        } else if (recurringHoliday.RecurrenceType == 'RecursDaily') {
            dates = getDailyHoliday(recurringHoliday, startDate, endDate);
        }
        return dates;
    }

    private List<Date> getYearlyHoliday(Holiday yearlyHoliday, Date startDate, Date endDate) {
        //recurs on set days in a year, like Christmas, New Years
        List<Date> toReturn = new List<Date>();
        for (Integer year : getYears(startDate, endDate)) {
            Integer month = MONTH_NAME_TO_NUMBER.get(yearlyHoliday.RecurrenceMonthOfYear);
            Date newDate = Date.newInstance(year, month, yearlyHoliday.RecurrenceDayOfMonth);
            if (newDate >= startDate && newDate <= endDate) {
                toReturn.add(newDate);
            }
        }
        return toReturn;
    }

    private List<Date> getYearlyNthHoliday(Holiday yearlyNthHoliday, Date startDate, Date endDate) {
        //recurs on something like 2nd tuesday of march - Thanksgiving, MLK day, Columbus Day
        List<Date> toReturn = new List<Date>();

        Integer day = BIT_MASK_TO_DAY_OF_WEEK.get(yearlyNthHoliday.RecurrenceDayOfWeekMask);
        Integer month = MONTH_NAME_TO_NUMBER.get(yearlyNthHoliday.RecurrenceMonthOfYear);
        for (Integer year : getYears(startDate, endDate)) {
            Date newDate;
            if (yearlyNthHoliday.RecurrenceInstance == 'Last') {
                newDate = getLastXOfMonth(day, month, year);
            } else {
                Integer week = WEEK_NUMBER_STRING_TO_NUMBER.get(yearlyNthHoliday.RecurrenceInstance);
                newDate = getXDayOfMonth(week, day, Date.newInstance(year, month, 2));
            }
            if (newDate >= startDate && newDate <= endDate) {
                toReturn.add(newDate);
            }
        }
        return toReturn;
    }

    private List<Date> getMonthlyHoliday(Holiday monthlyHoliday, Date startDate, Date endDate) {
        //recurs on set day of every month - something like 5th of every month
        List<Date> toReturn = new List<Date>();
        for (Date nextDate : getMonths(startDate, endDate)) {
            Date newDate = Date.newInstance(nextDate.year(), nextDate.month(), monthlyHoliday.RecurrenceDayOfMonth);
            if (newDate >= startDate && newDate <= endDate) {
                toReturn.add(newDate);
            }
        }
        return toReturn;
    }
    private List<Date> getMonthlyNthHoliday(Holiday monthlyNthHoliday, Date startDate, Date endDate) {
        //recurs monthly - something like every second sunday
        List<Date> toReturn = new List<Date>();

        List<Date> months = getMonths(startDate, endDate);
        Integer day = BIT_MASK_TO_DAY_OF_WEEK.get(monthlyNthHoliday.RecurrenceDayOfWeekMask);

        Integer week = WEEK_NUMBER_STRING_TO_NUMBER.get(monthlyNthHoliday.RecurrenceInstance);
        for (Date month : months) {
            Date holidayDate;
            if (monthlyNthHoliday.RecurrenceInstance == 'Last') {
                holidayDate = getLastXOfMonth(day, month.month(), month.year());
            } else {
                holidayDate = getXDayOfMonth(week, day, date.newInstance(month.year(), month.month(), 1));
            }
            if (holidayDate >= startDate && holidayDate <= endDate) {
                toReturn.add(holidayDate);
            }
        }
        return toReturn;
    }
    private List<Date> getWeeklyHoliday(Holiday weeklyHoliday, Date startDate, Date endDate) {
        //something like every sat, sun or tues
        List<Date> toReturn = new List<Date>();
        Integer day = BIT_MASK_TO_DAY_OF_WEEK.get(weeklyHoliday.RecurrenceDayOfWeekMask);
        Datetime newDate = Datetime.newInstance(startDate.year(), startDate.month(), startDate.day(), 0, 0, 0); //valueOf(startDate);
        while (DAY_OF_WEEK_NAME_TO_NUMBER.get(newDate.format('EEEE')) != day) {
            newDate = newDate.addDays(1);
        }
        while (newDate <= endDate) {
            if (newDate >= startDate && newDate <= endDate) {
                toReturn.add(Date.valueOf(newDate));
            }
            newDate = newDate.addDays(7);
        }
        return toReturn;
    }

    private List<Date> getDailyHoliday(Holiday dailyHoliday, Date startDate, Date endDate) {
        //something like every 15 days from start
        List<Date> toReturn = new List<Date>();
        Integer remainder;
        // if startDate is after RecurrenceStartDate, do not count days prior to the start, jump ahead to start of recurring holiday
        if (dailyHoliday.RecurrenceStartDate >= startDate && dailyHoliday.RecurrenceStartDate <= endDate) {
            startDate = dailyHoliday.recurrenceStartDate;
        } else {
            // dates are outside of recurrence start date - return empty list now
            return toReturn;
        }
        Date dailyDate = startDate.addDays(-1);
        while (remainder != 0) {
            dailyDate = dailyDate.addDays(1);
            remainder = Math.mod(
                dailyHoliday.RecurrenceStartDate.daysBetween(dailyDate),
                dailyHoliday.RecurrenceInterval
            );
        }
        toReturn.add(dailyDate);
        while (dailyDate <= endDate && dailyDate <= dailyHoliday.RecurrenceEndDateOnly) {
            dailyDate = dailyDate.addDays(dailyHoliday.RecurrenceInterval);
            if (dailyDate >= startDate && dailyDate <= endDate && dailyDate <= dailyHoliday.RecurrenceEndDateOnly) {
                toReturn.add(dailyDate);
            }
        }
        return toReturn;
    }

    private Date getLastXOfMonth(Integer dayOfWeek, Integer month, Integer year) {
        Datetime lastMonthDate = Datetime.newInstance(year, month + 1, 0, 0, 0, 0);
        Integer day = DAY_OF_WEEK_NAME_TO_NUMBER.get(lastMonthDate.format('EEEE'));

        while (day != dayOfWeek) {
            lastMonthDate = lastMonthDate.addDays(-1);
            day = DAY_OF_WEEK_NAME_TO_NUMBER.get(lastMonthDate.format('EEEE'));
        }
        return Date.valueOf(lastMonthDate);
    }

    private Date getXDayOfMonth(Integer week, Integer day, Date monthIn) {
        Datetime firstMonthDate = Datetime.newInstance(monthIn.year(), monthIn.month(), 0, 0, 0, 0);

        Integer dayName;
        while (dayName != day) {
            firstMonthDate = firstMonthDate.addDays(1);
            dayName = DAY_OF_WEEK_NAME_TO_NUMBER.get(firstMonthDate.format('EEEE'));
        }
        if (week == 1) {
            return Date.valueOf(firstMonthDate);
        } else {
            return Date.valueOf(firstMonthDate.addDays(7 * (week - 1)));
        }
    }

    /**
     * @description Return a list of Dates, one for the 1st of each Month between input startDate & endDate
     *
     * @example
     * `Date startDate = Date.newInstance(2020,1,5);
     *  Date endDate = Date.newInstance(2021,5,1);
     *  List<Integer> years = getMonths(startDate, endDate);
     *
     *  years should be ["2020-01-01", "2020-02-01", "2020-03-01", "2020-04-01", "2020-05-01",
     *  "2020-06-01", "2020-07-01", "2020-08-01", "2020-09-01", "2020-10-01", "2020-11-01", "2020-12-01",
     *  "2021-01-01", "2021-02-01", "2021-03-01", "2021-04-01", "2021-05-01"]`
     *
     * @param startDate date from which we start counting the months
     * @param endDate date until which we count the months
     *
     * @return `List<Date>` List of Date(s) that are between startDate & endDate inclusive
     */
    private List<Date> getMonths(Date startDate, Date endDate) {
        List<Date> months = new List<Date>();
        Date month = Date.newInstance(startDate.year(), startDate.month(), 1);
        months.add(month);
        if (startDate.month() != endDate.month() || startDate.year() != endDate.year()) {
            while (month.monthsBetween(endDate) != 0) {
                month = month.addMonths(1);
                months.add(month);
            }
        }
        return months;
    }

    /**
     * @description Return the number of years between input startDate & endDate
     * @example
     * `Date startDate = Date.newInstance(2020,1,5);
     *  Date endDate = Date.newInstance(2024,5,1);
     *  List<Integer> years = getYears(startDate, endDate);
     *
     *  years should be [2020, 2021, 2022, 2023, 2024]`
     *
     * @param startDate date from which we start counting the years
     * @param endDate date until which we count the years
     *
     * @return `List<Integer>` List of years that are between startDate & endDate inclusive
     */
    private List<Integer> getYears(Date startDate, Date endDate) {
        List<Integer> years = new List<Integer>();
        Integer year = startDate.year();
        years.add(year);
        if (startDate.year() != endDate.year()) {
            while (year != endDate.year()) {
                year = year + 1;
                years.add(year);
            }
        }
        return years;
    }

    /**
     * @description - Takes in a Holiday and calculates if today's date matches that Holiday, calculating both recurring
     *                and non-recurring holidays.
     * @param holidayToCalc - The Holiday to calculate against
     * @return Boolean - True or False based on if today is a holiday
     */
    public Boolean calculateIfTodayIsHoliday(Holiday holidayToCalc) {
        Boolean isTodayHoliday = false;
        Date currentDate = System.today();

        if (!holidayToCalc.IsRecurrence) {
            return (holidayToCalc.ActivityDate == currentDate);
        }
        Holiday recurrenceHoliday = holidayToCalc;
        Date currentYearJanuaryFirst = Date.newInstance(currentDate.year(), 1, 1);
        Date currentYearDecemberThirtyFirst = Date.newInstance(currentDate.year(), 12, 31);
        List<Date> recurrenceDateList = getHolidayInstancesWithinDateRange(
            recurrenceHoliday,
            currentYearJanuaryFirst,
            currentYearDecemberThirtyFirst
        );
        if (recurrenceDateList.contains(currentDate)) {
            isTodayHoliday = true;
        }

        return isTodayHoliday;
    }
}
