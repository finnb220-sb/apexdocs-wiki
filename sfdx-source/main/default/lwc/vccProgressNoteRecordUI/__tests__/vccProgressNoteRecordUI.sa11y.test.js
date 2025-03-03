import { createElement } from 'lwc';
import vccProgressNoteRecordUI from 'c/vccProgressNoteRecordUI';

describe('c-vcc-progress-note-record-ui', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-progress-note-record-ui', {
            is: vccProgressNoteRecordUI
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
