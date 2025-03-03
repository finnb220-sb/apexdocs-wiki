/**
 * @description Functional Jest test for the `baseChart` LWC component.
 *
 * @author Booz Allen Hamilton
 * @see baseChart
 */

// Import the `createElement` function from LWC's testing library. This is used to create
// testable instances of Lightning Web Components in a simulated DOM environment.
import { createElement } from 'lwc';

// Import the LWC component being tested.
import baseChart from 'c/baseChart';

/**
 * @description Begin a Jest test suite for the `baseChart` component.
 */
describe('c-base-chart', () => {
    let element; // Declare a variable to hold the LWC instance for use in each test.
    var dateLabels = ['1/12/25', '04/26/24', '05/12/23'];
    var testDataSets = [
        {
            label: 'Test Label',
            data: dateLabels,
            backgroundColor: 'red',
            borderColor: 'green',
            fill: false
        }
    ];
    /**
     * @description - Runs before each test case in the suite.
     * - Creates a new instance of the `baseChart` component.
     */
    beforeEach(() => {
        element = createElement('c-base-chart', {
            is: baseChart
        });
        element.chartType = JSON.parse(JSON.stringify('line'));
        window.Chart = jest.fn();
        HTMLCanvasElement.prototype.getContext = jest.fn();
        document.body.appendChild(element); // Attach the component to the DOM for rendering.
    });

    /**
     * @description - Runs after each test case.
     * - Cleans up the DOM to ensure no leftover elements interfere with subsequent tests.
     * - Removes all child elements from the document body.
     */
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild); // Remove child elements from the DOM.
        }
        window.Chart.mockClear();
        HTMLCanvasElement.prototype.getContext.mockClear();
    });

    /**
     * @description - Test case: Verify that the component is properly defined.
     * - Uses Jest's `toBeDefined` matcher to confirm that the `element` variable
     *   holds a valid, instantiated LWC object.
     */
    it('is defined', async () => {
        await expect(element).toBeDefined(); // Ensure the component is defined.
    });

    /**
     * @description - Test case: testing the getter and setter for Labels
     */
    it('covering getter and setter for labels', async () => {
        var labelToVerify;

        element.chartLabels = dateLabels;
        labelToVerify = element.chartLabels[0];
        await expect(labelToVerify).toBe('1/12/25');
    });

    /**
     * @description - Test case: testing the getter and setter for chart datasets
     */
    it('covering getter and setter for chart datasets', async () => {
        var dataSetToVerify;
        var testDataSet;
        element.chartDatasets = testDataSets;
        dataSetToVerify = JSON.parse(JSON.stringify(element.chartDatasets));
        testDataSet = JSON.parse(JSON.stringify(testDataSets));
        await expect(dataSetToVerify).toStrictEqual(testDataSet);
    });

    /**
     * @description - Test case: testing the getter and setter for chart options
     */
    it('covering getter and setter for chart options', async () => {
        var optionsToVerify;
        element.chartOptions = {
            legend: {
                display: true,
                position: 'bottom',
                align: 'center'
            },
            scales: {
                xAxes: [
                    {
                        offset: true,
                        padding: 3
                    }
                ]
            }
        };
        optionsToVerify = element.chartOptions.legend.display;
        await expect(optionsToVerify).toBe(true);
    });
});
