import { createElement } from 'lwc';
import vccLabDetails from 'c/vccLabDetails';

describe('c-vcc-lab-details', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-lab-details', {
            is: vccLabDetails
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
