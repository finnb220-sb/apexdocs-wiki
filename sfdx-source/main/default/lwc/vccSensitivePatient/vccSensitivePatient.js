import { /*LightningElement,*/ api } from 'lwc';
import LightningModal from 'lightning/modal';
import acknowledgeSenstivePatient from '@salesforce/apex/VCC_lwc_utils.acknowledgeSenstivePatient';
import sensitivePopupLabel from '@salesforce/label/c.VCC_Sensitive_Patient_Popup_Message';

/**
 * @description This const maps known modal sizes to known SLDS modal CSS classes.
 * - Aids in accurately setting modal sizes
 * - This sensitive patient modal may never be anything other than "small" or an un-sized modal.
 *   - But this is a pattern we could incorporate into other modals or into BaseLightningModal
 * @type {{small: string, medium: string, large: string, full: string}}
 * @see adjustCSS
 */
const MODAL_SIZE_CLASS_MAP = {
    small: 'slds-modal_small',
    medium: 'slds-modal_medium',
    large: 'slds-modal_large',
    full: 'slds-modal_full'
};

/**
 * @description The VCC_Sensitive_Patient_Popup_Message custom label contains this token wherever we want a line break.
 * @type {string}
 */
const LABEL_BR_TOKEN = '{0}';
/**
 * @description An HTML line break that will replace all instances of LABEL_BR_TOKEN
 * @type {string}
 */
const HTML_BR_ELEMENT = '<br/>';

export default class VccSensitivePatient extends LightningModal {
    /**
     * @description Used in acknowledge Apex method
     * @see VCC_lwc_utils.acknowledgeSenstivePatient
     */
    @api recordId;

    /**
     * @description Indicates if CSS has been adjusted in `renderedCallback()` lifecycle function
     * - Prevents excessive execution of `adjustCSS()` function when `renderedCallback()` is called multiple times during component lifecycle
     * @type {boolean}
     */
    adjustedCSS = false;

    /**
     * @description Indicates if we've already put focus on the body/message, which we only want to do once, when the modal loads
     * @type {boolean}
     */
    focusedOnMessage = false;

    /**
     * @description Standard lifecycle function. On first-rendering of this LWC, we:
     * - Adjust modal's size via `adjustCSS()` function
     * - Focus on the <div> containing the content of the modal
     */
    renderedCallback() {
        this.adjustCSS();
        this.focusOnMessage();
    }

    /**
     * @description Returns HTML-friendly value of VCC_Sensitive_Patient_Popup_Message for use in lightning-formatted-rich-text
     * @return {string}
     */
    get message() {
        return this.prepStringAsHTML(sensitivePopupLabel);
    }

    /**
     * @description Replaces {0} tokens in provided string with <br> elements
     * @param {String} value the value to be processed
     * @return the value as an HTML-ready string
     */
    prepStringAsHTML(value = '') {
        return value.replaceAll(LABEL_BR_TOKEN, HTML_BR_ELEMENT);
    }

    /**
     * @description Finds this modal's `<section>` tag and adjusts its CSS classes in the following manner:
     * - Removes the 'slds-modal_medium' class
     *   - This is a workaround for a known bug on some devices where lightning-modal always renders a "medium" sized modal, regardless of what argument is passed to a modal LWC's `size` property
     * - This also lets us render an "unsized" lightning-modal that is even narrower than the slds-modal_small class
     * - Respects `this.adjustedCSS` flag to not execute more than once.
     */
    adjustCSS() {
        if (!this.adjustedCSS) {
            const modalSection = this.findModalSectionElement();
            if (modalSection) {
                //remove the default medium css class from the section element
                modalSection.classList.remove('slds-modal_medium');

                //if `size` property has a valid value that comes with a known SLDS modal class...
                // add that SLDS class back to the section element
                const newClass = MODAL_SIZE_CLASS_MAP[this.size];
                if (newClass) {
                    modalSection.classList.add(newClass);
                }

                //flip flag to not do this again
                this.adjustedCSS = true;
            }
        }
    }

    /**
     * @description This queries the DOM to find the <section> element rendered by lightning-modal-base.
     * - This assists in the CSS class adjustment workaround for known lightning-modal sizing bug
     * - This function assumes the lightning modal DOM structure to be something like:
     * @example
     * <!-- pseudo DOM rendered by LWC that extends LightningModal -->
     * <!-- extra attributes, classes, and elements omitted for brevity -->
     * <section class="slds-modal" role="dialog">
     *     <div class="slds-modal__container">
     *         <lightning-button-icon class="slds-button slds-button_icon slds-modal__close" variant="bare" size="large"></lightning-button-icon>
     *         <div>
     *             <!-- Your LWC that extends LightningModal "owns" the markup starting with <lightning-modal> tag -->
     *             <lightning-modal>
     *                 <lightning-modal-header>
     *                     <div class="slds-modal__header">
     *                         <slot></slot>
     *                     </div>
     *                 </lightning-modal-header>
     *                 <lightning-modal-body>
     *                     <div class="slds-modal__content">
     *                         <slot></slot>
     *                     </div>
     *                 </lightning-modal-body>
     *                 <lightning-modal-footer>
     *                     <div class="slds-modal__footer">
     *                         <slot></slot>
     *                     </div>
     *                 </lightning-modal-footer>
     *             </lightning-modal>
     *         </div>
     *     </div>
     * </section>
     * @return {Element}
     */
    findModalSectionElement() {
        let result;
        //this LWC uses a lightning-modal header, so find that...
        const modalHeader = this.template.querySelector('lightning-modal-header');
        if (modalHeader) {
            //then find closest to that the <section> tag having the slds-modal class
            result = modalHeader.closest('section.slds-modal');
        }
        return result;
    }

    /**
     * @description Finds the body lwc:ref and puts user focus on it.
     * - Called on load, and respects `this.focusedOnMessage` in order to only execute once
     */
    focusOnMessage() {
        if (!this.focusedOnMessage) {
            const body = this.refs?.body;
            if (body) {
                body.focus();
                this.focusedOnMessage = true;
            }
        }
    }

    /**
     * @description Handles click event from "Go back to home" button
     * - Calls `close()` function inherited from LightningModal, passing an undefined value, indicating user has NOT acknowledged the sensitive patient warning
     * - Whatever component opened this modal is responsible for correctly handling the resolved value.
     * @example
     * VccSensitivePatient.open()
     * .then((acknowledged) => {
     *   if(acknowledged){
     *     //do something
     *   }
     *   else{
     *     //do something else
     *   }
     * })
     * @see VccPersonAccountOnRead
     */
    handleBackToHomeClick() {
        this.close(undefined);
    }

    /**
     * @description Handles click event from "Acknowledge and Continue" button
     * - Calls `close()` function inherited from LightningModal, passing a `true` value, indicating user has acknowledged the sensitive patient warning
     * - Whatever component opened this modal is responsible for correctly handling the resolved value.
     * @example
     * VccSensitivePatient.open()
     * .then((acknowledged) => {
     *   if(acknowledged){
     *     //do something
     *   }
     *   else{
     *     //do something else
     *   }
     * })
     * @see VccPersonAccountOnRead
     */
    handleAcknowledgeClick() {
        acknowledgeSenstivePatient({ recordId: this.recordId }).then(() => {
            this.close(true);
        });
    }
}
