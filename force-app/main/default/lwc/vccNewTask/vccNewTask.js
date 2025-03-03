import { LightningElement } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import vccMPUser from "@salesforce/customPermission/VCC_Medical_Provider";
import toastTitle from "@salesforce/label/c.VCC_Prevent_New_Task_Title";
import toastMessage from "@salesforce/label/c.VCC_Prevent_New_Task_Message";

export default class VccNewTask extends NavigationMixin(LightningElement) {
    connectedCallback() {
        if (vccMPUser) {
            const event = new ShowToastEvent({
                title: toastTitle,
                message: toastMessage,
                variant: "warning"
            });
            this.dispatchEvent(event);

            this[NavigationMixin.Navigate]({
                type: "standard__objectPage",
                attributes: {
                    objectApiName: "Task",
                    actionName: "list"
                },
                state: {
                    filterName: "VCC_VCV_Tasks_Queue"
                }
            });
        } else {
            this[NavigationMixin.Navigate]({
                type: "standard__objectPage",
                attributes: {
                    objectApiName: "Task",
                    actionName: "new"
                },
                state: {
                    nooverride: "1"
                }
            });
        }
    }
}
