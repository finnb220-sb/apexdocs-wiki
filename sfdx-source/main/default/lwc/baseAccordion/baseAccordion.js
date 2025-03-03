/**
 * @description LWC used to style the messages returned to address management component.
 */
import { LightningElement, api } from 'lwc';

export default class BaseAccordion extends LightningElement {
    @api iconName; // A string of the icon name (i.e. 'utility:warning')
    @api iconAlt;
    @api text;
    @api colorBackground = ''; // A string for a CSS value to set the background colour 'white' or other valid CSS
    @api colorFont = 'black'; // A string for a CSS value to set the font color 'rgb(0,0,0)' or other valid CSS
    @api colorIcon = 'black'; // A string for a CSS value to set the icon color 'red' or other valid CSS

    /**
     * @description This is used to style the accordian of potential errors or messages the address management component receives.
     */
    connectedCallback() {
        this.style.setProperty('--background-color', this.colorBackground);
        this.style.setProperty('--font-color', this.colorFont);
        this.style.setProperty('--icon-color', this.colorIcon);
    }
}
