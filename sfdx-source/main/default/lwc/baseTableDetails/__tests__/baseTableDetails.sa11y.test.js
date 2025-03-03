import { createElement } from 'lwc';
import baseTableDetails from 'c/baseTableDetails';

describe('c-base-table-details', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-base-table-details', {
            is: baseTableDetails
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
