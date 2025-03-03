import { createElement } from 'lwc';
import vccMedicationTable from 'c/vccMedicationTable';

describe('c-vcc-medication-table', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-medication-table', {
            is: vccMedicationTable
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
