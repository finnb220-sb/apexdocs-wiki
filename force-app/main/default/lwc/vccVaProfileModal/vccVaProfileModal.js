import { api } from "lwc";
import LightningModal from "lightning/modal";

/**
 * @author Patrick Skamarak
 * Testing out the new out-of-the-box lightning-modal.
 * https://developer.salesforce.com/docs/component-library/bundle/lightning-modal/documentation
 */
export default class VaProfileModal extends LightningModal {
    isLoading = false;

    @api
    variant;

    @api
    value;

    @api
    headerLabel = "Default Header Label";

    handleBack(event) {
        this.close();
    }

    async handleSubmit(event) {
        this.disableClose = true;
        this.isLoading = true;

        try {
            this.template.querySelector("c-vcc-va-profile-input").validate();
            event.detail.validationPromise.resolve();
        } catch (e) {
            event.detail.validationPromise.reject(e);
            this.disableClose = false;
            this.isLoading = false;
        }

        try {
            await Promise.resolve(event.detail.submitPromise);
            this.disableClose = false;
            this.isLoading = false;
            this.close();
        } catch (e) {
            this.disableClose = false;
            this.isLoading = false;
        }
    }
}
