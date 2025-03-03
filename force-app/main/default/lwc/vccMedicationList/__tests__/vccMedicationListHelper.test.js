/**
 * @description Jest tests for vccMedicationList/vccMedicationListHelper.js
 * @see vccMedicationList
 * @see vccMedicationListHelper
 * @author Booz Allen Hamilton
 */
import * as helper from '../vccMedicationListHelper';
import duplicate_meds_mock from './duplicate_mock.json';

describe('vccMedicationListHelper.processCallout', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('returns null when medsResponse is empty', () => {
        let preparedMeds = helper.processCallout({
            medsResponse: JSON.stringify({})
        });
        expect(preparedMeds).toBeNull();
    });

    // CCCM-41271, test case that proves the bug and will pass when its fixed
    it('chooses the med with the latest exiration date as the "unique duplicate med" to display when no "Active", "Pending", or "Suspended" meds are present', () => {
        const meds_mock = duplicate_meds_mock;
        let med_with_latest_expiry = meds_mock[1];
        let med_without_latest_expiry = meds_mock[0];

        //asserting contitions to reproduce the bug are present
        expect(med_with_latest_expiry.fullData.expires.formattedValue).toBe('2025-04-16');
        expect(med_with_latest_expiry.vaStatusValue).toBe('DISCONTINUED');
        expect(med_without_latest_expiry.fullData.expires.formattedValue).toBe('2025-04-12');
        expect(med_without_latest_expiry.vaStatusValue).toBe('EXPIRED');

        let preparedMeds = helper.processCallout({ medsResponse: JSON.stringify(meds_mock) });

        expect(preparedMeds.uniqueMedsListForDisplay[0].expiresValue).toBe(
            med_with_latest_expiry.fullData.expires.formattedValue
        );
    });
});
