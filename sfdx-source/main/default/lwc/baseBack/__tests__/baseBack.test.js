import { createElement } from 'lwc';
import BaseBack from 'c/baseBack';

/**
 * The describe() function is used to define a test suite.
 * It takes a description of the test suite and a callback function that contains the test cases.
 */
describe('c-base-back', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    /**
     * The it() function is used to define a single test case.
     * It takes a description of the test case and a callback function that contains the test logic.
     */
    it('should call window.history.back() on connectedCallback', () => {
        /**
         * The jest.fn() function is a utility provided by the Jest.
         * It allows you to create a mock function.
         * In this case we're using it to mock window.history.back().
         */
        window.history.back = jest.fn();

        // Create instance of the BaseBack LWC.
        const element = createElement('c-base-back', {
            is: BaseBack
        });

        // Append the element to the document body.
        document.body.appendChild(element);

        // Verify if connectedCallback was called.
        expect(window.history.back).toHaveBeenCalled();
    });
});
