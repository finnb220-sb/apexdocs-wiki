/**
 * @description This lwc is designed to provide a confirmation when working with an Appointment Request. In the VAHC App, under the appointments tab on a patient account record, there is an Open Appt Requests tab. Here you can see and act on
 * appointment requests. If you select the "Create Appointment Request" at the top of the list of flexcards, or either the "Edit Appointment Request" or "Cancel Appointment Request" button on the Appointment Request flexcard (this is OmniStudio),
 * it will process a flyout to this lwc, where data will be passed into the stepName, stepTitle, stepMessage, and accountId properties. It is also used when you click on the "Cancel Appointment" button in the Upcoming Appts tab.
 * In this component,  it will display a toast message as the final step to provide confirmation to the user that the operation was successful, then direct the user to the Patient page.
 * @author Booz Allen Hamilton
 * @since 5/21/2024
 */
import { api, LightningElement } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class VccDisplayMessage extends OmniscriptBaseMixin(NavigationMixin(LightningElement)) {
    //Omni properties
    @api stepName;
    @api stepTitle;
    @api stepMessage;
    @api accountId;
    ////////////////

    /**
     * @description renderedCallback will call handleOmniStepLoadData to validate the data passed in from OmniStudio and post a toast message to the user.
     * It then calls navigateToNextStep, which will call the next step in the Omniscript. That step will direct the user back to the Patient(Account) page.
     */
    renderedCallback() {
        this.handleOmniStepLoadData();
        this.navigateToNextStep();
    }

    /**
     * @description Validates that the parameters from Omni are pulled in and calls a method to display a toast message.
     */
    handleOmniStepLoadData() {
        if (this.stepName && this.stepTitle && this.stepMessage) {
            this.postSuccess(this.stepTitle, this.stepMessage);
        }
    }

    /**
     * @description Success is a helper function that will take in a message variable and publish a toast that contains the message.
     * @param {String} title The title to display in the success toast message
     * @param {String} message The message to display in the success toast message
     */
    postSuccess(title, message) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: 'success'
        });
        this.dispatchEvent(evt);
    }

    /**
     * @description Navigates to the next step in OmniScript which takes the user to the Patient(Account) record detail page after the toast message is displayed.
     */
    navigateToNextStep() {
        this.omniNextStep();
    }
}
