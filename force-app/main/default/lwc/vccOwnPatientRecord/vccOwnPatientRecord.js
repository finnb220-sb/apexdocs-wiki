import { LightningElement, api } from "lwc";
import { showOwnAccountPopup } from "c/vccAccountPopupController";
import ExposedPromise from "c/exposedPromise";
export default class VccOwnPatientRecord extends LightningElement {
    @api recordId;
    @api title;
    @api body;

    shouldShowModal = false;
    showModal = false;

    //resolved/rejected in the renderedCallback function
    componentInitialization = new ExposedPromise();

    @api
    async open(promise) {
        if (typeof this.recordId != "string") {
            return;
        }
        await this.componentInitialization;
        if (this.shouldShowModal === true) {
            this.showModal = true;
        } else {
            promise.resolve();
        }
    }

    initialized = false;
    async renderedCallback() {
        if (this.initialized === true) {
            return;
        }
        this.initialized = true;

        this.setModalBody();

        try {
            this.shouldShowModal = await showOwnAccountPopup(this.recordId);
            this.componentInitialization.resolve();
        } catch (e) {
            console.warn(e);
            this.componentInitialization.reject(e);
        }
    }

    setModalBody() {
        this.modal.body =
            '<div class="slds-grid slds-wrap">' +
            '<div class="slds-col slds-size_12-of-12">' +
            '<div class="slds-grid slds-wrap">' +
            '<div class="slds-col slds-size_2-of-12" style="padding-top: 10px;padding-left: 20px;">' +
            '<div class="slds-icon-utility-warning slds-icon_container" title="Warning">' +
            '<svg style="fill:#fe9339;" class="slds-icon slds-icon-text-default slds-icon_small" focusable="false" data-key="warning" aria-hidden="true" viewBox="0 0 52 52">' +
            "<g>" +
            '<path d="M51.4 42.5l-22.9-37c-1.2-2-3.8-2-5 0L.6 42.5C-.8 44.8.6 48 3.1 48h45.8c2.5 0 4-3.2 2.5-5.5zM26 40c-1.7 0-3-1.3-3-3s1.3-3 3-3 3 1.3 3 3-1.3 3-3 3zm3-9c0 .6-.4 1-1 1h-4c-.6 0-1-.4-1-1V18c0-.6.4-1 1-1h4c.6 0 1 .4 1 1v13z"></path>' +
            "</g>" +
            "</svg>" +
            '<span class="slds-assistive-text">Warning</span>' +
            "</div>" +
            "</div>" +
            "<br/>" +
            '<div class="slds-col slds-size_10-of-12">' +
            '<div style="font-size:1rem;font-weight: 600;">' +
            this.title +
            "</div>" +
            '<div style="font-size:1rem;padding-top: 20px;">' +
            this.body +
            "</div>" +
            "</div>" +
            "<br/>" +
            "</div>" +
            "</div>" +
            "</div>";
    }

    modal = {
        heading: "Personal Record Access Warning",
        body: "",
        headerColor: "#CA4D36",
        primaryButtonLabel: "Acknowledge & Go back to home",
        buttonOneLabel: "Go back to home"
    };
}
