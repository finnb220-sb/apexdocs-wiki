/**
 * @description
 * @author Booz Allen Hamilton
 * Created by 603837 on 1/21/2025.
 */

import { createElement } from 'lwc';
import vccBaseVerticalVisualPicker from 'c/vccBaseVerticalVisualPicker';
import validateAddress from '@salesforce/apex/VCC_lwc_utils.validateAddress';

const LWCNAME_KEBAB = 'c-vcc-base-vertical-visual-picker';

async function flushPromises() {
    return Promise.resolve();
}

/**
 * @description This function runs a standard JSON object through the `JSON.stringify` function twice, to mimic how the response from `VCC_lwc_utils.validateAddress` is a double-stringified JSON string
 * - We do this because the `checkMatch()` function parses the Apex method's response twice... e.g. `JSON.parse(JSON.parse(data))`
 * @param object
 * @returns {string}
 */
function doubleStringify(object = {}) {
    return JSON.stringify(JSON.stringify(object));
}

/**
 * @description This function builds an object in the shape expected for the `VCC_lwc_utils.validateAddress` Apex method
 * @param addressData an object representing either patient's VA Profile address or from their address at a facility
 * @returns {{data: {}, type: string}} - an object with inputs required for `VCC_lwc_utils.validateAddress` method
 */
function buildValidateAddressInput(addressData = {}) {
    return {
        data: { ...addressData },
        type: 'CORRESPONDENCE'
    };
}

//input data to LWC, from meds list
const ADDRESS_FROM_MEDS = require('./data/addressFromVccMedicationList.json');
const FACILITIES_FROM_MEDS = require('./data/listFromVccMedicationList.json');

//mock imperative validateAddress call
jest.mock('@salesforce/apex/VCC_lwc_utils.validateAddress', () => ({ default: jest.fn() }), { virtual: true });

const VALIDATEADDRESS_RESPONSE_VAPROFILE = require('./data/validateAddressResultVaProfileAddress.json');
const VALIDATEADDRESS_RESPONSE_FACILITYADDRESS = require('./data/validateAddressResultFacilityAddress.json');

/**
 * @description Test suite uses mock data to make a few assertions:
 * - Asserts the VA Profile address is rendered in the UI
 * - Asserts successive callouts to `VCC_lwc_utils.validateAddress` are made with the correct inputs
 * - Asserts the component renders an <input> for each facility in the `list` property
 * - Asserts a facility with a foreign temp address results in rending an error message with the non-US address warning
 */
describe('c-vcc-base-vertical-visual-picker', () => {
    let element;
    beforeAll(async () => {
        //this LWC calls validateAddress 2+ times, initiated by its connectedCallback() function
        //once for VA Profile address
        //once more for each facility passed to the LWC's "list" property
        //so have to set up these mock responses before appending the component to the DOM

        //first validateAddress call is for va profile address
        //mock its response first
        validateAddress.mockResolvedValueOnce(doubleStringify(VALIDATEADDRESS_RESPONSE_VAPROFILE));

        //all subsequent validateAddress calls are for facilities' address data
        //mock its response next
        //for now, let all facility addresses just validate to the same result.
        validateAddress.mockResolvedValue(doubleStringify(VALIDATEADDRESS_RESPONSE_FACILITYADDRESS));

        element = Object.assign(
            createElement(LWCNAME_KEBAB, {
                is: vccBaseVerticalVisualPicker
            }),
            {
                address: ADDRESS_FROM_MEDS,
                list: FACILITIES_FROM_MEDS
            }
        );
        document.body.appendChild(element);
        //let rendering finish...
        await flushPromises();
    });
    afterAll(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild); // Remove child elements from the DOM.
        }
    });

    /**
     * @description Asserts success connecting to the DOM
     */
    it('is defined and inserted into DOM', () => {
        expect(element).toBeDefined();
        //the component should indeed be present in the DOM
        expect(document.body.querySelector(LWCNAME_KEBAB)).toBeTruthy();
    });

    /**
     * @description Asserts the VA Profile address is rendered in the UI
     */
    it('displays the VA Profile address in a lightning-formatted-address', () => {
        const formattedAddress = element.shadowRoot.querySelector('lightning-formatted-address');
        expect(formattedAddress).toBeTruthy();
    });

    /**
     * @description Asserts successive callouts to `VCC_lwc_utils.validateAddress` are made with the correct inputs
     */
    it('calls validateAddress list.length + 1 times', () => {
        //validateAddress is called once for VA Profile, and once more for each facility
        const expectedCount = 1 + FACILITIES_FROM_MEDS.length;
        expect(validateAddress).toHaveBeenCalledTimes(expectedCount);

        //first call out uses address.PersonMailingAddress
        expect(validateAddress).toHaveBeenNthCalledWith(
            1,
            buildValidateAddressInput(ADDRESS_FROM_MEDS.PersonMailingAddress)
        );

        //each subsequent callout uses facility address data from each list item
        FACILITIES_FROM_MEDS.forEach((listItem, i) => {
            expect(validateAddress).toHaveBeenNthCalledWith(
                i + 2,
                buildValidateAddressInput({
                    city: listItem.facility.address.city,
                    country: 'United States',
                    postalCode: listItem.facility.address.postalCode,
                    state: listItem.facility.address.stateProvince,
                    street: listItem.facility.address.streetLine1
                })
            );
        });
    });

    /**
     * @description Asserts the component renders an <input> for each facility in the `list` property
     */
    it('renders an <input> element for each facility passed to `list` property', () => {
        const inputs = element.shadowRoot.querySelectorAll('input');
        expect(inputs).toHaveLength(FACILITIES_FROM_MEDS.length);
    });

    /**
     * @description Asserts a facility with a foreign temp address results in rending an error message with the non-US address warning
     */
    it('renders the foreign address warning for any facility containing a foreign temp address', () => {
        //first item in mock data has foreign temp address
        const FOREIGN_INDEX = 0;

        const labels = element.shadowRoot.querySelectorAll('label');
        const labelWithForeignAddressWarning = labels[FOREIGN_INDEX];
        const errorMessages = labelWithForeignAddressWarning.querySelectorAll('c-base-error-message');

        expect(errorMessages.length).toEqual(2);
        //first error message is 'no match' message
        //second error message is foreign address warning
        expect(errorMessages[1].message).toContain('Patient has a non-US address');
    });
});
