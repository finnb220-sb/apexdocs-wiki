import { createElement } from 'lwc';
import baseSpinner from 'c/baseSpinner';

describe('c-base-spinner', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-base-spinner', {
            is: baseSpinner
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
