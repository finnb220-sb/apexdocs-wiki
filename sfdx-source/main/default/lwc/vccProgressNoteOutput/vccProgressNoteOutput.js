/* eslint-disable no-console */
import { api, LightningElement } from 'lwc';
import LoggerMixin from 'c/loggerMixin';

export default class VccProgressNoteOutput extends LoggerMixin(LightningElement) {
    @api
    set pnJson(val) {
        if (val && typeof val === 'string') {
            let parsedJson;
            try {
                //fix <br> tag displaying in address
                let newVal = val.replace('<br>', '');
                parsedJson = JSON.parse(newVal);
            } catch (e) {
                console.warn(e);
            }
            if (parsedJson && typeof parsedJson === 'object') {
                this.progressNoteSections = parsedJson;
            }
        }
        /**this.Logger.debug('...Ending Progress Note Error Logging...');
        this.Logger.saveLog(); **/
    }
    get pnJson() {
        return this.progressNoteSections;
    }

    progressNoteSections;
}
