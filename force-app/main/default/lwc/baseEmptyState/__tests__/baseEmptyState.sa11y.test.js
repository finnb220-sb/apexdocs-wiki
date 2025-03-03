import { createElement } from 'lwc';
import baseEmptyState from 'c/baseEmptyState';

describe('c-base-empty-state', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-base-empty-state', {
            is: baseEmptyState
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
