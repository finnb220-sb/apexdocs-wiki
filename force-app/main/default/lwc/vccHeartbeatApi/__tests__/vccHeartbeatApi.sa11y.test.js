import { createElement } from 'lwc';
import vccHeartbeatApi from 'c/vccHeartbeatApi';

describe('c-vcc-heartbeat-api', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-vcc-heartbeat-api', {
            is: vccHeartbeatApi
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
