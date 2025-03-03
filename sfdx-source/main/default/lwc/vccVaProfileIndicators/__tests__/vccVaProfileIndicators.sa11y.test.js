import { createElement } from 'lwc';
import vccVaProfileIndicators from 'c/vccVaProfileIndicators';

describe('c-vcc-va-profile-indicators', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-va-profile-indicators', {
            is: vccVaProfileIndicators
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
