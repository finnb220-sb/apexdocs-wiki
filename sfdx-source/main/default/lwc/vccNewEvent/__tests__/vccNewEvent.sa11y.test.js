import { createElement } from 'lwc';
import vccNewEvent from 'c/vccNewEvent';

describe('c-vcc-new-event', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-new-event', {
            is: vccNewEvent
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
