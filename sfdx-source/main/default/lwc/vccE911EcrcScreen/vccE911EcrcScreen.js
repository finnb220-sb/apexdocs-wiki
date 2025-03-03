import { LightningElement, api } from 'lwc';
import { FlowNavigationFinishEvent } from 'lightning/flowSupport';
export default class VccE911ECRC_Screen extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api nonAddress;
    @api availableActions = [];
    @api isLoggedInBucherSuter;

    ecrcButtondisabled;

    connectedCallback() {
        if (this.isLoggedInBucherSuter) {
            this.ecrcButtondisabled = false;
        } else {
            this.ecrcButtondisabled = true;
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

    handleDone() {
        if (this.availableActions.find((action) => action === 'FINISH')) {
            // navigate to the next screen
            const navigateNextEvent = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }
}
