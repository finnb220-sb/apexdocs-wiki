import { createElement } from 'lwc';
import vccBaseVerticalVisualPicker from 'c/vccBaseVerticalVisualPicker';

const LWCNAME_KEBAB = 'c-vcc-base-vertical-visual-picker';
const BASEEMPTYSTATE = 'c-base-empty-state';

async function flushPromises() {
    return Promise.resolve();
}

/**
 * @description This test suite makes assertions about the component when we don't pass any data to it
 * - empty object `address`
 * - empty array to `list`
 */
describe('vccBaseVerticalVisualPicker, without data', () => {
    let element;

    beforeAll(() => {
        //this element creation passes default values to `address` and `list` properties because the LWC errors without them and doesn't define its own default values.
        element = Object.assign(
            createElement(LWCNAME_KEBAB, {
                is: vccBaseVerticalVisualPicker
            }),
            {
                address: {},
                list: []
            }
        );
        document.body.appendChild(element);
    });

    afterAll(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild); // Remove child elements from the DOM.
        }
    });

    /**
     * @description The LWC can attach to the DOM without throwing errors
     */
    it('is defined and inserted into DOM', async () => {
        await expect(element).toBeDefined();
        //the component should indeed be present in the DOM
        expect(document.body.querySelector(LWCNAME_KEBAB)).toBeTruthy();
    });

    /**
     * @description The LWC displays a baseEmptyState component
     */
    it('renders c-base-empty-state', async () => {
        await flushPromises();
        const emptyStateElement = element.shadowRoot.querySelector(BASEEMPTYSTATE);
        //having passed no data to the component, it renders an empty state UI
        expect(emptyStateElement).toBeTruthy();
    });
});
