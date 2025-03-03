import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import writeAddress from '@salesforce/apex/VCC_lwc_utils.vaProfileWriteAddress';
import writePhone from '@salesforce/apex/VCC_lwc_utils.vaProfileWritePhone';
import writeEmail from '@salesforce/apex/VCC_lwc_utils.vaProfileWriteEmail';
import vaProfileUpsertAssociatedPersons from '@salesforce/apex/VCC_lwc_utils.vaProfileUpsertAssociatedPersons';
import validateAddress from '@salesforce/apex/VCC_lwc_utils.validateAddress';
// import createVaProfile from '@salesforce/apex/VCC_lwc_utils.createVaProfile';
import pendingMedicationsLabel from '@salesforce/label/c.VAHC_Pending_Medications_message';
import static_data from '@salesforce/resourceUrl/vccCountries';
import * as helper from 'c/helpersLWC';
import { hasPendingMedications, dispatchToast } from './vccEditAddressHelper';
import { BridgMedsError } from 'c/baseErrors';
import pendingMedsFail from '@salesforce/label/c.VCC_Pending_Meds_Fail';
import hdrUnavailable from '@salesforce/label/c.VCC_HDR_ERROR_LABEL';
import phoneNumberLabel from '@salesforce/label/c.Phone_Number';
import { checkAddressValidity, removeControlCharacters } from 'c/vccVaProfileController';
import invalidAddressTitle from '@salesforce/label/c.VCC_VA_Profile_Invalid_Address_Title';
import invalidPOBOX from '@salesforce/label/c.VCC_VA_Profile_Address_Error_POBOX';
import addressNotFound from '@salesforce/label/c.VCC_VA_Profile_Address_Error_Not_Found';
import { loadScript } from 'lightning/platformResourceLoader';
const INVALID_ADDRESS_TITLE = invalidAddressTitle;
const INVALID_PO_BOX = invalidPOBOX;
const ADDRESS_NOT_FOUND = addressNotFound;
export default class VccEditAddress extends LightningElement {
    pendingMedsFail = pendingMedsFail;
    hdrUnavailable = hdrUnavailable;

    messages = {
        overrideMessage:
            'The address entered is not recognized as a valid address, would you like to proceed anyway? Proceeding with an override will save an address that is potentially undeliverable by USPS.'
    };
    @api recordid;
    @api telephone;
    //@api addressedit;
    @api phoneedit;
    @api emailedit;
    @api inputType;
    showModal = false;
    loading = false;
    mode = 'Edit';
    showFooter = true;
    displayType;
    overrideAddress = false;
    phNumLbl = phoneNumberLabel; // Expose the imported label to the template
    phone;
    areaCode;
    extension;
    email;
    validationKey = null;
    _pendingMeds;
    _type;
    //address
    getAddressCountryOptions;
    options;
    _addressedit;
    medsCalloutError = false;

    @api
    set addressedit(value) {
        if (value) {
            /**
             * create "full" property to house multiple address line display
             */
            if (typeof value === 'object') {
                this._addressedit = {
                    ...value,
                    full: `${value?.addressLine1 !== null ? value?.addressLine1 + '\n' : ''} ${value?.addressLine2 !== null ? value?.addressLine2 + '\n' : ''} ${value?.addressLine3 !== null ? value?.addressLine3 + '\n' : ''}`,
                    fullZip: `${value?.zipCode5 != null ? (value?.zipCode4 != null ? value?.zipCode5 + '-' + value?.zipCode4 : value?.zipCode5) : value?.intPostalCode != null ? value?.intPostalCode : ''}`
                };
            }
        }
    }

    get addressedit() {
        return this._addressedit;
    }

    _nextofkinoremergencyconobj;
    @api
    set nextofkinoremergencyconobj(value) {
        this._nextofkinoremergencyconobj = value;
    }
    get nextofkinoremergencyconobj() {
        return this._nextofkinoremergencyconobj;
    }
    onPhoneChange(event) {
        this.phone = event.detail.value;
        this.template.querySelector('[data-id="submit-btn"]').disabled = false;
    }

    onAreaCodeChange(event) {
        this.areaCode = event.detail.value;
        this.template.querySelector('[data-id="submit-btn"]').disabled = false;
    }

    onEmailChange(event) {
        this.email = event.detail.value;
        this.template.querySelector('[data-id="submit-btn"]').disabled = false;
    }

    get showPendingMedsModal() {
        if (this._pendingMeds && this._type === 'CORRESPONDENCE') {
            this.showFooter = false;
            return true;
        } else {
            return false;
        }
    }

    @api set pendingMeds(value) {
        if (value) {
            this._pendingMeds = true;
        } else {
            this._pendingMeds = false;
            this.showFooter = true;
        }
    }

    get pendingMeds() {
        return this._pendingMeds;
    }

    // showFooter;

    @api show() {
        this.showModal = true;
    }

    @api hide() {
        this.showModal = false;
    }

    @api address = {
        badAddress: false,
        overrideIndicator: false
    };

    @track
    nav = {
        phone: false,
        email: false,
        address: false,
        create: false
    };

    value;
    /**
     * defaulting to USA since VA Profile only supports domestic addresses
     */
    @track phoneWrapper = {
        areaCode: null,
        countryCode: '1',
        internationalIndicator: false,
        effectiveEndDate: null,
        phoneNumber: null,
        phonetype: null,
        phoneNumberExt: null
    };

    async handleSubmit() {
        this.template.querySelector('[data-id="submit-btn"]').disabled = true;

        if (this.inputType) {
            switch (this.inputType) {
                case 'create':
                    const isInputsCorrect3 = [...this.template.querySelectorAll('lightning-input')].reduce(
                        (validSoFar, inputField) => {
                            inputField.reportValidity();
                            return validSoFar && inputField.checkValidity();
                        },
                        true
                    );

                    if (isInputsCorrect3) {
                        this.create();
                    }
                    break;

                case 'address':
                    this.writeAddress();
                    break;

                case 'phone':
                    const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')].reduce(
                        (validSoFar, inputField) => {
                            inputField.reportValidity();
                            return validSoFar && inputField.checkValidity();
                        },
                        true
                    );
                    if (isInputsCorrect) {
                        this.phoneWrapper = {
                            areaCode: this.template.querySelector('[data-id="area-code"]').value,
                            countryCode: this.phoneWrapper.countryCode,
                            internationalIndicator: this.phoneWrapper.countryCode === '1' ? false : true,
                            phoneNumber: this.template.querySelector('[data-id="phone"]').value,
                            phonetype: helper.upperCase(this._type),
                            phoneNumberExt: this.isShowExtension
                                ? this.template.querySelector('[data-id="extension"]').value
                                : ''
                        };

                        this.writePhone();
                    }
                    break;
                case 'email':
                    const isInputsCorrect2 = [...this.template.querySelectorAll('lightning-input')].reduce(
                        (validSoFar, inputField) => {
                            inputField.reportValidity();
                            return validSoFar && inputField.checkValidity();
                        },
                        true
                    );
                    if (isInputsCorrect2) {
                        this.writeEmail();
                        break;
                    }
            }
        }
    }

    async handleDelete() {
        if (this.inputType) {
            switch (this.inputType) {
                case 'phone':
                    const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')].reduce(
                        (validSoFar, inputField) => {
                            inputField.reportValidity();
                            return validSoFar && inputField.checkValidity();
                        },
                        true
                    );
                    if (isInputsCorrect) {
                        this.phoneWrapper = {
                            areaCode: this.template.querySelector('[data-id="area-code"]').value,
                            countryCode: this.phoneWrapper.countryCode,
                            effectiveEndDate: new Date().toISOString(), // Set effectiveEndDate to current datetime which functionally removes the phone number.
                            internationalIndicator: this.phoneWrapper.countryCode === '1' ? false : true,
                            phoneNumber: this.template.querySelector('[data-id="phone"]').value,
                            phonetype: helper.upperCase(this._type),
                            phoneNumberExt: this.isShowExtension
                                ? this.template.querySelector('[data-id="extension"]').value
                                : ''
                        };

                        this.writePhone();
                        break;
                    }
            }
        }
    }

    @track picklistVals = [];

    @api set type(value) {
        if (value) {
            this._type = value;
        } else {
            this._type = null;
        }
    }

    get type() {
        return this._type;
    }

    get isMailing() {
        return this._type === 'CORRESPONDENCE';
    }

    get medsLabel() {
        return pendingMedicationsLabel;
    }

    get isShowExtension() {
        if (this._type === 'NextOfKin' || this._type === 'EmergencyContact' || this._type === 'Home') {
            return false;
        }
        return true;
    }

    get isWorkPhone() {
        if (this._type === 'Work') {
            return true;
        }
        return false;
    }

    async connectedCallback() {
        this.loading = true;
        loadScript(this, static_data)
            .then(() => {
                this.options = window.telephoneCountryCodes.map((country) => {
                    return {
                        label: country.name,
                        value: country.dial_code
                    };
                });
                this.getAddressCountryOptions = window.addressCountryCodes.map((country) => {
                    return {
                        label: country.countryName,
                        value: country.countryCodeISO3
                    };
                });
            })
            .catch((error) => {
                const logger = this.template.querySelector('c-logger');
                if (logger !== undefined) logger.error(error);
                logger.saveLog();
            });
        try {
            if (this._type === 'CORRESPONDENCE') {
                const hasPendingMeds = await hasPendingMedications(this.recordid);

                if (hasPendingMeds) {
                    this._pendingMeds = true;
                } else {
                    this._pendingMeds = false;
                    this.showFooter = true;
                }
            }
        } catch (err) {
            err instanceof BridgMedsError &&
                dispatchToast(this.template, { title: hdrUnavailable, message: pendingMedsFail, variant: 'warning' });
        }

        /**
         * check if incoming address is defined and not empty
         */

        if (this.addressedit && Object.keys(this.addressedit).length) {
            this.address = this.addressedit;
        }

        /**
         * Dynamic Header for addresses
         */

        if (
            this._type &&
            this.inputType.includes('address') &&
            (this._type.includes('CORRESPONDENCE') || this._type.includes('RESIDENCE'))
        ) {
            this.displayType = this._type === 'CORRESPONDENCE' ? 'Mailing Address' : 'Residential Address';
        } else {
            if (this.type === 'NextOfKin' || this.type === 'EmergencyContact') {
                this.displayType = ' ' + `${helper.properCase(this.inputType)}`;
            } else {
                this.displayType = (this.type == null ? '' : this.type + ' ') + `${helper.properCase(this.inputType)}`;
            }
        }

        /**
         * Set HTML template based on inputType -> Address (mailing or residential), Email and Phone
         */

        if (this.inputType) {
            this.setTemplate(this.inputType);
        }

        this.loading = false;
    }

    /**
     * @return {`void`} Create VA Profile instance based on Email
     */

    async create() {
        try {
            this.loading = true;
            // const response = await createVaProfile({
            //     recordId: this.recordid,
            //     email: this.template.querySelector('[data-id="email"]').value
            // });

            this.loading = false;

            const post = new CustomEvent('post', {
                bubbles: true,
                cancelable: false,
                composed: true
            });

            this.dispatchEvent(post);

            const evt = new ShowToastEvent({
                title: 'Success',
                message: 'Email Updated Successfully',
                variant: 'success'
            });
            this.dispatchEvent(evt);
            this.handleDialogClose();
        } catch (err) {
            const evt = new ShowToastEvent({
                title: 'Record Not Created',
                message: err,
                variant: 'error'
            });
            this.dispatchEvent(evt);
            this.loading = false;
        }
    }

    throwAddressValidationToastErrors(errors) {
        for (let i = 0; i < errors.length; i++) {
            const evt = new ShowToastEvent({
                title: INVALID_ADDRESS_TITLE,
                message: errors[i],
                variant: 'warning',
                mode: 'pester'
            });
            this.dispatchEvent(evt);
        }
    }
    processAddressForRequest() {
        //Process Multi Line Address
        if (typeof this.address.street == 'string' && this.address.street.search('\n') !== -1) {
            let addressLines = this.address.street.split('\n').flatMap((e) => {
                if (e === '') {
                    return [];
                }
                return removeControlCharacters(e);
            });

            if (addressLines.length >= 1) {
                this.address.addressLine1 = addressLines[0];
            } else {
                this.address.addressLine1 = null;
            }

            if (addressLines.length >= 2) {
                this.address.addressLine2 = addressLines[1];
            } else {
                this.address.addressLine2 = null;
            }

            if (addressLines.length >= 3) {
                this.address.addressLine3 = addressLines[2];
            } else {
                this.address.addressLine3 = null;
            }
        } else {
            this.address.addressLine1 = this.address.street;
            this.address.addressLine2 = null;
            this.address.addressLine3 = null;
        }
        //Process Postal Code into zipCode5 and zipCode4
        this.address.zipCode5 = this.address.postalCode.slice(0, 5);
        //Set ZipCode4 if Postal Code is longer than 5 digits
        if (this.address.postalCode.length > 5) {
            this.address.zipCode4 = this.address.postalCode.substr(this.address.postalCode.length - 4);
        } else {
            this.address.zipCode4 = '';
        }
        if (this.address.country === 'US') this.address.country = 'USA';
    }
    async writeAddress() {
        //Check for an invalid address
        let addressErrors = checkAddressValidity(this.address);
        //Is address valid? If not throw toast message errors and return
        if (Array.isArray(addressErrors) && addressErrors.length) {
            this.throwAddressValidationToastErrors(addressErrors);
            return;
        }
        this.processAddressForRequest();
        this.loading = true;

        try {
            // /*const response = await writeAddress({
            //     recordId: this.recordid,
            //     data: this.address,
            //     type: this._type,
            //     key: this.validationKey
            // });*/

            await writeAddress({
                recordId: this.recordid,
                data: this.address,
                type: this._type,
                key: this.validationKey
            });

            const post = new CustomEvent('post', {
                bubbles: true,
                cancelable: false,
                composed: true
            });

            this.dispatchEvent(post);

            const evt = new ShowToastEvent({
                title: 'Success',
                message: 'Address Updated Successfully',
                variant: 'success'
            });
            this.dispatchEvent(evt);
            this.loading = false;
            this.handleDialogClose();
        } catch (err) {
            if (JSON.stringify(err).includes('POBox could not be validated')) {
                this.vaProfileErrorToast(INVALID_PO_BOX);
            } else if (JSON.stringify(err).includes('The Address could not be found')) {
                this.vaProfileErrorToast(ADDRESS_NOT_FOUND);
            } else {
                const evt = new ShowToastEvent({
                    title: 'Failure',
                    message: 'Address not updated',
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            }
            this.loading = true;
            await this.vaProfileAddressReject(this.address);
            // Focus override modal for 508 compliance.
            setTimeout(() => {
                let overrideBtn = this.template.querySelector("[data-id='override-button']");
                if (overrideBtn) {
                    overrideBtn.focus();
                }
            }, 0);
            /**
             * Invoke override logic
             */

            this.loading = false;
        }
    }

    /**
     * @description set variables to display override modal, then grab validation key from AVS and set the validationKey property
     * @param {`String`} address Address object to pass through to AVS
     *
     */

    async vaProfileAddressReject() {
        this.loading = true;
        const avsObject = await this.getOverrideKey();
        this.validationKey = avsObject?.candidateAddresses[0]?.addressMetaData?.validationKey || null;

        if (this.validationKey) {
            this.overrideAddress = true;
            this.showFooter = false;
        }

        this.loading = false;
        return;
    }

    vaProfileErrorToast(message) {
        const evt = new ShowToastEvent({
            title: 'Failure',
            message: message,
            variant: 'error'
        });
        this.dispatchEvent(evt);
    }

    async writeAddressWithKey() {
        try {
            this.loading = true;
            this.address = { ...this.address, overrideIndicator: true };
            await writeAddress({
                recordId: this.recordid,
                data: this.address,
                type: this._type,
                key: this.validationKey
            });

            this.loading = false;

            const post = new CustomEvent('post', {
                bubbles: true,
                cancelable: false,
                composed: true
            });

            this.dispatchEvent(post);

            const evt = new ShowToastEvent({
                title: 'Success',
                message: 'Address Updated Successfully',
                variant: 'success'
            });

            this.dispatchEvent(evt);
            this.handleDialogClose();
        } catch (err) {
            if (JSON.stringify(err).includes('POBox could not be validated')) {
                this.vaProfileErrorToast(INVALID_PO_BOX);
            } else if (JSON.stringify(err).includes('The Address could not be found')) {
                this.vaProfileErrorToast(ADDRESS_NOT_FOUND);
            } else {
                const evt = new ShowToastEvent({
                    title: 'Failure',
                    message: 'Address unable to be persisted',
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            }
            this.loading = false;
        }
    }

    async getOverrideKey() {
        try {
            this.loading = true;
            const response = await validateAddress({
                data: this.address,
                type: this._type
            });

            this.loading = false;

            // const evt = new ShowToastEvent({
            //     title: 'Validation Override Key Obtained',
            //     variant: 'success',
            // });
            // this.dispatchEvent(evt);

            return JSON.parse(JSON.parse(response));
        } catch (err) {
            const evt = new ShowToastEvent({
                title: 'Failure',
                message: 'Unable to contact Address Validation',
                variant: 'error'
            });
            this.dispatchEvent(evt);
            this.loading = false;
        }
    }

    async writePhone() {
        try {
            this.loading = true;
            /*const response = await writePhone({
                recordId: this.recordid,
                phone: this.phoneWrapper,
                type: this._type
            });*/
            if (this._type === 'NextOfKin' || this._type === 'EmergencyContact') {
                let nextofkinoremergencyconobj = JSON.parse(JSON.stringify(this.nextofkinoremergencyconobj));
                delete nextofkinoremergencyconobj.telephoneVal;
                delete nextofkinoremergencyconobj.addressVal;
                nextofkinoremergencyconobj.addressLine1 = nextofkinoremergencyconobj.address.line1;
                nextofkinoremergencyconobj.addressLine2 = nextofkinoremergencyconobj.address.line2;
                nextofkinoremergencyconobj.addressLine3 = nextofkinoremergencyconobj.address.line3;
                nextofkinoremergencyconobj.city = nextofkinoremergencyconobj.address.city;
                nextofkinoremergencyconobj.state = nextofkinoremergencyconobj.address.state;
                nextofkinoremergencyconobj.county = nextofkinoremergencyconobj.address.country;
                nextofkinoremergencyconobj.zipCode = nextofkinoremergencyconobj.address.zipCode;
                nextofkinoremergencyconobj.zipPlus4 = nextofkinoremergencyconobj.address.zipPlus4;
                nextofkinoremergencyconobj.postalCode = nextofkinoremergencyconobj.address.postalCode;
                nextofkinoremergencyconobj.provinceCode = nextofkinoremergencyconobj.address.provinceCode;
                nextofkinoremergencyconobj.country = nextofkinoremergencyconobj.address.country;
                delete nextofkinoremergencyconobj.address;
                delete nextofkinoremergencyconobj.lastUpdateDate;
                delete nextofkinoremergencyconobj.organizationName;
                delete nextofkinoremergencyconobj.prefix;
                delete nextofkinoremergencyconobj.suffix;

                nextofkinoremergencyconobj.primaryPhone =
                    '(' + this.phoneWrapper.areaCode + ') ' + this.phoneWrapper.phoneNumber.replace('-', '');
                await vaProfileUpsertAssociatedPersons({
                    recordId: this.recordid,
                    data: this.phoneWrapper,
                    type: this._type,
                    nextofkinoremergencyconobj: JSON.stringify(nextofkinoremergencyconobj)
                });
            } else {
                await writePhone({
                    recordId: this.recordid,
                    phone: this.phoneWrapper,
                    type: this._type
                });
            }
            this.loading = false;

            const post = new CustomEvent('post', {
                bubbles: true,
                cancelable: false,
                composed: true
            });

            this.dispatchEvent(post);

            const evt = new ShowToastEvent({
                title: 'Success',
                message: 'Phone Updated Successfully',
                variant: 'success'
            });
            this.dispatchEvent(evt);
            this.handleDialogClose();
        } catch (err) {
            const evt = new ShowToastEvent({
                title: 'Failure',
                message: `phone not updated: ${err?.body?.message}`,
                variant: 'error'
            });
            this.dispatchEvent(evt);
            this.loading = false;
        }
    }

    async writeEmail() {
        try {
            this.loading = true;
            await writeEmail({
                recordId: this.recordid,
                email: this.template.querySelector('[data-id="email"]').value
            });
            this.loading = false;

            const post = new CustomEvent('post', {
                bubbles: true,
                cancelable: false,
                composed: true
            });

            this.dispatchEvent(post);

            const evt = new ShowToastEvent({
                title: 'Success',
                message: 'Email Updated Successfully',
                variant: 'success'
            });
            this.dispatchEvent(evt);
            this.handleDialogClose();
        } catch (err) {
            const evt = new ShowToastEvent({
                title: 'Failure',
                message: 'Email not updated',
                variant: 'error'
            });
            this.dispatchEvent(evt);
            this.loading = false;
        }
    }

    /**
     *
     * @param {string} input string that informs app which template to render, based on parent vaProfile component
     */

    setTemplate(input) {
        if (input) {
            switch (input) {
                case 'address':
                    this.nav.address = true;
                    break;

                case 'phone':
                    this.nav.phone = true;
                    break;

                case 'email':
                    this.nav.email = true;
                    break;

                case 'create':
                    this.mode = null;
                    this.displayType = 'Create Demographics Info';
                    this.nav.create = true;
                    this.showFooter = true;
                    break;
            }
        }
    }

    handleDialogClose() {
        //Let parent know that dialog is closed (mainly by that cross button) so it can set proper variables if needed
        const closedialog = new CustomEvent('closedialog', {
            bubbles: true,
            composed: true,
            cancelable: false
        });

        this.dispatchEvent(closedialog);
        this.hide();
    }

    handleChange(event) {
        const dataId = event?.currentTarget?.dataset?.id || null;
        if (dataId) {
            switch (dataId) {
                /*
                case 'effective-startdate':

                    const today = new Date();
                    const inputDate = new Date(event.target.value);

                    if (inputDate > today) {

                    }

                    if (helper.daysBetween(today, inputDate) > 60) {
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            message: 'Valid Date must not be greater than 60 days prior to today',
                            variant: 'error',
                        });
                        this.dispatchEvent(evt);
                        return;
                    }

                    this.address = {...this.address, effectiveStartDate: event.target.value};
                    break;

                    */

                case 'address':
                    this.address = { ...this.address, ...event.detail };
                    this.template.querySelector('[data-id="submit-btn"]').disabled = false;
                    break;

                case 'extension':
                    this.phoneWrapper = {
                        ...this.phoneWrapper,
                        phoneNumberExt: event.detail,
                        phoneNumber: this.phoneedit.phoneNumber,
                        areaCode: this.phoneedit.areaCode
                    };

                    this.template.querySelector('[data-id="submit-btn"]').disabled = false;
                    break;
            }
        }
    }

    handleTypeInput(event) {
        this._type = event.detail.value;
    }

    /**
     * @description generic click handler based on LWC data-attributes
     * @param {object} event
     */

    handleClick(event) {
        /**
         * dataset object, created from passed in event, used to guide functionlity
         * dataset comes from the data-id attribute in this components markup
         */
        const dataset = {
            id: event?.currentTarget?.dataset.id || null,
            name: event?.currentTarget?.dataset.name || null
        };

        if (dataset.id === 'med-button') {
            this._pendingMeds = false;
            this.showFooter = true;

            return;
        }

        if (dataset.id === 'override-button') {
            this.overrideAddress = false;
            this.showFooter = true;
            this.writeAddressWithKey();
        }

        if (dataset && dataset.id === 'back-button') {
            this.overrideAddress = false;
            this.showFooter = true;
        }
    }

    /**
     * @description rendered callback, setting default combobox value
     * @returns `undefined`
     */
    renderedCallback() {
        setTimeout(() => {
            // Call focus on pending medications modal for 508 compliance.
            let medButton = this.template.querySelector('[data-id="med-button"]');
            if (medButton) medButton.focus();

            // Call focus on address/email/phone edit modals for 508 compliance.
            let inputDataId = this.inputType === 'phone' ? 'area-code' : this.inputType;
            let inputField = this.template.querySelector('[data-id="' + inputDataId + '"]');
            if (inputField) inputField.focus();
        });
    }

    /**
     * returning today in ISO format to pass into lightning-input date
     */
    get today() {
        return new Date().toISOString();
    }

    handleKeyup(event) {
        if (event.target.value.length > 1) {
            this.picklistVals = this.options.filter((value) =>
                value.label.toLowerCase().includes(event.target.value.toLowerCase())
            );
        } else {
            this.picklistVals = [];
        }
    }

    handleSelect(event) {
        this.template.querySelector('[data-id="search-input"]').value = event.currentTarget.dataset.label;
        this.phoneWrapper.countryCode = event?.currentTarget?.dataset.value.slice(1);
        this.picklistVals = [];
    }
}
