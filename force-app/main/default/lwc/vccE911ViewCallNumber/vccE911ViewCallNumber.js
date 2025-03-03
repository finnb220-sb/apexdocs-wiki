/**
 * @author Booz Allen
 * @description This is the controller class that handles the interactions on the E911 View/Call Number
 *
 * @extends LightningElement
 */
import { LightningElement, api } from 'lwc';
import { FlowNavigationFinishEvent } from 'lightning/flowSupport';
import getE911MetricRecord from '@salesforce/apex/VCC_E911ViewCallNumberController.getE911MetricRecord';
import * as helper from './vccE911ViewCallNumberHelper';

export default class VccE911ViewCallNumber extends LightningElement {
    isLoading = true;

    @api e911RecordId;
    @api isLoggedInBucherSuter = false;
    @api availableActions = [];

    address = {
        street: null,
        city: null,
        state: null,
        country: null,
        zipCode: null
    };
    e911TransferNumber;
    employeeCallBackNum;
    response;
    ecrcNum = helper.ecrcPhoneNumberConst;
    warnMsg;

    /**
     * @description on connect, retrieve transfer number
     */
    async connectedCallback() {
        try {
            await this.getE911MetricRecordCallout();
        } catch (e) {
            this.error = e;
        } finally {
            if (this.response) {
                ({
                    VCC_Street__c: this.address.street,
                    VCC_City__c: this.address.city,
                    VCC_Zip_Code__c: this.address.zipCode,
                    VCC_State__c: this.address.state,
                    VCC_Country__c: this.address.country,
                    VCC_Temporary_e911_Number__c: this.e911TransferNumber,
                    VCC_Call_Back_Number__c: this.employeeCallBackNum
                } = this.response);
            } else {
                this.error = 'Data did not return from getting updated me911 metric from Intrado API call';
            }
            this.isLoading = false;
        }
    }

    /**
     * @description on render, check if softphone is connected
     */
    renderedCallback() {
        if (!this.isLoading) {
            if (this.isLoggedInBucherSuter) {
                this.warnMsg = helper.dialWithSoftphoneMsg;
            } else {
                this.warnMsg = helper.dialManuallyMsg;
                this.template.querySelector('lightning-button[data-name="placeE911Button"]').disabled = 'true';
            }
        }
    }

    /**
     * @description Retrieves the e911 Transfer Number and e911 Metric record data
     */
    async getE911MetricRecordCallout() {
        try {
            //getTransferNumber callout that returns an e911 Metric object with the temporary e911 populated
            this.response = await getE911MetricRecord({
                recordId: this.e911RecordId
            });
        } catch (error) {
            this.error = error;
        }
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
     * @description handle the copy button
     */
    doCopy() {
        navigator.clipboard.writeText(this.e911TransferNumber);
    }

    /**
     * @description handles the placeE911 button action
     */
    handlePlaceE911() {
        this.dispatchFlowFinishEvnt();
    }

    /**
     * @description handles the cancel button action
     */
    handleCancel() {
        this.dispatchFlowFinishEvnt();
    }

    /**
     * @description dispatches a flow finish event to move forward in a flow context
     */
    dispatchFlowFinishEvnt() {
        if (this.availableActions.find((action) => action === 'FINISH')) {
            const finEvnt = new FlowNavigationFinishEvent();
            this.dispatchEvent(finEvnt);
        }
    }
}
