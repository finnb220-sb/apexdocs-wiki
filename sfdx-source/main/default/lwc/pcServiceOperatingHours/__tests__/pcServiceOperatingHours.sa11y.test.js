import { createElement } from 'lwc';
import pcServiceOperatingHours from 'c/pcServiceOperatingHours';

describe('c-pc-service-operating-hours', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-pc-service-operating-hours', {
            is: pcServiceOperatingHours
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
