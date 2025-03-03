/**
 * @description Formats the current date-time or a given ISO date string based on The Clinic's specified time zone.
 * @param {string} clinicTimeZoneValue - The time zone to format the date-time.
 * @param {string} isoDateString - ISO 8601 date string provided from a Clinic's Timeslot.
 * If isoDateString is not provided, the current date-time is used to calculate Today's Date in the Clinic's Timezone.
 * @returns {Date} - A Date object reflecting the formatted date-time.
 */
import { getTimezoneValue } from 'c/vccVistaTimeZoneHelper';
export function clinicTimezoneDateSetter(clinicTimeZone, isoDateString) {
    const dateToFormat = isoDateString ? new Date(isoDateString) : new Date();
    // Define formatting options
    const options = {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        hour12: false
    };
    //IANA (Internet Assigned Numbers Authority) holds the timezone database for the naming convention for Timezone ids.
    let ianaTimezone = getTimezoneValue(clinicTimeZone) || 'UTC';
    options.timeZone = ianaTimezone;

    const formatter = new Intl.DateTimeFormat('en-US', options);
    const parts = formatter.formatToParts(dateToFormat);

    const year = parts.find((part) => part.type === 'year').value;
    const month = parts.find((part) => part.type === 'month').value;
    const day = parts.find((part) => part.type === 'day').value;
    const hour = parts.find((part) => part.type === 'hour').value;
    const minute = parts.find((part) => part.type === 'minute').value;
    const second = parts.find((part) => part.type === 'second').value;

    const formattedDateString = `${year}-${month}-${day}T${hour}:${minute}:${second}`;
    const clinicDate = new Date(formattedDateString);

    return {
        clinicDate: clinicDate,
        timeZone: ianaTimezone
    };
}
