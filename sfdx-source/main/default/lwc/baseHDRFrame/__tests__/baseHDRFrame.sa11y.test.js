import { createElement } from 'lwc';
import baseHDRFrame from 'c/baseHDRFrame';

describe('c-base-hdrframe', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('is accessible', async () => {
        const element = createElement('c-base-hdrframe', {
            is: baseHDRFrame
        });
        element.dateRangeField = 'date';
        element.settings = { icon: 'standard:account', title: 'Account' };
        element.list = ['a', 'b', 'c'];
        element.columns = [{ label: 'Name', fieldName: 'name' }];
        element.size = 'small';
        element.currentObject = 'VCC_Progress_Note__c';
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
