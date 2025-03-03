/**
 * @author Booz Allen
 * @description This is the controller class that handles the interactions on the E911 Confirm Location Screen
 *
 * @extends LightningElement
 */
import { LightningElement, api } from 'lwc';
import retrieveVetInfo from '@salesforce/apex/VCC_OnPatientLoadController.retrieveVetInfo';
import * as helper from './vccE911ConfirmLocationHelper';
import { FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';
import handleSubmit from '@salesforce/apex/VCC_E911ConfirmLocationController.handleSubmit';

export default class VccE911ConfirmLocation extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api nonAddrInfo;
    @api e911RecordId;
    @api availableActions = [];

    isGlobalLoading = true;
    nonAddrRequired = false;
    otherCurLocRequired = false;

    accountId;
    mpiData;
    noConnection;

    residentialAddress;
    mailingAddress;
    otherCurLoc;

    countryProvinceMap = helper.countryProvinceMap;
    countryOptions = helper.countryOptions;

    selectedLocationOption;
    mailingDisabled = true;
    residentialDisabled = true;

    /**
     * @returns Array of province values that are displayed in the province drop down in input address
     */
    get getProvinceOptions() {
        return this.countryProvinceMap[this.otherCurLoc.country];
    }

    /**
     * @returns Array of Country options that are displayed in the country drop down in input address
     */
    get getCountryOptions() {
        return this.countryOptions;
    }

    /**
     * @description Inits all default params and starts the callout to MPIe for patient's address information
     */
    async connectedCallback() {
        try {
            this.template.addEventListener('keydown', this.handleKeyDown.bind(this));
            this.nonAddrText = this.nonAddrInfo;
            this.initAddresses();
            if (typeof this.recordId !== 'string' && typeof this.objectApiName !== 'string') {
                this.setDefaultedLocOption();
                return;
            }
            this.getAccountId();
            let mpiCallout = this.mpiCallout();
            await mpiCallout;
            await this.getAddressesFromProfile();
            this.setDefaultedLocOption();
        } catch (e) {
            if (e instanceof Error) {
                this.logger(e.message);
            } else {
                this.logger(e);
            }
        } finally {
            this.isGlobalLoading = false;
        }
    }

    /**
     * @description Ensures that the radio button is selected
     */
    renderedCallback() {
        if (this.hasSelectedLocationBoxBeenChecked || this.isGlobalLoading) {
            return;
        }
        this.template.querySelector('input[value="' + this.selectedLocationOption + '"]').checked = 'checked';
        this.hasSelectedLocationBoxBeenChecked = true;
    }

    /**
     * @description Fetches the dependent custom nebula logger LWC and that will be used for logging
     * @param {*} incomingError - object/string that represents the error that has occured
     */
    logger(incomingError) {
        const logger = this.template.querySelector('c-logger');
        if (!logger) {
            return;
        }
        logger.error(JSON.stringify(incomingError));
        logger.saveLog();
    }

    /**
     * @description Stores the user's input on the input address field
     * @param {*} event
     */
    handleAddrInput(event) {
        ({
            street: this.otherCurLoc.street,
            city: this.otherCurLoc.city,
            postalCode: this.otherCurLoc.zipCode,
            province: this.otherCurLoc.state,
            country: this.otherCurLoc.country
        } = event.detail);
    }

    /**
     * @description used to track key down press from user. Used for accessibility on the faux radio buttons
     * @param {*} event - keyboard event
     * @return break out if option was disabled
     */
    handleKeyDown(event) {
        if (event.key === 'Enter') {
            // When Enter key is pressed, simulate a click on the focused radio input
            const focusedElement = this.template.activeElement;
            if (
                focusedElement &&
                focusedElement.tagName === 'SPAN' &&
                focusedElement.classList.contains('slds-radio_faux')
            ) {
                let index = focusedElement.id.indexOf('-');
                let option;
                if (index !== -1) {
                    option = focusedElement.id.slice(0, index);
                } else {
                    option = focusedElement.id;
                }

                if (
                    (this.mailingDisabled && option === 'mailing') ||
                    (this.residentialDisabled && option === 'residential')
                ) {
                    return;
                }
                this.selectedLocationOption = option;
                this.template.querySelector('input[value="' + this.selectedLocationOption + '"]').checked = 'checked';
            }
        }
    }

    /**
     * @description Stores the user's location option selection and resets the error/warning messages on fields if they were invalid
     * @param {*} event
     */
    chooseLocOption(event) {
        this.selectedLocationOption = event.target.value;
        this.nonAddrRequired = false;
        this.otherCurLocRequired = false;
        this.template.querySelector('input[value="' + this.selectedLocationOption + '"]').checked = 'checked';
    }

    /**
     * @description Stores the user's text area input
     * @param {*} event
     */
    handleNonAddrInput(event) {
        this.nonAddrText = event.detail.value;
    }

    /**
     * @description If this is running in a flow context, the footer 'Cancel' button will act as the 'BACK' action
     */
    handleCancel() {
        if (this.availableActions.find((action) => action === 'BACK')) {
            // navigate to the prev screen
            const navigateBackEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(navigateBackEvent);
        }
    }

    /**
     * @description If this is running in a flow context, the footer 'Next' button will act as the 'Next' action
     */
    async handleNext() {
        if (this.validate()) {
            //Handle the E911 metrics record update/creation via apex
            switch (this.selectedLocationOption) {
                case 'residential':
                    await handleSubmit({
                        e911RecordId: this.e911RecordId,
                        accountId: this.accountId,
                        serializedAddressInfo: JSON.stringify(this.residentialAddress),
                        nonAddrInfo: null
                    });
                    break;
                case 'mailing':
                    await handleSubmit({
                        e911RecordId: this.e911RecordId,
                        accountId: this.accountId,
                        serializedAddressInfo: JSON.stringify(this.mailingAddress),
                        nonAddrInfo: null
                    });
                    break;
                case 'othercurloc':
                    await handleSubmit({
                        e911RecordId: this.e911RecordId,
                        accountId: this.accountId,
                        serializedAddressInfo: JSON.stringify(this.otherCurLoc),
                        nonAddrInfo: null
                    });
                    break;
                case 'nonaddress':
                    await handleSubmit({
                        e911RecordId: this.e911RecordId,
                        accountId: this.accountId,
                        serializedAddressInfo: null,
                        nonAddrInfo: this.nonAddrText
                    });
                    break;
                default:
                    break;
            }

            if (this.availableActions.find((action) => action === 'NEXT')) {
                // navigate to the next screen
                const navigateNextEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent);
            }
        }
    }

    /**
     * @description Determines the actual account Id associated with the record/context that this was invoked on
     * @param recordId - record id that is going to be one of Account Id, Progress Note Id, or Case Id
     * @param objectApiName - object type/name that the record id is of: [Account, VCC_Progress_Note__c, Case]
     */
    getAccountId() {
        switch (this.objectApiName) {
            case 'Account':
                this.accountId = this.recordId;
                break;
            default:
                break;
        }
    }

    /**
     * @description Identifies what the default selected location option should be. If residential address or mailing address data was returned from API call, start with respective option as default
     */
    setDefaultedLocOption() {
        this.selectedLocationOption = 'othercurloc';
        //Enable options if values from API were retrieved
        if (this.mailingAddress !== null && !Object.values(this.mailingAddress).every((x) => x === null)) {
            this.mailingDisabled = false;
            this.selectedLocationOption = 'mailing';
        }

        if (this.residentialAddress !== null && !Object.values(this.residentialAddress).every((x) => x === null)) {
            this.residentialDisabled = false;
            this.selectedLocationOption = 'residential';
        }
    }

    /**
     * @description Handles the MPI callout to get patient's address data
     */
    async mpiCallout() {
        try {
            //MPI vet retreive callout
            const response = await retrieveVetInfo({
                recordId: this.accountId
            });

            //parse response
            let parsedResponse = JSON.parse(JSON.stringify(response));
            //pick out vet info, if it exists
            this.mpiData =
                Array.isArray(parsedResponse.vetsV3) && parsedResponse.vetsV3.length === 1
                    ? parsedResponse.vetsV3[0]
                    : null;

            //set error on MPI data
            if (!this.mpiData) {
                this.logger('No MPI Data was retrieved');
            }
        } catch (error) {
            this.logger(error);
        }
    }

    /**
     * @description Inits empty mailing, residential and otherCurLoc address vars
     */
    initAddresses() {
        this.residentialAddress = this.mailingAddress = {
            street: null,
            city: null,
            state: null,
            country: null,
            zipCode: null
        };

        this.otherCurLoc = Object.assign({}, this.residentialAddress);
        this.otherCurLoc.country = 'United States';
    }

    /**
     * @description Processes the retrieved MPIe json data into residential and mailing address vars
     */
    async getAddressesFromProfile() {
        let addressList = this.mpiData?.vaProfileV2?.vaProfileContactInfo?.addresses;

        if (typeof addressList === 'undefined' || addressList.length === 0) {
            return;
        }

        for (let address of addressList) {
            let mapping = {};
            mapping.street = [address.addressLine1, address.addressLine2, address.addressLine3]
                .filter((street) => street !== null && street !== '')
                .join(', ');
            ({ cityName: mapping.city = null, countryName: mapping.country = null } = address);

            switch (address.addressType) {
                case 'Domestic':
                case 'Overseas Military':
                    ({ zipCode5: mapping.zipCode = null, stateCode: mapping.state = null } = address);
                    break;
                case 'International':
                    ({ intPostalCode: mapping.zipCode = null, provinceName: mapping.state = null } = address);
                    break;
                default:
                    break;
            }

            switch (address.addressPurposeOfUse) {
                case 'CORRESPONDENCE':
                    this.mailingAddress = mapping;
                    break;
                case 'RESIDENCE':
                    this.residentialAddress = mapping;
                    break;
                default:
                    break;
            }
        }
    }

    /**
     * @description Validation to ensure that user selections and inputs are valid with existing data for future Apex processes
     */
    validate() {
        switch (this.selectedLocationOption) {
            case 'nonaddress':
                if (typeof this.nonAddrText === 'undefined' || this.nonAddrText === null || this.nonAddrText === '') {
                    this.nonAddrRequired = true;
                    return false;
                }
                break;
            case 'othercurloc':
                if (!Object.values(this.otherCurLoc).every((x) => x !== null && x !== '')) {
                    this.otherCurLocRequired = true;
                    return false;
                }
                break;
            default:
                break;
        }
        return true;
    }
}
