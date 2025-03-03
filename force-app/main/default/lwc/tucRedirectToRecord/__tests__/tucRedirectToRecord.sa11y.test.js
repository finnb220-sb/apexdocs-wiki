import { createElement } from 'lwc';
import tucRedirectToRecord from 'c/tucRedirectToRecord';

describe('c-tuc-redirect-to-record', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-tuc-redirect-to-record', {
            is: tucRedirectToRecord
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
