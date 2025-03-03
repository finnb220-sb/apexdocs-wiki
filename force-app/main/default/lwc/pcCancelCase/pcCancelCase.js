/**
 * @description JavaScript controller for the pcCancelCase Lightning Web Component - displays the Cancel Case Button on the PrC Case Record Page
 * & Loads a modal that requires the user to choose a Cancel Case Reason when the Cancel Case button is selected
 * @author      Booz Allen Hamilton
 */

import { LightningElement, wire, api, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import COMMENTS_FIELD from '@salesforce/schema/Case.PC_Specialist_Comments__c';
import ID_FIELD from '@salesforce/schema/PC_Case__c.Id';
import SUBSTATUS_FIELD from '@salesforce/schema/PC_Case__c.PC_Sub_Status__c';
import cancelCase from '@salesforce/apex/PC_CancelCaseController.cancelCase';

export default class PcCancelCase extends LightningElement {
    @api recordId;
    @track showConfirm = false;
    @track showSpinner = false;
    @track showPicklist = false;

    // The 4th Substatus value "Note Signing Error" is removed from the LWC modal and will instead be handled in the PC_Complete_Progress_Note_via_EHR flow
    PC_Sub_Status_Values = [
        { label: 'Opened in Error', value: 'Opened in Error' },
        { label: 'No Response from Consultant', value: 'No Response from Consultant' },
        { label: 'Other', value: 'Other' }
    ];

    WARNING_VARIANT = 'Warning';
    ERROR_VARIANT = 'Error';
    ERROR_CANCELLING_CASE_TITLE = 'Error Cancelling Case';
    ERROR_CANCELLING_CASE_MESSAGE = 'This case is already closed.';
    SUCCESS_VARIANT = 'Success';
    CASE_CLOSED_TITLE = 'Case Closed';
    CASE_CANCELLED_MESSAGE = 'Case cancelled.';
    REASON_CANCELLING_CASE_MESSAGE = 'Reason for Cancellation is Required When Cancelling a Case';

    /**
     * @description retrieves relevant fields on the PC_Case and Case objects.
     */

    @wire(getRecord, { recordId: '$recordId', fields: [COMMENTS_FIELD, SUBSTATUS_FIELD] })
    pcCaseRaw;

    substatusValue;
    cancelReason;

    /**
     * @description Handles getting the Case and returning its data
     */

    get pcCase() {
        return this.pcCaseRaw && this.pcCaseRaw.data ? this.pcCaseRaw.data : {};
    }

    /**
     * @description Handles getting the pcCase and returning the Sub Status field
     */
    get pcCaseSubStatus() {
        return this.pcCaseRaw?.data?.fields?.SUBSTATUS_FIELD;
    }

    /**
     * @description Prevents the PC_Case record from saving
     */

    get disableSave() {
        return !this.cancelReason;
    }

    /**
     * @description Prevents the PC_Case record from saving
     * @param event - Event handler for the Cancel PC Case No selection
     */

    handleChange(event) {
        this.cancelReason = event.target.value;
    }

    /**
     * @description Handles the reason the PC Case is being cancelled.  The value is being captured when the PC_Case__c.PC_Sub_Status__c value is selected.
     * @param event - Event handler for the Cancel PC Case Reason selection
     */
    handleReason(event) {
        this.substatusValue = event.target.value;
    }

    /**
     * @description Handles the selection of the Cancel Case LWC button and the visibility of the selection modal
     */

    handleCancelClicked() {
        this.showConfirm = true;
    }

    /**
     * @description Handles exiting the selection modal when the 'No' button is selected
     */

    handleCloseConfirm() {
        this.showConfirm = false;
        this.substatusValue = null;
    }

    /**
     * @description Gets the PC_Sub_Status__c picklist values for the modal when the 'Yes' button is selected
     */
    get cancelCaseReason() {
        return this.PC_Sub_Status_Values;
    }

    /**
     * @description Handles showing the picklist values of the PC_Sub_Status__c field when the 'Yes' button is selected
     */

    handleYesToCancelCase() {
        this.showPicklist = true;
    }

    /**
     * @description Updates the SubStatus field and calls the saveReason method to cancel the PC_Case
     */

    updateStatusAndSubStatus() {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[SUBSTATUS_FIELD.fieldApiName] = this.substatusValue;

        const recordInput = {
            fields: fields
        };

        if (!this.substatusValue) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.ERROR_CANCELLING_CASE_TITLE,
                    message: this.REASON_CANCELLING_CASE_MESSAGE,
                    variant: this.ERROR_VARIANT
                })
            );
        } else {
            updateRecord(recordInput).then((record) => {
                if (record.success) {
                    this.substatusValue(record);
                }
            });
            this.handleCancelCase();
        }
    }

    /**
     * @description Cancels the PC_Case, updates the status and displays the Case Cancelled success toast message or the error is caught and the Error message is displayed
     */

    handleCancelCase() {
        this.showSpinner = true;
        this.handleCloseConfirm();

        cancelCase({ caseId: this.recordId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.SUCCESS_VARIANT,
                        message: this.CASE_CANCELLED_MESSAGE,
                        variant: this.SUCCESS_VARIANT
                    })
                );
                getRecordNotifyChange([{ recordId: this.recordId }]);
            })
            .catch((error) => {
                let variant = this.ERROR_VARIANT;
                let title = this.ERROR_CANCELLING_CASE_TITLE;
                if (error.body && error.body.message.includes(this.ERROR_CANCELLING_CASE_MESSAGE)) {
                    variant = this.WARNING_VARIANT;
                    title = this.CASE_CLOSED_TITLE;
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: title,
                        message: error.body ? error.body.message : error.message,
                        variant: variant
                    })
                );
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }
}
