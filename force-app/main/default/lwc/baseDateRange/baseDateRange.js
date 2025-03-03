import { LightningElement, api, track } from "lwc";
import * as helper from "./baseDateRangeHelper";

export default class BaseDateRange extends LightningElement {
    _list = []; // list to filter against, 'read only' property populated by setter
    _field = null; // comparison field, 'read only' property populated by setter

    requiredProperties = {
        list: false,
        field: false
    };

    // clear the values input values from a parent component
    @api
    clear() {
        this.template.querySelectorAll("lightning-input").forEach((input) => (input.value = null));
    }

    // uses the "every" array method to check if every required property is set to true
    validate() {
        return Object.values(this.requiredProperties).every((property) => property === true);
    }

    // Dispatches event with a filtered array if the validate function evaluates to true, else it throws a handled error
    handleChange(event) {
        try {
            !this.validate() && this.throwRequiredFieldsError();
            this.dispatchEvent(new CustomEvent("filterlistbydate", { detail: this.returnFilteredList() })); // dispatching filtered array
        } catch (error) {
            console.error(error);
        }
    }

    // Invokes and returns output of betweenTwoDates helper function
    returnFilteredList() {
        return helper.betweenTwoDates({
            start: this.template.querySelector("[data-id='start']").value || null,
            end: this.template.querySelector("[data-id='end']").value || null,
            list: this.list,
            field: this.field
        });
    }

    // chains the entries, filter and map array methods to grab all required properties that are missing
    // then throws an error indicating which required fields are missing or invalid using a template literal
    throwRequiredFieldsError() {
        const emptyFields = Object.entries(this.requiredProperties)
            .filter((entryArray) => entryArray[1] === false)
            .map((badProperty) => badProperty[0]);
        throw `Error: The following required properties are missing or invalid: [${emptyFields}]`; // template literal
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
    set field(val) {
        // comparison field
        if (val) {
            this._field = val;
            this.requiredProperties.field = true;
        }
    }

    get field() {
        return this._field;
    }

    @api
    inputsAreBlank() {
        return [...this.template.querySelectorAll("lightning-input")].every((val) => !val.value);
    }
}
