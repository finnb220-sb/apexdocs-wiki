/**
 * @description This component is composed of 4 buttons and an indicator string "1 of 10" for pagination
 * @author Booz Allen
 */
import { LightningElement, api } from 'lwc';

export default class BasePaginationString extends LightningElement {
    _paginationString;
    _currentRecordIndex;
    _totalRecords;
    prevDisable;
    nextDisable;

    /**
     * @description Sets the Pagination String of the health data records from healthDataService.js
     * @param value The value of the Pagination String
     */

    @api
    set paginationString(value) {
        this._paginationString = value;
    }

    /**
     * @description Gets the Pagination String of the health data records that is set in the setter
     */
    get paginationString() {
        return this._paginationString;
    }

    /**
     * @description Sets the Pagination String of the health data records from healthDataService.js- gets called everytime the modal changes
     * @param value The value of the Pagination String
     */
    @api
    setPaginationString(value) {
        this._paginationString = value;
    }

    /**
     * @description Sets the current Index of the health data records from healthDataService.js
     * @param value The value of the current Index
     */

    @api
    set currentRecordIndex(value) {
        this._currentRecordIndex = value;
    }

    /**
     * @description Gets the current Index of the health data records from healthDataService.js
     */

    get currentRecordIndex() {
        return this._currentRecordIndex;
    }

    /**
     * @description Sets the current Index of the health data records from healthDataService.js gets called everytime the modal changes
     * @param value The value of the
     */
    @api
    setCurrentIndex(value) {
        this._currentRecordIndex = value;
    }

    /**
     * @description Sets the total count of the health data records from healthDataService.js
     * @param value The value of the total records
     */

    @api
    set totalRecords(value) {
        this._totalRecords = value;
    }

    /**
     * @description returns the total count of the health data records
     */

    get totalRecords() {
        return this._totalRecords;
    }

    /**
     * @description This immediately runs the toggleNavButtons() method whenever the navigation components gets loaded
     */
    connectedCallback() {
        this.toggleNavButtons();
    }

    /**
     * @description Handle navigation events for pagination
     * @param event
     */
    handleNav(event) {
        let direction;
        switch (event?.target?.dataset?.id) {
            case 'first':
                direction = 'first';
                break;
            case 'next':
                direction = 'next';
                break;
            case 'previous':
                direction = 'previous';
                break;
            case 'last':
                direction = 'last';
                break;
            default:
            // do nothing
        }
        this.dispatchEvent(
            new CustomEvent('navclick', {
                bubbles: true,
                composed: true,
                detail: { operation: { name: 'nav', direction: direction } }
            })
        );
        this.toggleNavButtons();
    }

    /**
     * @description Enables/disables pagination buttons depending on index of current page
     */

    toggleNavButtons() {
        this.prevDisable = this.currentRecordIndex === 0;
        this.nextDisable = this.currentRecordIndex === this.totalRecords - 1;
    }

    /**
     * @description Dispatches a close event to the parent component
     */
    handleClose() {
        this.dispatchEvent(
            new CustomEvent('close', {
                bubbles: true,
                composed: true,
                detail: { operation: { name: 'close' } }
            })
        );
    }
}
