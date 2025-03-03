export const sortFlatList = (list, property, direction) => {
    const { propertyName, type } = property;

    switch (type) {
        case "text":
            return list.sort((a, b) => {
                a = a[propertyName]?.toLowerCase() || "";
                b = b[propertyName]?.toLowerCase() || "";

                if (direction === "asc") {
                    return a > b ? 1 : -1;
                } else {
                    return b > a ? 1 : -1;
                }
            });

        case "caseSensitive":
            return list.sort((a, b) => {
                if (direction === "asc") {
                    return a[propertyName] ? a[propertyName] : "" > b[propertyName] ? b[propertyName] : "" ? 1 : -1;
                } else {
                    return b[propertyName] ? b[propertyName] : "" > a[propertyName] ? a[propertyName] : "" ? 1 : -1;
                }
            });

        case "date":
        case "date-local":
            return list.sort((a, b) => {
                a = Date.parse(a[propertyName]) || 0;
                b = Date.parse(b[propertyName]) || 0;

                if (direction === "asc") {
                    return a - b;
                } else {
                    return b - a;
                }
            });

        case "number":
            return list.sort((a, b) => {
                a = parseFloat(a[propertyName]) || 0;
                b = parseFloat(b[propertyName]) || 0;

                if (direction === "asc") {
                    return a - b;
                } else {
                    return b - a;
                }
            });
        case "groupByType":
        // TODO: Sort data 'excel style'
    }
};
