import { checkAddressValidity } from '../vccVaProfileController';
import specCharErrorMsg from '@salesforce/label/c.VCC_VA_Profile_Special_Characters_Error';

/**
 * @description this describe method is testing vccVaProfileController method checkAddressValidity. At the time
 * this was written there are two test cases, one testing that prohibited characters are caught and another testing
 * allowed characters are not flagged as prohibited.
 */
describe('vccVaProfileController.checkAddressValidity', () => {
    it('when a prohibited character is present, returns a list containing one element that is equal to label "specCharErrorMessage"', () => {
        for (let character of ['❗️', '%', '(', ')', '^', '&', '*', '$', "'", '"', '@', '!']) {
            let address = {
                street: character
            };
            let addressErrors = checkAddressValidity(address);
            try {
                expect(Array.isArray(addressErrors)).toBe(true);
                expect(addressErrors.length).toBe(1);
                expect(addressErrors[0]).toBe(specCharErrorMsg);
            } catch (error) {
                console.log(`Expected character "${character}" to be invalid but it wasn't.`);
                throw error;
            }
        }
    });
    it('when no prohibited character is present, returns a list containing no "specCharErrorMsg" string', () => {
        let address = {
            street: 'hello world, back slash \\ comma, forward slash / period . pound sign and numbers #1-234567890 alphabet ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz',
            city: 'hello world, back slash \\ comma, forward slash / period . pound sign and numbers #1-234567890 alphabet ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz',
            province:
                'hello world, back slash \\ comma, forward slash / period . pound sign and numbers #1-234567890 alphabet ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz',
            postalCode:
                'hello world, back slash \\ comma, forward slash / period . pound sign and numbers #1-234567890 alphabet ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz',
            country:
                'hello world, back slash \\ comma, forward slash / period . pound sign and numbers #1-234567890 alphabet ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz'
        };
        let addressErrors = checkAddressValidity(address);
        expect(Array.isArray(addressErrors)).toBe(true);
        expect(
            addressErrors.flatMap((errorMessage) => {
                if (errorMessage === specCharErrorMsg) {
                    return [specCharErrorMsg];
                }
                return [];
            }).length
        ).toBe(0);
    });
});
