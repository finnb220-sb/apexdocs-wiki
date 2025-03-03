import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import search from "@salesforce/apex/PC_LookupController.search";
import getSomeResults from "@salesforce/apex/PC_LookupController.getSomeResults";
import insertShift from "@salesforce/apex/pcScheduleShiftsController.insertShift";

export default class PcScheduleShifts extends LightningElement {
    // Use alerts instead of toasts (LEX only) to notify user
    @api notifyViaAlerts = false;
    _pcServiceId;
    pcServiceMemberId;
    @api get pcServiceId() {
        return this._pcServiceId;
    }
    set pcServiceId(_pcServiceId) {
        this._pcServiceId = _pcServiceId;
    }

    isMultiEntry = false;
    minDate = new Date().toISOString().slice(0, 10);
    maxSelectionSize = 1;
    initialSelection = [];
    errors = [];
    recentlyViewed = [];
    newRecordOptions = [{ value: "PC_Service_Team_Member__c", label: "New Service Team Member" }];

    connectedCallback() {
        setTimeout(() => {
            if (this._pcServiceId) {
                this.handleGetSomeResults();
            }
        }, 1000);
    }
    handleGetSomeResults() {
        getSomeResults({ serviceId: this._pcServiceId })
            .then((results) => {
                if (results) {
                    this.recentlyViewed = results;
                    this.initLookupDefaultResults();
                }
            })
            .catch((error) => {
                this.notifyUser("Lookup Error", "An error occured while searching with the lookup field.", "error");
                // eslint-disable-next-line no-console
                console.error("Lookup error", JSON.stringify(error));
                this.errors = [error];
            });
    }

    /**
     * Initializes the lookup default results with a list of recently viewed records (optional)
     */
    initLookupDefaultResults() {
        // Make sure that the lookup is present and if so, set its default results
        const lookup = this.template.querySelector("c-lookup");
        if (lookup) {
            lookup.setDefaultResults(this.recentlyViewed);
        }
    }

    /**
     * Handles the lookup search event.
     * Calls the server to perform the search and returns the resuls to the lookup.
     * @param {event} event `search` event emmitted by the lookup
     */
    handleLookupSearch(event) {
        const lookupElement = event.target;
        // Call Apex endpoint to search for records and pass results to the lookup

        let searchTerm = event.detail.searchTerm;
        search({ searchTerm: searchTerm, serviceId: this._pcServiceId })
            .then((results) => {
                lookupElement.setSearchResults(results);
            })
            .catch((error) => {
                this.notifyUser("Lookup Error", "An error occured while searching with the lookup field.", "error");
                // eslint-disable-next-line no-console
                console.error("Lookup error", JSON.stringify(error));
                this.errors = [error];
            });
    }

    /**
     * Handles the lookup selection change
     * @param {event} event `selectionchange` event emmitted by the lookup.
     * The event contains the list of selected ids.
     */
    // eslint-disable-next-line no-unused-vars
    handleLookupSelectionChange(event) {
        this.checkForErrors();
        if (this.errors.length === 0) {
            this.pcServiceMemberId = event.detail[0];
            const selectedEvent = new CustomEvent("select", { detail: event.detail[0] });
            this.dispatchEvent(selectedEvent);
        }
    }

    handleLookupTypeChange(event) {
        this.initialSelection = [];
        this.errors = [];
        this.isMultiEntry = event.target.checked;
    }

    handleMaxSelectionSizeChange(event) {
        this.maxSelectionSize = event.target.value;
    }

    handleSubmit() {
        this.checkForErrors();
        if (this.errors.length === 0) {
            let shiftDate = this.template.querySelector('[data-id="shiftDate"]');
            let startTimeField = this.template.querySelector('[data-id="startTime"]');
            let endTimeField = this.template.querySelector('[data-id="endTime"]');
            let startTime = startTimeField.value;
            let endTime = endTimeField.value;
            let dateSelected = shiftDate.value ? new Date(shiftDate.value) : null;
            if (endTime < startTime) {
                this.notifyUser("Error", "The Shift End Time cannot be less than the Start Time. If this is for third shift, use two shift records.", "error");
            } else if (!dateSelected) {
                shiftDate.setCustomValidity("Date is required");
                this.notifyUser("Error", "Please supply a date of the shift.", "error");
            } else if (dateSelected < new Date(this.minDate)) {
                this.notifyUser("Error", "Date must not be in the past.", "error");
            } else {
                shiftDate.setCustomValidity("");
                let month, day, year;
                let date = new Date();
                month = date.getMonth() + 1;
                day = date.getDate();
                year = date.getFullYear();
                let strDate = month + "/" + day + "/" + year;
                let pcShiftMap = {};
                pcShiftMap.pcServiceId = this._pcServiceId;
                pcShiftMap.pcServiceMemberId = this.pcServiceMemberId;
                pcShiftMap.startTime = startTime;
                pcShiftMap.endTime = endTime;
                pcShiftMap.shiftDate = dateSelected;
                pcShiftMap.startDay = strDate;
                insertShift(pcShiftMap)
                    .then((results) => {
                        this.notifyUser("Success", "Shift has been created", "success");
                        const selectedEvent = new CustomEvent("insertshift", { detail: results });
                        this.dispatchEvent(selectedEvent);
                        this.template.querySelector('[data-id="shiftDate"]').value = "";
                    })
                    .catch((error) => {
                        this.notifyUser("Error", "An error occured while trying to insert the Shift: " + error.body ? error.body.message : error.message, "error");
                    });
            }
            shiftDate.reportValidity();
        }
    }

    checkForErrors() {
        this.errors = [];
        const selection = this.template.querySelector("c-lookup").getSelection();
        // Custom validation rule
        if (this.isMultiEntry && selection.length > this.maxSelectionSize) {
            this.errors.push({ message: `You may only select up to ${this.maxSelectionSize} items.` });
        }
        // Enforcing required field
        if (selection.length === 0) {
            this.errors.push({ message: "Please make a selection." });
        }
    }

    notifyUser(title, message, variant) {
        if (this.notifyViaAlerts) {
            // Notify via alert
            // eslint-disable-next-line no-alert
            alert(`${title}\n${message}`);
        } else {
            // Notify via toast (only works in LEX)
            const toastEvent = new ShowToastEvent({ title, message, variant });
            this.dispatchEvent(toastEvent);
        }
    }
}
