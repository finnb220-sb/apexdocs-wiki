/**
 * @description Manages the address verification modal for patient mailing and temp addresses
 * at patient registered facilities
 */
import { api, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import { refreshApex } from '@salesforce/apex';

import getICN from '@salesforce/apex/VCC_lwc_utils.getICN';
import getPatientasSFRecord from '@salesforce/apex/VCC_MedsListController.getPatientasSFRecord';
import getMailingAddresses from '@salesforce/apex/VCC_VistaAddressManagementController.getMailingAddressesVTC';
import getTempAddresses from '@salesforce/apex/VCC_VistaAddressManagementController.getTemporaryAddressesVTC';
import getWorkstreamSettings from '@salesforce/apex/VCC_WorkstreamSettingsController.getWorkstreamSettings';
import getMedsWithParams from '@salesforce/apex/VCC_MedsListController.getMedsWithParams';
import getUserVistaList from '@salesforce/apex/VCC_OnPatientLoadController.userVistAs';
import getFacilityNames from '@salesforce/apex/VCC_OnPatientLoadController.getFacilityNames';
import getRecentView from '@salesforce/apex/VCC_VistaAddressManagementController.getRecentView';

import EditModal from 'c/vccVistaEditMailingAddress';

import VERIFY_ADDRESS_FIELD from '@salesforce/schema/VCC_Recent_View__c.VCC_Pharmacy_Verify_Addresses__c';
import ID_FIELD from '@salesforce/schema/VCC_Recent_View__c.Id';
import { updateRecord } from 'lightning/uiRecordApi';
import LoggerMixin from 'c/loggerMixin';

const attributeOrder = [
    'street1',
    'street2',
    'street3',
    'city',
    { concat: ', ', attrs: ['state', 'zipExt'] },
    { concat: ' ', attrs: ['province', 'postCode'] },
    'country',
    { concat: '', attrs: ['startDate'], prepend: 'Start Date: ' },
    { concat: '', attrs: ['endDate'], prepend: 'End Date: ' }
];

export default class VccVistaAddressManagement extends LoggerMixin(LightningModal) {
    profileAddress;
    @api promiseResolve;
    _icn;
    data = [];
    @api recordId;
    @api mpiData;

    selectedStartDate;
    defaultStartDate;

    medicalCenterFacilitiesWithoutNamesJson;
    _filteredFacilityList = [];
    facilityIdList = [];
    facilitiesWithNames;

    mailingAddressArgs;
    tempAddressArgs;

    userFacilityList;
    @api isAccountPage = false;

    columns = [
        {
            label: 'Facilities',
            fieldName: 'facilityName',
            type: 'text',
            hideDefaultActions: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Mailing Address',
            fieldName: 'mailingAddress',
            type: 'text',
            hideDefaultActions: true,
            wrapText: true,
            cellAttributes: {
                iconName: { fieldName: 'mailingAddressIcon' },
                class: { fieldName: 'mailingAddressClass' }
            }
        },
        {
            label: 'Temporary Address',
            fieldName: 'temporaryAddress',
            type: 'text',
            hideDefaultActions: true,
            wrapText: true,
            cellAttributes: {
                iconName: { fieldName: 'temporaryAddressIcon' },
                class: { fieldName: 'temporaryAddressClass' }
            }
        },
        {
            label: 'Bad Address/Mail Status',
            fieldName: 'badAddress',
            type: 'text',
            hideDefaultActions: true,
            wrapText: true,
            cellAttributes: {
                iconName: { fieldName: 'medsIcon' },
                class: { fieldName: 'medsClass' }
            }
        },
        {
            label: 'Narrative',
            fieldName: 'narrative',
            type: 'text',
            hideDefaultActions: true,
            wrapText: true,
            cellAttributes: {
                iconName: { fieldName: 'medsIcon' },
                class: { fieldName: 'medsClass' }
            }
        }
    ];

    facilitiesPopulated = false;
    mailingAddressPopulated = false;
    tempAddressPopulated = false;
    medsPopulated = false;

    dataLoadSpinner = true;
    _refreshing = false;
    get refreshing() {
        return this.dataLoadSpinner || this._refreshing;
    }
    get hasError() {
        return Object.values(this.errorMap)?.flat()?.length > 0;
    }

    accordionErrorLabel = 'ERROR: One or more errors were encountered. Verify and update directly in EHR.';
    errorMap = {
        mailList: [],
        tempList: [],
        medsList: []
    };
    errorCallMail;
    errorCallTemp;

    selectedRowKeys;
    selectedRows;
    facilityPendingMeds = {};

    /**
     * @description This returns the modal title
     */
    get modalTitle() {
        return this.isAccountPage ? this.MODAL_TITLE_REGISTERED : this.MODAL_TITLE_VERIFY;
    }

    MODAL_TITLE_VERIFY = 'Verify Patient Addresses';
    MODAL_TITLE_REGISTERED = 'Registered Patient Addresses';
    EMPTY_STRING = '';
    NEW_LINE = '\n';
    NOT_FOUND = 'NOT FOUND';
    UTILITY_WARNING_ICON = 'utility:warning';
    ERROR_STRING = 'ERROR';
    ERROR_CSS = 'slds-text-color_error slds-icon-text-error';
    REGULAR_MAIL_TEXT = 'Regular Mail';
    CERTIFIED_MAIL_TEXT = 'Certified Mail';
    DO_NOT_MAIL_TEXT = 'Do Not Mail';
    FOR_LOCAL_REGULAR_MAIL_TEXT = 'For Local - Regular Mail';
    FOR_LOCAL_CERTIFIED_MAIL_TEXT = 'For Local - Certified Mail';
    MAILING_ADDRESS_ERROR = 'Mailing Address Error:';
    TEMPORARY_ADDRESS_ERROR = 'Temporary Address Error:';
    BAD_ADDRESS_ERROR = 'Bad Address / Mail Status / Narrative Error:';

    /**
     * @description Formatted list of error objects to display in an accordion
     */
    get getErrorList() {
        return Object.keys(this.errorMap)
            .filter((key) => this.errorMap[key].length)
            .map((key, index) => {
                let item = {};
                item.key = index;
                switch (key) {
                    case 'mailList':
                        item.header = this.MAILING_ADDRESS_ERROR;
                        break;
                    case 'tempList':
                        item.header = this.TEMPORARY_ADDRESS_ERROR;
                        break;
                    case 'medsList':
                        item.header = this.BAD_ADDRESS_ERROR;
                        break;
                    default:
                    // No other options
                }
                item.messages = this.errorMap[key].map((text, ind) => ({ key: ind, message: text }));
                return item;
            });
    }

    /**
     * @description Determine when all required asynchronous calls complete
     */
    checkDataLoaded() {
        this.dataLoadSpinner = !(
            this.facilitiesPopulated &&
            this.mailingAddressPopulated &&
            this.tempAddressPopulated &&
            this.medsPopulated
        );
        return this.dataLoadSpinner;
    }

    verifyValue = '';
    verifyOptions = [
        { label: 'Verified addresses are correct', value: 'Verified Address' },
        { label: 'Updated address', value: 'Updated Address' }
    ];

    refreshWire = {};

    /**
     * @description  sets up the component when it is initially loaded
     */
    async connectedCallback() {
        this.medicalCenterFacilitiesWithoutNamesJson = JSON.stringify(this.mpiData?.mvi?.medicalCenterFacilities);
    }

    /**
     * @description  Populates the subset of available facilities once both getUserVistaList and
     * getFacilityNames complete
     */
    filterFacilities() {
        if (this._icn && this.facilitiesWithNames && this.userFacilityList) {
            this._filteredFacilityList = this.facilitiesWithNames
                .filter((item) => this.userFacilityList.includes(item.facilityId))
                .map((item) => ({
                    facilityId: item.facilityId,
                    facilityName: item.facilityName ? item.facilityName : item.facilityId
                }));

            this.facilityIdList = this._filteredFacilityList.map((item) => item.facilityId);

            this._filteredFacilityList.forEach((elem) =>
                this.data.push({ ...elem, mailingAddress: '-', temporaryAddress: '-', badAddress: '-', narrative: '-' })
            );
            this.facilitiesPopulated = true;

            this.setMailingArgs();
            this.setTemporaryArgs();
        }
    }

    /**
     * @description  Adds facility name then cross references facilities from enriched MPI data with
     * user accessible facilities
     */
    @wire(getFacilityNames, { facilityListJson: '$medicalCenterFacilitiesWithoutNamesJson' })
    wiredGetFacilityNames({ data, error }) {
        if (data) {
            this.facilitiesWithNames = JSON.parse(data);
            this.filterFacilities();
        }
        if (error) {
            this.Logger.info('Attempted to filter facilities from enriched MPI data with user accessible ones');
            this.Logger.error('Get Facility names error: ', error);
            this.Logger.saveLog();
        }
    }

    /**
     * @description Gets user accessible facilities.
     */
    @wire(getUserVistaList)
    wiredUserVistaList({ data, error }) {
        if (data) {
            this.userFacilityList = [...new Set(data)];
            this.filterFacilities();
        }

        if (error) {
            this.Logger.error('wiredUserVistaList error: ', error);
            this.Logger.saveLog();
        }
    }

    /**
     * @description  gets workstream settings for user to define which static resource dates should be set
     * sets default dates for 1 and 3 year medslist durations
     */
    @wire(getWorkstreamSettings)
    wiredGetSettings({ data, error }) {
        if (data) {
            this.workStreamSettings = data;
            this.defaultStartDate = new Date(new Date().setMonth(new Date().getMonth() - data.VCC_Meds_Duration__c));
            this.selectedStartDate = this.defaultStartDate.toISOString().split('T', 1)[0];
        }
        if (error) {
            this.Logger.error('getWorkstreamSettings error: ', error);
            this.Logger.saveLog();
        }
    }

    /**
     * @description Gets ICN number for patient from recordId
     * @param string recordId
     */
    @wire(getICN, { recordId: '$recordId' })
    wiredGetIcn({ data, error }) {
        if (data) {
            this._icn = data;
            this.filterFacilities();
            this.getPatientAddress();
        }
        if (error) {
            this.Logger.error('wiredGetIcn error: ', error);
            this.Logger.saveLog();
        }
    }

    /**
     * @description Get patient meds via wire after icn and Workstream Settings are retrieved.
     * @param result Data from meds call, including info about patient medications and addresses.
     */
    @wire(getMedsWithParams, { icn: '$_icn', startDate: '$selectedStartDate' })
    wiredGetMedsWithParams(result) {
        if (result.data) {
            this.refreshWire.getMeds = result;
            this.errorMap.medsList = [];
            const medsData = result.data;
            if (medsData?.isMaxRecordsError) {
                this.setMedsError('Max records reached.');
                this.Logger.error('getMedsWithParams error: Max Records reached');
                this.Logger.saveLog();
            } else {
                let sites = medsData?.v1?.sites;
                this.facilityPendingMeds = {};
                this.data.forEach((row) => {
                    let siteIndex = sites?.findIndex((site) => row.facilityId === site?.siteSupplemental?.facility);
                    if (siteIndex >= 0 && sites[siteIndex]) {
                        let supplement = sites[siteIndex]?.siteSupplemental;

                        let meds = sites[siteIndex]?.results?.meds?.med;
                        let noPendingMeds = true;
                        if (meds && meds.length) {
                            for (let i = 0; i < meds.length; i++) {
                                let medStatus = meds[i]?.vaStatus?.value?.toLowerCase();
                                noPendingMeds = noPendingMeds && medStatus !== 'pending' && medStatus !== 'suspended';
                                if (!noPendingMeds) {
                                    break;
                                }
                            }
                            this.facilityPendingMeds[row.facilityId] = !noPendingMeds;
                        }

                        row.narrative = supplement?.narrative ?? '-';
                        row.badAddress = this.formatBadAddress(supplement)?.join(this.NEW_LINE);
                        row.medsClass = '';
                        row.medsIcon = '';
                    } else {
                        row.narrative = this.NOT_FOUND;
                        row.badAddress = this.NOT_FOUND;
                        row.medsIcon = this.UTILITY_WARNING_ICON;
                    }
                });
            }
        } else if (result.error) {
            this.setMedsError(JSON.stringify(result.error));
            this.Logger.error('getMedsWithParams error: ', result.error);
            this.Logger.saveLog();
        }
        if (result.data || result.error) {
            this.medsPopulated = true;
            this.checkDataLoaded();
        }
    }

    /**
     * @description Populate the table rows and error display when an error occurs for the meds call.
     * @param error
     */
    setMedsError(error) {
        this.errorMap.medsList = [error];
        this.data.forEach((row) => {
            row.hasError = true;
            row.badAddress = this.ERROR_STRING;
            row.narrative = this.ERROR_STRING;
            row.medsClass = this.ERROR_CSS;
            row.medsIcon = this.UTILITY_WARNING_ICON;
        });
    }

    /**
     * @description Convert the site supplemental Bad Address and Mail Status fields to a formatted string.
     * @param supplemental Site supplemental object from the meds call
     * @returns an array of formatted strings holding Bad Address and Mail Status (with Expiration)
     */
    formatBadAddress(supplemental) {
        let formatted = [];
        if (supplemental) {
            if (supplemental?.badAddressIndicator) {
                formatted.push('Bad Address: ' + supplemental.badAddressIndicator);
            }
            if (supplemental?.mailStatus) {
                let formattedMail = 'Mail Status: ';
                switch (supplemental.mailStatus) {
                    case '0':
                        formattedMail += this.REGULAR_MAIL_TEXT;
                        break;
                    case '1':
                        formattedMail += this.CERTIFIED_MAIL_TEXT;
                        break;
                    case '2':
                        formattedMail += this.DO_NOT_MAIL_TEXT;
                        break;
                    case '3':
                        formattedMail += this.FOR_LOCAL_REGULAR_MAIL_TEXT;
                        break;
                    case '4':
                        formattedMail += this.FOR_LOCAL_CERTIFIED_MAIL_TEXT;
                        break;
                    default:
                        break;
                }
                if (supplemental?.mailStatusExpDate) {
                    formattedMail += ' (EXP: ' + supplemental.mailStatusExpDate + ')';
                }
                formatted.push(formattedMail);
            }
        }
        if (!formatted.length) {
            formatted.push('-');
        }
        return formatted;
    }

    /**
     * @description Gets the PersonMailingAddress saved in Salesforce
     */
    async getPatientAddress() {
        let patient = await getPatientasSFRecord({ icn: this._icn });
        if (!patient?.PersonMailingAddress) {
            this.profileAddress = {
                PersonMailingAddress: {
                    street: 'No Address On File',
                    city: '',
                    state: '',
                    postalCode: ''
                }
            };
        } else {
            this.profileAddress = patient;
        }
    }

    /**
     * @description This function will set up our arguments for getting the mailing addresses from VTC.
     */
    setMailingArgs() {
        this.mailingAddressArgs = {
            icn: this._icn,
            facilityIds: this.facilityIdList.sort()
        };
    }

    /**
     * @description This function will set up our arguments for getting the temporary addresses from VTC.
     */
    setTemporaryArgs() {
        this.tempAddressArgs = {
            icn: this._icn,
            facilityIds: this.facilityIdList.sort()
        };
    }

    /**
     * @description Get Mailing Addresses for the patient via wire after icn and facilityList are retrieved
     * @param result
     */
    @wire(getMailingAddresses, { args: '$mailingAddressArgs' })
    wiredGetMailingAddresses(result) {
        if (result.data) {
            this.refreshWire.getMailing = result;
            this.errorCallMail = false;
            this.errorMap.mailList = []; // Clear mailing address errors on refresh
            let sites = result.data?.sites;
            sites.forEach((site) => {
                let rowIndex = this.data.findIndex((elem) => elem.facilityId === site.id);
                if (rowIndex >= 0) {
                    if (site?.errors?.length) {
                        this.populateRowError(rowIndex, 'mailList', site.errors, site.id);
                    } else {
                        let address = site?.records[0];
                        let row = this.data[rowIndex];
                        row.addressMail = { ...address };
                        row.errorMail = false;
                        row.mailingAddress = this.formatAddress(address);
                        row.mailingAddressClass = '';
                        row.mailingAddressIcon = '';
                        row.singleLineMail = this.singleLine(site.id, address);
                    }
                }
            });
        } else if (result.error) {
            this.populateErrorMap(result.error, 'mailList');
            this.Logger.error('getMailingAddresses error: ', JSON.stringify(result.error));
            this.Logger.saveLog();
        }
        if (result.data || result.error) {
            this.mailingAddressPopulated = true;
            this.checkDataLoaded();
        }
    }

    /**
     * @description Get Temporary Addresses for the patient via wire after icn and facilityList are retrieved
     * @param result
     */
    @wire(getTempAddresses, { args: '$tempAddressArgs' })
    wiredGetTempAddresses(result) {
        if (result.data) {
            this.refreshWire.getTemporary = result;
            this.errorCallTemp = false;
            this.errorMap.tempList = []; // Clear temporary address errors on refresh
            let sites = result.data?.sites;
            sites.forEach((site) => {
                let rowIndex = this.data.findIndex((elem) => elem.facilityId === site.id);
                if (rowIndex >= 0) {
                    if (site?.errors?.length) {
                        this.populateRowError(rowIndex, 'tempList', site.errors, site.id);
                    } else {
                        let record = site?.records[0];
                        let address = record?.address;
                        if (record && address) {
                            address = JSON.parse(JSON.stringify(address));
                            address.tempAddActive = record?.tempAddActive;
                            address.startDate = record?.startDate;
                            address.endDate = record?.endDate;
                        }
                        let row = this.data[rowIndex];
                        row.addressTemp = { ...address };
                        row.errorTemp = false;
                        row.temporaryAddress = this.formatAddress(address);
                        row.temporaryAddressClass = '';
                        row.temporaryAddressIcon = '';
                        row.singleLineTemp = this.singleLine(site.id, address);
                    }
                }
            });
        } else if (result.error) {
            this.populateErrorMap(result.error, 'tempList');
            this.Logger.error('getTemporaryAddress error: ', JSON.stringify(result.error));
            this.Logger.saveLog();
        }
        if (result.data || result.error) {
            this.tempAddressPopulated = true;
            this.checkDataLoaded();
        }
    }

    /**
     * @description This populates errors for the table row and for display
     * @param rowIndex The table's data row
     * @param typeOfList An expected string of 'mailList' or 'tempList'
     * @param messages An array of error objects from VTC errors
     * @param facilityId The site id of the row
     */
    populateRowError(rowIndex, typeOfList, messages, facilityId) {
        let dataAttribute;
        let errorAttribute;
        if (typeOfList === 'mailList') {
            dataAttribute = 'mailingAddress';
            errorAttribute = 'errorMail';
        } else {
            dataAttribute = 'temporaryAddress';
            errorAttribute = 'errorTemp';
        }
        messages.forEach((err) => this.errorMap[typeOfList].push(facilityId + ' - ' + err.message));
        let row = this.data[rowIndex];
        row.hasError = true;
        row[errorAttribute] = true;
        row[dataAttribute] = 'ERROR';
        row[dataAttribute + 'Class'] = this.ERROR_CSS;
        row[dataAttribute + 'Icon'] = this.UTILITY_WARNING_ICON;
    }

    /**
     * @description This populates errors for display
     * @param error An error object
     * @param typeOfList An expected string of 'mailList' or 'tempList'
     */
    populateErrorMap(error, typeOfList) {
        let dataAttribute;
        let errorAttribute;
        if (typeOfList === 'mailList') {
            dataAttribute = 'mailingAddress';
            errorAttribute = 'errorMail';
            this.errorCallMail = true;
        } else {
            dataAttribute = 'temporaryAddress';
            errorAttribute = 'errorTemp';
            this.errorCallTemp = true;
        }
        let errObj;
        if (error?.body?.message) {
            try {
                errObj = JSON.parse(error.body.message);
            } catch (invalidJson) {
                // not an error from VTC
            }
        }
        // Check if entire call did not succeed
        if (errObj?.success === false && errObj?.message) {
            this.errorMap[typeOfList] = [error?.body?.message];
            // Unhandled error
        } else {
            this.errorMap[typeOfList] = ['Unhandled error: ' + JSON.stringify(error)];
        }
        this.data.forEach((row) => {
            row.hasError = true;
            row[errorAttribute] = true;
            row[dataAttribute] = 'ERROR';
            row[dataAttribute + 'Class'] = this.ERROR_CSS;
            row[dataAttribute + 'Icon'] = this.UTILITY_WARNING_ICON;
        });
    }

    /**
     * @description This formats a VTC DIVA address (Mailing & Temporary) into a single line string
     * @param siteId A VistA instance Id
     * @param address An address object
     * @returns a formatted Address string
     */
    singleLine(siteId, address) {
        let formattedLine = '';
        if (siteId && address) {
            formattedLine = siteId + ' - ';
            // Skip startDate and endDate
            for (let i = 0; i < attributeOrder.length - 2; i++) {
                let attr = attributeOrder[i];
                if (typeof attr === 'string') {
                    let addrElement = address[attr];
                    formattedLine += addrElement ? addrElement + ', ' : '';
                } else {
                    // eslint-disable-next-line no-loop-func
                    attr?.attrs?.forEach((elem) => {
                        let addrElement = address[elem];
                        formattedLine += addrElement ? addrElement + ', ' : '';
                    });
                }
            }
            if (formattedLine?.slice(-2) === ', ') {
                formattedLine = formattedLine.slice(0, -2);
            }
        }
        return formattedLine;
    }

    /**
     * @description This formats a VTC DIVA address (Mailing & Temporary) into a string
     * @param address An address object
     * @returns a formatted Address string, or '-' if N/A
     */
    formatAddress(address) {
        let formattedAddress = '';

        if (address) {
            // Check if this is a future active temp address
            if (Object.hasOwn(address, 'tempAddActive')) {
                if (address?.tempAddActive?.toLowerCase() === 'active') {
                    if (Object.hasOwn(address, 'startDate') && address?.startDate) {
                        try {
                            let dStart = new Date(Date.parse(address?.startDate));
                            let dEnd = address?.endDate ? new Date(Date.parse(address?.endDate)) : null;
                            if (dEnd) {
                                // Allow same day completion before expiring temp address
                                dEnd.setDate(dEnd.getDate() + 1);
                            }
                            let dNow = new Date();
                            let dOff = dNow.getTimezoneOffset() * 60000;

                            if (dStart && dStart - dNow + dOff > 0) {
                                formattedAddress += '- Future -\n';
                            } else if (dEnd && dEnd - dNow + dOff < 0) {
                                // End date is in the past, so Temp Address is inactive
                                formattedAddress = '-';
                                return formattedAddress;
                            }
                        } catch (error) {
                            formattedAddress = '- Error: Start / End Date -';
                        }
                    } else {
                        // No start date, so Temp Address is inactive
                        formattedAddress = '-';
                        return formattedAddress;
                    }
                } else {
                    // Temp Address is inactive
                    formattedAddress = '-';
                    return formattedAddress;
                }
            }
            attributeOrder.forEach((attrObj, index) => {
                if (typeof attrObj === 'string') {
                    if (Object.hasOwn(address, attrObj) && address[attrObj]) {
                        formattedAddress += formattedAddress && index ? '\n' : '';
                        formattedAddress += address[attrObj];
                    }
                } else {
                    // Check if any concatenatable items are in the address
                    let foundAny = attrObj.attrs.reduce((val, elem) => {
                        if (Object.keys(address).includes(elem) && address[elem]) {
                            val += 1;
                        }
                        return val;
                    }, 0);
                    if (foundAny) {
                        formattedAddress += formattedAddress && index ? '\n' : '';
                        formattedAddress +=
                            (Object.hasOwn(attrObj, 'prepend') ? attrObj.prepend : '') +
                            attrObj.attrs.map((key) => address[key]).join(attrObj.concat);
                    }
                }
            });
        } else {
            formattedAddress = '-';
        }
        return formattedAddress;
    }

    /**
     * @description Inspect each row and reeavluate if there is a row level error, updating row.hasError
     */
    reevaluateRowErrors() {
        this.data.forEach((row) => {
            if (this.errorCallMail) {
                row.errorMail = true;
            }
            if (this.errorCallTemp) {
                row.errorTemp = true;
            }
            row.hasError = row.errorMail || row.errorTemp;
        });
    }

    /**
     * @description This will refresh the wired calls
     */
    refreshCalls() {
        this._refreshing = true;
        this.dataLoadSpinner = true;
        this.mailingAddressPopulated = false;
        this.tempAddressPopulated = false;
        this.medsPopulated = false;

        Promise.all(
            Object.values(this.refreshWire).map((call) => {
                return refreshApex(call);
            })
        ).finally(() => {
            this._refreshing = false;
            this.mailingAddressPopulated = true;
            this.tempAddressPopulated = true;
            this.medsPopulated = true;
            this.checkDataLoaded();
            this.reevaluateRowErrors();
        });
    }

    /**
     * @description This function will handle opening the edit modal with necessary data.
     */

    editMailing() {
        if (this.selectedRows.length) {
            let pendingMeds = this.selectedRows
                .filter((row) => {
                    let matched = Object.hasOwn(this.facilityPendingMeds, row.facilityId);
                    return matched && this.facilityPendingMeds[row.facilityId];
                })
                .map((selected) => selected.facilityName);

            EditModal.open({
                size: 'medium',
                addresses: this.selectedRows,
                hasPendingMeds: pendingMeds,
                icn: this._icn
            }).then((result) => {
                if (result === 'Confirmed') {
                    this._refreshing = true;
                    this.dataLoadSpinner = true;
                    this.mailingAddressPopulated = false;
                    refreshApex(this.refreshWire.getMailing).finally(() => {
                        this._refreshing = false;
                        this.mailingAddressPopulated = true;
                        this.checkDataLoaded();
                        this.reevaluateRowErrors();
                    });
                }
            });
        }
    }

    /**
     * @description This will handle the cancel button.
     */
    handleCancel() {
        this.close();
    }

    isButtonDisabled = true;

    /**
     * @description This method will handle selection of different rows for editing.
     * @param event An event to handle the selection of different rows in the grid.
     */
    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows.filter((row) => !row.hasError);
        this.selectedRowKeys = this.selectedRows.map((row) => row.facilityId);
    }

    /**
     * @description This method will handle radio group selection.
     * @param event An event to capture the Pharmacist action Verify/Update.
     */
    handleSelection(event) {
        this.verifyValue = event.target.value;
        this.isButtonDisabled = false;
    }

    /**
     * @description This will handle the data being confirmed by the user.
     */
    async handleConfirm() {
        this.close('confirm');

        let recentView = await getRecentView();
        let recentViewRecordID = recentView[0].Id;
        const fields = {};
        fields[ID_FIELD.fieldApiName] = recentViewRecordID;
        fields[VERIFY_ADDRESS_FIELD.fieldApiName] = this.verifyValue;
        let recordInput = { fields };
        updateRecord(recordInput).catch((error) => {
            this.Logger.error('Error updating view record: ', error);
            this.Logger.saveLog();
        });
    }
}
