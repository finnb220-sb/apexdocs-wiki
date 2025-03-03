/**
 * @description Basic virtual Date range object. Can be extended.
 * @see VCC_TimeSlot
 */
public inherited sharing virtual class VCC_DateRange {
    public DateTime startDateTime;
    public DateTime endDateTime;

    @TestVisible
    private static final String INVALID_START_END_DATE_MSG = 'Cannot have an endDateTime that starts before the startDateTime!';

    @TestVisible
    private static final String NULL_ARG_MSG = 'Null dateTime passed to constructor';

    /**
     * @description Constructor for the VCC_DateRange Object. Sets the internal startDateTime
     * and endDateTime properties.
     * @param startDateTime `DateTime` startDateTime for the range.
     * @param endDateTime `DateTime` endDateTime for the range.
     * @throws `InvalidDateRangeException` When the endDateTime passed in is before the startDateTime.
     */
    public VCC_DateRange(DateTime startDateTime, DateTime endDateTime) {
        if (startDateTime == null || endDateTime == null) {
            throw new InvalidDateRangeException(NULL_ARG_MSG);
        }
        if (endDateTime < startDateTime) {
            throw new InvalidDateRangeException(
                INVALID_START_END_DATE_MSG + ' startDateTime : ' + startDateTime + ' EndDateTime: ' + endDateTime
            );
        }

        this.startDateTime = startDateTime;
        this.endDateTime = endDateTime;
    }

    /**
     * @description Overloading of VCC_DateRange Object Constructor. Sets the internal startDateTime
     * and endDateTime properties calling other constructor after creating Datetime instances.
     * NOTE: To ensure correct behavior regardless of user's TimeZone, creating instance in GMT.
     *
     * @param startDate `Date` Start Date for the range - sets Time to midnight on startDate.
     * @param endDate `Date` end Date for the range - sets Time to midnight on endDate.
     * @throws `InvalidDateRangeException` When the endDate passed in is before the startDate.
     */
    public VCC_DateRange(Date startDate, Date endDate) {
        this(
            Datetime.newInstance(startDate, Time.newInstance(0, 0, 0, 0)),
            Datetime.newInstance(endDate, Time.newInstance(0, 0, 0, 0))
        );
    }

    /**
     * @description Used for calculating total time elapsed in a date range.
     * @return `Long` returns total time in this given date range in milliseconds.
     */
    public Long getTimeInRange() {
        return this.endDateTime.getTime() - this.startDateTime.getTime();
    }

    /**
     * @description Used to determine if the current date range is inside of another DateRange
     * @param comparedRange `VCC_DateRange` VCC_DateRange object to compare to.
     * @return `Boolean` Returns true if this DateRange exists inside of the passed in Date Range.
     * This is inclusive of the edges.
     */
    public Boolean existsInsideOf(VCC_DateRange comparedRange) {
        //Example:
        //Given the date ranges of ...
        // Feb 1, 9:00 am => Feb 1, 5:00 PM (this instance)
        // Feb 1, 9:00 am => Feb 3rd, 12:00am (comparedRange)
        return this.startDateTime >=
            comparedRange.startDateTime && //9:00 am Feb 1  = 9 am feb 1
            this.startDateTime <= comparedRange.endDateTime && //9:15 am Feb 1 < Feb 3 12 am
            this.endDateTime <= comparedRange.endDateTime && //5 pm Feb 1 < 12 am Feb 3
            this.endDateTime >= comparedRange.startDateTime; //5 pm Feb 1 > 9 am Feb 1
        //then this time slot is completely inside the compared time slot.
    }

    /**
     * @description Used to determine if two VCC_DateRanges overlap each other.
     * @param comparedRange `VCC_DateRange` Time slot to compare to.
     * @return `Boolean` returns true if the current Date Range and compareDateRange overlap.
     */
    public Boolean isOverlapping(VCC_DateRange comparedRange) {
        //(StartA <= EndB)  and  (EndA >= StartB)
        //Example:
        //Given the date ranges of ...
        // Feb 1, 9:15 am => Feb 1, 5:00 PM (this instance)
        // Feb 1, 9:00 am => Feb 3rd, 12:00am (comparedRange)
        // Feb 1 9:00 am <= Feb 3rd, 12:00am
        // Feb 1 5:00 pm >= Feb 1, 9:00 am
        //Then these two time slots are overlapping
        return this.startDateTime <= comparedRange.endDateTime && this.endDateTime >= comparedRange.startDateTime;
    }

    /**
     * @description Exception thrown when an illogical date range is passed in.
     * Ignoring class naming conventions as this is an inner class, and does not need a prefix.
     */
    @SuppressWarnings('PMD.ClassNamingConventions')
    public class InvalidDateRangeException extends Exception {
    }
}
