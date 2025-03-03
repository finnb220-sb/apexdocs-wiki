import { LightningElement, api } from 'lwc';
import { dateFormatter } from 'c/utils';

export default class VccRadiologyDetails extends LightningElement {
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
     * @param record Consult record to render
     */
    @api
    setSelectedRecord(record) {
        // need to supress this so that the modal remains reactive.
        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
        this.selectedRecord = record;
    }

    /**
     * @description this getter returns the content of the first document (if present) from the selected record.
     * @return {string}
     */
    get reportContent() {
        return this.selectedRecord?.documents &&
            Array.isArray(this.selectedRecord.documents) &&
            this.selectedRecord.documents.length >= 1 &&
            this.selectedRecord.documents[0] &&
            this.selectedRecord.documents[0].content
            ? this.selectedRecord.documents[0].content
            : 'Patient does not have this data';
    }

    /**
     * @description Returns standardized date and time formatting options to pass as argument to lightning-formatted-date-time markup.
     * @return {{year: string, month: string, day: string, timeZone: string}}
     */
    get dateTimeOptions() {
        return dateFormatter.LIGHTNING_FORMATTED_DATE_TIME_OPTIONS;
    }
}
