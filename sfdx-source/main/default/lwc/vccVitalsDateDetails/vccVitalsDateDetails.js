import { LightningElement, api } from 'lwc';

export default class VccVitalsDateDetails extends LightningElement {
    _selectedRecord;

    @api
    get selectedRecord() {
        return this._selectedRecord;
    }

    set selectedRecord(value) {
        this._selectedRecord = value;
        this.vitalList = [];
        this.processVital(this._selectedRecord);
    }

    /**
     * @description sets the selected vitals measurement set to display
     * @param record Consult record to render
     */
    @api
    setSelectedRecord(record) {
        // need to supress this so that the modal remains reactive.
        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
        this.selectedRecord = record;
    }

    chartTitle;

    columns = [
        { label: 'Vital', fieldName: 'vital', type: 'text', sortable: true },
        { label: 'Reading', fieldName: 'reading', type: 'text', sortable: true },
        { label: 'Unit', fieldName: 'unit', type: 'text', sortable: true },
        { label: 'Reference Range', fieldName: 'referenceRange', type: 'text', sortable: true },
        { label: 'Interpretation', fieldName: 'interpretation', type: 'text', sortable: true }
    ];
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    vitalList = [];

    /**
     * @description Given a row clicked by a user, we need to manipulate the row passed into an object that plays well with our datatable.
     * @param focusedVital this.selectedRecord
     * @see this.selectedRecord
     */
    processVital(focusedVital) {
        this.chartTitle = `Vitals - ${focusedVital.takenFormatted}`;
        for (const property in focusedVital) {
            if (Object.hasOwn(focusedVital, property)) {
                switch (property) {
                    case 'bloodPressure':
                        this.vitalList.push({
                            id: 1,
                            vital: 'Blood Pressure',
                            reading: focusedVital[property],
                            unit: 'mm[Hg]',
                            referenceRange: `${focusedVital.bloodPressureLow} - ${focusedVital.bloodPressureHigh}`,
                            interpretation: ''
                        });
                        break;
                    case 'temperature':
                        this.vitalList.push({
                            id: 2,
                            vital: 'Temperature',
                            reading: focusedVital[property],
                            unit: '°F',
                            referenceRange: `${focusedVital.temperatureLow} - ${focusedVital.temperatureHigh}`,
                            interpretation: this.calculateInterpretation(
                                focusedVital.temperatureLow,
                                focusedVital.temperatureHigh,
                                focusedVital[property]
                            )
                        });
                        break;
                    case 'circumferenceGirth':
                        this.vitalList.push({
                            id: 3,
                            vital: 'Circumference/Girth',
                            reading: focusedVital[property],
                            unit: 'in',
                            referenceRange: '⏤',
                            interpretation: ''
                        });
                        break;
                    case 'centralVenousPressure':
                        this.vitalList.push({
                            id: 4,
                            vital: 'Central Venous Pressure',
                            reading: focusedVital[property],
                            unit: 'cmH2O',
                            referenceRange: `${focusedVital.centralVenousPressureLow} - ${focusedVital.centralVenousPressureHigh}`,
                            interpretation: this.calculateInterpretation(
                                focusedVital.centralVenousPressureLow,
                                focusedVital.centralVenousPressureHigh,
                                focusedVital[property]
                            )
                        });
                        break;
                    case 'height':
                        this.vitalList.push({
                            id: 5,
                            vital: 'Height',
                            reading: focusedVital[property],
                            unit: 'in',
                            referenceRange: '⏤',
                            interpretation: ''
                        });
                        break;
                    case 'weight':
                        this.vitalList.push({
                            id: 6,
                            vital: 'Weight',
                            reading: focusedVital[property],
                            unit: 'lbs',
                            referenceRange: '⏤',
                            interpretation: ''
                        });
                        break;
                    case 'pulse':
                        this.vitalList.push({
                            id: 7,
                            vital: 'Pulse',
                            reading: focusedVital[property],
                            unit: '/min',
                            referenceRange: `${focusedVital.pulseLow} - ${focusedVital.pulseHigh}`,
                            interpretation: this.calculateInterpretation(
                                focusedVital.pulseLow,
                                focusedVital.pulseHigh,
                                focusedVital[property]
                            )
                        });
                        break;
                    case 'respiration':
                        this.vitalList.push({
                            id: 8,
                            vital: 'Respiration',
                            reading: focusedVital[property],
                            unit: '/min',
                            referenceRange: `${focusedVital.respirationLow} - ${focusedVital.respirationHigh}`,
                            interpretation: this.calculateInterpretation(
                                focusedVital.respirationLow,
                                focusedVital.respirationHigh,
                                focusedVital[property]
                            )
                        });
                        break;
                    case 'pulseOximetry':
                        this.vitalList.push({
                            id: 9,
                            vital: 'Pulse Oximetry',
                            reading: focusedVital[property],
                            unit: '%',
                            referenceRange: `${focusedVital.pulseOximetryLow} - ${focusedVital.pulseOximetryHigh}`,
                            interpretation: this.calculateInterpretation(
                                focusedVital.pulseOximetryLow,
                                focusedVital.pulseOximetryHigh,
                                focusedVital[property]
                            )
                        });
                        break;
                    case 'pain':
                        this.vitalList.push({
                            id: 10,
                            vital: 'Pain',
                            reading: focusedVital[property],
                            unit: '⏤',
                            referenceRange: '⏤',
                            interpretation: ''
                        });
                        break;
                    case 'bmi':
                        this.vitalList.push({
                            id: 11,
                            vital: 'BMI',
                            reading: focusedVital[property],
                            unit: '⏤',
                            referenceRange: '⏤',
                            interpretation: ''
                        });
                        break;
                    default:
                        break;
                }
            }
        }
    }

    /**
     * @description Given a normal range for a specific vital reading, determine whether the patients vital reading is Norma, High, or Low.
     * @param low Bottom number of the range. If a reading is below this number, it is considered Low.
     * @param high Upper number of the range. If a reading is above this number, it is considered high.
     * @param value The current vital readings value.
     * @returns {string} 'High', 'Low' or 'Normal',
     */
    calculateInterpretation(low, high, value) {
        if (value > high) {
            return 'High';
        } else if (value < low) {
            return 'Low';
        }
        return 'Normal';
    }

    /**
     * @description Sorting method that gets called from the data table.
     * @param event Object fired off when a user clicks a header of a table.
     */
    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.vitalList];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.vitalList = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    /**
     * @description Given a sort field, and a sort direction, this function returns the proper sort function to order our table data.
     * @param field field to sort by
     * @param reverse Integer that determines sort direction.
     * @returns {function(*, *): *} sort function based on the sort direction and field passed in.
     * @see onHandleSort
     */
    sortBy(field, reverse) {
        const key = function (x) {
            return x[field];
        };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }
}
