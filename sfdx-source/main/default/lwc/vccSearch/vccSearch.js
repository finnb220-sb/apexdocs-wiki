/**
 * @description vccSearch is a generic search component used to allow selection of data that has been served in the form of an array of objects. Upon selection, the component will
 * return the entirety of the object selected to the implementing component via a custom event.Compatible with any flat array of objects. See vccClinicGroupLookup for an example implementation.
 * @author Booz Allen Hamilton
 * @since 5/1/2024
 */
import { LightningElement, api } from 'lwc';

export default class VccSearch extends LightningElement {
    //Interface properties
    @api iconName = 'standard:job_profile';
    @api displayField;
    @api keyField;
    @api searchLabel;
    @api searchType;
    @api isLoading;

    //Component properties
    selectedRecord;
    selectedKey;
    searchKey = null;
    message;
    _records;

    firstSearchPerformed = false;

    get records() {
        return this._records;
    }

    /**
     * @description setter for the records attribute. When the parent component retrieves new data and updates the records property, this setter will inject the displayField property
     * and the keyField property into the list of records that will be used to display in the vccSearch lwc. They will be instantiated with the value of the displayField and keyField properties that were
     * passed in from the parent component. This is the trick that allows this lwc to be used with any data source.
     */
    @api
    set records(value) {
        let searchRecords = [...value];
        if (searchRecords.length) {
            searchRecords = searchRecords.map((record) => {
                let rec = { ...record };
                rec.displayField = record[this.displayField];
                rec.keyField = record[this.keyField];
                return rec;
            });
            this._records = searchRecords;
            this.message = undefined;
        } else {
            this._records = this.firstSearchPerformed ? [] : undefined;
            this.message = this.firstSearchPerformed ? `No ${this.searchType} found` : undefined;
        }
    }

    /**
     * @description When a record is selected, it will set the selectedRecord property, clear out the searchKey, and call onSelectedRecord to publish the event.
     * @param {*} event
     */
    onRecordSelection(event) {
        this.selectedRecord = event.target.dataset;
        this.searchKey = '';
        this.onSelectedRecord();
    }

    /**
     * @description This method is called when a user selects a record using the spacebar or enter key. 508 compliance.
     * @param {*} event
     */
    onRecordSelectionKeyPress(event) {
        if (event.keyCode === 13 || event.keyCode === 32) {
            //13 is the Enter key 32 is spacebar
            this.selectedKey = event.target.dataset.key;
            this.searchKey = '';
            this.onSelectedRecord();
        }
    }

    /**
     * @description This method is called whenever the search key changes. It publishes a searchEvent to the parent component, to kick off a new retrieval of data.
     * @param {*} event
     */
    handleKeyChange(event) {
        this._records = undefined;
        this.searchKey = event.target.value;
        if (!this.firstSearchPerformed) {
            this.firstSearchPerformed = true;
        }
        if (this.searchKey.trim() !== '' && this.searchKey.length >= 3) {
            this.dispatchEvent(new CustomEvent('keychange', { detail: { searchKey: this.searchKey } }));
        }
    }

    /**
     * @description This method resets the component to a blank state.
     */
    removeSelection() {
        this.searchKey = '';
        this.selectedRecord = null;
        this._records = null;
    }

    /**
     * @description This method resets the component to a blank state for 508 compliance.
     */
    removeSelection508(event) {
        if (event.keyCode === 13 || event.keyCode === 32) {
            //13 is the Enter key 32 is spacebar
            this.searchKey = '';
            this.selectedRecord = null;
            this._records = null;
        }
    }

    /**
     * @description This method publishes an event that includes the entirety of the object that was selected.
     */
    onSelectedRecord(event) {
        let key = event?.target?.dataset?.key || this.selectedKey;
        this.selectedRecord = this.records.find((record) => record[this.keyField] === key);
        const selectEvent = new CustomEvent('select', {
            detail: {
                selectedRecord: this.selectedRecord
            }
        });
        this.dispatchEvent(selectEvent);
    }
}
