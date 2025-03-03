/**
 * @description vccClinicLookup is used to search for Clinic records. It implements the generic vccSearch component to search and select the data. This components purpose is to serve the
 * data to the vccSearch component, and pass the selected data back to its own parent component when received.
 * @author Booz Allen Hamilton
 * @since 5/1/2024
 */
import { LightningElement, api, track } from 'lwc';
import getClinicsByNameVTC from '@salesforce/apex/VCC_ClinicSearchController.getClinicsByName';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { debounce } from 'c/bahToolKit';

export default class VccClinicLookup extends LightningElement {
    //vccSearch settings
    displayField = 'name';
    keyField = 'id';
    searchLabel = 'Clinic Search';
    searchType = 'clinics';
    iconName = 'standard:job_profile';
    clinicRecords = [];
    searchKey = null;
    error;
    //public properties
    @api siteId = null;
    @track isLoading = false;

    //Debounce delay in milliseconds
    debounceTimeMs = 1000;

    connectedCallback() {
        // Initialize Debounce
        this.debouncedSearch = debounce((searchText) => this.searchClinicsVTC(searchText), this.debounceTimeMs);
    }

    /**
     * @description searchClinics is called whenever a key change event is received from vccSearch.
     *  It retrieves new data utilizing the VTC Framework for the CHRONOS Provider.
     */
    searchClinicsVTC() {
        this.isLoading = true;
        getClinicsByNameVTC({ clinicName: this.searchKey, siteId: this.siteId })
            .then((result) => {
                if (result.length === 0) {
                    throw new Error('Clinic search result is not an Array');
                } else {
                    this.clinicRecords = result;
                    this.isLoading = false;
                }
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.clinicRecords = [];
                this.isLoading = false;
            });
    }

    /**
     * @description When a key change event is received from vccSearch, this method is called. It sets the search key for the new search, then kicks off the data retrieval. If search key is null/undefined
     * it clears the clinicRecords property
     * @param {Object} event
     */
    handleKeyChange(event) {
        this.searchKey = event.detail.searchKey.toUpperCase();
        this.debounceSearchClinics();
    }
    /**
     * @description Called each time this.searchKey is changed. Debounces the searchClinicsVTC function.
     * @returns nothing/null
     */
    debounceSearchClinics() {
        if (typeof this.searchKey !== 'string' || this.searchKey.length < 3) {
            window.clearTimeout(this.debouncedSearch.timeout);
            this.clinicRecords = [];
            return;
        }
        this.debouncedSearch(this.searchKey);
    }

    /**
     * @description When a record is selected in vccSearch, a select event is published. This handler will be called to publish the selected data again to its parent component.
     * @param {Object} event
     */
    handleSelectClinic(event) {
        let clinic = event.detail.selectedRecord;
        let selectedClinicEvent = new CustomEvent('selectedclinic', {
            detail: { selectedClinic: clinic }
        });
        this.dispatchEvent(selectedClinicEvent);
    }

    /**
     * @description postError is a helper function that will take in a message variable and publish a toast that contains the message.
     * @param {String} message The message to display in the error
     */
    postError(message) {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error'
        });
        this.dispatchEvent(evt);
    }
}
