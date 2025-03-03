/* eslint-disable @lwc/lwc/no-api-reassignments */
/* eslint-disable no-else-return */
/* eslint-disable eqeqeq */
/* eslint-disable no-unused-vars */
import { api, LightningElement, wire, track } from "lwc";
import MEDICATIONS from "@salesforce/schema/VCC_Progress_Note__c.VCC_Medications__c";
import PATIENT_NAME from "@salesforce/schema/VCC_Progress_Note__c.VCC_Patient_Name__c";
import PATIENT_DOB from "@salesforce/schema/VCC_Progress_Note__c.VCC_Date_of_Birth__c";
import REQUESTED_MEDICATION from "@salesforce/schema/VCC_Progress_Note__c.VCC_Requested_Medication__c";
import MEDICATION_EXTENSION from "@salesforce/schema/VCC_Progress_Note__c.VCC_Requested_Medication_extension__c";
import isTierI from "@salesforce/customPermission/VCC_Pharmacy_Tier_I";
import isTierII from "@salesforce/customPermission/VCC_Pharmacy_Tier_II";
import isTierIII from "@salesforce/customPermission/VCC_Pharmacy_Tier_III";
import { proxyTool } from "c/helpersLWC";
import * as h from "c/helpersLWC";

const columns = [
    //Components to display for for Pharma Tier I, II, III Persona
    { label: "Rx #", fieldName: "prescriptionValue", type: "text", sortable: true, initialWidth: 110 },
    { label: "Medication", fieldName: "drugName", type: "text", wrapText: false, initialWidth: 250, sortable: true },
    { label: "Fill Qty", fieldName: "quantityValue", type: "number", cellAttributes: { alignment: "left" }, initialWidth: 90, sortable: true },
    { label: "Last Fill Date", fieldName: "lastFilledValue", type: "text", initialWidth: 100, sortable: true },
    { label: "Refills Remaining", fieldName: "fillsRemainingValue", type: "number", sortable: true, cellAttributes: { alignment: "left" } },
    { label: "Expiration Date", fieldName: "expiresValue", type: "date-local", sortable: true },
    { label: "SIG", fieldName: "sig", type: "text", initialWidth: 200, sortable: true },
    { label: "Provider Comments", fieldName: "orderingProviderComments", type: "text", initialWidth: 250, sortable: true },
    { label: "Status", fieldName: "vaStatusValue", type: "text", initialWidth: 125, sortable: true }

    //Original fields Listed
    // { label: "Medication", fieldName: "drugName", type: "text", wrapText: false, initialWidth: 350, sortable: true },
    // { label: "Status", fieldName: "vaStatusValue", type: "text", initialWidth: 125, sortable: true },
    // { label: "Provider", fieldName: "orderingProviderName", type: "text", initialWidth: 175, sortable: true },
    // { label: "Dosage", fieldName: "dosesDoseDosage", type: "text", initialWidth: 100, sortable: true },
    // { label: "Expiration Date", fieldName: "expiresValue", type: "text", initialWidth: 115, sortable: true },
    // { label: "Fill Qty", fieldName: "quantityValue", type: "number", cellAttributes: { alignment: "left" }, initialWidth: 90, sortable: true },
    // { label: "Date Prescribed", fieldName: "startValue", type: "text", initialWidth: 100, sortable: true },
    // { label: "Last Fill Date", fieldName: "lastFilledValue", type: "text", initialWidth: 100, sortable: true },
    // {
    //     label: "Refills Remaining",
    //     fieldName: "fillsRemainingValue",
    //     type: "number",
    //     cellAttributes: { alignment: "left" },
    //     initialWidth: 150,
    //     sortable: true
    // },
    // { label: "Route", fieldName: "routingValue", type: "text", cellAttributes: { alignment: "left" }, initialWidth: 100, sortable: true }
];

//Adding requested medication renewal/extension to insert data into fields
const fields = [MEDICATIONS, PATIENT_NAME, PATIENT_DOB, REQUESTED_MEDICATION, MEDICATION_EXTENSION];

export default class VccProgressNoteMedsModalTier extends LightningElement {
    /** Properties  x*/
    @track displayList;
    @track displayStatus;
    @track medField;
    @api
    set recordId(val) {
        if (val && typeof val === "string" && val.length >= 15) {
            this._recordId = val;
        }
    }

    get recordId() {
        return this._recordId;
    }

    //disable the Add Medication Extension button on Modal for Tier I
    get isExtensionBtnVisible() {
        return isTierII || isTierIII;
    }

    //disable the Add Medication Extension component on Modal for Tier I
    get isExtensionVisible() {
        return isTierII || isTierIII;
    }

    formLoading = true;
    tableLoading = true;

    //datatable properties
    columns = columns;
    @api meds = [];
    selectedRows = [];
    selectedSet = new Set();
    tableData = [];
    loadMoreAmount = 20;
    get enableInfiniteLoading() {
        if (this.meds && this.meds.length > 20) {
            return true;
        } else {
            return false;
        }
    }

    /** Methods */

    @api open(element, meds) {
        this.template.querySelector("c-vcc-modal").open(element);
        this.meds = meds;
        if (this.meds.length > 20) {
            this.tableData = this.meds.slice(0, this.loadMoreAmount);
            this.displayList = this.tableData;
        } else {
            this.tableData = this.meds;
            this.displayList = this.tableData;
        }
        this.tableLoading = false;
    }

    @api close() {
        this.template.querySelector("c-vcc-modal").close();
        this.selectedRows = [];
        this.selectedSet = new Set();
    }

    get options() {
        return [
            //Other medication status options that can be added
            // {label: 'None',value:''},
            { label: "All Active VA Meds", value: "ALL" },
            { label: "Active", value: "ACTIVE" },
            { label: "Pending", value: "PENDING" },
            { label: "Suspended", value: "SUSPENDED" }
        ];
    }

    preTextValue = "Rx # - Medication - Fill Qty - Last Fill Date - Refills Remaining - Expiration Date - SIG - Provider Comments - Status \n";

    addToNote(medsToAdd) {
        let medField = this.template.querySelector('lightning-input-field[data-field-name="VCC_Requested_Medication__c"]');

        let medsHeader = "";
        this.columns.forEach((element) => {
            if (medsHeader.length > 0) {
                medsHeader += "  -  ";
            }
            medsHeader += element.label;
        });
        medsHeader += " \n";

        if (!medField.value || medField?.value.indexOf(medsHeader) === -1) {
            if (medField.value === null) {
                medField.value = medsHeader;
            }
        }

        medsToAdd.forEach((e) => {
            let valueString = "";

            this.columns.forEach((col) => {
                for (let keys in e) {
                    if (col.fieldName == keys) {
                        valueString += e[keys];
                    }
                }
                valueString += " - ";
            });
            valueString += " \n";

            medField.value += valueString;
        });
    }

    addExtensionToNote(medsToAdd) {
        let medField = this.template.querySelector('lightning-input-field[data-field-name="VCC_Requested_Medication_extension__c"]');
        let medsHeader = "";
        this.columns.forEach((element) => {
            if (medsHeader.length > 0) {
                medsHeader += "  -  ";
            }
            medsHeader += element.label;
        });
        medsHeader += " \n";

        if (!medField.value || medField?.value.indexOf(medsHeader) === -1) {
            if (medField.value === null) {
                medField.value = medsHeader;
            }
        }

        medsToAdd.forEach((e) => {
            let valueString = "";

            this.columns.forEach((col) => {
                for (let keys in e) {
                    if (col.fieldName == keys) {
                        valueString += e[keys];
                    }
                }
                valueString += " - ";
            });
            valueString += " \n";

            medField.value += valueString;
        });
    }

    submit() {
        this.template.querySelector("lightning-record-edit-form").submit();
        this.formLoading = true;
    }

    resetTable() {
        this.tableData = this.meds.slice(0, this.loadMoreAmount);
        this.displayList = this.tableData;
        this.template.querySelector("lightning-datatable").selectedRows = [];
    }

    handleLoadMore(event) {
        this.tableData = [...this.tableData, ...this.meds.slice(this.tableData.length, this.tableData.length + this.loadMoreAmount)];
    }

    //handlers

    handleAddAll(event) {
        this.addToNote(this.meds);
    }

    handleAddSelectedRenewal(event) {
        let datatable = this.template.querySelector("lightning-datatable");
        let selectedRowData = datatable.getSelectedRows();

        this.addToNote(selectedRowData);
    }
    handleAddSelectedExtension(event) {
        let datatable = this.template.querySelector("lightning-datatable");
        let selectedRowData = datatable.getSelectedRows();
        this.addExtensionToNote(selectedRowData);
    }

    handleAddActiveVAMeds(event) {
        let selectedValue = event.detail.value;

        if (selectedValue == "ALL") {
            this.displayList = this.meds.filter((row) => row.vaStatusValue == "ACTIVE" || row.vaStatusValue == "PENDING" || row.vaStatusValue == "SUSPENDED");
        } else if (selectedValue == "ACTIVE") {
            this.displayList = this.meds.filter((row) => row.vaStatusValue == "ACTIVE");
        } else if (selectedValue == "PENDING") {
            this.displayList = this.meds.filter((row) => row.vaStatusValue == "PENDING");
        } else if (selectedValue == "SUSPENDED") {
            this.displayList = this.meds.filter((row) => row.vaStatusValue == "SUSPENDED");
        } else {
            this.displayList = this.meds.filter((row) => row.vaStatusValue == selectedValue);
        }
    }

    handleRowSelected(event) {
        let selectedRows = [];
        event.detail.selectedRows.forEach((e) => {
            selectedRows.push(e.id);
        });
        this.selectedRows = selectedRows;
        this.selectedSet = new Set(selectedRows);
    }

    handleLoad() {
        this.formLoading = false;
    }

    handleEscape() {
        this.close();
    }

    handleSuccess() {
        this.formLoading = false;
        this.close();
    }
    handleSearch(event) {
        this.displayList = event.detail;
    }

    /** Sorting Properties and Methods */
    sortedBy;
    defaultSortDirection = "asc";
    sortDirection = "asc";

    handleSort(event) {
        this.tableLoading = true;
        const sorted = this.doSort(event);
        this.meds = sorted;
        this.displayList = sorted;
        this.resetTable();
        this.tableLoading = false;
    }

    doSort(event) {
        /*
                Function to handle sorting of the meds list
                @param event       Standard event object
            */

        // set up sort variables and sort the meds list
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const sortData = [...this.displayList];

        sortData.sort(this.sortBy(sortedBy, sortDirection === "asc" ? 1 : -1));

        // set component variables with results and end values
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
        return sortData;
    }

    sortBy(field, reverse) {
        /*
            Function to handle sorting of multi-dimensional array. Checks if the field value
            is numeric and sorts as a number if so, otherwise sorts as text.            
            @param field    A string with the key name to access for sorting
            @param reverse  A number (+1/-1) to control whether to sort in ascending or descending order
        */

        // @CMTNIMBASH 2021-11-11
        return function (a, b) {
            let parser = (v) => v;
            let a1 = parser(a[field]),
                b1 = parser(b[field]);
            let r1 = a1 < b1,
                r2 = a1 === b1;
            return r2 ? 0 : r1 ? -reverse : reverse;
        };
        // return function( a, b ) {
        //     a = !isNaN(a[field]) ? parseFloat(a[field]) : a[field];
        //     b = !isNaN(b[field]) ? parseFloat(b[field]) : b[field];
        //     return reverse * (( a > b ) - ( b > a ));
        // };
    }
}
