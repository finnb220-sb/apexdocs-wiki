import { createElement } from 'lwc';
import vccAddPatient from 'c/vccAddPatient';

describe('c-vcc-add-patient', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-add-patient', {
            is: vccAddPatient
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
