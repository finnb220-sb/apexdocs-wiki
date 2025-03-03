import { LightningElement, api } from "lwc";
import { FlowAttributeChangeEvent } from "lightning/flowSupport";

export default class VccLookUpCall extends LightningElement {
    @api clinicId;
    @api clinicName;
    @api searchkey;
    @api recordId;
    @api persona;
    @api selectedFacilitySiteId;
    @api recordType;
    @api visn;

    onClinicSelection(event) {
        this.clinicId = event.detail.selectedRecordId;
        this.clinicName = event.detail.selectedValue;
        this.visn = event.detail.selectedVisn;

        let attributeChangeEvent = new FlowAttributeChangeEvent("clinicId", this.clinicId);
        this.dispatchEvent(attributeChangeEvent);

        let attributeChangeEvent2 = new FlowAttributeChangeEvent("clinicName", this.clinicName);
        this.dispatchEvent(attributeChangeEvent2);

        let attributeChangeEvent3 = new FlowAttributeChangeEvent("visn", this.visn);
        this.dispatchEvent(attributeChangeEvent3);
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
