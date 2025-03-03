/**
 * @description This Lightning Web Component serves as a toolkit with various utility functions.
 * Usage:
 *
 * Importing a Specific Method:
 * import { debounce } from 'c/bahToolKit';
 *
 * Importing Multiple Functions or the Full Module:
 * import { capitalizeFirstLetter, toUpperCase, removeWhitespace } from 'c/bahToolKit';
 *
 * Importing all functions from strings.js:
 * import * as StringUtils from 'c/bahToolKit';
 *
 * ///EXAMPLES:
 * import { debounce } from 'c/bahToolKit';
 * const debouncedFunction = debounce((param) => functionToBeDebounced(param), 300);
 *
 * import { stringUtils } from 'c/bahToolKit';
 * const upperCaseString = stringUtils.makeUpperCase('hello');
 * console.log(upperCaseString); // Outputs: 'HELLO'
 *
 * const stringWithoutWhitespace = stringUtils.removeWhitespace('hello world   ');
 * console.log(stringWithoutWhitespace); // Outputs: 'hello world'
 *
 */

export { debounce } from './debounce';
export * from './strings';
