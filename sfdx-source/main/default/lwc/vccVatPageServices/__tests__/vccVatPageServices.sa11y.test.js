import { createElement } from 'lwc';
import vccVatPageServices from 'c/vccVatPageServices';

describe('c-vcc-vat-page-services', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-vat-page-services', {
            is: vccVatPageServices
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
