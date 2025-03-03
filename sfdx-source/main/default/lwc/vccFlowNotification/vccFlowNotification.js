import { LightningElement, api } from "lwc";
import { FlowNavigationNextEvent, FlowNavigationFinishEvent } from "lightning/flowSupport";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";

export default class flowScreen_displayToastMessage extends NavigationMixin(LightningElement) {
    hasRendered = false;

    @api recordId;
    @api objectApiName;
    @api title;
    @api variant;
    @api mode;
    @api message;
    @api urlLabel;
    @api delay;
    @api triggerNavigationNextEvent;

    // Parameters for publishing methods on LMS
    @api messageChannel;
    @api messageJSON;

    @api
    availableActions = [];

    // CSV String from Flows to populate into availableActions
    @api
    flowAvaliableActions = "";

    connectedCallback() {
        if (this.flowAvaliableActions) {
            this.availableActions = this.flowAvaliableActions.split(",").map((e) => e.trim().toUpperCase());
        }
    }

    renderedCallback() {
        if (!this.hasRendered) {
            this.hasRendered = true;
            if (!this.mode) {
                this.mode = "dismissible";
            }

            setTimeout(
                () => {
                    this.showToastMessage();
                },
                this.delay ? this.delay : 0
            );
        }
    }

    async showToastMessage() {
        const url = await this[NavigationMixin.GenerateUrl]({
            type: "standard__recordPage",
            attributes: {
                recordId: this.recordId,
                actionName: "view"
            }
        });

        const event = new ShowToastEvent({
            title: this.title,
            variant: this.variant,
            mode: this.mode,
            message: this.message,
            messageData: [
                {
                    url,
                    label: this.urlLabel
                }
            ]
        });
        this.dispatchEvent(event);

        if (this.triggerNavigationNextEvent) {
            if (this.availableActions.find((action) => action === "NEXT")) {
                const navigateNextEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent);
            } else if (this.availableActions.find((action) => action === "FINISH")) {
                const navigateFinishEvent = new FlowNavigationFinishEvent();
                this.dispatchEvent(navigateFinishEvent);
            }
        }
    }
}
