import { api, LightningElement } from "lwc";

export default class VccProgressNoteFlowSigners extends LightningElement {
    @api
    site;

    @api
    recordId;

    @api
    signersOutputJson;

    @api
    validate() {
        try {
            let signers = this.template.querySelector("c-vcc-progress-note-flow-signers-list").getSigners();
            if (Array.isArray(signers) && signers.length > 0) {
                this.signersOutputJson = JSON.stringify(
                    signers.map((signer) => {
                        return signer.VCC_DUZ__c;
                    })
                );
                return {
                    isValid: true
                };
            } else if (signers === false) {
                return {
                    isValid: false
                };
            }
        } catch (e) {
            const logger = this.template.querySelector("c-logger");
            logger.error(JSON.stringify(e));
            logger.saveLog();
        }
    }
}
