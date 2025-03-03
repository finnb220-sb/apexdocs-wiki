/**
 * @author Booz Allen
 * @description accessibility jest test for the vccAllergyDetails lwc
 * @see c/vccAllergyDetails
 *
 * Created 01/2025
 */
import { createElement } from 'lwc';
import vccAllergyDetails from 'c/vccAllergyDetails';

describe('c-vcc-allergy-details-sa11y', () => {
    /**
     * @description reset the DOM after each test
     */
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    /**
     * @description check if component is accessible, positive
     */
    it('is accessible', async () => {
        const element = createElement('c-vcc-allergy-details', { is: vccAllergyDetails });
        element.dateRangeField = 'date';
        element.commentColumns = [];
        element.selectedRecord = {};
        document.body.appendChild(element);
        await expect(element).toBeAccessible();
    });
});
