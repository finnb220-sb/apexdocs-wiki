import { createElement } from 'lwc';
import VccCustomLookup from 'c/vccCustomLookup';
import { CurrentPageReference } from 'lightning/navigation';
import findRecords from '@salesforce/apex/VCC_LookupController.findRecords';

//pubsub has been retired in favor of LMS,
//support for jest has been added at force-app/test/jest-mocks/c/pubsub.js
import { registerListener, unregisterListener } from 'c/pubsub';

// Loading mock data stored in the data folder
const mockCurrentPageReference = require('./data/mockCurrentPageReference.json');
const mockFindRecords = require('./data/mockFindRecords.json');

// Mocking imperative Apex method call findRecords
jest.mock(
    '@salesforce/apex/VCC_LookupController.findRecords',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

// Mocking pubsub module
// TODO: Repalce pubsub use with LMS and/or update pubsub stub to remove these mocks.
jest.mock('c/pubsub', () => ({
    registerListener: jest.fn((eventName, callback, context) => {
        // Call the callback function
        callback.call(context, eventName);
    }),
    unregisterListener: jest.fn(),
    fireEvent: jest.fn()
}));

// vccCustomLookup component test suite
describe('c-wire-current-page-reference', () => {
    // Element is shared across test cases, created in beforeEach
    let element;

    // Setup the component shared across test cases
    beforeEach(() => {
        // Create component
        element = createElement('c-vcc-custom-lookup', {
            is: VccCustomLookup
        });

        // Add the element to the dom
        document.body.appendChild(element);
    });

    // Reset the DOM after each test
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

    // Test to validate if the siteChange listener is registered and unregistered
    it('registers and unregisters the siteChange listener', async () => {
        // Mock findRecords imperative Apex call
        findRecords.mockResolvedValue(mockFindRecords);

        // Emit the mockCurrentPageReference
        // eslint-disable-next-line @lwc/lwc/no-unexpected-wire-adapter-usages
        CurrentPageReference.emit(mockCurrentPageReference);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Validate if pubsub got registered after connected to the DOM
        expect(registerListener.mock.calls.length).toBe(1);
        expect(registerListener.mock.calls[0][0]).toBe('siteChange');

        // Remove from DOM
        document.body.removeChild(element);

        // Check if unregisterListener was called
        expect(unregisterListener).toHaveBeenCalled();
        expect(unregisterListener).toHaveBeenCalledWith('siteChange');
    });

    // Test to validate if the records are rendered via resetLookup on wiredPageRef
    it('renders records via resetLookup on wiredPageRef', async () => {
        // Mock findRecords imperative Apex call
        findRecords.mockResolvedValue(mockFindRecords);

        // Emit the mockCurrentPageReference
        // eslint-disable-next-line @lwc/lwc/no-unexpected-wire-adapter-usages
        CurrentPageReference.emit(mockCurrentPageReference);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Query the list items
        const listItems = element.shadowRoot.querySelectorAll('ul.slds-listbox.slds-listbox_vertical > li');

        // Validate the number of list items
        expect(listItems.length).toBe(3);

        // Validate the content of the list items
        listItems.forEach((item, index) => {
            expect(item.querySelector('span[data-visn]').getAttribute('data-visn')).toBe(
                mockFindRecords[index].VCC_VISN__c
            );
            expect(item.textContent).toBe(mockFindRecords[index].Name);
        });
    });
});
