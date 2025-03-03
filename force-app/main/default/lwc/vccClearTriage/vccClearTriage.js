import { LightningElement, track, api } from 'lwc';

/**
 * @description This is the ClearTriage Lightning Web Component. When added to a page in Salesforce, it will load ClearTriage
 * in an iframe.
 */

export default class VccClearTriage extends LightningElement {
    @api srcUrl;
    @api ctAccessKey;
    @api userVisn;
    iframeElement;
    @track isRendered = false;
    @track ctCallNote;

    messageEventListener = (event) => {
        this.handleMessage(event);
    }
    beforeUnloadEventListener = (event) => {
        this.handleBeforeUnload(event);
    }

    renderedCallback() {
        if (this.isRendered) {
            return;
        }
        this.isRendered = true;
        // Create the iframe
        this.iframeElement = document.createElement('iframe');
        this.iframeElement.src = `${this.srcUrl}/app/login/license/${this.ctAccessKey}?visn=${this.userVisn}`;
        this.iframeElement.width = '100%';
        this.iframeElement.height = '755';
        this.iframeElement.frameBorder = '0';

        // Append iframe to the component
        this.template.querySelector('div[id^="cleartriage-iframe"]').appendChild(this.iframeElement);

        // Add postMessage and load event listeners
        window.addEventListener('message', this.messageEventListener, false);
        window.addEventListener('beforeunload', this.handleBeforeUnload, false);
    }

    /**
     * @description ensure the event listners are removed when the component is removed from the DOM
     */
    disconnectedCallback() {
        window.removeEventListener('message', this.messageEventListener, false);
        window.removeEventListener('beforeunload', this.beforeUnloadEventListener, false);
    }

    /**
     * @description handle the message event from the iframe
     * @param {*} event
     */
    handleMessage(event) {
        let dataChangedEvent;
        switch (event.data.subject) {
            case 'ct-ready':
                this.initializeCt();
                break;
            case 'ct-call-summary':
                this.ctCallNote = event.data.messageBody.callSummaryText;
                dataChangedEvent = new CustomEvent('datachanged', {
                    detail: event.data.messageBody
                });
                this.dispatchEvent(dataChangedEvent);
                // after clicking Finish Triage, remove listeners
                window.removeEventListener('message', this.messageEventListener, false);
                window.removeEventListener('beforeunload', this.beforeUnloadEventListener, false);
                break;
            default:
                break;
        }
    }

    /**
     * @description initialize the ClearTriage iframe
     */
    initializeCt() {
        const message = {
            subject: 'ct-init'
        };
        const iframeOrigin = this.srcUrl;

        if (this.iframeElement?.contentWindow) {
            this.iframeElement.contentWindow.postMessage(message, iframeOrigin);
        }
    }

    /**
     * @description remove listeners if user starts triage, navigates away via browser back button
     */
    handleBeforeUnload(event) {
        window.removeEventListener('message', this.messageEventListener, false);
        window.removeEventListener('beforeunload', this.beforeUnloadEventListener, false);
    }

}