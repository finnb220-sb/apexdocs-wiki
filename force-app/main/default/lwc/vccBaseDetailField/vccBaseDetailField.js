/**
 * @description
 * @author Booz Allen Hamilton
 * Created by Kyle Knab on 1/6/2025.
 */

import { LightningElement, api } from 'lwc';
import { dateFormatter } from 'c/utils';

export default class VccBaseDetailField extends LightningElement {
    @api label;
    /**
     * A value to be displayed. Composer can assign this property, or can fill the default slot with its own markup
     */
    @api value;
    @api type = 'text'; //a data type (default 'text') for the value. Pass 'date' or 'date-local' to force usage of lightning-formatted-date-time markup

    /**
     * @description Indicates if this field's value should be formatted as a date
     * @returns {boolean}
     */
    get formatAsDate() {
        return dateFormatter.DATATABLE_DATE_TYPES.includes(this.type);
    }

    /**
     * Returns appropriate options for lightning-formatted-date-time markup, based on this.type
     * - a type of 'date-local' will return an options object without hour and minute properties
     * - a type of 'date' will return an options object WITH hour and minute properties, thus rendering a time stamp in the UI
     * @return {{year: string, month: string, day: string, timeZone: string, hour: string, minute: string}|{year: string, month: string, day: string, timeZone: string}|null}
     */
    get dateFormattingOptions() {
        if (this.type === dateFormatter.DATE_LOCAL) {
            return dateFormatter.LIGHTNING_FORMATTED_DATE_OPTIONS;
        }
        return this.type === dateFormatter.DATE ? dateFormatter.LIGHTNING_FORMATTED_DATE_TIME_OPTIONS : null;
    }
}
