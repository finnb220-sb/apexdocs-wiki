import { createElement } from 'lwc';
import vccSignNote from 'c/vccSignNote';

describe('c-vcc-sign-note', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-sign-note', {
            is: vccSignNote
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
