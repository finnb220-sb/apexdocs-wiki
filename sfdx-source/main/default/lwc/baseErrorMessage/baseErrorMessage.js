import { LightningElement, api } from 'lwc';

export default class BaseErrorMessage extends LightningElement {
    css = {};
    iconName;
    messagePrefix = '';

    //? incoming example
    // 	message: "Lorem ipsum dolor sit amet consectetur adipisicing elit. Odio harum culpa esse quas voluptatibus!",
    // 	variant: "warning"
    //  styling: "slds-align_absolute-center"

    @api message;
    @api variant;
    @api styling; //? not required
    @api override;

    /**
     * @description builds the message dynamically to fire off re-rendering message
     */
    get _message() {
        return this.messagePrefix + this.message;
    }

    connectedCallback() {
        if (this.variant?.length === 0) {
            return;
        }
        this.setValues();
    }

    renderedCallback() {
        //? guard clause to make sure the message is built only once
        if (this._message?.length > this.message || this.variant?.length === 0) {
            return;
        }
        this.setValues();
    }

    setValues() {
        this.css.container = this.styling ? this.styling + ' content' : 'slds-align_absolute-center content';
        this.css.icon = 'icon ' + this.variant;
        this.css.message =
            `slds-text-title_bold slds-col slds-m-left_x-small message ${this.override ? this.override : ''} ` +
            this.variant;
        switch (this.variant) {
            case 'warning':
                this.iconName = 'utility:warning';
                this.messagePrefix = 'WARNING: ';
                break;
            case 'error':
                this.iconName = 'utility:error';
                this.messagePrefix = 'ERROR: ';
                break;
            case 'important':
                this.iconName = 'utility:warning';
                this.messagePrefix = 'IMPORTANT! ';
                break;
            case 'note':
                this.iconName = 'utility:info_alt';
                this.messagePrefix = 'NOTE: ';
                break;
            case 'success':
                this.iconName = 'utility:success';
                this.messagePrefix = 'SUCCESS! ';
                break;
            default:
                break;
        }
    }
}
