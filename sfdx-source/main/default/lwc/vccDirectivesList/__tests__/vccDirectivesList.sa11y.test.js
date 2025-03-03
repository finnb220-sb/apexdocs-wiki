import { createElement } from 'lwc';
import vccDirectivesList from 'c/vccDirectivesList';

describe('c-vcc-directives-list', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-directives-list', {
            is: vccDirectivesList
        });
        document.body.appendChild(element);
        // await expect(element).toBeAccessible();

        // leaving this for assigned developer
    });
});
