import { LightningElement, api, wire } from 'lwc';
import { uniqueId, inBothArrays } from 'c/helpersLWC';
import { allFutureRenewalOptions, renewalSettings } from './constants';
import { sortList, getColumn } from './vccMedsFutureRenewalRequestHelper';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import CASE_Object from '@salesforce/schema/Case';
import PN_Object from '@salesforce/schema/VCC_Progress_Note__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { publish, MessageContext } from 'lightning/messageService';
import baseAddToNoteMC from '@salesforce/messageChannel/vccBaseAddToNote__c';
import * as h from 'c/helpersLWC';

//? connection errors are caught on the parent component
import noResultsMessage from '@salesforce/label/c.VCC_Generic_message_for_null_search_results';
import noResultsSubMessage from '@salesforce/label/c.VCC_Generic_sub_message_for_null_search_results';
import entryTooLong from '@salesforce/label/c.VCC_Entry_is_too_long_error';
import entryReachedMax from '@salesforce/label/c.VCC_Entry_reached_max_error';
import notFutureDate from '@salesforce/label/c.VCC_Date_Not_In_Future';

import getAccountName from '@salesforce/apex/VCC_MedsListController.getAccountInfo';
import handleFutureRenewalTaskCreation from '@salesforce/apex/VCC_FutureRenewalController.handleFutureRenewalTaskCreation';

import { loadStyle } from 'lightning/platformResourceLoader';
import staticCustomCSS from '@salesforce/resourceUrl/VCC_MedsFutureRenewalCustomCSS';

export default class vccMedsFutureRenewalRequest extends LightningElement {
    @api incomingRecordId;
    @api pageSize;
    @api size;
    @api currentObject;

    options = allFutureRenewalOptions;
    _options = {};
    settings = renewalSettings;
    selectedMedications = {};
    existingMedValue = '';
    buttonLabel = 'Submit';
    accountInfo;
    fullName;
    birthDate;
    groupedSlimmedList = [];
    selectedDate;
    flattenedGroupedFacilitiesObj = {};
    facilityLengthMap = new Map();

    allSelectedRowsSet = new Set();
    allSelectedRows = []; //? holds all selections (additive)
    uniqueSelectedRows = [];

    formLoading = true;
    noRowsSelected = true;
    addingSelectedError = false;
    notFutureDateError = false;
    emptyState = false;
    noIncomingData = false;

    displayList;
    tableData;
    sortDirection;
    sortedBy;
    _list; //? unchanging property
    todayPlusOne;
    dateHasError = false;

    selectedRows = [];
    fieldsUsedInFrame = [];
    searchResults = [];
    baseFilterResults = [];
    uniqueIdProperty = 'frrId';

    tableDetails = {
        total: 0,
        sortedBy: 'Date' //? defaulting to date
    };

    labels = {
        noResultsMessage: noResultsMessage,
        noResultsSubMessage: noResultsSubMessage,
        entryTooLong: entryTooLong,
        entryReachedMax: entryReachedMax,
        notFutureDate: notFutureDate
    };

    get medsFilterOptions() {
        return [
            { label: 'All Active VA Meds', value: 'ALL' },
            { label: 'Active', value: 'ACTIVE' },
            { label: 'Pending', value: 'PENDING' },
            { label: 'Suspended', value: 'SUSPENDED' }
        ];
    }

    /**
     * @description Combines the frozen and dynamic columns.  This is used when only a single datatable displays the data.
     *              We recently added an option to display the data with 2 separate datatables. The reason for that, it allows us
     *              to "freeze" the first column of the table (in reality, the first column is its own table).
     */
    get columns() {
        return [...this.frozenColumns, ...this.dynamicColumns];
    }

    @wire(getObjectInfo, { objectApiName: CASE_Object })
    objectInfo;

    @wire(getObjectInfo, { objectApiName: PN_Object })
    objectInfoPN;

    @wire(MessageContext)
    messageContext;

    @wire(getAccountName, { caseId: '$incomingRecordId' })
    getAccountInfo({ error, data }) {
        if (data) {
            this.accountInfo = data;
            this.fullName = this.generateFullName(data);
            this.birthDate = this.accountInfo.HealthCloudGA__BirthDate__pc;
        } else if (error) {
            // Handle error somehow
        }
    }

    generateFullName(Account) {
        // Combine FirstName, MiddleName, and LastName to create the full name
        let fullName = '';
        if (Account.FirstName) {
            fullName += Account.FirstName + ' ';
        }
        if (Account.MiddleName) {
            fullName += Account.MiddleName + ' ';
        }
        if (Account.LastName) {
            fullName += Account.LastName;
        }
        return fullName.trim();
    }

    /* LIFECYCLE METHODS */

    /**
     * @description populates class variables, calls loadStyle for custom CSS
     */
    connectedCallback() {
        loadStyle(this, staticCustomCSS);

        this.labels.noResultsMessage = noResultsMessage.replace('{0}', this.settings.title);

        this._options = {
            topButtons: this.options.topButtons,
            initialSort: this.options.initialSort,
            medsFilterField: this.options.medsFilterField
        };
        this.displayMedsFilter = this.options.medsFilterField?.label !== undefined;
        this.frozenColumns = this.options.frozenColumns;
        this.dynamicColumns = this.options.dynamicColumns;

        const todaysDate = new Date();
        this.todayPlusOne = new Date(todaysDate);
        this.todayPlusOne.setDate(this.todayPlusOne.getDate() + 1);
        this.todayPlusOne = this.todayPlusOne.toISOString().split('T')[0].toString();
    }

    renderedCallback() {
        const pagination = this.template.querySelector('c-base-pagination');
        if (pagination) this.tableDetails.total = pagination.totalRecords();
    }

    /* HANDLERS */

    handleClearText(resetError = true) {
        this.facilityLengthMap.clear();
        let clearField = this.refs.requestTextArea;
        clearField.value = '';
        this.uniqueSelectedRows = [];
        this.allSelectedRowsSet.clear();
        this.allSelectedRows = [];
        this.deactivateSubmitButton(true);
        if (resetError) this.resetErrorState('text');
    }

    handleLoad() {
        this.formLoading = false;
        if (this.noIncomingData) return;
        this.reset();
        this.deactivateSubmitButton(true);
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

    handleSort(event) {
        let { fieldName, sortDirection } = event.detail;
        const column = getColumn(this.columns, fieldName);

        //? if column is a button or "clickable link" use the typeAttributes.type property to sort else use regular type on the root object
        if (column.type === 'button') {
            this.displayList = sortList(
                [...this.displayList],
                { propertyName: fieldName, type: column.typeAttributes.type },
                sortDirection
            );
        } else {
            this.displayList = sortList(
                [...this.displayList],
                { propertyName: fieldName, type: column.type },
                sortDirection
            );
        }

        this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        this.sortedBy = fieldName;
        this.tableDetails.sortedBy = column.label;
        // this.setRecords(this.displayList);
        this.setPagination();
    }

    /**
     * @description Handles the click event for the Refill button. Sends event to parent LWC.
     * @param {`object`} event Expecting an event from lightning-datatable or c-fixed-column-datatable
     */
    handleRowSelection(event) {
        this.noRowsSelected = event.detail.selectedRows.length === 0 ? true : false;
        this.resetErrorState();
    }

    /**
     * @description puts the selected data in the corresponding field based on the options object sent in to this component
     * @param {`object`} event Expecting an event from the add selected button
     */
    handleAddSelected(event) {
        const label = JSON.parse(JSON.stringify(event.target.label));
        let datatable = this.template.querySelector('c-fixed-column-datatable');
        let selectedRowData = datatable?.getSelectedRows();
        this.allSelectedRows = [...selectedRowData, ...this.uniqueSelectedRows];
        this.uniqueSelectedRows = h.uniqueVals(this.allSelectedRows, this.uniqueIdProperty);
        this.facilityLengthMap.clear();
        this.resetErrorState();
        this.addSelectionsToField(this.uniqueSelectedRows, this.getDetailsFromButtonLabel(label));
    }

    handleOnFocus() {
        this.deactivateSubmitButton(true);
        this.resetErrorState('date');
    }

    handleOnChange(event) {
        if (event.target.value === '' || event.target.value === null) return;

        let dateField = this.refs.requestDateInput;
        //? if the date is in the future
        if (this.checkForFutureDate(dateField)) {
            this.dateHasError = false;
            if (this.checkInputValues()) {
                this.deactivateSubmitButton(false);
            } else {
                this.deactivateSubmitButton(true);
            }
            this.resetErrorState('date');
        } else {
            // dateField.value = "";
            this.dateHasError = true;
            this.deactivateSubmitButton(true);
            // this.addErrorToDate(dateField);
        }
    }

    /* METHODS */

    //? checking to see if these input fields have values and will turn on the submit button if they do
    checkInputValues() {
        if (this.dateHasError) return false;

        let textField = this.refs.requestTextArea;
        let textFieldBoolean = !!textField.value;

        let dateField = this.refs.requestDateInput;
        let dateFieldBoolean = !!dateField.value;

        //? true = values are good
        return textFieldBoolean && dateFieldBoolean;
    }

    checkForFutureDate(targetField) {
        if (targetField === '' || targetField === null) return false;

        //? get today's date
        const todaysDate = new Date();
        this.selectedDate = new Date(targetField.value);
        if (this.selectedDate <= todaysDate) {
            this.deactivateSubmitButton(true);
            // this.addErrorToDate(targetField);
            return false; //? the date isn't in the future
        }
        return true;
    }

    addErrorToDate(targetField) {
        targetField.classList.add('slds-has-error');
        this.notFutureDateError = true;
    }

    resetErrorState(resetOnly = null) {
        if (resetOnly === 'text' || resetOnly === null) {
            this.addingSelectedError = false;
            let textField = this.refs.requestTextArea;
            if (textField) textField.classList.remove('slds-has-error');
        }
        if (resetOnly === 'date' || resetOnly === null) {
            this.notFutureDateError = false;
            let dateField = this.refs.requestDateInput;
            if (dateField) dateField.classList.remove('slds-has-error');
        }
    }

    buildListOfFieldsUsed() {
        this._options.topButtons.forEach((elem) => this.fieldsUsedInFrame.push(elem.field));
    }

    @api
    buttonPressed() {
        Object.keys(this.groupedSlimmedList).forEach((key) => {
            this.flattenedGroupedFacilitiesObj[key] = JSON.stringify(this.groupedSlimmedList[key]);
        });
        this.formLoading = true;
        this.deactivateSubmitButton(true);
        this.createTasks(this.incomingRecordId, this.flattenedGroupedFacilitiesObj, this.selectedDate);
    }

    async createTasks(id, obj, date) {
        try {
            let result = await handleFutureRenewalTaskCreation({
                recordId: id,
                medicationRenewalsByFacilityMap: obj,
                renewalDate: date
            });
            let successTitle = 'Successful Task Creation';
            let successMessage = `${result.length} Task${result.length === 1 ? '' : 's'}  added to the VAHC Pharmacy Queue`;
            this.formLoading = false;
            this.showToast(successTitle, successMessage, 'success', 'sticky');
            this.close();
        } catch (err) {
            let errorTitle = 'Error';
            let errorMessage =
                'An error has occurred when creating a task. If the problem persists, please contact the Help Desk.';
            this.formLoading = false;
            this.nebulaLogger(err);
            this.showToast(errorTitle, errorMessage, 'error', 'sticky');
        }
    }

    nebulaLogger(incomingError) {
        const logger = this.template.querySelector('c-logger');
        if (!logger) return;
        logger.error(JSON.stringify(incomingError));
        logger.saveLog();
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

    close(event) {
        const evt = new CustomEvent('closemodal', {
            detail: event?.detail?.row,
            composed: true,
            cancelable: false,
            bubbles: true
        });
        this.dispatchEvent(evt);
    }

    //? get the field that needs to be used for the addSelectionsToField method
    getDetailsFromButtonLabel(label) {
        let buttonObj = this._options.topButtons.filter((elem) => elem.label === label);
        return buttonObj[0];
    }

    reset() {
        this.clearSearch();
        this.clearTableSelections();
        let medsFilter = this.template.querySelector('.medsFilter');
        if (medsFilter) this.value = null;
        this.emptyState = false;
        this.searchResults = this._list;
        this.baseFilterResults = this._list;
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
            pagination.setList(this.displayList);
        }
    }

    clearSearch() {
        const searchBar = this.template.querySelector('c-base-search-bar');
        if (searchBar) searchBar.clear();
    }

    clearTableSelections() {
        if (this.emptyState) return;
        if (this.noRowsSelected) return;
        if (this.template.querySelector('c-fixed-column-datatable') != null) {
            this.template.querySelector('c-fixed-column-datatable').selectedRows = [];
        }
        this.noRowsSelected = true;
    }

    //? build out the field value after you press the Add to Selected button
    /*eslint-disable array-callback-return*/
    addSelectionsToField(rowsToAdd, buttonObj) {
        //? get the target field details
        let targetField = this.refs.requestTextArea;

        //? format each selected row, concatentate into - separated strings and add them to the add to note text field
        let fieldHeader = buttonObj.preTextHeader.slice(0, -2);

        const lineSeparator = ' \n';

        let selectedData = '';
        let slimmedList = [];
        let slimmedDownProperties = this.columns.map((col) => col.fieldName);
        //? adding the csSchedule property to be sent thru
        slimmedDownProperties.push('csSchedule');

        rowsToAdd.forEach((selectedMed) => {
            let facilityCheck = selectedMed.facilityName;
            let valueString = '';
            let valueStringPart = this.columns
                .map((col) => {
                    // checking to see if the sort field is a string value (ex: DateTimeVal vs DateTimeStringVal)
                    let fieldToCheck =
                        col.fieldName === this._options.initialSort.field
                            ? this._options.initialSort.stringField
                            : col.fieldName;
                    if (Object.hasOwn(selectedMed, fieldToCheck)) {
                        return selectedMed[fieldToCheck] === undefined ? '' : selectedMed[fieldToCheck];
                    }
                    return '';
                })
                .join(' - ');

            slimmedList.push(this.selectSomeProperties(selectedMed, slimmedDownProperties));

            valueString = lineSeparator + valueStringPart + lineSeparator;
            if (!this.facilityLengthMap.get(facilityCheck)) {
                this.facilityLengthMap.set(facilityCheck, fieldHeader + valueString);
            } else {
                this.facilityLengthMap.set(facilityCheck, this.facilityLengthMap.get(facilityCheck) + valueString);
            }
            selectedData += valueString;
        });
        this.groupedSlimmedList = slimmedList.reduce((facilityMedsGroup, medication) => {
            const truncatedFacility = medication?.facilityName?.match(/\d{3}/);
            const facilityId = truncatedFacility ? truncatedFacility[0] : medication.facilityName;
            if (facilityMedsGroup === undefined || facilityMedsGroup === null) {
                facilityMedsGroup = {};
            }
            if (!facilityMedsGroup[facilityId]) {
                facilityMedsGroup[facilityId] = [];
            }
            facilityMedsGroup[facilityId].push(medication);
            return facilityMedsGroup;
        }, {});

        //? remove the last new line
        selectedData = selectedData.slice(0, -1);
        //? reset text box
        targetField.value = '';

        //? check the length of the proposed new field value against the max length the field allows
        //? if the length exceeds, do not update the field, instead throw error until changes are made
        let taskDescriptionLimit = 32000;
        let pnFieldLength = this.objectInfoPN.data.fields?.VCC_Requested_Medication__c?.length; //? Pharm Renewal Field
        let maxLength = pnFieldLength < taskDescriptionLimit ? pnFieldLength : taskDescriptionLimit;

        let proposedNewValue = targetField.value;
        proposedNewValue += fieldHeader + selectedData;
        for (let value of this.facilityLengthMap.values()) {
            value = value.slice(0, -2);
            if (value.length >= maxLength) {
                targetField.classList.add('slds-has-error');
                this.addingSelectedError = true;
                this.handleClearText(false);
            } else {
                targetField.value = proposedNewValue;
                if (this.checkInputValues()) {
                    this.deactivateSubmitButton(false);
                } else {
                    this.deactivateSubmitButton(true);
                }
            }
        }
    }

    //? used to slim down an object to only hold those in an array of specific properties
    selectSomeProperties(incomingObj, specificProperties) {
        return Object.keys(incomingObj).reduce(function (obj, k) {
            if (specificProperties.includes(k)) {
                obj[k] = incomingObj[k];
            }
            return obj;
        }, {});
    }

    deactivateSubmitButton(boolean) {
        //? LMC the submit button should be activated
        const payload = { deactivateButton: boolean, buttonLabel: this.buttonLabel };
        publish(this.messageContext, baseAddToNoteMC, payload);
    }
}
