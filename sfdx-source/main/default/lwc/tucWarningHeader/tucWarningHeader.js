import { LightningElement, api } from "lwc";
import { FlowNavigationNextEvent } from "lightning/flowSupport";

export default class TucWarningHeader extends LightningElement {
    showModal = true;

    @api
    availableActions = [];

    handleClose() {
        this.showModal = false;
    }

    handleContinue() {
        this.showModal = false;
    }

    handleGoNext() {
        // check if NEXT is allowed on this screen
        if (this.availableActions.find((action) => action === "NEXT")) {
            // navigate to the next screen
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }
}
