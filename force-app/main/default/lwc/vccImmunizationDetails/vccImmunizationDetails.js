import { LightningElement, api } from 'lwc';
import { dateFormatter } from 'c/utils';

export default class VccImmunizationDetails extends LightningElement {
    _selectedRecord;

    @api
    get selectedRecord() {
        return this._selectedRecord;
    }

    set selectedRecord(value) {
        this._selectedRecord = value;
    }

    /**
     * @description sets the selected record to display
     * @param record HDR record to render
     */
    @api
    setSelectedRecord(record) {
        // need to supress this so that the modal remains reactive.
        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
        this.selectedRecord = record;
    }

    get dateOptions() {
        return dateFormatter.LIGHTNING_FORMATTED_DATE_OPTIONS;
    }
}
