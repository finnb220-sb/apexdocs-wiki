/* eslint-disable no-unused-expressions */
import { LightningElement, api, track, wire } from 'lwc';
import { uniqueId, inBothArrays } from 'c/helpersLWC';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { datatableHelper, dateFormatter } from 'c/utils';

import PN_Object from '@salesforce/schema/VCC_Progress_Note__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { publish, MessageContext } from 'lightning/messageService';
import baseAddToNoteMC from '@salesforce/messageChannel/vccBaseAddToNote__c';

//? connection errors are caught on the parent component and will prevent Add to Note functionality
import noResultsMessage from '@salesforce/label/c.VCC_Generic_message_for_null_search_results';
import noResultsSubMessage from '@salesforce/label/c.VCC_Generic_sub_message_for_null_search_results';
import entryTooLong from '@salesforce/label/c.VCC_Entry_is_too_long_error';
import entryReachedMax from '@salesforce/label/c.VCC_Entry_reached_max_error';
import differentFacilityWarning from '@salesforce/label/c.VCC_different_facility_warning';
import facilityMessage from '@salesforce/label/c.VCC_facility_message';
import facilityPopup from '@salesforce/label/c.VCC_Facility_Popup';

import getProgressNote from '@salesforce/apex/VCC_MedsListController.getProgressNoteInfo';
import facilityModal from 'c/baseConfirmPopup';

export default class baseAddToNoteFrame extends LightningElement {
    @api incomingRecordId;
    @api pageSize;
    @api settings;

    selectedRowData; //Gives a map of the selected medication that a user clicks on.
    buttonObj; //Stores relevant information about the row clicked and the action to take.
    isDifferentFacilitySelected = false; //Provides a boolean based on whether a different facility has been selected.
    differentFacilityWarning; //Provides the text that should be populated in the html if a different facility has been chosen.
    facilityError = facilityMessage; //Message from Custom Label VCC_facility_message.
    selectedFacilityMap; // A map of all the facilities selected including those selected in previous sessions.
    recordFacility; //? contains the value from the Progress Note record.
    selectedFacility; //? contains the facility from the selection made by the user when no recordFacility is present.
    newFacilityMap; //A map of new facilities to be added.
    selectedFacilityArray; // An Array of the original Facilities that exists in the Progress Note.
    newFacilityArray; //An Array of the new Facilities to be added.
    selectedMedications = {}; //An Object that will hold the medications selected.
    _options = {}; // Initialize as an empty object to be populated by @api set options, and to prevent null pointers if not set.
    buttonLabel = 'Submit'; //Button that adds the list of selected meds to the record.
    isVAMeds = false; //Checks whether the med selected is a VA med.

    popupMessage = facilityPopup; //Retrieves the label value from VCC_Facility_Popup.
    POPUP_VARIANT = 'warning'; // Popup Variant
    POPUP_STYLING = 'slds-align_absolute-center slds-var-m-around_large';
    POPUP_NEXT = 'Continue'; // Popup continue button label
    POPUP_CANCEL = 'Cancel'; // Popup cancellation buttion label

    @api
    set options(value) {
        this._options = value;
        this.displaySingleFilter = value.singleFilterField?.label !== undefined;
        this.displayMedsFilter = value.medsFilterField?.label !== undefined;
        this.isVAMeds = value?.isVAMeds;
        this.displayMedSupplyFilter = value.medSupplyFilterField;
    }

    get options() {
        return this._options;
    }

    @api
    set userPermissions(value) {
        this._userPermissions = value;
        this.showFacilitiesField =
            (value?.adminSchedulingMSA ||
                value?.clinicalTriageRN ||
                value?.pharmacyPHR.includes(true) ||
                value?.teleUrgentTED) &&
            this.isVAMeds;
    }

    get userPermissions() {
        return this._userPermissions;
    }

    get medsFilterOptions() {
        return [
            { label: 'All Active VA Meds', value: 'ALL' },
            { label: 'Active', value: 'ACTIVE' },
            { label: 'Pending', value: 'PENDING' },
            { label: 'Suspended', value: 'SUSPENDED' }
        ];
    }

    get medSupplyFilterOptions() {
        return [
            { label: 'ALL', value: 'ALL' },
            { label: 'MEDICATIONS', value: 'Medication' },
            { label: 'SUPPLIES', value: 'Supply' }
        ];
    }

    @wire(getObjectInfo, { objectApiName: PN_Object })
    objectInfo;

    @wire(MessageContext)
    messageContext;

    formLoading = true;
    noRowsSelected = true;
    addingSelectedError = false;
    inputError = false;

    @api columns;
    @api size;
    @api currentObject;
    @api hideAddToNote = false;

    @track displayList;
    @track tableData;
    displaySingleFilter = false;

    emptyState = false;
    noIncomingData = false;
    _sortedDirection;
    get sortedDirection() {
        return this._sortedDirection;
    }
    @api set sortedDirection(value) {
        this._sortedDirection = value;
    }
    _sortedBy;
    get sortedBy() {
        return this._sortedBy;
    }
    @api set sortedBy(value) {
        this._sortedBy = value;
    }
    /**
     * @description Find the column matching this.sortedBy to get its label, and pass that to baseTableDetails
     * - still respects an outside value passed to this.tableSort
     * @return `String` the label of the column whose fieldName matches this.sortedBy
     */
    get tableDetailsSortedByLabel() {
        return this.tableSort ?? datatableHelper.getColumn(this.columns, this.sortedBy)?.label;
    }
    _list; //? unchanging property

    selectedRows = [];
    fieldsUsedInFrame = [];
    searchResults = [];
    baseFilterResults = [];
    medsSupplyFilterResults = [];
    meds;
    uniqueIdProperty = 'addToNoteId';

    // auto check properties
    controlledMed;
    nonControlledMed;
    renewRequested;
    _tableSort;

    @api
    set tableSort(value) {
        this.tableDetails.sortedBy = value ? value : 'Date'; //? defaulting to date
        this._tableSort = value;
    }

    get tableSort() {
        return this._tableSort;
    }

    @track
    tableDetails = {
        total: 0,
        sortedBy: 'Date' //? defaulting to date
    };

    labels = {
        noResultsMessage: noResultsMessage,
        noResultsSubMessage: noResultsSubMessage,
        entryTooLong: entryTooLong,
        entryReachedMax: entryReachedMax
    };

    /* LIFECYCLE METHODS */

    async connectedCallback() {
        if (this.incomingRecordId) {
            await this.getFacilityAndCheckboxInfo();

            this.labels.noResultsMessage = noResultsMessage.replace('{0}', this.settings.title);
            if (
                this.options.topButtons[0].field === 'VCC_Requested_Medication__c' ||
                this.options.topButtons[0].field === 'VCC_Medications_Refill_Renewal_Request__c'
            ) {
                this.differentFacilityWarning = differentFacilityWarning;
            }
        }
    }

    async getFacilityAndCheckboxInfo() {
        try {
            let recordFound = await getProgressNote({ recordId: this.incomingRecordId });
            //? populate this value if found on load
            this.selectedFacility = recordFound.VCC_Facility__c ? recordFound.VCC_Facility__c : '';
            this.controlledMed = recordFound.VCC_Controlled_medication__c;
            this.nonControlledMed = recordFound.VCC_Non_controlled_medication__c;
            return recordFound;
        } catch (err) {
            console.error('replace with logger: ', err.body.message);
            return null;
        }
    }

    renderedCallback() {
        const pagination = this.template.querySelector('c-base-pagination');
        if (pagination) this.tableDetails.total = pagination.totalRecords();
    }

    /* HANDLERS */

    handleLoad() {
        this.formLoading = false;
        if (this.noIncomingData) return;
        this.reset();
        this.deactivateSubmitButton(true);
    }

    handleSuccess() {
        this.buildListOfFieldsUsed();
        let fieldNameLabels = this.fieldsUsedInFrame
            .map((field) => {
                return this.objectInfo.data.fields[field].label;
            })
            .join(' and ');

        let successTitle = 'Add to note successful';
        let successMessage = `${this.settings.title} added to "${fieldNameLabels}"`;
        //? option if wanting to use the word "field(s)" at end of toast
        // let successMessage = `${this.settings.title} added to "${fieldNameLabels}" field${this.fieldsUsedInFrame.length > 1 ? '(s)' : ''}`;

        this.formLoading = false;
        this.showToast(successTitle, successMessage, 'success', 'sticky');
        this.close();
    }

    handleError(event) {
        let errorTitle = 'An error has occurred while updating record';
        this.formLoading = false;
        this.showToast(errorTitle, event.detail.message, 'error', 'sticky');
        this.close();
    }

    handlePageChange(event) {
        this.tableData = event.detail;
        this.clearTableSelections();
    }

    handleSearch(event) {
        const results = JSON.parse(event.detail) || null;
        const baseSearchBar = this.template.querySelector('c-base-search-bar');
        this.clearTableSelections();

        // handle clearing
        if (!baseSearchBar.inputLength()) {
            this.emptyState = false;
            this.searchResults = this._list;
            this.setRecords();
            return;
        }

        if (results?.length) {
            this.emptyState = false;
            this.searchResults = results;
            this.setRecords();
        } else {
            this.emptyState = true;
            this.noRowsSelected = true;
        }
    }

    handleBaseFilter(event) {
        const filteredList = event.detail;
        this.clearTableSelections();

        if (filteredList.length) {
            this.emptyState = false;
            this.baseFilterResults = event.detail;
            this.setRecords();
        } else {
            this.emptyState = true;
        }
    }

    handleMedsFilter(event) {
        //? event.detail = {value: 'SUSPENDED'}
        let filterForArray = [];
        if (event.detail.value === 'ALL') {
            filterForArray.push('ACTIVE', 'PENDING', 'SUSPENDED');
        } else {
            filterForArray.push(event.detail.value);
        }
        this.value = event.detail.value;
        const filteredList = this._list.filter((el) => filterForArray.includes(el?.vaStatusValue));
        this.clearTableSelections();
        // // this.clearSearch();

        if (filteredList.length) {
            this.emptyState = false;
            this.baseFilterResults = filteredList;
            this.setRecords();
        } else {
            this.emptyState = true;
        }
    }

    handleMedSupplyFilter(event) {
        let filterForArray = [];
        if (event.detail.value === 'ALL') {
            filterForArray.push('Medication', 'Supply');
        } else {
            filterForArray.push(event.detail.value);
        }
        this.medSupplyFilterValue = event.detail.value;
        const filteredList = this._list.filter((el) => filterForArray.includes(el?.medicationSupply));

        if (filteredList.length) {
            this.emptyState = false;
            this.medsSupplyFilterResults = filteredList;
            this.setRecords();
        } else {
            this.emptyState = true;
        }
    }

    handleSort(event) {
        let { fieldName, sortDirection } = event?.detail ?? {};
        this.displayList = this.sortData(this.displayList, fieldName, sortDirection);
        this.setPagination();
    }

    sortData(data, fieldName, sortDirection) {
        this._sortedDirection = sortDirection;
        this._sortedBy = fieldName;
        const column = datatableHelper.getColumn(this.columns, fieldName);
        return datatableHelper.sortHDRData(data ?? [], column, sortDirection);
    }

    handleRowSelected(event) {
        this.selectedRows = event.detail.selectedRows;
        this.noRowsSelected = this.selectedRows.length === 0 ? true : false;
        this.resetErrorState();
    }

    handleDispatchAddToNoteEvent() {
        this.dispatchEvent(new CustomEvent('addtonote', { bubbles: true, composed: true }));
    }

    //? puts the selected data in the corresponding field based on the options object sent in to this component
    handleAddSelected(event) {
        const label = JSON.parse(JSON.stringify(event.target.label));
        let datatable = this.template.querySelector('lightning-datatable');
        this.selectedRowData = datatable.getSelectedRows();
        this.resetErrorState();
        //check if renewal or extension
        if (event.target.label === 'Add for Extension') {
            //Don't do anything for now, but keeping this condition for future changes which may be required for updating VCC_Medication_Extension__c checkbox
        } else {
            //Check renew selected checkbox for tier I or Tier II + add for renewal
            this.renewRequested = true;
        }
        this.buttonObj = this.getDetailsFromButtonLabel(label);
        if (this.buttonObj?.validateFacility) {
            if (this.isSameFacilitySelected(this.selectedRowData)) {
                //These Items have been added to the Technical Debt Sheet.
                let meds = JSON.parse(JSON.stringify(this.selectedMedications));
                for (let i = 0; i < this.selectedRowData.length; i++) {
                    meds[this.selectedRowData[i].id] = this.selectedRowData[i];
                }

                if (!this.isSameFacilitySelected(Object.values(meds))) {
                    this.isDifferentFacilitySelected = true;
                    this.differentFacilityWarning = undefined;
                    this.handleOpenWarning();
                    return;
                }

                for (let i = 0; i < this.selectedRowData.length; i++) {
                    this.selectedMedications[this.selectedRowData[i].id] = this.selectedRowData[i];
                }

                //? Check if is renewal and the selected row data to see if it contains CS Schedule meds in it, if so auto-check controlled med checkbox
                if (this.renewRequested && this.isCSScheduleMed(this.selectedRowData)) {
                    this.controlledMed = true;
                }
                //? Check if is renewal and the selected row data to see if it contains non CS Schedule meds in it, if so auto-check non-controlled med checkbox
                if (this.renewRequested && this.isNotCSScheduleMed(this.selectedRowData)) {
                    this.nonControlledMed = true;
                }

                if (!this.isSameFacilitySelected(this.selectedRowData)) {
                    this.isDifferentFacilitySelected = true;
                    this.differentFacilityWarning = undefined;
                    this.handleOpenWarning();
                    return;
                }

                this.addToNoteField(this.selectedRowData, this.buttonObj);
                this.isDifferentFacilitySelected = false;
                this.differentFacilityWarning = differentFacilityWarning;
            } else {
                this.isDifferentFacilitySelected = true;
                this.differentFacilityWarning = undefined;
                this.handleOpenWarning();
            }
        } else {
            this.addToNoteField(this.selectedRowData, this.buttonObj);
        }
    }

    /**
     * @description This method accounts for all the unique facilities added and their scenarios once the message on the warning modal has been accepted
     */
    //Open Warning Modal
    async handleOpenWarning() {
        const acceptMessage = 'continue';
        facilityModal
            .open({
                size: 'small',
                description: 'Facility Warning Modal',
                variant: this.POPUP_VARIANT,
                styling: this.POPUP_STYLING,
                content: this.popupMessage,
                next: this.POPUP_NEXT,
                cancel: this.POPUP_CANCEL
            })
            .then((result) => {
                if (result === acceptMessage) {
                    let facilitySize = this.selectedFacilityArray?.length;
                    this.formatFacilityList(facilitySize);
                }
                //Adds Selected Medications
                this.addToNoteField(this.selectedRowData, this.buttonObj);

                //? Check if is renewal and the selected row data to see if it contains CS Schedule meds in it, if so auto-check controlled med checkbox
                if (this.renewRequested && this.isCSScheduleMed(this.selectedRowData)) {
                    this.controlledMed = true;
                }
                //? Check if is renewal and the selected row data to see if it contains non CS Schedule meds in it, if so auto-check non-controlled med checkbox
                if (this.renewRequested && this.isNotCSScheduleMed(this.selectedRowData)) {
                    this.nonControlledMed = true;
                }
            });
    }

    /**
     * @description This method formats the facilities array into a string seperated by commas for each individual facility
     */

    formatFacilityList(facilityLength) {
        if (facilityLength === 0) {
            let formattedFacility = this.newFacilityArray?.join('').replace(/.{3}/g, '$&,').replace(/,/g, ', ');
            this.selectedFacility = formattedFacility?.slice(0, -2);
        } else {
            let allFacilityList = this.selectedFacilityArray?.concat(this.newFacilityArray);
            let formattedFacility = [...new Set(allFacilityList)].join('').replace(/.{3}/g, '$&,').replace(/,/g, ', ');
            this.selectedFacility = formattedFacility?.slice(0, -2);
        }
    }

    //Checks if the selected medications have csSchedule data
    isCSScheduleMed(rowsToAdd) {
        return rowsToAdd.some((e) => e.csSchedule !== '' && e.csSchedule !== '1');
    }

    //Checks if the selected medications have no csSchedule data
    isNotCSScheduleMed(rowsToAdd) {
        return rowsToAdd.some((e) => e.csSchedule === '' || e.csSchedule === '1');
    }

    // checks if the medication belongs to same facitily - CCCM- 20527
    isSameFacilitySelected(rowsToAdd) {
        this.selectedFacilityMap = {};
        this.newFacilityMap = {};
        this.selectedFacilityArray = [];
        this.newFacilityArray = [];

        if (this.selectedFacility !== undefined && this.selectedFacility !== null && this.selectedFacility !== '') {
            //After we have converted the selected array to a string if we have more than one facility we want to get rid of the comma and convert it back to an array after then convert it to an object.
            // So '983, 982' to {983:983, 982:982}
            if (this.selectedFacility.length >= 3) {
                let currentFacilities = this.selectedFacility.replace(/,/g, '').split(' ');
                this.selectedFacilityMap = currentFacilities.reduce((a, v) => ({ ...a, [v]: v }), {});
            } else {
                this.selectedFacilityMap[this.selectedFacility] = this.selectedFacility;
            }
        }

        rowsToAdd.forEach((e) => {
            if (e?.fullData?.facility?.code) {
                this.newFacilityMap[e?.fullData?.facility?.code.substring(0, 3)] =
                    e?.fullData?.facility?.code.substring(0, 3);
            }
        });

        if (this.selectedFacilityMap !== null) {
            this.selectedFacilityArray = Object.keys(this.selectedFacilityMap);
        }

        if (this.newFacilityMap !== null) {
            this.newFacilityArray = Object.keys(this.newFacilityMap);
        }

        if (this.selectedFacilityArray?.length === 0 && this.newFacilityArray?.length > 1) {
            return false;
        }

        if (
            this.selectedFacilityArray.length === 1 &&
            this.newFacilityArray.length === 1 &&
            this.selectedFacilityArray[0] !== this.newFacilityArray[0]
        ) {
            return false;
        }

        if (this.selectedFacilityArray.length === 1 && this.newFacilityArray.length > 1) {
            return false;
        }

        let allFacilities = this.newFacilityArray.concat(this.selectedFacilityArray);
        let uniqueFacilities = [...new Set(allFacilities)];

        if (uniqueFacilities.length > 1) {
            let formattedFacility = uniqueFacilities.join('').replace(/.{3}/g, '$&,').replace(/,/g, ', ');
            this.selectedFacility = formattedFacility.slice(0, -2);
            return true;
        }

        this.selectedFacility = uniqueFacilities.join('');
        return true;
    }

    /* METHODS */

    resetErrorState() {
        this.addingSelectedError = false;
        this.inputError = false;
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        inputFields.forEach((inputs) => inputs.classList.remove('slds-has-error'));
    }

    buildListOfFieldsUsed() {
        this.options.topButtons.forEach((elem) => this.fieldsUsedInFrame.push(elem.field));
    }

    @api
    buttonPressed(button) {
        if (button) this.template.querySelector('lightning-record-edit-form').submit();
        this.formLoading = true;
    }

    //? using css to hide pagination for performance
    get paginationState() {
        if (this.emptyState) {
            return 'hide';
        }
        return '';
    }

    @api
    set list(value) {
        if (value?.length) {
            this._list = this.addUniqueIdToData(value);
            this.searchResults = this._list;
            this.baseFilterResults = this._list;
            this.medsSupplyFilterResults = this._list;
            this.displayList = this._list;
        } else {
            this.emptyState = true;
            this.noIncomingData = true;
        }
    }

    get list() {
        return this._list;
    }

    addUniqueIdToData(list) {
        //? not all data coming in has a uniqueId so this method will execute that
        let obj = {};
        let arr = [];
        arr = list.map((el) => {
            obj = JSON.parse(JSON.stringify(el));
            obj[this.uniqueIdProperty] = uniqueId();
            return obj;
        });
        return arr;
    }

    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    close(event) {
        const evt = new CustomEvent('closemodal', {
            detail: event?.detail?.row,
            composed: true,
            cancelable: false,
            bubbles: true
        });
        this.dispatchEvent(evt);
    }

    //? get the field that needs to be used for the addToNoteField method
    getDetailsFromButtonLabel(label) {
        let buttonObj = this.options.topButtons.filter((elem) => elem.label === label);
        return buttonObj[0];
    }

    reset() {
        this.clearSearch();
        this.clearTableSelections();
        let baseFilter = this.template.querySelector('c-base-single-filter');
        if (baseFilter) baseFilter.setValue('selectanoptionplaceholder'); // "selectanoptionplaceholder" is a value that will not appear in the data set so it will show the placeholder "Select an Option"
        let medsFilter = this.template.querySelector('.medsFilter');
        if (medsFilter) this.value = null;
        this.emptyState = false;
        this.isDifferentFacilitySelected = false;
        if (
            this.options.topButtons[0].field === 'VCC_Requested_Medication__c' ||
            this.options.topButtons[0].field === 'VCC_Medications_Refill_Renewal_Request__c'
        ) {
            this.differentFacilityWarning = differentFacilityWarning;
        }
        this.searchResults = this._list;
        this.baseFilterResults = this._list;
        this.medsSupplyFilterResults = this._list;
        this.medSupplyFilterValue = null;
        this.setRecords();
        this.resetErrorState();
    }

    setRecords() {
        let filteredResults = this._list;
        //? if the searchResults is less than the full list then find inBothArrays
        if (this.searchResults.length < this._list.length) {
            filteredResults = inBothArrays(this.searchResults, filteredResults, this.uniqueIdProperty);
        }
        //? if the baseFilterResults is less than the full list then find inBothArrays
        if (this.baseFilterResults.length < this._list.length) {
            filteredResults = inBothArrays(this.baseFilterResults, filteredResults, this.uniqueIdProperty);
        }
        //? if the medsSupplyFilterResults is less than the full list then find inBothArrays
        if (this.medsSupplyFilterResults.length < this._list.length) {
            filteredResults = inBothArrays(this.medsSupplyFilterResults, filteredResults, this.uniqueIdProperty);
        }

        this.displayList = filteredResults;
        if (!this.displayList?.length) {
            this.emptyState = true;
        } else {
            this.setPagination();
        }
    }

    setPagination() {
        const pagination = this.template.querySelector('c-base-pagination');
        if (pagination) {
            this.displayList?.length && pagination.setList(this.displayList);
        }
    }

    clearSearch() {
        const searchBar = this.template.querySelector('c-base-search-bar');
        if (searchBar) searchBar.clear();
    }

    clearTableSelections() {
        if (this.emptyState) return;
        if (this.noRowsSelected) return;
        this.selectedRows = [];
        const table = this.template.querySelector('lightning-datatable');
        if (table) {
            this.template.querySelector('lightning-datatable').selectedRows = [];
        }

        this.noRowsSelected = true;
    }

    /**
     * @decription Populates progress note field value after you press the Add to Selected button
     * - Includes logic to automatically format date & datetime values according to business requirements (implmemented by utils/dateFormatter.js library)
     * @param {*} rowsToAdd The table rows selected for addition to the note
     * @param {*} buttonObj The button that was clicked
     */
    addToNoteField(rowsToAdd, buttonObj) {
        //? get the target field details
        let targetField = this.template.querySelector(`lightning-input-field[data-field-name=${buttonObj.field}]`);

        //? format each of the selected rows & then add them to the
        let fieldHeader = buttonObj.preTextHeader.slice(0, -2);
        let theFullString = fieldHeader;
        const lineSeparator = ' \n';

        let selectedData = '';
        rowsToAdd.forEach((row) => {
            const includedColumns = this.columns.filter((column) => column.exclude !== true); // Removes the Med/Supply column from being added to the note
            let valueStringBody = includedColumns
                .map((column) => {
                    const {
                        type,
                        fieldName,
                        isDateTime = type === dateFormatter.DATE,
                        isDateOnly = type === dateFormatter.DATE_LOCAL
                    } = column;
                    let fieldToCheck =
                        (fieldName === this.options?.initialSort?.field
                            ? this.options.initialSort.stringField
                            : fieldName) ?? fieldName;
                    //for a date column, return a formatted date, otherwise return the verbatim row value found at either column.fieldName or options.initialSort.stringField
                    return (
                        (isDateTime
                            ? dateFormatter.salesForceDateTimeStringToMMDDYYYYHHMM(row[fieldName])
                            : isDateOnly
                              ? dateFormatter.formatDateTimeStringToMMDDYYYY(row[fieldName])
                              : row[fieldToCheck]) ?? ''
                    );
                })
                .join(' - ');
            let valueString = lineSeparator + valueStringBody + lineSeparator;
            selectedData += valueString;
        });
        //? remove the last new line
        selectedData = selectedData.slice(0, -1);
        //? checking if the header is already in the value
        let isHeaderPresent = this.checkFieldForHeader(targetField.value, fieldHeader);
        //? clears only if the field is null. DOES NOT handle previously entered but not formatted to match current header values
        /*
            Example: If the previous value's header in the field was:
                Name - Description - Status
            but the new header is:
                Name - Date - Description
            then the new header will be added to the existing field values
        */
        if (targetField.value === null) targetField.value = '';

        //? check the length of the proposed new field value against the max length the field allows
        //? if the length exceeds, do not update the field, instead throw error until changes are made
        let maxLength = this.objectInfo.data.fields[buttonObj.field].length;
        let proposedNewValue = targetField.value;
        proposedNewValue += isHeaderPresent ? '\n' + selectedData : theFullString + selectedData;
        if (proposedNewValue.length >= maxLength) {
            targetField.classList.add('slds-has-error');
            this.addingSelectedError = true;
        } else {
            this.deactivateSubmitButton(false);
            targetField.value = proposedNewValue;
        }
    }

    handleOnChange() {
        this.resetErrorState();
        this.deactivateSubmitButton(false);
    }

    handleKeyPressInField(event) {
        this.resetErrorState();
        let fieldName = event.currentTarget.getAttribute('data-field-name');
        let maxLength = this.objectInfo.data.fields[fieldName].length;
        let targetField = this.template.querySelector(`lightning-input-field[data-field-name=${fieldName}]`);
        if (targetField.value == null) return;
        if (targetField.value.length >= maxLength) {
            targetField.classList.add('slds-has-error');
            this.inputError = true;
        }
    }

    deactivateSubmitButton(boolean) {
        //? LMC the submit button should be activated

        const payload = { deactivateButton: boolean, buttonLabel: this.buttonLabel };
        this.dispatchEvent(new CustomEvent('addtonoteselected', { bubbles: true, composed: true, detail: boolean }));
        publish(this.messageContext, baseAddToNoteMC, payload);
    }

    checkFieldForHeader(targetFieldvalue, fieldHeader) {
        if (targetFieldvalue === null) return false;
        return targetFieldvalue.includes(fieldHeader);
    }
}
