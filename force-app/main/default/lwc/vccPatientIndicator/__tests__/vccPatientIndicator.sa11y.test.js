import { createElement } from 'lwc';
import vccPatientIndicator from 'c/vccPatientIndicator';

describe('c-vcc-patient-indicator', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-patient-indicator', {
            is: vccPatientIndicator
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
