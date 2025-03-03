export const DASH_SEPARATOR = '-';
export const SLASH_SEPARATOR = '/';
export const LETTER_T = 'T';
export const PM = 'PM';
export const AM = 'AM';
export const COLON_SEPARATOR = ':';
export const ZERO_TIME_STRING = '00:00:00.000Z';
export const COMMA_SEPARATOR = ',';
const SPACE_SEPARATOR = ' ';
const FORMATTING_OPTION_NUMERIC = 'numeric';
const TIMEZONE_UTC = 'UTC';

export const DATE = 'date';
export const DATE_LOCAL = 'date-local';
/**
 * @description A list of datatable column types that should be formatted as a date.
 * - Used to determine if a column should be formatted as a date.
 * - SF documentation: https://developer.salesforce.com/docs/component-library/bundle/lightning-datatable/documentation#:~:text=to%202.-,Displaying%20Date%20and%20Time%20Using%20Type%20Attributes,-The%20locale%20set
 * @type {String[]}
 */
export const DATATABLE_DATE_TYPES = [DATE, DATE_LOCAL];

/**
 * @description A reusable config object for "date" or "date-local" datatable columns, or for lightning-formatted-date-time components.
 * - Can be used across the code base to format dates in a consistent manner
 * - Will NOT include time info.
 * - example usages:
 *   - In a datatable DATE column:
 *     - `{
 *         label: 'My Date',
 *         fieldName: 'myDate',
 *         type: 'date',
 *         sortable: true,
 *         typeAttributes: dateFormatter.LIGHTNING_FORMATTED_DATE_OPTIONS
 *     }`
 *   - For a lightning-formatted-date-time component:
 *     - JS:
 *       - `import { dateFormatter } from 'c/utils'`
 *       - `...`
 *       - `get dateOptions(){ return dateFormatter.LIGHTNING_FORMATTED_DATE_OPTIONS; }`
 *     - HTML:
 *       - `<lightning-formatted-date-time value={selectedRecord.someDate} lwc:spread={dateOptions}></lightning-formatted-date-time>`
 * @type {{year: string, month: string, day: string, timeZone: string}}
 */
export const LIGHTNING_FORMATTED_DATE_OPTIONS = {
    year: FORMATTING_OPTION_NUMERIC,
    month: FORMATTING_OPTION_NUMERIC,
    day: FORMATTING_OPTION_NUMERIC,
    timeZone: TIMEZONE_UTC
};

/**
 * @description A reusable config object for "date" or "date-local" datatable columns.
 * - Can also be passed to lwc:spread argument for a lightning-formatted-date-time component
 * - Will include time info.
 * - example usages:
 *   - datatable DATETIME column:
 *     - `{
 *         label: 'My Date',
 *         fieldName: 'myDate',
 *         type: 'date',
 *         sortable: true,
 *         typeAttributes: dateFormatter.LIGHTNING_FORMATTED_DATE_TIME_OPTIONS
 *     }`
 *   - For a lightning-formatted-date-time component:
 *     - JS:
 *       - `import { dateFormatter } from 'c/utils'`
 *       - `...`
 *       - `get dateTimeOptions(){ return dateFormatter.LIGHTNING_FORMATTED_DATE_TIME_OPTIONS; }`
 *     - HTML:
 *       - `<lightning-formatted-date-time value={selectedRecord.someDate} lwc:spread={dateTimeOptions}></lightning-formatted-date-time>`
 * @type {{year: string, month: string, day: string, timeZone: string, hour: string, minute: string}}
 */
export const LIGHTNING_FORMATTED_DATE_TIME_OPTIONS = {
    ...LIGHTNING_FORMATTED_DATE_OPTIONS,
    hour: FORMATTING_OPTION_NUMERIC,
    minute: FORMATTING_OPTION_NUMERIC
};

/**
 * @description Takes new Date(); and Salesforce User's Timezone, and formats it into a string. Example below.
                This prevents timezone issues if device and SF user have different zones.
                Before: Mon Aug 12 2024 13:19:40 GMT-0400 (Eastern Daylight Time)
                After:  "8/12/2024"
 * @param {*} toFormat
 * @param {*} userTimeZone 
 * @returns a formatted date with the following appearance: "8/12/2024"
 */
export const toEN_USShortDate = (toFormat, userTimeZone) => {
    return toFormat.toLocaleString('en-US', { timeZone: userTimeZone }).split(COMMA_SEPARATOR)[0];
};

/**
 * @description Replaces Slashes with Dashes
                Before: "8/12/2024"
                After:  "2024-8-12"
 * @param {*} toFormat 
 * @returns a formatted date string with the following appearance: "2024-8-12"
 */
export const en_UStoYyyyMMDD = (toFormat) => {
    return (
        toFormat.split(SLASH_SEPARATOR)[2] +
        DASH_SEPARATOR +
        toFormat.split(SLASH_SEPARATOR)[0] +
        DASH_SEPARATOR +
        toFormat.split(SLASH_SEPARATOR)[1]
    );
};

/**
 * @description Replaces Dashes with Slashes
 *              Before:  "2024-8-12"
 *              After:   "8/12/2024"
 * @param {*} toFormat
 * @returns a formatted date string with the following appearance: "2024-8-12"
 */
export const YYYYMMDDWithDashesToMMDDYYYYWithSlashes = (toFormat) => {
    if (toFormat === null) {
        return '';
    }
    return (
        removeLeadingZeros(toFormat.split(DASH_SEPARATOR)[1]) +
        SLASH_SEPARATOR +
        removeLeadingZeros(toFormat.split(DASH_SEPARATOR)[2]) +
        SLASH_SEPARATOR +
        toFormat.split(DASH_SEPARATOR)[0]
    );
};

/**
 * @description Formats DateTime to Date string
                Before: Mon Aug 12 2024 13:19:40 GMT-0400 (Eastern Daylight Time)
                After: "2024-8-12"
 * @param {*} toFormat 
 * @returns a formatted date string with the following appearance: "2024-8-12"
 */
export const newDatetoYyyyMMDD = (toFormat) => {
    if (toFormat === null) {
        return '';
    }
    return new Date(toFormat).toISOString().split(LETTER_T)[0];
};

/**
 * @description Formats a string in the Salesforce DateTime format to a string with the format M/d/yyyy h:mm AM/PM
 * - Before: "2024-08-25T19:25:56.000+0000 (Eastern Daylight Time)"
 * - After: "8/25/2024 7:25 PM"
 * - Note that leading zeros are removed from the hour, month, and day (requirement).
 *   - For example: April 7th, 2025 at 03:25 PM  =(should display as)=>  4/7/2025, 3:25 PM
 * - If time data is not present, or is equal to "00:00:00.000Z", the time will be omitted from the formatted result
 *   - e.g. "2024-01-01" yields "1/1/2024" (NOT "1/1/2024 12:00 AM")
 * @param {String} dateTimeStringToFormat
 * @return a formatted date string with the following appearance: "8/25/2024", or a formatted datetime string e.g. "8/1/2024, 1:01 PM"
 */
export const salesForceDateTimeStringToMMDDYYYYHHMM = (dateTimeStringToFormat) => {
    if (!dateTimeStringToFormat) {
        return '';
    }
    const pieces = [
        formatDateTimeStringToMMDDYYYY(dateTimeStringToFormat),
        formatDateTimeToHHMMAmPm(dateTimeStringToFormat)
    ];
    return pieces.filter((piece) => !!piece).join(COMMA_SEPARATOR + SPACE_SEPARATOR);
};

/**
 * @description Formats a string from the Salesforce DateTime format to a string containing just a DATE with the format M/d/yyyy
                Before: "2024-10-25T19:25:56.000+0000 (Eastern Daylight Time)"
                After: "10/25/2024"
 * @param {*} dateTimeStringToFormat this parameter will never be null/empty, as the invoking method handles this
 * @returns a formatted date string with the following appearance: "10/25/2024"
 */
export function formatDateTimeStringToMMDDYYYY(dateTimeStringToFormat) {
    if (!dateTimeStringToFormat) {
        return '';
    }
    try {
        let date = dateTimeStringToFormat.split(LETTER_T)[0];
        let year = date.split(DASH_SEPARATOR)[0];
        let month = removeLeadingZeros(date.split(DASH_SEPARATOR)[1]);
        let day = removeLeadingZeros(date.split(DASH_SEPARATOR)[2]);
        date = month + SLASH_SEPARATOR + day + SLASH_SEPARATOR + year;
        return date;
    } catch (ex) {
        //gracefully abort if we're trying to parse anything other than an ISO date string.
        return dateTimeStringToFormat;
    }
}

/**
 * @description Removes leading zeros from a string
                Before: "07"
                After: "7"
 * @param {*} str this parameter will never be null/empty, as the invoking method handles this
 * @returns a formatted time string with the following appearance: "7:25 pm"
 */
function removeLeadingZeros(str) {
    return str.replace(/^0+/, '');
}

/**
 * @description Formats a string from the Salesforce DateTime format to a string containing just a TIME with the format h:mm am/pm
                Before: "2024-10-25T19:25:56.000+0000 (Eastern Daylight Time)"
                After: "7:25 pm"
 * @param {*} dateTimeStringToFormat this parameter will never be null/empty, as the invoking method handles this
 * @returns a formatted time string with the following appearance: "7:25 pm"
 */
function formatDateTimeToHHMMAmPm(dateTimeStringToFormat) {
    if (
        !dateTimeStringToFormat ||
        dateTimeStringToFormat.length < 11 ||
        dateTimeStringToFormat.substring(11) === ZERO_TIME_STRING
    ) {
        return '';
    }
    const time24 = dateTimeStringToFormat.substring(11, 16);
    const [hours, minutes] = time24.split(COLON_SEPARATOR);
    const period = hours >= 12 ? PM : AM;
    const hours12 = (hours % 12 || 12).toString();
    return ` ${hours12}:${minutes} ${period}`;
}

/**
 * @Description Formats a string from 'YYYYMMDD' to 'MM/DD/YYYY'. For example
 *              '20240125' => '1/25/2024'
 * @param {String} dateString - an 8-digit date string in the form of YYYYMMDD (no dashes or slashes)
 * @return a formatted date string with the following appearance: '8/25/2024'
 */
export function formatYYYYMMDDDateToMMDDYYYY(dateString) {
    if (!dateString) {
        return '';
    }
    const year = dateString.substring(0, 4);
    const month = dateString.substring(4, 6) - 1; // Zero-indexed month
    const day = dateString.substring(6, 8);

    const dateFormatted = new Date(year, month, day);
    const formattedDate = `${dateFormatted.getMonth() + 1}/${dateFormatted.getDate()}/${dateFormatted.getFullYear()}`;

    return formattedDate;
}
