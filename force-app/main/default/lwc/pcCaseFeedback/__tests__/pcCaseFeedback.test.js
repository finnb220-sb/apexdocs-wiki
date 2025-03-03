import { createElement } from 'lwc';
import PcCaseFeedback from 'c/pcCaseFeedback';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import getIsSubmitted from '@salesforce/apex/PC_CaseFeedbackController.getIsSubmitted';
import getFeedbackQuestions from '@salesforce/apex/PC_CaseFeedbackController.getFeedbackQuestions';
import submitFeedback from '@salesforce/apex/PC_CaseFeedbackController.submitFeedback';
import { ShowToastEventName } from 'lightning/platformShowToastEvent';

const mockGetObjectInfo = require('./data/getObjectInfo.json');
const mockGetPicklistValues = require('./data/getPicklistValues.json');
const mockGetFeedbackQuestions = require('./data/getFeedbackQuestions.json');

// Mocking getProgressNote imperative Apex method call
jest.mock(
    '@salesforce/apex/PC_CaseFeedbackController.submitFeedback',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

// Mock getContactList Apex wire adapter
jest.mock(
    '@salesforce/apex/PC_CaseFeedbackController.getIsSubmitted',
    () => {
        const { createApexTestWireAdapter } = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);
// Mock getContactList Apex wire adapter
jest.mock(
    '@salesforce/apex/PC_CaseFeedbackController.getFeedbackQuestions',
    () => {
        const { createApexTestWireAdapter } = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

describe('c-pc-case-feedback', () => {
    let element;
    beforeEach(async () => {
        element = createElement('c-pc-case-feedback', {
            is: PcCaseFeedback
        });

        document.body.appendChild(element);
    });

    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });
    // Helper function to wait until the microtask queue is empty. This is needed for promise
    // timing when calling imperative Apex.
    async function flushPromises() {
        return Promise.resolve();
    }
    it('stuff', async () => {
        const confirmSpy = jest.spyOn(window, 'confirm');
        confirmSpy.mockImplementation(() => true);

        element.recordId = '123';
        element.role = 'Test';

        // eslint-disable-next-line @lwc/lwc/no-unexpected-wire-adapter-usages
        getObjectInfo.emit(mockGetObjectInfo);

        // eslint-disable-next-line @lwc/lwc/no-unexpected-wire-adapter-usages
        getPicklistValues.emit(mockGetPicklistValues);

        // eslint-disable-next-line @lwc/lwc/no-unexpected-wire-adapter-usages
        getIsSubmitted.emit(false);

        // eslint-disable-next-line @lwc/lwc/no-unexpected-wire-adapter-usages
        getFeedbackQuestions.emit(mockGetFeedbackQuestions);
        submitFeedback.mockResolvedValue({});

        const handler = jest.fn();
        element.addEventListener(ShowToastEventName, handler);

        await flushPromises();

        //dispatchEvent
        //ShowToastEvent

        // Select the lightning-formatted-text element
        const questions = element.shadowRoot.querySelectorAll('lightning-formatted-text');

        // Assert that the datatable data matches the mock data
        for (let i = 0; i < questions.length; i++)
            expect(questions[i].value).toBe(mockGetFeedbackQuestions[i].PC_Question__r.PC_Question__c);

        // Mock the reportValidity and validity.valid properties
        const comboboxes = element.shadowRoot.querySelectorAll('lightning-combobox');
        comboboxes.forEach((combobox) => {
            combobox.reportValidity = jest.fn(() => true);
            combobox.checkValidity = jest.fn(() => true);
        });

        // Click button
        element.shadowRoot.querySelector('lightning-button').click();

        await flushPromises();

        expect(handler).toHaveBeenCalled();
        expect(handler.mock.calls[0][0].detail.title).toBe('Success');
        expect(handler.mock.calls[0][0].detail.message).toBe('Feedback submitted.');
        expect(handler.mock.calls[0][0].detail.variant).toBe('success');
        expect(handler.mock.calls[0][0].detail.mode).toBe('dismissible');
    });
});
