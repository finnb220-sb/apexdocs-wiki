import { api } from "lwc";
import LightningModal from "lightning/modal";

export default class PcTeleHealthPhoneModal extends LightningModal {
    @api callback;
    @api callbackExt;

    get disablePhoneConnect() {
        return !this.callback;
    }

    handleCallback(event) {
        this.callback = event.detail.value;
    }

    handleCallbackExt(event) {
        this.callbackExt = event.detail.value;
    }

    handleSubmit() {
        let result = { value: "SUBMIT", callback: this.callback, callbackExt: this.callbackExt };
        this.close(result);
    }
}
