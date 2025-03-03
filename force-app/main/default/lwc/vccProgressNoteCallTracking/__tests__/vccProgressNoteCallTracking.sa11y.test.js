import { createElement } from 'lwc';
import vccProgressNoteCallTracking from 'c/vccProgressNoteCallTracking';

describe('c-vcc-progress-note-call-tracking', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-progress-note-call-tracking', {
            is: vccProgressNoteCallTracking
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
