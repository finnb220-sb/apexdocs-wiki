import { LightningElement, api, wire } from 'lwc';
import { componentDependencies as service, errMessageTitle, errSubMessage } from './componentDependencies.js';
import getICN from '@salesforce/apex/VCC_lwc_utils.getICN';
import getHealthDataConfig from '@salesforce/apex/VCC_OrderController.fetchHealthDataConfig';
import getOrdersVTC from '@salesforce/apex/VCC_OrderController.getOrders';
import { dateFormatter } from 'c/utils';

export default class VccOrderList extends LightningElement {
    state; // set by baseHDR

    @api flexipageRegionWidth;
    @api recordId;
    @api objectApiName;
    @api isFromParent = false;
    showAddToNote = false;
    isInit = true;
    orderLighntingReqWrp = {};
    vtcArgs;
    icn;
    settings = service.settings;
    actionsComponent = service.actionsComponent;
    patientBirthYear;
    labels = { ...service.labels };
    calloutsPerformed = [];
    hdrMessage;
    hasError = false;
    errMessageTitle = errMessageTitle;
    errSubMessage = errSubMessage;

    hdrData = [];
    selectedRecord;
    isShowSpinner = false;
    columns = service.columns;

    nxtBtn = false;
    prevBtn = false;
    ShowBtns = true;
    currentIndex = 0;
    totalRecords = 0;
    totalRecordsDetails;

    /** empty state */
    noConnection = false;
    noResults = false;
    noResultsMessage;

    /**
     * @description Gets ICN number for patient from recordId
     * @param string recordId
     */
    @wire(getICN, { recordId: '$recordId' })
    wiredGetIcn({ data, error }) {
        if (data) {
            this.icn = data;
        }
        if (error) {
            this.logger(error);
        }
    }

    /**
     * @description Gets patient birth year, and workstream settings, the data required to perform calls to VTC
     * @param string icn to query DB against
     */
    @wire(getHealthDataConfig, { icn: '$icn' })
    wiredHDRConfig({ data, error }) {
        if (data) {
            this.patientBirthYear = data.patientBirthYear;
            service.setLoadMoreOptions.call(this, data);

            this.vtcArgs = {
                icn: this.icn,
                startDate: new Date(data.workstreamSettings.startDate).toISOString().split('T')[0],
                stopDate: new Date(data.workstreamSettings.endDate).toISOString().split('T')[0]
            };
        }
        if (error) {
            this.logger(error);
        }
    }

    /**
     * @description Get Orders for the patient via wire after icn and workstream settings are retrieved
     * @param args the essential criteria for a vtc call { icn: String, startDate: "2023-12-17", stopDate: "2024-06-17" }
     */
    @wire(getOrdersVTC, { args: '$vtcArgs' })
    async wiredCallout(value) {
        const { data, error } = value;
        if (data) {
            service.handleCalloutSuccess.call(this, data, this.vtcArgs);

            this.hdrData = !this.hdrData ? [] : this.hdrData.map(this.processRecord);

            this.hdrData?.sort(function (a, b) {
                if (b.start === null) {
                    return -1;
                }
                return new Date(b.start) - new Date(a.start);
            });
        }

        if (error) {
            this.logger(error);
            this.hideLoading();
            if (error?.body?.message === 'NO_RETRY_CMD') {
                this.hasError = true;
            } else {
                await service.handleCalloutError.call(this, error, this.vtcArgs);
            }
        }
        this.hideLoading();
    }

    /**
     * @description Processes the record returned from the VTC callout
     * @param record The record to process
     * @return The processed record with additional formatted date string fields
     */
    processRecord(record = {}) {
        return {
            ...record,
            startDateFormattedString: dateFormatter.formatDateTimeStringToMMDDYYYY(record.start),
            signedDateFormattedString: dateFormatter.formatDateTimeStringToMMDDYYYY(record.signed),
            releasedDateFormattedString: dateFormatter.formatDateTimeStringToMMDDYYYY(record.released),
            flaggedDateFormattedString: dateFormatter.formatDateTimeStringToMMDDYYYY(record.flaggedDate)
        };
    }

    /**
     * @description Loads more data into this component, the start date of the previous request becomes the current stop date and the start date is set from the year returned in the event param
     * @param {`object`} event Expecting a year e.g. '2004'
     */
    handleLoadMore(event) {
        service.handleLoadMore.call(this, event);
    }

    /**
     * @description invoke refreshApex on batches returned by wired callouts
     */
    async handleReloadHealthData() {
        this.isShowSpinner = true;
        await service.refreshDataInBatchesAsync.call(this);
        this.isShowSpinner = false;
    }

    /**
     * @description breaks down a large request into a batch of smaller requests. The requests are run asynchronously
     */
    async handleMaxLimitReached(wiredCall) {
        const dateFieldForLimit = 'startDateStr'; // the date field your data is queried on

        this.setLoading(true);

        const maxHitDateRangeRequest = wiredCall.cachedResult.sites
            .filter((site) => site.records.length === wiredCall.args.max)
            .flatMap((site) => site.records)
            .sort((a, b) => new Date(b[dateFieldForLimit]) - new Date(a[dateFieldForLimit]))
            .reduce(
                (acc, record, index, arr) => {
                    if (index === 0) {
                        acc.stopDate = record[dateFieldForLimit].split('T')[0];
                    }
                    if (index === arr.length - 1) {
                        acc.startDate = record[dateFieldForLimit].split('T')[0];
                    }
                    return acc;
                },
                { ...this.vtcArgs, max: 1000 }
            );

        const batchOfNewRequests = service.createRequests(maxHitDateRangeRequest);
        await this.executeAsyncCalls(batchOfNewRequests);
        this.setLoading(false);
    }

    /**
     * @description invokes the setLoading method on the dynamically generated actions component
     * @param loading state of loading on actions component
     */
    setLoading(loading) {
        this.refs?.hdrFrame?.invokePublicMethodsInActionsComponent([{ methodName: 'setLoading', args: [loading] }]);
    }

    /**
     * @description this method is called inside the handleMaxLimitReached as part of the batch of smaller requests
     */
    async executeAsyncCalls(requests) {
        const asyncCalls = await Promise.allSettled(
            requests.map((request) =>
                getOrdersVTC({ args: request })
                    .then((result) => {
                        return {
                            response: result,
                            request: request
                        };
                    })
                    .catch((error) => {
                        return {
                            hasError: true,
                            response: error,
                            request: request
                        };
                    })
            )
        );

        asyncCalls.forEach((result) => {
            if (result.status === 'fulfilled') {
                if (result.value.hasError) {
                    service.handleCalloutError.call(this, result.value.response, result.value.request);
                } else {
                    service.handleCalloutSuccess.call(this, result.value.response, result.value.request);
                    this.hdrData = !this.hdrData ? [] : this.hdrData.map(this.processRecord);
                }
            } else {
                service.handleCalloutError.call(this, result.value.response, result.request);
            }
        });
    }

    /**
     * @description controls the visibility of the modal on connection
     * @returns null
     */
    async connectedCallback() {
        this.isShowSpinner = true;
        await service.setLabels.call(this, service.settings, 'orders');
    }

    /**
     * @description rendered callback to control no results flag
     */
    renderedCallback() {
        if (!this.isInit && !this.totalRecords && !this.noConnection) {
            this.noResults = true;
        } else {
            this.noResults = false;
        }
    }

    /**
     * @description handles the modal opening of an OrderDetail component
     */
    handleModalOpen() {
        const modal = this.template.querySelector('c-base-modal');
        modal.open(this.template.host);
    }

    /**
     * @description nebula logger
     * @param {*} incomingError error details
     * @returns null
     */
    logger(incomingError) {
        const logger = this.template.querySelector('c-logger');
        if (!logger) return;
        logger.error(JSON.stringify(incomingError));
        logger.saveLog();
    }

    /**
     * @description handles the row selection action
     * @param {*} event - event details
     */
    handleRowSelected(event) {
        this.selectedRecord = event.detail;
        this.getHDRFrameState();
        this.ShowBtns = this.state.displayList.length > 1 ? true : false;
        // this.handleModalOpen();
        this.template.querySelector('c-base-modal').open(this.template.host);

        this.totalRecordsDetails = this.currentIndex + 1 + '  of  ' + this.state.displayList.length;
        if (this.currentIndex === 0) {
            this.nxtBtn = false;
            this.prevBtn = true;
        } else if (this.currentIndex === this.hdrData.length - 1) {
            this.nxtBtn = true;
            this.prevBtn = false;
        } else {
            this.nxtBtn = false;
            this.prevBtn = false;
        }
    }

    /**
     * @description retrieved the hdr frame state
     */
    getHDRFrameState() {
        const frameComponent = this.template.querySelector('c-base-h-d-r-frame');

        if (frameComponent) {
            this.state = frameComponent.getState();
            this.currentIndex = this.state.displayList.findIndex(
                (record) => record.vtcId === this.selectedRecord.vtcId
            ); // get the index of the current record
        }
    }

    /**
     * @description show loading boolean
     */
    showLoading() {
        this.isShowSpinner = true;
    }
    /**
     * @description hide loading boolean
     */
    hideLoading() {
        this.isShowSpinner = false;
    }

    /**
     * @description handles the next value change when viewing an OrderDetail
     * @param {*} event - event details
     * @returns null
     */
    nextValueChange(event) {
        try {
            this.getHDRFrameState();
        } catch (error) {
            return;
        }

        this.currentIndex = this.state.displayList.findIndex((record) => record.vtcId === this.selectedRecord.vtcId); // get the index of the current record

        if (event.detail.name === 'Next') {
            if (this.currentIndex < this.state.displayList.length) {
                this.currentIndex += 1;
            }
        } else if (event.detail.name === 'Previous') {
            if (this.currentIndex > 0 && this.currentIndex !== 0) {
                this.currentIndex -= 1;
            }
        } else if (event.detail.name === 'First') {
            this.currentIndex = 0;
        } else if (event.detail.name === 'Last') {
            this.currentIndex = this.state.displayList.length - 1;
        }
        this.totalRecordsDetails = this.currentIndex + 1 + '  of  ' + this.state.displayList.length;
        this.selectedRecord = this.state.displayList[this.currentIndex];

        if (this.currentIndex === 0) {
            this.nxtBtn = false;
            this.prevBtn = true;
        } else if (this.currentIndex === this.state.displayList.length - 1) {
            this.nxtBtn = true;
            this.prevBtn = false;
        } else {
            this.nxtBtn = false;
            this.prevBtn = false;
        }
    }
}
