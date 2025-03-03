import { api, LightningElement, track } from "lwc";
import { getSignersForRecord } from "c/vccSignersController";

export default class VccProgressNoteSignersFormattedOutput extends LightningElement {
    @track
    signers = [];

    // start deprecated properties
    @api
    set signersJSON(val) {
        try {
            let parsedJSON = JSON.parse(val);
            if (parsedJSON && typeof parsedJSON == "object" && Array.isArray(parsedJSON)) {
                this.signers = [...parsedJSON];
            }
            this._signersJSON = val;
        } catch (e) {
            this.signers = [];
        }
        this.isLoading = false;
    }
    get signersJSON() {
        return this._signersJSON;
    }
    @api isNewApi;
    @api isNewApiString;
    // end deprecated properties

    @api recordId;

    initialized = false;
    async renderedCallback() {
        if (this.initialized === true) {
            return;
        }
        this.initialized = true;
        let signers = await getSignersForRecord({ recordId: this.recordId });
        if (Array.isArray(signers) && signers.length > 0) {
            this.signers = [
                ...signers.map((signer) => {
                    return {
                        providername: signer.Name,
                        providertitle: signer.VCC_Title__c,
                        duz: signer.VCC_DUZ__c
                    };
                })
            ];

            this.isLoading = false;
        }
    }
}
