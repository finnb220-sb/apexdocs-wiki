import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import ACCT_VVC_URL from '@salesforce/schema/Account.comm_VVC_URL__c';
import CASE_VVC_URL from '@salesforce/schema/Case.comm_VVC_URL__c';
//will need to add more imports if more objects are added in

export default class Comm_VVCCallViewer extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api forceOpenNewWindow;
    @wire(getRecord, { recordId: '$recordId', fields: [ACCT_VVC_URL] }) accountRec; //retrieves relevant objects and fields
    @wire(getRecord, { recordId: '$recordId', fields: [CASE_VVC_URL] }) caseRec;
    //will need to add more wires if more objects are added in

    inputURL;
    urlLoaded = false;
    hasError = false;
    startIframe = false;
    startPopout = false;
    popoutWindow;
    errorMessage;

    get vvcUrl() {
        //returns a url based on the object
        var dataInput;
        var fieldInput;
        var returnedField;

        if (this.objectApiName === 'Account') {
            //add more/rework for more added objects
            dataInput = this.accountRec.data; //pulled from 11
            fieldInput = ACCT_VVC_URL; //pulled from 4
        } else if (this.objectApiName === 'Case') {
            dataInput = this.caseRec.data; //pulled from 12
            fieldInput = CASE_VVC_URL; //pulled from 5
        }

        returnedField = getFieldValue(dataInput, fieldInput);

        if (returnedField !== undefined && returnedField !== null) {
            //check for empty fields first
            if (this.validateUrl(returnedField, true) === true) {
                //check validation
                return returnedField;
            }
        }
        return '';
    }

    handleStart() {
        //queries for an input url, validates it, then flips to the active call state
        var submittedUrl = this.template.querySelector("[data-id='urlInput']").value;
        var popoutCheck = this.template.querySelector("[data-id='popoutCheckbox']").checked;

        if (this.validateUrl(submittedUrl, false) === true) {
            //check validation
            this.inputURL = submittedUrl;
            this.urlLoaded = true;
            this.hasError = false;
            this.errorMessage = '';

            if (popoutCheck) {
                let windowFeatures = 'menubar=no,resizable=yes,scrollbars=yes';
                // eslint-disable-next-line no-restricted-globals
                windowFeatures = 'width=' + screen.width;
                // eslint-disable-next-line no-restricted-globals
                windowFeatures += ',height=' + screen.height;
                this.popoutWindow = window.open(this.inputURL, '_blank', windowFeatures);
                this.startPopout = true;
            } else {
                this.startIframe = true;
            }
        }
    }

    refocusWindow() {
        //this brings the opened window back to the front
        this.popoutWindow.focus();
    }

    validateUrl(incomingUrl, firstLaunch) {
        if (incomingUrl.includes('veteran.apps.va.gov') || incomingUrl.includes('care.va.gov')) {
            //check for VVC now base urls
            if (incomingUrl.startsWith('https://')) {
                //make sure the url starts appropriately
                return true;
            }

            if (firstLaunch) {
                this.errorMessage =
                    'The link saved on the Record seems to be improper. Please ensure that a valid URL is supplied and that it is formatted correctly.';
            } else {
                this.errorMessage =
                    'The submitted URL seems to be improper. Please ensure that you submitted a valid URL that it is formatted correctly.';
            }

            this.hasError = true;
        } else {
            if (firstLaunch) {
                this.errorMessage = 'The link saved on the Record is not for the VVC Now, please supply a valid link.';
            } else {
                this.errorMessage = 'The submitted URL is not for the VVC Now, please supply a valid link.';
            }

            this.hasError = true;
        }
        return false;
    }

    endCallAction() {
        //resets the booleans, flipping the component back to starting state
        this.urlLoaded = false;
        this.hasError = false;
        this.startIframe = false;
        this.startPopout = false;
        this.popoutWindow.close();
    }
}
