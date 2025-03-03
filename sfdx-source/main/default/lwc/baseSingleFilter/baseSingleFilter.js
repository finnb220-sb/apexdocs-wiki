import { LightningElement, api } from "lwc";
import * as helper from "./baseSingleFilterHelper";

export default class BaseSingleFilter extends LightningElement {
    _list = []; //? list to filter against, 'read only' property populated by setter
    _filterApiName = []; //? string of api names to filter on
    _filterLabel;

    placeholderString;
    filterValue;
    value = "";

    requiredProperties = {
        list: false,
        filter: false
    };

    //? uses the "every" array method to check if every required property is set to true
    validate() {
        return Object.values(this.requiredProperties).every((property) => property === true);
    }

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
    set filterLabel(val) {
        // this.placeholderString = `Select a(n) ${val}`;
        this._filterLabel = val;
    }

    get filterLabel() {
        return this._filterLabel;
    }

    @api
    set filterApiName(val) {
        if (val.length) {
            // checking the length of the string
            this._filterApiName = val;
            this.requiredProperties.filter = true;
        }
    }

    get filterApiName() {
        return this._filterApiName;
    }

    get filterOptions() {
        return helper.buildFilterOptions(this.list, this.filterApiName);
    }

    @api
    setValue(string) {
        this.template.querySelector("lightning-combobox").value = string;
    }

    handleFilterChange(event) {
        this.filterValue = event.detail.value;
        try {
            !this.validate() && this.throwRequiredFieldsError();
            this.dispatchEvent(
                new CustomEvent("filterlistbyfilter", {
                    detail: this.returnFilteredList(this.list, this.filterApiName, this.filterValue)
                })
            );
        } catch (error) {
            //
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

    //? chains the entries, filter and map array methods to grab all required properties that are missing
    //? then throws an error indicating which required fields are missing or invalid using a template literal
    throwRequiredFieldsError() {
        const emptyFields = Object.entries(this.requiredProperties)
            .filter((entryArray) => entryArray[1] === false)
            .map((badProperty) => badProperty[0]);
        throw `Error: The following required properties are missing or invalid: [${emptyFields}]`;
    }
}
