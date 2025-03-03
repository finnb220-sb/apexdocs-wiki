/**
 * @author Booz Allen Hamilton
 * @description Displays flags in a table given a PersonAccount, Case, or Progress Note record Id
 */
import { LightningElement, track, api, wire } from 'lwc';
import getFlags from '@salesforce/apex/VCC_FlagsController.getFlags';
import { healthDataService } from 'c/services';
import { datatableHelper, dateFormatter } from 'c/utils';
import { transformFlagsData } from 'c/vccFlagsDataTransformer';

export default class VccFlags extends LightningElement {
    @api useMockData; //deprecated do not use
    @api recordId;
    @api isFromParent = false;
    /**
     * Indicates if the "Test Flags Alert Modal" button will be visible, which enables manual testing of the flag alert modal.
     * - Leave false unless testing in dev environment
     * @type {boolean}
     */
    enabledTestFlagsAlertModal = false;
    isInit = true;
    flagLighntingReqWrp = {};
    @track flagList = [];
    @track flagSelected;
    @track isShowSpinner = false;
    get totalRecords() {
        return this._allFlags?.length ?? 0;
    }
    @track pageSize = 5;
    @track currentPage = 1;
    allowFlagsModal = false;

    nxtBtn = false;
    prevBtn = false;
    ShowBtns = true;
    currentIndex = 0;
    get totalRecordsDetails() {
        return this.currentIndex + 1 + '  of  ' + this.totalRecords;
    }

    _allFlags = [];

    showFlagsModal = false;

    alertModalConfig = {
        header: 'Flag Acknowledgement',
        body: '',
        headerColor: '#d04d37',
        primaryButtonLabel: 'Acknowledge and Continue',
        buttonOneLabel: 'Go back to home'
    };

    columns = [
        {
            label: 'Flag Name',
            fieldName: 'flagName',
            type: 'button',
            sortable: true,
            wrapText: false,
            initialWidth: 300,
            typeAttributes: {
                label: { fieldName: 'flagName' },
                name: 'ActionName',
                variant: 'base',
                type: 'text'
            }
        },
        { label: 'Flag Type', fieldName: 'flagType', type: 'text', sortable: true },
        { label: 'Status', fieldName: 'status', type: 'text', sortable: true },
        {
            label: 'Review Date',
            fieldName: 'reviewDate',
            type: 'date-local',
            sortable: true,
            typeAttributes: dateFormatter.LIGHTNING_FORMATTED_DATE_OPTIONS
        }
    ];
    defaultSortedBy = 'flagName';
    defaultSortedDirection = 'asc';
    @track
    selectedRows = [];
    @track
    selectedRowData;

    variableText = 'Assignment Narrative';

    connectedCallback() {
        if (!this.isInit) {
            return;
        }
        this.isInit = false;
        this.isShowSpinner = true;
    }

    renderedCallback() {
        if (typeof this.recordId === 'string' && this.recordId !== '') {
            // trigger wired 'getFlags'
            this.flagRequest.recordId = this.recordId;
        }
    }

    flagRequest = {
        recordId: null,

        // facility, startDate, and endDate can be ignored but are required by the backend
        // if you change this request object, ensure the vccFlagsModalLauncher.js request object matches so browser cache is used when apropriate
        facility: '613',
        startDate: '1950-01-01',
        endDate: '2050-01-01'
    };

    @wire(getFlags, { flagReqWrp: '$flagRequest' })
    handleGetFlags({ data, error }) {
        if (typeof this.recordId !== 'string' || this.recordId === '') {
            return;
        }
        if (typeof error === 'object' && error !== null) {
            const logger = this.template.querySelector('c-logger');
            logger.error(JSON.stringify(error));
            logger.saveLog();
        } else if (typeof data === 'object' && data !== null) {
            this.processResult(data);
        }
    }

    /**
     * @description Processes data from `getFlags` Apex method.
     * - Flattens payload's "sites" into single array of flags.
     * - Adds flags from women's health data, if that feature is enabled
     * @param result an instance of `VCC_FlagResponseWrp` class
     */
    processResult(result = {}) {
        this._allFlags = healthDataService.processRecordsBaseline.call(this, transformFlagsData(result));
        this.setRecords();
        this.isShowSpinner = false;
    }

    /**
     * @description Assigns `this.flagList` as a subset of `this._allFlags`, according to current pagination index.
     */
    setRecords() {
        const currentPage = this.currentPage - 1,
            startPageIndex = currentPage === 0 ? currentPage : currentPage * this.pageSize,
            endPageIndex = startPageIndex + this.pageSize;
        this.flagList = this._allFlags.slice(startPageIndex, endPageIndex);
    }

    /**
     * @description Captures selected row in `this.flagSelected` and opens detail modal.
     * @param row The clicked table row
     */
    handleRowClick(row) {
        // Initialize modal with the clicked flag's details.
        this.flagSelected = this.flagList.find((record) => record.key === row.key);
        this.handleModalOpen();
        this.currentIndex = this.flagList.findIndex((flag) => flag.key === this.flagSelected.key);

        this.ShowBtns = this.flagList.length > 1;
        if (this.currentIndex === 0) {
            this.nxtBtn = false;
            this.prevBtn = true;
        } else if (this.currentIndex === this.flagList.length - 1) {
            this.nxtBtn = true;
            this.prevBtn = false;
        } else {
            this.nxtBtn = false;
            this.prevBtn = false;
        }
    }

    /**
     * @description Handles `rowaction` event from vccDatatableCustomTypes (bubbled up from lightning-datatable). Passes selected row to `handleRowClick`
     * @param event
     */
    handleRowAction(event) {
        this.handleRowClick(event.detail.row);
    }

    /**
     * @description Opens baseModal
     */
    handleModalOpen() {
        const modal = this.template.querySelector('c-base-modal');
        if (modal) {
            modal.open(this.template.host);
        }
    }

    /**
     * @description Handles change event from vccPagination component. Sets `this.currentPage` from event.detail.
     * @param event
     */
    handlePageChange(event) {
        this.currentPage = event.detail;
        this.setRecords();
    }

    /**
     * @description Returns label of the currently sorted table column.
     * @return {string}
     */
    get sortedByLabel() {
        return datatableHelper.getColumn(this.columns, this.sortedBy)?.label;
    }
    sortedBy = this.defaultsortedBy;
    sortDirection = this.defaultSortedDirection;

    /**
     * @description Handles sort event from datatable, sorts data using `datatableHelper.sortHDRData()` function
     * @param event
     */
    handleSort(event) {
        const { fieldName, sortDirection } = event?.detail ?? {};
        this._allFlags = datatableHelper.sortHDRData(
            this._allFlags,
            datatableHelper.getColumn(this.columns, fieldName),
            sortDirection
        );

        this.sortDirection = sortDirection;
        this.sortedBy = fieldName;
        this.setRecords();
    }

    /**
     * @description Handles `nextvaluechange` event from baseModal. Moves between record details
     * @param event
     */
    nextValueChange(event) {
        if (event.detail.name === 'Next') {
            if (this.currentIndex === 0 || this.currentIndex < this._allFlags.length - 1) {
                this.currentIndex += 1;
            }
        } else if (event.detail.name === 'Previous') {
            if (this.currentIndex > 0 && this.currentIndex !== 0) {
                this.currentIndex -= 1;
            }
        } else if (event.detail.name === 'First') {
            this.currentIndex = 0;
        } else if (event.detail.name === 'Last') {
            this.currentIndex = this._allFlags.length - 1;
        }
        this.flagSelected = this._allFlags[this.currentIndex];

        if (this.currentIndex === 0) {
            this.nxtBtn = false;
            this.prevBtn = true;
        } else if (this.currentIndex === this._allFlags.length - 1) {
            this.nxtBtn = true;
            this.prevBtn = false;
        } else {
            this.nxtBtn = false;
            this.prevBtn = false;
        }
    }

    /**
     * @description Parses string into JS Date
     * @param dateTimeString String representation of a datetime from women's health callout
     * - example: `20211027135952` for 11/27/2021 1:59:32 PM
     * - month being zero-indexed
     * @return {Date}
     */
    getJsDateFromDateTime = (dateTimeString) => {
        if (!dateTimeString) {
            return null;
        }
        try {
            let year = parseInt(dateTimeString.substring(0, 4), 10);
            let month = parseInt(dateTimeString.substring(4, 6), 10);
            let day = dateTimeString.substring(6, 8);
            let hours = dateTimeString.substring(8, 10);
            let minutes = dateTimeString.substring(10, 12);
            return new Date(year, month, day, hours, minutes);
        } catch (e) {
            //gracefully catch error parsing string into date, return null.
            return null;
        }
    };
}
