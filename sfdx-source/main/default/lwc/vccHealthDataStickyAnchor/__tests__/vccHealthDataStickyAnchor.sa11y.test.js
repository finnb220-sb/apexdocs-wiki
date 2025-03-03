import { createElement } from 'lwc';
import vccHealthDataStickyAnchor from 'c/vccHealthDataStickyAnchor';

describe('c-vcc-health-data-sticky-anchor', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-health-data-sticky-anchor', {
            is: vccHealthDataStickyAnchor
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
