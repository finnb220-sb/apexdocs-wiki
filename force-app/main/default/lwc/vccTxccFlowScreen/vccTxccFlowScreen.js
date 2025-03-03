import { LightningElement } from "lwc";
import { FlowNavigationNextEvent } from "lightning/flowSupport";
import { createClient } from "c/vccMessageChannel";
import VCC_Progress_Note_Flow_Triage_Incomplete_Warning from "@salesforce/label/c.VCC_Progress_Note_Flow_Triage_Incomplete_Warning";

export default class VccTxccFlowScreen extends LightningElement {
    customLabel = VCC_Progress_Note_Flow_Triage_Incomplete_Warning;
    isLoading = true;
    isTxccIncomplete = false;
    client;

    connectedCallback() {
        try {
            this.client = createClient("vccTxccFlowScreen", (msg) => {}, true);
        } catch (e) {
            console.warn(e);
            this.dispatchEvent(new FlowNavigationNextEvent());
        }

        this.client
            .sendRequestTo("txccState", {
                action: "isTxccActive"
            })
            .then((res) => {
                if (res == true) {
                    this.isTxccIncomplete = true;
                } else {
                    this.dispatchEvent(new FlowNavigationNextEvent());
                }
            })
            .catch((e) => {
                console.warn(e);
                this.dispatchEvent(new FlowNavigationNextEvent());
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    disconnectedCallback() {
        if (typeof this.client?.close == "function") {
            this.client.close();
        }
    }

    handleCancel() {
        history.go(-1);
    }

    handleOkay() {
        this.client.sendMessageTo("txccState", { action: "destroy" });
        this.dispatchEvent(new FlowNavigationNextEvent());
    }
}
