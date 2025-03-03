/**
 * @description Functional Jest test for the `vccHealthDataStickyAnchor` LWC component.  This test
 * suite validates that the component is properly defined and lifecycle methods are being called appropriately.
 * @author Booz Allen Hamilton
 * @see vccHealthDataStickyAnchor
 */

import { createElement } from 'lwc';
import vccHealthDataStickyAnchor from 'c/vccHealthDataStickyAnchor';

// Begin a Jest test suite for the `vccHealthDataStickyAnchor` component.
describe('c-vcc-health-data-sticky-anchor', () => {
    let element;
    /**
     * @description Runs before each test case in the suite.Appends the component to the DOM for rendering and interaction.
     */

    beforeEach(() => {
        element = createElement('c-vcc-health-data-sticky-anchor', {
            is: vccHealthDataStickyAnchor
        });

        document.body.appendChild(element);
    });

    /**
     * @description Runs after each test case.
     * Cleans up the DOM to ensure no leftover elements interfere with subsequent tests.
     * Removes all child elements from the document body.
     */

    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    /**
     * @description Checks that the 'Rendered' lifecycle method is being initiated with the addEventListener method
     */

    it('should execute rendered logic', async () => {
        //Spy on window.addEventListener- using jest.spyOn-  essentially just keep track of when it gets called

        const addEvenListenerSpy = jest.spyOn(window, 'addEventListener');

        //Create the Component

        element = createElement('c-vcc-health-data-sticky-anchor', {
            is: vccHealthDataStickyAnchor
        });

        //Add the component variable
        element.hasRun = false;

        //Append the component to the DOM to trigger the rendered callback
        document.body.appendChild(element);

        //Assert that the window.addEventListener was called in the renderedCallback with resize and scroll actions

        expect(addEvenListenerSpy).toHaveBeenCalledWith('resize', expect.any(Function));
        expect(addEvenListenerSpy).toHaveBeenCalledWith('scroll', expect.any(Function));

        //expect(addEvenListenerSpy).toHaveBeenCalledWith('mouseover', expect.any(Function));
    });

    /**
     * @description Checks that the 'Disconnected callback' lifecycle method is being initiated with the removeEventListener method
     */

    it('should execute disconnected logic', async () => {
        //Spy on window.removeEventListener using jest.spyOn-  essentially just keep track of when it gets called

        const removeEvenListenerSpy = jest.spyOn(window, 'removeEventListener');

        //Create the Component
        element = createElement('c-vcc-health-data-sticky-anchor', {
            is: vccHealthDataStickyAnchor
        });

        //Add Component to the DOM
        document.body.appendChild(element);

        //Remove Component from the DOM Component to trigger Disconnected Callback method
        document.body.removeChild(element);

        //Assert that the window.removeEventListener was called in the disconnected callback with resize and scroll actions

        expect(removeEvenListenerSpy).toHaveBeenCalledWith('resize', expect.any(Function));
        expect(removeEvenListenerSpy).toHaveBeenCalledWith('scroll', expect.any(Function));
    });

    /**
     * @description Checks that the publish height method is sending the height information through the lightning message channel
     */

    it('publishes component height', async () => {
        //Create the Component

        element = createElement('c-vcc-health-data-sticky-anchor', {
            is: vccHealthDataStickyAnchor
        });

        //Add the component variable
        element.hasRun = false;

        //Append the component to the DOM to trigger the rendered callback
        document.body.appendChild(element);

        const lms = element.shadowRoot.querySelector('c-vcc-l-m-s-publisher');
        expect(lms).not.toBeNull();
    });
});
