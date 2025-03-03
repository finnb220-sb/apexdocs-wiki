import { LightningElement, track, wire, api } from "lwc";
import findRecords from "@salesforce/apex/tucLookupController.findRecords";
// Imported to catch events from lookup table
import { CurrentPageReference } from "lightning/navigation";
import { registerListener, unregisterListener } from "c/pubsub";

export default class TucCustomLookup extends LightningElement {
    @track recordsList;
    searchKey = null;
    @api userPersona;
    @api selectedValue;
    @api selectedRecordId;
    @api objectApiName;
    @api iconName = "standard:job_profile";
    @api lookupLabel;
    @track message;
    @api recordId;
    siteId;
    pageRef;

    @wire(CurrentPageReference)
    wiredPageRef(pageRef) {
        this.pageRef = pageRef;
        if (this.pageRef) registerListener("siteChange", this.resetLookup, this);
    }

    resetLookup(event) {
        console.log("siteId from event ", event);
        this.siteId = event;
        this.removeRecordOnLookup(event);
    }

    disconnectedCallback() {
        unregisterListener("siteChange");
    }

    onLeave() {
        setTimeout(() => {
            this.searchKey = "";
            this.recordsList = null;
        }, 3000);
    }

    onRecordSelection(event) {
        this.selectedRecordId = event.target.dataset.key;
        this.selectedValue = event.target.dataset.name;
        this.searchKey = "";
        this.onSeletedRecordUpdate();
    }

    handleKeyChange(event) {
        var searchKey = event.target.value;
        this.searchKey = searchKey;
        this.getLookupResult();
    }

    removeRecordOnLookup() {
        this.searchKey = "";
        this.selectedValue = null;
        this.selectedRecordId = null;
        this.recordsList = null;
        this.onSeletedRecordUpdate();
    }

    getLookupResult() {
        if (!this.siteId) {
            this.recordsList = [];
            this.message = "Please select a Site first";
        } else {
            findRecords({ siteId: this.siteId, searchParam: this.searchKey, persona: this.userPersona })
                .then((result) => {
                    if (result.length === 0) {
                        this.recordsList = [];
                        this.message = "No Records Found";
                    } else {
                        this.recordsList = result;
                        this.message = "";
                    }
                    this.error = undefined;
                })
                .catch((error) => {
                    this.error = error;
                    this.recordsList = undefined;
                });
        }
    }

    onSeletedRecordUpdate() {
        const passEventr = new CustomEvent("recordselection", {
            detail: { selectedRecordId: this.selectedRecordId, selectedValue: this.selectedValue }
        });
        this.dispatchEvent(passEventr);
    }
}
