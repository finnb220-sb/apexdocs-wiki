import { createElement } from 'lwc';
import vccBaseVerticalVisualPicker from 'c/vccBaseVerticalVisualPicker';

/**
 * @description Test suite asserts general accessibility of the LWC
 */
describe('c-base-vertical-visual-picker', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    /**
     * @description Asserts the element, with no data, is accessible
     */
    it('is accessible', async () => {
        //this element creation passes default values to `address` and `list` properties because the LWC errors without them and doesn't define its own default values.
        const element = Object.assign(
            createElement('c-base-vertical-visual-picker', {
                is: vccBaseVerticalVisualPicker
            }),
            {
                address: {},
                list: []
            }
        );
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
