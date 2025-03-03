/**
 * @description Unit test suite for the `VccHighlightBar` LWC component.
 * It validates the behavior of the `formatPhoneNumber` method for phone number formatting,
 * covering edge cases, as well as verifying the rendering of highlight bar elements
 * populated via the `getPatientDemographics` Apex wire adapter.
 *
 * @author Booz Allen Hamilton
 * @see VccHighlightBar
 */
import { createElement } from 'lwc';
import VccHighlightBar from 'c/vccHighlightBar';
import getPatientDemographics from '@salesforce/apex/VCC_HighlightBarController.getPatientDemographics';

// Mock data for various test scenarios
const mockGetHighlightArray = require('./data/getHighlightArray.json');
const happyPath = mockGetHighlightArray.happyPath;
const nullCheck = mockGetHighlightArray.nullCheck;
const emptyCheck = mockGetHighlightArray.emptyCheck;
const onlyAlphaCheck = mockGetHighlightArray.onlyAlphaCheck;
const lengthTooShort = mockGetHighlightArray.lengthTooShort;
const lengthTooLong = mockGetHighlightArray.lengthTooLong;

// Constants for repeated strings
const HIGHLIGHT_KEY_SELECTORS = 'div.slds-text-title.slds-m-top_xx-small';
const HIGHLIGHT_VALUE_SELECTORS = 'div.slds-text-body_regular.slds-wrap.slds-m-bottom_xx-small';
const EMPTY_STRING = '';
const INVALID_DATA = 'invalidData';
const INVALID_DATE = 'Invalid Date';

const LABELS = {
    DOB: 'DOB',
    AGE: 'Age',
    GENDER: 'Gender',
    GENDER_IDENTITY: 'Gender Identity',
    CALLBACK_NUMBER: 'Call Back Number',
    EMERGENCY_CONTACT_PHONE: 'Emergency Contact Phone',
    EMERGENCY_CONTACT: 'Emergency Contact',
    CURRENT_LOCATION: 'Current Location'
};

// Utility functions

/**
 * @description Validates the key-value pairs of the highlight bar elements to ensure that they are rendered with empty strings.
 * This utility function is used for cases where no data is provided or data is missing.
 *
 * @param {NodeList} key - NodeList of key elements rendered in the highlight bar.
 * @param {NodeList} value - NodeList of value elements rendered in the highlight bar.
 */
function validateHighlightBarData(key, value) {
    expect(key[0].textContent).toBe(LABELS.DOB);
    expect(value[0].textContent).toBe(EMPTY_STRING);
    expect(key[1].textContent).toBe(LABELS.AGE);
    expect(value[1].textContent).toBe(EMPTY_STRING);
    expect(key[2].textContent).toBe(LABELS.GENDER);
    expect(value[2].textContent).toBe(EMPTY_STRING);
    expect(key[3].textContent).toBe(LABELS.GENDER_IDENTITY);
    expect(value[3].textContent).toBe(EMPTY_STRING);
    expect(key[4].textContent).toBe(LABELS.CALLBACK_NUMBER);
    expect(value[4].textContent).toBe(EMPTY_STRING);
    expect(key[5].textContent).toBe(LABELS.EMERGENCY_CONTACT_PHONE);
    expect(value[5].textContent).toBe(EMPTY_STRING);
    expect(key[6].textContent).toBe(LABELS.EMERGENCY_CONTACT);
    expect(value[6].textContent).toBe(EMPTY_STRING);
    expect(key[7].textContent).toBe(LABELS.CURRENT_LOCATION);
    expect(value[7].textContent).toBe(EMPTY_STRING);
}

// Mock getPatientDemographics Apex wire adapter
jest.mock(
    '@salesforce/apex/VCC_HighlightBarController.getPatientDemographics',
    () => {
        const { createApexTestWireAdapter } = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

/**
 * @description Unit test suite for the `VccHighlightBar` LWC component.
 * This suite validates the behavior of various methods and the rendering of highlight bar elements,
 * including the `formatPhoneNumber` method, `formatDate` method, and data rendered via the `getPatientDemographics` Apex wire adapter.
 * Covers different scenarios such as valid data, missing data, invalid data, and edge cases.
 */
describe('c-vcc-highlight-bar', () => {
    let formatPhoneNumber;
    let formatDate;

    /**
     * @description Assigns the `formatPhoneNumber` and `formatDate` methods from the `VccHighlightBar` component prototype for isolated testing.
     */
    beforeEach(() => {
        // Assign the method from the prototype for isolated testing

        /**
         * @description Formats a phone number string into a standard format (XXX-XXX-XXXX).
         * Removes non-digit characters and validates length.
         *
         * @param {string} phoneNumber - The phone number string to be formatted.
         * @returns {string} - The formatted phone number or the original input if invalid.
         */
        formatPhoneNumber = VccHighlightBar.prototype.formatPhoneNumber;

        /**
         * @description Formats a date string into a localized date format.
         * If the input is invalid, it returns the original string.
         *
         * @param {string} date - The date string to be formatted.
         * @returns {string} - The formatted date or the original input if invalid.
         */
        formatDate = VccHighlightBar.prototype.formatDate;
    });

    /**
     * @description Cleans up the DOM and resets mocks after each test to prevent test leakage.
     */
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    /**
     * @description Validates the correct rendering of highlight bar elements when populated via the `getPatientDemographics` Apex wire adapter.
     */
    describe('getHighlightList @wire data', () => {
        /**
         * @description Validates the correct rendering of highlight bar data when populated with valid data.
         * It ensures the correct key-value pairs are rendered when data is present for all fields.
         */
        it('renders highlight bar data correctly when populated with valid data', () => {
            const element = createElement('c-wire-apex', { is: VccHighlightBar });
            document.body.appendChild(element);

            // Emit mock data from @wire
            getPatientDemographics.emit(happyPath);

            return Promise.resolve().then(() => {
                // Select elements for validation
                const highlightValueElements = element.shadowRoot.querySelectorAll(HIGHLIGHT_VALUE_SELECTORS);
                const highlightKeyElements = element.shadowRoot.querySelectorAll(HIGHLIGHT_KEY_SELECTORS);

                expect(highlightValueElements.length).toBe(8);

                // Validate key-value pairs
                expect(highlightKeyElements[0].textContent).toBe(LABELS.DOB);
                expect(highlightValueElements[0].textContent).toBe('1/1/1981');
                expect(highlightKeyElements[1].textContent).toBe(LABELS.AGE);
                expect(highlightValueElements[1].textContent).toBe('44');
                expect(highlightKeyElements[2].textContent).toBe(LABELS.GENDER);
                expect(highlightValueElements[2].textContent).toBe('Male');
                expect(highlightKeyElements[3].textContent).toBe(LABELS.GENDER_IDENTITY);
                expect(highlightValueElements[3].textContent).toBe('Male');
                expect(highlightKeyElements[4].textContent).toBe(LABELS.CALLBACK_NUMBER);
                expect(highlightValueElements[4].textContent).toBe('123-456-7890');
                expect(highlightKeyElements[5].textContent).toBe(LABELS.EMERGENCY_CONTACT_PHONE);
                expect(highlightValueElements[5].textContent).toBe('804-555-1005');
                expect(highlightKeyElements[6].textContent).toBe(LABELS.EMERGENCY_CONTACT);
                expect(highlightValueElements[6].textContent).toBe('Some Name');
                expect(highlightKeyElements[7].textContent).toBe(LABELS.CURRENT_LOCATION);
                expect(highlightValueElements[7].textContent).toBe('Washington, D.C.');
            });
        });

        /**
         * @description Validates the rendering of highlight bar elements when no data is provided.
         * It ensures all fields display empty values when the data is null.
         */
        it('renders empty values when no data is provided', () => {
            const element = createElement('c-wire-apex', {
                is: VccHighlightBar
            });
            document.body.appendChild(element);

            // Emit mock data from @wire
            getPatientDemographics.emit(nullCheck);

            return Promise.resolve().then(() => {
                // Select elements for validation
                const highlightValueElements = element.shadowRoot.querySelectorAll(HIGHLIGHT_VALUE_SELECTORS);
                const highlightKeyElements = element.shadowRoot.querySelectorAll(HIGHLIGHT_KEY_SELECTORS);

                expect(highlightValueElements.length).toBe(8);

                // Validate key-value pairs
                validateHighlightBarData(highlightKeyElements, highlightValueElements);
            });
        });

        /**
         * @description Validates the rendering of highlight bar elements when the data is missing.
         * It ensures all fields display empty values when the data is missing for some fields.
         */
        it('renders empty values when data is missing', () => {
            const element = createElement('c-wire-apex', {
                is: VccHighlightBar
            });
            document.body.appendChild(element);

            // Emit mock data from @wire
            getPatientDemographics.emit(emptyCheck);

            return Promise.resolve().then(() => {
                // Select elements for validation
                const highlightValueElements = element.shadowRoot.querySelectorAll(HIGHLIGHT_VALUE_SELECTORS);
                const highlightKeyElements = element.shadowRoot.querySelectorAll(HIGHLIGHT_KEY_SELECTORS);

                expect(highlightValueElements.length).toBe(8);

                // Validate key-value pairs
                validateHighlightBarData(highlightKeyElements, highlightValueElements);
            });
        });

        /**
         * @description Validates the rendering of highlight bar elements when non-numeric or invalid data is provided.
         * It ensures that invalid data (like text in fields that expect numbers) is displayed correctly.
         */
        it('renders invalid values when non-numeric data is provided', () => {
            const element = createElement('c-wire-apex', {
                is: VccHighlightBar
            });
            document.body.appendChild(element);

            // Emit mock data from @wire
            getPatientDemographics.emit(onlyAlphaCheck);

            return Promise.resolve().then(() => {
                const highlightValueElements = element.shadowRoot.querySelectorAll(HIGHLIGHT_VALUE_SELECTORS);
                const highlightKeyElements = element.shadowRoot.querySelectorAll(HIGHLIGHT_KEY_SELECTORS);

                expect(highlightValueElements.length).toBe(8);

                // Validate key-value pairs
                expect(highlightKeyElements[0].textContent).toBe(LABELS.DOB);
                expect(highlightValueElements[0].textContent).toBe(INVALID_DATE);
                expect(highlightKeyElements[1].textContent).toBe(LABELS.AGE);
                expect(highlightValueElements[1].textContent).toBe(INVALID_DATA);
                expect(highlightKeyElements[2].textContent).toBe(LABELS.GENDER);
                expect(highlightValueElements[2].textContent).toBe(INVALID_DATA);
                expect(highlightKeyElements[3].textContent).toBe(LABELS.GENDER_IDENTITY);
                expect(highlightValueElements[3].textContent).toBe(INVALID_DATA);
                expect(highlightKeyElements[4].textContent).toBe(LABELS.CALLBACK_NUMBER);
                expect(highlightValueElements[4].textContent).toBe(INVALID_DATA);
                expect(highlightKeyElements[5].textContent).toBe(LABELS.EMERGENCY_CONTACT_PHONE);
                expect(highlightValueElements[5].textContent).toBe(INVALID_DATA);
                expect(highlightKeyElements[6].textContent).toBe(LABELS.EMERGENCY_CONTACT);
                expect(highlightValueElements[6].textContent).toBe(INVALID_DATA);
                expect(highlightKeyElements[7].textContent).toBe(LABELS.CURRENT_LOCATION);
                expect(highlightValueElements[7].textContent).toBe(INVALID_DATA);
            });
        });

        /**
         * @description Validates the rendering of highlight bar elements when data is too short.
         * It ensures that fields with values shorter than expected are truncated and displayed appropriately.
         */
        it('renders shortened values when data is too short', () => {
            const element = createElement('c-wire-apex', { is: VccHighlightBar });
            document.body.appendChild(element);

            // Emit mock data from @wire
            getPatientDemographics.emit(lengthTooShort);

            return Promise.resolve().then(() => {
                // Select elements for validation
                const highlightValueElements = element.shadowRoot.querySelectorAll(HIGHLIGHT_VALUE_SELECTORS);
                const highlightKeyElements = element.shadowRoot.querySelectorAll(HIGHLIGHT_KEY_SELECTORS);

                expect(highlightValueElements.length).toBe(8);

                // Validate key-value pairs
                expect(highlightKeyElements[0].textContent).toBe(LABELS.DOB);
                expect(highlightValueElements[0].textContent).toBe('1/1/2001');
                expect(highlightKeyElements[1].textContent).toBe(LABELS.AGE);
                expect(highlightValueElements[1].textContent).toBe('4');
                expect(highlightKeyElements[2].textContent).toBe(LABELS.GENDER);
                expect(highlightValueElements[2].textContent).toBe('Ma');
                expect(highlightKeyElements[3].textContent).toBe(LABELS.GENDER_IDENTITY);
                expect(highlightValueElements[3].textContent).toBe('Ma');
                expect(highlightKeyElements[4].textContent).toBe(LABELS.CALLBACK_NUMBER);
                expect(highlightValueElements[4].textContent).toBe('123');
                expect(highlightKeyElements[5].textContent).toBe(LABELS.EMERGENCY_CONTACT_PHONE);
                expect(highlightValueElements[5].textContent).toBe('804');
                expect(highlightKeyElements[6].textContent).toBe(LABELS.EMERGENCY_CONTACT);
                expect(highlightValueElements[6].textContent).toBe('S');
                expect(highlightKeyElements[7].textContent).toBe(LABELS.CURRENT_LOCATION);
                expect(highlightValueElements[7].textContent).toBe('Wash');
            });
        });

        /**
         * @description Validates the rendering of highlight bar elements when data is too long.
         * It ensures that fields with values longer than expected are truncated and displayed appropriately.
         */
        it('renders truncated values when data is too long', () => {
            const element = createElement('c-wire-apex', { is: VccHighlightBar });
            document.body.appendChild(element);

            // Emit mock data from @wire
            getPatientDemographics.emit(lengthTooLong);

            return Promise.resolve().then(() => {
                // Select elements for validation
                const highlightValueElements = element.shadowRoot.querySelectorAll(HIGHLIGHT_VALUE_SELECTORS);
                const highlightKeyElements = element.shadowRoot.querySelectorAll(HIGHLIGHT_KEY_SELECTORS);

                expect(highlightValueElements.length).toBe(8);

                // Validate key-value pairs
                expect(highlightKeyElements[0].textContent).toBe(LABELS.DOB);
                expect(highlightValueElements[0].textContent).toBe('1/1/1981');
                expect(highlightKeyElements[1].textContent).toBe(LABELS.AGE);
                expect(highlightValueElements[1].textContent).toBe('4444');
                expect(highlightKeyElements[2].textContent).toBe(LABELS.GENDER);
                expect(highlightValueElements[2].textContent).toBe('MaleMaleMaleMale');
                expect(highlightKeyElements[3].textContent).toBe(LABELS.GENDER_IDENTITY);
                expect(highlightValueElements[3].textContent).toBe('MaleMaleMaleMale');
                expect(highlightKeyElements[4].textContent).toBe(LABELS.CALLBACK_NUMBER);
                expect(highlightValueElements[4].textContent).toBe('80455123456789051005');
                expect(highlightKeyElements[5].textContent).toBe(LABELS.EMERGENCY_CONTACT_PHONE);
                expect(highlightValueElements[5].textContent).toBe('80455123456789051005');
                expect(highlightKeyElements[6].textContent).toBe(LABELS.EMERGENCY_CONTACT);
                expect(highlightValueElements[6].textContent).toBe('Some Long Long Long Long Long Long Long Name');
                expect(highlightKeyElements[7].textContent).toBe(LABELS.CURRENT_LOCATION);
                expect(highlightValueElements[7].textContent).toBe('Some Long Long Long Long Long Long Long Name');
            });
        });
    });

    /**
     * @description Ensures `formatDate` returns the original string for invalid date inputs.
     */
    it('returns the original string for invalid date inputs', () => {
        const input = '';
        const expectedOutput = '';
        const result = formatDate(input);
        expect(result).toBe(expectedOutput);
    });

    /**
     * @description Validates that `formatPhoneNumber` correctly formats a valid 10-digit phone number.
     */
    it('formats a valid 10-digit phone number correctly', () => {
        const input = '1234567890';
        const expectedOutput = '123-456-7890';
        const result = formatPhoneNumber(input);
        expect(result).toBe(expectedOutput);
    });

    /**
     * @description Ensures `formatPhoneNumber` returns the original string for invalid phone numbers.
     */
    it('returns the original string for invalid phone numbers', () => {
        const input = '12345';
        const expectedOutput = '12345';
        const result = formatPhoneNumber(input);
        expect(result).toBe(expectedOutput);
    });

    /**
     * @description Ensures `formatPhoneNumber` returns an empty string for an empty input.
     */
    it('returns an empty string for empty phone number input', () => {
        const input = '';
        const expectedOutput = '';
        const result = formatPhoneNumber(input);
        expect(result).toBe(expectedOutput);
    });

    /**
     * @description Validates that `formatPhoneNumber` removes non-digit characters from valid phone numbers.
     */
    it('removes non-digit characters and formats a phone number correctly', () => {
        const input = '(123) 456-7890';
        const expectedOutput = '123-456-7890';
        const result = formatPhoneNumber(input);
        expect(result).toBe(expectedOutput);
    });

    /**
     * @description Confirms that `formatPhoneNumber` returns the original input for phone numbers with more than 10 digits.
     */
    it('returns the original string for phone numbers with more than 10 digits', () => {
        const input = '1234567890123';
        const expectedOutput = '1234567890123';
        const result = formatPhoneNumber(input);
        expect(result).toBe(expectedOutput);
    });
});
