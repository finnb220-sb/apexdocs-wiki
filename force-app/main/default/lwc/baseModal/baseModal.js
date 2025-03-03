import { api, LightningElement, track, wire } from "lwc";
import { recursiveClimb } from "./TreeUtils";
import { genericHelper } from "c/utils";

import { subscribe, unsubscribe, MessageContext } from "lightning/messageService";
import baseAddToNoteMC from "@salesforce/messageChannel/vccBaseAddToNote__c";

const createUID = genericHelper.uniqueId;

const NavType = {
    KEYBOARD: Symbol("keyboard"),
    MOUSE: Symbol("mouse")
};

export default class BaseModal extends LightningElement {
    /** Properties */

    @api title = "";

    @api labelOverrides;

    get modalLabels() {
        return {
            close: this.labelOverrides?.close || "Close"
        };
    }

    subscription = null;
    @wire(MessageContext)
    messageContext;

    // a random unsigned 32 bit integer generated every time the modal opens
    modalSessionId;

    // determines the behavior of focus trapping
    userNavigationType = NavType.KEYBOARD;

    // modal sizing property

    modalClass = "modal slds-fade-in-open";
    @api set size(val) {
        if (val && typeof val === "string") {
            this._size = val;

            switch (val) {
                case "small":
                    this.modalClass += " slds-modal_small";

                    break;
                case "medium":
                    this.modalClass += " slds-modal_medium";
                    break;
                case "large":
                    this.modalClass += " slds-modal_large";
                    break;
                default:
                    break;
            }
        }
    }
    get size() {
        return this._size;
    }

    @api
    setSizeExternal(size) {
        switch (size) {
            case "small":
                // const modalDiv = this.template.querySelector("[data-id='modal-container']").classList.add('modal_40');

                // this.template.querySelector(`[data-id='startDate']`)?.value;

                break;
            case "medium":
                break;
            case "large":
                break;
            default:
                break;
        }
    }

    @api preventClose = false; //prevents the modal from closing
    displayModal = false; //set to true via 'open' function, controls html rendering
    displayContainer = true; //set to true after backdrop animation ends, controls html rendering
    errorMessage = "";
    isLoading = true;
    hasError = false;
    rerenderTrigger = false;

    initialRenderComplete = false;
    @api nextdisable;
    @api prevdisable;
    @api showbtns;
    @api recordcount;

    // all html elements
    callingElement; //the element that opened the modal (to focus again after closing)
    firstElement; //should always be the 'X' button in top right of modal
    lastElement; //should always be the 'close' button in bottom right of modal
    backDropElement; //should always be the...backdrop

    // Default footer display to true
    @track _showFooter = true;
    @api set showfooter(bool) {
        if (bool !== undefined && bool !== null) {
            // sets value as string
            this._showFooter = bool == "true";
        }
    }
    get showfooter() {
        return this._showFooter;
    }

    /**
     * Button Logic
     * Expects a list of javascript "button config" objects with the required properties label,type and handler
     */

    _buttons;

    @api set buttons(value) {
        /** is value a non-empty array? and does each item in the array contain a label property?*/
        if (value?.length && value.every((button) => button.label && button.variant)) {
            value = value.map((button) => {
                return { ...button, uid: createUID() }; // unique id for iteration key
            });
            this._buttons = value;
        } else {
            // eslint-disable-next-line no-console
            console.error("VAHC Exception - One or more buttons is missing a required property");
        }
    }

    get buttons() {
        return this._buttons;
    }

    /** Lifecycle Hooks */

    constructor() {
        super();
        this.handleKeyDown = this.handleKeyDown.bind(this);
        this.handleWindowFocusOut = this.handleWindowFocusOut.bind(this);
        this.handleClick = this.handleClick.bind(this);
        this.handleModalFocusOut = this.handleModalFocusOut.bind(this);
    }

    connectedCallback() {
        // this.template.addEventListener("closemodal", this.close());
        //subscribing to the Lightning Message Service Channel
        if (!this.subscription) {
            this.subscription = subscribe(this.messageContext, baseAddToNoteMC, (message) => this.handleAddToNoteMessage(message));
        }
    }

    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    renderedCallback() {
        if (this.backDropElement == null) {
            this.backDropElement = this.template.querySelector(".modal__backdrop");
        }
        if (this.displayModal) {
            if (this.firstElement == null) {
                this.firstElement = this.template.querySelector(".slds-modal__close");
            }
            if (this.lastElement == null) {
                if (this._buttons?.length) {
                    this.lastElement = this.template.querySelector(".buttons");
                } else {
                    this.lastElement = this.template.querySelector(".slds-modal__footer > lightning-button");
                }
            }
        }
        if (this.displayContainer === true && this.initialRenderComplete === false) {
            this.handleRenderedOpen();
        } else if (this.displayModal === false && this.initialRenderComplete === true) {
            this.handleRenderedClosed();
        }
    }

    /** Methods */

    setProperties(state) {
        switch (state) {
            case "open":
                document.body.style.overflow = "hidden";
                this.displayModal = true;
                // this.backDropElement.classList.add("slds-backdrop_open");
                this.modalSessionId = crypto.getRandomValues(new Uint32Array(1))[0];
                break;
            case "close":
                this.displayModal = false;
                // this.backDropElement.classList.remove("slds-backdrop_open");
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

    @api
    open(elementThatOpenedModal, loadingPromise) {
        this.setProperties("open");
        this.callingElement = elementThatOpenedModal;
        if (loadingPromise instanceof Promise) {
            /**
             * The variable 'contextSessionId' saves the value of 'modalSessionId' at the time that open() is called.
             * This prevents issues with 'loadingPromise' resolving for a previous modal opening.
             *
             * For example:
             * If the user opens and closes and opens the modal in quick succession, the promise from the first open would
             * resolve for the second time the modal opened.
             */
            let contextSessionId = this.modalSessionId;
            loadingPromise
                .then(() => {
                    if (this.displayModal === true && this.modalSessionId === contextSessionId) {
                        this.isLoading = false;
                    }
                })
                .catch((error) => {
                    if (this.displayModal === true && this.modalSessionId === contextSessionId) {
                        this.isLoading = false;
                        this.hasError = true;
                        this.errorMessage = error;
                    }
                });
        } else {
            this.isLoading = false;
        }
    }

    @api
    close() {
        this.setProperties("close");
        this.focusElement(this.callingElement).catch(() => {
            // console.warn("vccModal couldn't focus element that opened the modal.");
        });

        //dispatches a custom event that can be handled in a parent component
        const closedEvent = new CustomEvent("basemodalclosed", { detail: true });
        this.dispatchEvent(closedEvent);
    }

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

    /** Handlers */

    handleAddToNoteMessage(payload) {
        //? use the payload data to locate the correct button to change the property for
        if (!this._buttons) return;

        this._buttons.forEach((button) => {
            if (payload.buttonLabel !== button.label) return;
            button.deactivated = payload.deactivateButton;
            this.rerenderTrigger = payload.deactivateButton;
        });
    }

    handleRenderedOpen() {
        //attaching event listeners
        this.template.addEventListener("mousedown", this.handleClick);
        //! const modalBackdrop = this.template.querySelector('.modal__backdrop');
        //! modalBackdrop.addEventListener("click", this.handleClose);
        window.addEventListener("keydown", this.handleKeyDown);
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
        window.removeEventListener("keydown", this.handleKeyDown);
        window.removeEventListener("focusout", this.handleWindowFocusOut);
    }

    handleBackdropTransitionEnd(event) {
        if (event.target.classList.contains("slds-backdrop_open")) {
            this.displayContainer = true;
        }
    }

    handleHeaderSlotChange(event) {
        if (event.target) {
            event?.target?.parentNode?.classList?.remove("slds-modal__header_empty");
        }
    }

    handleClose() {
        if (this.preventClose === false) {
            this.close();
        }
    }

    handleKeyDown(event) {
        this.userNavigationType = NavType.KEYBOARD;
        switch (event.key) {
            case "Escape":
                this.dispatchEvent(
                    new CustomEvent("escape", {
                        detail: {
                            target: event
                        }
                    })
                );
                break;
            case "Enter":
                if (event.target.contentEditable === false) {
                    this.dispatchEvent(
                        new CustomEvent("enter", {
                            detail: {
                                target: event
                            }
                        })
                    );
                }
                break;
            default:
                break;
        }
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
        event.stopPropagation();
        if (this.displayModal === true && this.userNavigationType === NavType.KEYBOARD) {
            this.focusElement(this.firstElement).catch(() => {});
        }
    }

    handleModalFocusOut(event) {
        event.stopPropagation();
        if (this.displayModal && this.userNavigationType === NavType.KEYBOARD) {
            this.controlFocus(event.target, event.relatedTarget);
        }
    }

    clickHandle(event) {
        const selectedEvent = new CustomEvent("nextvaluechange", {
            detail: {
                label: event.target.label,
                name: event.target.name
            },
            composed: true,
            bubbles: true
        });

        this.dispatchEvent(selectedEvent);
    }

    handleFooterButtonClick(event) {
        const dataId = event.target.dataset.id;

        const visualPicker = this.querySelector("c-vcc-base-vertical-visual-picker");

        if (visualPicker) {
            this.querySelector("c-vcc-base-vertical-visual-picker").submitRefill();
            this.dispatchEvent(new CustomEvent(dataId, { bubbles: true }));
            this.close();
        }

        const addToNote = this.querySelector("c-base-add-to-note-frame");

        if (addToNote) {
            addToNote.buttonPressed("Submit");
        }

        const futureRenewalRequest = this.querySelector("c-vcc-meds-future-renewal-request");

        if (futureRenewalRequest) {
            futureRenewalRequest.buttonPressed("Submit");
        }
    }
}
