import { createElement } from 'lwc';
import vccEditAddress from 'c/vccEditAddress';

describe('c-vcc-edit-address', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-edit-address', {
            is: vccEditAddress
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
