import { api, LightningElement } from "lwc";
import { FlowNavigationNextEvent } from "lightning/flowSupport";

export default class VccNewProgressNoteButton extends LightningElement {
    @api
    buttonPress = false;

    @api
    availableActions = [];

    handleClick() {
        this.buttonPress = true;

        // check if NEXT is allowed on this screen
        if (this.availableActions.find((action) => action === "NEXT")) {
            // Navigate to the next screen
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }
}
