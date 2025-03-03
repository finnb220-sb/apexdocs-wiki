import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { getRecord, updateRecord, deleteRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import getCallTrackingList from '@salesforce/apex/VCC_ProgressNoteController.getCallTrackingList';
import ID_FIELD from '@salesforce/schema/VCC_Call_Tracking__c.Id';
import CALLDATETIME_FIELD from '@salesforce/schema/VCC_Call_Tracking__c.VCC_Call_Date_Time__c';
import MESSAGELEFTFORPATIENT_FIELD from '@salesforce/schema/VCC_Progress_Note__c.VCC_Message_left_for_patient__c';
import PATIENTNOSHOW_NOWELFARECHECK_FIELD from '@salesforce/schema/VCC_Progress_Note__c.VCC_Patient_No_Show_no_welfare_check__c';
import PATIENTNOSHOW_WELFARECHECK_FIELD from '@salesforce/schema/VCC_Progress_Note__c.VCC_Patient_was_a_No_Show__c';
import ASSOCIATEDAPPOINTMENT_FIELD from '@salesforce/schema/VCC_Progress_Note__c.VCC_Associated_Appointment__c';
import TIME_ZONE from '@salesforce/i18n/timeZone';

const columns = [
    {
        label: 'Call Date/Time',
        fieldName: 'VCC_Call_Date_Time__c',
        type: 'date',
        typeAttributes: {
            year: 'numeric',
            month: 'numeric',
            day: 'numeric',
            hour: 'numeric',
            minute: 'numeric',
            timeZone: TIME_ZONE
        },
        editable: false,
        hideDefaultActions: true,
        wrapText: true
    },
    {
        label: 'Date/Time Timestamp Entered',
        fieldName: 'CreatedDate',
        type: 'date',
        typeAttributes: {
            year: 'numeric',
            month: 'numeric',
            day: 'numeric',
            hour: 'numeric',
            minute: 'numeric',
            timeZone: TIME_ZONE
        },
        editable: false,
        hideDefaultActions: true,
        wrapText: true
    }
];

const FIELDS = ['VCC_Progress_Note__c.VCC_Associated_Appointment__c'];

export default class VccProgressNoteAppointment extends LightningElement {
    messageLeftForPatientField = MESSAGELEFTFORPATIENT_FIELD;
    patientNoShow_NoWelfareCheckField = PATIENTNOSHOW_NOWELFARECHECK_FIELD;
    patientNoShow_WelfareCheckField = PATIENTNOSHOW_WELFARECHECK_FIELD;
    associatedAppointmentField = ASSOCIATEDAPPOINTMENT_FIELD;

    objectApiNameCT = 'VCC_Call_Tracking__c';
    objectApiNamePN = 'VCC_Progress_Note__c';
    // progress note record id
    @api recordId;
    // call tracking records
    wiredRecords;
    data;
    columns = columns;
    draftValues = [];
    modalTitle = 'Unsuccessful Call Attempts/ No Show';
    associatedAppointment = '';
    error;

    // spinning logic
    wireCTSpinning = true;
    wirePNSpinning = true;
    form1Spinning = true;
    form2Spinning = true;
    submitSpinning = false;
    get isModalSpinning() {
        return (
            this.wireCTSpinning ||
            this.wirePNSpinning ||
            this.form1Spinning ||
            this.form2Spinning ||
            this.submitSpinning
        );
    }
    callTrackingSpinning = false;

    handleForm1Load() {
        this.form1Spinning = false;
    }
    handleForm2Load() {
        this.form2Spinning = false;
    }

    stopSpinning() {
        this.wireCTSpinning = false;
        this.wirePNSpinning = false;
        this.form1Spinning = false;
        this.form2Spinning = false;
        this.submitSpinning = false;
        this.callTrackingSpinning = false;
    }

    initialRender = true;
    renderedCallback() {
        const element = this.template.querySelector("[data-name='iptVCC_Call_Date_Time__c']");
        if (element) {
            element.value = new Date().toISOString();
        }
        if (this.initialRender) {
            this.initialRender = false;
            this.open();
        }
    }

    @wire(getCallTrackingList, { recordId: '$recordId' })
    wiredCallTrackingRecords(value) {
        this.wiredRecords = value;
        const { data, error } = value;
        if (data) {
            this.data = data;
            this.wireCTSpinning = false;
            this.callTrackingSpinning = false;
        } else if (error) {
            this.error = error.body.message;
            this.wireCTSpinning = false;
            this.callTrackingSpinning = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error returning Call Tracking records.',
                    message: this.error,
                    variant: 'error',
                    mode: 'sticky'
                })
            );
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    progressNote({ error, data }) {
        if (data) {
            this.associatedAppointment = data.fields.VCC_Associated_Appointment__c.value;
            this.wirePNSpinning = false;
        } else if (error) {
            this.error = error.body.message;
            this.wirePNSpinning = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error returning Progress Note record.',
                    message: this.error,
                    variant: 'error',
                    mode: 'sticky'
                })
            );
        }
    }

    // call tracking submit
    handleSubmitCT(event) {
        event.preventDefault(); // stop the form from submitting
        this.callTrackingSpinning = true;
        // populate master-detail parent record automatically
        const fields = event.detail.fields;
        fields.VCC_Progress_Note__c = this.recordId;
        this.template.querySelectorAll('lightning-record-edit-form').forEach((element) => {
            let elementId = element.id;
            if (elementId.includes('form1')) {
                element.submit(fields);
            }
        });
    }

    // call tracking success
    handleSuccessCT() {
        refreshApex(this.wiredRecords);

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Call tracking created successfully.',
                variant: 'success'
            })
        );
    }

    // call tracking handle inline editing
    handleSave(event) {
        this.callTrackingSpinning = true;
        const fields = {};
        fields[ID_FIELD.fieldApiName] = event.detail.draftValues[0].Id;
        fields[CALLDATETIME_FIELD.fieldApiName] = event.detail.draftValues[0].VCC_Call_Date_Time__c;
        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Call Tracking updated.',
                        variant: 'success'
                    })
                );
                // Display fresh data in the datatable
                return refreshApex(this.wiredRecords).then(() => {
                    // Clear all draft values in the datatable
                    this.draftValues = [];
                });
            })
            .catch((error) => {
                this.error = error.body.message;
                this.callTrackingSpinning = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating or reloading record.',
                        message: this.error,
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
            });
    }

    // call tracking datatable action
    handleRowAction(event) {
        let actionName = event.detail.action.name;
        switch (actionName) {
            case 'delete':
                this.deleteCallTrackingRecord(event);
                break;
            default:
                this.nebulaLogger('Unrecognized action: ${action.name}');
                break;
        }
    }

    // call tracking delete
    deleteCallTrackingRecord(event) {
        this.callTrackingSpinning = true;
        let deleteId = event.detail.row.Id;
        deleteRecord(deleteId)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record deleted successfully',
                        variant: 'success'
                    })
                );
                refreshApex(this.wiredRecords);
                getRecordNotifyChange([{ recordId: this.recordId }]);
            })
            .catch((error) => {
                this.error = error.body.message;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error handling the record',
                        message: this.error,
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
            });
    }

    // submit progress note form
    handleSubmitPN() {
        this.submitSpinning = true;

        this.template.querySelectorAll('lightning-record-edit-form').forEach((element) => {
            let elementId = element.id;
            if (elementId.includes('form2')) {
                element.submit();
            }
        });
    }

    // progress note - appointment form success
    handleSuccessPN() {
        this.submitSpinning = false;
        this.handleClose();
    }

    handleError() {
        this.stopSpinning();
    }

    open() {
        this.template.querySelector('c-vcc-modal').openNoElement();
    }

    handleClose() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSelectedApptEvent(event) {
        this.associatedAppointment = event.detail;
        let assocAppt = this.template.querySelector('lightning-input-field[data-name="assocappt"]');
        assocAppt.value = this.associatedAppointment;
    }

    handleClearAppt() {
        this.associatedAppointment = '';
        let assocAppt = this.template.querySelector('lightning-input-field[data-name="assocappt"]');
        assocAppt.value = this.associatedAppointment;
    }

    /**
     * @description  Logs an error to the Nebula Logger component and saves the log.
     * @param {object} incomingError - The error to be logged.
     */

    nebulaLogger(incomingError) {
        const logger = this.template.querySelector('c-logger');
        if (!logger) return;
        logger.error(JSON.stringify(incomingError));
        logger.saveLog();
    }
}
