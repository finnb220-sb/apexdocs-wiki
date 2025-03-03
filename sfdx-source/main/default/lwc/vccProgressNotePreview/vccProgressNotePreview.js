/**
 * @description this LWC queries the VCC_Progress_Note__c with the given recordId, using the 'Full' page layout (as configured for the record's record type).
 * It then parses the retrieved data and renders it in the HTML as a preview of the progress note's content.
 * Subscribes to vccUIUpdate LMS channel to refresh its data when CSSRS screening is complete.
 */

import { LightningElement, wire, api } from 'lwc';
import vccUIUpdate from '@salesforce/messageChannel/vccUIUpdate__c';
import { subscribe, unsubscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import { getRecord } from 'lightning/uiRecordApi';
import parseLWC from '@salesforce/apex/VCC_Adapter_NoteToVdif.parseLWC';
import { RefreshEvent } from 'lightning/refresh';
import LoggerMixin from 'c/loggerMixin';

const KEYUP = 'keyup';

//a list of LWCs that might notify fire vccUIUpdate events to which this LWC should react.
const NOTIFYING_COMPONENTS = ['vccColumbiaProtocol'];

export default class VccProgressNotePreview extends LoggerMixin(LightningElement) {
    wiredResults;
    isModalOpen = false;

    subscription = null;
    @wire(MessageContext) messageContext;

    /**
     * @description This property is no longer used by this component, because this component wires its own data and sets progressNotePreviewJson.
     * Leaving in place because some usages of this LWC might still reference this public property and try to pass a value to it.
     */
    @api progressNoteJson;
    progressNotePreviewJson;

    @api recordId;

    /**
     * @description retrieves the current Progress Note and parses the fields and values on the record so that it can be displayed on the Progress Note Preview
     */
    @wire(getRecord, { recordId: '$recordId', layoutTypes: ['Full'] })
    wiredRecord(result) {
        this.wiredResults = result;
        if (this.wiredResults?.data) {
            this.dispatchEvent(new RefreshEvent());
            parseLWC({ pnId: this.recordId, pnRtId: this.wiredResults.data.recordTypeId })
                .then((parseResult) => {
                    this.progressNotePreviewJson = this.transformText(parseResult[0]);
                })
                .catch((error) => {
                    this.Logger.error('Error in parseLWC: ', error);
                });
        } else if (this.wiredResults?.error) {
            this.Logger.error('Error retrieving record: ', this.wiredResults.error);
        }
        this.Logger.saveLog();
    }

    /**
     * @description Replaces pipes with carriage returns, and removes html breaks
     * @param input {String} any text
     * @returns {String} - the transformed input
     */
    transformText(input = '') {
        if (!input) {
            return input;
        }
        let formattedInput = input.replace(/\|/g, '\n'); // Replace | with \n
        formattedInput = formattedInput.replace(/<br>/g, ''); // Remove <br>
        return formattedInput;
    }

    /**
     * @description set up listener(s) and subscription(s)
     */
    connectedCallback() {
        document.addEventListener(KEYUP, this.handleKeyUp.bind(this));
        this.subscribeToUiUpdateChannel();
    }
    /**
     * @description break down listener(s) and subscription(s)
     */
    disconnectedCallback() {
        window.removeEventListener(KEYUP, this.handleKeyUp);
        this.unsubscribeFromUiUpdateChannel();
    }

    /**
     * @description Subscribes to vccUIUpdate LMS channel
     */
    subscribeToUiUpdateChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                vccUIUpdate,
                (message) => {
                    this.handleUiUpdateMessage(message, this);
                },
                { scope: APPLICATION_SCOPE }
            );
        }
    }
    /**
     * @description A message handler... Checks message contents and if valid, fires RefreshEvent, to incorporate CSSRS screening results into PN preview data.
     * @param message message from LMS channel
     * @param lwc this LWC, passed in as 'this'
     */
    handleUiUpdateMessage(message = {}, lwc) {
        if (NOTIFYING_COMPONENTS.includes(message.componentName) && message.recordId === lwc.recordId) {
            if (lwc && typeof lwc.dispatchEvent === 'function') {
                lwc.dispatchEvent(new RefreshEvent());
            }
        }
    }
    /**
     * @description unsubscribes from vccUIUpdate LMS channel
     */
    unsubscribeFromUiUpdateChannel() {
        if (this.subscription) {
            unsubscribe(this.subscription);
            this.subscription = null;
        }
    }
    /**
     * @description opens modal
     */
    handleExpandClick() {
        this.isModalOpen = true;
    }
    /**
     * @description closes modal
     */
    handleCloseClick() {
        this.isModalOpen = false;
    }
    /**
     * @description checks if escape key was pressed and closes modal.
     * @param event a `KeyboardEvent`
     */
    handleKeyUp(event) {
        if (event?.keyCode === 27) {
            this.handleCloseClick();
        }
    }
}
