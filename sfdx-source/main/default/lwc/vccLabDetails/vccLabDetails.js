/* eslint no-unused-expressions: ["error", { "allowShortCircuit": true }] */
import { LightningElement, api } from 'lwc';
import { dateFormatter } from 'c/utils';

export default class VccLabDetails extends LightningElement {
    _selectedRecord;

    @api
    set selectedRecord(value) {
        this._selectedRecord = value;
    }

    get selectedRecord() {
        return this._selectedRecord;
    }

    /**
     * @description Format the Collected date for this Lab result into DD/MM/YYYY format.
     * @returns {string} The formatted date string or an empty string if the 'collected' date is not set.
     */

    get formattedDate() {
        return dateFormatter.formatDateTimeStringToMMDDYYYY(this.selectedRecord.collected);
    }

    @api
    setSelectedRecord(lab) {
        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
        this.selectedRecord = lab;
    }
}
