import { createElement } from 'lwc';
import vccMedsFutureRenewalRequest from 'c/vccMedsFutureRenewalRequest';

describe('c-vcc-meds-future-renewal-request', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-meds-future-renewal-request', {
            is: vccMedsFutureRenewalRequest
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
