/**
 * @description This LWC (though poorly named) provides the body for a modal in the medication refill UI.
 * - It presents to the user a list of facilities, where each facility shows address info and the meds to be refilled.
 * - Each facility "row" indicates what address the medication refill will go to.
 * - It implements the "visual picker" SLDS blueprint: https://www.lightningdesignsystem.com/components/visual-picker/
 */
import { LightningElement, api, track } from 'lwc';
import validateAddress from '@salesforce/apex/VCC_lwc_utils.validateAddress';

import PERMISSION_PHARM_I from '@salesforce/customPermission/VCC_Pharmacy_Tier_I';
import PERMISSION_PHARM_II from '@salesforce/customPermission/VCC_Pharmacy_Tier_II';
import PERMISSION_PHARM_III from '@salesforce/customPermission/VCC_Pharmacy_Tier_III';

import * as h from 'c/helpersLWC';

/**
 * @description This const represents the possible "inactive" value for the 'tempAddActive' property in the HDR getTempAddress payload.
 */
const TEMPADDACTIVE_INACTIVE = 'inactive';

const TEMPADDRESSSTATUS_ACTIVE = 'Active';
const TEMPADDRESSSTATUS_INACTIVE = 'Inactive';
const TEMPADDRESSSTATUS_FUTURE = 'Future';
const TEMPADDRESSSTATUS_EXPIRED = 'Expired';

const TODAY = new Date(new Date().setHours(0, 0, 0, 0));

const ADDRESS_BOX_CSS_ENABLED = 'slds-box refill';
const ADDRESS_BOX_CSS_DISABLED = ADDRESS_BOX_CSS_ENABLED + ' slds-theme_shade';

const EMPTY_STRING = '';
const SPACE = ' ';
const COMMA = ',';
const COMMA_SPACE = COMMA + SPACE;

export default class VccBaseVerticalVisualPicker extends LightningElement {
    @api list;
    @api label;
    @api address;
    @api warning;
    @api error;

    displaySpinner = true;
    @track isTempAddress = false;
    @track isMailingAddress = false;
    @track notUsAddress = false;
    @track addressNotification;
    @track fullyDisabled = false;
    @track mailingClasses;
    @track tempClasses;
    // @track isTemp = false;
    @track
    medsToRefill = [];
    @track displayList = [];
    isInitialized = false;
    css = {
        message: 'font-size: 8px;'
    };

    /**
     * @description Evaluates to true if user has any of the 3 pharmacy custom permissions
     */
    get isPharmacyUser() {
        return (PERMISSION_PHARM_I || PERMISSION_PHARM_II || PERMISSION_PHARM_III) === true;
    }
    /**
     * Evaluates to false if user doesn't have any of the 3 pharmacy custom permissions
     */
    get isNotPharmacyUser() {
        return !this.isPharmacyUser;
    }

    async connectedCallback() {
        this.displayList = JSON.parse(JSON.stringify(this.list));

        this.processAddresses();
        if (this.address.PersonMailingAddress) {
            this.displayList = await this.checkMatch(this.displayList);
            this.displaySpinner = false;
        }
    }

    renderedCallback() {
        this.handleCheckboxSelect();
    }

    /**
     * @description Evaluates temp address object to determine a status value for the temp address.
     * - The new tempAddActive flag overrides any other logic: 'inactive' will always evaluate to 'Inactive'
     * - If startDate is null, it is 'Inactive'
     * - If startDate is in the future, it is a 'Future' temporary address
     * - If endDate is in the past, it is an 'Expired' temporary address
     * - If startDate is today or in the past and endDate is not set or is today or in the future, it is an 'Active' temporary address
     *
     * @param {Object} tempAddress
     * @return {string} A value from the TEMPADDRESSSTATUS contstants set... Active, Inactive, Expired, Future
     */
    calculateTempAddressStatus(tempAddress = {}) {
        const { tempAddActive, startDate, endDate } = tempAddress;
        if (tempAddActive === TEMPADDACTIVE_INACTIVE || !startDate) {
            //an 'inactive' flag in the payload or any empty startDate constitute an Inactive temporary address
            return TEMPADDRESSSTATUS_INACTIVE;
        }

        //some data could be dirty enough to have an endDate that falls before the startDate...
        //evaluate endDate (expiration) before startDate (future), to enforce the "more restrictive" logic of hiding an expired temp address
        const end = new Date(endDate ?? null);
        end.setDate(end.getDate() + 1);
        end.setHours(0, 0, 0, 0);

        const endDateIsInPast = endDate && end.getTime() < TODAY.getTime();
        if (endDateIsInPast) {
            //if end date is not null and is before today, it is an expired temporary address, no matter the start date value
            return TEMPADDRESSSTATUS_EXPIRED;
        }

        const start = new Date(startDate);
        start.setDate(start.getDate() + 1);
        start.setHours(0, 0, 0, 0);

        const startDateIsInFuture = start.getTime() > TODAY.getTime();
        if (startDateIsInFuture) {
            //if start date is after today, it is a future temporary address, no matter the end date value
            return TEMPADDRESSSTATUS_FUTURE;
        }

        const startDateIsTodayOrInPast = start.getTime() <= TODAY.getTime();
        const endDateIsTodayOrInFuture = endDate && end.getTime() >= TODAY.getTime();
        if (startDateIsTodayOrInPast && (!endDate || endDateIsTodayOrInFuture)) {
            //if start date is before today and end date is not set or is today or a future date, it is an active temporary address
            return TEMPADDRESSSTATUS_ACTIVE;
        }

        //default to inactive
        return TEMPADDRESSSTATUS_INACTIVE;
    }

    /**
     * @description Evaluates if the temporary address is domestic or international.
     * @param {string} country Value of the 'country' property from the temporary address from a facility.
     * @returns {boolean} Returns returns false if country is empty or not equal to 'USA', otherwise it returns true.
     */
    countryIsDomestic(country) {
        let isDomesticAddress = true;
        if (country !== 'USA' && country !== EMPTY_STRING) {
            isDomesticAddress = false;
        }

        return isDomesticAddress;
    }

    /**
     * @description processes each of our temporary addresses, determines if there is a temporary address, if it is
     * a domestic or international address and if it is an active temporary address.
     */
    processAddresses() {
        // need to actually parse the list and process each temp address
        this.displayList.forEach((object) => {
            // process the tempAddress
            if (object.facility.isTemp === false) {
                object.facility.isDomesticAddress = true;
                object.facility.errorTempAddressTabIndex = -1;
                object.facility.isTempAddress = false;
            } else {
                let isTempAddressActive = false;
                if (object.facility?.tempAddress?.address) {
                    const city = object.facility.tempAddress.address.city;
                    const state = object.facility.tempAddress.address.state;
                    const zip = object.facility.tempAddress.address.zip;
                    const county = object.facility.tempAddress.address.county;
                    if (county) {
                        object.facility.tempAddress.address.county = county + ' County';
                    }

                    const isDomesticAddress = this.countryIsDomestic(object.facility.tempAddress.address.country);
                    object.facility.isDomesticAddress = isDomesticAddress;
                    if (isDomesticAddress) {
                        object.facility.errorTempAddressTabIndex = -1;
                        let formattedAddress = EMPTY_STRING;
                        if (city) {
                            formattedAddress += city;
                        }
                        if (state) {
                            formattedAddress += (city ? COMMA_SPACE : EMPTY_STRING) + state;
                        }
                        if (zip) {
                            formattedAddress += (city || state ? SPACE : EMPTY_STRING) + zip;
                        }
                        object.facility.formattedAddress = formattedAddress;
                    } else {
                        object.facility.errorTempAddressTabIndex = 0;
                        let formattedForeignAddress = EMPTY_STRING;
                        if (city) {
                            formattedForeignAddress += city;
                        }
                        const foreignPostalCode = object.facility.tempAddress.address.postCode;
                        if (foreignPostalCode) {
                            formattedForeignAddress += (city ? SPACE : EMPTY_STRING) + foreignPostalCode;
                        }
                        object.facility.formattedForeignAddress = formattedForeignAddress;
                    }

                    const tempAddressStatus = this.calculateTempAddressStatus(object.facility.tempAddress);
                    object.facility.tempAddress.status = tempAddressStatus;
                    object.facility.tempAddress.hide =
                        tempAddressStatus === TEMPADDRESSSTATUS_INACTIVE ||
                        tempAddressStatus === TEMPADDRESSSTATUS_EXPIRED;
                    isTempAddressActive = tempAddressStatus === TEMPADDRESSSTATUS_ACTIVE;
                    object.facility.tempAddress.isFuture = tempAddressStatus === TEMPADDRESSSTATUS_FUTURE;
                    object.facility.showForeignAddressWarning =
                        !isDomesticAddress && (isTempAddressActive || object.facility.tempAddress.isFuture);
                }
                object.facility.isTempAddress = isTempAddressActive;
            }
        });
    }
    /**
     * @description method to determine if the VA mailing address in vista and va mailing address from profile are both
     * the same. As well as logic to style our modal and which messages to display to the user.
     * @param {Object[]} takes our list, calls external APEX method to determine if addresses are the same.
     * @returns map must have a return, returning our list.
     */
    async checkMatch(list) {
        const vaProfile = await validateAddress({
            data: this.address.PersonMailingAddress,
            type: 'CORRESPONDENCE'
        }).then((data) => JSON.parse(JSON.parse(data)));

        return Promise.all(
            list.map(async (listItem) => {
                const ui = await validateAddress({
                    data: {
                        city: listItem.facility.address.city,
                        country: 'United States',
                        postalCode: listItem.facility.address.postalCode,
                        state: listItem.facility.address.stateProvince,
                        street: listItem.facility.address.streetLine1
                    },
                    type: 'CORRESPONDENCE'
                }).then((data) => JSON.parse(JSON.parse(data)));

                listItem.facility.fullyDisabled = false;
                let doesNotMatch =
                    JSON.stringify(ui.candidateAddresses[0].address) !==
                    JSON.stringify(vaProfile.candidateAddresses[0].address);

                let match = !doesNotMatch;
                if (match !== true) {
                    listItem.facility.errorAddressMatchTabIndex = 0;
                } else {
                    listItem.facility.errorAddressMatchTabIndex = -1;
                }

                listItem.facility.selected = true;
                listItem.facility.doesNotMatch = doesNotMatch;
                if (listItem.facility.isTempAddress) {
                    listItem.facility.addressNotification = 'Current refill address is Temporary Address';
                    listItem.facility.tempClasses = ADDRESS_BOX_CSS_ENABLED;
                    listItem.facility.mailingClasses = ADDRESS_BOX_CSS_DISABLED;
                } else if (!listItem.facility.isTempAddress && !doesNotMatch) {
                    listItem.facility.addressNotification = 'Current refill address is Mailing Address';
                    listItem.facility.mailingClasses = ADDRESS_BOX_CSS_ENABLED;
                    listItem.facility.tempClasses = ADDRESS_BOX_CSS_DISABLED;
                } else {
                    //pharmacy users don't see no-valid-address warning, and can select a facility even if it veteran doesn't have a valid address for that facility
                    listItem.facility.addressNotification = this.isPharmacyUser
                        ? 'Current refill address is Mailing Address'
                        : 'No valid address';
                    listItem.facility.fullyDisabled = this.isPharmacyUser ? false : true;
                    listItem.facility.mailingClasses = this.isPharmacyUser
                        ? ADDRESS_BOX_CSS_ENABLED
                        : ADDRESS_BOX_CSS_DISABLED;
                    listItem.facility.tempClasses = ADDRESS_BOX_CSS_DISABLED;
                    listItem.facility.selected = this.isPharmacyUser ? true : false;
                }

                return {
                    ...listItem
                };
            })
        );
    }
    /**
     * @description when submit on first modal is clicked this method makes a list of our meds to refill, also dispatches an event
     * to our verifyRefill method in vccMedicationList.js.
     */
    @api
    submitRefill() {
        const inputs = this.template.querySelectorAll(`[data-group='med-checkbox']`);

        for (const i of inputs) {
            if (i.checked) {
                this.medsToRefill.push(this.list.filter((e) => e.facility.id === i.dataset.id)[0].facility.meds);
            }
        }

        this.dispatchEvent(
            new CustomEvent('verifyrefill', {
                bubbles: true,
                detail: h.uniqueVals(this.medsToRefill.flat(), 'prescriptionId')
            })
        );
    }
    /**
     * @description method to determine if cards should be selected or deselected by default. dispatches event
     * to handlePicked method on vccMedicationList.js.
     */
    handleCheckboxSelect() {
        let countSelected = [...this.template.querySelectorAll(`[data-group='med-checkbox']`)].reduce((checked, i) => {
            if (i.checked) {
                checked++;
            }
            return checked;
        }, 0);

        this.dispatchEvent(
            new CustomEvent('picked', {
                detail: { selected: countSelected && countSelected > 0, count: countSelected }
            })
        );
    }
}
