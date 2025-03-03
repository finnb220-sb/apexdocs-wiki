/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable consistent-return */

// not sure why set timeout is called, need to investigate that further
// adding another suppression for existing code, that needs to be investigated further as well
import { LightningElement, api, track } from 'lwc';
import { collectSearchTargets, format, sortList, columns } from './vccHistoricalProgressNotesListHelper';
import getSettings from '@salesforce/apex/VCC_WorkstreamSettingsController.getSettings';

export default class VccHistoricalProgressNotesList extends LightningElement {
    _list;
    _processed;
    searchLoading;

    filterTypes = [
        { label: 'Type', value: 'type' },
        { label: 'Facility', value: 'facility' }
    ];

    filterSwitch;
    filterOptions;
    secondFilterOptions;
    firstFilterOptions;
    dataSettings = {};
    @api hdrMessage;
    @track facilityPicklist;
    @track typePicklist;
    @track all;
    @track page = [];
    @track picklist = [];
    filterMessage = '';
    @track
    headerMessage = '';
    dateRange = false;
    columns = columns;

    @track displayList;
    sortOrder = 'asc';
    loading;

    @track masterList;
    @track masterList2;
    @track filteredList;

    @track displayIcons = {
        title: false,
        date: false,
        type: false,
        facility: false,
        code: false
    };

    @track filters = false;
    @api initial;
    @track heading = 'EHR Progress Notes';
    @track sortInfo = {
        title: null,
        numItems: null,
        sortedBy: 'Date'
    };

    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    _actionsComponent;

    async connectedCallback() {
        this.dataSettings = await getSettings({ dataType: 'ehr_progress_notes' });
    }

    @api
    set list(value) {
        if (value?.length) {
            this.loading = true;
            this.masterList = value;
            this.masterList2 = value;
            this.filteredList = value;
            this._list = value;
            this.displayList = value;
            this.sortInfo.numItems = this._list.length || 0;
            this.loading = false;
        }
    }

    get list() {
        return this._list;
    }

    @api
    set processed(val) {
        this._processed = val;
        this.facilityPicklist = Object.keys(this._processed?.facility ?? {}) || [];
        this.typePicklist = Object.keys(this._processed?.type ?? {}) || [];
    }

    get processed() {
        return this._processed;
    }

    handleFirstChange(event) {
        // TODO: set options for type
        if (event.detail?.value) {
            switch (event.detail.value) {
                case 'facility':
                    this.filterSwitch = 'facility';
                    this.secondFilterOptions = this.facilityPicklist.map((e) => {
                        return {
                            label: e,
                            value: e,
                            type: 'facility'
                        };
                    });
                    break;

                case 'type':
                    this.filterSwitch = 'type';
                    this.secondFilterOptions = this.typePicklist.map((e) => {
                        return {
                            label: e,
                            value: e,
                            type: 'type'
                        };
                    });
                    break;

                default:
                //do nothing on default
            }
        }
    }

    updateList(newList) {
        if (newList?.length) {
            this.dispatchEvent(
                new CustomEvent('listupdate', {
                    detail: JSON.stringify(newList),
                    cancelable: false,
                    bubbles: true
                })
            );
        }
    }

    @track filterEvent;

    handleSecondChange(event) {
        this.searchLoading = true;
        this.filterEvent = !event ? this.filterEvent : event;
        if (this.filterEvent?.detail?.value) {
            switch (this.filterSwitch) {
                case 'facility':
                    this.masterList2 = this.masterList.filter(
                        (row) => row.facilityName === this.filterEvent?.detail?.value
                    );
                    this.displayList = this.masterList2;
                    this.filteredList = this.masterList2;
                    // this.setPagination();
                    break;

                case 'type':
                    this.masterList2 = this.masterList.filter(
                        (row) => row.typeName === this.filterEvent?.detail?.value
                    );
                    this.displayList = this.masterList2;
                    this.filteredList = this.masterList2;
                    // this.setPagination();
                    break;

                default:
                // do nothing
            }

            this.sortInfo.sortedBy = 'Date';
        }

        if (this.searchEvent) {
            this.handleSearch();
        }
        this.searchLoading = false;
    }

    handleRowAction(event) {
        const evt = new CustomEvent('rowclick', {
            detail: {
                id: event.detail.row.vtcId,
                view: 'single'
            }
        });
        this.dispatchEvent(evt);
    }

    timeout = null;
    searchValue;

    @track
    searchEvent;

    handleSearch(event) {
        this.searchEvent = !event ? this.searchEvent : { value: event.target?.value, keyCode: event.keyCode };
        clearTimeout(this.timeout);
        this.timeout = setTimeout(
            function () {
                this.searchLoading = true;
                if (this.searchEvent?.keyCode === 8 && this.searchEvent?.value?.length > 3) {
                    return;
                }
                if (this.searchEvent?.value?.length < 3) {
                    this.displayList = this.masterList;
                    // this.setPagination();
                } else {
                    this.displayList = this.search(this.searchEvent.value, this.masterList2);
                    this.filteredList = this.displayList;
                    // this.setPagination();
                }
                if (this.searchEvent.keyCode === 13) {
                    this.displayList = this.search(this.searchEvent?.value, this.masterList2);
                    this.filteredList = this.displayList;
                    // this.setPagination();
                }
                this.searchLoading = false;
            }.bind(this),
            500
        );
    }

    setPagination() {
        const pagination = this.template.querySelector('c-base-pagination');
        if (pagination && this.displayList?.length) {
            pagination.setList(this.displayList);
        }
    }

    search(searchString, arr) {
        if (arr?.length) {
            arr = arr.filter((item) => {
                for (const searchTarget of collectSearchTargets(item)) {
                    // FML
                    if (!searchTarget.includes(format(searchString))) continue;
                    return true;
                }
                return false;
            });
            if (arr) return arr;
        }
    }

    handleSort(event) {
        if (this.displayList?.length) {
            const { fieldName: sortedBy, sortDirection } = event.detail;
            const type = sortedBy === 'dateCreatedFormatted' ? 'date' : 'text';
            this.filteredList = sortList([...this.filteredList], { propertyName: sortedBy, type: type }, sortDirection);
            this.displayList = this.filteredList;
            this.sortDirection = sortDirection;
            this.sortedBy = sortedBy;
            this.sortInfo.sortedBy = sortedBy;
            switch (sortedBy) {
                case 'dateCreatedFormatted':
                    this.sortInfo.sortedBy = 'Date';
                    break;
                case 'localTitle':
                    this.sortInfo.sortedBy = 'Local Title';
                    break;
                case 'typeName':
                    this.sortInfo.sortedBy = 'Type';
                    break;
                case 'encounterName':
                    this.sortInfo.sortedBy = 'Encounter Name';
                    break;
                case 'facilityName':
                    this.sortInfo.sortedBy = 'Facility';
                    break;
                case 'authorName':
                    this.sortInfo.sortedBy = 'Author Name';
                    break;

                default:
                // do nothing
            }
        }
    }
    /**
     * @description called on reload to reset to default sorting values.
     */
    @api resetSortedDefaultValues() {
        this.sortInfo.sortedBy = 'Date';
        this.sortDirection = null;
        this.sortedBy = null;
    }

    handleRefresh() {
        this.template.querySelectorAll('lightning-input').forEach((input) => (input.value = null)); // reset inputs
        this.template.querySelectorAll('lightning-combobox').forEach((input) => (input.value = null));
        this.template.querySelector('c-base-date-range').clear();
        this.heading = 'EHR Progress Notes';
        this.headerMessage = '';
        this.masterList = this.processed.all;
        this.masterList2 = this.processed.all;
        this.displayList = this.processed.all;
        this.filteredList = this.processed.all;
        this.filterEvent = null;
        this.searchEvent = null;
        this.filterSwitch = null;
        this.secondFilterOptions = null;
    }

    handleBaseDateChange(event) {
        this.searchLoading = true;
        if (this.template.querySelector('c-base-date-range').inputsAreBlank() && !event.detail.length) {
            this.masterList = this._list;
            this.masterList2 = this._list;
            this.updateList(this.processed.all);
            this.filteredList = this._list;
        } else {
            this.masterList = event.detail;
            this.masterList2 = event.detail;
            this.displayList = event.detail;
            this.filteredList = event.detail;
        }

        if (this.filterEvent) {
            this.handleSecondChange();
        } else if (this.searchEvent) {
            this.handleSearch();
        }
        this.searchLoading = false;
    }

    handlePageChange(event) {
        this.displayList = event.detail;
    }

    @api
    setListLoading(isLoading) {
        this.loading = isLoading;
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
