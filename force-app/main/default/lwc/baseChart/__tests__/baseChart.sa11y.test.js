/**
 * @description Accessibility Jest test for baseChart LWC
 * It will FAIL unless the html is updated to have an aria-label tag
 * @author Booz Allen Hamilton
 *
 * @see baseChart
 * @see baseChart.test
 */
import { createElement } from 'lwc';
import baseChart from 'c/baseChart';
import { expect } from '@jest/globals';

describe('c-base-chart', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    /**
     * @description this method tests the accessibility of the lwc.
     * It will FAIL unless the html is updated to have an aria-label tag
     */
    it('is accessible', async () => {
        const element = createElement('c-base-chart', {
            is: baseChart
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
