import { LightningElement, api } from "lwc";
import { proxyTool } from "c/helpersLWC";

export default class BaseCompactCard extends LightningElement {
    _title;
    _icon;

    @api list; // flat list of data

    @api variant;

    // setters and getters
    @api
    set settings(val) {
        this._title = val?.title ? val.title : "generic";
        this._icon = val?.icon ? val.icon : "standard:custom_component_task";
    }

    get settings() {
        return {
            title: this._title,
            icon: this._icon
        };
    }

    handleClick(event) {
        this.dispatchEvent(new CustomEvent("cardclick", { detail: { value: this.pickItem(event.currentTarget.value), variant: this.variant } }));
    }

    connectedCallback() {
        return;
    }

    pickItem(id) {
        return this.list.filter((entry) => entry.Id === id)[0];
    }
}
