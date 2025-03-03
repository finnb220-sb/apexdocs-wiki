import { createElement } from 'lwc';
import tucAudioNotify from 'c/tucAudioNotify';

describe('c-tuc-audio-notify', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-tuc-audio-notify', {
            is: tucAudioNotify
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
