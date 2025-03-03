import { createElement } from 'lwc';
import vccSelectDuplicateFlag from 'c/vccSelectDuplicateFlag';

describe('c-vcc-select-duplicate-flag', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-select-duplicate-flag', {
            is: vccSelectDuplicateFlag
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
