import apex_upsertAssociatedPersons from '@salesforce/apex/VCC_VaProfileController.upsertAssociatedPersons';
import postalCodeRegEx from '@salesforce/label/c.VCC_VA_Profile_Postal_Code_RegEx';
import specCharErrorMsg from '@salesforce/label/c.VCC_VA_Profile_Special_Characters_Error';
import postalCodeErrorMsg from '@salesforce/label/c.VCC_VA_Profile_Postal_Code_Error';
import stateCodeRegEx from '@salesforce/label/c.VCC_VA_Profile_State_Code_RegEx';
import stateCodeErrorMsg from '@salesforce/label/c.VCC_VA_Profile_State_Code_Error';
const POSTAL_CODE_REGEX = new RegExp(postalCodeRegEx);
const STATE_CODE_REGEX = new RegExp(stateCodeRegEx);
const SPEC_CHAR_ERROR_MSG = specCharErrorMsg;
const POSTAL_CODE_ERROR_MSG = postalCodeErrorMsg;
const STATE_CODE_ERROR_MSG = stateCodeErrorMsg;

// @justification: false positive \. is not a useless escape
// eslint-disable-next-line no-useless-escape
export let specialCharactersRegEx = /[^A-Za-z0-9\.\s,#\\\-/]/;
const SPEC_CHAR_REGEX = new RegExp(specialCharactersRegEx);

/**
 * @description CRM Pre-Submit Address Validation
 * @param {Object} address object containing address fields to check for validity
 */
export function checkAddressValidity(address) {
    let fullAddressString =
        address?.street + address?.city + address?.province + address?.postalCode + address?.country;
    let addressErrors = [];
    //Check for Special Characters
    if (SPEC_CHAR_REGEX.test(fullAddressString)) {
        addressErrors.push(SPEC_CHAR_ERROR_MSG);
    }
    //Check for valid Postal Code format if domestic
    if (address?.country === 'USA' && address?.postalCode && !POSTAL_CODE_REGEX.test(address.postalCode)) {
        addressErrors.push(POSTAL_CODE_ERROR_MSG);
    }

    //Check state code is 2 characters
    if (address?.country === 'USA' && (address?.province.length !== 2 || !STATE_CODE_REGEX.test(address.province))) {
        addressErrors.push(STATE_CODE_ERROR_MSG);
    }
    return addressErrors;
}

/**
 * @description Finds and removes control characters before submitting an address to VA Profile. Call this function before submittng to Apex
 * @param {String} line string of characters to remove control characters
 */
export function removeControlCharacters(line) {
    //Convert to JSON to expose Control Characters. Remove backslash and the next character after backslash
    line = JSON.stringify(line).replace(/\\./g, ' ');
    //Remove extra double quotes added by JSON.stringify
    line = line.replace(/"/g, '');
    return line;
}

/**
 * @description Calls apex method to send VA Profile HTTP request or throws an error if parameters are invalid.
 * @param {Object} param0 object with two properties destructured for this method
 * @param {String} param0.recordId Account record Id whose ICN you want to update their associated persons
 * @param {Array} param0.associatedPersons Array of associated persons to update
 */
export async function upsertAssociatedPersons({ recordId, associatedPersons }) {
    if (typeof recordId != 'string' || !Array.isArray(associatedPersons)) {
        throw new Error(
            `Failed to update associated persons because:\nOne or more parameters are invalid: recordId: ${recordId}, associatedPersons: ${associatedPersons}`
        );
    }
    return apex_upsertAssociatedPersons({ recordId: recordId, associatedPersons: JSON.stringify(associatedPersons) });
}
