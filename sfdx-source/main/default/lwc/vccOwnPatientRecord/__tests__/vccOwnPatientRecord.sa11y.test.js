import { createElement } from 'lwc';
import vccOwnPatientRecord from 'c/vccOwnPatientRecord';

describe('c-vcc-own-patient-record', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-own-patient-record', {
            is: vccOwnPatientRecord
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
