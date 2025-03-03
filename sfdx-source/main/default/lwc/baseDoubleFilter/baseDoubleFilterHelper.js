// converts
// array = ["Id", "CreatedById", "firstName__c", "important_date__c", "Today__c"];
// to      ["Id", "Created By Id", "First Name", "Important Date", "Today"]
export const prettyString = (field) => {
    let newString = field
        .replace("__c", "")
        .replace("_", " ")
        .split(" ")
        .map((word) => word[0].toUpperCase().concat(word.slice(1)))
        .join("")
        .replace(/([A-Z])/g, " $1")
        .trim();
    return newString;
};

const sortArray = (incomingArray, value, descending = false) => {
    let i = descending ? -1 : 1;
    incomingArray.sort((a, b) => {
        if (a[value] > b[value]) {
            return 1 * i;
        } else if (b[value] > a[value]) {
            return -1 * i;
        }
        return 0;
    });
};

export const buildFirstFilterOptions = (list) => {
    // takes in an array of the api names from the data and makes an options array for the combobox
    let options = [];
    list.forEach((element) => {
        let rowData = {};
        rowData.label = prettyString(element);
        rowData.value = element;

        options.push(rowData);
    });
    sortArray(options, "label");
    //? add all as filter option
    let allOption = { label: "All", value: "all" };
    options.unshift(allOption);
    return options;
};

export const buildSecondFilterOptions = (list, filter) => {
    // takes in an array of the api names from the data and makes an options array for the combobox
    let options = [];
    // make a set of results
    const resultsSet = new Set();
    list.forEach((element) => {
        resultsSet.add(element[filter]);
    });
    let results = Array.from(resultsSet);
    results.forEach((result) => {
        let rowData = {};
        if (result.toString() === "" || result.toString() === null) {
            //? visualize all the blank value data
            rowData.label = "(no data)";
            rowData.value = result.toString();
        } else {
            rowData.label = result.toString();
            rowData.value = result.toString();
        }
        options.push(rowData);
    });
    sortArray(options, "label");
    // console.log('options: ', options);
    return options;
};

export const extractKeysFromList = (list, filterApiNames) => {
    // pulls the property key values from the data array and only keeps the filterApiNames given
    const keysSet = new Set();

    list.forEach((element) => {
        Object.keys(element).forEach((field) => {
            if (filterApiNames.includes(field)) keysSet.add(field);
        });
    });
    return Array.from(keysSet);
};
