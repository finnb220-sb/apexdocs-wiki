import { createElement } from 'lwc';
import baseButtonList from 'c/baseButtonList';

describe('c-base-button-list', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-base-button-list', {
            is: baseButtonList
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
