import { createElement } from 'lwc';
import baseSingleFilter from 'c/baseSingleFilter';

describe('c-base-single-filter', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-base-single-filter', {
            is: baseSingleFilter
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
