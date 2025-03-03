import LightningModal from "lightning/modal";
import ExposedPromise from "c/exposedPromise";
import { api } from "lwc";

export default class VccLoadingModal extends LightningModal {
    isLoading = true;

    result;

    @api
    actionDescription = "Loading...";

    @api
    modalPromise;

    async connectedCallback() {
        this.disableClose = true;
        try {
            if (!(this.modalPromise instanceof Promise)) {
                setTimeout(() => {
                    this.disableClose = false;
                    this.close();
                }, 1000);
                return;
            }

            this.result = await this.modalPromise;
            this.isLoading = false;

            if (typeof this.result.dwellTime === "number" && this.result.dwellTime > 0) {
                setTimeout(() => {
                    this.disableClose = false;
                    this.close();
                }, this.result.dwellTime);
                return;
            }
        } catch (e) {
            console.warn(e);
        } finally {
            this.disableClose = false;
        }
    }
}

export function openLoadingModal({ label = "Loading...", size = "small", description = "Loading screen.", actionDescription = "Loading..." } = {}) {
    let modalPromise = new ExposedPromise();
    VccLoadingModal.open({
        label: label,
        size: size,
        description: description,
        actionDescription: actionDescription,
        modalPromise: modalPromise
    });
    return modalPromise;
}

export class LoadingModalResult {
    message;
    iconName;
    iconSize;
    iconVariant;
    dwellTime;

    constructor({ message = "", iconName = "", iconSize = "", iconVariant = "", dwellTime = 1 } = {}) {
        this.message = message;
        this.iconName = iconName;
        this.iconSize = iconSize;
        this.iconVariant = iconVariant;
        this.dwellTime = dwellTime;
    }
}
