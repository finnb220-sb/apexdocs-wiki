/**
 * @description Error Display Component for Omniscripts to showcase an Error Message to end-users and to log error with Nebula Logger
 * @author Booz Allen Hamilton
 * @since 4/4/2024
 */
import { LightningElement, api } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';
import LoggerMixin from 'c/loggerMixin';

export default class VccLoggerTesting extends OmniscriptBaseMixin(LoggerMixin(LightningElement)) {
    //Omni properties - must be lowercase
    @api omnierrormessage;
    @api errortype;
    //////////////////////

    /**
     * @description connectedCallback will create a Nebula Logger Error log
     * and log information in regards to error message and Error Type
     **/
    connectedCallback() {
        this.Logger.error(`An Error occured: ${this.omnierrormessage}, Action: ${this.errortype}`);
        this.Logger.saveLog();
    }
}
