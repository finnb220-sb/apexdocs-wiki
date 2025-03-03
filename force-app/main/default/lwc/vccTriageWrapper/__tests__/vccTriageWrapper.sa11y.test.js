import { createElement } from 'lwc';
import vccTriageWrapper from 'c/vccTriageWrapper';

describe('c-vcc-triage-wrapper', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-triage-wrapper', {
            is: vccTriageWrapper
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
