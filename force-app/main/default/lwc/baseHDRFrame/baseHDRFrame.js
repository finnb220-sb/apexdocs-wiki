import { LightningElement, api, track } from 'lwc';
import { datatableHelper } from 'c/utils';
import noResultsMessage from '@salesforce/label/c.VCC_Generic_message_for_null_search_results';
import noResultsSubMessage from '@salesforce/label/c.VCC_Generic_sub_message_for_null_search_results';
import genericError from '@salesforce/label/c.VCC_Generic_Error';
import genericSubError from '@salesforce/label/c.VCC_Generic_Sub_error';
import getSettings from '@salesforce/apex/VCC_WorkstreamSettingsController.getSettings';

// TODO: Group handlers and members

export default class BaseHDRFrame extends LightningElement {
    //? api properties
    @track _actionsComponent;
    /**
     * @description Dynamically creates an lwc component in the actions slot of this frame component
     * @param value - an object containing the name of the component to render and the properties to pass to the component
     */
    @api
    set actionsComponent(value) {
        try {
            import(value.name).then((cmp) => {
                this._actionsComponent = { ...value, cmp: cmp.default };
            });
        } catch (error) {
            this.logger(`Error importing component: ${error}`);
        }
    }

    /**
     * @description getter for a rendered body component
     */
    get actionsComponent() {
        return this._actionsComponent;
    }

    @api
    set dateRangeField(value) {
        if (value) {
            this._dateRangeField = value;
            this.requiredProperties.dateRangeField = true;
        }
    }

    get dateRangeField() {
        return this._dateRangeField;
    }

    @api
    set settings(value) {
        if (value?.icon && value?.title) {
            this._settings = { ...value };
            this.initialSortedBy = value.sortedBylabel ? value.sortedBylabel : 'Date';
            this.tableDetails.sortedBy = this.initialSortedBy;
            this.requiredProperties.settings = true;
        } else {
            this._settings = { icon: null, title: null };
        }
    }

    get settings() {
        return this._settings;
    }

    @api
    set list(value) {
        let recordCount = value?.length;
        if (recordCount) {
            this._list = value;
            this.displayList = this._list;
            this.tableDetails.total = recordCount;
            this.requiredProperties.list = true;
        } else {
            this.emptyState = true;
        }
    }

    get list() {
        return this._list;
    }

    @api
    set columns(value) {
        if (value?.length) {
            this._columns = value;
            this.requiredProperties.columns = true;
        }
    }

    get columns() {
        return this._columns;
    }

    @api
    set size(value) {
        if (value) {
            this._size = value;
            this.requiredProperties.size = true;
        }
    }

    get size() {
        return this._size;
    }

    @api
    set currentObject(value) {
        if (value) {
            this._currentObject = value;
            this.requiredProperties.currentObject = true;
        }
    }

    get currentObject() {
        return this._currentObject;
    }

    @api hdrMessage;

    @api
    set hideHdrDetails(val) {
        this._hideHdrDetails = val;
    }

    get hideHdrDetails() {
        return this._hideHdrDetails;
    }

    @api wrapTextMaxLinesCount = '1';

    //? Other variables
    @track displayList;
    @track tableData;
    initialSortedBy;

    emptyState = false;
    _sortDirection;
    /**
     * @deprecated Use `sortedDirection` property instead.
     * @return {*} Returns value of this._sortDirection
     */
    get sortDirection() {
        return this._sortDirection;
    }
    @api set sortDirection(value) {
        this._sortDirection = value;
    }

    /**
     * @description Overloading a public property because we should be using "sortedDirection" but previously used "sortDirection"
     * - Existing parent LWCs may be passing a value to "sortDirection", but want to expose this property for future use.
     * - LWCs composing this component should pass a value to sorted-direction. But both 'sort-direction' and 'sorted-direction' will have the same effect
     * @return {*} Returns value of this._sortDirection
     */
    get sortedDirection() {
        return this._sortDirection;
    }
    @api set sortedDirection(value) {
        this._sortDirection = value;
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
     * @return `String` the label of the column whose fieldName matches this.sortedBy
     */
    get tableDetailsSortedByLabel() {
        return datatableHelper.getColumn(this.columns, this.sortedBy)?.label;
    }
    _dateRangeField;
    _settings;
    _list;
    _columns;
    _size;
    _currentObject;
    dataSettings = {};

    //? Property based checking
    requiredProperties = {
        dateRangeField: false,
        settings: false,
        list: false,
        columns: false,
        size: false,
        currentObject: false
    };

    //? uses the "every" array method to check if every required property is set to true
    validate() {
        return Object.values(this.requiredProperties).every((property) => property === true);
    }

    //? chains the entries, filter and map array methods to grab all required properties that are missing
    //? then throws an error indicating which required fields are missing or invalid using a template literal
    throwRequiredFieldsError() {
        const emptyFields = Object.entries(this.requiredProperties)
            .filter((entryArray) => entryArray[1] === false)
            .map((badProperty) => badProperty[0]);
        throw new Error(`Error: The following required properties are missing or invalid: [${emptyFields}]`); // template literal
    }
    //? -----------------------

    @track
    tableDetails = {
        total: 0
    };

    labels = {
        noResultsMessage: noResultsMessage,
        noResultsSubMessage: noResultsSubMessage,
        noConnectionMessage: genericError,
        noConnectionSubMessage: genericSubError
    };

    async connectedCallback() {
        let replaceString = this._settings?.title ? this._settings.title : '';
        this.labels.noResultsMessage = noResultsMessage.replace('{0}', replaceString);
        this.labels.noConnectionMessage = genericError.replace('{0}', 'Connection Error');
        this.dataSettings = await getSettings({ dataType: 'labs' });
    }

    handleSearch(event) {
        const searchResults = JSON.parse(event.detail) || null;
        const baseSearchBar = this.template.querySelector('c-base-search-bar');

        // handle clearing
        if (!baseSearchBar.inputLength()) {
            this.emptyState = false;
            this.setRecords(this._list);
            return;
        }

        if (searchResults?.length) {
            this.emptyState = false;
            this.setRecords(searchResults);
        } else {
            this.emptyState = true;
        }
    }

    handleBaseDateRange(event) {
        const baseDateRange = this.template.querySelector('c-base-date-range');
        const filteredList = event.detail;

        this.clearSearch();

        if (filteredList.length) {
            this.emptyState = false;
            this.setRecords(event.detail);
        } else {
            this.emptyState = true;
        }
        // if the user clears out the inputs
        if (baseDateRange.inputsAreBlank()) {
            this.emptyState = false;
            this.setRecords(this._list);
        }
    }

    reset() {
        this.emptyState = false;
        this.setRecords(this._list);
    }
    /**
     * @description Method to sort columns of lightning-datatable of this component
     * @param event dispatched when sort buttons are clicked
     */
    handleSort(event) {
        let { fieldName, sortDirection } = event?.detail ?? {};
        this.setRecords(this.sortData(this.displayList, fieldName, sortDirection));
    }

    /**
     * @description Use this function to sort given HDR data array by the provided fieldName, in the provided sort direction
     * - Calls utils\datatableHelper.sortHDRData() function.
     * @see utils\datatableHelper.js
     * @param data `Object[]` - the array of table data (JSON objects)
     * @param fieldName `String` - The field by which to sort. This should be a fieldName used by a column in the datatable.
     * @param sortDirection `String` - the direction to sort in, either "asc" or "desc"
     * @return {*} `Object[]` the sorted data
     */
    @api sortData(data, fieldName, sortDirection) {
        this._sortDirection = sortDirection;
        this._sortedBy = fieldName;
        const column = datatableHelper.getColumn(this.columns, fieldName);
        return datatableHelper.sortHDRData(data ?? [], column, sortDirection);
    }

    handleRowSelected(event) {
        let row = Object.assign({}, event?.detail?.row);
        row.actionName = event.detail.action.name;
        let payload = {
            detail: row
        };
        const evt = new CustomEvent('rowselected', payload);
        this.dispatchEvent(evt);
    }

    handleDispatchAddToNoteEvent() {
        this.dispatchEvent(new CustomEvent('addtonote', { bubbles: true, composed: true }));
    }

    handleDispatchReloadEvent() {
        this.dispatchEvent(new CustomEvent('reload', { bubbles: true, composed: true }));
    }

    setRecords(list) {
        this.displayList = list;
        this.dispatchEvent(new CustomEvent('listwassorted', { detail: this.displayList }));
    }

    renderedCallback() {
        if (typeof this?.displayList?.length !== 'number' || this.displayList.length === 0) {
            return;
        }
        this.tableDetails.total = this.displayList?.length;
    }

    // using css to hide pagination for performance
    get paginationState() {
        if (this.emptyState) {
            return 'hide';
        }
        return '';
    }

    clearSearch() {
        this.template.querySelector('c-base-search-bar').clear();
    }

    // TODO: make this accept arguments and return a tailored JSON instead of whole payload
    @api getState() {
        return {
            displayList: this.displayList,
            tableData: this.tableData,
            tableDetails: this.tableDetails
        };
    }

    /**
     * @description Invokes public methods in the actions component, this decouples the dynamically generated component rendered in the actions slot from the parent component
     * @param listOfMethodsToInvoke - an array of objects containing the method name and arguments to pass to the method
     */
    @api
    invokePublicMethodsInActionsComponent(listOfMethodsToInvoke) {
        for (const methodToInvoke of listOfMethodsToInvoke) {
            const { methodName, args } = methodToInvoke;

            try {
                this.refs.actionsComponent[`${methodName}`](...args);
            } catch (error) {
                this.logger(`Error calling method: ${error}`);
            }
        }
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
     * @description called on reload to reset to default sorting values.
     */
    @api resetSortedDefaultValues() {
        this.tableDetails.sortedBy = this.initialSortedBy;
        this._sortDirection = null;
        this._sortedBy = null;
    }
}
