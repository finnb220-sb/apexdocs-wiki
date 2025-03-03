/* eslint no-console: ["error", { allow: ["warn", "error"] }] */
/* eslint-disable consistent-return */

import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// return parsed objects from proxyObject input
//
// eslint-disable-next-line consistent-return
export const proxyTool = (obj) => {
    if (typeof obj === 'object') return JSON.parse(JSON.stringify(obj));
};

export const getMPIRootElement = (json) => {
    let root = null;

    if (typeof json == 'string') {
        let list = Object.values(JSON.parse(json)).filter((data) => data != null);

        if (list.length === 1) {
            root = list[0][0];
        }

        return root;
    }
    console.error(`${json} is not a stringified object`);

    return root;
};

/**
 * @description Takes in a list of objects and checks for unique records based on a property
 * @param {*} list List of objects to iterate through
 * @param {*} uniqueProperty Unique property that list should filter against
 * @returns {Array<object>}
 */

// eslint-disable-next-line consistent-return
export const uniqueVals = (list, uniqueProperty) => {
    const result = [];
    if (list?.length) {
        const map = new Map();
        for (const item of list) {
            if (item && !map.has(item[uniqueProperty])) {
                map.set(item[uniqueProperty], true);
                result.push({
                    ...item
                });
            }
        }
    }
    return result;
};

/**
 * @description Capitalize first character and undercase the rest on a string
 * @param {string}
 * @returns {string}
 */

export const properCase = (string) => {
    if (typeof string !== 'string') {
        return '';
    }
    return string.charAt(0).toUpperCase() + string.slice(1).toLowerCase();
};

export const upperCase = (string) => {
    if (typeof string !== 'string') {
        return '';
    }
    return string.charAt(0).toUpperCase() + string.slice(1).toUpperCase();
};

export const lowerCase = (string) => {
    if (typeof string !== 'string') {
        return '';
    }
    return string.slice(0).toLowerCase();
};

export const daysBetween = (firstDate, secondDate) => {
    return Math.ceil(Math.abs(secondDate - firstDate) / (1000 * 60 * 60 * 24)) - 1;
};
/**
 * Generates a unique id by getting the current time appended to a randomly generated MAX int.
 */
export const uniqueId = () => {
    return Date.now() + '::' + Math.floor(Math.random() * Number.MAX_SAFE_INTEGER);
};

/**
 * @param {Array} arr array to enumerate
 * @param {*} enumProperty property to enumerate by
 * @returns {Object} Javascript object with each property being an array based on incoming property parameter
 */
export const groupBy = (arr, enumProperty) => {
    return arr.reduce(function (item, prop) {
        if (!item[prop[enumProperty]]) {
            item[prop[enumProperty]] = [];
        }
        item[prop[enumProperty]].push(prop);
        return item;
    }, {});
};

/**
 *
 * @param {dateTimeValue} Number from data like 3041029.0026 where 304 is years since 1970
 * @returns {String} converted 3041029.0026 time to standard JS time format (ex: Fri Oct 29 2004 00:26:00 GMT-0500 (Central Daylight Time))
 */

export const getJsDateFromDateTime = (dateTimeValue) => {
    //? calculating to handle dateTimes without 4 digits after the decimal
    //? ex: 3041207.1050 comes in as 3041207.105 and needs to be 4 digits so it will convert to the date properly
    let dateTimeString = (dateTimeValue * 10000).toFixed() + '';
    let year = parseInt(dateTimeString.substring(0, 3), 10) + 1700;
    let month = parseInt(dateTimeString.substring(3, 5), 10) - 1;
    let day = dateTimeString.substring(5, 7);
    let hours = dateTimeString.substring(7, 9);
    let minutes = dateTimeString.substring(9, 11);
    return new Date(year, month, day, hours, minutes);
};

/**
 *
 * @param {jsDate} String converted 3041029.0026 time to standard JS time format
 * @returns {String} time that is ready to be displayed on UI
 */

export const dateToDateTime = (jsDate) => {
    let options = {
        hourCycle: 'h23',
        hour: '2-digit',
        minute: '2-digit',
        month: '2-digit',
        day: '2-digit',
        year: 'numeric'
    };
    return jsDate.toLocaleString('en-US', options);
};

/**
 * Specifically made this for searching through datatables.
 * It will only search through the columns specified.
 *
 * @param {*} searchString string to look for
 * @param {*} columns datatable columns to search
 * @param {*} array the array being searched
 * @param {*} forEachMatch function passed to handle each match
 */
export const search = (searchString, columns, array, forEachMatch) => {
    if (Array.isArray(array) && Array.isArray(columns) && typeof forEachMatch === 'function') {
        for (let e of array) {
            for (let col of columns) {
                if (
                    typeof e[col.fieldName] === 'string' &&
                    e[col.fieldName].toLowerCase().indexOf(searchString.toLowerCase()) !== -1
                ) {
                    forEachMatch(e);
                    break;
                }
            }
        }
    }
};

/**
 * Compare function to be used in Array.sort()
 *
 * @param {*} a
 * @param {*} b
 * @returns 1, 0, or -1. see JavaScript documentation for Array.sort() for details.
 */
export const compare = (a, b) => {
    let aString = String(a).trim();
    let bString = String(b).trim();

    if (aString === '' || aString === 'null' || aString === 'undefined') {
        if (bString === '' || bString === 'null' || bString === 'undefined') {
            return 0;
        }
        return 1;
    } else if (bString === '' || bString === 'null' || bString === 'undefined') {
        return -1;
    }
    if ((aString === 'true' || aString === 'false') && (bString === 'true' || bString === 'false')) {
        if (aString === bString) {
            return 0;
        } else if (aString === 'true' && bString === 'false') {
            return -1;
        }
        return 1;
    }

    return a === b ? 0 : a > b ? 1 : -1;
};

/** returns a javascript object with different formats of date for display in HTML */
export const formatDateHDR = (dateString) => {
    const time = dateString.split('.')[1] || null;
    const dateObject = {
        year: 1700 + parseInt(dateString.substring(0, 3), 10),
        month: parseInt(dateString.substring(3, 5), 10),
        day: dateString.substring(5, 7),
        hour: time % 24,
        minute: time % 60,
        time: null,
        fullDate: null,
        timeZone: null,
        timeMilliSeconds: null,
        isoDate: null
    };

    dateObject.fullDate = new Date(
        dateObject.year,
        dateObject.month - 1,
        dateObject.day,
        dateObject.hour,
        dateObject.minute
    );
    dateObject.timeZone = dateObject.fullDate
        .toTimeString()
        .substring(
            dateObject.fullDate.toTimeString().indexOf('(') + 1,
            dateObject.fullDate.toTimeString().lastIndexOf(')')
        );
    dateObject.time = dateObject.fullDate.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });
    dateObject.timeMilliSeconds = dateObject.fullDate.getTime();
    dateObject.date = dateObject.fullDate.toDateString();
    dateObject.isoDate = dateObject.fullDate.toISOString().split('T')[0];
    dateObject.isoString = dateObject.fullDate.toISOString();
    dateObject.dateTimeString = `${dateObject.fullDate.toDateString()} ${dateObject.time}`;
    return dateObject;
};

/**
 * breaking up large list into sublists for pagination
 *
 * @param {*} arr array to cut up
 * @param {*} size size of units to cut array by
 * @returns
 */

export const chunk = (arr, size) => {
    let result = [];

    while (arr.length) {
        result.push(arr.splice(0, size));
    }

    return result;
};

export const flattenObject = ({ ...obj }, extractMultiples) => {
    const preFormatted = { ...obj };

    Object.keys(obj).forEach((property) => {
        if (
            obj[property] &&
            typeof obj[property] === 'object' &&
            Object.prototype.hasOwnProperty.call(obj[property], extractMultiples)
        ) {
            Object.keys(obj[property]).forEach((innerProp) => {
                if (innerProp === extractMultiples) {
                    obj[property][property] = obj[property][innerProp];
                }
            });
        }
    });

    const flattened = {};

    Object.keys(obj).forEach((key) => {
        const value = obj[key];

        if (typeof value === 'object' && value !== null && !Array.isArray(value)) {
            Object.assign(flattened, flattenObject(value));
        } else {
            flattened[key] = value;
        }
    });

    flattened.preFormatted = preFormatted;

    delete flattened[extractMultiples];

    return flattened;
};

/**
 *  // need this function to be an arrow so "this" can be inherited without binding, this method also modifies an object by reference so it doesn't return anything
 * @param list
 * @param property
 * @param direction
 * @returns {*}
 */

// eslint-disable-next-line consistent-return
export const sortFlatList = (list, property, direction) => {
    const { propertyName, type } = property;

    // eslint-disable-next-line default-case
    switch (type) {
        case 'text':
            return list.sort((a, b) => {
                a = a[propertyName]?.toLowerCase() || '';
                b = b[propertyName]?.toLowerCase() || '';

                if (direction === 'asc') {
                    return a > b ? 1 : -1;
                }
                return b > a ? 1 : -1;
            });

        case 'caseSensitive':
            return list.sort((a, b) => {
                if (direction === 'asc') {
                    return (a[propertyName] ? a[propertyName] : '') > (b[propertyName] ? b[propertyName] : '') ? 1 : -1;
                }
                return (b[propertyName] ? b[propertyName] : '') > (a[propertyName] ? a[propertyName] : '') ? 1 : -1;
            });

        case 'date':
            return list.sort((a, b) => {
                a = Date.parse(a[propertyName]) || 0;
                b = Date.parse(b[propertyName]) || 0;

                if (direction === 'asc') {
                    return a - b;
                }
                return b - a;
            });

        case 'number':
            return list.sort((a, b) => {
                a = parseFloat(a[propertyName]) || 0;
                b = parseFloat(b[propertyName]) || 0;

                if (direction === 'asc') {
                    return a - b;
                }
                return b - a;
            });
        case 'groupByType':
        // TODO: Sort data 'excel style'
    }
};

export const searchFlatList = (list, searchString, property) => {
    searchString =
        searchString
            ?.toLowerCase()
            .replace(/(\r\n|\n|\r)/gm, '')
            .replace(/\s/g, '') || '';
    let content = null;

    if (list?.length) {
        return list.filter((item) => {
            if (item[property]) {
                content =
                    item[property]
                        .toLowerCase()
                        .replace(/(\r\n|\n|\r)/gm, '')
                        .replace(/\s/g, '') || '';
                return content.includes(searchString);
            }
            return false;
        });
    }
    return list;
};

// eslint-disable-next-line consistent-return
export const filterListByDate = (list, date, config) => {
    const { propertyName, direction } = config;

    return list.filter((item) => {
        if (direction === 'start') {
            return Date.parse(item[propertyName]) > Date.parse(date);
        }
        return Date.parse(item[propertyName]) < Date.parse(date);
    });
};

/** get an array of objects between two dates, includes start and end date */
export const betweenTwoDates = ({ start, end, list, field }) => {
    let returnList = [];
    try {
        let endDateAdjusted = Date.parse(end) + 3600 * 1000 * 24; // adds full day to make the filter inclusive when comparing datetimes and dates
        if (start && end) {
            return list.filter(
                (item) =>
                    Date.parse(item[field] || 0) >= Date.parse(start) && Date.parse(item[field] || 0) < endDateAdjusted
            );
        }

        if (start) {
            returnList = list.filter((item) => Date.parse(item[field] || 0) >= Date.parse(start));
        } else {
            returnList = list.filter((item) => Date.parse(item[field] || 0) < endDateAdjusted);
        }

        return returnList.filter((entry) => !!entry[field]); // check if object has field we're filtering against
    } catch (err) {
        console.error(err);
    }
};

export const getToday = () => {
    return {
        iso: new Date().toLocaleDateString('sv', { timeZoneName: 'short' }).substring(0, 10),
        en: new Date().toLocaleDateString('en-US')
    };
};
/**
 * @description Decorator Function that logs in ms a function's execution time
 * @param {Function to Performance Log} fn
 * @returns Invocation of passed in function
 */
// eslint-disable-next-line consistent-return
export const performanceLogDecorator = (fn) => {
    /* eslint-disable no-unused-vars */
    return function (...args) {
        let start, end;
        start = performance.now();
        let val = fn(...args);
        end = performance.now();
        //
        return val;
    };
    /* eslint-enable no-unused-vars */
};

/**
 * @description Function that takes in a date in iso format and returns a screen-reader friendly date string
 * @param {string} isoDateWithoutTime date in iso format
 * @returns {string} Screen-reader friendly date string
 */

export const screenReaderFriendlyDate = (isoDateWithoutTime) => {
    try {
        const [year, month, day] = isoDateWithoutTime.split('-');
        return new Date(year, month - 1, day).toDateString();
    } catch (error) {
        console.error(error);
    }
};

//? used as helper function for inBothArrays method
const operation = (list1, list2, property, isUnion = false) =>
    list1.filter((a) => isUnion === list2.some((b) => a[property] === b[property]));

/**
 * @description Function that takes in 2 array of objects then checks based on
 * @param {array} list1 array of objects
 * @param {array} list2 array of objects
 * @returns {string} property used to match
 */

export const inBothArrays = (list1, list2, property) => operation(list1, list2, property, true);
/**
 * @description Uses Mixin library to create a SF url based on an incoming record ID
 * @param {object} reference the template of the component calling this method, the "this" keyword when inside of an LWC class
 * @param {string} recordId id of record you wish to generate a url for
 * @returns
 */
export const generateRecordUrl = (reference, recordId) => {
    return reference[NavigationMixin.GenerateUrl]({
        type: 'standard__recordPage',
        attributes: {
            recordId: recordId,
            actionName: 'view'
        }
    });
};

export const areArraysEqual = (arr1, arr2) => {
    if (arr1.length !== arr2.length) {
        return false;
    }

    return arr1.every((element, index) => element === arr2[index]);
};
// eslint-disable-next-line consistent-return
export const shallowCompare = (obj1, obj2) => {
    obj1.sort();
    obj2.sort();

    if (!Object.keys(obj1).length === Object.keys(obj2).length) {
        return false;
    }

    return (
        areArraysEqual(Object.keys(obj1), Object.keys(obj2)) && areArraysEqual(Object.values(obj1), Object.values(obj2))
    );
};

/**
 * @description Organizes med metadata such as facility of a med
 * @returns metadata of a list of meds
 */

export const identifyAllFacilitiesInMedList = (meds) => {
    try {
        return groupBy(
            uniqueVals(
                meds.map((med) => {
                    return {
                        id: med?.fullData?.facility?.code,
                        name: med?.fullData?.facility?.name,
                        concat: `${med?.fullData?.facility?.code}-${med?.fullData?.facility?.name}`
                    };
                }),
                'concat'
            ),
            'id'
        );
    } catch (error) {
        console.error(error);
    }
};

/**
 * @description Returns an ISO formatted date string based on the workstream duration
 * @param workstreamDuration Integer that determines in months how far back an API call to DIP/VTC/VDIF/DAS should go
 * @returns {string} ISO formatted date string
 *
 */
export const setDateParamsPerWorkstreamDuration = (workstreamDuration) => {
    return new Date(new Date().setMonth(new Date().getMonth() - workstreamDuration)).toISOString().split('T')[0];
};

/**
 * @description displays a toast message to the user
 * @param {object} context the context in which your toast popup should display (usually pass in 'this')
 * @param {string} title the title of the toast popup
 * @param {string} message the message of the toast popup
 * @param {string} variant the variant of the toast popup (error/warning/success/info) - default is 'info'
 * @param {string} mode the mode of the toast popup (dismissible/pester/sticky) - default is 'dismissible'
 */
export const showToast = (context, title, message, variant = 'info', mode = 'dismissible') => {
    context.dispatchEvent(
        new ShowToastEvent({
            message: message,
            title: title,
            variant: variant,
            mode: mode
        })
    );
};

/**
 * @description formats date/time to display in the format MM/DD/YYYY, HH:MM AM/PM
 * @param {string} dateString YYYY-MM-DDTHH:MM:SS.MMMZ
 * @returns {string} formattedDate MM/DD/YYYY, HH:MM AM/PM
 */
export function formatDateTime(dateString) {
    const EMPTY_STRING = '';
    const US_DATETIME_FORMAT = 'en-US';
    const formatOptions = { dateStyle: 'short', timeStyle: 'short', timeZone: 'UTC' };
    try {
        let formattedDate = dateString
            ? new Date(dateString).toLocaleString(US_DATETIME_FORMAT, formatOptions)
            : EMPTY_STRING;
        return formattedDate;
    } catch (error) {
        console.error(error);
    }
}
