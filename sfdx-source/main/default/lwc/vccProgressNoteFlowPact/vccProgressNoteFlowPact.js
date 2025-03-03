import { api, LightningElement } from "lwc";
import { createClient } from "c/vccMessageChannel";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { searchProviders } from "c/vccSignersController";
import { PN_FLOW_SIGNERS_SEARCH_CLIENT_NAME } from "c/vccProgressNoteFlowVistaUserSearch";
import { PN_FLOW_SIGNERS_LIST_CLIENT_NAME } from "c/vccProgressNoteFlowSignersList";
import { LoadingModalResult, openLoadingModal } from "c/vccLoadingModal";

export const PN_FLOW_PACT_CLIENT_NAME = "progressNoteFlowPact";
export default class VccProgressNoteFlowPact extends LightningElement {
    @api responseJSON;
    @api siteCode;
    isLoading = false;

    messageChannelClient;
    pactMessageHandler;
    isAddMany = false;
    pactMembers = [];

    openLoadingModal(actionDescription) {
        this.loadingModalPromise = openLoadingModal({ actionDescription: actionDescription });
    }

    resolveLoadingModal(result) {
        if (this.loadingModalPromise !== null && this.loadingModalPromise instanceof Promise) {
            this.loadingModalPromise.resolve(result);
        }
    }

    connectedCallback() {
        this.messageChannelClient = createClient(
            PN_FLOW_PACT_CLIENT_NAME,
            (msg) => {
                switch (msg.payload.action) {
                    case "removed":
                        this.pactMessageHandler({
                            result: "removed",
                            providers: msg.payload.signers.map((signer) => {
                                return {
                                    loginSiteCode: signer.VCC_Location__c,
                                    providername: signer.Name
                                };
                            })
                        });
                        msg.reply(true);
                        this.resolveLoadingModal(new LoadingModalResult());
                        break;
                }
            },

            true
        );
    }

    disconnectedCallback() {
        if (this.messageChannelClient !== null || this.messageChannelClient !== undefined) {
            this.messageChannelClient.close();
        }
    }

    handlePactConnected(e) {
        e.stopPropagation();
        this.pactMessageHandler = e.detail.messageHandler;
        this.pactMembers = e.detail.tableData;
    }

    async handleMessage(e) {
        e.stopPropagation();
        try {
            switch (e.detail?.message?.action) {
                case "add":
                    this.openLoadingModal("Adding Signer...");
                    await this.handleAddMessage(e.detail);
                    this.resolveLoadingModal(new LoadingModalResult());
                    break;

                case "remove":
                    this.openLoadingModal("Removing Signer...");
                    await this.handleRemoveMessage(e.detail);
                    break;
            }
        } catch (e) {
            console.warn(e);
        }
    }

    async handleAddMessage(eventDetail) {
        let providers = eventDetail?.message?.providers;
        if (!Array.isArray(providers) || providers?.length === 0) {
            return;
        }
        let resultString = await this.handleSingleSearch(providers[0]);
        this.pactMessageHandler({
            result: resultString,
            providers: providers
        });
    }

    async handleRemoveMessage(eventDetail) {
        await this.removeSignerByname(eventDetail.message.providers[0]);
    }

    async handleSingleSearch(provider) {
        let searchResults = await this.searchSinglePact(provider);
        let exactMatches = this.removeNonMatches(searchResults, provider);
        if (!Array.isArray(exactMatches) || exactMatches?.length === 0 || exactMatches?.length >= 2) {
            await this.setVistaSearchState(provider.providername, searchResults);
            this.template.dispatchEvent(
                new ShowToastEvent({
                    title: "No Exact Record Match Found",
                    variant: "info",
                    message: "View search results below"
                })
            );
            return "error";
        }
        if (Array.isArray(exactMatches) && exactMatches?.length === 1) {
            await this.addSigners(exactMatches);
            this.template.dispatchEvent(
                new ShowToastEvent({
                    title: "Signer Added",
                    variant: "success"
                })
            );
            return "added";
        }
    }

    async searchSinglePact(provider) {
        let searchResults = await searchProviders({ searchString: provider.providername, site: this.siteCode });
        if (!Array.isArray(searchResults)) {
            console.warn(`Expected an array, got ${searchResults}.`);
            return [];
        }
        return searchResults;
    }

    removeNonMatches(searchResults, provider) {
        return searchResults.flatMap((vistaUser) => {
            if (vistaUser.VCC_StaffName__c === provider.providername) {
                return vistaUser;
            } else {
                return [];
            }
        });
    }

    async addSigners(providers) {
        return await this.messageChannelClient.sendRequestTo(PN_FLOW_SIGNERS_LIST_CLIENT_NAME, {
            action: "addsigners",
            vistaUsers: providers
        });
    }

    async setVistaSearchState(searchString, searchResults) {
        return await this.messageChannelClient.sendRequestTo(PN_FLOW_SIGNERS_SEARCH_CLIENT_NAME, {
            action: "settablestate",
            vistaUsers: searchResults,
            searchString: searchString
        });
    }

    async removeSignerByname(providername) {
        return await this.messageChannelClient.sendRequestTo(PN_FLOW_SIGNERS_LIST_CLIENT_NAME, {
            action: "removesignerbyname",
            signerName: providername
        });
    }
}
