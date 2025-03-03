import { createElement } from 'lwc';
import vccDuplicateVistaRecordPrompt from 'c/vccDuplicateVistaRecordPrompt';

describe('c-vcc-duplicate-vista-record-prompt', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-duplicate-vista-record-prompt', {
            is: vccDuplicateVistaRecordPrompt
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
