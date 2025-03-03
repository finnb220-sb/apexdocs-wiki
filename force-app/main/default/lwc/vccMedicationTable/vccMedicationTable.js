import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { uniqueId, inBothArrays } from 'c/helpersLWC';
import noResultsMessage from '@salesforce/label/c.VCC_Generic_message_for_null_search_results';
import noResultsSubMessage from '@salesforce/label/c.VCC_Generic_sub_message_for_null_search_results';
import hasSpecialistPermissions from '@salesforce/customPermission/PC_Specialist';
import nonPharmBadAddressErrorMessage from '@salesforce/label/c.VCC_Bad_Address_Error_Non_Pharmacy';
import pharmBadAddressErrorMessage from '@salesforce/label/c.VCC_Bad_Address_Error_Pharmacy';
import hasPharmI_Permission from '@salesforce/customPermission/VCC_Pharmacy_Tier_I';
import hasPharmII_Permission from '@salesforce/customPermission/VCC_Pharmacy_Tier_II';
import hasPharmIII_Permission from '@salesforce/customPermission/VCC_Pharmacy_Tier_III';

export default class VccMedicationTable extends LightningElement {
    @api usersVistAs;
    @api frozenColumns;
    @api dynamicColumns;
    @api tableData;

    @api
    set medsList(val) {
        if (val?.length) {
            this._medsList = this.addUniqueIdToData(val);
            this.searchResults = this._medsList;
            this.baseFilterResults = this._medsList;
            this.displayList = this._medsList;
            //updating setDisplayList values in setter so that when a Pharm user changes meds duration the correct number of meds is displayed
            this.setDisplayList(this._medsList);
            this.state = { tempList: this.displayList, recordCount: this.displayList.length };
            this.updateState({ recordCount: this.displayList.length });
        } else {
            this.noResults = true;
        }
    }

    get medsList() {
        return this._medsList;
    }

    @api
    set isVaMeds(value) {
        if (value) {
            this._isVaMeds = true;
            this.tableDetails.sortedBy = 'Status & Expiration Date';
        } else {
            this._isVaMeds = false;
        }
    }

    get isVaMeds() {
        return this._isVaMeds;
    }

    @api
    set componentOptions(val) {
        if (val?.length && val.every((option) => option.label && option.value)) {
            // checking to make sure every option record has a name and value
            this._componentOptions = val;
        } else {
            // required properties missing
        }
    }

    get componentOptions() {
        return this._componentOptions ? this._componentOptions[0] : null; //? only sending in the first option
    }

    @track state = {
        rowCount: 0,
        tempList: []
    };

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

    @api
    set displayMedSupplyFilter(value) {
        if (value) {
            this._displayMedSupplyFilter = true;
        } else {
            this._displayMedSupplyFilter = false;
        }
    }

    get displayMedSupplyFilter() {
        return this._displayMedSupplyFilter;
    }

    _isVaMeds;
    _componentOptions;
    _displayMedSupplyFilter;
    badAddressMessage;

    @api notRefillable;
    @api title;
    @api columns = [];
    @api progressValue;
    @api medsStartDate;
    // @api displayrefillspinner;

    sortedBy;
    tableDetails = {
        total: 0,
        sortedBy: 'Medication Name' //? default for Non-VA Meds
    };
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    @track displayList = [];
    medsListEmpty = true;
    refillButtonDisabled = true;
    selectedRows = [];
    selectedRowData;
    entriesPerPage = 10;

    /** empty state */
    componentTitle = 'Medications';
    noResults = false;
    labels = {
        noResultsMessage: noResultsMessage,
        noResultsSubMessage: noResultsSubMessage
    };

    // drives which inputs are showing above the meds table
    @track
    nav = {
        input: {
            search: true, // defaults to searchbar
            daterange: false,
            filters: false
        }
    };

    searchBarSettings = {
        variant: 'label-hidden'
    };

    /**
     * @description Retrieves Boolean if current User has Specialist Permissions.
     * @returns {isSpecialist} Boolean value if permission exists for the logged in user
     */
    get isSpecialist() {
        return hasSpecialistPermissions;
    }

    @api showFrozenColumns; //show The new Frozen Column table for va meds

    connectedCallback() {
        this.labels.noResultsMessage = noResultsMessage.replace('{0}', this.componentTitle);
        this.tableDetails.total = this.displayList.length;
        // !this.noResults && this.setPagination();
    }

    /** HANDLERS */

    // handleBaseFilter(event) {

    // }

    /**
     * @description Handles the click event for the Refill button. Sends event to parent LWC.
     */
    handleRefillButtonClick() {
        let tmpProgressValue = this.selectedRowData;

        const selectedEvent = new CustomEvent('progressvaluechange', {
            detail: tmpProgressValue
        });
        this.dispatchEvent(selectedEvent);
    }

    //? Function to handle row actions defined in the columns variable. Performs logic based on the name of the action
    handleRowAction(event) {
        //? get row action name
        var action = event.detail.action.name;

        //? if row action = rxDetails, set currentRx to current row and displayCurrentRx to true
        //? to display details in UI on current rx
        if (action === 'rxDetails') {
            this.dispatchDisplayRxDetailsEvent(event.detail.row);
        }

        if (action === 'rxDuplicates') {
            this.dispatchDisplayRxDuplicatesEvent(event.detail.row);
        }
    }

    getColumn(columns, fieldName) {
        return columns.filter((entry) => entry.fieldName === fieldName)[0];
    }

    //? Function to handle sorting of the meds list
    handleSort(event) {
        //? set up sort variables and sort the meds list
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const column = this.getColumn(this.columns, sortedBy);
        const sortData = JSON.parse(JSON.stringify(this.displayList));
        sortData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));

        //? set component variables with results and end values
        this.displayList = [...sortData].map((med, index) => {
            return {
                ...med,
                index: index
            };
        });

        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
        this.tableDetails.sortedBy = column.label;
        this.state = { ...this.state, tempList: this.displayList };
        // this.setPagination();
    }

    //? Will reset the sort on clearing out the search bar.
    resetSort() {
        // handling clear button when no data is returned from "get more records functionality"
        // calling dispatching event to parent to do "default callout" then returning

        if (this.noResults) {
            this.dispatchEvent(new CustomEvent('defaultcall', { composed: true }));
            return;
        }

        let payload = {
            detail: {
                fieldName: 'expiresValue',
                sortDirection: 'desc'
            }
        };
        this.handleSort(payload);
        this.handleClearInputClick();
    }

    //? Will clear out search bar. Replace with pagination setup.
    handleClearInputClick() {
        //? Clear Inputs
        this.noResults = false;
        const searchbar = this.template.querySelector('c-base-search-bar');
        if (searchbar) {
            searchbar.clear();
        }

        this.setNavInput('search');
    }

    /**
     * @description Function to handle row selection, blocking selection of rows that are not allowed for refill. Displays a warning toast message for refills that are blocked.
     */
    handleRowSelection(event) {
        let enableRefillButton = false;
        const rowIdSet = new Set();
        const ACTIVE_STATUS = 'ACTIVE'.toLowerCase();
        const FACILITY_ID_PLACEHOLDER = '{1}';

        this.selectedRows = event?.detail?.selectedRows?.map((row) => {
            let rtnId;
            let activeStatus = row.vaStatusValue?.toLowerCase() === ACTIVE_STATUS;
            let isAvailableFacilities = this.usersVistAs.some((vistAs) => row.facilityName.includes(vistAs));
            let hasBadAddressIndicator = row.badAddressIndicator || row.mailStatusIndicator;
            let rxHasRefillsRemaining = false;
            if (typeof row?.fillsRemainingValue != 'undefined') {
                rxHasRefillsRemaining = parseInt(row.fillsRemainingValue, 10) > 0;
            }
            let rowCanSelect =
                activeStatus && rxHasRefillsRemaining && isAvailableFacilities && !hasBadAddressIndicator;

            this.badAddressMessage =
                hasPharmI_Permission || hasPharmII_Permission || hasPharmIII_Permission
                    ? pharmBadAddressErrorMessage.replace(FACILITY_ID_PLACEHOLDER, row.facilityId)
                    : nonPharmBadAddressErrorMessage.replace(FACILITY_ID_PLACEHOLDER, row.facilityId);

            if (!activeStatus) {
                /// dispatch event refill not allowed
                this.dispatchEventRefillNotAllowed(row);
                return rtnId; // Exit after showing the toast
            }

            if (!rxHasRefillsRemaining) {
                /// dispatch event no refills
                this.dispatchEventNoRefills();
                return rtnId; // Exit after showing the toast
            }

            if (!isAvailableFacilities) {
                this.flagForUnavailableFacilities(row);
                return rtnId; // Exit after showing the toast
            }

            if (hasBadAddressIndicator) {
                this.dispatchEventBadAddress();
                return rtnId; // Exit after showing the toast
            }

            if (rowCanSelect) {
                /// mark available for refills
                rtnId = row.id;
                rowIdSet.add(row.id);
                enableRefillButton = true;
            }
            /// end check for available refills on active rx's
            return rtnId;
        });

        //? toggle refill button based on allowedRows count
        this.refillButtonDisabled = !enableRefillButton;

        /// this returns only those Rx's that are in the set of selected rows and who are active and have refills.
        this.selectedRowData = event.detail.selectedRows.filter((row) => {
            return rowIdSet.has(row.id);
        });
    }
    /**
     * @description Dispatch a toast event on rx's where there is a Bad Address or Mail Status Indicator.
     */
    dispatchEventBadAddress() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Refill not allowed',
                message: this.badAddressMessage,
                variant: 'Warning',
                mode: 'sticky'
            })
        );
    }
    /**
     * @description Method DRY's (Don't Repeat Yourself) up the process to dispatch a toast event on rx's where refills are not allowed.
     */
    dispatchEventRefillNotAllowed(row) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Refill not allowed',
                message: row.vaStatusValue,
                variant: 'Warning',
                mode: 'sticky'
            })
        );
    }
    /**
     * @description method DRYs (Don't Repeat Yourself) up process to dispatch toast event when no refills remain for Rx.
     */
    dispatchEventNoRefills() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Refill not allowed',
                message: 'No refills remaining',
                variant: 'Warning',
                mode: 'sticky'
            })
        );
    }
    /**
     * @description method DRYs (Don't Repeat Yourself) up process to dispatch toast event when facility is unavailable.
     */
    flagForUnavailableFacilities(row) {
        if (!this.usersVistAs.some((vistAs) => row.facilityName.includes(vistAs))) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Refill not allowed',
                    message: `This medication is located at an Unavailable Facility. Please transfer to Pharmacy services at ${row.facilityName}`,
                    variant: 'Warning',
                    mode: 'sticky'
                })
            );
        }
    }

    handleDefaultOrder() {
        const evt = new CustomEvent('defaultsort', { bubbles: true, cancelable: false });
        this.dispatchEvent(evt);
    }

    clearSearch() {
        const searchBar = this.template.querySelector('c-base-search-bar');
        if (this.nav.input.search && searchBar) {
            searchBar.clear();
            this.setDisplayList(this._medsList);
            this.tableDetails.sortedBy = this.isVaMeds ? 'Status & Expiration Date' : 'Medication Name';
        }

        if (this.nav.input.daterange) this.resetSort();

        this.searchResults = this._medsList;
        this.baseFilterResults = this._medsList;
        this.medSupplyFilterValue = null;
    }

    searchResults = [];
    baseFilterResults = [];
    uniqueIdProperty = 'addToNoteId';

    async handleSearch(event) {
        const results = JSON.parse(event.detail) || null;
        const baseSearchBar = this.template.querySelector('c-base-search-bar');

        // handle clearing
        if (!baseSearchBar.inputLength()) {
            this.noResults = false;
            // this.setDisplayList(this._medsList);
            this.searchResults = this._medsList;
            this.setRecords();
            return;
        }

        if (results?.length) {
            this.noResults = false;
            this.searchResults = results;
            this.setRecords();
            // this.setDisplayList();
        } else {
            this.noResults = true;
        }
    }

    setDisplayList(array) {
        // array = JSON.parse(array);
        this.displayList = [...array].map((med, index) => {
            return {
                ...med,
                index: index
            };
        });
        this.state.tempList = this.displayList;

        this.updateState({ recordCount: this.displayList.length });

        // this.setPagination();
        //? put these here since setPagination was removed from use
        this.noResults = false;
        this.tableDetails.total = this.displayList.length;
        // return this.displayList?.length || 0;
    }

    setRecords() {
        let filteredResults = this._medsList;
        //? if the searchResults is less than the full list then find inBothArrays
        if (this.searchResults.length < this._medsList.length) {
            filteredResults = inBothArrays(this.searchResults, filteredResults, this.uniqueIdProperty);
        }
        //? if the baseFilterResults is less than the full list then find inBothArrays
        if (this.baseFilterResults.length < this._medsList.length) {
            filteredResults = inBothArrays(this.baseFilterResults, filteredResults, this.uniqueIdProperty);
        }

        this.setDisplayList(filteredResults);
    }

    get medSupplyFilterOptions() {
        return [
            { label: 'ALL', value: 'ALL' },
            { label: 'MEDICATIONS', value: 'Medication' },
            { label: 'SUPPLIES', value: 'Supply' }
        ];
    }

    handleMedSupplyFilter(event) {
        let filterForArray = [];
        if (event.detail.value === 'ALL') {
            filterForArray.push('Medication', 'Supply');
        } else {
            filterForArray.push(event.detail.value);
        }
        this.medSupplyFilterValue = event.detail.value;
        const filteredList = this._medsList.filter((el) => filterForArray.includes(el?.medicationSupply));
        // this.clearTableSelections();
        // TODO this.clearSearch();

        if (filteredList.length) {
            this.noResults = false;
            this.baseFilterResults = filteredList;
            this.setRecords();
        } else {
            this.noResults = true;
        }
    }

    tableDisplayList = [];
    handlePageChange(event) {
        this.tableDetails.total = this.displayList.length;
        this.tableDisplayList = event.detail;
        // this.displayList = event.detail;
    }

    /** METHODS */

    dispatchDisplayRxDetailsEvent(rowFullData) {
        let displayRxDetailsEvent = new CustomEvent('displayrxdetails', { detail: { rx: rowFullData } });
        this.dispatchEvent(displayRxDetailsEvent);
    }

    dispatchDisplayRxDuplicatesEvent(rowFullData) {
        let displayRxDuplicatesEvent = new CustomEvent('displayrxduplicates', { detail: { rx: rowFullData } });
        this.dispatchEvent(displayRxDuplicatesEvent);
    }

    dispatchRefillEvent() {
        let refillEvent = new CustomEvent('refill', {
            detail: {
                selectedRowsData: this.selectedRows // todo : replace null with selected rows
            }
        });
        this.dispatchEvent(refillEvent);
    }

    /*
        Function to handle sorting of multi-dimensional array. Checks if the field value
        is numeric and sorts as a number if so, otherwise sorts as text.            

        @param field    A string with the key name to access for sorting
        @param reverse  A number (+1/-1) to control whether to sort in ascending or descending order
    */
    sortBy(field, reverse) {
        return function (a, b) {
            let parser = (v) => v;
            let a1 = parser(a[field]),
                b1 = parser(b[field]);
            let r1 = a1 < b1,
                r2 = a1 === b1;
            return r2 ? 0 : r1 ? -reverse : reverse;
        };
    }
    //Follow this framework for clearing out the input on searchbar.
    setPagination() {
        this.noResults = false;

        const pagination = this.template.querySelector('c-base-pagination');
        if (pagination) {
            pagination.setList(this.displayList);
        }
    }

    //? used when only Add to Note button is shown
    handleAddToNoteClick() {
        this.dispatchEvent(new CustomEvent('addtonote', { composed: true }));
    }

    //? used when component options has multiple
    handleOptionSelect(event) {
        const optionChosen = event?.target?.value; // data attribute on single lightning button
        this.dispatchEvent(new CustomEvent(optionChosen, { composed: true })); // if option chosen is truthy dispatch it as an event
    }

    @api
    setNavInput(input) {
        const navInputKeys = Object.keys(this.nav.input);

        if (navInputKeys.includes(input)) {
            for (const key of navInputKeys) {
                this.nav.input[key] = key === input;
            }
        }
    }

    handleRequestMoreData() {
        const loadMoreRecsDateVal = this.template.querySelector("[data-id='meds-date']")?.value;

        if (loadMoreRecsDateVal) {
            this.dispatchEvent(
                new CustomEvent('requestmoredata', {
                    detail: {
                        value: { start: loadMoreRecsDateVal, end: null }
                    },
                    composed: true
                })
            );
        }
    }

    @api paginateModal(instruction, index) {
        if (!instruction) {
            return;
        }

        switch (instruction) {
            case 'Next':
                if (index < this.state.tempList.length - 1) {
                    this.dispatchDisplayRxDetailsEvent(this.state.tempList[index + 1]);
                }
                break;

            case 'Previous':
                if (index > 0) {
                    this.dispatchDisplayRxDetailsEvent(this.state.tempList[index - 1]);
                }
                break;

            case 'First':
                this.dispatchDisplayRxDetailsEvent(this.state.tempList[0]);
                break;

            case 'Last':
                this.dispatchDisplayRxDetailsEvent(this.state.tempList[this.state.tempList.length - 1]);
                break;

            default:
            // do nothing
        }
    }
    // updating global state management
    //! TODO: CREATE SCHEMA FOR A GLOBAL STATE VARIABLE

    updateState(stateObject) {
        this.dispatchEvent(
            new CustomEvent('updatestate', { composed: true, bubbles: true, detail: { value: stateObject } })
        );
    }

    // TODO: make this accept arguments and return a tailored JSON instead of whole payload
    @api getState() {
        return {
            displayList: this.state.tempList,
            tableData: this.tableData,
            tableDetails: this.tableDetails
        };
    }
}
