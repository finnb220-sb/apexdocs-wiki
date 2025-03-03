import { LightningElement, api } from 'lwc';
import { dateFormatter } from 'c/utils';
export default class VccAllergyDetails extends LightningElement {
    @api commentColumns;
    _selectedRecord;
    get selectedRecordComments() {
        return this.selectedRecord?.comments ?? [];
    }

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
        this._selectedRecord = record;
    }

    /**
     * Returns standardized date-only formatting options to pass as argument to lightning-formatted-date-time markup.
     * @returns {{year: string, month: string, day: string, timeZone: string, hour: string, minute: string}}
     */
    get dateTimeOptions() {
        return dateFormatter.LIGHTNING_FORMATTED_DATE_TIME_OPTIONS;
    }
}
