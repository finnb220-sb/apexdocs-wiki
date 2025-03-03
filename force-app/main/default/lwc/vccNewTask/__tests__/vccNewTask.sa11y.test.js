import { createElement } from 'lwc';
import vccNewTask from 'c/vccNewTask';

describe('c-vcc-new-task', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-new-task', {
            is: vccNewTask
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
