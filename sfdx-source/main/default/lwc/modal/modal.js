import { LightningElement, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { proxyTool } from "c/helpersLWC";

const CSS_CLASS = "modal-hidden";

export default class Modal extends NavigationMixin(LightningElement) {
    @api
    body;

    @api
    headerColor;
    // primary aka close modal button
    // this handler is supplied by this class
    // and not passed by parent component
    @api primaryButtonLabel;

    @api buttonOneLabel;

    @api handleButtonOneClick;

    hasHeaderString = true;
    _headerPrivate;

    showModal = true;
    @api
    set header(value) {
        this.hasHeaderString = value !== "";
        this._headerPrivate = value;
    }
    get header() {
        return this._headerPrivate;
    }

    @api show() {
        this.showModal = true;
    }

    @api hide() {
        this.showModal = false;
    }

    @api viewType;
    isHtmlBlock = false;

    cssClass = "slds-modal slds-fade-in-open popup";
    ishideHomeButton = false;
    isOwnRecord = false;
    connectedCallback() {
        debugger;
        if (this.viewType == "OWN_RECORD") {
            this.ishideHomeButton = true;
            this.isHtmlBlock = true;
            this.isOwnRecord = true;

            let thisObj = this;
            var Intervalele = setInterval(function () {
                if (thisObj.template.querySelector(".htmlMsgBlock") != undefined) {
                    thisObj.template.querySelector(".htmlMsgBlock").innerHTML = thisObj.body;
                    clearInterval(Intervalele);
                }
            }, 100);
        }
        if (this.viewType == "FLAG") {
            this.cssClass = "slds-modal slds-fade-in-open flag-css";
            this.ishideHomeButton = true;
        }
        if (this.viewType == "HTML_BLOCK") {
            this.isHtmlBlock = true;
            let thisObj = this;

            var Intervalele = setInterval(function () {
                if (thisObj.template.querySelector(".htmlMsgBlock") != undefined) {
                    thisObj.template.querySelector(".htmlMsgBlock").innerHTML = thisObj.body;
                    clearInterval(Intervalele);
                }
            }, 100);
        }
    }

    renderedCallback() {
        this.addStyles();
        // Focus modal for 508 compliance.
        setTimeout(() => {
            let primaryBtn = this.template.querySelector(".primary-button");
            if (primaryBtn) {
                primaryBtn.focus();
            }
        }, 2000);
    }

    addStyles() {
        const header = this.template.querySelector("header");
        if (header) {
            header.style.backgroundColor = `${this.headerColor}`;
            header.style.color = "#ffffff";
        }
    }

    handleDialogClose() {
        //Let parent know that dialog is closed (mainly by that cross button) so it can set proper variables if needed
        const closedialog = new CustomEvent("closedialog", {
            bubbles: true,
            composed: true,
            cancelable: false
        });
        this.dispatchEvent(closedialog);

        this.hide();
    }

    handleBackToHome() {}

    handleSlotTaglineChange() {
        // Only needed in "show" state. If hiding, we're removing from DOM anyway
        // Added to address Issue #344 where querySelector would intermittently return null element on hide
        if (this.showModal === false) {
            return;
        }
        const taglineEl = this.template.querySelector("p");
        taglineEl.classList.remove(CSS_CLASS);
    }

    handleSlotFooterChange() {
        // Only needed in "show" state. If hiding, we're removing from DOM anyway
        // Added to address Issue #344 where querySelector would intermittently return null element on hide
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
}
