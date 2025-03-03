import { createElement } from 'lwc';
import tucGlobalStopwatch from 'c/tucGlobalStopwatch';

describe('c-tuc-global-stopwatch', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-tuc-global-stopwatch', {
            is: tucGlobalStopwatch
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
