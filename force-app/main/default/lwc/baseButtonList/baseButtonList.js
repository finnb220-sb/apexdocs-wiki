/**
 * @description List of buttons to render
 */
import { LightningElement, api } from 'lwc';

export default class BaseButtonList extends LightningElement {
    _buttons;
    _styles;
    triggerRender;

    @api
    set buttons(value) {
        this._buttons = value;
    }

    get buttons() {
        return this._buttons;
    }

    @api
    set styles(value) {
        this._styles = value;
    }

    get styles() {
        return this._styles;
    }

    /**
     * @description this method handles a click event from the buttons rendered in this list.
     * Using the "data-id" attribute of the button that was clicked, this handler will dispatch an event to the parent component indicating which button was clicked
     *
     * @param event Event dispatched from a button rendered in this component
     */

    handleButtonClick(event) {
        const { id } = event.target.dataset;
        this.dispatchEvent(
            new CustomEvent(id, {
                bubbles: true,
                composed: true,
                detail: { operation: { name: 'button', button: event.target.dataset.id } }
            })
        );
    }

    /**
     * @description this method allows the parent component to modify the html attributes of buttons rendered in this component
     * @param buttons - an array of button objects with a property of "name" that matches the "data-id" attribute of the button to modify and an attribute to modify
     * @example baseButtonList.modifyButtons([{name: 'button1', disabled: true}, {name: 'button1', label: 'Changing Label of Button 1'}]) // targets "button 1", disables it and changes its label
     */

    @api
    modifyButtons(buttons) {
        if (buttons?.length) {
            for (const button of buttons) {
                const buttonToModify = this.template.querySelector(`[data-id='${button.name}']`);
                if (buttonToModify) {
                    for (const [key, value] of Object.entries(button)) {
                        buttonToModify[key] = value;
                    }
                }
            }
        }

        this.triggerRender = !this.triggerRender;
    }
}
