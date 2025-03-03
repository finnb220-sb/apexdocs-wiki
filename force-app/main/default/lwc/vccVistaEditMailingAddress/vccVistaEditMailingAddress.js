import { api } from 'lwc';
import { addressFields, states } from 'c/vccVistaConstants';
import LightningModal from 'lightning/modal';

import ConfirmModal from 'c/baseConfirmPopup';
import validateAddress from '@salesforce/apex/VCC_lwc_utils.validateAddress';
import updateAddresses from '@salesforce/apex/VCC_VistaAddressManagementController.updateMailingAddressesVTC';

export default class vccVistaEditMailingAddress extends LightningModal {
    @api hasPendingMeds; // Array of facility names that have pending meds
    openedPendingMeds;
    @api addresses;
    @api addressType = 'Mail'; // One of 'Mail' or 'Temp' to be handled differently
    address = { country: 'USA' };
    @api icn;
    avsAddresses = []; // Array of Address Validation Service USPS possible matching candidate addresses
    avsAddress;
    noMatchingAddress;
    noMatchingMessage =
        'The address entered is not recognized as a valid address, would you like to proceed anyway? ' +
        'Proceeding with an override will save an address that is potentially undeliverable by USPS.';
    noValidation;
    noValidationMessage =
        'The address validation could not be completed, and the address could not be validated. ' +
        'Proceeding with the address changes will save an address that is potentially undeliverable by USPS.';

    CONFIRM_MEDS = 'Acknowledge';

    isLoading;
    page = {
        one: true,
        two: false,
        three: false
    };
    selectedUser = false;
    selectedAvs = false;

    siteUpdateSuccess;
    siteSuccessMessage = 'The address update was successfully completed at the following facilities:';
    siteUpdateFailed;
    siteFailedMessage =
        'The mailing address change for these facilities could not be saved in VistA. ' +
        'Please make your update directly in VistA.';

    /**
     * @description This will determine if the AVS Address Card is disabled and other logic on card selection
     */
    get avsDisableCard() {
        return this.noMatchingAddress || this.noValidation;
    }

    /**
     * @description This will determine if the Confirm button is enabled when a card is selected
     */
    get noAddressCardSelected() {
        return !this.selectedAvs && !this.selectedUser;
    }

    /**
     * @description This will get the address options based on the address values selected in prior modal, as well as present a 'New Address' option
     */
    get addressOptions() {
        let options = [];
        options.push({ label: 'New Address', value: 'New Address' });

        this.addresses.forEach((addr) => {
            options.push({
                label: addr['singleLine' + this.addressType],
                value: addr.facilityId
            });
        });

        return options;
    }

    get noteSitesToSet() {
        return (
            'The following address will be set as the mailing address for ' +
            this.addresses.map((site) => site.facilityName).join(', ') +
            '.'
        );
    }

    fieldsInvalid;

    mailFields = addressFields.mail;
    allowedKeys = new Set(this.mailFields.map((field) => field.key));

    initialRender = true;
    rerenderForm;

    /**
     * @description Redered callback to populate address fields on screen based on selection.
     */
    renderedCallback() {
        if (this.initialRender && this.template.querySelectorAll('[data-field="mailing"]')?.length) {
            this.initialRender = false;
            this.populateFields();
            if (this.addressOptions.length === 2) {
                this.template.querySelector('[data-field="addressSelector"]').value = this.addressOptions[1].value;
                this.populateAddress(this.addressOptions[1].value);
            }
        }
        if (this.rerenderForm && this.template.querySelectorAll('[data-field="mailing"]')?.length) {
            this.populateFields();
            this.rerenderForm = false;
        }
        if (!this.openedPendingMeds && this.hasPendingMeds && this.hasPendingMeds?.length) {
            this.openedPendingMeds = true;
            let msg =
                'Veteran has pending, transmitted, or suspended prescriptions in facilit' +
                (this.hasPendingMeds.length > 1 ? 'ies: ' : 'y ') +
                this.hasPendingMeds.join(', ') +
                '. Completing the address change at this time may interfere with delivery of those prescriptions.';
            ConfirmModal.open({
                title: 'Pending Medication Warning',
                content: msg,
                variant: 'warning',
                styling: 'slds-align_absolute-center slds-var-m-around_large',
                next: this.CONFIRM_MEDS
            }).then((result) => {
                if (result !== this.CONFIRM_MEDS) {
                    this.handleClose();
                }
            });
        }
    }

    /**
     * @description This will handle the logic for field validation and input changes.
     * @param event The input change event that occurs.
     */
    handleInputChange(event) {
        let field = event.target.dataset.id;
        this.address[field] = event.detail.value;
        this.validateFields();
    }

    /**
     * @description This will handle changes on address to populate the fields based on selection or clear them.
     * @param event The input change event that occurs.
     */
    handleAddressChange(event) {
        let selectedFacility = event.detail.value;

        // If the selected address type is "New Address", reset all fields
        if (selectedFacility === 'New Address') {
            this.resetAddressFields();
        } else {
            this.populateAddress(selectedFacility);
        }
    }

    /**
     * @description Populate addess for the VTC call based on user selection and inputs.
     * @param siteId Facility Id used to populate the address.
     */
    populateAddress(siteId) {
        let foundAddress = this.addresses.find((addr) => addr.facilityId === siteId);

        if (foundAddress && foundAddress['address' + this.addressType]) {
            this.address = { ...foundAddress['address' + this.addressType] };
            if (this.address.country !== 'USA') {
                this.address.country = '';
            }
            if (this.address.state) {
                let stateEntry = states.find(
                    (pickValue) => pickValue?.label?.toLowerCase() === this.address?.state?.toLowerCase()
                );
                if (stateEntry) {
                    this.address.state = stateEntry.value;
                }
            }
            this.populateFields();
        }
    }

    /**
     * @description Will auto-populate address fields based on selections from picklist.
     */
    populateFields() {
        let fields = this.template.querySelectorAll('[data-field="mailing"]');
        fields.forEach((input) => {
            let fieldKey = input.dataset.id;
            input.value = this.address[fieldKey];
        });
        this.validateFields();
    }

    /**
     * @description Function to reset address fields per selecting "New Address" picklist option.
     */
    resetAddressFields() {
        this.address = {};
        this.address.street1 = '';
        this.address.street2 = '';
        this.address.street3 = '';
        this.address.city = '';
        this.address.state = '';
        this.address.zipExt = '';
        this.address.country = 'USA';
        this.populateFields();
    }

    /**
     * @description Will validate field inputs to ensure they have the proper length, characters, etc...
     * @returns Will return a boolean to determine if the data in the fields passes necessary validation.
     */
    validateFields() {
        let fields = this.template.querySelectorAll('[data-field="mailing"]');
        let isValid = true;
        fields.forEach((input) => {
            input.checkValidity();
            isValid = isValid && input.reportValidity();
        });
        this.fieldsInvalid = !isValid;
        return isValid;
    }

    /**
     * @description This will handle the address card selection.
     */
    handleCheckboxSelect(event) {
        let check = event.target.checked;
        let card = event.target.dataset.item;
        if (card === 'userAddress') {
            if (!this.avsDisableCard) {
                this.template.querySelector('[data-item="avsAddress"]').checked = !check;
                this.selectedAvs = !check;
            }
            this.template.querySelector('[data-item="userAddress"]').checked = check;
            this.selectedUser = check;
        } else {
            this.template.querySelector('[data-item="userAddress"]').checked = !check;
            this.selectedUser = !check;
            this.template.querySelector('[data-item="avsAddress"]').checked = check;
            this.selectedAvs = check;
        }
    }

    /**
     * @description This will handle the modal closing.
     */
    handleClose() {
        this.close('close');
    }

    /**
     * @description This will handle the USPS address validation required by calling the validateAddress function.
     */
    handleVerify() {
        if (this.validateFields() && this.address.country === 'USA') {
            this.page = { one: false, two: true, three: false };
            this.isLoading = true;
            this.noMatchingAddress = false;
            this.noValidation = false;
            this.selectedAvs = false;
            this.selectedUser = false;
            const requestAddress = {
                addressLine1: this.address.street1,
                addressLine2: this.address.street2,
                addressLine3: this.address.street3,
                city: this.address.city,
                zipCode5: this.address.zipExt?.slice(0, 5),
                zipCode4: this.address.zipExt?.length >= 9 ? this.address.zipExt?.slice(-4) : '',
                province: this.address.state,
                country: this.address.country
            };
            validateAddress({
                data: requestAddress,
                type: 'CORRESPONDENCE'
            })
                .then((data) => {
                    this.avsAddresses = JSON.parse(JSON.parse(data)).candidateAddresses;
                    this.avsAddresses.sort(
                        (a, b) => b?.addressMetaData?.confidenceScore - a?.addressMetaData?.confidenceScore
                    );

                    if (this.avsAddresses.length && this.avsAddresses[0].addressMetaData.confidenceScore > 80) {
                        this.noMatchingAddress = false;

                        this.avsAddress = JSON.parse(JSON.stringify(this.avsAddresses[0].address));

                        this.avsAddress.country = 'USA';
                        this.avsAddress.state = this.avsAddress?.stateProvince?.code;

                        if (this.avsAddress.city && this.avsAddress?.city?.length > 15) {
                            this.avsAddress.city = this.address.city;
                        }

                        this.avsAddress.zipExt =
                            this.avsAddress.zipCode5 +
                            (this.avsAddress.zipCode4?.length ? '-' + this.avsAddress.zipCode4 : '');

                        if (
                            this.avsAddress?.addressLine1?.length > 35 ||
                            this.avsAddress?.addressLine2?.length > 30 ||
                            this.avsAddress?.addressLine3?.length > 30
                        ) {
                            let line1 = this.avsAddress.addressLine1;
                            let line2 = this.avsAddress.addressLine2;
                            let line3 = this.avsAddress.addressLine3;
                            if (line1.length > 35) {
                                let words = line1.slice(0, 35).split(' ');
                                let strBreak = words.pop() + line1.slice(35);
                                this.avsAddress.street1 = words.join(' ');
                                line2 = [strBreak, line2].join(' ');
                                this.avsAddress.street2 = line2;
                            }
                            if (line2.length > 30) {
                                let words = line2.slice(0, 30).split(' ');
                                let strBreak = words.pop() + line2.slice(35);
                                this.avsAddress.street2 = words.join(' ');
                                line3 = [strBreak, line3].join(' ');
                                this.avsAddress.street3 = line3;
                            }
                            if (line3.length > 30) {
                                let words = line2.slice(0, 30).split(' ');
                                let strBreak = words.pop() + line2.slice(35);
                                this.avsAddress.street2 = words.join(' ');
                                line3 = [strBreak, line3].join(' ');
                                this.avsAddress.street3 = line3;
                            }
                        } else {
                            this.avsAddress.street1 = this.avsAddress.addressLine1;
                            this.avsAddress.street2 = this.avsAddress.addressLine2;
                            this.avsAddress.street3 = this.avsAddress.addressLine3;
                        }

                        Object.keys(this.avsAddress).forEach((attr) => {
                            if (!this.allowedKeys.has(attr)) {
                                delete this.avsAddress[attr];
                            }
                        });
                    } else {
                        this.noMatchingAddress = true;
                    }
                })
                .catch(() => {
                    this.noValidation = true;
                })
                .finally(() => {
                    this.isLoading = false;
                    if (!this.avsDisableCard) {
                        this.selectedAvs = true;
                        this.selectedUser = false;
                    }
                });
        }
    }

    handleBack() {
        this.page = { one: true, two: false, three: false };
        this.rerenderForm = true;
    }

    /**
     * @description This function will handle submission of the data, make necessary validation and verification calls, etc...
     */
    handleSubmit() {
        // Here, you can add your save logic (e.g., calling an Apex method)
        if (!this.noAddressCardSelected) {
            this.isLoading = true;
            this.page = { one: false, two: false, three: true };
            this.disableClose = true;
            let updateAddress;
            if (this.selectedAvs) {
                updateAddress = JSON.parse(JSON.stringify(this.avsAddress));
            } else {
                updateAddress = JSON.parse(JSON.stringify(this.address));
            }

            // Convert the state code back to the label for DIVA / RPCs
            updateAddress.state = states.find((entry) => entry.value === updateAddress.state)?.label;

            let data = {
                icn: this.icn,
                facilityIds: this.addresses.map((addr) => addr.facilityId),
                newAddress: updateAddress
            };
            updateAddresses({ args: data })
                .then((result) => {
                    result?.sites?.forEach((site) => {
                        if (site?.errors?.length) {
                            if (!this.siteUpdateFailed) {
                                this.siteUpdateFailed = [];
                            }
                            this.siteUpdateFailed.push({
                                key: site.id,
                                label:
                                    this.addresses.find((addr) => addr.facilityId === site.id)?.facilityName +
                                    ' : ' +
                                    site.errors.map((err) => err.type + ' : ' + err.message).join(' ---- ')
                            });
                        } else {
                            if (!this.siteUpdateSuccess) {
                                this.siteUpdateSuccess = [];
                            }
                            this.siteUpdateSuccess.push({
                                key: site.id,
                                label: this.addresses.find((addr) => addr.facilityId === site.id)?.facilityName
                            });
                        }
                    });
                })
                .catch((error) => {
                    if (!this.siteUpdateFailed) {
                        this.siteUpdateFailed = [];
                    }
                    this.addresses.forEach((addr) => {
                        if (
                            !this.siteUpdateFailed.find((site) => site.key === addr.facilityId) &&
                            !this.siteUpdateSuccess?.find((site) => site.key === addr.facilityId)
                        ) {
                            this.siteUpdateFailed.push({
                                key: addr.facilityId,
                                label: addr.facilityName + ' : Unhandled error: ' + JSON.stringify(error)
                            });
                        }
                    });
                })
                .finally(() => {
                    this.isLoading = false;
                });
        }
    }

    handleComplete() {
        this.disableClose = false;
        this.close('Confirmed');
    }
}
