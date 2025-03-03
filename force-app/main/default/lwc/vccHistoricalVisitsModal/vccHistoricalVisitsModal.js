import { api, LightningElement } from 'lwc';

export default class VccHistoricalVisitsModal extends LightningElement {
    _selectedRecord;

    @api
    get selectedRecord() {
        return this._selectedRecord;
    }

    set selectedRecord(value) {
        this._selectedRecord = value;
    }

    /**
     * @description sets the selected visit to display
     * @param record Visit record to render
     */
    @api
    setSelectedRecord(record) {
        // need to supress this so that the modal remains reactive.
        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
        this.selectedRecord = record;
    }
}