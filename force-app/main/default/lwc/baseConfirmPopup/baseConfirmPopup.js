import { api } from 'lwc';
import LightningModal from 'lightning/modal';

/**
 * @description This lwc serves as a base warning modal to be used across the project
 */
export default class baseConfirmPopup extends LightningModal {
    @api title;
    @api content; //Specific Message that the warning modal should display
    @api variant = 'warning'; // Default to warning, but can be success, note, error, etc. See base-error-message LWC
    @api styling = 'slds-align_absolute-center'; // Default for centered base-error-message
    @api next = 'Continue';
    @api nextVariant = 'brand'; // Default to brand, can be base, neutral, brand, destructive, inverse, or success

    @api cancel;
    @api cancelVariant; // Can be base, neutral, brand, destructive, inverse, or success

    @api directional; // boolean true or false to drive whether the buttons are separated

    get directionalBump() {
        return 'slds-col' + (this.directional ? ' slds-col_bump-left' : '');
    }

    /**
     * @description This method closes the warning modal when the 'X' buton has been clicked
     */
    handleClose() {
        this.close();
    }

    /**
     * @description This method closes the warning modal after 'next' has been clicked.
     */
    handleNext() {
        this.close(this.next);
    }

    /**
     * @description This method closes the warning modal after 'cancel' has been clicked.
     */
    handleCancel() {
        this.close(this.cancel);
    }
}
