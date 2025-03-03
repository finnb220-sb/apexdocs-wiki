/**
 * @description JavaScript controller for the pcCaseListComponent Lightning Web Component - displays a Specialist's Open Case details (currently on the Specialist Home Page)
 * @author      Booz Allen Hamilton
 * @see         PC_PrcCaseRepo
 * @see         PC_PrcCaseRepoTest
 * @see         PC_CaseListController
 * @see         PC_CaseListControllerTest
 */
import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Apex
import getOpenPcCase from '@salesforce/apex/PC_CaseListController.getOpenPcCase';

export default class PcCaseListComponent extends LightningElement {
    openCase;
    wiredPcCase;

    /**
     * @description    gets a list of the oldest open PC Cases from the PC_CaseListController Apex Class.
     */
    @wire(getOpenPcCase)
    getOldestOpenCase(result) {
        this.wiredPcCase = result;

        if (result.data) {
            this.openCase = result.data;
        } else if (result.error) {
            this.handleError(
                result.error,
                "Error: Failed to return the user's PrC Case.  Please reach out to your System Admin."
            );
        }
    }

    /**
     * @description used for conditional display of Patient Account Name if the returned field is null or it was not queried
     */
    get hasPatientAccountField() {
        return this?.openCase?.Patient_Account__c && this?.openCase?.Patient_Account__r?.Name;
    }

    /**
     * @description    Handles errors
     * @param {Object} error the error response object
     * @param {String} toastTitle title of the toast error message
     */
    handleError(error, toastTitle) {
        let messageStr = 'Unknown error';
        if (Array.isArray(error?.body)) {
            messageStr = error?.body?.map((err) => err.message).join(', ');
        } else if (typeof error?.body?.message === 'string') {
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
