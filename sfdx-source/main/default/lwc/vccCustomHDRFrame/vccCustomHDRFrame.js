import { LightningElement, api, track } from 'lwc';
import { sortList, getColumn } from './vccCustomHDRFrameHelper';
import noResultsMessage from '@salesforce/label/c.VCC_Generic_message_for_null_search_results';
import noResultsSubMessage from '@salesforce/label/c.VCC_Generic_sub_message_for_null_search_results';
import genericError from '@salesforce/label/c.VCC_Generic_Error';
import genericSubError from '@salesforce/label/c.VCC_Generic_Sub_error';
import getSettings from '@salesforce/apex/VCC_WorkstreamSettingsController.getSettings';
// TODO: Group handlers and members

export default class VccCustomHDRFrame extends LightningElement {
    // TODO: turn this into an API property when ready to hookup
    @api columns;
    @api size;
    @api currentObject;
    @api hideAddToNote = false;
    @api showAddToNote;
    @api dateRangeField;
    @api hdrMessage;
    @api yearList;
    @track displayList;
    @track tableData;

    emptyState = false;
    sortDirection;
    sortedBy;
    _list; // unchanging property
    _actionsComponent;
    dataSettings = {};

    @api
    set hideHdrDetails(val) {
        this._hideHdrDetails = val;
    }

    get hideHdrDetails() {
        return this._hideHdrDetails;
    }

    @api
    settings = {
        icon: null,
        title: null
    };

    @track
    tableDetails = {
        total: 0,
        sortedBy: 'Date' // defaulting to date
    };

    labels = {
        noResultsMessage: noResultsMessage,
        noResultsSubMessage: noResultsSubMessage,
        noConnectionMessage: genericError,
        noConnectionSubMessage: genericSubError
    };

    async connectedCallback() {
        let replaceString = this.settings?.title ? this.settings.title : '';
        this.labels.noResultsMessage = noResultsMessage.replace('{0}', replaceString);
        this.labels.noConnectionMessage = genericError.replace('{0}', 'Connection Error');
        this.dataSettings = await getSettings({ dataType: 'labs' });
    }

    // handlePageChange(event) {
    //     this.tableData = event.detail;
    // }

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

    handleSort(event) {
        let { fieldName, sortDirection } = event.detail;
        const column = getColumn(this.columns, fieldName);
        // if column is a button or "clickable link" use the typeAttributes.type property to sort else use regular type on the root object
        if (column.type === 'button') {
            this.displayList = sortList(
                [...this.displayList],
                { propertyName: fieldName, type: column.typeAttributes.type },
                sortDirection
            );
        } else if (column.type === 'clickableText') {
            this.copyData = [...this.copyData].sort((a, b) => {
                a = Date.parse(a.DATE) || 0;
                b = Date.parse(b.DATE) || 0;

                if (sortDirection === 'asc') {
                    return a - b;
                }
                return b - a;
            });
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
        this.setRecords(this.displayList);
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

    @api
    set list(value) {
        let recordCount = value?.length;
        if (recordCount) {
            this._list = value;
            this.displayList = this._list;
            this.tableDetails.total = recordCount;
        } else {
            this.emptyState = true;
        }
    }

    get list() {
        return this._list;
    }

    clearSearch() {
        this.template.querySelector('c-base-search-bar').clear();
    }

    get isProgressNote() {
        //? only show Add To Note button if we are on a progress note, the parent HDR component allows it & there are records to display
        return (
            this.currentObject === 'VCC_Progress_Note__c' && this.hideAddToNote === false && this.emptyState === false
        );
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
            console.error(`Error importing component: ${error}`);
        }
    }

    /**
     * @description getter for a rendered body component
     */
    get actionsComponent() {
        return this._actionsComponent;
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
                console.error(`Error calling method: ${error}`);
            }
        }
    }
}
