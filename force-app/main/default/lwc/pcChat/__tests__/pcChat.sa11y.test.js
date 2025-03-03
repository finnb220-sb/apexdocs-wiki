import { createElement } from 'lwc';
import pcChat from 'c/pcChat';

describe('c-pc-chat', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-pc-chat', {
            is: pcChat
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
