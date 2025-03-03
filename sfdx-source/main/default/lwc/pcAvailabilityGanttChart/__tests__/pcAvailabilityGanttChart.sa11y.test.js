import { createElement } from 'lwc';
import pcAvailabilityGanttChart from 'c/pcAvailabilityGanttChart';

describe('c-pc-availability-gantt-chart', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-pc-availability-gantt-chart', {
            is: pcAvailabilityGanttChart
        });
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
