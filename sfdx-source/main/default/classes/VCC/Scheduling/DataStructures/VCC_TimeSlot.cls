/**
 * @description Class for storing potential time slots for a given Service Territory member.
 * Used in calculating Virtual Clinic Visit Appointment Utilization
 * Extends VCC_DateRange so that it can override built in CompareTo for custom sorting Equals and HashCode for overriding built in comparisons so that it can be used in Sets and Maps.
 * @see VCV_TimeSlotCollection
 * @see VCC_AppointmentUtilizationService
 * @see VCC_RepeatingRule
 * @see VCC_DateRange
 *
 */
public inherited sharing class VCC_TimeSlot extends VCC_DateRange implements Comparable {
    /**
     * @description Constructor that calls the superclasses constructor to set internal fields.
     * @param startDateTime `DateTime` Start of the given time slot.
     * @param endDateTime `DateTime` End of the given Time slot.
     */
    public VCC_TimeSlot(DateTime startDateTime, DateTime endDateTime) {
        super(startDateTime, endDateTime);
    }

    /**
     * @description Constructor that calls the superclasses constructor to set internal fields.
     * @param startDate `Date` Start of the given time slot defaults to midnight.
     * @param endDate `Date` End of the given Time slot defaults to midnight.
     */
    public VCC_TimeSlot(Date startDate, Date endDate) {
        super(startDate, endDate);
    }

    /**
     * @description compareTo function that gets called when sorting lists. Default sort order is StartDateTime asc.
     * @param compareTo `Object` Object to be compared to.
     * @return `Integer` Returns 0 if the objects are the same.
     * Returns -1 if the StartDateTime is before the compared objects.
     * Returns 1 if the StartDateTime is after the compared objects.
     */
    public Integer compareTo(Object compareTo) {
        VCC_TimeSlot timeSlotToCompareTo = (VCC_TimeSlot) compareTo;
        if (this.startDateTime == timeSlotToCompareTo.startDateTime) {
            return 0;
        } else if (this.startDateTime > timeSlotToCompareTo.startDateTime) {
            return 1;
        }
        return -1;
    }

    /**
     * @description Definition of the equals method so we can compare this object based on just the startDateTime and the endDateTime
     * @param comparedObj Object we are comparing to.
     * @return `Boolean` returns true or false based on whether the startDateTime and the endDateTime are the same.
     */
    public Boolean equals(Object comparedObj) {
        if (!(comparedObj instanceof VCC_TimeSlot)) {
            return false;
        }
        VCC_TimeSlot comparedTimeSlot = (VCC_TimeSlot) comparedObj;

        return (startDateTime == comparedTimeSlot.startDateTime && endDateTime == comparedTimeSlot.endDateTime);
    }

    /**
     * @description To utilize this object in Hash based collections, Maps, Sets we must define a hash function.
     * This function adds the HashCodes of the field on the object, then multiplies it by the Prime number 31.
     * 31 is chosen because it is an odd prime that will not overflow on multiplication
     * and it is easily calculated by shifting, making it easy for the compiler to optimize
     * the multiplication.
     * @return Integer Hashcode representation of this object.
     */
    public Integer hashCode() {
        return (this.startDateTime.hashCode() + this.endDateTime.hashCode()) * 31;
    }
}
