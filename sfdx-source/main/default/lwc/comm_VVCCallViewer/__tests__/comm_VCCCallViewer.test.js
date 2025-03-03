import { createElement } from 'lwc';
import Comm_VVCCallViewer from 'c/comm_VVCCallViewer';
import { getRecord } from 'lightning/uiRecordApi';

//Mock data is shared across across Account and Contact with the same field API name.
const mockGetRecord = {
    fields: {
        comm_VVC_URL__c: { value: 'https://www.veteran.apps.va.gov' }
    }
};

describe('c-comm_vcccallviewer', () => {
    // Element is shared across test cases, created in beforeEach
    let element;

    //Before each test, create a comm_VVCCallViewer element
    beforeEach(async () => {
        element = createElement('c-comm-vvc-call-viewer', {
            is: Comm_VVCCallViewer
        });
        element.objectApiName = 'Account';
        document.body.appendChild(element);
    });

    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    // Helper function to wait until the microtask queue is empty.
    // Used when having to wait for asynchronous DOM updates.
    async function flushPromises() {
        return Promise.resolve();
    }
    it('returns the correct vvcUrl for Account', async () => {
        // eslint-disable-next-line @lwc/lwc/no-unexpected-wire-adapter-usages
        getRecord.emit(mockGetRecord);

        await flushPromises();

        const urlInput = element.shadowRoot.querySelector("[data-id='urlInput']");
        expect(urlInput.value).toBe('https://www.veteran.apps.va.gov');
    });

    it('returns the correct vvcUrl for Case', async () => {
        element.objectApiName = 'Case';

        // eslint-disable-next-line @lwc/lwc/no-unexpected-wire-adapter-usages
        getRecord.emit(mockGetRecord);

        await flushPromises();

        const urlInput = element.shadowRoot.querySelector("[data-id='urlInput']");
        expect(urlInput.value).toBe('https://www.veteran.apps.va.gov');
    });

    // urlLoaded true
    it('returns the correct vvcUrl on button click', async () => {
        const windowOpen = jest.spyOn(window, 'open');
        // Provide a mock implementation of window.open
        windowOpen.mockImplementation(() => {
            console.log('window.open called');
        });

        // eslint-disable-next-line @lwc/lwc/no-unexpected-wire-adapter-usages
        getRecord.emit(mockGetRecord);

        const urlInput = element.shadowRoot.querySelector("[data-id='urlInput']");
        urlInput.value = 'https://www.veteran.apps.va.gov';

        // Click button
        element.shadowRoot.querySelector('lightning-button').click();

        // [data-id='popoutCheckbox'] is checked by default
        const popoutCheck = element.shadowRoot.querySelector("[data-id='popoutCheckbox']");
        expect(popoutCheck.checked).toBe(true);

        expect(windowOpen).toHaveBeenCalled();
    });
});
