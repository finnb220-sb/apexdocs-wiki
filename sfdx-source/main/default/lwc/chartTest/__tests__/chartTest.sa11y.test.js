import { createElement } from 'lwc';
import chartTest from 'c/chartTest';

describe('c-chart-test', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-chart-test', {
            is: chartTest
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
