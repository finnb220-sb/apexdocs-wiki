/**
 * Created by abaddon on 10/23/23.
 */

import LightningModal from "lightning/modal";
import { api } from "lwc";
import { recursiveClimb } from "./facilityHelper";

const NavType = {
    KEYBOARD: Symbol("keyboard"),
    MOUSE: Symbol("mouse")
};

export class FacilityModalResult {
    acknowledged;
    constructor({ acknowledged = false } = {}) {
        this.acknowledged = acknowledged;
    }
}

export default class VccFacilityAccessModalWrapper extends LightningModal {
    //Accessibility
    // all html elements
    callingElement; //the element that opened the modal (to focus again after closing)
    firstElement; //should always be the 'X' button in top right of modal
    lastElement; //should always be the 'close' button in bottom right of modal
    backDropElement; //should always be the...backdrop
    // a random unsigned 32 bit integer generated every time the modal opens
    modalSessionId;
    // determines the behavior of focus trapping
    displayModal = false;
    userNavigationType = NavType.KEYBOARD;
    initialRenderComplete = false;
    loadCorrection = false;
    hasRendered = false;

    constructor() {
        super();
        this.handleWindowFocusOut = this.handleWindowFocusOut.bind(this);
        this.handleFacilityFocusOut = this.handleFacilityFocusOut.bind(this);
        this.handleClick = this.handleClick.bind(this);
    }

    // modal sizing property
    @api content = [];
    @api mpiData = [];
    @api header;
    @api homeButton;
    @api hideHome;
    @api recordId;
    @api navigateHome;
    @api acknowledgeButton;

    handleAfterFacilityLoad(event) {
        this.eventDataResolve({ ...event.detail });
    }

    eventDataResolve;
    eventDataPromise = new Promise((resolve) => {
        this.eventDataResolve = resolve;
    });

    handleClose() {
        this.disableClose = false;
        this.close(new FacilityModalResult({ acknowledged: false }));
    }

    handleAcknowledge() {
        this.setProperties("close");
        this.disableClose = false;
        this.close(new FacilityModalResult({ acknowledged: true }));
    }

    handleGoHome() {
        if (typeof this.navigateHome !== "function") {
            //throw eerrorrr
            return;
        }
        this.disableClose = false;
        this.setProperties("close");
        this.navigateHome();
        this.close(new FacilityModalResult({ acknowledged: false }));
    }

    connectedCallback() {}

    disconnectedCallback() {
        this.template.removeEventListener("mousedown", this.handleClick);
        window.removeEventListener("focusout", this.handleWindowFocusOut);
    }

    async renderedCallback() {
        if (this.hasRendered === false) {
            let eventData = await Promise.resolve(this.eventDataPromise);
            if (!Array.isArray(eventData?.tableDataAccessible) || (Array.isArray(eventData?.tableDataAccessible) && eventData?.tableDataAccessible.length == 0)) {
                /*
                WIll run only if not array or is undefined || array but empty will then prompt to close modal
                and send promise resolution in order to not affect the other modals that should pop up after
                 */
                this.setProperties("open");
                this.disableClose = true;
            } else {
                /*
                Refine and figure out why this isn't closing the instance like expected
                 */
                this.setProperties("close");
                this.handleClose();
            }
            if (this.displayModal) {
                const modal = this.template.querySelector('[data-id="facilityModal"]');
                if (this.backDropElement == null) {
                    this.backDropElement = this.template.querySelector(".slds-backdrop");
                }
                if (modal) {
                    if (this.firstElement == null) {
                        this.firstElement = this.template.querySelector('[data-id="facilityModal"]');
                    }
                    if (this.lastElement == null) {
                        this.lastElement = this.template.querySelector('[data-id="acknowledgeButton"]');
                    }
                }
                if (this.initialRenderComplete === false) {
                    this.handleRenderedOpen();
                } else if (this.displayModal === false && this.initialRenderComplete === true) {
                    this.handleRenderedClosed();
                }
            }
        }
        this.hasRendered = true;
    }

    delayedStart() {
        const customElement = this.template.querySelector('[data-id="facilityHeader"]');
        if (customElement) {
            customElement.focus();
            this.loadCorrection = true;
        }
    }

    handleLoad() {
        if (this.loadCorrection === true) {
            return;
        }
        // eslint-disable-next-line
        setTimeout(() => {
            this.delayedStart();
        }, 3000);
    }

    //Accessibility Methods
    /**
     * Attempts to focus the given element.
     * @param {HTMLElement} element The element to be focused.
     * @returns Promise that resolves when the element is focused and rejects after
     * one second or if an error occurs.
     */
    focusElement(element) {
        return new Promise((resolve, reject) => {
            if (element instanceof HTMLElement) {
                let listener = (e) => {
                    element.removeEventListener("focus", listener);
                    resolve(e);
                };
                try {
                    element.addEventListener("focus", listener);
                    element.focus();
                } catch (e) {
                    element.removeEventListener("focus", listener);
                    reject("Error when focusing.");
                }
                // eslint-disable-next-line
                setTimeout(() => {
                    element.removeEventListener("focus", listener);
                    reject("Timed out.");
                }, 1000);
            } else {
                reject("Not an HTML Element.");
            }
        });
    }

    /**
     * Climbs from parent to parent until it either reaches the modal or the root component.
     * @param {HTMLElement} element an html element.
     * @returns returns true if element is a child of the modal, false otherwise.
     */
    isElementInModal(element) {
        let elementIsInModal = false;
        recursiveClimb(element, (e) => {
            if (e === this.template || e === this.template.host) {
                elementIsInModal = true;
            }
        });
        return elementIsInModal;
    }

    /**
     * Re-directs focus under certain conditions.
     * @param {HTMLElement} elementLosingFocus the element losing focus.
     * @param {HTMLElement} elementGainingFocus the element gaining focus.
     */
    controlFocus(elementLosingFocus, elementGainingFocus) {
        if (this.firstElement && this.lastElement) {
            let fromFirst, fromLast, fromInModal, fromOther;
            let toFirst, toLast, toInModal, toOther;

            fromFirst = elementLosingFocus === this.firstElement;
            fromLast = elementLosingFocus === this.lastElement;
            fromInModal = this.isElementInModal(elementLosingFocus) && !(fromFirst || fromLast);
            // eslint-disable-next-line no-unused-vars
            fromOther = !(fromFirst || fromLast || fromInModal);

            toFirst = elementGainingFocus === this.firstElement;
            toLast = elementGainingFocus === this.lastElement;
            toInModal = this.isElementInModal(elementGainingFocus) && !(toFirst || toLast);
            toOther = !(toFirst || toLast || toInModal);

            if (fromLast === true && toOther === true) {
                this.firstElement.focus();
            } else if (fromFirst === true && toOther === true) {
                this.lastElement.focus();
            }
        }
    }

    handleRenderedOpen() {
        //attaching event listeners
        this.template.addEventListener("mousedown", this.handleClick);
        window.addEventListener("focusout", this.handleWindowFocusOut);
        //focusing the close button to be consistent with OOB salesforce modal behavior
        this.focusElement(this.firstElement).catch(() => {
            // console.warn("vccModal was unable to focus first element.");
        });
        //initial render complete
        this.initialRenderComplete = true;
    }

    handleRenderedClosed() {
        this.setProperties("reset");
        //removing event listeners when modal is closed
        this.template.removeEventListener("mousedown", this.handleClick);
        window.removeEventListener("focusout", this.handleWindowFocusOut);
    }

    handleClick(event) {
        if (this.userNavigationType !== NavType.MOUSE) {
            this.userNavigationType = NavType.MOUSE;
            // dispatch events on button click for incoming buttons array
            if (event?.target?.dataset?.handler) {
                const evt = new CustomEvent(event.target.dataset.handler, {
                    bubbles: true,
                    cancelable: false,
                    composed: true
                });
                this.dispatchEvent(evt);
            }
        }
    }

    handleWindowFocusOut(event) {
        if (this.displayModal) {
            event.stopPropagation();
            if (this.displayModal === true && this.userNavigationType === NavType.KEYBOARD) {
                this.focusElement(this.firstElement).catch(() => {});
            }
        }
    }

    handleFacilityFocusOut(event) {
        if (this.displayModal) {
            event.preventDefault();
            event.stopPropagation();
            // Check if the new focus target is outside the modal
            const isFocusOutsideModal = !this.isElementInModal(event.relatedTarget);
            if (isFocusOutsideModal) {
                if (this.displayModal && this.userNavigationType === NavType.KEYBOARD) {
                    this.controlFocus(event.target, event.relatedTarget);
                }
            }
        }
    }

    setProperties(state) {
        switch (state) {
            case "open":
                document.body.style.overflow = "hidden";
                this.displayModal = true;
                this.modalSessionId = crypto.getRandomValues(new Uint32Array(1))[0];
                break;
            case "close":
                this.displayModal = false;
                document.body.style.overflow = "visible";
                this.modalSessionId = null;
                break;
            case "reset":
                this.modalSessionId = null;
                this.initialRenderComplete = false;
                this.displayModal = false;
                // this.displayContainer = false;
                this.callingElement = undefined;
                this.firstElement = undefined;
                this.lastElement = undefined;
                this.isLoading = true;
                this.hasError = false;
                this.modalSessionId = null;
                this.errorMessage = "";
                break;
            default:
                break;
        }
    }
}
