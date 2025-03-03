import { createElement } from 'lwc';
import baseBack from 'c/baseBack';

describe('c-base-back', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-base-back', {
            is: baseBack
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
