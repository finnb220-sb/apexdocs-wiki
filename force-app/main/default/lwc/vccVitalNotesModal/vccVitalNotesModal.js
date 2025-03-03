import { api, LightningElement, wire } from "lwc";
import MEDICATIONS from "@salesforce/schema/VCC_Progress_Note__c.VCC_Medications__c";
import VITALS from "@salesforce/schema/VCC_Progress_Note__c.VCC_Vitals__c";
import PATIENT_NAME from "@salesforce/schema/VCC_Progress_Note__c.VCC_Patient_Name__c";
import PATIENT_DOB from "@salesforce/schema/VCC_Progress_Note__c.VCC_Date_of_Birth__c";

const columns = [
    { label: "Date/Time", fieldName: "DATE", type: "clickableText", wrapText: false, initialWidth: 250, sortable: true },
    { label: "Weight (lbs)", fieldName: "WEIGHT", type: "clickableText", cellAttributes: { alignment: "left" }, initialWidth: 200, sortable: true },
    { label: "Blood Pressure (mm[Hg])", fieldName: "BLOOD PRESSURE", type: "clickableText", initialWidth: 200, sortable: true },
    { label: "Temperature (\u2109)", fieldName: "TEMPERATURE", type: "clickableText", cellAttributes: { alignment: "left" }, initialWidth: 150, sortable: true },
    { label: "Pulse (beats/min)", fieldName: "PULSE", type: "clickableText", cellAttributes: { alignment: "left" }, initialWidth: 150, sortable: true },
    { label: "Respiration (breaths/min)", fieldName: "RESPIRATION", type: "clickableText", cellAttributes: { alignment: "left" }, initialWidth: 200, sortable: true },
    { label: "Pain", fieldName: "PAIN", type: "text", initialWidth: 100, sortable: true }
];

const fields = [MEDICATIONS, VITALS, PATIENT_NAME, PATIENT_DOB];

export default class VccVitalNotesModal extends LightningElement {
    /** Properties */
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

    //datatable properties
    columns = columns;
    @api vitals = [];
    tableData = [];
    loadMoreAmount = 20;
    get enableInfiniteLoading() {
        if (this.vitals && this.vitals.length > 20) {
            return true;
        } else {
            return false;
        }
    }

    /** Methods */

    @api open(element, vitals) {
        this.template.querySelector("c-vcc-modal").open(element);
        this.vitals = vitals;
        if (this.vitals.length > 20) {
            this.tableData = this.vitals.slice(0, this.loadMoreAmount);
        } else {
            this.tableData = this.vitals;
        }
        this.tableLoading = false;
        this.tableData.forEach((e) => {
            if (this.columns.filter((a) => a.fieldName == e.measurements.measurement[0].name).length == 0) {
                let headerValue =
                    e.measurements.measurement[0].name[0].toUpperCase() +
                    e.measurements.measurement[0].name.slice(1).toLowerCase() +
                    " (" +
                    e.measurements.measurement[0].units +
                    ")";

                let vitalHeader = {
                    label: headerValue,
                    fieldName: e.measurements.measurement[0].name,
                    type: "text",
                    initialWidth: 150,
                    sortable: true
                };
                this.columns.push(vitalHeader);
            }
        });
    }

    @api close() {
        this.clearSelectedRows();
        this.template.querySelector("c-vcc-modal").close();
    }

    addToNote(vitalsToAdd) {
        let vitField = this.template.querySelector('lightning-input-field[data-field-name="VCC_Vitals__c"]');
        let textHeader = "\n";
        for (let keys in vitalsToAdd[0]) {
            console.log(keys);
            for (var i = 0; i < columns.length; i++) {
                if (columns[i].fieldName == keys) {
                    var header = columns[i].label;
                    textHeader += header.toUpperCase() + "  -  ";
                }
            }
        }
        textHeader += " \n";

        if (!vitField.value || vitField?.value.indexOf(textHeader) === -1) {
            if (vitField.value === null) {
                vitField.value = textHeader;
            }
        }

        vitalsToAdd.forEach((e) => {
            vitField.value += `\n`;
            for (let keys in e) {
                for (var i = 0; i < columns.length; i++) {
                    if (keys == columns[i].fieldName) {
                        vitField.value += e[keys] != null ? e[keys] + "  -  " : "";
                    }
                }
            }
        });
    }

    submit() {
        this.template.querySelector("lightning-record-edit-form").submit();
        this.formLoading = true;
    }

    resetTable() {
        this.tableData = this.vitals.slice(0, this.loadMoreAmount);
    }

    handleLoadMore(event) {
        this.tableData = [...this.tableData, ...this.vitals.slice(this.tableData.length, this.tableData.length + this.loadMoreAmount)];
    }

    //handlers

    handleAddAll(event) {
        this.addToNote(this.vitals);
        this.clearSelectedRows();
    }

    handleAddSelected(event) {
        let datatable = this.template.querySelector("lightning-datatable");
        let selectedRowData = datatable.getSelectedRows();
        this.addToNote(selectedRowData);
        this.clearSelectedRows();
    }

    handleLoad() {
        this.formLoading = false;
    }

    handleEscape() {
        this.clearSelectedRows();
        this.close();
    }

    handleSuccess() {
        this.formLoading = false;
        this.close();
    }

    clearSelectedRows() {
        this.template.querySelector("lightning-datatable").selectedRows = [];
    }

    /** Sorting Properties and Methods */
    sortedBy;
    defaultSortDirection = "asc";
    sortDirection = "asc";

    handleSort(event) {
        this.tableLoading = true;
        this.doSort(event).then((sortData) => {
            this.vitals = sortData;
            this.resetTable();
            this.tableLoading = false;
        });
    }

    doSort(event) {
        // trying to make the sorting asyncronous (for large lists) though it doesn't seem to work
        return new Promise((resolve, reject) => {
            // set up sort variables and sort the meds list
            const { fieldName: sortedBy, sortDirection } = event.detail;
            const sortData = [...this.vitals];
            sortData.sort(this.sortBy(sortedBy, sortDirection === "asc" ? 1 : -1));

            // set component variables with results and end values
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
}
