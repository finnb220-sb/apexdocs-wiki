/**
 * @description This component is a container for the actions that are housed in the "actions" slot of a lightning-datatble
 * @author Booz Allen
 */
import { LightningElement, api } from 'lwc';
import hasCanUseLoadMorePermission from '@salesforce/customPermission/VCC_Can_Use_Load_More';

export default class VccHdrDatatableActions extends LightningElement {
    @api showAddToNote = false;
    @api showLoadMore;
    isLoading = false;
    _options;
    @api placeholderString = 'Select a year to load';
    @api isOnProgressNote = false;
    @api selectedValue = '';

    /**
     * @description sets the options for the combobox
     * @param value
     */
    @api
    set options(value) {
        this._options = value;
    }

    get options() {
        return this._options;
    }

    get canUseLoadMore() {
        // checking to see if the showLoadMore value was set to false by the very unique scenarios (default is to be on)
        return hasCanUseLoadMorePermission && (this.showLoadMore === undefined || this.showLoadMore);
    }

    /**
     * @description dispatches the reload health data event for cache refreshing
     */
    handleReload() {
        this.dispatchEvent(new CustomEvent('reloadhealthdata', { bubbles: true, composed: true }));
    }

    /**
     * @description dispatches the add to note event for components that require add to note functionality
     */
    handleAddToNote() {
        this.dispatchEvent(new CustomEvent('addtonote', { bubbles: true, composed: true }));
    }

    /**
     * @description sets the combobox and dispatches a load more event
     * @param event - year that was selected to load back to
     */
    handleDispatchLoadMore(event) {
        const { value } = event.detail;
        this.refs.loadMoreCombobox.value = +value; // casting to a number
        this.dispatchEvent(new CustomEvent('loadmore', { detail: { value }, bubbles: true, composed: true }));
    }
    /**
     * @description enables a parent component to set the options for the combobox programatically
     * @param options - list of javascript objects with key value pairs for the load more combobox
     */
    @api
    setOptions(options) {
        this._options = options;
    }

    /**
     * @description sets the loading state of the component
     * @param isLoading - `boolean` value of whether the component is loading
     */
    @api
    setLoading(isLoading) {
        this.isLoading = isLoading;
    }
}
