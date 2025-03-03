/**
 * @description vccConvertToUTC acts as date time transformer, and is used to convert a Timeslot date string in the Clinic's local time zone to UTC.
 * @returns {Date} - A Date object reflecting the converted date string in UTC. Example: 2024-10-09T14:00:00.000Z (EDT 4-hour conversion)
 * @param {string} dateString - A date string that is being converted to UTC. Example: '2024-10-09T10:00:00'
 * @param {string} timeZone - The time zone in IANA formatting. Example: 'America/New_York'
 * @author Booz Allen Hamilton
 */
export function convertToUTC(dateString, timeZone) {
    //Parse the input date string as a Date object.
    //Date String entering from vccScheduleAppointment.js is a properly formatted Date String due to it being formatted from a Date Object.
    const localDate = new Date(dateString);

    //Define formatting options to match the Clinic's time zone
    const options = {
        timeZone: timeZone,
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        hour12: false
    };

    //Create a formatter for the specified time zone using the options
    const formatter = new Intl.DateTimeFormat('en-US', options);

    //Format the local date to get a Date representation in the specified time zone
    const dateInTimeZone = new Date(formatter.format(localDate));

    //Calculate the offset milliseconds between the local date and the date adjusted to the specified time zone
    const timezoneOffset = localDate.getTime() - dateInTimeZone.getTime();

    //Adjust the original local date by the calculated offset to get the proper UTC date conversion.
    const utcDate = new Date(localDate.getTime() + timezoneOffset);

    return utcDate;
}
