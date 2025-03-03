import { LightningElement, api } from "lwc";

export default class BaseEmptyState extends LightningElement {
    @api type; // string of the desired frame
    @api msg; // message
    @api subMsg; // submessage
    @api variant; // color variant of the message text
    isError = false;

    renderedCallback() {
        let messageDiv = this.template.querySelector("h3");
        if (!this.variant || !messageDiv) return;
        if (this.variant === "error") {
            messageDiv.classList.add("slds-text-color_error");
            this.isError = true;
        }
        if (this.variant === "success") messageDiv.classList.add("slds-text-color_success");
    }
}
