import { createElement } from 'lwc';
import vccDirectivesLoadmore from 'c/vccDirectivesLoadmore';

describe('c-vcc-directives-loadmore', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-directives-loadmore', {
            is: vccDirectivesLoadmore
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
