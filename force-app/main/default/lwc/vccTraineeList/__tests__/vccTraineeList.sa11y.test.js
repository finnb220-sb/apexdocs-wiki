import { createElement } from 'lwc';
import vccTraineeList from 'c/vccTraineeList';

describe('c-vcc-trainee-list', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-trainee-list', {
            is: vccTraineeList
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
