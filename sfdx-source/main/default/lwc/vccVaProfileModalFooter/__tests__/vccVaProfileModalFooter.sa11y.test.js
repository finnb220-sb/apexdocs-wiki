import { createElement } from 'lwc';
import vccVaProfileModalFooter from 'c/vccVaProfileModalFooter';

describe('c-vcc-va-profile-modal-footer', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-va-profile-modal-footer', {
            is: vccVaProfileModalFooter
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
