import { createElement } from 'lwc';
import pcCaseFeedback from 'c/pcCaseFeedback';

describe('c-pc-case-feedback', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-pc-case-feedback', {
            is: pcCaseFeedback
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
