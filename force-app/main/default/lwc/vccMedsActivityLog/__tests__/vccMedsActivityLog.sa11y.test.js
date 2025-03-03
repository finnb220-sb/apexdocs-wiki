import { createElement } from 'lwc';
import vccMedsActivityLog from 'c/vccMedsActivityLog';

describe('c-vcc-meds-activity-log', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-meds-activity-log', {
            is: vccMedsActivityLog
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
