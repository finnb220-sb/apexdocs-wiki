import { createElement } from 'lwc';
import vccCustomHDRFrame from 'c/vccCustomHDRFrame';

describe('c-vcc-custom-hdrframe', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-custom-hdrframe', {
            is: vccCustomHDRFrame
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
