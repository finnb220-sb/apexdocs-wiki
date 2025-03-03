import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class TucRedirectToRecord extends NavigationMixin(LightningElement) {
    @api SendToRecord;
    @api SendToPage;

    connectedCallback() {
        if (this.SendToRecord) {
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: this.SendToRecord,
                    objectApiName: this.objectName,
                    actionName: "view"
                }
            });
        } else if (this.SendToPage) {
            this[NavigationMixin.Navigate]({
                type: "standard__navItemPage",
                attributes: {
                    apiName: this.SendToPage
                }
            });
        }
    }
}
