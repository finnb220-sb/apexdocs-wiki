import { createElement } from 'lwc';
import vccVisitRelatedTos from 'c/vccVisitRelatedTos';

describe('c-vcc-visit-related-tos', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-visit-related-tos', {
            is: vccVisitRelatedTos
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
