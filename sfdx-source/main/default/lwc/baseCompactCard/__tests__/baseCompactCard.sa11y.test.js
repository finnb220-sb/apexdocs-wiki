import { createElement } from 'lwc';
import baseCompactCard from 'c/baseCompactCard';

describe('c-base-compact-card', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-base-compact-card', {
            is: baseCompactCard
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
