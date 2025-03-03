import { api, LightningElement } from "lwc";
import { createClient } from "c/vccMessageChannel";
import { PN_FLOW_SIGNERS_LIST_CLIENT_NAME } from "c/vccProgressNoteFlowSignersList";
import { openLoadingModal, LoadingModalResult } from "c/vccLoadingModal";

export const PN_FLOW_SIGNERS_SEARCH_CLIENT_NAME = "progressNoteFlowSignersSearch";
export default class VccProgressNoteFlowVistaUserSearch extends LightningElement {
    isLoading = true;
    initialized = false;

    @api
    siteCode;

    @api
    recordId;

    vistaUserSearchComponent;
    clientName = PN_FLOW_SIGNERS_SEARCH_CLIENT_NAME;
    messageChannelClient;

    connectedCallback() {
        this.messageChannelClient = createClient(
            this.clientName,
            (msg) => {
                switch (msg.payload.action) {
                    case "search":
                        this.handleSearch(msg);
                        break;
                    case "settablestate":
                        this.handleSetTableState(msg);
                        break;
                    case "removed":
                        this.handleRemovalUIRecord(msg.payload);
                        msg.reply(true);
                        break;
                }
            },
            true
        );
    }

    disconnectedCallback() {
        if (this.messageChannelClient !== null && this.messageChannelClient !== undefined) {
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
            let vistaUserSearchComponent = this.template.querySelector("c-vcc-vista-user-search");
            if (vistaUserSearchComponent === null || vistaUserSearchComponent === undefined) {
                return false;
            }
            this.vistaUserSearchComponent = vistaUserSearchComponent;
        } catch (e) {
            console.warn(e);
            return false;
        }
        return true;
    }

    handleRemovalUIRecord(data) {
        this.template.querySelector("c-vcc-vista-user-search").handleRemovalUI(data);
    }

    async handleAddSigners(e) {
        this.isLoading = true;
        try {
            let modalPromise = openLoadingModal({
                actionDescription: "Adding signer..."
            });
            await this.messageChannelClient.sendRequestTo(PN_FLOW_SIGNERS_LIST_CLIENT_NAME, {
                action: "addsigners",
                vistaUsers: e?.detail?.records
            });
            modalPromise.resolve(new LoadingModalResult());
        } catch (e) {
            console.warn(e);
        } finally {
            this.isLoading = false;
        }
    }

    async handleSearch(msg) {
        let { searchString = "" } = msg.payload;
        this.vistaUserSearchComponent.setInputString(searchString);
        msg.reply(await this.vistaUserSearchComponent.searchVistaUsers({ searchString: searchString, site: this.siteCode }));
    }

    async handleSetTableState(msg) {
        try {
            this.vistaUserSearchComponent.setInputString(msg.payload?.searchString);
            this.vistaUserSearchComponent.setTableData(msg.payload?.vistaUsers);
            msg.reply(true);
        } catch (e) {
            console.warn(e);
            msg.reply(false);
        }
    }
}
