/**
 * Created by abaddon on 8/16/23.
 */

import { LightningElement, api } from "lwc";
import { FlowNavigationBackEvent, FlowNavigationNextEvent, FlowNavigationPauseEvent, FlowNavigationFinishEvent } from "lightning/flowSupport";

export default class vccFlowNavigationButtons extends LightningElement {
    @api availableActions = [];
    finalScreen = false;
    firstScreen = false;
    showCancelButton = false;
    @api switchLogic;
    @api flowStage;
    @api reactiveValue;
    @api lwcMemory;
    @api varPageRedirect;
    @api recordId;
    handleCancel() {
        window.history.back();
    }
    handleNext() {
        let navigateEvent;
        if (this.availableActions.find((action) => action === "NEXT")) {
            navigateEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateEvent);
            this.topFunction();
        }
        try {
            this.dispatchEvent(navigateEvent);
        } catch (e) {
            this.handleError(e);
        }
    }
    handleBack() {
        let navigateEvent;
        if (this.availableActions.find((action) => action === "BACK")) {
            navigateEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(navigateEvent);
            this.topFunction();
        }
        try {
            this.dispatchEvent(navigateEvent);
        } catch (e) {
            this.handleError(e);
        }
    }
    handleFinish() {
        let navigateEvent;
        if (this.availableActions.find((action) => action === "FINISH")) {
            navigateEvent = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigateEvent);
            this.topFunction();
        }
        try {
            this.dispatchEvent(navigateEvent);
        } catch (e) {
            this.handleError(e);
        }
    }
    handlePause() {
        let navigateEvent;
        if (this.availableActions.find((action) => action === "PAUSE")) {
            navigateEvent = new FlowNavigationPauseEvent();
            this.dispatchEvent(navigateEvent);
            this.topFunction();
        }
        try {
            this.dispatchEvent(navigateEvent);
        } catch (e) {
            this.handleError(e);
        }
    }
    handleError(e) {
        console.error("Exception: " + e);
    }
    topFunction() {
        const scrollOptions = {
            left: 0,
            top: 0,
            behavior: "smooth"
        };
        window.scrollTo(scrollOptions);
    }
    handleInput() {
        let _flowStage = this.flowStage;
        let _switchLogic = this.switchLogic;
        this.showCancelButton = false;
        switch (_flowStage) {
            case 1:
                this.firstScreen = true;
                this.finalScreen = _switchLogic !== 1;
                this.showCancelButton = this.varPageRedirect === "true" ? true : false;
                break;
            case 3:
                this.firstScreen = false;
                this.finalScreen = _switchLogic === 0;
                break;

            case 8:
                this.firstScreen = false;
                this.finalScreen = _switchLogic === 0;
                break;
            default:
                this.firstScreen = false;
                this.finalScreen = false;
                break;
        }
    }
    connectedCallback() {
        this.handleInput();
    }
    disconnectedCallback() {}
}
