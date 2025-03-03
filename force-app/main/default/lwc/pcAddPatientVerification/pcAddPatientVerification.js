import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import ACC_BIRTH_CITY from '@salesforce/schema/Account.VCC_Birth_City__c';
import ACC_BIRTH_STATE from '@salesforce/schema/Account.VCC_Birth_State__c';
import associateAccount from '@salesforce/apex/PC_AddPatientController.associateAccount';

const fields = [ACC_BIRTH_CITY, ACC_BIRTH_STATE];

export default class pcPatientVerification extends LightningElement {
    @api patientRecordId;
    recordId;
    @track isLoading = true;
    formattedCityState = '';

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.attributes.recordId;
        }
    }

    @wire(getRecord, { recordId: '$patientRecordId', fields }) handleAccRetrieve(response) {
        if (response.data) {
            let city = JSON.stringify(response.data.fields.VCC_Birth_City__c.value).replaceAll('"', '');
            let state = JSON.stringify(response.data.fields.VCC_Birth_State__c.value).replaceAll('"', '');
            if (city !== 'null' && state !== 'null') {
                this.formattedCityState = city + ', ' + state;
            } else if (city !== 'null' && state === 'null') {
                this.formattedCityState = city;
            } else if (state !== 'null' && city === 'null') {
                this.formattedCityState = state;
            }
        }
    }

    handleOnload() {
        this.isLoading = false;
    }

    handleConfirmPatient() {
        this.isLoading = true;
        associateAccount({ prcCaseId: this.recordId, selectedAccId: this.patientRecordId })
            .then(() => {
                const event = new ShowToastEvent({
                    title: 'Success',
                    message: 'Case has been updated',
                    variant: 'success'
                });
                this.dispatchEvent(event);
                window.location.assign('/' + this.recordId);
                this.isLoading = false;
            })
            .catch((error) => {
                this.handleError(error, 'Error Updating Case');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleBackToSearchClick() {
        this.template.dispatchEvent(new CustomEvent('backtosearch', { bubbles: true, composed: true }));
    }

    /**
     * Handles errors
     * @param {Object} error the error response object
     * @param {String} toastTitle title of the toast error message
     */
    handleError(error, toastTitle) {
        let messageStr = 'Unknown error';
        if (Array.isArray(error.body)) {
            messageStr = error.body.map((err) => err.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            //Grab message value from error.body.message using object destructuring
            const {
                body: { message }
            } = error;
            messageStr = message;
        }
        this.dispatchEvent(
            new ShowToastEvent({
                message: messageStr,
                title: toastTitle,
                variant: 'error'
            })
        );
    }
}
