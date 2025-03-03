import { createElement } from 'lwc';
import baseEmptyStateIllustration from 'c/baseEmptyStateIllustration';

describe('c-base-empty-state-illustration', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-base-empty-state-illustration', {
            is: baseEmptyStateIllustration
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
