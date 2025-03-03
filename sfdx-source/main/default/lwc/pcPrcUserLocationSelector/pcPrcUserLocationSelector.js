import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import UserId from '@salesforce/user/Id';

import getPrcUser from '@salesforce/apex/PC_PrcUserLocationSelectorController.getPrcUser';
import savePrcUser from '@salesforce/apex/PC_PrcUserLocationSelectorController.savePrcUser';

export default class PcPrcUserLocationSelector extends LightningElement {
    recordPickerLabel = 'Current Referring Provider Site';
    recordPickerPlaceholder = 'Search Locations...';
    recordPickerHelpText = 'Select your Home VA Facility';

    showSpinner = false;
    progressLabel = 'Saving Location...';

    wiredPrcUser;

    //Current PrC User record for the current running FLP user that holds its location Ids
    @track prcUser = {
        Current_Location__c: null,
        Id: null,
        User_ID__c: UserId
    };
    //Current location Id selected in location record picker component
    selectedUserLocationId = null;

    locDisplayInfo = {
        primaryField: 'Name',
        additionalFields: ['Common_Name__c']
    };

    locMatchingInfo = {
        primaryField: { fieldPath: 'Name' },
        additionalFields: [{ fieldPath: 'Common_Name__c' }]
    };

    locFilter = {
        criteria: [
            {
                fieldPath: 'VAF_Facility_Type__c',
                operator: 'eq',
                value: 'va_health_facility'
            }
        ]
    };

    /**
     * Wired function to retrieve the running user's respective PrC User
     * and, if it exists, set the selected Location to its Current Location value
     * @param {Id} UserId the running user's salesforce Id
     */

    @wire(getPrcUser, { userId: UserId })
    fetchPrcUser(result) {
        this.wiredPrcUser = result;
        if (result.data) {
            this.prcUser = { ...result.data };
            this.selectedUserLocationId = this.prcUser.Current_Location__c;
            const selectedEvent = new CustomEvent('locationchanged', { detail: { prcUser: this.prcUser } });
            this.dispatchEvent(selectedEvent);
        } else if (result.error) {
            this.handleError(result.error, "Error loading user's location");
        }
    }

    /**
     * Used to display the Save button when the selected location differs from the PrC User field value for Current Location
     */
    get userLocationHasChanged() {
        return this.selectedUserLocationId && this.prcUser?.Current_Location__c !== this.selectedUserLocationId;
    }

    /**
     * On change handler for the location record picker
     * Sets the selected location to the recordId of the user's selection
     * @param {Object} event the on change event
     */
    handleOnChangeCurrentLocation(event) {
        this.selectedUserLocationId = event.detail.recordId;
    }

    /**
     * On blur handler for the location record picker
     * Resets the selected location back to the current location
     */
    handleOnBlurCurrentLocation() {
        //Reset back to current database Location value if focus moves away from record picker with no location selected
        if (!this.selectedUserLocationId) {
            this.selectedUserLocationId = this.prcUser.Current_Location__c;
        }
    }

    /**
     * Handles the Save button press
     * Sends the prcUser to be upserted via apex controller
     */
    handleSaveCurrentLocation() {
        this.showSpinner = true;
        const originalLocationId = this.prcUser.Current_Location__c;
        this.prcUser.Current_Location__c = this.selectedUserLocationId;

        if (!this.refs.locationRecordPicker.checkValidity()) {
            this.refs.locationRecordPicker.reportValidity();
            this.showSpinner = false;
            return;
        }

        savePrcUser({ prcUser: this.prcUser })
            .then((result) => {
                this.prcUser = result;
                const selectedEvent = new CustomEvent('locationchanged', { detail: { prcUser: this.prcUser } });
                this.dispatchEvent(selectedEvent);
            })
            .catch((error) => {
                this.handleError(error, "Error saving user's location");
                this.prcUser.Current_Location__c = originalLocationId;
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    /**
     * Handles errors
     * @param {Object} error the error response object
     * @param {String} toastTitle title of the toast error message
     */
    handleError(error, toastTitle) {
        let messageStr = 'Unknown error';
        if (Array.isArray(error.body)) {
            messageStr = error.body.map((err) => err.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            //Grab message value from error.body.message using object destructuring
            const {
                body: { message }
            } = error;
            messageStr = message;
        }
        this.dispatchEvent(
            new ShowToastEvent({
                message: messageStr,
                title: toastTitle,
                variant: 'error'
            })
        );
    }

    /**
     * Checks that the input of the record picker is valid
     * Can be called from parent component
     */
    @api isValid() {
        let isValid = true;
        if (!this.refs.locationRecordPicker.checkValidity()) {
            this.refs.locationRecordPicker.reportValidity();
            isValid = false;
        }
        return isValid;
    }
}
