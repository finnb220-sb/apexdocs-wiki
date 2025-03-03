// makes all characteres lowercase, and strips whitespace from a string

export const formatStringForSearch = (string) => {
    if (typeof string === "number") string = JSON.stringify(string);
    return (
        (typeof string === "string" &&
            string
                ?.toLowerCase()
                ?.replace(/(\r\n|\n|\r)/gm, "")
                ?.replace(/\s/g, "")) ||
        ""
    );
};

export const flatSearch = (list, searchString, propsToSearch) => {
    try {
        if (propsToSearch?.length) {
            return list.filter((listEntry) => {
                for (const [key, value] of Object.entries(listEntry)) {
                    if (!propsToSearch.includes(key)) continue;
                    return formatStringForSearch(value).includes(formatStringForSearch(searchString));
                }
            });
        } else {
            return list
                .map((entry) => {
                    for (const val of Object.values(entry)) {
                        if (!formatStringForSearch(val).includes(formatStringForSearch(searchString))) continue;
                        return entry;
                    }
                })
                .filter((e) => e != null); // filtering out null values
        }
    } catch (error) {
        console.error(error);
    }
};

export const chunk = (arr, size) => {
    let result = [];

    while (arr.length) {
        result.push(arr.splice(0, size));
    }

    return result;
};
