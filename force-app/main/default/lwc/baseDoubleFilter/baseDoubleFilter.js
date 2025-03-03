import { LightningElement, api } from "lwc";
import * as helper from "./baseDoubleFilterHelper";

export default class BaseDoubleFilter extends LightningElement {
    _list = []; // list to filter against, 'read only' property populated by setter
    _filterApiNames = []; // list of api names to filter on, 'read only' property populated by setter (ex: Year__c, import_month__c, ShippingState)

    requiredProperties = {
        list: false,
        filter: false
    };

    // uses the "every" array method to check if every required property is set to true
    validate() {
        return Object.values(this.requiredProperties).every((property) => property === true);
    }

    value1;
    value2;
    firstFilter;
    secondFilter;
    buttonState = true;
    secondFilterOptions;

    // chains the entries, filter and map array methods to grab all required properties that are missing
    // then throws an error indicating which required fields are missing or invalid using a template literal
    throwRequiredFieldsError() {
        const emptyFields = Object.entries(this.requiredProperties)
            .filter((entryArray) => entryArray[1] === false)
            .map((badProperty) => badProperty[0]);
        throw `Error: The following required properties are missing or invalid: [${emptyFields}]`;
    }

    // getters and setters
    @api
    set list(val) {
        if (val?.length) {
            // is truthy and not an empty array?
            this._list = val;
            this.requiredProperties.list = true;
        }
    }

    get list() {
        return this._list;
    }

    @api
    set filterApiNames(val) {
        if (val?.length) {
            // is truthy and not an empty array?
            this._filterApiNames = val;
            this.requiredProperties.filter = true;
        }
    }

    get filterApiNames() {
        return this._filterApiNames;
    }

    get firstFilterOptions() {
        if (this.filterApiNames.length === 1) this.setupForOneFilterApiNames();
        if (this.list) {
            return helper.buildFirstFilterOptions(helper.extractKeysFromList(this.list, this.filterApiNames));
        }

        return null;
    }

    handleFocus() {
        try {
            !this.validate() && this.throwRequiredFieldsError();
        } catch (error) {
            console.error(error);
        }
    }

    handleFirstChange(event) {
        this.value2 = null;
        this.firstFilter = event.detail.value;
        if (this.firstFilter !== "all") {
            this.secondFilterOptions = helper.buildSecondFilterOptions(this.list, this.firstFilter);
            this.buttonState = false;
        }
        if (this.firstFilter === "all") {
            this.secondFilterOptions = null;
            this.value2 = "";
            this.buttonState = true;
        }
        // console.log('this.firstFilter === \'all\': ', this.firstFilter === 'all');
        // this.firstFilter === 'all' ? this.buttonState = true : this.buttonState = false;
        // console.log('this.buttonState: ', this.buttonState);
        try {
            !this.validate() && this.throwRequiredFieldsError();
            this.dispatchEvent(new CustomEvent("filterlistbyfilter", { detail: this.list }));
        } catch (error) {
            console.error(error);
        }
    }

    handleSecondChange(event) {
        this.secondFilter = event.detail.value;
        try {
            !this.validate() && this.throwRequiredFieldsError();
            this.dispatchEvent(
                new CustomEvent("filterlistbyfilter", {
                    detail: this.returnFilteredList(this.list, this.firstFilter, this.secondFilter)
                })
            );
        } catch (error) {
            console.error(error);
        }
    }

    returnFilteredList(list, filter, term) {
        let filteredResults = [];
        list.forEach((element) => {
            if (element[filter].toString() === term.toString()) {
                filteredResults.push(element);
            }
        });
        return filteredResults;
    }

    setupForOneFilterApiNames() {
        this.value1 = this.filterApiNames[0];
        this.firstFilter = this.filterApiNames[0];
        this.buttonState = false;
        if (this.list) this.secondFilterOptions = helper.buildSecondFilterOptions(this.list, this.firstFilter);
    }
}
