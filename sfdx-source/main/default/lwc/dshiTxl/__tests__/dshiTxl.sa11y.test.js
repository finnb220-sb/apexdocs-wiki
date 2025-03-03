import { createElement } from 'lwc';
import dshiTxl from 'c/dshiTxl';

describe('c-dshi-txl', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-dshi-txl', {
            is: dshiTxl
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
