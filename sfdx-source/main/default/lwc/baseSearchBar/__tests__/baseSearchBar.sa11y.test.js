import { createElement } from 'lwc';
import baseSearchBar from 'c/baseSearchBar';

describe('c-base-search-bar', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-base-search-bar', {
            is: baseSearchBar
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
