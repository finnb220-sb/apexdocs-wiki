import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { RefreshEvent } from 'lightning/refresh';
import { refreshApex } from '@salesforce/apex';

import handleRefillRequest from '@salesforce/apex/VCC_MedsListController.handleRefillRequest';
import getRequesterName from '@salesforce/apex/VCC_MedsListController.getRequesterName';
import fetchDemographicsByVista from '@salesforce/apex/VCC_MedsListController.fetchDemographicsByVista';
import getFacilityIens from '@salesforce/apex/VCC_MedsListController.getFacilityIens';
import getPatientasSFRecord from '@salesforce/apex/VCC_MedsListController.getPatientasSFRecord';
import getCaseInfo from '@salesforce/apex/VCC_MedsListController.getCaseInfo';
import getMedsWithParams from '@salesforce/apex/VCC_MedsListController.getMedsWithParams';
import getTemporaryAddress from '@salesforce/apex/VCC_MedsListController.getTemporaryAddress';
import getProgressNoteInfo from '@salesforce/apex/VCC_MedsListController.getProgressNoteInfo';
// import createAdministrativeCase from "@salesforce/apex/VCC_MedsListController.createAdministrativeCase";
import getICN from '@salesforce/apex/VCC_lwc_utils.getICN';
import noResultsMessage from '@salesforce/label/c.VCC_Generic_message_for_null_search_results';
import noResultsSubMessage from '@salesforce/label/c.VCC_Generic_sub_message_for_null_search_results';
import genericError from '@salesforce/label/c.VCC_Generic_Error';
import genericSubError from '@salesforce/label/c.VCC_Generic_Sub_error';
import dataHasErrorsMessage from '@salesforce/label/c.VCC_Medications_Data_Error_Message';
import dataHasErrorsSubMessage from '@salesforce/label/c.VCC_Medications_Data_Error_Sub_Message';
import refillVerificationAddress from '@salesforce/label/c.VCC_Meds_Address_Warning';
import refillVerificationAddressNonPharm from '@salesforce/label/c.VCC_Meds_Address_Warning_Non_Pharmacy';

import * as vccMedicationListHelper from './vccMedicationListHelper';
import {
    activityLogColumns,
    importedFrozenColumns,
    importedDynamicColumns,
    duplicateMedsTable,
    nonVAcolumns,
    activityPermissions,
    defaultParams,
    emptyStateLabels
} from './constants';
import { NonVAMedsAddToNoteDefaults, AddToNoteDefaults, allFutureRenewalOptions } from './componentDefaults';
import currentUserId from '@salesforce/user/Id';
import getWorkstreamSettings from '@salesforce/apex/VCC_WorkstreamSettingsController.getWorkstreamSettings';
import hdrDateRangeMessageLabel from '@salesforce/label/c.VCC_HDR_Date_Range_Message';
import hasMSAPermission from '@salesforce/customPermission/VCC_MSA';
import hasRenewalPermission from '@salesforce/customPermission/VAHC_Access_Future_Renewal_Request';
import hasPharmI_Permission from '@salesforce/customPermission/VCC_Pharmacy_Tier_I';
import hasPharmII_Permission from '@salesforce/customPermission/VCC_Pharmacy_Tier_II';
import hasPharmIII_Permission from '@salesforce/customPermission/VCC_Pharmacy_Tier_III';
import VCC_Medical_ProviderPermission from '@salesforce/customPermission/VCC_Medical_Provider';
import VCC_Registered_NursePermission from '@salesforce/customPermission/VCC_Registered_Nurse';
import isTedMP from '@salesforce/userPermission/c_TED_Medical_Provider';
import isTedRN from '@salesforce/userPermission/c_TED_Registered_Nurse';
// static response to use while HDR is down, for testing only
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import maxRecordMessage from '@salesforce/label/c.VCC_max_Record_Limit';
import maxRecordMessage2 from '@salesforce/label/c.VCC_max_Record_Limit_pt2';
import userVistAs from '@salesforce/apex/VCC_OnPatientLoadController.userVistAs';
/* eslint-disable no-unused-vars */

export default class VccMedicationList extends NavigationMixin(LightningElement) {
    @api isDebugMode; /** @deprecated */

    componentTitle = 'Meds & Rx Refill'; // TODO: Move to custom label
    @api recordId;
    medsRequest;
    selectedThreeYears;
    selectedStartDate;
    hdrFormattedStartDate;
    defaultStartDate;
    threeYearStartDate;
    medsResponse = {};
    @api flowRecordObjectApiName;
    @api meds; // needs to be kept here and decorated with @api due to package ancestry

    _meds; // "read-only" property, an object of categorized meds arrays
    workStreamSettings;
    hdrMessage;
    hasMedsList = false;
    error;
    expanded = false; // expand button condition
    expandCollapseLabel = 'Expand';
    expandCollapseIconName = 'utility:expand_alt';
    expandedCSSClasses = '';
    expandedModalContainerCSS = '';
    displaySpinner = true; // loading spinner
    frozenColumns = importedFrozenColumns;
    dynamicColumns = importedDynamicColumns;
    progressValue;
    uniqueMedsListForDisplay = [];
    groupedDuplicateMeds = [];
    duplicateMedsTable = duplicateMedsTable; // columns for duplicate meds table
    nonVAcolumns = nonVAcolumns; // non-va meds datatable columns
    todaysDate; // todays day constant
    _drugName = null;
    hasError = false;
    showAddToNote = false;
    hideRefillFunctionality = true;
    firstRun = true;
    defaults = defaultParams;
    @track med;
    _med;
    medFormatted = {};
    dose;
    vtcTempAddressArgs;
    hasFills;
    fillArray = [];
    activityLogColumns = activityLogColumns;
    _objectApiName;
    pagmd; // pagination metadata
    permissionsThatCanRefillOnAccount = [
        hasPharmI_Permission,
        hasPharmII_Permission,
        hasPharmIII_Permission,
        hasMSAPermission
    ];
    permissionsThatCanSeeExtraColumns = [hasPharmI_Permission, hasPharmII_Permission, hasPharmIII_Permission];
    userPermissions = {
        adminSchedulingMSA: hasMSAPermission,
        clinicalTriageRN: VCC_Registered_NursePermission,
        pharmacyPHR: [hasPharmI_Permission, hasPharmII_Permission, hasPharmIII_Permission],
        teleUrgentTED: isTedMP || isTedRN,
        virtualCareVisitMP: VCC_Medical_ProviderPermission
    };
    isPharmacyUser;
    workstream = new Set();
    medsStartDate;
    medWarningData;
    dataErrorsList = []; // list of warning objects to show ex: {message: "Error loading"}

    _icn;
    // getting the activity permissions for this user from the constants helper
    activityPermissions = activityPermissions;
    emptyStateLabels = emptyStateLabels; // empty state labels
    refillVerificationAddress = refillVerificationAddress;

    //max record details
    maxRecordReached = false;
    maxErrorCheck = false;
    maxRecordMessage = maxRecordMessage;
    maxRecordMessage2;
    customMessage;

    //String Constants
    EMPTY_STRING = '';
    EXPAND = 'Expand';
    COLLAPSE = 'Collapse';
    ESCAPE = 'Escape';
    ESC = 'Esc';
    UTIL_COLLAPSE_ALL = 'utility:collapse_all';
    UTIL_EXPAND_ALT = 'utility:expand_alt';
    EXPND_CSS_CLSS = 'slds-modal slds-fade-in-open slds-modal_large slds-backdrop slds-backdrop_open';
    EXPND_MOD_CONT = 'slds-modal__container';
    EXPND_MOD_HEADER = 'slds-modal__header';
    EXPND_MOD_CONTENT = 'slds-modal__content slds-p-around_small';
    TRUE = 'true';

    /** empty state */
    noNonVaResults = false;
    noNonVaResultsAndNoErrors = false;
    noVaResults = false;
    noVaResultsAndNoErrors = false;
    noConnection = false;
    dataHasErrors = false;
    dataHasVistaLimitErrors = false;
    nonVADataHasErrors = false;
    hasServerError = false;
    hasLimitError = false;
    labels = {
        noNonVaMessage: 'No Non-VA Medications were found.',
        noVaMessage: 'No Active Medications were found.',
        noResultsMessage: noResultsMessage,
        noResultsSubMessage: noResultsSubMessage,
        noConnectionMessage: genericError,
        noConnectionSubMessage: genericSubError,
        dataHasErrorsMessage: dataHasErrorsMessage,
        dataHasErrorsSubMessage: dataHasErrorsSubMessage,
        nonVADataHasErrorsMessage: dataHasErrorsMessage,
        nonVADataHasErrorsSubMessage: dataHasErrorsSubMessage,
        successfulRefillMessage: 'All refills submitted successfully.',
        errorRefillMessage: 'One or more prescriptions cannot be refilled.',
        hasLimitErrorMessage: 'The Number of Records Returned Exceeds the Loading Capacity',
        hasLimitErrorSubMessage: 'Please head to EHR to view this patients list of medications.',
        dataHasVistaLimitErrorMessage: 'Medications from these sites failed to load ({0})',
        dataHasVistaLimitErrorSubMessage: 'Please naviage to CPRS to view the full medication history.'
    };

    // what to render on base modal
    baseModalCloseButton = {
        close: 'Cancel'
    };

    // keep values at lowercase
    componentOptions = [
        // {
        //     label: "Load More Records",
        //     value: "getmoredata"
        // },
        // {
        //     label: "Reset View",
        //     value: "defaultcall"
        // }
    ];
    _vaComponentOptions; // store component options when switching tabs between VA / Non-VA

    @track
    personAccount;

    // Flag to check if Add to Note option is added to options
    addedAddToNote = false;
    addedFutureRenewal = false;
    addToNoteTitle = '';
    addToNoteMedsToDisplay = [];
    @track refreshTempAddress = {};
    @track uniqueFacilityIds = [];
    @track currentFacilityIndex = 0;
    @track currentFacilityId;
    @track input;
    makeTempAddressCallout = false;
    state = {};
    isTempAddressesLoaded;
    isMedsLoaded;
    slotActions; //Controls button group placement in lightning-card slot

    currentTable = 'va-meds'; // defaulting to regular meds table
    usersVistAs; //stores list ofVistA/CPRS (3 digit facility codes) the user has access to is passed to vccMedicationTable LWC.

    /**
     * @description if expanded view is used, then utilize frozen columnn component, otherwise usage is determined by the public property 'showFrozenColumns'
     */
    @api showFrozenColumns;
    get _showFrozenColumns() {
        if (this.expanded) {
            return true;
        }
        return this.showFrozenColumns;
    }

    /**
     * @description Gets a list of VistA/CPRS (3 digit facility codes) the User has access to.
     */
    @wire(userVistAs)
    wiredGetUserVistAs({ data, error }) {
        if (data) {
            this.usersVistAs = data;
        }
        if (error) {
            this.nebulaLogger(error);
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
        }
        if (error) {
            this.nebulaLogger(error);
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
            this.setUserWorkStream();
            this.isPharmUser = this.workstream.has('pharmacy');
            this.defaultStartDate = new Date(new Date().setMonth(new Date().getMonth() - data.VCC_Meds_Duration__c));
            this.threeYearStartDate = new Date(new Date().setMonth(new Date().getMonth() - 36));

            if (!this.isPharmUser) {
                this.refillVerificationAddress = refillVerificationAddressNonPharm;
            }
            if (!this.selectedStartDate) {
                this.selectedStartDate = this.defaultStartDate.toISOString().split('T', 1)[0];
                this.hdrFormattedStartDate = this.defaultStartDate.toLocaleDateString('en-US', {
                    year: 'numeric',
                    month: 'numeric',
                    day: 'numeric'
                });
            }
        }
        if (error) {
            this.nebulaLogger(error);
        }
    }
    /**
     * @description method sets our boolean makeTempAddressCallout variable based on if facilities are populated
     * and what the hideRefillFunctionality is then once makeTempAddressCallout is true then we set our reactive vtcTempAddressArgs
     * to initiate our getTempAddress wire method.
     */
    processTempCallout() {
        this.makeTempAddressCallout = Object.values(this.facilities).length && !this.hideRefillFunctionality;
        if (this.makeTempAddressCallout) {
            this.currentFacilityIndex = 0;
            this.currentFacilityId = this.uniqueFacilityIds[this.currentFacilityIndex];
            this.vtcTempAddressArgs = {
                icn: this._icn,
                facilityId: this.currentFacilityId
            };
        }
    }

    /**
     * @description Gets medslist based on ICN Number and selected start date VCC_MedsListController.getMedsWithParams.
     * Selected start date set in wiredgetSettings and for Pharm users handleChangeWorkStream.
     * @param string ICN Number
     * @param string medicationList startDate
     */
    @wire(getMedsWithParams, { icn: '$_icn', startDate: '$selectedStartDate' })
    wiredGetMedsWithParams(value) {
        if (value.data) {
            this.medsResponse[this.selectedStartDate] = value;
            this.hdrMessage = hdrDateRangeMessageLabel
                .replace(
                    '{1}',
                    new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric' })
                )
                .replace('{2}', this.hdrFormattedStartDate);
            const medsData = this.medsResponse[this.selectedStartDate].data;
            if (medsData?.isMaxRecordsError) {
                this.customMessage = maxRecordMessage2.replace('{0}', this.componentTitle);
                this.maxRecordReached = true;
            } else {
                this.medWarningData = medsData.v1;
                const processedData = vccMedicationListHelper.processCallout(medsData);
                this.facilities = vccMedicationListHelper.facilitesInMedslist(processedData?.all);
                if (this.facilities) {
                    let facilityIds = Object.keys(this.facilities).map((facId) => facId.substring(0, 3));
                    this.uniqueFacilityIds = [...new Set(facilityIds)];
                    this.processTempCallout();
                }

                const processedVistaLimitErrors = vccMedicationListHelper.processVistaLimitErrors(medsData.errors);
                // if preparedMeds is good, proceed setting the initial class variables/properties
                if (this.validate(processedData)) {
                    this.setInitialClassProperties(processedData, processedVistaLimitErrors);
                }
            }
            this.isMedsLoaded = true;
            this.updateDisplaySpinner();
        }
        if (value.error) {
            // Handle server errors and classify them based on the type for appropriate response
            this.nebulaLogger(value.error);
            // Specific handling for known server limits
            if (
                value.error?.body?.message.includes('Apex heap size too large') ||
                value.error?.body?.message.includes('Exceeded Max Records')
            ) {
                this.hasServerError = true;
                this.hasLimitError = true;
                this.isMedsLoaded = true;
                this.updateDisplaySpinner();
            }
            // General error handling for other unexpected issues
            else {
                this.hasServerError = true;
                this.noConnection = true;
                this.labels.noConnectionMessage = genericError.replace('{0}', 'Connection Error');
                this.isMedsLoaded = true;
                this.updateDisplaySpinner();
            }
        }
    }

    /**
     * @description Gets temporary Address based on registered facility, ICN Number and a boolean value that determines if it should do the callout VCC_MedsListController.getTempAddresses.
     * current facility is a reactive property and due to endpoint must be done in series.
     * @param string currentFacilityId
     * @param string ICN Number
     * @param boolean to decide if callout needs to happen
     */
    refreshTempAddressObj = {};
    @wire(getTemporaryAddress, { args: '$vtcTempAddressArgs', makeTempAddressCallout: '$makeTempAddressCallout' })
    wiredGetTemporaryAddress(result) {
        if (result.data) {
            this.refreshTempAddressObj[this.currentFacilityId] = result;
            const facilityId = this.currentFacilityId;
            this.refreshTempAddress[facilityId] = JSON.parse(JSON.stringify(result.data));
            this.moveToNextFacility();
        } else if (result.error) {
            console.error('Error getting the temp addresses', result.error);
            this.moveToNextFacility();
        }
    }

    /**
     * @description updates reactive property currentFacilityId to go through all facilities patient is registered to.
    
     */
    moveToNextFacility() {
        if (this.currentFacilityIndex < this.uniqueFacilityIds.length - 1) {
            this.currentFacilityIndex++;
            this.currentFacilityId = this.uniqueFacilityIds[this.currentFacilityIndex];
            this.vtcTempAddressArgs = {
                icn: this._icn,
                facilityId: this.currentFacilityId
            };
        } else {
            this.isTempAddressesLoaded = true;
            this.updateDisplaySpinner();
        }
    }
    /**
     * @description makes sure both wire methods getMedsWithParams and getTemporaryAddress have fully loaded before removing the spinner.
     */
    updateDisplaySpinner() {
        if (!this.makeTempAddressCallout) {
            this.displaySpinner = !this.isMedsLoaded;
        } else {
            this.displaySpinner = !(this.isTempAddressesLoaded && this.isMedsLoaded);
        }
    }

    @api
    set objectApiName(val) {
        switch (val) {
            case 'Account':
                this.labels.successfulRefillMessage += ' Click {1} to see the associated {0} record.';
                this.labels.errorRefillMessage += ' Click {1} to see the associated {0} record.';
                this.checkObjectForRefillAccess();
                break;
            case 'VCC_Progress_Note__c':
                // this.componentOptions.unshift({ label: "Add To Note", value: "addtonote" });
                break;
            default:
                this._objectApiName = val;
        }
        this._objectApiName = val;
    }

    get objectApiName() {
        return this._objectApiName;
    }

    async connectedCallback() {
        this.slotActions = this._showFrozenColumns ? 'actions' : '';
        this.displaySpinner = true;
        if (this.flowRecordObjectApiName) {
            this._objectApiName = this.flowRecordObjectApiName;
        }
        this.checkObjectForRefillAccess(this._objectApiName);
        if (this.firstRun) {
            this.addColumnsForPharmUsers();
        }
        this.firstRun = false;
    }

    /**
     * @description allow external components to change messaging channel
     * @param event the triggering event
     */
    @api
    changeChannel(event) {
        const newChannel = event?.target?.value;
        this.channelName = newChannel;
    }

    _futureRenewalOptions = {
        topButtons: allFutureRenewalOptions.topButtons,
        initialSort: allFutureRenewalOptions.initialSort,
        medsFilterField: allFutureRenewalOptions.medsFilterField
    };

    _columnsForFutureRenewal = allFutureRenewalOptions.columns;

    //? Add to Note
    addToNoteDefaults = AddToNoteDefaults;

    @api addToNoteOptions;
    @api columnsForAddToNote;
    _addToNoteOptions = {
        fromMeds: true,
        topButtons: [], //? being set by either the flexipage input or the default
        initialSort: {
            field: 'drugName',
            stringField: 'drugName',
            direction: 'asc'
        },
        medsFilterField: { label: 'Status', apiName: 'vaStatusValue' },
        medSupplyFilterField: true
    };
    _columnsForAddToNote = []; //? being set by either the flexipage input or the default

    settings = {
        title: 'Meds & Rx Refill',
        icon: 'standard:medication'
    };

    tableSort;

    modalButtons = [
        {
            variant: 'Brand',
            label: 'Submit'
        }
    ];

    nxtBtn = false;
    prevBtn = false;
    ShowBtns = true;
    currentIndex = 0;
    totalRecordsDetails;

    @track facilities = {};

    logErrorAndToast(error) {
        this.nebulaLogger(error);

        this.displayRefillSpinner = false;
        const event = new ShowToastEvent({
            title: 'Error!',
            message: 'An unexpected error has occurred.',
            variant: 'error',
            mode: 'sticky'
        });
        this.dispatchEvent(event);
    }

    nebulaLogger(incomingError, isArray = false) {
        const logger = this.template.querySelector('c-logger');
        if (!logger) return;
        if (isArray) {
            incomingError.forEach((error) => {
                logger.error(JSON.stringify(error));
            });
        } else {
            logger.error(JSON.stringify(incomingError));
        }
        logger.saveLog();
    }

    handleLogWarnings(event) {
        this.nebulaLogger(event.detail.value);
    }

    /**
     * @description splices in additional columns if the running user is a Pharmacy user
     */
    addColumnsForPharmUsers() {
        //? check for Pharmacy User
        if (!this.permissionsThatCanSeeExtraColumns.includes(true)) return;
        let indicatorsObj = {
            label: 'Indicators',
            fieldName: 'indicatorString',
            initialWidth: 120,
            wrapText: false,
            type: 'text',
            sortable: false
        };
        let csScheduleObj = { label: 'CS Schedule', fieldName: 'csSchedule', type: 'text', sortable: true };
        let parkedObj = { label: 'Parked', fieldName: 'parked', wrapText: false, type: 'text', sortable: true };
        this.isPharmacyUser = true;
        //? check for indicators
        if (!this.dynamicColumns.find((obj) => obj.label === 'Indicators')) {
            this.dynamicColumns.splice(1, 0, indicatorsObj);
        }

        if (!this.dynamicColumns.find((obj) => obj.label === 'CS Schedule')) {
            this.dynamicColumns.splice(7, 0, csScheduleObj);
        }

        if (!this.dynamicColumns.find((obj) => obj.label === 'Parked')) {
            this.dynamicColumns.splice(8, 0, parkedObj);
        }
    }

    /**
     * @description Combines the frozen and dynamic columns.  This is used when only a single datatable displays the data.
     *              We recently added an option to display the data with 2 separate datatables. The reason for that, it allows us
     *              to "freeze" the first column of the table (in reality, the first column is its own table).
     */
    get columns() {
        return [...this.frozenColumns, ...this.dynamicColumns];
    }

    /**
     * @description Conditionally shows the 'Future Renewal Request' or the 'Add to Note' buttons depending on object type and user permissions.
     * @author Jakob Orkin
     * @param objectName the name of the object
     */
    checkObjectForRefillAccess(objectName) {
        switch (objectName) {
            case 'Task':
                this.hideRefillFunctionality = true;
                break;
            case 'Account':
                if (this.permissionsThatCanRefillOnAccount.includes(true)) {
                    this.hideRefillFunctionality = false;
                    this.processTempCallout();
                }
                break;
            case 'Case':
                getCaseInfo({ recordId: this.recordId })
                    .then((result) => {
                        if (result.OwnerId === currentUserId && !result.IsClosed) {
                            this.hideRefillFunctionality = false;
                            this.processTempCallout();
                            //? add future renewal request option ONE TIME since the criteria was met
                            //! need to confirm this is a Pharmacy RT??? or Pharm User???
                            if (hasRenewalPermission && !this.addedFutureRenewal) {
                                this.componentOptions.unshift({
                                    label: 'Future Renewal Request',
                                    value: 'futurerenewalrequest',
                                    variant: 'brand'
                                });
                                this.addedFutureRenewal = true;
                            }
                        } else {
                            this.hideRefillFunctionality = true;
                        }
                        this.componentOptions = JSON.parse(JSON.stringify(this.componentOptions));
                    })
                    .catch((error) => {
                        this.nebulaLogger(error);
                    });
                break;
            case 'VCC_Progress_Note__c':
                getProgressNoteInfo({ recordId: this.recordId })
                    .then((result) => {
                        if (result.CreatedById === currentUserId && !result.VCC_Signed__c) {
                            this.showAddToNote = true;
                            this.hideRefillFunctionality = false;
                            this.processTempCallout();

                            //? add add to note option ONE TIME since the criteria was met
                            if (!this.addedAddToNote) {
                                this.componentOptions.unshift({
                                    label: 'Add To Note',
                                    value: 'addtonote',
                                    variant: 'neutral'
                                });
                                this.addedAddToNote = true;
                            }
                        } else {
                            this.hideRefillFunctionality = true;
                        }
                        this.progressNoteRecordType = result.RecordType.DeveloperName;
                        this.settingVaAddToNoteValues();
                        this.componentOptions = JSON.parse(JSON.stringify(this.componentOptions));
                    })
                    .catch((error) => {
                        this.nebulaLogger(error);
                    });
                break;
            default:
                break;
        }
    }

    isAddToNote = false;

    // get pages() {
    //     return `${'3'} of ${this.uniqueMedsListForDisplay?.length}`;
    // }

    handleAddToNote() {
        this.isAddToNote = true;
        this.handleModalOpen();
    }

    @track verifyButtons = [
        {
            value: 'submit',
            label: 'Submit',
            variant: 'brand',
            deactivated: true
        }
    ];

    // Use this to continue showing the refill spinner when the submit & close events are fired
    _skipRefillClose = false;

    handleRefillClosed() {
        if (!this._skipRefillClose) {
            this.displayRefillSpinner = false;
        }
        this._skipRefillClose = false;
    }

    handleRefilling() {
        this.displayRefillSpinner = true;
        this._skipRefillClose = true;
    }

    async handleVerifyRefill(event) {
        const record = {
            sObjectType: this._objectApiName,
            id: this.recordId
        };

        let facilityTransformedDetail = JSON.parse(JSON.stringify(event.detail));
        facilityTransformedDetail.forEach((e) => {
            e.facilityId = e.refillId;
            delete e.refillId;
        });

        try {
            const refillResponse = await handleRefillRequest({
                objectInfo: record,
                requestData: { requestJSON: JSON.stringify(facilityTransformedDetail) }
            });

            this.template.querySelector('[data-id="refill-verification"]').close();

            this.responseCaseObject = Object.assign({}, refillResponse.caseObject);
            this.responseAllSuccessful = refillResponse.allSuccessful;
            this.displayRefillSpinner = await false;
            // const url = generateRecordUrl(this,  refillResponse.caseObject.Id);

            let url = await this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: refillResponse.caseObject.Id,
                    objectApiName: 'Case',
                    actionName: 'view'
                }
            });

            if (refillResponse.allSuccessful) {
                // ? wait for toast message to show

                await this.dispatchEvent(
                    new ShowToastEvent({
                        variant: 'success',
                        title: 'Success!',
                        message: this.labels.successfulRefillMessage,
                        mode: 'sticky',
                        messageData: [
                            'Case',
                            {
                                url,
                                label: 'here'
                            }
                        ]
                    })
                );
            } else {
                await this.dispatchEvent(
                    new ShowToastEvent({
                        variant: 'error',
                        title: 'Uh oh...',
                        message: this.labels.errorRefillMessage,
                        mode: 'sticky',
                        messageData: [
                            'Case',
                            {
                                url,
                                label: 'here'
                            }
                        ]
                    })
                );
            }
        } catch (error) {
            this.logErrorAndToast(error);
        } finally {
            this.displayRefillSpinner = false;
            this._skipRefillClose = false;
            this.refreshMeds();
            this.dispatchEvent(new RefreshEvent());
        }
    }

    handlePickedCard(event) {
        this.verifyButtons[0].deactivated = !event?.detail?.selected;
        this.verifyButtons = JSON.parse(JSON.stringify(this.verifyButtons));
    }

    isFutureRenewalRequest = false;
    handleFutureRenewalRequest() {
        this.isFutureRenewalRequest = true;
        this.handleModalOpen();
    }

    settingVaAddToNoteValues() {
        //? VA values
        this.addToNoteTitle = 'Add VA Medications To The Progress Note';
        this.tableSort = 'Status & Expiration Date';
        this.addToNoteDefaults = AddToNoteDefaults;
        this.addToNoteMedsToDisplay = this.uniqueMedsListForDisplay;
        this._addToNoteOptions.isVAMeds = true;
        this._addToNoteOptions.isNonVAMeds = false;
        this._addToNoteOptions.medsFilterField = { label: 'Status', apiName: 'vaStatusValue' };
        this._addToNoteOptions.medSupplyFilterField = true;
        this._addToNoteOptions.rtPharmacy = this.progressNoteRecordType?.includes('VCC_Tier_I');
        //? update default value
        if (this.addToNoteOptions) {
            this._addToNoteOptions.topButtons = JSON.parse(this.addToNoteOptions);
        } else {
            this._addToNoteOptions.topButtons = this.getValuesBasedOnRecordType('topButtons');
        }

        //? update default value
        if (this.columnsForAddToNote) {
            this._columnsForAddToNote = JSON.parse(this.columnsForAddToNote);
        } else {
            this._columnsForAddToNote = this.getValuesBasedOnRecordType('columns');
        }

        // Restore VA Component Options when switching back to the VA Tab if modified for Non-VA
        if (this._vaComponentOptions) {
            this.componentOptions = JSON.parse(JSON.stringify(this._vaComponentOptions));
            this._vaComponentOptions = undefined;
        }
    }

    settingNonVaAddToNoteValues() {
        //? Non-VA Values
        this.addToNoteTitle = 'Add Non-VA Medications To The Progress Note';
        this.tableSort = 'Medication Name';
        this.addToNoteDefaults = NonVAMedsAddToNoteDefaults;
        this.addToNoteMedsToDisplay = this._meds.nonVaMeds;

        this._addToNoteOptions.topButtons = this.getValuesBasedOnRecordType('topButtons');
        this._addToNoteOptions.isVAMeds = false;
        this._addToNoteOptions.isNonVAMeds = true;
        this._addToNoteOptions.medsFilterField = null;
        this._addToNoteOptions.medSupplyFilterField = false;
        this._addToNoteOptions.rtPharmacy = this.progressNoteRecordType?.includes('VCC_Tier_I');
        this._columnsForAddToNote = this.addToNoteDefaults.columnsForAll;

        // Remove Future Renewal Request if present on Case for Non-VA tab
        if (this.objectApiName === 'Case' && !this._vaComponentOptions) {
            this._vaComponentOptions = JSON.parse(JSON.stringify(this.componentOptions));
            let removeByValue = new Set(['futurerenewalrequest']);
            this.componentOptions = JSON.parse(
                JSON.stringify(this.componentOptions.filter((elem) => !removeByValue.has(elem.value)))
            );
        }
    }

    // Populates this.workstream, a set of the user's workstreams
    // Output - Set<String>, values include: ct, vcv, pharmacy, msa
    // Usage - this.workstream.has('pharmacy') ? 'do pharmacy thing' : 'do something else';
    setUserWorkStream() {
        if (hasMSAPermission) {
            this.workstream.add('msa');
        }
        if (hasPharmI_Permission || hasPharmII_Permission || hasPharmIII_Permission) {
            this.workstream.add('pharmacy');
        }
        if (VCC_Medical_ProviderPermission) {
            this.workstream.add('vcv');
        }
        if (VCC_Registered_NursePermission) {
            this.workstream.add('ct');
        }
    }

    //? "property" is the property name that is used in the componentDefault.js object
    getValuesBasedOnRecordType(property) {
        let workstreamProperty;
        switch (this.progressNoteRecordType) {
            case 'VCC_Scheduling_Progress_Note':
            case 'VCC_Clinical_Triage_Note_Progress_Note':
                workstreamProperty = 'clinicalTriage';
                break;
            case 'VCC_Tier_I_Progress_Note':
            case 'VCC_Tier_II_Progress_Note':
            case 'VCC_Tier_III_Progress_Note':
                workstreamProperty = 'pharmacy';
                break;
            case 'VCC_Virtual_Visit_Progress_Note':
                workstreamProperty = 'virtualCareVisit';
                break;
            case 'PC_Provider_Connect_Progress_Note':
                workstreamProperty = 'virtualCareVisit';
                break;
            case 'TUC_Chart_Review':
            case 'TUC_Virtual_Visit':
            case 'TUC_Consultation_with_Triage_RN':
                workstreamProperty = 'teleUrgent';
                break;
            default:
                workstreamProperty = 'pharmacy';
                break;
        }
        //
        return this.addToNoteDefaults[workstreamProperty][property];
    }

    currentRx;
    displayCurrentRx = false;
    showMainTable = true;

    handleDisplayRxDetails(event) {
        // ! redundant
        this.currentRx = event.detail.rx;
        this.med = event.detail.rx;

        this.getTableState();
        this.showPaginationButtons();

        this.totalRecordsDetails = `${this.currentIndex + 1} of ${this.state.displayList.length}`;
        this.displayCurrentRx = true;
        this.enableDisableButtons();
        this.prepRxDetails(this.currentRx);
    }

    handleDisplayRxDuplicates(event) {
        this.currentRx = event.detail.rx;
        this.displayCurrentRx = false;
        this.displayRxDuplicates = true;
        this.showMainTable = false;
        this.createDuplicatesTable(this.currentRx);
        this.currentTable = 'dupe-meds';
        this.getTableState();
        this.totalRecordsDetails = `${this.currentIndex + 1} of ${this.state?.displayList?.length}`;
    }

    handleResetUI(event) {
        const tabSelected = event?.target?.dataset?.id;

        this.displayCurrentRx = false;
        this.displayRxDuplicates = false;
        this.showMainTable = true;

        switch (tabSelected) {
            case 'va-meds-tab':
                this.currentTable = 'va-meds';
                this.settingVaAddToNoteValues();
                break;
            case 'non-va-meds-tab':
                this.currentTable = 'non-va-meds';
                this.settingNonVaAddToNoteValues();
                break;
            default:
                // defaulting to va meds
                this.currentTable = 'va-meds';
        }
    }

    handleModalOpen() {
        // const modal = null;
        if (this.isAddToNote) {
            this.template.querySelector('[data-id="addToNoteBaseModal"]').open(this.template.host);
            this.isAddToNote = false;
        } else if (this.isFutureRenewalRequest) {
            this.template.querySelector('[data-id="futureRenewalRequestBaseModal"]').open(this.template.host);
            this.isFutureRenewalRequest = false;
        } else {
            this.template.querySelector('[data-id="detailBaseModal"]').open(this.template.host);
        }
        // modal.open(this.template.host);
    }

    @track
    medsToVerify = [];
    // TODO: align all modal opening methods
    async openVerificationRefillModal() {
        // const { dataId } = event?.target?.dataset?.id;
        const modal = this.template.querySelector(`[data-id="refill-verification"]`);

        await modal.open(this.template.host);
        modal.setSizeExternal('small');
        // modal.setSizeExternal('small');

        // this.template.querySelector(`[data-id="refill-verification"]`).setSizeExternal(t);

        // switch (dataId) {
        //     case 'refill-verification':
        //
        //         this.template.querySelector(`[data-id="refill-verification"]`).open(this.template.host);
        //         break;

        //     default:
        //         // eslint-disable-next-line
        //         console.error('unrecognized input');

        // }
    }

    handleModalClose() {
        const modal = this.template.querySelector('c-base-modal');
        if (modal) modal.close();
        this.template.querySelector('[data-id="futureRenewalRequestBaseModal"]')?.close();
    }

    closeRxDetailsHandler() {
        /*
            Function to hide the RX Details sub-component in the UI
        */

        this.displayCurrentRx = false;
    }

    handleKeyPress(event) {
        /*
            Function to handle key presses in the component
            @param event       Standard event object
        */

        if (event.code === this.ESCAPE) {
            // hide the RX Details sub-component in the UI when the escape key is pressed
            this.closeRxDetailsHandler();
        }
    }

    displayRefillSpinner = false;

    handleProgressValueChange(event) {
        this.progressValue = event.detail;
        // TODO: verification modal

        this.handleRefill();
    }

    responseCaseObject = {};
    responseAllSuccessful = false;

    @track vistaAddresses = [];

    fetchVISTADataForPatient(listOfMedsToBeRefilled) {
        try {
            let uniqueList = Object.keys(vccMedicationListHelper.help.groupBy(listOfMedsToBeRefilled, 'refillId'));
            return Promise.all(
                uniqueList.map((vista) => {
                    return getFacilityIens({ params: { icn: this._icn, facilityId: vista } }).then((f) => {
                        return fetchDemographicsByVista({ params: { ien: f, facilityId: vista } });
                    });
                })
            );
        } catch (error) {
            this.nebulaLogger(error);
            return null;
            // resume execution
        }
    }
    /**
     * @description Method creates our refill object as well as adds our temporary addresses to the medsToVerify list
     * that we are passing to the vccBaseVerticalPicker LWC
     */
    async handleRefill() {
        let stringMeds = '';
        this.displayRefillSpinner = true;
        const requester = await getRequesterName({ userId: currentUserId });

        let jsonBody = [];

        for (let i = 0; i < this.progressValue.length; i++) {
            let facilityCode = this.progressValue[i]?.fullData?.facility?.code;
            facilityCode =
                typeof facilityCode == 'string' && facilityCode.length > 3
                    ? facilityCode.substring(0, 3)
                    : facilityCode;
            // prescriptionNames.push(JSON.stringify(this.progressValue[i].drugName));

            let refillObject = {
                facilityId: this.progressValue[i]?.fullData?.facility?.code.substring(0, 3),
                refillId: facilityCode,
                prescriptionId: this.progressValue[i].prescriptionValue,
                prescriptionName: this.progressValue[i].drugName,
                icn: this._icn,
                requesterId: requester.Name
            };
            //
            jsonBody.push(refillObject);
        }
        let jsonBodyString = JSON.stringify(jsonBody);
        // const record = {
        //     sObjectType: this._objectApiName,
        //     id: this.recordId
        // };

        const requestData = {
            requestJSON: jsonBodyString
        };

        let res;

        try {
            res = await this.fetchVISTADataForPatient(JSON.parse(requestData.requestJSON));

            let resAddress = vccMedicationListHelper.help.groupBy(res, 'facilityId');
            const chunk = vccMedicationListHelper.help.groupBy(JSON.parse(requestData.requestJSON), 'facilityId');

            Object.keys(chunk).forEach((e) => {
                let fId = chunk[e][0].facilityId;
                let rId = chunk[e][0].refillId;
                chunk[e] = {
                    address: resAddress[rId][0].address, //resAddress.address, resAddress.facilityId (truncated to refillId)
                    facilityId: fId,
                    id: fId,
                    meds: chunk[e]
                };
            });

            this.medsToVerify = Object.values(chunk).map((val) => {
                return {
                    facility: val
                };
            });
            this.medsToVerify.forEach((object) => {
                let facId = object.facility.id.substring(0, 3);

                let aMatch = this.refreshTempAddress[facId];
                // let objectThreeDigitCode = object.facility.

                try {
                    if (aMatch.records.length > 0) {
                        object.facility.tempAddress = aMatch.records[0];
                        object.facility.isTemp = true;
                    } else {
                        object.facility.isTemp = false;
                    }
                } catch (error) {
                    console.error('Problem with Temporary address', error);
                }
            });
            this.medsToVerify.forEach((object) => {
                stringMeds = '';
                object.facility.meds.map((row) => {
                    stringMeds +=
                        JSON.parse(JSON.stringify(row.prescriptionName)) +
                        ' - ' +
                        JSON.parse(JSON.stringify(row.prescriptionId)) +
                        '\n';

                    return row.prescriptionName + ' - ' + row.prescriptionId + '\n';
                });
                object.facility.stringMeds = stringMeds;
            });
            this.personAccount = await getPatientasSFRecord({ icn: this._icn });
            this.openVerificationRefillModal();
        } catch (error) {
            // Handle error
            this.displayRefillSpinner = false;
            this.logErrorAndToast(error);
        }
    }
    refreshMeds() {
        this.displaySpinner = true;
        //? reset important variables
        this.showAddToNote = false;
        this.checkObjectForRefillAccess(this._objectApiName);
        Promise.all(Object.values(this.medsResponse).map((val) => refreshApex(val))).then(() => {
            this.displaySpinner = false;
        });
    }
    /**
     * @description handles refreshing our from the refresh button on the meds component, Utilizes cached data
     * from our wire methods.
     */
    refreshMedsFromButton() {
        this.displaySpinner = true;
        //? reset important variables
        this.showAddToNote = false;
        this.checkObjectForRefillAccess(this._objectApiName);
        Promise.all(
            [...Object.values(this.medsResponse), ...Object.values(this.refreshTempAddressObj)].map((val) =>
                refreshApex(val)
            )
        ).then(() => {
            this.displaySpinner = false;
        });
    }

    /**
     * @description when the user clicks the expand/collapse button, sets css classes in the HTML for the Modal to appear properly
     */
    expandCollapseMedsRxComponent() {
        this.expanded = !this.expanded;
        this.expandCollapseLabel = this.expanded ? this.COLLAPSE : this.EXPAND;
        this.expandCollapseIconName = this.expanded ? this.UTIL_COLLAPSE_ALL : this.UTIL_EXPAND_ALT;
        this.expandedCSSClasses = this.expanded ? this.EXPND_CSS_CLSS : this.EMPTY_STRING;
        this.expandedModalContainerCSS = this.expanded ? this.EXPND_MOD_CONT : this.EMPTY_STRING;
        this.expandedModalHeaderCSS = this.expanded ? this.EXPND_MOD_HEADER : this.EMPTY_STRING;
        this.expandedModalContentCSS = this.expanded ? this.EXPND_MOD_CONTENT : this.EMPTY_STRING;
        this.slotActions = this._showFrozenColumns ? 'actions' : '';
    }

    /**
     * @description handles user keyup events and closes the expanded modal if escape is pressed
     * @param event the triggering event
     */
    handleKeyUp(event) {
        event.stopPropagation();
        if (this.expanded && (event.code === this.ESCAPE || event.code === this.ESC)) {
            this.expandCollapseMedsRxComponent();
            this.refs.expandButton.focus();
        }
    }

    getRefillErrors(rx) {
        /*
            Function to check a med list row for allowed refills, and return an error message if applicable. 
            If refills are not allowed for the specified reasons, such as 0 refills or an expired prescription, 
            return the specific error. Otherwise, return a null error.
            @param rx       A med list row object
            @return String  An error message if the row does not allow refills, or null if it does
        */

        let rxRefillError = '';

        // if no refills are allowed by the fillsRemaining count, add error text
        if (parseInt(rx.fillsRemaining, 10) === 0 || rx.fillsRemaining === '') {
            rxRefillError += 'There are no remaining refills for this prescription. ';
        }

        // if no refills are allowed by the status, add error text
        // note: at time of writing this code, some meds data is coming back as DISCONTINUED (EDIT), thus it's included here
        if (
            rx.status.toLowerCase() === 'expired' ||
            rx.status.toLowerCase() === 'discontinued' ||
            rx.status.toLowerCase() === 'discontinued (edit)' ||
            rx.status.toLowerCase() === 'suspended'
        ) {
            rxRefillError += 'This prescription is ' + rx.status.toLowerCase() + '. ';
        }

        // return error text, or null if error text is empty
        return rxRefillError === '' ? null : rxRefillError;
    }

    /** async/await method to re-render the shadow dom after user clicks default sorting */
    async handleDefaultSorting() {
        this.displaySpinner = true;

        await new Promise((resolve) => {
            /* eslint-disable */
            setTimeout(resolve, 250);
            /**eslint-disable */
        });
        this.displaySpinner = false;
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'rxDetails':
                this.handleRowClick(row);
                break;
            default:
        }
    }

    handleRowClick(row) {
        this.displayCurrentRx = true;
        this.currentRx = row;
    }

    /** METHODS */

    createDuplicatesTable(incomingRx) {
        this.duplicateMedsTable.data = [];
        //? Use incomingRx to locate the array of duplicates
        this.duplicateMedsTable.data = this.groupedDuplicateMeds[incomingRx.drugNameFacilityString];
        this.duplicateMedsTable.drugName = incomingRx.drugName;
        //
        this.duplicateMedsTable.totalRecords = this.duplicateMedsTable.data.length;
        // this.scrollToTop(); // removed since the PACT component when shown is so large the screen hops up beyond user view
    }

    scrollToTop() {
        document.body.scrollTop = document.documentElement.scrollTop = 0;
    }

    //TODO: Remove all references to this classes members
    // instead create an object to house everything below then return it
    isVAMed;
    prepRxDetails(value) {
        try {
            this._med = value;

            // Check if med is VA or non-VA med
            this.isVAMed = this._med?.fullData?.vaType?.value === 'O';

            // clone the med object
            let tempMed = JSON.parse(JSON.stringify(value));

            // Storing in array for use later
            let doseArray = tempMed.fullData.doses.dose;
            let productArray = tempMed.fullData.products.product;

            this.medFormatted.fillDate =
                this.fillArray[this.fillArray.length - 1] !== undefined
                    ? this.transformDate(this.fillArray[this.fillArray.length - 1].fillDate)
                    : '';

            // Set dose information to the most recent dose (last element in array)
            if (doseArray.length > 0) {
                this.dose = doseArray[doseArray.length - 1];
                if (this.dose.noun) {
                    this.medFormatted.dosage = this.dose.unitsPerDose + ' ' + this.dose.noun;
                } else if (!this.dose.noun || !this.dose.unitsPerDose) {
                    this.medFormatted.dosage = this.dose.dose;
                } else {
                    this.medFormatted.dosage = '';
                }
            } else {
                this.medFormatted.dosage = '';
            }

            this.product = productArray[0];
            /**
             *
             */
            this._drugName = tempMed.fullData.name?.value;
            this._drugName = tempMed.drugName;

            // Missing value handling
            //? was removed since it is no longer on details pop-up
            //? since Non-VA meds do not have this if the dosage is missing, a console error appeared & no pop-up opened
            // if (!this.product?.vaProduct) {
            //     this.product.vaProduct = {};
            //     this.product.vaProduct.name = "";
            // }

            if (!this.med.fullData.prescription) {
                this.med.fullData.prescription = {};
                this.med.fullData.prescription.value = '';
            }
            if (!this.med.fullData.vaStatus) {
                this.med.fullData.vaStatus = {};
                this.med.fullData.vaStatus.value = '';
            }
            if (!this.med.fullData.facility) {
                this.med.fullData.facility = {};
                this.med.fullData.facility.name = '';
                this.med.fullData.facility.code = '';
            }
            if (!this.med.fullData.vaStatus) {
                this.med.fullData.vaStatus = {};
                this.med.fullData.vaStatus.value = '';
            }
            if (!this.dose) {
                this.dose = {};
                this.dose.schedule = '';
            }
            if (!this.med.fullData.sig) {
                this.med.fullData.sig = {};
                this.med.fullData.sig.content = '';
            }
            if (!this.med.fullData.ptInstructions) {
                this.med.fullData.ptInstructions = {};
                this.med.fullData.ptInstructions.content = '';
            }
            if (!this.med.fullData.fillsAllowed) {
                this.med.fullData.fillsAllowed = {};
                this.med.fullData.fillsAllowed.value = '';
            }
            if (!this.med.fullData.orderingProvider) {
                this.med.fullData.orderingProvider = {};
                this.med.fullData.orderingProvider.name = '';
            }
            if (!this.med.fullData.quantity) {
                this.med.fullData.quantity = {};
                this.med.fullData.quantity.value = '';
            }
            if (!this.med.fullData.fillsRemaining) {
                this.med.fullData.fillsRemaining = {};
                this.med.fullData.fillsRemaining.value = '';
            }
            if (!this.med.fullData.daysSupply) {
                this.med.fullData.daysSupply = {};
                this.med.fullData.daysSupply.value = '';
            }
            if (!this.med.fullData.routing) {
                this.med.fullData.routing = {};
                this.med.fullData.routing.value = '';
            }
            if (!this.med.fullData.location) {
                this.med.fullData.location = {};
                this.med.fullData.location.name = '';
            }
            if (!this.med.fullData.fillCost) {
                this.med.fullData.fillCost = {};
                this.med.fullData.fillCost.value = '';
            }

            // if the med has fills, set data on the fills object and set hasFills = true
            // otherwise, set hasfills = false
            if (tempMed.fullData.fills.fill.length > 0) {
                this.fillArray = tempMed.fullData.fills.fill;
                this.hasFills = true;

                // Reverse array to sort descending
                this.fillArray = this.fillArray.reverse();

                for (const fillElement of this.fillArray) {
                    fillElement.fillDate = this.transformDate(fillElement.fillDate);
                }
            } else {
                this.hasFills = false;
            }
            this.handleModalOpen();
        } catch (error) {
            this.nebulaLogger(error);
            this.hasError = true;
        }
    }

    transformDate(dateString) {
        /* 
            Takes date value of format 3YYMMDD and transforms it into a Salesforce-readable date
            @param dateString   a string in format 3YYMMDD to be transformed
            @return String      a date formatted to YYYY-MM-DD
        */
        // Date format from Meds API is YYYMMDD, where YYY is how many years since 1700
        // if string isn't blank, transform into more usable YYYY-MM-DD

        let rVal;

        if (dateString !== undefined && dateString !== '') {
            let y = dateString.substr(0, 3);
            let m = dateString.substr(3, 2);
            let d = dateString.substr(5, 2);

            y = 1700 + parseInt(y, 10);

            rVal = y + '-' + m + '-' + d;
        } else {
            rVal = '';
        }
        return rVal;
    }

    /**
     * @description Checks and handles bad connection and empty list scenarios
     * @param {`object`} preparedMeds categorized medslist object
     */
    validate(preparedMeds) {
        let vaErrorCount;
        let nonVaErrorCount;
        this.dataErrorsList = [];
        if (preparedMeds?.dataHasErrors.length > 0) {
            this.dataHasErrors = true;
            vaErrorCount = `${preparedMeds.dataHasErrors.length} VA Meds`;

            this.nebulaLogger(preparedMeds.dataHasErrors, true);
        }
        if (preparedMeds?.nonVADataHasErrors.length > 0) {
            nonVaErrorCount = `${preparedMeds.nonVADataHasErrors.length} Non-VA Meds`;
            this.nonVADataHasErrors = true;

            this.nebulaLogger(preparedMeds.nonVADataHasErrors, true);
        }
        let errorString;
        if (this.dataHasErrors && this.nonVADataHasErrors) errorString = vaErrorCount + ' and ' + nonVaErrorCount;
        if (this.dataHasErrors) errorString = vaErrorCount;
        if (this.nonVADataHasErrors) errorString = nonVaErrorCount;

        if (errorString) {
            this.labels.dataHasErrorsMessage = dataHasErrorsMessage.replace('{0}', errorString);

            //The patient has 13 VA Meds and 6 Non-VA Meds that have missing values and have not been retrieved. The medication list may be incomplete, please review the patient's medical records in EHR.

            //? bundle warning for warning component
            let warningString = `${this.labels.dataHasErrorsMessage} ${this.labels.dataHasErrorsSubMessage}`;
            let warningObj = { message: warningString };
            this.dataErrorsList.push(warningObj);
        }

        this.noVaResultsAndNoErrors = this.noVaResults + !this.dataHasErrors;
        this.noNonVaResultsAndNoErrors = this.noNonVaResults + !this.nonVADataHasErrors;
        // is the "all" key an empty array? -> the all key is the original medslist before processing
        if (!preparedMeds?.all?.length) {
            this._medsListEmpty = true;
            this.labels.noResultsMessage = noResultsMessage.replace('{0}', this.componentTitle);
            return false;
        }

        return true;
    }

    /**
     * @description Sets initial reactive properties
     * @param {*} processedMedsList
     */

    setInitialClassProperties(processedMedsList, processedVistaLimitErrors) {
        /* eslint-disable no-unused-expressions */ // <-- Allow long lines starting from her
        this._meds = processedMedsList;
        this.uniqueMedsListForDisplay = processedMedsList.uniqueMedsListForDisplay;
        this.groupedDuplicateMeds = processedMedsList.groupedDuplicateMeds;

        this._meds?.nonVaMeds ? (this.noNonVaResults = false) : (this.noNonVaResults = true); // list of meds to display
        if (this._meds?.nonVaMeds.length == 0) this.noNonVaResults = true;
        this._meds?.active ? (this.noVaResults = false) : (this.noVaResults = true); // list of meds to display
        if (this._meds?.active.length == 0) this.noVaResults = true;
        /* eslint-disable no-unused-expressions */ // <-- Allow long lines starting from her
        if (processedVistaLimitErrors.length > 0) {
            this.labels.dataHasVistaLimitErrorMessage = this.labels.dataHasVistaLimitErrorMessage.replace(
                '{0}',
                processedVistaLimitErrors.join(', ')
            );
            this.dataHasVistaLimitErrors = true;
        }
    }

    displayAddMoreDataInputs() {
        const medsTableComponent = this.template.querySelector('c-vcc-medication-table');
        medsTableComponent && medsTableComponent.setNavInput('daterange');
    }

    handleUpdateState(obj) {
        // validate incoming object
        obj = obj?.detail?.value || undefined;

        if (!typeof obj === 'object' || Array.isArray(obj)) {
            return;
        }

        for (const key of Object.keys(obj)) {
            // iterate through all the keys in the incoming object

            if (!Object.keys(this.state).includes(key)) {
                continue;
            }

            try {
                this.state[key] = obj[key];
            } catch (error) {
                this.nebulaLogger(error);
            }
        }
    }

    /**
     * @description Fetches the state of the displayList in BaseHDR Frame, then paginates accordingly
     * @param {`object`} event Expecting an event from baseModal
     * @returns
     */

    nextValueChange(event) {
        try {
            this.getTableState();
            switch (event?.detail?.name) {
                case 'Next':
                    if (this.currentIndex < this.state.displayList.length - 1) {
                        this.currentIndex = this.currentIndex + 1;
                    }
                    break;
                case 'Previous':
                    if (this.currentIndex > 0) {
                        this.currentIndex -= 1;
                    }
                    break;
                case 'First':
                    this.currentIndex = 0;
                    break;
                case 'Last':
                    this.currentIndex = this.state.displayList.length - 1;
                    break;
                default: // do nothing
            }

            this.totalRecordsDetails = this.currentIndex + 1 + '  of  ' + this.state.displayList.length;

            // !redundant properties
            this.currentRx = this.state.displayList[this.currentIndex];
            this.med = this.state.displayList[this.currentIndex];
            this.showPaginationButtons();
            this.enableDisableButtons();
            this.prepRxDetails(this.currentRx);
        } catch (error) {
            this.nebulaLogger(error);
        }
    }

    /**
     * @description retrieves and stores Base HDR Frame state
     * then identify the index of the selected record
     * @param tableId
     */

    getTableState() {
        const tableComponent = this.template.querySelector(`[data-id='${this.currentTable}']`);

        if (tableComponent) {
            this.state = tableComponent.getState();

            this.currentIndex = this.state.displayList.findIndex((record) => record.uuid === this.currentRx.uuid); // get the index of the current record
        }
    }

    /**
     * @description Enables/disables pagination buttons depending on index of current page
     */

    enableDisableButtons() {
        switch (this.currentIndex) {
            case 0:
                this.nxtBtn = false;
                this.prevBtn = true;
                break;
            case this.state.displayList.length - 1:
                this.nxtBtn = true;
                this.prevBtn = false;
                break;
            default:
                this.nxtBtn = false;
                this.prevBtn = false;
        }
    }

    showPaginationButtons() {
        this.ShowBtns = this.state.displayList.length > 1 ? true : false;
    }

    get pharmLogRequest() {
        return {
            prescriptionId: this.med?.fullData?.prescription?.value,
            facilityId: this.med?.fullData?.facility?.code,
            logType: this.logType
        };
    }

    logType;
    handlePharmLogTabClick(event) {
        this.logType = event.target.value;
    }
    handleChangeWorkStream() {
        this.displaySpinner = true;
        this.selectedThreeYears = !this.selectedThreeYears;
        this.selectedStartDate = (this.selectedThreeYears ? this.threeYearStartDate : this.defaultStartDate)
            .toISOString()
            .split('T', 1)[0];
        this.hdrFormattedStartDate = (
            this.selectedThreeYears ? this.threeYearStartDate : this.defaultStartDate
        ).toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'numeric',
            day: 'numeric'
        });
    }
}
