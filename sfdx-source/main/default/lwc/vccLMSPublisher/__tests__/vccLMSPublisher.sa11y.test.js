import { createElement } from 'lwc';
import vccLMSPublisher from 'c/vccLMSPublisher';

describe('c-vcc-lmspublisher', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-lmspublisher', {
            is: vccLMSPublisher
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
