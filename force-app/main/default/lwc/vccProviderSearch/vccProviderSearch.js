/**
 * @author Booz Allen Hamilton
 * @date 04/30/2024
 * @description Component that is utilized to search for Providers based on the displayed Clinic's IEN.
 */

import { LightningElement, track, api } from 'lwc';

export default class VccProviderSearch extends LightningElement {
    @api iconName = 'standard:employee_job';
    _clinicIEN;
    providerId;
    @track filteredProviderList;
    searchKey = null;
    message;
    isLoading;
    @track fullProviderList;
    _selectedProviderName;

    @api
    get selectedProviderName() {
        return null;
    }
    set selectedProviderName(valueProviderName) {
        if (valueProviderName) {
            this._selectedProviderName = valueProviderName;
        }
    }

    @api
    get clinicIEN() {
        return null;
    }
    set clinicIEN(valueClinicIEN) {
        if (valueClinicIEN) {
            this._clinicIEN = valueClinicIEN;
            this.filteredProviderList = null;
        }
    }

    /**
     * @description When Drop down selection is made, values of that selection are stored.
     */
    onProviderSelection(event) {
        this.providerId = event.target.dataset.key;
        this._selectedProviderName = event.target.dataset.name;
        this.searchKey = null;
        this.handleProviderTimeSlotSearch();
    }
    /**
     * @description When Drop down selection is made, values of that selection are stored.
     */
    onProviderSelectionKeyPress(event) {
        if (event.keyCode === 13 || event.keyCode === 32) {
            this.providerId = event.target.dataset.key;
            this._selectedProviderName = event.target.dataset.name;
            this.searchKey = null;
            this.handleProviderTimeSlotSearch();
        }
    }
    /**
     * @description When button is pressed provider Data is dispatched for use in vccScheduleAppointmentRequest
     */
    handleProviderTimeSlotSearch() {
        const providerEvent = new CustomEvent('providerselect', {
            detail: {
                providerId: this.providerId,
                providerName: this._selectedProviderName
            }
        });
        this.dispatchEvent(providerEvent);
    }
    /**
     * @description Sets value of typed words, and filters down list of providers.
     */
    handleKeyChange(event) {
        var searchedKey = event.target.value;
        if (searchedKey === '') {
            this.searchKey = null;
            this.providerId = null;
            this.filteredProviderList = null;
            this._selectedProviderName = null;
        } else {
            this.searchKey = searchedKey;
            this.filterProviders();
        }
    }
    /**
     * @description Removes Selected Provider so another option can be chosen.
     */
    removeSelection() {
        this.searchKey = null;
        this.providerId = null;
        this.filteredProviderList = null;
        this._selectedProviderName = null;
    }
    /**
     * @description Filters ProviderList based on searchkey value.
     */
    filterProviders() {
        if (this.searchKey) {
            this.filteredProviderList = this.fullProviderList.filter((provider) =>
                provider?.VCC_Provider__r.Name.includes(this.searchKey)
            );
        } else {
            this.filteredProviderList = this.fullProviderList;
        }
    }
}
