import { LightningElement, api, wire } from 'lwc';
import HideLightningHeader from '@salesforce/resourceUrl/NoHeader';
import { loadStyle } from 'lightning/platformResourceLoader';
import getCTAccessSecurity from '@salesforce/apex/VCC_ClearTriageWrapperController.getCTAccessSecurity';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Division from '@salesforce/schema/User.Division';
import userId from '@salesforce/user/Id';

/**
 * This component is a wrapper around the clearTriage component and the patientDemo component illustrating
 * how ClearTriage can be displayed alongside a customer-owned component showing patient information and
 * triage encounter details.
 *
 * For demonstration purposes, this component has a hard-coded access key. In a production setting, this
 * key would be treated as a secret, stored securely, and passed into the ClearTriage component at runtime.
 *
 * The handleDataReceived method defines the behavior when the ClearTriage user clicks the "Finish Call" button.
 * This method is passed to the ClearTriage component as a callback function. The data structure of event.detail
 * is described in the JSON Call Note document provided by ClearTriage.
 */

export default class VccClearTriageWrapper extends LightningElement {
    @api ctCallData;
    @api protocols;
    @api disposition;
    @api recordId;

    _ctCallData;
    _protocols;
    _disposition;

    srcUrl;
    ctAccessKey;
    userVisn;
    showTriageButton = true;

    /**
     * @description using the record Id will retrieve the provided fields from the user's record
     * @param {Id} recordId the user's record id
     * @param {String} fields the fields to retrieve from the user's record
     * @returns {String} the value of the field from the user's record
     */
    @wire(getRecord, { recordId: userId, fields: [Division] })
    wiredUserData({ error, data }) {
        if (error) {
            this.logger('User Data Error ' + JSON.stringify(error));
        } else if (data) {
            if (data.fields.Division.value) {
                this.userVisn = data.fields.Division.value;
            } else {
                this.userVisn = 'No VISN';
            }
        }
    }

    /**
     * @description pulls the access security URL and key needed for ClearTriage
     */
    @wire(getCTAccessSecurity, { visn: '$userVisn' })
    wiredCTAccessSecurity({ error, data }) {
        if (error) {
            this.logger('External Data Error' + JSON.stringify(error));
        } else if (data) {
            this.srcUrl = data.ctAccessUrl;
            this.ctAccessKey = data.ctAccessKey;
        }
    }

    get dataLoaded() {
        return this.srcUrl && this.ctAccessKey && this.userVisn && !this.showTriageButton;
    }

    /**
     * @description once the response is received from the iframe, the data is then updated in the values which will later be placed in the record
     * @param {*} event
     */
    handleDataReceived(event) {
        this._ctCallData = '⠀\n\rDecision Support Tool Used: ClearTriage \n\r' + event.detail.callSummaryText;
        this._protocols = event.detail.callSummary.protocols?.map((protocol) => protocol.title).join(', ') || '';
        this._disposition = event.detail.callSummary.callDisposition?.title || '';

        updateRecord({
            fields: {
                Id: this.recordId,
                VCC_Triage_Complete__c: true,
                VCC_Triage_Note__c: this._ctCallData,
                VCC_Chief_Complaint__c: this._protocols
            }
        })
            .then(() => {})
            .catch((error) => {
                let errorMsgs = ['Error Updating Record'];

                if (error.body?.message) {
                    errorMsgs = [error.body.message];
                }

                if (error.body?.output?.errors) {
                    errorMsgs = [];
                    error.body.output.errors.forEach((errorFound) => {
                        errorMsgs.push(errorFound.message);
                    });
                }

                errorMsgs.forEach((errorFound) => {
                    const errorEvent = new ShowToastEvent({
                        title: 'Error',
                        message: errorFound,
                        variant: 'error',
                        mode: 'sticky'
                    });

                    this.dispatchEvent(errorEvent);
                });
            });
    }

    /**
     * @description Fetches the dependent custom nebula logger LWC and that will be used for logging
     * @param {*} incomingError - object/string that represents the error that has occured
     */
    logger(incomingError) {
        const logger = this.template.querySelector('c-logger');
        if (!logger) {
            return;
        }
        logger.error(JSON.stringify(incomingError));
        logger.saveLog();
    }

    /**
     * @description after clicking Start, set show button to false
     */
    onStartTriage() {
        this.showTriageButton = false;
    }

    /**
     * @description on location change from aura component, set show button to true
     */
    @api
    locationChange() {
        this.showTriageButton = true;
    }

    /**
     * @description pull in the styling for this component
     */
    connectedCallback() {
        loadStyle(this, HideLightningHeader);
    }
}
