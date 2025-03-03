import { LightningElement } from "lwc";

export default class BaseBack extends LightningElement {
    connectedCallback() {
        window.history.back();
    }
}
