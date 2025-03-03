import { LightningElement } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import vccApptViewer from "@salesforce/customPermission/VCC_Appointment_Viewer";
import toastTitle from "@salesforce/label/c.VCC_Prevent_New_Event_Title";
import toastMessage from "@salesforce/label/c.VCC_Prevent_New_Event_Message";

export default class VccNewEvent extends NavigationMixin(LightningElement) {
    connectedCallback() {
        if (vccApptViewer) {
            const event = new ShowToastEvent({
                title: toastTitle,
                message: toastMessage,
                variant: "warning",
                mode: "sticky"
            });
            this.dispatchEvent(event);

            this[NavigationMixin.Navigate]({
                type: "standard__objectPage",
                attributes: {
                    objectApiName: "Task",
                    actionName: "home"
                }
            });
        } else {
            this[NavigationMixin.Navigate]({
                type: "standard__objectPage",
                attributes: {
                    objectApiName: "Event",
                    actionName: "new"
                },
                state: {
                    nooverride: "1"
                }
            });
        }
    }
}
