import { LightningElement, api } from 'lwc';

export default class VccAppointmentDetails extends LightningElement {
    showIt = true;
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
}
