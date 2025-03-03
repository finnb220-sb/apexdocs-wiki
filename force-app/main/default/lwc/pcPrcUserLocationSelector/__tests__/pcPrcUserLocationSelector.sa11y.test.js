import { createElement } from 'lwc';
import pcPrcUserLocationSelector from 'c/pcPrcUserLocationSelector';

describe('c-pc-prc-user-location-selector', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-pc-prc-user-location-selector', {
            is: pcPrcUserLocationSelector
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
