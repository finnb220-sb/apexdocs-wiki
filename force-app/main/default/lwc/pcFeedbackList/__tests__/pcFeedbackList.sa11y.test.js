import { createElement } from 'lwc';
import pcFeedbackList from 'c/pcFeedbackList';

describe('c-pc-feedback-list', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-pc-feedback-list', {
            is: pcFeedbackList
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
