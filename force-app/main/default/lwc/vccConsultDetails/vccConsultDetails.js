import { LightningElement, api } from 'lwc';
import { dateFormatter } from 'c/utils';

export default class VccConsultDetails extends LightningElement {
    _selectedRecord;

    columns = [
        {
            label: 'Date',
            type: 'date',
            initialWidth: 200,
            fieldName: 'activityEntryDate',
            typeAttributes: dateFormatter.LIGHTNING_FORMATTED_DATE_TIME_OPTIONS
        },
        { label: 'Activity', initialWidth: 200, fieldName: 'activity' },
        { label: 'Comment', fieldName: 'comment', wrapText: true }
    ];

    @api
    get selectedRecord() {
        return this._selectedRecord;
    }

    set selectedRecord(value) {
        this._selectedRecord = value;
    }

    /**
     * @description sets the selected consult to display
     * @param record Consult record to render
     */
    @api
    setSelectedRecord(record) {
        this._selectedRecord = record;
    }

    /**
     * @description Returns standardized date-only formatting options to pass as argument to lightning-formatted-date-time markup.
     * @return {{year: string, month: string, day: string, timeZone: string}}
     */
    get dateOptions() {
        return dateFormatter.LIGHTNING_FORMATTED_DATE_OPTIONS;
    }
}
