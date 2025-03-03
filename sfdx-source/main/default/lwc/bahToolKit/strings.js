/**
 * @description This file contains a class with utility methods that manipulate string parameters to change their structure.
 */

export class stringUtils {
    /**
     * @description Converts the entire input string to uppercase.
     * @param {string} string - The string to be transformed.
     * @returns {string} - The transformed string in uppercase.
     */
    static makeUpperCase(string) {
        return string.toUpperCase();
    }

    /**
     * @description Removes all whitespace from the input string.
     * @param {string} string - The string to be transformed.
     * @returns {string} - The transformed string without any whitespace.
     */
    static removeWhitespace(string) {
        return string.trim();
    }
}
