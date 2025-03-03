import { createElement } from 'lwc';
import vccInsuranceAndEligibility from 'c/vccInsuranceAndEligibility';

describe('c-vcc-insurance-and-eligibility', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-insurance-and-eligibility', {
            is: vccInsuranceAndEligibility
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
