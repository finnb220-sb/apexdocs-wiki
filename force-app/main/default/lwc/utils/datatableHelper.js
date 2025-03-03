export const getColumn = (columns = [], fieldName) => columns.find((entry) => entry.fieldName === fieldName);

function isNumeric(str) {
    if (typeof str != 'string') return false; // we only process strings!
    return (
        !isNaN(str) && // use type coercion to parse the _entirety_ of the string (`parseFloat` alone does not do this)...
        !isNaN(parseFloat(str))
    ); // ...and ensure strings of whitespace fail
}

// eslint-disable-next-line consistent-return
export const sortFlatList = (list, property, direction) => {
    const { propertyName, type } = property;
    //TODO: Add all possible lightning-data-table column "types" to this case statement
    // eslint-disable-next-line default-case
    switch (type) {
        case 'text':
            return list.sort((a, b) => {
                a = a[propertyName]?.toLowerCase() || '';
                b = b[propertyName]?.toLowerCase() || '';

                if (a === b) return 1;

                if (direction === 'asc') {
                    //CCCM-27465 Lab Results Not Displaying in Results Column
                    //Conditions added to check for strings that are actually numbers. Some columns have both text and numbers passed as a string datatype by the API (ex. Results column on Labs)
                    //These sorting conditions will either add the Numbers to the top or bottom of the sorted array depending on direction, as well as sort those numbers smallest to greatest or vice versa
                    if (isNumeric(a) && !isNumeric(b)) {
                        return 1;
                    }
                    if (!isNumeric(a) && isNumeric(b)) {
                        return -1;
                    }
                    if (isNumeric(a) && isNumeric(b)) {
                        return parseFloat(a) > parseFloat(b) ? 1 : -1;
                    }
                    return a > b ? 1 : -1;
                }
                if (isNumeric(a) && !isNumeric(b)) {
                    return -1;
                }
                if (!isNumeric(a) && isNumeric(b)) {
                    return 1;
                }
                if (isNumeric(a) && isNumeric(b)) {
                    return parseFloat(a) > parseFloat(b) ? -1 : 1;
                }
                return b > a ? 1 : -1;
            });

        case 'caseSensitive':
            return list.sort((a, b) => {
                if (direction === 'asc') {
                    return (a[propertyName] || '') > (b[propertyName] || '') ? 1 : -1;
                }
                return (b[propertyName] || '') > (a[propertyName] || '') ? 1 : -1;
            });

        case 'date':
        case 'date-local':
            return list.sort((a, b) => {
                return sortDates(a, b, propertyName, direction);
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
    }
};

function sortDates(dateA, dateB, propertyName, direction) {
    dateA = Date.parse(dateA[propertyName]) || 0;
    dateB = Date.parse(dateB[propertyName]) || 0;
    if (direction === 'asc') {
        return dateA - dateB;
    }
    return dateB - dateA;
}

/**
 * @description Use this function to sort given HDR data array by the provided fieldName, in the provided sort direction
 * - Uses the sortFlatList() function for most column types.
 * - Has special use cases when sorting by 'bmi' and 'bloodPressure' columns.
 * - When sorting by a button column, sorts by the column's typeAttributes.type value.
 * @param data `Object[]` An array of data (e.g. HDR data!)
 * @param column `Object` A column for a lightning datatable
 * - Expected to have a 'fieldName' property
 * @param sortDirection `String` - the direction to sort in, either "asc" or "desc"
 * @returns {*} `Object[]` the sorted data
 */
export const sortHDRData = (data = [], column, sortDirection) => {
    if (!column || !column.fieldName) {
        //invalid column
        return data;
    }
    if (column.fieldName === 'bmi') {
        data = [...data].sort((a, b) => {
            a = a.bmi?.includes('*') ? parseFloat(a.bmi.split('*')[0], 10) : a.bmi;
            b = b.bmi?.includes('*') ? parseFloat(b.bmi.split('*')[0], 10) : b.bmi;
            if (sortDirection === 'asc') {
                return a - b;
            }
            return b - a;
        });
    } else if (column.fieldName === 'bloodPressure') {
        data = [...data].sort((a, b) => {
            a = a.bloodPressure ? a.bloodPressure?.split(' ')[0].split('/')[0] : 0;
            b = b.bloodPressure ? b.bloodPressure?.split(' ')[0].split('/')[0] : 0;

            if (sortDirection === 'asc') {
                return a - b;
            }
            return b - a;
        });
    } else if (column.fieldName === 'onsetdate') {
        //for HDR problems list, when sorting by onsetdate, descending, make sure nulls are first.
        //otherwise, follow normal date sorting algorithm (encapsulated by the sortDates function)
        data = [...data].sort((a, b) => {
            if (sortDirection === 'desc') {
                if (!a.onsetdate && !b.onsetdate) {
                    //a and b are both null
                    return 0;
                }
                if (!a.onsetdate && b.onsetdate) {
                    //null a should come before b
                    return -1;
                }
                if (a.onsetdate && !b.onsetdate) {
                    //null b should come before a
                    return 1;
                }
            }
            return sortDates(a, b, column.fieldName, sortDirection);
        });
    } else if (column.type === 'button') {
        // if column is a button or "clickable link" use the typeAttributes.type property to sort else use regular type on the root object
        data = sortFlatList(
            [...data],
            { propertyName: column.fieldName, type: column.typeAttributes?.type },
            sortDirection
        );
    } else {
        data = sortFlatList([...data], { propertyName: column.fieldName, type: column.type }, sortDirection);
    }
    return data;
};
