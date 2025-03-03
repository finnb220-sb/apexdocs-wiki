/**
 * @description Blurs the screen. The z-index specified in the css should only blur
 * the record page contents and not the navigation bar/menu.
 * @author Booz Allen Hamilton
 */
import { api, LightningElement } from 'lwc';

export default class VccGlobalBlur extends LightningElement {
    isBlurred = false;

    /**
     * @description shows the blur and disables scrolling
     */
    @api
    show() {
        this.isBlurred = true;
    }

    /**
     * @description hides the blur from the screen and enables scrolling
     */
    @api
    hide() {
        this.isBlurred = false;
    }
}
