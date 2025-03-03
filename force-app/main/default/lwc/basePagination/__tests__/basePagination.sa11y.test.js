import { createElement } from 'lwc';
import basePagination from 'c/basePagination';

describe('c-base-pagination', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-base-pagination', {
            is: basePagination
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
