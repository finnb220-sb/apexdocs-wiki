import { LightningElement, api, wire } from "lwc";
import { getRecord, updateRecord, getFieldValue } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import ID_FIELD from "@salesforce/schema/VCC_Progress_Note__c.Id";
import CREATED_BY_ID_FIELD from "@salesforce/schema/VCC_Progress_Note__c.CreatedById";
import ELECTRONIC_SIGNATURE_FIELD from "@salesforce/schema/VCC_Progress_Note__c.VCC_Electronic_Signature__c";
import USER_ID from "@salesforce/user/Id";
import NAME_FIELD from "@salesforce/schema/User.Name";

export default class VccSignNote extends LightningElement {
    @api recordId;
    showModal = false;

    @wire(getRecord, { recordId: "$recordId", fields: CREATED_BY_ID_FIELD, ELECTRONIC_SIGNATURE_FIELD })
    progressNote;

    @wire(getRecord, { recordId: USER_ID, fields: NAME_FIELD })
    user;

    get electronicSignature() {
        return getFieldValue(this.progressNote.data, ELECTRONIC_SIGNATURE_FIELD);
    }

    get creatorSignerDiff() {
        if (getFieldValue(this.progressNote.data, CREATED_BY_ID_FIELD) !== USER_ID) {
            return true;
        } else {
            return false;
        }
    }

    get name() {
        return getFieldValue(this.user.data, NAME_FIELD);
    }

    openModal() {
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
    }

    handleConfirm() {
        this.updateCase();
    }

    updateCase() {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[ELECTRONIC_SIGNATURE_FIELD.fieldApiName] = this.name;

        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Progress Note successfully signed.",
                        variant: "success"
                    })
                );
            })
            .catch((error) => {
                console.log(error);
            })
            .finally(() => {
                this.closeModal();
            });
    }
}
