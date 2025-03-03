import { LightningElement, api } from "lwc";

const columns = [
    { label: "Name", fieldName: "name", type: "text", sortable: true, initialWidth: 200 },
    {
        label: "Onset Date",
        fieldName: "onsetDate",
        type: "date-local",
        sortable: true,
        typeAttributes: {
            month: "2-digit",
            day: "2-digit"
        }
    },
    { label: "Status", fieldName: "status", type: "text", sortable: true },
    {
        label: "Last Updated",
        fieldName: "lastUpdated",
        type: "date-local",
        sortable: true,
        typeAttributes: {
            month: "2-digit",
            day: "2-digit"
        }
    },
    { label: "ICD Code", fieldName: "ICGCode", type: "text", sortable: true },
    { label: "Description", fieldName: "description", type: "text", sortable: true, initialWidth: 200 }
];

//  const problemHeader = "PROBLEM NAME";

export default class VccProgressNoteProblemModal extends LightningElement {
    @api
    set recordId(val) {
        if (val && typeof val === "string" && val.length >= 15) {
            this._recordId = val;
        }
    }
    get recordId() {
        return this._recordId;
    }

    formLoading = true;
    tableLoading = true;

    //Datatable Properties
    @api records = [];
    columns = columns;
    tableData = [];
    selectedRows = [];
    selectedSet = new Set();
    loadMoreAmount = 20;

    //Sorting Properties
    sortedBy;
    defaultSortDirection = "asc";
    sortDirection = "asc";

    //slice table
    @api open(element, records) {
        this.template.querySelector("c-vcc-modal").open(element);
        this.records = records;
        this.tableData = this.records;
        this.tableLoading = false;
    }

    @api close() {
        this.template.querySelector("c-vcc-modal").close();
        this.selectedRows = [];
        this.selectedSet = new Set();
    }

    addToNote(problemsToAdd) {
        // let textHeader = problemHeader;
        let problemField = this.template.querySelector('lightning-input-field[data-field-name="VCC_Problems__c"]');

        // if (!problemField.value || problemField?.value.indexOf(textHeader) === -1) {
        // if(problemField.value === null){
        //     problemField.value = textHeader;
        // }else{
        //     problemField.value += textHeader;
        // }
        // }

        problemField.value = "";
        problemsToAdd.forEach((e) => {
            let { name } = e;
            console.log(name, "Name printed here");
            console.log(e, "what is E");
            if (name.includes("ICD")) {
                name = name.replace(/\(ICD.+/g, "");
            }
            if (name.includes("SCT")) {
                name = name.replace(/\(SCT.+/g, "");
            }

            problemField.value += `\n${name || ""}`;
        });
    }

    get enableInfiniteLoading() {
        if (this.records && this.records.length > 20) {
            return true;
        } else {
            return false;
        }
    }
    /** Handlers */
    handleEscape() {
        this.close();
    }

    handleSuccess() {
        this.formLoading = false;
        this.close();
    }
    handleLoad() {
        this.formLoading = false;
    }

    handleAddAll(event) {
        this.addToNote(this.records);
    }

    handleAddSelected(event) {
        let datatable = this.template.querySelector("lightning-datatable");
        let selectedRowData = datatable.getSelectedRows();
        this.addToNote(selectedRowData);
    }

    handleRowSelected(event) {
        let selectedRows = [];
        event.detail.selectedRows.forEach((e) => {
            selectedRows.push(e.key);
        });
        this.selectedRows = selectedRows;
        this.selectedSet = new Set(selectedRows);
    }

    submit() {
        this.template.querySelector("lightning-record-edit-form").submit();
        this.formLoading = true;
    }

    /** Sorting Properties and Methods */
    handleSort(event) {
        this.tableLoading = true;
        this.doSort(event).then((sortData) => {
            this.records = sortData;
            this.resetTable();
            this.tableLoading = false;
        });
    }

    doSort(event) {
        return new Promise((resolve, reject) => {
            const { fieldName: sortedBy, sortDirection } = event.detail;
            const sortData = [...this.records];
            sortData.sort(this.sortBy(sortedBy, sortDirection === "asc" ? 1 : -1));
            this.sortDirection = sortDirection;
            this.sortedBy = sortedBy;
            resolve(sortData);
        });
    }

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

    resetTable() {
        this.tableData = this.records.slice(0, this.loadMoreAmount);
    }

    handleLoadMore(event) {
        this.tableData = [...this.tableData, ...this.records.slice(this.tableData.length, this.tableData.length + this.loadMoreAmount)];
    }
}
