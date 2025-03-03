/**
 * @description
 * @author Booz Allen Hamilton
 * Created by 603837 on 1/16/2025.
 */

import { createElement } from 'lwc';
import baseEmptyState from 'c/baseEmptyState';

const TEST_MESSAGE = 'This is a test empty state message';

async function flushPromises() {
    return Promise.resolve();
}

/**
 * @description This test suite confirms changes in HTML, when a message is or is not provided to the LWC
 */
describe('assert UI differences based on public properties', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    /**
     * @description When msg is empty, HTML does not render a message
     */
    it('does not have a message when none is provided', async () => {
        //createElement simply constructs an instance of BaseEmptyState without populating any public (@api) properties
        const emptyStateWithoutMessage = createElement('c-base-empty-state', {
            is: baseEmptyState
        });
        //append BaseEmptyState (with no message) to the DOM
        document.body.appendChild(emptyStateWithoutMessage);

        //wait for rendering to complete
        await flushPromises();

        //the h3 tag in this LWC renders the msg property, to which we haven't passed any value
        //expect its textContent to be empty
        const h3 = emptyStateWithoutMessage.shadowRoot.querySelector('h3');
        expect(h3.textContent).toBeFalsy();
    });

    /**
     * @description When msg is populated, HTML renders a message in h3 tags
     */
    it('has a message when one is provided', async () => {
        const emptyStateWithMessage = createElement('c-base-empty-state', {
            is: baseEmptyState
        });
        //this gives us an instance of BaseEmptyState whose msg property has a value
        emptyStateWithMessage.msg = TEST_MESSAGE;

        //append BaseEmptyState (with a message) to the DOM
        document.body.appendChild(emptyStateWithMessage);

        //wait for rendering to complete
        await flushPromises();

        //the h3 tag in this LWC renders the msg property, to which we have passed the TEST_MESSAGE constant
        //expect the h3's textContent to match the TEST_MESSAGE constant
        const h3 = emptyStateWithMessage.shadowRoot.querySelector('h3');
        expect(h3.textContent).toStrictEqual(TEST_MESSAGE);
    });

    /**
     * @description When variant is 'error', HTML renders an svg with the `slds-icon` class
     */
    it('displays an error slds-icon for error variant', async () => {
        const errorVariantEmptyState = createElement('c-base-empty-state', {
            is: baseEmptyState
        });
        errorVariantEmptyState.variant = 'error';
        document.body.appendChild(errorVariantEmptyState);

        await flushPromises();

        const svg = errorVariantEmptyState.shadowRoot.querySelector('svg');
        expect(svg).toBeDefined();
        expect([...(svg.classList ?? [])].includes('slds-icon')).toBeTruthy();
    });
});
