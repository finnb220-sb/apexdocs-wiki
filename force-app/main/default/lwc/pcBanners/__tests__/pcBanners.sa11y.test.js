import { createElement } from 'lwc';
import pcBanners from 'c/pcBanners';

describe('c-pc-banners', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-pc-banners', {
            is: pcBanners
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
