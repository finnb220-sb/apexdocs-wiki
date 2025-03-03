/**
 * @description This LWC is intended to be used as a screen action on the VCC_Progress_Note__c object.
 * - As a screen quick action, it renders in a modal UI.
 * - It provides a UI for updating 3 picklist fields on the progress note's parent Case record.
 * - It sets the Case record's VCC_Case_Outcome__c field to 'MSA/Scheduling'
 * - It checks the VCC_TransferToSchedulingButtonwasUsed__c box on the current progress note record.
 */
import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';

import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';

import PROGRESSNOTE_OBJECT from '@salesforce/schema/VCC_Progress_Note__c';
import PROGRESSNOTE_CASE_FIELD from '@salesforce/schema/VCC_Progress_Note__c.VCC_Case__c';
import PROGRESSNOTE_TRANSFERBUTTONWASUSED_FIELD from '@salesforce/schema/VCC_Progress_Note__c.VCC_TransferToSchedulingButtonwasUsed__c';

import CASE_OBJECT from '@salesforce/schema/Case';
import CASE_RECORDTYPEID_FIELD from '@salesforce/schema/Case.RecordTypeId';
import CASE_FOLLOWUPAPPTNEEDED_FIELD from '@salesforce/schema/Case.VCC_Follow_Up_Appt_Needed__c';
import CASE_APPTMODALITY_FIELD from '@salesforce/schema/Case.VCC_Recommended_Preferred_Appt_Modality__c';
import CASE_APPOINTMENTSERVICE_FIELD from '@salesforce/schema/Case.VCC_Appointment_Service__c';
import CASE_CASEOUTCOME_FIELD from '@salesforce/schema/Case.VCC_Case_Outcome__c';

const CASEOUTCOME_MSASCHEDULING = 'MSA/Scheduling';

const CASE_FIELDS = [
    CASE_FOLLOWUPAPPTNEEDED_FIELD,
    CASE_APPTMODALITY_FIELD,
    CASE_APPOINTMENTSERVICE_FIELD,
    CASE_CASEOUTCOME_FIELD
];

export default class VccProgressNoteTransferToScheduling extends LightningElement {
    /**
     * @description Indicates if UI is loading.
     * - Will show lightning-spinner
     * @type {boolean}
     */
    loading = false;

    /**
     * @description Indicates if all required fields in UI have values.
     * @type {boolean}
     */
    formIsValid = false;

    /**
     * @description Indicates if lightning-record-form and uiRecordApi are saving.
     * - Will show lightning-spinner
     * @type {boolean}
     */
    saving = false;

    /**
     * @description Indicates if Reset button should be visible.
     * - Toggled to true when save lightning-record-form save catches an error from Case field validations.
     * @type {boolean}
     */
    showResetButton = false;

    /**
     * @description Indicates if <lightning-messages> element should be hidden.
     * - We hide that element when user clicks Reset button.
     * @type {boolean}
     */
    hideErrorMessages = false;

    /**
     * @description Holds errors from save operations;
     */
    error;

    /**
     * @description Indicates if submit button should be enabled.
     * - Only enable the button if required fields have values, and we're not currently saving.
     * @return {boolean}
     */
    get enableSubmitButton() {
        return this.formIsValid && !this.saving;
    }

    /**
     * @description Flips `enableSubmitButton` to pass to `lightning-button` component's `disabled` property
     * @see enableSubmitButton
     * @return {boolean}
     */
    get disableSubmitButton() {
        return !this.enableSubmitButton;
    }

    /**
     * @description Indicates if spinner should be visible when UI is loading or save is happening.
     * @return {boolean}
     */
    get showSpinner() {
        return this.loading || this.saving;
    }

    /**
     * @description LWC quick actions (lightning__RecordAction) do not automatically receive a value for `recordId` public property. Set it manually.
     * @see https://developer.salesforce.com/docs/platform/lwc/guide/use-quick-actions-screen.html
     * @private
     */
    _recordId;
    @api set recordId(recordId) {
        if (recordId !== this._recordId) {
            this._recordId = recordId;
        }
    }
    get recordId() {
        return this._recordId;
    }

    /**
     * @description The object api name of the current record context.
     */
    @api objectApiName;

    /**
     * @description Wire the current progress note record to get its Case lookup field value
     */
    @wire(getRecord, { recordId: '$recordId', fields: [PROGRESSNOTE_CASE_FIELD] }) wiredProgressNoteRecord;

    /**
     * @description Derive the Case record Id from either the `recordId` (if we're showing this on a case for some reason), or from wired progress note's Case lookup value.
     * @return {*}
     */
    get caseRecordId() {
        return this.objectApiName === CASE_OBJECT.objectApiName
            ? this.recordId
            : getFieldValue(this.wiredProgressNoteRecord?.data, PROGRESSNOTE_CASE_FIELD);
    }

    /**
     * @description Returns API name of imported CASE_FOLLOWUPAPPTNEEDED_FIELD
     * @return {string}
     */
    get caseFollowUpApptNeededFieldApiName() {
        return CASE_FOLLOWUPAPPTNEEDED_FIELD.fieldApiName;
    }

    /**
     * @description Returns API name of imported CASE_APPTMODALITY_FIELD
     * @return {string}
     */
    get caseApptModalityFieldApiName() {
        return CASE_APPTMODALITY_FIELD.fieldApiName;
    }

    /**
     * @description Returns API name of imported CASE_APPOINTMENTSERVICE_FIELD
     * @return {string}
     */
    get caseApptServiceFieldApiName() {
        return CASE_APPOINTMENTSERVICE_FIELD.fieldApiName;
    }

    /**
     * @description wires the Case record we're going to be updating
     */
    @wire(getRecord, { recordId: '$caseRecordId', fields: CASE_FIELDS }) wiredCaseRecord;

    /**
     * @description Finds Case's RecordTypeId value.
     * - This is passed to the lightning-record-edit-form so that any picklists are filtered correctly by the Case's record type.
     * @return {any}
     */
    get caseRecordTypeId() {
        return getFieldValue(this.wiredCaseRecord?.data, CASE_RECORDTYPEID_FIELD);
    }

    /**
     * @description Set `loading` flag to true on first connection to DOM, to show spinner.
     */
    connectedCallback() {
        this.loading = true;
    }

    /**
     * @description If we hide the <lightning-messages> tag (via `hideErrorMessages`), un-hide it now.
     * - This resets the big red error message when user clicks Reset button.
     */
    renderedCallback() {
        if (this.hideErrorMessages) {
            this.hideErrorMessages = false;
        }
    }

    /**
     * @description Handles 'load' event from lightning-record-edit-form.
     * - Hides spinner
     * - Checks fields' initial validity to possibly disable the form's submit button.
     */
    handleLoad() {
        this.loading = false;
        this.checkValidity();
    }

    /**
     * @description Handles click of the Cancel button. Closes the modal without saving.
     */
    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    /**
     * @description Handles `submit` event from the lightning-record-edit-form.
     * - Shows spinner
     * - Hard-codes value of CASE_CASEOUTCOME_FIELD to CASEOUTCOME_MSASCHEDULING
     * - After doing so, re-fires form submission.
     * @param event
     */
    handleSubmit(event) {
        //block original submission
        event.preventDefault();
        this.saving = true;
        //set CASE_CASEOUTCOME_FIELD value in-flight
        event.detail.fields[CASE_CASEOUTCOME_FIELD.fieldApiName] = CASEOUTCOME_MSASCHEDULING;
        //submit programmatically
        this.refs.caseForm.submit(event.detail.fields);
    }

    /**
     * @description Handles `error` event from lightning-record-edit-form.
     * - Hides spinner
     * - Reveals Reset button.
     */
    handleError() {
        this.saving = false;
        this.showResetButton = true;
    }

    /**
     * @description Handles click of Reset button.
     * - Resets all fields in the form.
     * - Hides reset button.
     * - Hides <lightning-messages> element (which is immediately unhidden in `renderedCallback`)
     */
    handleReset() {
        this.template.querySelectorAll('lightning-input-field').forEach((field) => {
            field.reset();
        });
        this.showResetButton = false;
        this.hideErrorMessages = true;
        this.error = null;
    }

    /**
     * @description Handles `success` event from lightning-record-edit-form.
     * - Hides spinner
     * - Updates flag on progress note
     * - Closes modal
     * @see `updateProgressNote`
     */
    handleSuccess() {
        this.saving = true;
        this.updateProgressNote()
            .then(() => {
                // Close the modal window
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch((err) => {
                this.error = err;
            })
            .finally(() => {
                this.saving = false;
            });
    }

    /**
     * @description If we are on a progress note record (which we should be), updates record via `uiRecordApi.updateRecord`.
     * - Input for `updateRecord` comes from `progressNoteForUpdate` getter
     * @see progressNoteForUpdate
     * @return {Promise<unknown>}
     */
    updateProgressNote() {
        //If for some reason we've used this component somewhere other than a progress note quick action, don't try to update the progress note.
        if (this.objectApiName !== PROGRESSNOTE_OBJECT.objectApiName) {
            return Promise.resolve();
        }
        return updateRecord(this.progressNoteForUpdate);
    }

    /**
     * @description Builds RecordInput for `uiRecordApi.updateRecord` function.
     * @see https://developer.salesforce.com/docs/atlas.en-us.uiapi.meta/uiapi/ui_api_requests_record_input.htm
     * @return {{fields: {Id}}}
     */
    get progressNoteForUpdate() {
        const fields = {
            Id: this.recordId
        };
        fields[PROGRESSNOTE_TRANSFERBUTTONWASUSED_FIELD.fieldApiName] = true;
        return { fields };
    }

    /**
     * @description Evaluates if all required fields on UI have values.
     * - Using custom `required` && `value` evaluations instead of `field.reportValidity()` because we want to do it silently.
     *   - (The `lightning-input-field` component does not have a silent `checkValidity` function like `lightning-input` does.)
     */
    checkValidity() {
        this.formIsValid = [...this.template.querySelectorAll('lightning-input-field')].reduce((validSoFar, field) => {
            return validSoFar && (!field.required || (field.required && field.value));
        }, true);
    }
}
