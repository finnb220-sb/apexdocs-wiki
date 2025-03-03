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

export const buildFilterOptions = (list, filter) => {
    // takes in an api name and makes an options array for the combobox
    let options = [];
    // make a set of results
    const resultsSet = new Set();
    list.forEach((element) => {
        resultsSet.add(element[filter]);
    });
    let results = Array.from(resultsSet);
    results.forEach((result) => {
        // if (result.toString() === "" || result.toString() === null) return;
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
    return options;
};
