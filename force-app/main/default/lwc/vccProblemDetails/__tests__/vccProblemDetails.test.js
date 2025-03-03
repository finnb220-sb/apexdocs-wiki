/**
 * @description Functional Jest test for the `vccProblemDetails` LWC component.  This test
 * suite validates that the component is properly defined, renders expected elements, and
 * dynamically displays data based on the provided input (`selectedRecord`).
 *
 * @author Booz Allen Hamilton
 * @see vccProblemDetails
 */

// Import the `createElement` function from LWC's testing library. This is used to create
// testable instances of Lightning Web Components in a simulated DOM environment.
import { createElement } from 'lwc';

// Import the LWC component being tested.
import vccProblemDetails from 'c/vccProblemDetails';

// Import a mock dataset for testing. This JSON file simulates a "selected record" to be used
// as input to the component. It ensures consistency and reproducibility in tests.
const mockSelectedRecord = require('./data/selectedRecord.json');

// Begin a Jest test suite for the `vccProblemDetails` component.
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
            is: vccProblemDetails
        });

        // ToDo: Correct work around where selectedRecord is always initialized for Jest tests
        // The fact selectedRecord is always required regardless of the assertion in the test, red flags
        // the vccProblemDetails component as needing enhancements to handle null and or other data
        // scenarios that it currently does not handle gracefully.  I'm leaving this comment here for
        // my future self and others, as well as, for a talking point during peer review.
        element.setSelectedRecord(mockSelectedRecord); // Set the mock input to the component.
        document.body.appendChild(element); // Attach the component to the DOM for rendering.
    });

    /**
     * Runs after each test case.
     * - Cleans up the DOM to ensure no leftover elements interfere with subsequent tests.
     * - Removes all child elements from the document body.
     */
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild); // Remove child elements from the DOM.
        }
    });

    /**
     * Test case: Verify that the component is properly defined.
     * - Uses Jest's `toBeDefined` matcher to confirm that the `element` variable
     *   holds a valid, instantiated LWC object.
     */
    it('is defined', async () => {
        await expect(element).toBeDefined(); // Ensure the component is defined.
    });

    /**
     * Test case: Verify that the card title renders correctly.
     * - Queries the shadow DOM for an element with the CSS class `.card-title`.
     * - Ensures that the title element is present and its text content matches the expected value.
     */
    it('renders the card title correctly', () => {
        const cardTitle = element.shadowRoot.querySelector('.card-title'); // Locate the card title.
        expect(cardTitle).not.toBeNull(); // Verify the title exists.
        expect(cardTitle.textContent).toBe('Problem Details'); // Verify the title's text content.
    });

    /**
     * Test case: Verify that the component displays details from the `selectedRecord` input.
     * - Uses the mock data to simulate the presence of a record.
     * - After the DOM updates, verifies that the expected details are displayed correctly.
     */
    it('renders selectedRecord details when provided', () => {
        // Wait for the component's internal state and DOM updates to resolve.
        return Promise.resolve().then(() => {
            // Locate the element displaying the record's name within the shadow DOM.
            const nameElement = element.shadowRoot.querySelector('.detail-cell .info p');
            expect(nameElement.textContent).toBe('John Doe'); // Verify that the rendered text matches.
        });
    });
});
