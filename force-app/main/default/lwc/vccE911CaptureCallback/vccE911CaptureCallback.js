import { LightningElement, api } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import queryE911Record from '@salesforce/apex/VCC_E911CaptureCallbackController.queryE911Record';
import getBSConfigAssignedUserRecord from '@salesforce/apex/VCC_E911CaptureCallbackController.getBSConfigAssignedUserRecord';
import getCustomSettingsValue from '@salesforce/apex/VCC_E911CaptureCallbackController.getCustomSettingsValue';
import getIntegrationApi from 'c/connectsIntegrationApiSvc';
export default class VccE911CaptureCallback extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api availableActions = [];

    /**
     * @description Getter for
     * @return boolean for terminating flow
     */
    @api
    get terminateFlow() {
        return this._terminateFlow;
    }
    @api
    get isBucherSuter() {
        return this.isLoggedInBucherSuter;
    }

    cnxIntegrationAPI;
    error;
    _terminateFlow = false;

    isBSUser = false;
    isLoggedInBucherSuter = false;
    phone = '';
    isGlobalLoading = true;

    scriptsLoaded = false;

    run() {
        this.cnxIntegrationAPI.onWorkItemCreate = (event) => {
            if (event.item.Channel === 'VOICE') {
                console.log('onWorkItemCreate');
                // Insert your code here
            }
        };
        this.cnxIntegrationAPI.onWorkItemConnect = (event) => {
            if (event.item.Channel === 'VOICE') {
                console.log('onWorkItemConnect');
                // Insert your code here
            }
        };
        this.cnxIntegrationAPI.onAgentStateChange = (event) => {
            if (event.channelType === 'VOICE') {
                console.log('onAgentStateChange');
                // Insert your code here
            }
        };
        let ctiData = this.cnxIntegrationAPI.getCtiData();
        if (ctiData) {
            //set the value to autopopulate on the component
            this.phone = ctiData.MobileNumber;
            //set value of logged in to true
            this.isLoggedInBucherSuter = true;
        } else {
            console.log('No data found');
        }
    }

    renderedCallback() {
        let _this = this;
        if (getCustomSettingsValue()) {
            getBSConfigAssignedUserRecord().then((result) => {
                this.isBSUser = result;
                if (this.isBSUser) {
                    // Retrieve Connects Integration API object
                    // First parameter "this" must be a valid LWC (must extend LightningElement)
                    // Second parameter is the callback, it will run when the API is initialized
                    // (substitutes the waitReady() request)
                    getIntegrationApi(this, function (el, err) {
                        if (el !== null) {
                            _this.cnxIntegrationAPI = el;
                            _this.run();
                        } else {
                            // An error occurred: the static resource may not exist or the library is not readable
                            console.log('Error: ' + err);
                        }
                    });
                }
                this.error = undefined;
            });
        }
        this.isGlobalLoading = false;
    }

    handleClose() {
        this._terminateFlow = true;
        if (this.availableActions.find((action) => action === 'NEXT')) {
            // navigate to the next screen
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }

    validateInput() {
        let callBackNum = this.template.querySelector('lightning-input[data-name="callBackNum"]');
        return callBackNum.reportValidity();
    }

    async handleNext() {
        var inputObj;
        var inputId;
        if (!this.validateInput()) {
            return;
        }
        if (this.objectApiName === '') {
            inputObj = null;
        } else {
            inputObj = this.objectApiName;
        }
        if (this.recordId === '') {
            inputId = null;
        } else {
            inputId = this.recordId;
        }
        await queryE911Record({
            objectAPI: inputObj,
            recordClickedOn: inputId,
            callBackNumber: this.template.querySelector('lightning-input[data-name="callBackNum"]').value
        }).catch(() => {
            this.nebulaLogger('Error attempted to create an e911 record');
        });

        if (this.availableActions.find((action) => action === 'NEXT')) {
            // navigate to the next screen
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }

    nebulaLogger(incomingError) {
        const logger = this.template.querySelector('c-logger');
        if (!logger) return;
        logger.error(JSON.stringify(incomingError));
        logger.saveLog();
    }
}
