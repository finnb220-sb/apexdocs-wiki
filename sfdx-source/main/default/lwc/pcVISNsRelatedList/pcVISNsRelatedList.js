import { LightningElement, wire, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

//Apex
import getRelatedRecords from "@salesforce/apex/PC_VISNsRelatedListController.getVISNs";
import saveRecords from "@salesforce/apex/PC_VISNsRelatedListController.saveRecords";

import { datatableHelper } from "c/utils";

//exports
export const sortList = datatableHelper.sortFlatList;
export const getColumn = (columns, fieldName) => columns.filter((entry) => entry["fieldName"] === fieldName)[0];

export default class PcVISNsRelatedList extends LightningElement {
    //component custom properties
    @api limitForRecords;
    @api includeIndirectVISNs;
    @api iconName;

    //component native properties
    @api recordId; //native Salesforce functionality that gives us the recordId of the current page

    _objectLabel = "VISNs";
    _defaultTitle = this._objectLabel + " (0)";
    componentTitle = this._defaultTitle; //will later be updated to show the correct number of results
    assignButtonTitle = "Assign " + this._objectLabel;
    URL = "/";

    // showFilter = true;
    // filterFields = ['CreatedByName'];

    error; //allows us to toggle the error state of the component

    showError = false;
    showBodyAndFooter = false;
    isExpanded = false; //controls the pill container's expanded/collapsed state
    isSubmitting = false;

    _recordsWireValue; //wire object from load of salesforce records - used to refresh record lists if database changes occur

    _originalRecords; //all results
    fullTableData; //all results (but able to be modified)
    paginatedTableData; //subset of fullTableData results displayed to user from pagination

    displayList; //trimmed list of results for Related List

    _originalSelectedRecords = [];
    selectedRecords = []; //selected records in the lightning data table. Holds full data of record and properties required for pill container

    _originalSelectedIndirectRecords; // all results with selected AND indirect = true (these records should not be removed)

    _originalSelectedTableRows = [];
    selectedTableRows = []; //selected rows in lightning data table. allows for programmatic selection/deselection of rows by providing array of key-field values

    //? columns used for View All
    columns = [
        {
            label: "VISN Name",
            fieldName: "VISN_Number__c",
            type: "button",
            sortable: true,
            typeAttributes: {
                label: { fieldName: "Name" },
                title: "Click to Open VISN record",
                name: "openRecord",
                variant: "base",
                type: "number"
            },
            wrapText: false,
            cellAttributes: {
                style: "padding: 0 !important; flex-wrap: nowrap !important",
                class: "slds-has-flexi-truncate"
            }
        },
        {
            label: "Created By",
            fieldName: "CreatedByName",
            type: "text",
            sortable: true,
            hideDefaultActions: true,
            initialWidth: 150
        },
        {
            label: "Created Date",
            fieldName: "CreatedDate",
            type: "date",
            sortable: true,
            typeAttributes: {
                month: "2-digit",
                day: "2-digit",
                year: "numeric",
                hour: "2-digit",
                minute: "2-digit"
            },
            hideDefaultActions: true,
            initialWidth: 170
        }
    ];

    sortDirection;
    sortedBy;
    tableDetails = {
        total: 0,
        sortedBy: "VISN Name" // defaulting to VISN Name
    };

    searchBarSettings = {
        variant: "label-hidden"
    };

    entriesPerPage = 10;

    @wire(getRelatedRecords, { territoryId: "$recordId", includeIndirectVISNs: "$includeIndirectVISNs" })
    loadRelatedRecords({ data, error }) {
        this._recordsWireValue = { data, error };
        //console.log(this._recordsWireValue);
        if (data) {
            //console.log(data);
            //console.log(data.records);
            this.displayList = JSON.parse(JSON.stringify(data.records));
            // console.log('this.displayList: ', JSON.parse(JSON.stringify(this.displayList)));
            let updatedRecordsAll = [];
            let updatedRecordsIndirect = [];
            let updatedRecordsSelected = [];

            //? iterate over the list of records (Array of Objects)
            this.displayList.forEach((item) => {
                let recordData = item.record;
                //? modifications to the record & adding anything that is needed
                recordData.recordURL = this.URL + item.record.Id;
                recordData.CreatedByName = item.record.CreatedBy.Name;
                recordData.selected = item.selected;
                recordData.indirect = item.indirect;

                //add properties for pill display
                recordData.type = "icon";
                recordData.label = recordData.Name;
                recordData.iconName = this.iconName;
                recordData.alternativeText = "VISN";

                //console.log(recordData);
                if (item.selected === true) {
                    //? add this record to the list of all the updated records
                    updatedRecordsSelected.push(recordData);

                    if (item.indirect === true) {
                        updatedRecordsIndirect.push(recordData);
                    }
                }

                updatedRecordsAll.push(recordData);
            });
            //? update related list display
            this.updateRelatedListDisplay(updatedRecordsSelected);

            //console.log(this._originalRecords);
            this._originalRecords = updatedRecordsAll;
            this.setRecords(this._originalRecords);

            //add records to list of selectedRecords for display in pill container list
            //console.log(this._originalSelectedRecords);
            this._originalSelectedRecords = updatedRecordsSelected;
            this.setSelectedRecords(this._originalSelectedRecords);

            this._originalSelectedIndirectRecords = updatedRecordsIndirect;

            //set list of pre-selected rows in datatable
            //console.log(this._originalSelectedTableRows);
            this.updateTableCheckboxes(this.selectedRecords);
            this._originalSelectedTableRows = this.selectedTableRows;
            //console.log(this.selectedTableRows);

            this.setPagination();

            this.error = undefined;
        } else if (error) {
            // handle Error
            this.error = error;
            //? only show error if there was a problem retrieving records
            this.showError = this.displayList?.length == 0 ? false : true;
            this.displayList = undefined;
            if (this.showError) {
                console.error("Related VISNs Component Error: ", this.error.body.message);
            }
        }
    }

    //GETTERS

    get hasSelectedRecords() {
        return this.selectedRecords?.length > 0;
    }

    get selectedRecordCountText() {
        if (this.selectedRecords?.length === 1) {
            return this.selectedRecords?.length + " Item Selected";
        } else {
            return this.selectedRecords?.length + " Items Selected";
        }
    }

    //tracks if the record selections in the datatable have changed from the original load
    get hasNoChanges() {
        const objectsEqual = (o1, o2) =>
            typeof o1 === "object" && Object.keys(o1).length > 0
                ? Object.keys(o1).length === Object.keys(o2).length && Object.keys(o1).every((p) => objectsEqual(o1[p], o2[p]))
                : o1 === o2;
        const arraysEqual = (a1, a2) => a1.length === a2.length && a1.every((o, idx) => objectsEqual(o, a2[idx]));
        return arraysEqual(this._originalSelectedRecords, this.selectedRecords);
    }

    get disableSubmit() {
        return this.hasNoChanges || this.isSubmitting;
    }

    get hidePaginationBtns() {
        return this.fullTableData?.length <= this.entriesPerPage;
    }

    //HANDLERS

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case "openRecord":
                this.visitCorrelatedURL(row, "Name", "recordURL");
                break;
            default:
        }
    }

    handleSort(event) {
        let { fieldName, sortDirection } = event.detail;
        const column = getColumn(this.columns, fieldName);
        // if column is a button or "clickable link" use the typeAttributes.type property to sort else use regular type on the root object
        if (column.type === "button") {
            this.fullTableData = sortList([...this.fullTableData], { propertyName: fieldName, type: column.typeAttributes.type }, sortDirection);
        } else {
            this.fullTableData = sortList([...this.fullTableData], { propertyName: fieldName, type: column.type }, sortDirection);
        }

        this.sortDirection = this.sortDirection === "asc" ? "desc" : "asc";
        this.sortedBy = fieldName;
        this.tableDetails.sortedBy = column.label;
        this.setRecords(this.fullTableData);
        this.setPagination();
    }

    handleViewAllClick() {
        this.openModal();
    }

    handleAssignButtonClick() {
        this.openModal();
    }

    // handleFilterChange(event) {
    //     // console.log(event.detail);
    //     //this.fullTableData = event.detail;
    //     //this.tableDetails.total = this.fullTableData.length;

    //     this.setRecords(event.detail);
    //     this.updateTableCheckboxes(this.selectedRecords);
    // }

    //handles check/uncheck of data table row
    handleRowSelection(event) {
        console.log(JSON.parse(JSON.stringify(event.detail)));
        console.log(event.detail.config.action); //type of checkbox selection made (rowSelect/rowDeselect/selectAllRows/deselectAllRows)
        console.log(event.detail.config.value); //Id (key-field) of the most recently selected row
        console.log(event.detail.selectedRows); //Array of all selected rows
        console.log(this.selectedRecords);

        const currentSelectionType = event.detail.config.action;
        const currentSelectedKey = event.detail.config.value;
        const currentSelectedRows = event.detail.selectedRows;
        const currentSelectedRowsWithKey = currentSelectedRows.filter((item) => item.Id === currentSelectedKey);

        //ensure event has a selection type otherwise erroneous logic might be run on programmtic updates to selectedTableRows
        if (currentSelectionType) {
            if (currentSelectionType === "rowSelect") {
                this.setSelectedRecords(this.selectedRecords.concat(currentSelectedRowsWithKey));
            } else if (currentSelectionType === "rowDeselect") {
                if (this._originalSelectedIndirectRecords.filter((item) => item.Id === currentSelectedKey).length > 0) {
                    this.showToast(
                        "Removal cannot be completed.",
                        "This record is related to the territory through an indirect relationship, which cannot be removed. Please reach out to your System Administrator.",
                        "warning"
                    );
                } else {
                    //remove selected record
                    this.setSelectedRecords(this.selectedRecords.filter((item) => item.Id !== currentSelectedKey));
                }
            } else if (currentSelectionType === "selectAllRows") {
                this.setSelectedRecords(this.fullTableData);
            } else if (currentSelectionType === "deselectAllRows") {
                //deselect all rows except the originally selected indirect records
                this.setSelectedRecords(this._originalSelectedIndirectRecords);
            }

            this.selectedRecords = sortList([...this.selectedRecords], { propertyName: "VISN_Number__c", type: "number" }, "asc");
            this.updateTableCheckboxes(this.selectedRecords);
        }
    }

    //handles remove button on location pills
    handleItemRemove(event) {
        //remove item from selected records list
        this.selectedRecords = this.selectedRecords.filter((item) => item.Id !== event.detail.item.Id);
        this.updateTableCheckboxes(this.selectedRecords);
    }

    //handles expansion of the pills container to show/hide all locations
    handlePillExpansion() {
        this.isExpanded = !this.isExpanded;
    }

    //closes baseModal and resets record lists to last saved state
    handleClose() {
        const baseModal = this.template.querySelector("c-base-modal");
        baseModal.close();

        this.isExpanded = false;
        this.resetRecordLists();
    }

    handleSearch(event) {
        const searchResults = JSON.parse(event.detail) || null;
        const baseSearchBar = this.template.querySelector("c-base-search-bar");

        // console.log('Search Results: ');
        // console.log(searchResults);
        // console.log(baseSearchBar.inputLength());

        // handle clearing
        if (!baseSearchBar.inputLength()) {
            //console.log('handle clearing');
            this.setRecords(this._originalRecords);
            this.updateTableCheckboxes(this.selectedRecords);
            this.setPagination();
            return;
        }

        if (searchResults?.length) {
            //console.log('has results');
            this.setRecords(searchResults);
            this.updateTableCheckboxes(this.selectedRecords);
            this.setPagination();
        } else {
            //console.log('no results');
            this.setRecords([]);
        }
    }

    handleSubmitClick() {
        // console.log('SUBMIT button pressed');
        // console.log(JSON.stringify(this._originalSelectedTableRows));
        // console.log(JSON.stringify(this.selectedTableRows));

        this.isSubmitting = true;

        saveRecords({
            territoryId: this.recordId,
            originalSelectedRecordIds: JSON.stringify(this._originalSelectedTableRows),
            selectedRecordIds: JSON.stringify(this.selectedTableRows)
        })
            .then((result) => {
                //console.log(result);
                this.showToast("Submit Successful!", result, "success");

                //update base lists with new values
                this._originalSelectedRecords = this.selectedRecords;
                this._originalSelectedTableRows = this.selectedTableRows;
                this.updateRelatedListDisplay(this.selectedRecords);

                this.isSubmitting = false;
            })
            .catch((error) => {
                this.error = error;
                //? only show error if there was a problem retrieving records
                // this.showError = (this.displayList?.length == 0 ) ? false : true;
                // this.displayList = undefined;
                if (this.showError) console.error("Locations Related List Component Error: ", this.error.body.message);
                this.showToast("Error on Submit", this.error.body.message, "error");
                this.isSubmitting = false;
            });

        //on success, refresh Table
        //return this.refreshTable();
    }

    handlePageChange(event) {
        this.setPaginatedRecords(event.detail);
        this.updateTableCheckboxes(this.selectedRecords);
    }

    //METHODS

    openModal() {
        //this.template.querySelector('c-base-modal').open(this.template.host);
        this.template.querySelector(".viewAllModal").open(this.template.host);
    }

    setPagination() {
        this.noResults = false;
        const pagination = this.template.querySelector("c-base-pagination");

        if (pagination) {
            pagination.setList(this.fullTableData);
        }
    }

    setRecords(list) {
        // console.log('Entering setRecords fullTableData...');
        // console.log(list);
        this.fullTableData = list;
        //console.log('Leaving setRecords fullTableData...');
        this.updateTableTotal();
    }

    setPaginatedRecords(list) {
        // console.log('Entering setPaginatedRecords paginatedTableData...');
        // console.log(list);
        this.paginatedTableData = list;
        //console.log('Leaving setPaginatedRecords paginatedTableData...');
    }

    setSelectedRecords(list) {
        //console.log('Entering setSelectedRecords selectedRecords...');
        //console.log(list);
        this.selectedRecords = list;
        //console.log('Leaving setSelectedRecords selectedRecords...');
    }

    setSelectedTableRows(list) {
        this.selectedTableRows = list;
    }

    resetRecordLists() {
        //console.log('Entering resetRecordLists...');
        this.setRecords(this._originalRecords);
        this.setSelectedRecords(this._originalSelectedRecords);
        this.setSelectedTableRows(this._originalSelectedTableRows); //TODO still need this?
    }

    updateRelatedListDisplay(selectedList) {
        //? records to display are going to be only the first few
        this.displayList = selectedList.slice(0, this.limitForRecords);

        //? changes the number in the title based on the limitForRecords variable
        //? will show the number (5) or the limitForRecords number as (5+)
        //? https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Template_literals
        let recordCount = selectedList.length > this.limitForRecords ? `${this.limitForRecords}+` : selectedList.length;
        //? swap out the 0 for the correct number of records in the componentTitle
        this.componentTitle = this._defaultTitle.replace("0", recordCount);

        //show list of records on related list component
        if (selectedList.length > 0) this.showBodyAndFooter = true;
    }

    updateTableCheckboxes(checkedRecords) {
        // console.log('Entering updateTableCheckboxes...');
        // console.log(this.selectedTableRows);
        // console.log(checkedRecords);

        //reselect checkbox in datatable checkbox column using array of key-fields (Id)
        let selectedTableRecordIds = [];
        checkedRecords.forEach((item) => {
            selectedTableRecordIds.push(item.Id);
        });
        this.selectedTableRows = selectedTableRecordIds;

        // console.log(this.selectedTableRows);
        // console.log('Leaving updateTableCheckboxes...');
    }

    updateTableTotal() {
        this.tableDetails.total = this.fullTableData.length;
    }

    visitCorrelatedURL(row, matchField, urlField) {
        // console.log("this.selectedRecord: ", proxyTool(this.selectedRecord));
        // console.log("this.selectedRecord: ", proxyTool(this.selectedRecord.Name));
        this._originalRecords.forEach((r) => {
            if (r[matchField] === row[matchField]) window.open(r[urlField], "_self");
        });
    }

    showToast(title, message, variant, mode) {
        //variants are error/warning/success/info
        //modes are dismissible, pester, sticky
        this.dispatchEvent(
            new ShowToastEvent({
                message: message,
                title: title,
                variant: variant ? variant : "info",
                mode: mode ? mode : "dismissable"
            })
        );
    }
}
