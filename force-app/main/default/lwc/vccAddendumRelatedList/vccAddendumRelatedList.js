import { LightningElement, api } from "lwc";
//? https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_wire_adapters_object_info
// import { getObjectInfo } from 'lightning/uiObjectInfoApi';
//? Apex class that is called
import getRelatedRecords from "@salesforce/apex/VCC_AddendumRelatedListController.getRelatedAddendums";
import genericError from "@salesforce/label/c.VCC_Generic_Error";
import genericSubError from "@salesforce/label/c.VCC_Generic_Sub_error";
import { proxyTool } from "c/helpersLWC";
import { datatableHelper } from "c/utils";

export const sortList = datatableHelper.sortFlatList;
export const getColumn = (columns, fieldName) => columns.filter((entry) => entry["fieldName"] === fieldName)[0];

export default class VccAddendumRelatedList extends LightningElement {
    @api recordId; //? native Salesforce functionality that gives us the recordId of the current page
    limitForRecords = 3;
    displayList; //? trimmed list of results
    fullTableData; //? all results but able to be modified
    _records; //? all results
    error; //? allows us to toggle the error state of the component
    componentTitle = "Addendums (0)"; //? will later be updated to show the correct number of results
    URL = "/";
    showBodyAndFooter = false;
    showError = false;
    showFilter = true;
    filterFields = ["CreatedByName", "ProgressNoteName", "Signed"];
    selectedRecord;

    //? columns used for View All
    columns = [
        // {label:'Addendum Number', fieldName:'Name', type:'text', hideDefaultActions:true, initialWidth:125},
        {
            label: "Addendum Number",
            fieldName: "Name",
            type: "button",
            sortable: true,
            typeAttributes: {
                label: { fieldName: "Name" },
                title: "Click to Open Addendum record",
                name: "openAddendum",
                variant: "base",
                type: "text"
            },
            wrapText: false,
            cellAttributes: {
                style: "padding: 0 !important; flex-wrap: nowrap !important",
                class: "slds-has-flexi-truncate"
            }
        },
        // {label:'Progress Note', fieldName:'ProgressNoteName', type:'text', hideDefaultActions:true, initialWidth:125},
        {
            label: "Progress Note",
            fieldName: "ProgressNoteName",
            type: "button",
            sortable: true,
            typeAttributes: {
                label: { fieldName: "ProgressNoteName" },
                title: "Click to Open Addendum record",
                name: "openProgressNote",
                variant: "base",
                type: "text"
            },
            wrapText: false,
            cellAttributes: {
                style: "padding: 0 !important; flex-wrap: nowrap !important",
                class: "slds-has-flexi-truncate"
            }
        },
        { label: "Created By", fieldName: "CreatedByName", type: "text", sortable: true, hideDefaultActions: true, initialWidth: 150 },
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
            initialWidth: 150
        },
        { label: "Addendum", fieldName: "VCC_Addendum__c", type: "text", hideDefaultActions: true, initialWidth: 300 },
        { label: "Signed", fieldName: "Signed", type: "boolean", wrapText: true, hideLabel: true }
        // {label:'Signed', fieldName:'signedSymbol', type:'text', wrapText: true, hideLabel: true}
    ];

    PNTitle;

    sortDirection;
    sortedBy;
    tableDetails = {
        total: 0,
        sortedBy: "Addendum Number" // defaulting to Addendum Number
    };

    labels = {
        addendumsErrorMessage: genericError,
        addendumsErrorSubMessage: genericSubError
    };

    //? lifecycle method of the LWC component that is called only once at the beginning
    connectedCallback() {
        this.getRecords();
        this.labels.addendumsErrorMessage = genericError.replace("{0}", "Retrieval Error");
    }

    //? Houses all the setup work that needs to be done at the beginning of the component
    getRecords() {
        //? Calling Apex Imperatively & sending in the recordId
        //? https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.apex_call_imperative
        // this.recordId = 'THROW_ERROR'; //! intentionally throw error
        getRelatedRecords({ incomingId: this.recordId })
            .then((result) => {
                this.displayList = result;
                // console.log('this.displayList: ', JSON.parse(JSON.stringify(this.displayList)));
                let updatedRecords = [];
                //? iterate over the list of records (Array of Objects)
                this.displayList.forEach((record) => {
                    let recordData = record;
                    //? modifications to the record & adding anything that is needed
                    recordData.addendumURL = this.URL + record.Id;
                    recordData.parentURL = this.URL + record.VCC_Related_Note__c;
                    recordData.ProgressNoteName = record.VCC_Related_Note__r.Name;
                    recordData.CreatedByName = record.CreatedBy.Name;
                    recordData.Signed = record.VCC_Signed__c;
                    // recordData.signedSymbol = record.VCC_Signed__c ? '✓' : '🗹'; //? empty box renders terribly. Possible 508 issue

                    //? add this record to the list of all the updated records
                    updatedRecords.push(recordData);
                });
                //? records to display are going to be only the first few
                this.displayList = updatedRecords.slice(0, this.limitForRecords);

                //? changes the number in the title based on the limitForRecords variable
                //? will show the number (3) or the limitForRecords number as (3+)
                //? https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Template_literals
                let recordCount = updatedRecords.length > this.limitForRecords ? `${this.limitForRecords}+` : updatedRecords.length;

                if (updatedRecords.length > 0) this.showBodyAndFooter = true;

                //? swap out the 0 for the correct number of records in the componentTitle
                this.componentTitle = this.componentTitle.replace("0", recordCount);
                this._records = updatedRecords;
                this.fullTableData = this._records;
                this.tableDetails.total = updatedRecords.length;
                this.error = undefined;
                this.PNTitle = updatedRecords[0].VCC_Related_Note__r.Name;
            })
            .catch((error) => {
                this.error = error;
                //? only show error if there was a problem retrieving records
                this.showError = this.displayList?.length == 0 ? false : true;
                this.displayList = undefined;
                if (this.showError) console.error("Addendums Component Error: ", this.error.body.message);
            });
    }

    //? HANDLERS

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case "openAddendum":
                this.visitCorrelatedURL(row, "Name", "addendumURL");
                break;
            case "openProgressNote":
                this.visitCorrelatedURL(row, "ProgressNoteName", "parentURL");
                break;
            default:
        }
    }

    handleSort(event) {
        let { fieldName, sortDirection, label } = event.detail;
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
    }

    handleViewAllClick() {
        this.template.querySelector("c-base-modal").open(this.template.host);
        // alert('view all');
    }

    handleFilterChange(event) {
        // console.log(event.detail);
        this.fullTableData = event.detail;
        this.tableDetails.total = this.fullTableData.length;
    }

    //? METHODS

    setRecords(list) {
        this.fullTableData = list;
        // this.setPagination();
    }

    visitCorrelatedURL(row, matchField, urlField) {
        this.selectedRecord = row;
        // console.log("this.selectedRecord: ", proxyTool(this.selectedRecord));
        // console.log("this.selectedRecord: ", proxyTool(this.selectedRecord.Name));
        this._records.forEach((r) => {
            if (r[matchField] === row[matchField]) window.open(r[urlField], "_self");
        });
    }
}
