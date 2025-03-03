import { createElement } from 'lwc';
import pcSpecialistChannelConvert from 'c/pcSpecialistChannelConvert';

describe('c-pc-specialist-channel-convert', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-pc-specialist-channel-convert', {
            is: pcSpecialistChannelConvert
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
