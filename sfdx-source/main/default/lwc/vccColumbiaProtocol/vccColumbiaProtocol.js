/**
 * @description This Component parses the results from VCC Columbia Protocol flow.
 * Depending on the result different HTML components are rendered.
 */

import { LightningElement, api } from 'lwc';
import LoggerMixin from 'c/loggerMixin';

const POSITIVE_VALUES = ['yes', 'true'];

export default class VccColumbiaProtocol extends LoggerMixin(LightningElement) {
    @api recordId; //must be passed in from screen flow
    @api scoreResults; //no longer used, but present in meta.xml file and present in screen flow, so not removing.
    data = {};
    _response;
    /**
     * @description Must be passed in from screen flow. Saves value to private property.
     * Parses value to set this.data, so that we aren't passing this.response all the time in getters
     * @param value - a stringified JSON representation of CSSRS screening answers, passed in from the Columbia Screening screen flow.
     */
    @api set response(value) {
        this._response = value;
        this.data = JSON.parse(value ?? '{}');
    }
    get response() {
        return this._response;
    }
    @api initialized = false;

    /**
     * @description Indicates if question 3 was answered positive.
     * @returns {boolean}
     */
    get q3IsPositive() {
        return POSITIVE_VALUES.includes((this.data.ColumbiaQ3 ?? '').toLowerCase());
    }
    /**
     * @description Indicates if question 4 was answered positive.
     * @returns {boolean}
     */
    get q4IsPositive() {
        return POSITIVE_VALUES.includes((this.data.ColumbiaQ4 ?? '').toLowerCase());
    }
    /**
     * @description Indicates if question 5 was answered positive.
     * @returns {boolean}
     */
    get q5IsPositive() {
        return POSITIVE_VALUES.includes((this.data.ColumbiaQ5 ?? '').toLowerCase());
    }
    /**
     * @description Indicates if question 8 was answered positive.
     * @returns {boolean}
     */
    get q8IsPositive() {
        return POSITIVE_VALUES.includes((this.data.ColumbiaQ8 ?? '').toLowerCase());
    }

    /**
     * @description Used in html to show specific markup when any of the operative questions were answered positive
     * @returns {boolean}
     */
    get showPositiveScore() {
        return this.q3IsPositive || this.q4IsPositive || this.q5IsPositive || this.q8IsPositive;
    }

    /**
     * @description Used in html to show specific markup when none of the operative questions were answered positive
     * @returns {boolean}
     */
    get showNegativeScore() {
        return !this.showPositiveScore;
    }

    /**
     * @description enter a log when empty response is provided.
     */
    connectedCallback() {
        if (this.response === undefined) {
            this.Logger.error(
                'Empty Response for CSSRS. Expected a valid Response for CSSRS questionnaire to be inputed in lwc'
            );
            this.Logger.saveLog();
        }
    }

    /**
     * @description After the vccColumbiaProtocol component renders the renderedCallback method sends a lightning message notifying
     * that the questionnaire has been completed. This message is picked up by the Progress Note Preview
     * and the Progress Note Preview component refreshes so that we can see the results of the questionnaire in the Progress Note Preview.
     */
    renderedCallback() {
        if (!this.initialized) {
            const publisher = this.refs?.publisher ?? this.template.querySelector('c-vcc-l-m-s-publisher');
            if (publisher) {
                publisher.publishMessage('vccUIUpdate', {
                    recordId: this.recordId,
                    componentName: 'vccColumbiaProtocol'
                });
            }
            // eslint-disable-next-line @lwc/lwc/no-api-reassignments
            this.initialized = true;
        }
    }
}
