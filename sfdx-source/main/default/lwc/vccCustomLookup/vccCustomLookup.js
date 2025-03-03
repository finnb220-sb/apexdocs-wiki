/* eslint-disable @lwc/lwc/no-api-reassignments */
import { LightningElement, track, wire, api } from 'lwc';
import findRecords from '@salesforce/apex/VCC_LookupController.findRecords';
// Imported to catch events from lookup table
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterListener } from 'c/pubsub';

export default class VccCustomLookup extends LightningElement {
    @track recordsList;
    searchKey = null;
    @api userPersona;
    @api selectedValue;
    @api selectedRecordId;
    @api selectedRecordVisn;
    @api objectApiName;
    @api iconName = 'standard:job_profile';
    @api lookupLabel;
    @track message;
    @api recordId;
    siteId;
    pageRef;

    @wire(CurrentPageReference)
    wiredPageRef(pageRef) {
        this.pageRef = pageRef;
        if (this.pageRef) registerListener('siteChange', this.resetLookup, this);
    }

    resetLookup(event) {
        if (this.selectedRecordId) {
            this.removeRecordOnLookup(event);
        }
        this.siteId = event;
        this.getLookupResult();
    }

    disconnectedCallback() {
        unregisterListener('siteChange');
    }

    onLeave() {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            this.searchKey = '';
            this.recordsList = null;
        }, 3000);
    }

    onRecordSelection(event) {
        this.selectedRecordId = event.target.dataset.key;
        this.selectedValue = event.target.dataset.name;
        this.selectedRecordVisn = event.target.dataset.visn;
        this.searchKey = '';
        this.onSeletedRecordUpdate();
    }

    handleKeyChange(event) {
        var searchKey = event.target.value;
        this.searchKey = searchKey;
        this.getLookupResult();
    }

    removeRecordOnLookup() {
        this.searchKey = '';
        this.selectedValue = null;
        this.selectedRecordId = null;
        this.recordsList = null;
        this.onSeletedRecordUpdate();
    }

    getLookupResult() {
        if (!this.siteId) {
            this.recordsList = [];
            this.message = 'Please select a Site first';
        } else {
            findRecords({ siteId: this.siteId, searchParam: this.searchKey, persona: this.userPersona })
                .then((result) => {
                    if (result.length === 0) {
                        this.recordsList = [];
                        this.message = 'No Records Found';
                    } else {
                        this.recordsList = result;
                        this.message = '';
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
        const passEventr = new CustomEvent('recordselection', {
            detail: {
                selectedRecordId: this.selectedRecordId,
                selectedValue: this.selectedValue,
                selectedVisn: this.selectedRecordVisn
            }
        });
        this.dispatchEvent(passEventr);
    }
}
