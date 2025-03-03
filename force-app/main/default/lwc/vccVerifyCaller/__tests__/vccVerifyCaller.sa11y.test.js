import { createElement } from 'lwc';
import vccVerifyCaller from 'c/vccVerifyCaller';

describe('c-vcc-verify-caller', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-verify-caller', {
            is: vccVerifyCaller
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
