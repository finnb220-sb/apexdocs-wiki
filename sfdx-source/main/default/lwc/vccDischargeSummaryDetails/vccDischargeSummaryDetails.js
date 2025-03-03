/**
 * @description When a Discharge Summary Record is selected, this component will appear in a modal to provide additional details of that discharge
 *
 */
import { LightningElement, api } from 'lwc';

export default class VccDischargeSummaryDetails extends LightningElement {
    _selectedRecord;

    dischargeSummarySelected;
    recordId;
    vtcArgs;

    argsWithEncounterId;

    visitUid = '';
    hasBeenIntialized = false;

    renderedCallback() {
        if (this.dischargeSummarySelected == null || typeof this.dischargeSummarySelected != 'object') {
            return;
        }
        if (this.hasBeenIntialized) {
            return;
        }
        this.visitUid = this.dischargeSummarySelected.encounterId;
        this.argsWithEncounterId = {
            startDate: this.dischargeSummarySelected.dateCreated,
            stopDate: this.dischargeSummarySelected.dateCreated,
            icn: this.vtcArgs.icn,
            uid: this.dischargeSummarySelected.encounterId
        };
        this.hasBeenIntialized = true;
    }

    /**
     * @description Receives the selected discharge summary record from healthDataService.handleRowSelected
     * @param value - the discharge summary record selected.
     */
    set selectedRecord(value) {
        if (value) {
            this._selectedRecord = value;
            this.setDischargeProperties();
        }
    }
    @api
    get selectedRecord() {
        return this._selectedRecord;
    }

    /**
     * @description sets the selected consult to display
     * @param record Discharge record to render
     */
    @api
    setSelectedRecord(record) {
        this.dischargeSummarySelected = record;
    }

    /**
     * @description sets the html properties for displaying content on the modal
     */
    setDischargeProperties() {
        this.dischargeSummarySelected = this._selectedRecord?.dischargeSummarySelected;
        this.vtcArgs = this._selectedRecord?.vtcArgs;
        this.recordId = this._selectedRecord?.recordId;
    }
}
