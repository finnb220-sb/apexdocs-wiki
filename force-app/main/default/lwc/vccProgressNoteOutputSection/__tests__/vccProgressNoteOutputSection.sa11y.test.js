import { createElement } from 'lwc';
import vccProgressNoteOutputSection from 'c/vccProgressNoteOutputSection';

describe('c-vcc-progress-note-output-section', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-progress-note-output-section', {
            is: vccProgressNoteOutputSection
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
