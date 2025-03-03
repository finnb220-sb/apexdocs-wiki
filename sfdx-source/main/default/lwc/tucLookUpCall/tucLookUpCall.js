import { LightningElement, api } from "lwc";
import { FlowAttributeChangeEvent } from "lightning/flowSupport";

export default class TucLookUpCall extends LightningElement {
    @api clinicId;
    @api clinicName;
    @api searchkey;
    @api recordId;
    @api persona;
    @api selectedFacilitySiteId;
    @api recordType;

    onClinicSelection(event) {
        //var currentText = event.currentTarget.dataset.id;
        this.clinicId = event.detail.selectedRecordId;
        let attributeChangeEvent = new FlowAttributeChangeEvent("clinicId", this.clinicId);
        this.dispatchEvent(attributeChangeEvent);
    }

    @api
    validate() {
        if (this.clinicId) {
            return { isValid: true };
        } else {
            return {
                isValid: false,
                errorMessage: "Please select a Clinic/Location."
            };
        }
    }
}
