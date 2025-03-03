import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import acknowledgeFacilityAccess from "@salesforce/apex/VCC_lwc_utils.acknowledgeFacilityAccess";
import vccMPINoRecordsReturned from "@salesforce/label/c.vccMPINoRecordsReturned";

const CSS_CLASS = "modal-hidden";

export default class VccFacilityAccesModal extends NavigationMixin(LightningElement) {
    mvi;
    vaProfile;
    _mpiData;
    esr;

    @api
    set mpiData(val) {
        if ((val && val.ee) || val.mvi || val.vaProfileV2) {
            this.esr = val.ee;

            this.mvi = val.mvi;
            this.vaProfile = val.vaProfileV2;
            this._mpiData = val;
        } else {
            this.hasError = true;
            this.error = vccMPINoRecordsReturned;
        }
    }
    get mpiData() {
        return this._mpiData;
    }
    @api recordId;

    @api
    headerColor;

    @api primaryButtonLabel;

    @api buttonOneLabel;

    @api handleButtonOneClick;

    hasHeaderString = true;
    _headerPrivate;

    showModal = "display:none;";
    modal;

    @api
    set header(value) {
        this.hasHeaderString = value !== "";
        this._headerPrivate = value;
    }
    get header() {
        return this._headerPrivate;
    }

    eventDataResolve;
    eventDataPromise = new Promise((resolve) => {
        this.eventDataResolve = resolve;
    });

    resolve;
    @api
    async show(onPersonAccountReadResolve) {
        this.resolve = onPersonAccountReadResolve;
        let eventData = await Promise.resolve(this.eventDataPromise);
        if (!Array.isArray(eventData?.tableDataAccessible) || (Array.isArray(eventData?.tableDataAccessible) && eventData?.tableDataAccessible.length == 0)) {
            this.showModal = "";
        } else {
            onPersonAccountReadResolve();
        }
    }

    @api hide() {
        this.showModal = "display:none;";
    }

    cssClass = "slds-modal slds-fade-in-open";
    ishideHomeButton = false;
    connectedCallback() {
        this.headerColor = "#d04d37";
        this.header = "Warning: No Available Facility";
        this.primaryButtonLabel = "Acknowledge and Continue";
        this.buttonOneLabel = "Go back to home";
    }

    renderedCallback() {
        this.addStyles();
    }

    addStyles() {
        const header = this.template.querySelector("header");
        if (header) {
            header.style.backgroundColor = `${this.headerColor}`;
            header.style.color = "#ffffff";
        }
    }

    handleDialogClose() {
        let request = {
            recordId: this.recordId
        };
        acknowledgeFacilityAccess(request)
            .then((result) => {
                let resp = JSON.parse(result);
                if (resp.status) {
                    const logger = this.template.querySelector("c-logger");
                    logger.warn(JSON.stringify(resp.status));
                    logger.saveLog();
                }
            })
            .catch((result) => {
                const logger = this.template.querySelector("c-logger");
                logger.error(JSON.stringify(result));
                logger.saveLog();
            });
        this.resolve();
        this.hide();
    }

    handleBackToHome() {}

    handleSlotTaglineChange() {
        if (this.showModal === false) {
            return;
        }
        const taglineEl = this.template.querySelector("p");
        taglineEl.classList.remove(CSS_CLASS);
    }

    handleSlotFooterChange() {
        if (this.showModal === false) {
            return;
        }
        const footerEl = this.template.querySelector("footer");
        footerEl.classList.remove(CSS_CLASS);
    }

    navigateToHome() {
        // Use the built-in 'Navigate' method
        this[NavigationMixin.Navigate]({
            // Pass in pageReference
            type: "standard__namedPage",
            attributes: {
                pageName: "home"
            }
        });
    }

    handleAfterFacilityLoad(event) {
        this.eventDataResolve({ ...event.detail });
    }
}
