/**
 * @file HighlightBar.js
 * @description This Lightning Web Component (LWC) fetches and displays patient demographics
 *              data in a highlight bar format, using the fields defined in the desiredFields array.
 *              The component includes utility methods for formatting dates and phone numbers,
 *              and for logging errors via a custom logger component.
 * @author Booz Allen
 */
import { LightningElement, api, wire } from 'lwc';
import getHighlightData from '@salesforce/apex/VCC_HighlightBarController.getPatientDemographics';

export default class VccHighlightBar extends LightningElement {
    @api recordId;
    @api objectApiName;
    data = [];
    desiredFields;

    /**
     * Lifecycle method that is invoked when the element is added to the DOM.
     * Initializes the `desiredFields` array with field information, including key, defaultValue,
     * optional formatter function, and styling for each field.
     */
    connectedCallback() {
        this.desiredFields = [
            { key: 'DOB', defaultValue: '', formatter: this.formatDate, style: 'flex: 1 0 auto;' },
            { key: 'Age', defaultValue: '', style: 'flex: 1 0 auto;' },
            { key: 'Gender', defaultValue: '', style: 'flex: 1 0 auto;' },
            { key: 'Gender Identity', defaultValue: '', style: 'flex: 1 1 auto; word-break: break-word;' },
            {
                key: 'Call Back Number',
                defaultValue: '',
                formatter: this.formatPhoneNumber,
                style: 'flex: 1 1 auto; word-break: break-word;'
            },
            {
                key: 'Emergency Contact Phone',
                defaultValue: '',
                formatter: this.formatPhoneNumber,
                style: 'flex: 1 1 auto; word-break: break-word;'
            },
            {
                key: 'Emergency Contact',
                defaultValue: '',
                style: 'flex: 1 1 auto; word-break: break-word;'
            },
            {
                key: 'Current Location',
                defaultValue: '',
                style: 'flex: 1 1 auto; word-break: break-word;'
            }
        ];
    }

    /**
     * @description Fetches and processes the highlight data for the given record ID.
     * @param {Object} response - The response from the Apex method, containing either data or error.
     */
    @wire(getHighlightData, { recordId: '$recordId' })
    wiredData({ data }) {
        if (data) {
            const dataMap = Object.entries(data).reduce((acc, [key, value]) => {
                acc[key] = value;
                return acc;
            }, {});

            // Create an array based on the desired order
            this.data = this.desiredFields.map((field) => ({
                key: field.key,
                value: field.formatter
                    ? field.formatter(dataMap[field.key] || field.defaultValue)
                    : dataMap[field.key] || field.defaultValue,
                style: field.style
            }));
        }
    }

    /**
     * @description Utility function to format a date string into a readable format.
     * @param {String} dateString - The date string to format.
     * @returns {String} The formatted date.
     */
    formatDate(dateString) {
        if (!dateString) {
            return '';
        }
        const date = new Date(dateString);
        const options = { year: 'numeric', month: 'numeric', day: 'numeric' };
        return date.toLocaleDateString('en-US', options);
    }

    /**
     * @description Utility function to format a phone number string into a standardized format (XXX-XXX-XXXX).
     * @param {String} phoneString - The phone number string to format.
     * @returns {String} The formatted phone number, or the original string if invalid.
     *
     * This function:
     * - Removes all non-digit characters from the input phone number string.
     * - Checks if the resulting string has exactly 10 digits.
     * - If valid, formats it as XXX-XXX-XXXX.
     * - If not valid, returns the original string.
     */
    formatPhoneNumber(phoneString) {
        if (!phoneString) {
            return '';
        }
        // Remove all non-digit characters
        const cleaned = phoneString.replace(/\D/g, '');
        // Validate if cleaned string contains exactly 10 digits
        if (cleaned.length !== 10) {
            return phoneString;
        }
        // Format the cleaned string into XXX-XXX-XXXX
        const match = cleaned.match(/^(\d{3})(\d{3})(\d{4})$/);
        if (match) {
            return `${match[1]}-${match[2]}-${match[3]}`;
        }
        // Return original string if formatting fails
        return phoneString;
    }
}
