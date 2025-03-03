import { api, LightningElement } from "lwc";
import { createClient } from "c/vccMessageChannel";
import { PN_FLOW_PACT_CLIENT_NAME } from "c/vccProgressNoteFlowPact";
import { LoadingModalResult } from "c/vccLoadingModal";
import LoggerMixin from "c/loggerMixin";

export const PN_FLOW_SIGNERS_LIST_CLIENT_NAME = "progressNoteFlowSignersList";
export default class VccProgressNoteFlowSignersList extends LoggerMixin(LightningElement) {
    isLoading = true;

    @api
    recordId;

    @api
    siteCode;

    messageChannelClient;
    signersListComponent;
    pactClientName = PN_FLOW_PACT_CLIENT_NAME;

    @api
    getSigners() {
        return this.signersListComponent.getSigners();
    }

    connectedCallback() {
        this.messageChannelClient = createClient(
            PN_FLOW_SIGNERS_LIST_CLIENT_NAME, //client name
            async (msg) => {
                //function to handle incoming messages
                switch (msg?.payload?.action) {
                    case "addsigners":
                        msg.reply(await this.signersListComponent.addSigners(msg?.payload?.vistaUsers));
                        break;
                    case "removesignerbyname":
                        msg.reply(await this.signersListComponent.removeSignerByName(msg?.payload?.signerName));
                        break;
                }
            },
            true //using application scope (because we're in a flow)
        );
    }

    disconnectedCallback() {
        if (this.messageChannelClient !== null && this.messageChannelClient != undefined) {
            this.messageChannelClient.close();
        }
    }

    renderedCallback() {
        if (this.initialized === true) {
            return;
        }
        this.initialized = this.tryInitialize();
        if (this.initialized === true) {
            this.isLoading = false;
        }
    }

    tryInitialize() {
        try {
            let signersListComponent = this.template.querySelector("c-vcc-signers-list");
            if (signersListComponent === null || signersListComponent === undefined) {
                return false;
            }
            this.signersListComponent = signersListComponent;
        } catch (e) {
            this.Logger.debug(e);
            return false;
        }
        return true;
    }

    async handleSignerRemoved(e) {
        let informProgressNoteFlowPact = this.messageChannelClient.sendRequestTo("progressNoteFlowPact", {
            action: "removed",
            signers: e.detail.signers
        });

        let informProgressNoteFlowSignersSearch = this.messageChannelClient.sendRequestTo("progressNoteFlowSignersSearch", {
            action: "removed",
            signers: e.detail.signers
        });

        try {
            await Promise.allSettled([informProgressNoteFlowPact, informProgressNoteFlowSignersSearch]);
        } catch (e) {
            this.Logger.debug(e);
        }

        if (e.detail.loadingModalPromise !== undefined && e.detail.loadingModalPromise instanceof Promise) {
            e.detail.loadingModalPromise.resolve(new LoadingModalResult());
        }
    }
}
