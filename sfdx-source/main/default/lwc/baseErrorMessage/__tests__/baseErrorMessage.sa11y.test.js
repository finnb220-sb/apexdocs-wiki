import { createElement } from 'lwc';
import baseErrorMessage from 'c/baseErrorMessage';

describe('c-base-error-message', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-base-error-message', {
            is: baseErrorMessage
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
