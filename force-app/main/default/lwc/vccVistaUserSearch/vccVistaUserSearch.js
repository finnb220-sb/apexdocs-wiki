import { api, LightningElement } from "lwc";
import { searchProviders, getSignersForRecord } from "c/vccSignersController";
import vccAddSignerNoResultsLabel from "@salesforce/label/c.vccAddSignerNoResultsLabel";
import vccSearchResultsLabel from "@salesforce/label/c.vccSearchResultsLabel";
//import { createClient } from 'c/vccMessageChannel';

const columns = [
    {
        label: "",
        type: "button-icon",
        typeAttributes: {
            iconName: { fieldName: "rowIcon" },
            name: "add",
            variant: { fieldName: "rowVariant" },
            disabled: { fieldName: "disable" }
        },
        initialWidth: 25
    },

    { label: "Name", fieldName: "VCC_StaffName__c", sortable: false, initialWidth: 200 },
    { label: "Title", fieldName: "VCC_PositionTitle__c", sortable: false, initialWidth: 225 },
    { label: "Service Section", fieldName: "VCC_ServiceSection__c", sortable: false, initialWidth: 150 },
    { label: "Office Phone", fieldName: "VCC_OfficePhone__c", sortable: false, initialWidth: 150 },
    { label: "NPI", fieldName: "VCC_NPI__c", sortable: false, initialWidth: 100 },
    { label: "Signature Block Title", fieldName: "VCC_SignatureBlockName__c", sortable: false, initialWidth: 225 }
];

export default class VccVistaUserSearch extends LightningElement {
    vccAddSignerNoResultsLabel = vccAddSignerNoResultsLabel;
    vccSearchResultsLabel = vccSearchResultsLabel;

    @api
    site;

    isSearching = false;
    fullData = [];
    columns = columns;
    updatedProviders = [];
    mappedData = [];
    rowStaffIEN;
    DUZnumber;
    rowArray = [];
    removalDUZArray = [];

    @api
    recordId;

    //call on load of component
    connectedCallback() {
        this.refreshCurrentSigners();
    }

    @api
    async refreshCurrentSigners() {
        //get list of current signers to ensure add button is disabled in search results
        let signers = await getSignersForRecord({ recordId: this.recordId });
        if (Array.isArray(signers)) {
            this.updatedProviders = [];
            for (let signer of signers) {
                this.updatedProviders.push(signer?.VCC_DUZ__c);
            }
        }
    }

    handleSearchState(e) {
        let { state, value } = e.detail;
        switch (state) {
            case "typing":
                if (typeof value === "string" && value.trim().length > 2) {
                    this.isSearching = true;
                }
                break;
            case "done":
                if (typeof value === "string" && value.trim().length > 2) {
                    this.searchVistaUsers({ searchString: value, site: this.site });
                }
                break;
        }
    }

    @api
    setInputString(inputString) {
        if (typeof inputString != "string") {
            return;
        }
        this.template.querySelector("lightning-input").value = inputString;
    }

    @api
    setTableData(vistaUsers) {
        if (!Array.isArray(vistaUsers)) {
            return;
        }
        this.fullData = vistaUsers;
    }

    @api
    async searchVistaUsers({ searchString, site }) {
        this.isSearching = true;
        try {
            let searchResults = await searchProviders({ searchString: searchString, site: site });

            if (Array.isArray(searchResults)) {
                this.fullData = searchResults.map((item) => ({
                    ...item,
                    rowIcon: this.updatedProviders.includes(item.VCC_StaffIEN__c) ? "utility:add" : "utility:add",
                    rowVariant: this.updatedProviders.includes(item.VCC_StaffIEN__c) ? "brand" : "brand",
                    disable: this.updatedProviders.includes(item.VCC_StaffIEN__c) ? true : false
                }));

                return searchResults;
            } else {
                const logger = this.template.querySelector("c-logger");
                logger.error(JSON.stringify(searchResults));
                logger.saveLog();
            }
        } catch (e) {
            const logger = this.template.querySelector("c-logger");
            logger.error(JSON.stringify(e));
            logger.saveLog();
        } finally {
            this.isSearching = false;
        }
    }

    handleRowAction(e) {
        let {
            action: { name },
            row
        } = e.detail;
        this.rowStaffIEN = JSON.parse(JSON.stringify(e.detail.row.VCC_StaffIEN__c));
        this.rowArray.push(this.rowStaffIEN);
        switch (name) {
            case "add":
                this.dispatchAddSignerEvent(row);
                break;
        }

        this.handleAddRow(e);
    }

    handleAddRow() {
        //console.log('entering add row action');

        if (this.updatedProviders.includes(this.rowStaffIEN)) {
            return;
        } else {
            this.updatedProviders.push(this.rowStaffIEN);
        }

        this.fullData.forEach((record) => {
            //let providerRecord = {...record}

            if (record.VCC_StaffIEN__c == this.rowArray[this.rowArray.length - 1]) {
                record.rowIcon = "utility:add";
                record.rowVariant = "brand";
                record.disable = true;
            } else {
                record.rowIcon = "utility:add";
                record.rowVariant = "brand";
            }
        });

        this.fullData = [...this.fullData];
    }

    @api handleRemovalUI(vistaData) {
        //console.log('entering remove row action');

        this.DUZnumber = JSON.parse(JSON.stringify(vistaData.signers[0].VCC_DUZ__c));
        this.removalDUZArray.push(this.DUZnumber);
        let removalIndex = this.updatedProviders.indexOf(this.DUZnumber);
        this.updatedProviders.splice(removalIndex, 1);

        this.fullData.forEach((record) => {
            //let providerRecord = {...record}
            if (record.VCC_StaffIEN__c == this.removalDUZArray[this.removalDUZArray.length - 1]) {
                record.rowIcon = "utility:add";
                record.rowVariant = "brand";
                record.disable = false;
            } else {
                record.rowIcon = "utility:add";
                record.rowVariant = "brand";
            }
        });

        this.fullData = [...this.fullData];
    }

    dispatchAddSignerEvent(vistaUser) {
        this.dispatchEvent(
            new CustomEvent("addsigners", {
                detail: {
                    records: [vistaUser]
                }
            })
        );
    }
}
