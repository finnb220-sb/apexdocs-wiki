/**
 * @description Jest test suite for the `vccHighlightBar` LWC component focusing on
 * accessibility compliance using Sa11y.
 *
 * @purpose Test the `vccHighlightBar` component for:
 * - Accessibility compliance (Sa11y).
 *
 * @author Booz Allen Hamilton
 * @see vccHighlightBar
 * @see https://github.com/salesforce/sa11y
 */

// Import the `createElement` function from LWC's testing library. This is used to create testable
// instances of Lightning Web Components in a simulated DOM environment.
import { createElement } from 'lwc';

// Import the LWC component being tested.
import VccHighlightBar from 'c/vccHighlightBar';

describe('c-vcc-highlight-bar', () => {
    /**
     * @description The LWC instance of the `vccHighlightBar` component used in tests.
     */
    let element;

    /**
     * @description Sets up the DOM environment for each test.
     * @returns {void} No return value; appends the component to the DOM.
     */
    beforeEach(() => {
        element = createElement('c-vcc-highlight-bar', { is: VccHighlightBar });
        document.body.appendChild(element);
    });

    /**
     * @description Cleans up the DOM to ensure no leftover elements interfere with subsequent tests.
     * @returns {void} No return value; removes all elements from the DOM.
     */
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    /**
     * @description Validates accessibility compliance for the `vccHighlightBar` component
     * using Sa11y's `toBeAccessible` matcher.
     * @returns {Promise<void>} Resolves once the accessibility test is complete.
     */
    it('is accessible', async () => {
        await expect(element).toBeAccessible();
    });
});
