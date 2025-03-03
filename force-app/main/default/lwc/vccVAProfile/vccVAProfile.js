import { LightningElement, api, track, wire } from 'lwc';
// import vccMPINoRecordsReturned from '@salesforce/label/c.vccMPINoRecordsReturned';
import vccVaProfileBadAddressTooltip from '@salesforce/label/c.vccVaProfileBadAddressTooltip';
import validateAddress from '@salesforce/apex/VCC_lwc_utils.validateAddress';
import writeAddress from '@salesforce/apex/VCC_lwc_utils.vaProfileWriteAddress';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import * as helper from 'c/helpersLWC';
import hasPharmI_Permission from '@salesforce/customPermission/VCC_Pharmacy_Tier_I';
import hasPharmII_Permission from '@salesforce/customPermission/VCC_Pharmacy_Tier_II';
import hasPharmIII_Permission from '@salesforce/customPermission/VCC_Pharmacy_Tier_III';
import { AssociatedPerson, AssociatedPersonKindToContactType } from 'c/vccVaProfileAssociatedPerson';
import isEnabled from '@salesforce/apex/VTC_FF.isEnabled';

// ADD TEMPORARY PHONETYPE   WHEN API IS CONFIGURED TO ACCEPT TEMPORARY PHONES
const phoneTypes = ['HOME', 'MOBILE', 'WORK', 'FAX'];

const accordianLabelMap = {
    telephones: 'Phone Number(s)',
    emails: 'Email Address(es)',
    addresses: 'Physical Address(es)',
    emergencyContact: 'Primary Emergency Contact',
    nextofKin: 'Primary Next of Kin',
    otherEmergencyContact: 'Other Emergency Contact',
    otherNextofKin: 'Other Next of Kin'
};

const expandedSections = [
    'addresses',
    'emails',
    'telephones',
    'emergencyContact',
    'nextofKin',
    'otherEmergencyContact',
    'otherNextofKin'
];

export default class VccVAProfile extends LightningElement {
    componentTitle = 'Contact Info';

    addressTypes;
    expandedSections = expandedSections;
    accordianLabelMap = accordianLabelMap;
    type = '';
    addressType = '';
    inputType = '';

    @api pendingMeds;
    @api recordId;

    mailingAddress;
    primaryAddress;
    loading = false;
    @api vaProfileData;
    @api vaProfileAssociatedPersons;
    @api vccRecordId;
    @api objectApiName;
    @api esrData;

    labels = {
        vccVaProfileBadAddressTooltip: vccVaProfileBadAddressTooltip
    };

    @track telephonesToDisplay = [];
    @track addressesToDisplay = [];
    @track emailsToDisplay = [];

    @track addressEdit;
    phoneEdit;
    emailEdit;

    editAddress = false;
    createDemographics = false;
    editPhone = false;
    editEmail = false;

    showEditValidateButtonMenu = true;
    isPharmUser = hasPharmI_Permission || hasPharmII_Permission || hasPharmIII_Permission;

    avsObject = {
        city: null,
        postalCode: null,
        street: null,
        province: null,
        country: null
    };

    @track addressesDisplay = {
        mailing: {
            addressLine1: null,
            cityName: null,
            stateCode: null,
            zipCode5: null,
            countryName: null,
            addressPurposeOfUse: null,
            fullAddressString: null
        },
        primary: {
            addressLine1: null,
            cityName: null,
            stateCode: null,
            zipCode5: null,
            countryName: null,
            addressPurposeOfUse: null,
            fullAddressString: null
        }
    };

    @track emergencyContact;
    @track primaryNextofKin;
    @track otherEmergencyContact;
    @track otherNextofKin;
    nextofkinoremergencyconobj;

    buttons = [{ label: 'Create', type: 'submit', handlerVar: 'createrecord' }];

    /**
     * @description Wire the isEnabled result from Feature Flagging framework to determine if user should see modals.
     */
    @wire(isEnabled, { featureName: 'VCC_Pharmacy_Address_Management' })
    wiredIsPharmacyAddressEnabled;

    async validate() {
        try {
            let response = await validateAddress({
                data: this.avsObject,
                type: this.avsObject.pou
            });

            /**
             * If response is not a valid stringified object it will an error will be thrown and execution will move over to catch block
             */

            response = JSON.parse(JSON.parse(response));

            /**
             * If successful response but no candidate address returned thrown
             */

            if (!response?.candidateAddresses?.length > 0) {
                throw new Error('address not found by avs');
            }

            const addressMetadata = response?.candidateAddresses[0]?.addressMetaData || null;

            /**
             * if the address is initially a bad address and
             * has a confidenceScore greater than 80 from AVS
             * write back badAddress = false to vaProfile
             */

            if (addressMetadata?.confidenceScore > 80 && this.avsObject.badAddress) {
                this.avsObject.badAddress = false;
                await writeAddress({
                    recordId: this.vccRecordId,
                    data: this.avsObject,
                    type: this.avsObject.pou,
                    key: null
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
            } else {
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'Address is valid',
                    variant: 'success'
                });
                this.dispatchEvent(evt);
            }

            // return JSON.parse(JSON.parse(response));
        } catch (err) {
            const logger = this.template.querySelector('c-logger');
            logger.error(JSON.stringify(err));
            logger.saveLog();
            const evt = new ShowToastEvent({
                title: 'Failure',
                message: 'Unable to obtain validation key',
                variant: 'error'
            });
            this.dispatchEvent(evt);
            this.loading = false;
            throw new Error('Unable to obtain validation key');
        }
    }

    /**
     * @description This lifecycle hook is triggered when the component is attached to the DOM.
     * It initializes data placeholders and processes initial data for addresses, telephones,
     * and emails. It also sets up associated persons based on their defined contact types.
     * It ensures that the component is fully prepared with all necessary data and structures
     * immediately after it becomes active in the DOM, allowing for a responsive and accurate
     * presentation of data as soon as the component is used.
     */
    connectedCallback() {
        this.initializePlaceholders();
        let addresses;
        let telephones;
        let emails;

        if (this.isPharmUser) {
            this.showEditValidateButtonMenu = false;
        }

        if (this.vaProfileData) {
            addresses = this.vaProfileData.addresses;
            telephones = this.vaProfileData.telephones;
            emails = this.vaProfileData.emails;
        }
        this.processAddresses(addresses);
        this.processTelephones(telephones);
        this.processEmails(emails);

        if (!Array.isArray(this.vaProfileAssociatedPersons)) {
            return;
        }

        this.vaProfileAssociatedPersons.forEach((associatedPerson) => {
            if (typeof associatedPerson.contactType !== 'string') {
                return;
            }
            if (
                typeof AssociatedPersonKindToContactType !== 'object' ||
                AssociatedPersonKindToContactType === null ||
                AssociatedPersonKindToContactType === undefined
            ) {
                return;
            }

            if (associatedPerson.contactType === AssociatedPersonKindToContactType.NextOfKin) {
                this.primaryNextofKin = new AssociatedPerson(associatedPerson);
            }

            if (associatedPerson.contactType === AssociatedPersonKindToContactType.EmergencyContact) {
                this.emergencyContact = new AssociatedPerson(associatedPerson);
            }

            if (associatedPerson.contactType === AssociatedPersonKindToContactType.OtherNextOfKin) {
                this.otherNextofKin = new AssociatedPerson(associatedPerson);
            }

            if (associatedPerson.contactType === AssociatedPersonKindToContactType.OtherEmergencyContact) {
                this.otherEmergencyContact = new AssociatedPerson(associatedPerson);
            }
        });
    }

    /**
     * @description Converts a string to title case where the first letter of each word is capitalized,
     * and the rest are in lowercase. This utility function is used to standardize text display,
     * particularly useful in user interfaces where consistent text formatting is crucial for
     * readability and aesthetics.
     * @param {string} str - The string to convert to title case.
     * @return {string} The string converted to title case.
     */
    toTitleCase(str) {
        return str
            .toLowerCase()
            ?.split(' ')
            .map(function (word) {
                return word.charAt(0).toUpperCase() + word.slice(1);
            })
            .join(' ');
    }

    /**
     * @description Initializes placeholders for telephone and address information,
     * setting up default structures for these data types in the UI. By setting up placeholders,
     * the function prepares the UI to handle and display user data correctly and uniformly,
     * even before any real data is loaded or entered.
     */
    initializePlaceholders() {
        //Assign Proper Address Types
        if (hasPharmI_Permission || hasPharmII_Permission || hasPharmIII_Permission) {
            this.addressTypes = ['Mailing'];
        } else {
            this.addressTypes = ['Mailing', 'Residential'];
        }
        // Initialize phone types with empty values
        this.telephonesToDisplay = phoneTypes.map((type) => ({
            areaCode: null,
            phoneType: this.toTitleCase(type),
            phoneNumber: null
        }));

        // Initialize address types with empty values
        this.addressesToDisplay = this.addressTypes.map((type) => ({
            addressLine1: null,
            cityName: null,
            stateCode: null,
            zipCode5: null,
            countryName: null,
            addressPurposeOfUse: null,
            fullAddressString: null,
            purposeOfUseMapping: type
        }));
    }

    /**
     * @description This function processes and displays telephone information.
     * It populates a list of telephones for display in the UI, integrating incoming data with predefined types.
     * The function ensures that telephone data is formatted and presented consistently across the user interface,
     * improving data readability and user interaction.
     * @param {Array} listOfTelephones - Array containing telephone data to be processed.
     */
    processTelephones(listOfTelephones) {
        if (listOfTelephones && Array.isArray(listOfTelephones)) {
            // Update placeholders with data from listOfTelephones
            listOfTelephones.forEach((incomingPhone) => {
                // Find the matching placeholder by phoneType
                const placeholderIndex = this.telephonesToDisplay.findIndex(
                    (placeholder) => this.toTitleCase(incomingPhone.phoneType) === placeholder.phoneType
                );

                if (placeholderIndex !== -1) {
                    // Update the placeholder with incoming phone data
                    this.telephonesToDisplay[placeholderIndex] = {
                        ...this.telephonesToDisplay[placeholderIndex],
                        areaCode: incomingPhone.areaCode,
                        phoneNumber: `${incomingPhone.phoneNumber.substr(0, 3)}-${incomingPhone.phoneNumber.substr(3)}`,
                        phoneNumberExt: incomingPhone.phoneNumberExt || '',
                        fullPhoneNumber: `(${incomingPhone.areaCode}) ${incomingPhone.phoneNumber.substr(0, 3)}-${incomingPhone.phoneNumber.substr(3)}`
                    };
                }
            });
        }
    }

    /**
     * @description This function processes and displays address data from a list.
     * It sets up address data for display by mapping incoming data to predefined address types
     * and ensuring it fits the UI layout.
     * The function ensures that address data is organized according to specific types (e.g., Mailing, Residential),
     * which helps in managing multiple address formats and enhances data integrity and user experience.
     * @param {Array} listOfAddresses - Array containing address data to be processed.
     */
    processAddresses(listOfAddresses) {
        if (listOfAddresses && Array.isArray(listOfAddresses)) {
            const RESIDENCE = 'RESIDENCE';
            const RESIDENTIAL = 'Residential';

            //Creating a new array of data for Pharmacy Users

            if (hasPharmI_Permission || hasPharmII_Permission || hasPharmIII_Permission) {
                let pharmacyAddressObject = JSON.parse(JSON.stringify(listOfAddresses));

                for (let address of pharmacyAddressObject) {
                    if (address.addressPurposeOfUse === RESIDENCE) {
                        let pharmacyAddressArray = listOfAddresses.filter(
                            (indivitualAddress) => indivitualAddress.addressPurposeOfUse !== RESIDENCE
                        );
                        listOfAddresses = JSON.parse(JSON.stringify(pharmacyAddressArray));
                    } else {
                        //Else Statement for just the Mailing Address for Pharmacy users
                        listOfAddresses = JSON.parse(JSON.stringify(listOfAddresses));
                    }
                }
                //Else statement fo non-pharmacy users
            } else {
                listOfAddresses = JSON.parse(JSON.stringify(listOfAddresses));
            }

            for (let address of listOfAddresses) {
                address.adressline1List = address.addressLine1.split('\n');
                let mapping = {
                    purposeOfUseMapping: null,
                    className: null
                };

                ({
                    adressline1List: mapping.adressline1List = null,
                    addressLine1: mapping.addressLine1 = null,
                    addressLine2: mapping.addressLine2 = null,
                    addressLine3: mapping.addressLine3 = null,
                    badAddress: mapping.badAddress = null,
                    cityName: mapping.cityName = null,
                    addressId: mapping.addressId = null,
                    county: mapping.county = null
                } = address);

                switch (address.addressPurposeOfUse) {
                    case 'CORRESPONDENCE':
                        mapping.purposeOfUseMapping = 'Mailing';
                        mapping.className = 'mailing slds-card slds-p-around_x-small';
                        break;
                    case RESIDENCE:
                        mapping.purposeOfUseMapping = RESIDENTIAL;
                        break;
                    default:
                        break;
                }

                switch (address.addressType) {
                    case 'Overseas Military':
                        ({
                            zipCode5: mapping.zipCode5 = null,
                            stateCode: mapping.stateCode = null,
                            zipCode4: mapping.zipCode4 = null,
                            countryCodeIso3: mapping.countryCodeIso3 = null
                        } = address);
                        break;
                    case 'International':
                        ({
                            intPostalCode: mapping.intPostalCode = null,
                            countryName: mapping.countryName = null,
                            provinceName: mapping.provinceName = null,
                            countryCodeIso3: mapping.countryCodeIso3 = null
                        } = address);
                        break;
                    case 'Domestic':
                        ({
                            zipCode5: mapping.zipCode5 = null,
                            stateCode: mapping.stateCode = null,
                            zipCode4: mapping.zipCode4 = null,
                            countryCodeIso3: mapping.countryCodeIso3 = null
                        } = address);
                        break;
                    default:
                        break;
                }
                // Find the index of the existing placeholder for the address type
                let index = this.addressesToDisplay.findIndex(
                    (placeholder) => placeholder.purposeOfUseMapping === mapping.purposeOfUseMapping
                );

                // Update the placeholder
                if (index !== -1) {
                    this.addressesToDisplay[index] = { ...this.addressesToDisplay[index], ...mapping };
                }
            }

            const [...addyTypes] = this.addressesToDisplay.map((addy) => addy.purposeOfUseMapping);

            if (addyTypes.length) {
                for (let i = 0; i < this.addressTypes.length; i++) {
                    if (!addyTypes.includes(helper.properCase(this.addressTypes[i]))) {
                        this.addressesToDisplay.push({
                            addressLine1: null,
                            addressLine2: null,
                            addressLine3: null,
                            cityName: null,
                            countryCodeIso3: null,
                            purposeOfUseMapping: this.addressTypes[i],
                            className: 'mailing slds-card slds-p-around_x-small',
                            stateCode: null,
                            county: null
                        });
                    }
                }
            }
        }
    }

    processEmails(listOfEmails) {
        if (listOfEmails || listOfEmails?.length) {
            for (let i = 0; i < listOfEmails.length; i++) {
                this.emailsToDisplay.push(listOfEmails[i]);
            }
        } else {
            this.emailsToDisplay.push({
                emailAddressText: null
            });
        }
    }

    handleClick(event) {
        const eventVal = event.target.value || null;
        const dataId = event?.currentTarget?.dataset?.id;

        if (dataId) {
            switch (dataId) {
                case 'address': {
                    this.editAddress = true;
                    this.inputType = 'address';
                    const type = event.currentTarget.dataset.purpose;
                    this.addressEdit = event.target.value;

                    switch (type.toLowerCase()) {
                        case 'residential':
                            this.type = 'RESIDENCE/CHOICE';
                            break;
                        case 'mailing':
                            this.type = 'CORRESPONDENCE';
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case 'phone': {
                    this.editAddress = true;
                    this.type = eventVal?.phoneType || null;
                    this.inputType = 'phone';
                    this.phoneEdit = event.target.value || '';
                    break;
                }
                case 'email': {
                    this.editAddress = true;
                    this.type = null;
                    this.inputType = 'email';

                    const emailObject = event.target.value;
                    this.emailEdit = emailObject?.emailAddressText;
                    break;
                }
                case 'validate': {
                    this.addressEdit = eventVal;

                    /**
                     * address validation callout mapping
                     */

                    this.avsObject = {
                        city: this.addressEdit.cityName,
                        postalCode: this.addressEdit.zipCode5,
                        street: this.addressEdit.addressLine1,
                        province: this.addressEdit.stateCode,
                        country: this.addressEdit.countryCodeIso3,
                        badAddress: this.addressEdit.badAddress,
                        pou:
                            this.addressEdit.purposeOfUseMapping === 'Residential'
                                ? 'RESIDENCE/CHOICE'
                                : 'CORRESPONDENCE'
                    };

                    this.validate();
                    break;
                }
                case 'create': {
                    /**
                     * TODO: call new create component here
                     */
                    this.editAddress = true;
                    this.type = null;
                    this.inputType = 'create';
                    this.emailEdit = null;
                    break;
                }
                default: {
                    break;
                }
            }
        }
    }

    handleClose() {
        this.editAddress = false;
        this.createDemographics = false;
    }

    handleClosePhone() {}

    /**
     * @description This function dispatches a custom event to open a modal
     */
    handleVistaAddressManagement() {
        this.dispatchEvent(
            new CustomEvent('openvistaaddressmanagement', {
                bubbles: true,
                composed: true
            })
        );
    }
}
