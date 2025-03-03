import { createElement } from 'lwc';
import vccAppointmentDetails from 'c/vccAppointmentDetails';

describe('c-vcc-appointment-details', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-appointment-details', {
            is: vccAppointmentDetails
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
