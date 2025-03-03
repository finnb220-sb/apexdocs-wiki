import { LightningElement, track, api, wire } from 'lwc';
//Wired apex methods.
import getDischargeSummary from '@salesforce/apex/VCC_DischargeSummaryController.getDischargeSummary';
import getICN from '@salesforce/apex/VCC_lwc_utils.getICN';
import getHealthDataConfig from '@salesforce/apex/VCC_DischargeSummaryController.fetchHealthDataConfig';

import noResultsMessage from '@salesforce/label/c.VCC_Generic_message_for_null_search_results';
import noResultsSubMessage from '@salesforce/label/c.VCC_Generic_sub_message_for_null_search_results';
import genericError from '@salesforce/label/c.VCC_Generic_Error';
import genericSubError from '@salesforce/label/c.VCC_Generic_Sub_error';

import { componentDependencies as service } from './componentDependencies.js';
import { dateFormatter } from 'c/utils';

import { MessageContext } from 'lightning/messageService';
// modal imports
import baseLightningModalComms from '@salesforce/messageChannel/baseLightningModalComms__c';

import maxRecordMessage from '@salesforce/label/c.VCC_max_Record_Limit';
const NO_RETRY_CMD = 'NO_RETRY_CMD';
export default class VccDischargeSummaryList extends LightningElement {
    componentTitle = 'Discharge Summary';
    @api useMockData;

    @api flexipageRegionWidth;
    @api objectApiName;

    @api recordId;
    @api isFromParent = false;
    isInit = true;
    vtcArgs = {};

    settings = service.settings;
    errSubMessage = service.errSubMessage;
    errMessageTitle = service.errMessageTitle;

    @track hdrData = [];
    @track dischargeSummarySelected;
    calloutsPerformed = [];

    isLoading = true;
    totalRecords = 0;
    pageSize = 5;
    currentPage = 1;

    searchTerm;
    dataSettings = {};
    hdrMessage;
    messageChannel = baseLightningModalComms;
    BASE_HDR_FRAME_COMPONENT_NAME = 'c-base-h-d-r-frame';
    DISCHARGE_SUMMARY_DETAILS_COMP_NAME = 'c/vccDischargeSummaryDetails';

    /** wires, these are defined by the ordered they're called*/
    @wire(MessageContext)
    messageContext;

    @track
    actionsComponent = service.actionsComponent; // grabs the actionsComponent object from the component dependencies
    max;

    patientBirthYear; // holds patient year to dynamically create the load more options until that year
    wiredDataBatches = []; // batches of data returned via wire calls
    columns = service.columns;

    /** empty state */
    noResults = false;
    noConnection = false;
    labels = {
        noResultsMessage: noResultsMessage,
        noResultsSubMessage: noResultsSubMessage,
        noConnectionMessage: genericError,
        noConnectionSubMessage: genericSubError
    };

    //max record details
    maxRecordReached = false;
    maxErrorCheck = false;
    maxRecordMessage = maxRecordMessage;
    customMessage;

    icn;
    async connectedCallback() {
        this.isLoading = true;
        await service.setLabels.call(this, this.settings, 'dischargeSummary');
    }

    renderedCallback() {
        if (!this.isInit && !this.totalRecords) {
            this.noResults = true;
        } else {
            this.noResults = false;
        }
    }

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
            this.dataSettings = data.workstreamSettings;
            this.vtcArgs = {
                icn: this.icn,
                startDate: new Date(this.dataSettings.startDate).toISOString().split('T')[0],
                stopDate: new Date(this.dataSettings.endDate).toISOString().split('T')[0],
                max: this.dataSettings.max
            };
        }

        if (error) {
            this.logger(error);
        }
    }
    /**
     * @description Get discharge Summaries for the patient via wire after icn and Workstream settings are retrieved
     * @param value `Object` response returned from Apex.
     */
    @wire(getDischargeSummary, { args: '$vtcArgs' })
    async wiredCallout(value) {
        const { data, error } = value;

        if (data) {
            this.wiredDataBatches.push(value);
            this.processResult(data);

            await service.handleCalloutSuccess.call(this, data, this.vtcArgs);
            this.isLoading = false;
            this.hdrData = this.hdrData === undefined ? [] : this.hdrData;
        }

        if (error) {
            this.logger(error);
            if (error.body?.message === NO_RETRY_CMD) {
                this.isLoading = false;
                this.hasError = true;
            } else {
                await service.handleCalloutError.call(this, error, this.vtcArgs);
            }
            this.isLoading = false;
        }
    }

    /**
     * @description Given a response from our VTC Callout, We need to parse the response into a format that our Columns are expecting.
     * @param result `Object` response object returned from our callout.
     * @see wiredCallout
     */
    processResult(result) {
        if (!result.sites[0]) {
            this.noResults = true;
            return false;
        }
        for (const key of Object.keys(result.sites)) {
            this.hdrData.push(
                ...result.sites[key].records.map((currentRecord) => {
                    return {
                        ...currentRecord,
                        clinicians: currentRecord?.clinicians[1]?.signature,
                        keyField: 'id',
                        role: currentRecord?.clinicians
                            .slice(1)
                            .map(({ role }) => {
                                return role;
                            })
                            .join(','),
                        dateCreatedWithSlashes: dateFormatter.formatDateTimeStringToMMDDYYYY(currentRecord.dateCreated)
                    };
                })
            );
        }

        this.noResults = false;
        this.totalRecords = this.hdrData.length;
        return this.hdrData;
    }
    /**
     * @description - Handles the row selection event from the datatable.
     *  Sends the selected dischargeSummary record + additional data into healthDataService.handleRowSelected to generate the lightningModal
     * @param {*} the selected row record from the datatable.
     */
    handleRowSelected(event) {
        if (event && event.detail) {
            this.dischargeSummarySelected = event.detail;
            let dischargeSummaryData = {
                detail: {
                    vtcId: this.dischargeSummarySelected.vtcId,
                    dischargeSummarySelected: this.dischargeSummarySelected,
                    recordId: this.recordId,
                    vtcArgs: this.vtcArgs
                }
            };
            service.handleRowSelected.call(
                this,
                dischargeSummaryData,
                this.BASE_HDR_FRAME_COMPONENT_NAME,
                this.DISCHARGE_SUMMARY_DETAILS_COMP_NAME
            );
        }
    }

    /**
     * @description Invokes the close modal method on the health data service
     */
    closeModal() {
        service.closeModal.call(this);
    }

    reset() {
        this.totalRecords = this.hdrData.length;
        this.currentPage = 1;
    }

    /**
     * @description On a pagination button click, update the selected record and the pagination string
     * @param {`object`} event Expecting an event from baseModal
     */
    nextValueChange(event) {
        service.nextValueChange.call(
            this,
            event,
            this.BASE_HDR_FRAME_COMPONENT_NAME,
            this.DISCHARGE_SUMMARY_DETAILS_COMP_NAME
        );
    }

    /**
     * @description Loads more data into this component, the start date of the previous request becomes the current stop date and the start date is set from the year returned in the event param
     * @param {`object`} event Expecting an event from baseModal
     */
    handleLoadMore(event) {
        this.isLoading = true;
        service.handleLoadMore.call(this, event);
        this.isLoading = false;
    }

    /**
     * @description invoke refreshApex on batches returned by wired callouts
     */
    async handleReloadHealthData() {
        this.isLoading = true;
        await service.refreshDataInBatchesAsync.call(this);
        this.isLoading = false;
    }

    /**
     * @description breaks down a large request into a batch of smaller requests. The requests are run asynchronously
     */
    async handleMaxLimitReached(wiredCall) {
        const dateFieldForLimit = 'dateCreated'; // the date field your data is queried on
        this.isLoading = true;
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
        this.isLoading = false;
        this.setLoading(false);
    }

    /**
     * @description this method is called inside the handleMaxLimitReached as part of the batch of smaller requests
     */
    async executeAsyncCalls(requests) {
        const asyncCalls = await Promise.allSettled(
            requests.map((request) =>
                getDischargeSummary({ args: request })
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

        try {
            asyncCalls?.forEach((result) => {
                if (result.status === 'fulfilled' && !result?.value?.hasError) {
                    service.handleCalloutSuccess.call(this, result?.value?.response, result?.value?.request);
                } else {
                    service.handleCalloutError.call(this, result?.value?.response, result?.value?.request);
                }
            });
        } catch (error) {
            this.logger(error);
        }
    }

    /**
     * @description invokes the setLoading method on the dynamically generated actions component
     * @param loading state of loading on actions component
     */
    setLoading(loading) {
        this.refs?.hdrFrame?.invokePublicMethodsInActionsComponent([{ methodName: 'setLoading', args: [loading] }]);
    }

    /**
     * @description Fetches the dependent custom nebula logger LWC and that will be used for logging
     * @param {*} incomingError - object/string that represents the error that has occured
     */
    logger(incomingError) {
        const logger = this.template.querySelector('c-logger');
        if (!logger) {
            return;
        }
        logger.error(JSON.stringify(incomingError));
        logger.saveLog();
    }
}
