export const chunk = (arr, size) => {
    let result = [];

    while (arr.length) {
        result.push(arr.splice(0, size));
    }

    return result;
};
