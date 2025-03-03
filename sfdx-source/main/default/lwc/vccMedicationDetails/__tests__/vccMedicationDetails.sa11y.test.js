import { createElement } from 'lwc';
import vccMedicationDetails from 'c/vccMedicationDetails';

describe('c-vcc-medication-details', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-medication-details', {
            is: vccMedicationDetails
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
