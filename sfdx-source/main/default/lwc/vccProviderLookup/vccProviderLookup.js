/**
 * @description vccProviderLookup is used to search for Provider records. It implements the generic vccSearch component to search and select the data. This components purpose is to serve the
 * data to the vccSearch component, and pass the selected data back to its own parent component when received.
 * @author Booz Allen Hamilton
 * @since 8/7/2024
 */
import { LightningElement, api, track } from 'lwc';
import searchProvidersVTC from '@salesforce/apex/VCC_ProviderSearchController.searchProviders';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { debounce } from 'c/bahToolKit';

export default class VccProviderLookup extends LightningElement {
    //vccSearch settings
    displayField = 'name';
    keyField = 'ien';
    searchLabel = 'Provider Search';
    searchType = 'providers';
    iconName = 'standard:employee_job';
    providerRecords = [];
    searchKey = null;
    error;
    //public properties
    @api siteId = null;
    @track isLoading = false;

    //Debounce delay in milliseconds
    debounceTimeMs = 1000;

    connectedCallback() {
        // Initialize Debounce
        this.debouncedSearch = debounce((searchText) => this.searchProvidersVTC(searchText), this.debounceTimeMs);
    }

    /**
     * @description searchProviders is called whenever a key change event is received from vccSearch.
     *  It retrieves new data utilizing the VTC Framework for the CHRONOS endpoint.
     */
    searchProvidersVTC() {
        this.isLoading = true;
        searchProvidersVTC({ providerName: this.searchKey, siteId: this.siteId })
            .then((result) => {
                if (result.length === 0) {
                    throw new Error('Provider search result is not an Array');
                } else {
                    this.providerRecords = result;
                    this.isLoading = false;
                }
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.providerRecords = [];
                this.isLoading = false;
            });
    }

    /**
     * @description When a key change event is received from vccSearch, this method is called. It sets the search key for the new search, then kicks off the data retrieval. If search key is null/undefined
     * it clears the providerRecords property
     * @param {Object} event
     */
    handleKeyChange(event) {
        this.searchKey = event.detail.searchKey.toUpperCase();
        this.debounceSearchProviders();
    }
    /**
     * @description Called each time this.searchKey is changed. Debounces the searchProvider function.
     * @returns nothing/null
     */
    debounceSearchProviders() {
        if (typeof this.searchKey !== 'string' || this.searchKey.length < 3) {
            window.clearTimeout(this.debouncedSearch.timeout);
            this.providerRecords = [];
            return;
        }
        this.debouncedSearch(this.searchKey);
    }

    /**
     * @description When a record is selected in vccSearch, a select event is published. This handler will be called to publish the selected data again to its parent component.
     * @param {Object} event
     */
    handleSelectProvider(event) {
        let provider = event.detail.selectedRecord;
        let selectedProviderEvent = new CustomEvent('selectedprovider', {
            detail: { selectedProvider: provider }
        });
        this.dispatchEvent(selectedProviderEvent);
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
