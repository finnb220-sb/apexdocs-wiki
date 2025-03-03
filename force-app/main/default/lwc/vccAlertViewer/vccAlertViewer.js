import { LightningElement } from 'lwc';
import refreshAlerts from '@salesforce/apex/VCC_ViewAlerts.refreshAlerts';

const ALERT_THRESHOLD = 3;
const EMPTY_LENGTH = 0;

/**
 * VccAlertViewer component is responsible for fetching and displaying alerts.
 */
export default class VccAlertViewer extends LightningElement {
    alertsData = [];
    sortedBy = 'timestamp';
    sortedDirection = 'desc';
    isLoading;
    emptyMsg = 'No Alerts Returned';
    displayError = false;
    error = '';

    columns = [
        { fieldName: 'patientName', label: 'Patient Name', sortable: true, type: 'text', initialWidth: 175 },
        { fieldName: 'patientLast4SSN', label: 'Last 4 of SSN', sortable: true, type: 'text', initialWidth: 130 },
        { fieldName: 'message', label: 'Alert Message', type: 'text', initialWidth: 300 },
        { fieldName: 'facilityId', label: 'Facility', sortable: true, type: 'text', initialWidth: 100 },
        {
            fieldName: 'dateTime',
            label: 'Date/Time',
            sortable: true,
            initialWidth: 150,
            type: 'date',
            typeAttributes: { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' }
        },
        { fieldName: 'surrogateName', label: 'Surrogate For', sortable: true, type: 'text', initialWidth: 175 },
        { fieldName: 'forwardedBy', label: 'Fwd By', sortable: true, type: 'text', initialWidth: 175 },
        {
            fieldName: 'forwardedDateTime',
            label: 'Fwd Date/Time',
            sortable: true,
            initialWidth: 150,
            type: 'date',
            typeAttributes: { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' }
        },
        { fieldName: 'forwardedComment', label: 'Fwd Comments', sortable: true, type: 'text', initialWidth: 300 }
    ];

    /**
     * @description Called when the component is inserted into the DOM. Fetches alerts manually.
     */
    connectedCallback() {
        this.fetchAlertsManually();
    }

    /**
     * @description Parses the response data from getAlerts or refreshAlerts.
     *              Updates the component state based on the response data or error.
     * @param {Object} data - The response data from the Apex call.
     * @param {Object} error - The error object if the Apex call fails.
     */
    parseGetAlerts(data, error) {
        let alertsData = [];

        if (data && Array.isArray(data.records) && data.records.length > 0) {
            alertsData = data.records.map((record) => ({
                patientName: record.patientName,
                patientLast4SSN: record.patientLast4SSN,
                facilityId: record.facilityId,
                dateTime: record.timestamp,
                message: record.message,
                forwardedBy:
                    record.forwardedNameAndDate != null //removing the date from the combined property
                        ? this.trimForwardedNameAndDate(record.forwardedNameAndDate, 'Name')
                        : null,
                forwardedDateTime:
                    record.forwardedNameAndDate != null //removing the name from the combined property
                        ? this.trimForwardedNameAndDate(record.forwardedNameAndDate, 'Date')
                        : null,
                forwardedComment: record.forwardedComment,
                surrogateName: record.surrogateName
            }));
            this.alertsData = alertsData;
            this.sortData(this.sortedBy, this.sortedDirection);
        } else if (error && error.body && error.body.message) {
            try {
                const parsedError = JSON.parse(error.body.message);

                if (Array.isArray(parsedError) && parsedError.length > 0) {
                    alertsData = parsedError.flatMap((item) => {
                        if (Array.isArray(item.alerts) && item.alerts.length > 0) {
                            return item.alerts.map((alert) => ({
                                patientName: alert.parsedPatientName,
                                patientLast4SSN: alert.parsedPatientLast4Ssn,
                                facilityId: item.facilityId,
                                dateTime: alert.parsedDateTime,
                                message: alert.alertDisplayText,
                                forwardedBy:
                                    alert.alertForwardedNameAndDate != null //removing the date from the combined property
                                        ? this.trimForwardedNameAndDate(alert.alertForwardedNameAndDate, 'Name')
                                        : null,
                                forwardedDateTime:
                                    alert.alertForwardedNameAndDate != null //removing the name from the combined property
                                        ? this.trimForwardedNameAndDate(alert.alertForwardedNameAndDate, 'Date')
                                        : null,
                                forwardedComment: alert.alertForwardedComment,
                                surrogateName: alert.alertSurrogateName
                            }));
                        }
                        return [];
                    });
                    this.alertsData = alertsData;
                } else {
                    this.displayError = true;
                    this.error = parsedError[0].message;
                }
            } catch (errorParsingException) {
                this.displayError = true;
                this.error = 'Error parsing error response' + errorParsingException.message;
            }
        } else {
            this.displayError = true;
            this.error = 'An unexpected error has occurred. Please contact your administrator.';
        }
    }

    /**
     * @description Returns one of two data points included in the forwardedNameAndDate property (Name or Date)
     * @param {String} nameAndDate The Name and Date concatenated Example: "PATEL,TUSHAR P 07/30/24 10:57:20"
     * @param {String} returnType The value to return (Name or Date)
     * @returns {String} The Name without the Date, or the Date without the Name
     * @example trimForwardedNameAndDate("PATEL,TUSHAR P 07/30/24 10:57:20", 'Name') //Returns "PATEL,TUSHAR P"
     * @example trimForwardedNameAndDate("PATEL,TUSHAR P 07/30/24 10:57:20", 'Date') //Returns "07/30/24 10:57:20"
     */
    trimForwardedNameAndDate(nameAndDate, returnType) {
        switch (returnType) {
            case 'Name':
                return nameAndDate
                    .trim()
                    .substring(0, nameAndDate.length - 17)
                    .trim();
            case 'Date':
                return nameAndDate
                    .trim()
                    .substring(nameAndDate.length - 17)
                    .trim();
            default: //default to return Name if no returnType is provided
                return nameAndDate
                    .trim()
                    .substring(0, nameAndDate.length - 17)
                    .trim();
        }
    }

    /**
     * @description Fetches alerts manually by making an imperative Apex call to refreshAlerts.
     *              Handles loading state and parses the response data.
     */
    async fetchAlertsManually() {
        let data;
        let error;
        try {
            this.isLoading = true;
            data = await refreshAlerts();
            error = undefined;
        } catch (exc) {
            data = undefined;
            error = exc;
        }
        this.parseGetAlerts(data, error);
        this.hideLoading();
    }

    /**
     * Handles sorting of the data when the user clicks on a sortable column.
     * @param {Event} event - The sort event.
     */
    handleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        this.sortedBy = sortedBy;
        this.sortedDirection = sortDirection;
        this.sortData(sortedBy, sortDirection);
    }

    /**
     * Sorts the alerts data based on the given field and direction.
     * @param {string} fieldName - The field name to sort by.
     * @param {string} sortDirection - The direction to sort ('asc' or 'desc').
     */
    sortData(fieldName, sortDirection) {
        if (!this.alertsData) {
            return;
        }
        const parseData = (data) => {
            if (fieldName === 'dateTime') {
                return new Date(data[fieldName]);
            }
            let result = '';
            if (data[fieldName]) {
                result = data[fieldName].toLowerCase();
            }
            return result;
        };

        this.alertsData = [...this.alertsData].sort((aValue, bValue) => {
            const EQUAL = 0,
                GREATER_THAN = 1,
                LESS_THAN = -1,
                valueA = parseData(aValue),
                valueB = parseData(bValue);

            let result = EQUAL;

            if (valueA > valueB) {
                result = GREATER_THAN;
            } else if (valueA < valueB) {
                result = LESS_THAN;
            }

            if (sortDirection === 'asc') {
                return result;
            }
            return -result;
        });
    }

    /**
     * Gets whether there are more than three alerts.
     * @return {boolean} - True if there are more than three alerts, false otherwise.
     */
    get isMoreThanThreeAlerts() {
        return this.alertsData && this.alertsData.length > ALERT_THRESHOLD;
    }

    /**
     * Gets whether there are no alerts.
     * @return {boolean} - True if there are no alerts, false otherwise.
     */
    get isEmpty() {
        return this.alertsData && this.alertsData.length === EMPTY_LENGTH;
    }

    /**
     * Hides the loading spinner.
     */
    hideLoading() {
        this.isLoading = false;
    }
}
