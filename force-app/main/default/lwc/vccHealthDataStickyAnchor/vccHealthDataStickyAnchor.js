import { LightningElement, api } from "lwc";

/**
 * @description LWC Anchor to give us measurement relative to the viewport for our Health Data Sticky Component
 */
export default class VccHealthDataStickyAnchor extends LightningElement {
    @api recordId;
    hasRun;

    /**
     * @description Runs after the component has been rendered on the page
     */

    renderedCallback() {
        if (!this.hasRun) {
            setTimeout(this.publishHeight, 500);
            window.addEventListener("resize", this.publishHeight);
            window.addEventListener("scroll", this.publishHeight);
            this.hasRun = true;
        }
    }

    /**
     * @description Publishes the height of the anchor as the component changes
     */

    publishHeight = () => {
        let lmsPublisher = this.template?.querySelector("c-vcc-l-m-s-publisher");
        let yAnchor = lmsPublisher?.getBoundingClientRect().y;
        let finalHeight = window.scrollY + yAnchor;
        const message = { recordId: this.recordId, componentName: "vccHealthDataSticky", values: finalHeight };
        lmsPublisher.publishMessage("vccUIUpdate", message);
    };

    /**
     * @description removes the two event listeners that we added in the connected callback
     */

    disconnectedCallback() {
        window.removeEventListener("resize", this.publishHeight);
        window.removeEventListener("scroll", this.publishHeight);
    }
}
