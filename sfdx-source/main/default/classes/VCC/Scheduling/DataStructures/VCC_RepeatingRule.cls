/**
 * @description This class is responsible for parsing RFC-5545 compliant 'Repeating Rules'
 * that specify how and when a given event repeats on a calendar. The entire specification is quite
 * lengthy and this class represents a small fraction of the RFC. Specifically, this class is only interested
 * in parsing RRules.
 *
 * @see VCC_RepeatingRuleTest
 * Suppressing given the time constraints and that this was supposed to be
 */
@SuppressWarnings('PMD.CognitiveComplexity, PMD.CyclomaticComplexity')
public with sharing class VCC_RepeatingRule {
    /**
     * @description Exception thrown when an illegal RRule is passed into the parser.
     */
    public class ArgumentException extends Exception {
    }

    /**
     * @description These enums are used to ensure compliance with the RFC-5545 specification.
     */
    @TestVisible
    private enum RFC5545Frequency {
        DAILY,
        WEEKLY,
        MONTHLY
    }
    private enum RFC5545Component {
        FREQ,
        UNTIL,
        INTERVAL,
        COUNT,
        BYDAY,
        BYMONTHDAY,
        BYSETPOS,
        VALUE
    }
    @TestVisible
    private enum RFC5545DayOfWeek {
        SU,
        MO,
        TU,
        WE,
        TH,
        FR,
        SA
    }

    /**
     * @description contains the start Datetime object from the parent Shift record.
     */
    public final Datetime startDatetime;
    /**
     * @description contains the end Datetime object from the parent Shift record.
     */
    public final Datetime endDatetime;
    /**
     * @description contains the parsed frequency of the repeating rule.
     */
    public final RFC5545Frequency frequency;
    /**
     * @description contains the parsed date that this rule repeats until.
     */
    public final Date until;
    /**
     * @description contains the parsed interval of the repeating rule. The interval references the number of days, weeks or months between each occurrence.
     */
    public final Integer interval;
    /**
     * @description contains the parsed count of the repeating rule. The count references the number of occurrences of the rule.
     */
    public final Integer count;
    /**
     * @description contains the parsed days of the week that the rule repeats on. Each day in the set is represented by an enum value.
     */
    public Set<RFC5545DayOfWeek> repeatOnDaysOfWeek = new Set<RFC5545DayOfWeek>();
    /**
     * @description contains the parsed relative occurrence of the repeating rule.
     * This is used to specify the nth occurrence of a day of the week in a month.
     * For example: Given the rule stating it repeats the 2nd Tuesday of the month; This holds the value 2.
     * It defaults to 0, because this field is optional in the RFC-5545 specification.
     */
    public Integer relativeOccurrence = 0;
    /**
     * @description contains the parsed exclusion dates of the repeating rule.
     * This is used to specify dates that should be excluded from the repeating rule.
     */
    public Set<Date> exclusionDates = new Set<Date>();

    public Integer monthOffset = 0;

    public Integer byMonthDay = 0;

    private final Boolean repeatsUntilDate {
        get {
            return until != null && count == null;
        }
    }

    /**
     * @description Generates a Time object from the startDatetime property.
     * Used when creating the time portion of new datetime objects.
     */
    private final Time startTime {
        get {
            return Time.newInstance(this.startDateTime.hour(), this.startDateTime.minute(), 0, 0);
        }
    }

    /**
     * @description calculates the effective interval in days based on the frequency and interval properties.
     */
    private final Integer effectiveIntervalInDays {
        get {
            switch on frequency {
                when DAILY {
                    return interval;
                }
                when WEEKLY {
                    return interval * 7;
                }
                when MONTHLY {
                    monthOffset = monthOffset + 1;
                    return startDatetime.date().daysBetween(startDatetime.date().addMonths((monthOffset * interval)));
                }
                when else {
                    throw new VCC_RepeatingRule.ArgumentException('Unsupported frequency: ' + frequency);
                }
            }
        }
    }

    /**
     * @description mutates the date input and returns it's RFC5545DayOfWeek enum value.
     * @param dateVal Date the date to be mutated into a RFC5545DayOfWeek enum.
     *
     * @return RFC5545DayOfWeek - the mutated date as an RFC5545DayOfWeek enum.
     */
    private static RFC5545DayOfWeek toDayOfWeek(Datetime dateVal) {
        return RFC5545DayOfWeek.valueOf(dateVal.formatGmt('E').left(2).toUpperCase());
    }

    /**
     * @description Calculates the last day of the month for a given date.
     * @param dateVal Date the date to find the last day of the month for.
     *
     * @return Date - the last day of the month for the given date.
     */
    private static Date toEndOfMonth(Date dateVal) {
        return dateVal.toStartOfMonth().addMonths(1).addDays(-1);
    }

    /**
     * @description Custom sorter class for days of the week.
     * Comparator interface allows sort order to be based on daysOfTheWeek.
     */
    public class DaysOfWeekSorter implements Comparator<String> {
        /**
         * @description Based on the startDateTime of the recurrence pattern.
         * If the startDateTime falls on a Tuesday, then the order of the daysOfTheWeek will be {TU,WE,TH,FR,SA,SU,MO}.
         */
        public List<String> daysOfTheWeek = new List<String>();
        /**
         * @description Compares two elements in the recurrence pattern day list. Sort order is based on daysOfTheWeek.
         *
         * @param currentElement `String` - current element in the recurrence pattern
         * @param nextElement `String` - current element + 1 in the recurrence pattern
         * @return      `Integer` - Returns 0 if elements indexes are equal.
         * Returns negative value if nextElement index is greater than currentElement index.
         * Return postive value if currentElement index is greater than nextElement index.
         */
        public Integer compare(String currentElement, String nextElement) {
            if (String.isBlank(currentElement) || String.isBlank(nextElement)) {
                return 0;
            } else {
                return this.daysOfTheWeek.indexOf(currentElement) - this.daysOfTheWeek.indexOf(nextElement);
            }
        }
    }

    /////////// constructors //////////

    /**
     * @description Default constructor responsible for parsing the RRule
     * @param rruleText String
     * @param startDatetime Datetime the start date of the repeating rule from the parent Shift record
     * @param endDatetime Datetime the end date of the repeating rule from the parent Shift record
     */

    public VCC_RepeatingRule(String rruleText, Datetime startDatetime, Datetime endDatetime) {
        this.startDatetime = startDatetime;
        this.endDatetime = endDatetime;

        // guard against non RRules being parsed.
        if (rruleText == null || rruleText.length() == 0 || !rruleText.startsWith('RRULE')) {
            throw new IllegalArgumentException('Invalid RRULE: ' + rruleText);
        }

        Map<RFC5545Component, String> keyValuePairs = parseRRuleStringIntoKeyValuePairs(rruleText);
        this.frequency = RFC5545Frequency.valueOf(keyValuePairs.get(RFC5545Component.FREQ)) ?? RFC5545Frequency.WEEKLY; // this cannot be null
        if (keyValuePairs.containsKey(RFC5545Component.UNTIL)) {
            this.until = parseRFC5545DateToApexDate(keyValuePairs.get(RFC5545Component.UNTIL)) ?? null;
        }
        this.interval = Integer.valueOf(keyValuePairs.get(RFC5545Component.INTERVAL)) ?? 1;
        if (keyValuePairs.containsKey(RFC5545Component.COUNT)) {
            this.count = Integer.valueOf(keyValuePairs.get(RFC5545Component.COUNT));
        }
        if (keyValuePairs.containsKey(RFC5545Component.BYDAY)) {
            this.repeatOnDaysOfWeek.addAll(
                extractDaysOfWeek(keyValuePairs.get(RFC5545Component.BYDAY), this.startDatetime)
            );
        }
        if (keyValuePairs.containsKey(RFC5545Component.BYMONTHDAY)) {
            this.byMonthDay = Integer.valueOf(keyValuePairs.get(RFC5545Component.BYMONTHDAY));
        }
        String setPos = keyValuePairs.containsKey(RFC5545Component.BYSETPOS)
            ? keyValuePairs.get(RFC5545Component.BYSETPOS)
            : '0';
        this.relativeOccurrence = Integer.valueOf(setPos);
        if (keyValuePairs.containsKey(RFC5545Component.VALUE)) {
            this.exclusionDates = parseExclusionDates(keyValuePairs.get(RFC5545Component.VALUE)) ?? new Set<Date>();
        }
    }

    /////////// Private Helper Methods ///////////

    /**
     * @description Extracts RFC5545DayOfWeek enum values from a string of comma separated day of week values.
     * @param daysOfWeekString `String` substring of the RRule string that contains the days of the week.
     * @param startDatetime `Datetime` - start date of recurrence pattern
     * @return `Set<RFC5545DayOfWeek>` - a set of RFC5545DayOfWeek enum values.
     */
    @TestVisible
    private static Set<RFC5545DayOfWeek> extractDaysOfWeek(String daysOfWeekString, Datetime startDatetime) {
        List<String> sortedDaysOfWeek = sortDaysOfWeek(daysOfWeekString, startDatetime);
        Set<RFC5545DayOfWeek> daysOfWeek = new Set<RFC5545DayOfWeek>();
        for (String dayOfWeek : sortedDaysOfWeek) {
            daysOfWeek.add(RFC5545DayOfWeek.valueOf(dayOfWeek));
        }
        return daysOfWeek;
    }

    /**
     * @description   Sorts days of the week based on the start day
     * @param daysOfWeekString `String` - string of recurrence pattern BYDAY
     * @param startDatetime `Datetime` - start date of recurrence pattern
     * @return daysOfWeek `List<String>` - dynamically ordered list of the days of the week
     */
    @TestVisible
    private static List<String> sortDaysOfWeek(String daysOfWeekString, Datetime startDatetime) {
        String sortedDaysOfTheWeek = 'SU, MO, TU, WE, TH, FR, SA';
        Datetime start = startDatetime;

        if (String.isBlank(daysOfWeekString)) {
            return new List<String>();
        } else {
            Integer indexOfStartDay = sortedDaysOfTheWeek.indexOf((toDayOfWeek(start)).name());

            // sorts string of days of the week based on the start day
            String dynamicallySortedDaysOfTheWeek =
                sortedDaysOfTheWeek.substring(indexOfStartDay) +
                ', ' +
                sortedDaysOfTheWeek.substring(0, indexOfStartDay);

            // convert sortedDaysOfTheWeek String to List<String>
            List<String> dynamicallySortedDaysOfTheWeekList = dynamicallySortedDaysOfTheWeek.split(', ');

            // convert input daysOfWeekString to List<String>
            List<String> daysOfWeek = daysOfWeekString.split(',');

            // initialize comparator and sort list
            VCC_RepeatingRule.DaysOfWeekSorter weekDaySorter = new VCC_RepeatingRule.DaysOfWeekSorter();
            weekDaySorter.daysOfTheWeek = dynamicallySortedDaysOfTheWeekList;
            daysOfWeek.sort(weekDaySorter);
            return daysOfWeek;
        }
    }

    /**
     * @description Parses a comma separated string of exclusion dates into a Set of Date objects.
     * @param exclusionDatesString String the substring of the RRule string that contains the exclusion dates.
     *
     * @return Set<Date> - a set of Date objects.
     */
    @TestVisible
    private static Set<Date> parseExclusionDates(String exclusionDatesString) {
        Set<Date> exclusionDates = new Set<Date>();
        // strip off DATE: prefix
        exclusionDatesString = exclusionDatesString.substring(5);
        String[] dateStrings = exclusionDatesString.split(',');
        for (String dateString : dateStrings) {
            exclusionDates.add(parseRFC5545DateToApexDate(dateString));
        }
        return exclusionDates;
    }

    /**
     * @description Parses a RFC-5545 compliant date string into an Apex Date object.
     * @param dateString String the date string to be parsed.
     *
     * @return Date - the parsed date.
     */
    @TestVisible
    private static Date parseRFC5545DateToApexDate(String dateString) {
        return Date.newInstance(
            Integer.valueOf(dateString.substring(0, 4)),
            Integer.valueOf(dateString.substring(4, 6)),
            Integer.valueOf(dateString.substring(6, 8))
        );
    }

    /**
     * @description Parses a Key / Value pair string into a Tuple object
     * @param keyValue String the input string in key=value format
     *
     * @return Tuple - a Tuple object with a key and value property.
     */
    private static Tuple parseKeyValueString(String keyValue) {
        String[] parts = keyValue.split('=');
        if (parts.size() == 2 && String.isNotBlank(parts[0].trim()) && String.isNotBlank(parts[1].trim())) {
            return new Tuple(parts[0].trim(), parts[1].trim());
        }
        return null;
    }

    /**
     * @description Parses the RRule string into a Map of RFC5545Component and String key value pairs.
     * @param rruleText String the RRule string to be parsed.
     *
     * @return Map<RFC5545Component,String> - a map of RFC5545Component and String key value pairs.
     */
    private static Map<RFC5545Component, String> parseRRuleStringIntoKeyValuePairs(String rruleText) {
        Map<RFC5545Component, String> keyValuePairs = new Map<RFC5545Component, String>();
        // strip off RRULE: prefix
        Set<RFC5545Component> foundComponents = new Set<RFC5545Component>();
        rruleText = rruleText.substring(6);
        String[] components = rruleText.split(';');
        for (String component : components) {
            Tuple keyValue = parseKeyValueString(component);
            if (keyValue != null) {
                RFC5545Component key = RFC5545Component.valueOf(keyValue.key);
                foundComponents.add(key);
                keyValuePairs.put(key, keyValue.value);
            }
        }
        // TODO: we should validate that the required components are present. Ie: a Frequency, and either count or util etc.
        // if (parsedResultIsInvalid()){ throw new ArgumentException('no parse for you!'); }
        return keyValuePairs;
    }

    /**
     * @description Calculates the future occurrences of the repeating rule.
     * The idea here, is that this method, returns the future occurrences of the repeating rule in the
     * form of Date objects
     * @return `Set<Date>` - A set of Dates for future occurrences.
     */
    public Set<Date> calculateFutureOccurrences() {
        Set<Date> futureOccurrences = new Set<Date>();
        for (Datetime occurrence : delegateToFrequencySpecificCalculation()) {
            futureOccurrences.add(occurrence.date());
        }
        return futureOccurrences;
    }

    /**
     * @description Delegates the calculation of future occurrences to the appropriate method based on the frequency of the repeating rule.
     * @return Set<Datetime> a set of Datetime objects representing the future occurrences of the repeating rule.
     */
    private Set<Datetime> delegateToFrequencySpecificCalculation() {
        switch on frequency {
            when DAILY {
                return calculateDailyOccurrences();
            }
            when WEEKLY {
                return calculateWeeklyOccurrences();
            }
            when MONTHLY {
                return calculateMonthlyOccurrences();
            }
            when else {
                throw new IllegalArgumentException('Unsupported frequency: ' + frequency);
            }
        }
    }

    /**
     * @description responsible for calculating future occurrences of a daily repeating rule.
     * @return Set<Datetime> - a set of Datetime objects representing the future occurrences of the repeating rule.
     */
    private Set<Datetime> calculateDailyOccurrences() {
        if (repeatsUntilDate) {
            return calculateDailyOccurrencesUntil();
        }
        return calculateDailyOccurrencesCount();
    }

    /**
     * @description responsible for calculating future occurrences of a weekly repeating rule.
     * @return Set<Datetime> - a set of Datetime objects representing the future occurrences of the repeating rule.
     */
    private Set<Datetime> calculateWeeklyOccurrences() {
        if (repeatsUntilDate) {
            return calculateWeeklyOccurrencesUntil();
        }
        return calculateWeeklyOccurrencesCount();
    }

    /**
     * @description responsible for calculating future occurrences of a monthly repeating rule.
     * @return Set<Datetime> - a set of Datetime objects representing the future occurrences of the repeating rule.
     */
    private Set<Datetime> calculateMonthlyOccurrences() {
        if (repeatsUntilDate) {
            return calculateMonthlyOccurrencesUntil();
        }
        return calculateMonthlyOccurrencesCount();
    }

    /**
     * @description Responsible for determining whether or not a given occurrence should be added to the set of occurrences.
     * @param occurrence Datetime the occurrence to be evaluated.
     *
     * @return Boolean - true if the occurrence should be added, false if it should not.
     */
    private Boolean shouldAddOccurrence(Datetime occurrence) {
        return occurrence >= startDatetime &&
            occurrence.date() <= endDatetime &&
            !exclusionDates.contains(occurrence.date());
    }

    /**
     * @description calculates the daily occurrences of the repeating rule until the until date.
     * @return Set<Datetime> - a set of Datetime objects representing the future occurrences of the repeating rule.
     */
    private Set<Datetime> calculateDailyOccurrencesUntil() {
        Set<Datetime> occurrences = new Set<Datetime>();
        Date iterativeDate = startDatetime.date();
        loopUntilDate(iterativeDate, occurrences);
        return occurrences;
    }

    /**
     * @description calculates the daily occurrences of the repeating rule until the count is reached.
     * @return Set<Datetime> - a set of Datetime objects representing the future occurrences of the repeating rule.
     */
    private Set<Datetime> calculateDailyOccurrencesCount() {
        Set<Datetime> occurrences = new Set<Datetime>();
        Date iterativeDate = startDatetime.date();

        occurrences = loopUntilCount(iterativeDate, occurrences);
        return occurrences;
    }

    /**
     * @description calculates the weekly occurrences of the repeating rule until the until date.
     * @return Set<Datetime> - a set of Datetime objects representing the future occurrences of the repeating rule.
     */
    private Set<Datetime> calculateWeeklyOccurrencesUntil() {
        Set<Datetime> occurrences = new Set<Datetime>();
        Datetime iterativeDate = startDatetime;
        for (RFC5545DayOfWeek dayOfWeek : repeatOnDaysOfWeek) {
            while (toDayOfWeek(iterativeDate) != dayOfWeek) {
                iterativeDate = iterativeDate.addDays(1);
            }
            loopUntilDate(iterativeDate.date(), occurrences);
        }
        return occurrences;
    }

    /**
     * @description Calculates the weekly occurrences of the repeating rule until the count is reached.
     * @return Set<Datetime> - a set of Datetime objects representing the future occurrences of the repeating rule.
     */
    private Set<Datetime> calculateWeeklyOccurrencesCount() {
        Set<Datetime> occurrences = new Set<Datetime>();
        Date iterativeDate = startDatetime.date();
        for (RFC5545DayOfWeek dayOfWeek : repeatOnDaysOfWeek) {
            if (toDayOfWeek(iterativeDate) == dayOfWeek) {
                occurrences = loopUntilCount(iterativeDate, occurrences);
            } else {
                while ((toDayOfWeek(iterativeDate) != dayOfWeek)) {
                    iterativeDate = iterativeDate.addDays(1);
                }

                occurrences = loopUntilCount(iterativeDate, occurrences);
            }
        }

        return occurrences;
    }

    /**
     * @description calculates the monthly occurrences of the repeating rule until the until date.
     * @return Set<Datetime> - a set of Datetime objects representing the future occurrences of the repeating rule.
     */
    private Set<Datetime> calculateMonthlyOccurrencesUntil() {
        Set<Datetime> occurrences = new Set<Datetime>();

        if (relativeOccurrence != 0) {
            return calculateMonthlyOccurrencesWithXthDayOfWeekUntil();
        }

        if (this.byMonthDay != 0) {
            return calculateMonthlyOnDayUntil();
        }

        Integer iterationLoop = 0;
        for (RFC5545DayOfWeek dayOfWeek : repeatOnDaysOfWeek) {
            if (toDayOfWeek(startDatetime.date()) == dayOfWeek) {
                loopUntilDate(startDatetime.date(), occurrences);
            }
            iterationLoop++;
        }
        return occurrences;
    }

    private Set<Datetime> calculateMonthlyOnDayUntil() {
        Datetime iterativeDate = caclulateByMonthDateEffectiveDate(startDatetime);
        Set<Datetime> occurrences = new Set<Datetime>();
        while (iterativeDate <= this.until) {
            while (iterativeDate.day() != byMonthDay) {
                iterativeDate = iterativeDate.addDays(1);
            }
            Datetime potentialNewOccurrence = Datetime.newInstance(iterativeDate.date(), startTime);
            if (shouldAddOccurrence(potentialNewOccurrence) && potentialNewOccurrence.day() == byMonthDay) {
                occurrences.add(potentialNewOccurrence);
            }
            iterativeDate = iterativeDate.addMonths(interval);
        }
        return occurrences;
    }

    private Set<Datetime> calculateMonthlyOnDayCount() {
        Datetime iterativeDate = caclulateByMonthDateEffectiveDate(startDatetime);
        Set<Datetime> occurrences = new Set<Datetime>();
        // do we have a problem where the start date is <= today, but the byDate is in the future?
        for (Integer i = 0; i < count; i++) {
            while (iterativeDate.day() != byMonthDay) {
                iterativeDate = iterativeDate.addDays(1);
            }
            Datetime potentialNewOccurrence = Datetime.newInstance(iterativeDate.date(), startTime);

            if (shouldAddOccurrence(potentialNewOccurrence)) {
                occurrences.add(potentialNewOccurrence);
            }
            iterativeDate = iterativeDate.addMonths(interval);
        }
        return occurrences;
    }

    private Datetime caclulateByMonthDateEffectiveDate(Datetime iterativeDate) {
        if (this.startDatetime.date().day() <= this.byMonthDay) {
            return iterativeDate.addDays(this.byMonthDay - iterativeDate.date().day());
        }
        return iterativeDate;
    }

    /**
     * @description loops until the until date, adding occurrences to the occurrences set.
     * @param iterativeDate Date the date to start the loop from, and to mutate each iteration
     * @param occurrences Set<Datetime> the set of occurrences to add to.
     *
     * @return Set<Datetime> - a set of Datetime objects representing the future occurrences of the repeating rule.
     */
    private Set<Datetime> loopUntilDate(Date iterativeDate, Set<Datetime> occurrences) {
        while (iterativeDate <= until) {
            Datetime potentialNewOccurrence = Datetime.newInstance(iterativeDate, startTime);
            if (shouldAddOccurrence(potentialNewOccurrence)) {
                occurrences.add(potentialNewOccurrence);
            }
            iterativeDate = iterativeDate.addDays(effectiveIntervalInDays);
        }
        return occurrences;
    }

    /**
     * @description Similar to loopUntilDate, but loops until the count is reached.
     * @param iterativeDate Date the date to start the loop from, and to mutate each iteration
     * @param occurrences Set<Datetime> the set of occurrences to add to.
     *
     * @return Set<Datetime> - a set of Datetime objects representing the future occurrences of the repeating rule.
     */
    private Set<Datetime> loopUntilCount(Date iterativeDate, Set<Datetime> occurrences) {
        for (Integer counter = 0; counter <= count; counter++) {
            Datetime potentialNewOccurrence = Datetime.newInstance(iterativeDate, startTime);
            if (shouldAddOccurrence(potentialNewOccurrence)) {
                occurrences.add(potentialNewOccurrence);
            }
            iterativeDate = iterativeDate.addDays(effectiveIntervalInDays);
        }
        return occurrences;
    }

    /**
     * @description Calculates the monthly of a repeating rule until the count is reached.
     * @return Set<Datetime> - a set of Datetime objects representing the future occurrences of the repeating rule.
     */
    private Set<Datetime> calculateMonthlyOccurrencesCount() {
        Set<Datetime> occurrences = new Set<Datetime>();

        if (relativeOccurrence != 0) {
            return calculateMonthlyOccurrencesWithXthDayOfWeekCount();
        }

        if (this.byMonthDay != 0) {
            return calculateMonthlyOnDayCount();
        }

        Integer iterationLoop = 0;
        for (RFC5545DayOfWeek dayOfWeek : repeatOnDaysOfWeek) {
            if (toDayOfWeek(startDatetime.date()) == dayOfWeek) {
                loopUntilCount(startDatetime.date(), occurrences);
            }
            iterationLoop++;
        }
        return occurrences;
    }

    /**
     * @description Handles the calculation of monthly occurrences with a relative occurrence until the until date.
     * @return Set<Datetime> - a set of Datetime objects representing the future occurrences of the repeating rule.
     */
    private Set<Datetime> calculateMonthlyOccurrencesWithXthDayOfWeekUntil() {
        Set<Datetime> occurrences = new Set<Datetime>();
        Datetime iterativeOccurrence = findFirstOccurrenceOfADayOfWeekInMonth(this.startDatetime);
        //        occurrences.add(iterativeOccurrence);
        while (iterativeOccurrence < until) {
            occurrences.add(iterativeOccurrence);
            iterativeOccurrence = findFirstOccurrenceOfADayOfWeekInMonth(
                iterativeOccurrence.dateGmt().addMonths(interval).toStartOfMonth()
            );
        }
        return occurrences;
    }

    /**
     * @description calculates the monthly occurrences of the repeating rule with a relative occurrence until the count is reached.
     * @return Set<Datetime> - a set of Datetime objects representing the future occurrences of the repeating rule.
     */
    private Set<Datetime> calculateMonthlyOccurrencesWithXthDayOfWeekCount() {
        Set<Datetime> occurrences = new Set<Datetime>();
        Datetime firstOccurrence = findFirstOccurrenceOfADayOfWeekInMonth(this.startDatetime);
        occurrences.add(firstOccurrence);
        for (Integer occurrenceCount = 1; occurrenceCount < count; occurrenceCount++) {
            firstOccurrence = firstOccurrence.addMonths(occurrenceCount * interval);
            occurrences.add(findFirstOccurrenceOfADayOfWeekInMonth(firstOccurrence));
        }
        return occurrences;
    }

    /**
     * @description Determines the first occurrence of a day of the week in a month.
     * @return Datetime - the first occurrence of a day of the week in a month. Ie, the first Monday in a month.
     */
    private Datetime findFirstOccurrenceOfADayOfWeekInMonth(DateTime dateTimeToSearch) {
        Date lastDayOfTheStartDatesMonth = toEndOfMonth(dateTimeToSearch.date());
        RFC5545DayOfWeek targetDayOfWeek = repeatOnDaysOfWeek.iterator().next();

        for (Integer dayOffset = 1; dayOffset <= 7; dayOffset++) {
            Date checkDate = lastDayOfTheStartDatesMonth.addDays(dayOffset);
            if (toDayOfWeek(checkDate) == targetDayOfWeek) {
                if (relativeOccurrence >= 2) {
                    // we've found the correct day of the week, but not the correct week of the month. Correct by taking current check date, and adding the week offset - 1 * 7 days.
                    return Datetime.newInstance(checkDate.addDays((relativeOccurrence - 1) * 7), startTime);
                }
                //we've found the first occurrence of the day we want in the month we want, and it's the first of the month
                return Datetime.newInstance(checkDate, startTime);
            }
        }
        return null;
    }

    /** /////////// Inner Classes ///////////
     * @description Class is a handy datatype for returning pairs of objects from a method.
     * This is used to return key value pairs from the parseKeyValueString method.
     */
    public class Tuple {
        /**
         * @description the key of the pair
         */
        public final String key;
        /**
         * @description the value of the pair
         */
        public final String value;

        /**
         * @description constructor for the Tuple class.
         * @param key String the key Name of the pair
         * @param value String the value of the pair
         */
        public Tuple(String key, String value) {
            this.key = key;
            this.value = value;
        }
    }
}
