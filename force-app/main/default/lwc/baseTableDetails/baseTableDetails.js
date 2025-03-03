import { api, LightningElement } from 'lwc';

export default class BaseTableDetails extends LightningElement {
    @api total;
    @api sortedBy;

    get displayText() {
        //while we're updating the onload sort behavior, at least fall back to showing "Sorted By Date" when no value is passed to this.sortedBy
        return `${this.total} items \u00B7 Sorted By ${this.sortedBy ? this.sortedBy : 'Date'}`;
    }
}
