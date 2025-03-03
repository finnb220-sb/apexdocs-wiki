import { createElement } from 'lwc';
import tucVeteranCrisisLine from 'c/tucVeteranCrisisLine';

describe('c-tuc-veteran-crisis-line', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-tuc-veteran-crisis-line', {
            is: tucVeteranCrisisLine
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
