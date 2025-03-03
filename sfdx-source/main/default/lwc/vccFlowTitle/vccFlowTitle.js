/**
 * @description LWC intended to provide a configurable title and Icon for flow screens.
 */
import { LightningElement, api } from 'lwc';

const ICON_CSSCLASS_MINIMUM = 'slds-var-p-around_xx-small';

export default class VccFlowTitle extends LightningElement {
    @api wrapperCssClass = 'slds-var-m-bottom_medium slds-var-m-top_small';

    @api hideIcon = false;
    get showIcon() {
        return !this.hideIcon;
    }
    @api iconName = 'utility:clear';
    @api iconSize = 'small';
    @api iconCssClass;
    /**
     * @description Concatenates whatever iconCssClass has with the minimum class(es) defined in the constant.
     * Ensures minimum classes are always present.
     * @returns {string}
     */
    get iconCssClassEvaluated() {
        return ICON_CSSCLASS_MINIMUM + ' ' + this.iconCssClass;
    }
    @api iconVariant;
    @api iconForegroundColor;
    @api iconBackgroundColor;

    @api title = 'Title';
    @api titleCssClass = 'slds-text-heading_small';

    /**
     * @description update icon colors on first render
     */
    renderedCallback() {
        this.updateIconColors();
    }

    appliedIconCss = false;
    /**
     * @description Called by renderedCallback.
     * If icon is present and any values have been provided for foreground or background, set the stlying hooks with those foreground/background colors respectively.
     * Logic only runs once.
     */
    updateIconColors() {
        if (!this.appliedIconCss) {
            const iconElement = this.refs.theIcon ?? this.template.querySelector('lightning-icon');
            if (iconElement) {
                if (this.iconForegroundColor) {
                    iconElement.style.setProperty('--slds-c-icon-color-foreground-default', this.iconForegroundColor);
                }
                if (this.iconBackgroundColor) {
                    iconElement.style.setProperty('--slds-c-icon-color-background', this.iconBackgroundColor);
                }
            }
            this.appliedIconCss = true;
        }
    }
}
