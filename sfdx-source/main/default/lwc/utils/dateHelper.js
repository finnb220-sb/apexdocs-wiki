/**
 * @description Creates a date 25 years in the future
 * @returns a date 25 years in the future, like Mon Aug 12 2049 13:19:40 GMT-0400 (Eastern Daylight Time)
 */
export const getFarFutureDate = () => {
    return new Date(new Date().setFullYear(new Date().getFullYear() + 25));
};

export const NOT_INSTANCE_OF_DATE_ERROR_MESSAGE = 'Method asUtc accepts one argument of type Date';

/**
 * @description Takes the given Date in the running system timezone, and creates a new one from it as if it were UTC
 * @param {Date} date The Date whose values from the running system timezone that we want to pretend is UTC
 * @returns A new `Date` created from the given date
 */
export function asUtc(date) {
    if (!(date instanceof Date)) {
        throw new TypeError(NOT_INSTANCE_OF_DATE_ERROR_MESSAGE);
    }
    return new Date(
        Date.UTC(
            date.getFullYear(),
            date.getMonth(),
            date.getDate(),
            date.getHours(),
            date.getMinutes(),
            date.getSeconds(),
            date.getMilliseconds()
        )
    );
}
