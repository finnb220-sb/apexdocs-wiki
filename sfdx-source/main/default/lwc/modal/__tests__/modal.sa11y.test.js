import { createElement } from 'lwc';
import modal from 'c/modal';

describe('c-modal', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-modal', {
            is: modal
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
