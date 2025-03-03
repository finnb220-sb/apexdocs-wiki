import { LightningElement, api, track } from "lwc";
import { search } from "./baseSearchBarHelper";
import { proxyTool } from "c/helpersLWC";

export default class BaseSearchBar extends LightningElement {
    _list = []; // list to filter against, 'read only' property populated by setter
    _propsToSearch = []; // comparison field, 'read only' property populated by setter

    @api
    settings = {
        label: "Search", // defaults to search
        variant: "standard" // defaults to standard
    }; // defaults to standard

    requiredProperties = {
        list: false
    };

    // uses the "every" array method to check if every required property is set to true
    validate() {
        return Object.values(this.requiredProperties).every((property) => property === true);
    }

    connectedCallback() {
        // !this.validate() && this.throwRequiredFieldsError();
    }

    /**
     * @description current time between keystrokes in MS
     * @member Double
     */

    timeout = null;

    /**
     * @description current string to search
     * @member String
     */
    searchValue;

    /**
     * @description Wraps an HTML event so that set timeout can access and execute for debouncing
     * @member Object
     */

    @track
    searchEvent;

    // search = performanceLogDecorator(search);
    // Dispatches event with a filtered array if the validate function evaluates to true, else it throws a handled error

    handleChange(event) {
        this.searchEvent = { value: event.target?.value, keyCode: event.keyCode };
        let searchReturn = [];

        clearTimeout(this.timeout);

        this.timeout = setTimeout(
            function () {
                try {
                    if (this.searchEvent?.value?.length < 3) {
                        searchReturn = null;
                    } else {
                        searchReturn = JSON.stringify(this.returnFilteredList(this.searchEvent));
                    }

                    const evt = new CustomEvent("filterlistbysearch", { composed: true, detail: searchReturn });
                    this.dispatchEvent(evt); // dispatching filtered array;
                    return;
                } catch (error) {
                    console.error(error);
                }
            }.bind(this),
            500
        ); // TODO: move this over to custom metadata
    }

    // clear the values input values from a parent component
    @api
    clear() {
        this.template.querySelectorAll("lightning-input").forEach((input) => (input.value = null));
    }

    // Invokes and returns output of imported search helper function
    returnFilteredList(event) {
        return search(this._list, event.value, this._propsToSearch);
    }

    // chains the entries, filter and map array methods to grab all required properties that are missing
    // then throws an error indicating which required fields are missing or invalid using a template literal
    throwRequiredFieldsError() {
        const emptyFields = Object.entries(this.requiredProperties)
            .filter((entryArray) => entryArray[1] === false)
            .map((badProperty) => badProperty[0]);
        throw new Error(`Error: The following required properties are missing or invalid: [${emptyFields}]`); // template literal
    }

    @api
    inputLength() {
        return this.template.querySelector("lightning-input").value.length;
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
    set propsToSearch(val) {
        if (val?.length) {
            // is truthy and not an empty array?
            this._propsToSearch = val;
            this.requiredProperties.searchString = true;
        }
    }

    get propsToSearch() {
        return this._propsToSearch;
    }

    @api
    setSettings(settings) {
        for (const [key, value] of Object.entries(settings)) {
            if (Object.keys(this.settings).includes(key)) {
                settings[key] = value;
            }
        }
    }
}
