/**
 * @description vccClinicGroupLookup is used to search for Clinic Group records. It implements the generic vccSearch component to search and select the data. This components purpose is to serve the
 * data to the vccSearch component, and pass the selected data back to its own parent component when received.
 * @author Booz Allen Hamilton
 * @since 5/1/2024
 */
import { LightningElement, api } from 'lwc';
import searchClinicGroups from '@salesforce/apex/VCC_ClinicGroupSearchController.searchClinicGroups';
import getClinicGroup from '@salesforce/apex/VCC_ClinicGroupSearchController.getClinicGroup';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { debounce } from 'c/bahToolKit';

export default class VccClinicGroupLookup extends LightningElement {
    //vccSearch settings
    displayField = 'name';
    keyField = 'ien';
    searchLabel = 'Clinic Group Search';
    iconName = 'standard:record';
    clinicGroupRecords = [];
    searchKey = null;
    error;
    //public properties
    @api siteId = null;
    isLoading = false;

    /**
     * @description searchClinicGroups is called whenever a key change event is received from vccSearch. It retrieves new data to send into vccSearch for selection.
     */
    async searchClinicGroups() {
        try {
            let result = await searchClinicGroups({ siteId: this.siteId, groupName: this.searchKey });
            if (!Array.isArray(result)) {
                throw new Error('Clinic group search result is not an Array');
            }
            this.clinicGroupRecords = result.flatMap((group) => {
                if (
                    (typeof group.ien !== 'string' || group.ien === '') &&
                    (typeof group.name !== 'string' || group.name === '')
                ) {
                    return [];
                }
                return group;
            });
            this.error = undefined;
        } catch (error) {
            this.error = error;
            this.postError('Failed to retrieve Clinic Groups.');
            this.clinicGroupRecords = []; // changed this from undefined to an empty array. undefined was causing the toast to not display because vccSearch errored
            this.isLoading = false;
        } finally {
            this.isLoading = false;
        }
    }

    /**
     * @description When a key change event is received from vccSearch, this method is called. It sets the search key for the new search, then kicks off the data retrieval.
     * @param {*} event
     */
    handleKeyChange(event) {
        this.searchKey = event.detail.searchKey;
        this.isLoading = true;
        this.debounceSearchClinicGroups();
    }

    debounceSearchClinicGroups = debounce(() => {
        if (typeof this.searchKey !== 'string' || this.searchKey.length < 3 || this.searchKey.length > 30) {
            this.clinicGroupRecords = [];
            this.isLoading = false;
            return;
        }
        this.searchClinicGroups();
    }, 1000);

    /**
     * @description When a record is selected in vccSearch, a select event is published. This handler will be called to publish the selected data again to its parent component.
     * @param {*} event
     */
    async handleSelectClinicGroup(event) {
        let selectedGroup = event.detail.selectedRecord;
        try {
            let clinicGroup = await getClinicGroup({ siteId: this.siteId, groupIen: selectedGroup?.ien });
            console.log(JSON.stringify(clinicGroup));
            if (!Array.isArray(clinicGroup?.resources)) {
                throw new Error(
                    'Clinic group does not contain any clinics or an error occurred. Please try again or modify your selection.'
                );
            }
            let selectedClinicGroupEvent = new CustomEvent('selectedclinicgroup', {
                detail: { selectedClinicGroup: clinicGroup }
            });
            this.dispatchEvent(selectedClinicGroupEvent);
        } catch (error) {
            this.postError(error);
        }
    }

    /**
     * @description postError is a helper function that will take in a message variable and publish a toast that contains the message.
     * @param {*} message The message to display in the error
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
