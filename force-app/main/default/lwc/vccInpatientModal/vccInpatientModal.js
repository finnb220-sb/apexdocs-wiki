import LightningModal from "lightning/modal";
import vccInPatientWarningMessage from "@salesforce/label/c.vccInPatientWarningMessage";
import { api } from "lwc";

export class InpatientModalResult {
    acknowledged;

    constructor({ acknowledged = false } = {}) {
        this.acknowledged = acknowledged;
    }
}

export default class VccInpatientModal extends LightningModal {
    warningMessage = vccInPatientWarningMessage;

    @api
    navigateHome;

    @api
    patientList = [];

    connectedCallback() {
        this.disableClose = true;
    }
    renderedCallback() {
        if (this.autofocus) {
            const homeButton = this.template.querySelector('[data-id="home"]');
            homeButton.focus();
        }
    }

    handleAcknowledge() {
        this.disableClose = false;
        this.close(new InpatientModalResult({ acknowledged: true }));
    }

    handleGoHome() {
        if (typeof this.navigateHome !== "function") {
            //throw eerrorrr
            return;
        }
        this.disableClose = false;
        this.navigateHome();
        this.close(new InpatientModalResult({ acknowledged: false }));
    }
}
