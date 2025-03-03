import { createElement } from 'lwc';
import vccSensitivePatient from 'c/vccSensitivePatient';

describe('c-vcc-sensitive-patient', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-sensitive-patient', {
            is: vccSensitivePatient
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
