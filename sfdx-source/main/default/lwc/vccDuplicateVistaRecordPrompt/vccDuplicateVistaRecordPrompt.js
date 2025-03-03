import { LightningElement, wire, api } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import PROGRESS_NOTE_OBJECT from "@salesforce/schema/VCC_Progress_Note__c";

export default class VccDuplicateVistaRecordPrompt extends LightningElement {
    isLoading = true;

    @api
    checkBoxFieldValue;

    @api
    vistaStation = "";

    @wire(getObjectInfo, { objectApiName: PROGRESS_NOTE_OBJECT })
    handleObjectInfo({ data }) {
        if (data != undefined && data != null) {
            this.helpText = data?.fields?.VCC_Progress_Note_created_in_CPRS__c?.inlineHelpText;
            this.isLoading = false;
        }
    }

    helpText = "";

    handleCheckBoxChange(event) {
        this.checkBoxFieldValue = event.target.checked;
    }
}
