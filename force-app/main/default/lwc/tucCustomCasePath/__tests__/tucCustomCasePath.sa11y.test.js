import { createElement } from 'lwc';
import tucCustomCasePath from 'c/tucCustomCasePath';

describe('c-tuc-custom-case-path', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-tuc-custom-case-path', {
            is: tucCustomCasePath
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
