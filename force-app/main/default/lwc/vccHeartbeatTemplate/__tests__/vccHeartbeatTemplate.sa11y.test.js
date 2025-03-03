import { createElement } from 'lwc';
import vccHeartbeatTemplate from 'c/vccHeartbeatTemplate';

describe('c-vcc-heartbeat-template', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-heartbeat-template', {
            is: vccHeartbeatTemplate
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
