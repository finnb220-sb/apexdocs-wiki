/**
 * @description Jest test for the `vccProblemDetails` LWC component using Sa11y to ensure
 * accessibility compliance.  Sa11y is a Salesforce library that automates accessibility
 * testing by checking for common issues that might make a component less usable for individuals
 * with disabilities.
 *
 * @purpose Ensure the component is accessible by default, adhering to WCAG (Web Content
 * Accessibility Guidelines) standards. Accessibility testing is crucial for inclusivity, improving
 * usability for all users regardless of ability.
 *
 * @author Booz Allen Hamilton
 * @see vccProblemDetails
 * @see https://github.com/salesforce/sa11y
 */

// Import the `createElement` function from LWC's testing library. This is used to create testable
// instances of Lightning Web Components in a simulated DOM environment.
import { createElement } from 'lwc';

// Import the LWC component being tested.
import vccProblemDetails from 'c/vccProblemDetails';

// Import a mock dataset for testing. This JSON file simulates a "selected record" to be used
// as input to the component. It ensures consistency and reproducibility in tests.
const mockSelectedRecord = require('./data/selectedRecord.json');

// Start a test suite for the `vccProblemDetails` component.
describe('c-vcc-problem-details', () => {
    let element; // Declare a variable to hold the LWC instance for use in each test.

    /**
     * Runs before each test case in the suite.
     * - Creates a new instance of the `vccProblemDetails` component.
     * - Sets a mock `selectedRecord` input for the component to simulate realistic data usage.
     * - Appends the component to the DOM for rendering and interaction.
     */
    beforeEach(() => {
        element = createElement('c-vcc-problem-details', {
            is: vccProblemDetails // Specify the LWC component to create.
        });
        element.setSelectedRecord(mockSelectedRecord); // Pass the mock dataset as input.
        document.body.appendChild(element); // Append the component to the simulated DOM.
    });

    /**
     * Runs after each test case.
     * - Cleans up the DOM to ensure no leftover elements interfere with subsequent tests.
     * - Removes all child elements from the document body.
     */
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild); // Remove all elements from the DOM.
        }
    });

    /**
     * Test case: Validate accessibility compliance.
     * - Uses the `toBeAccessible` assertion provided by Sa11y.
     * - This assertion performs automated checks for accessibility issues such as missing
     * ARIA attributes, improper focus management, insufficient color contrast, and more.
     *
     * @note Accessibility compliance is essential for ensuring that users with disabilities
     * can interact with the component effectively. This test confirms the component meets baseline
     * WCAG standards.
     */
    it('is accessible', async () => {
        // The `toBeAccessible` assertion checks the component for accessibility issues.
        // It runs asynchronously and compares the DOM against a set of accessibility rules.
        await expect(element).toBeAccessible();
    });
});
