import { LightningElement, api } from 'lwc';

/**
 * @description LWC used to display the validation of facility change on a Tele-EC Case Record.
 * @author            : Booz Allen Hamilton
 */

export default class TeleECValidationOfFacilityChange extends LightningElement {
    @api recordId;
    @api availableActions = [];
    flowApiName = 'TED_Validation_of_Facility_Change';
    isFlowVisible = false;
    inputVariables;

    /*
     * @description Runs on page load, gets case data to load into the flow.
     */
    connectedCallback() {
        this.inputVariables = [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId
            }
        ];
    }

    /*
     * @description Makes the flow TED_Validation_of_Facility_Change visible.
     */
    handleClick() {
        this.isFlowVisible = true;
    }

    /*
     * @description Makes the flow TED_Validation_of_Facility_Change hidden when the X button in the top right is clicked
     */
    handleCancelFlow() {
        this.isFlowVisible = false;
    }

    /*
     * @description Checks if the user has hit one of the "Done" buttons  the end of the flow. Takes flow off the screen
     * @param event - The event is the flow passed in from the onstatuschange inside the <lightning-flow> for TED_Validation_of_Facility_Change
     */
    handleStatusChange(event) {
        if (event.detail.status === 'FINISHED') {
            this.isFlowVisible = false;
            window.location.reload();
        }
    }
}
