/**
 * @description Visits List Component for VAHC. This component is responsible for displaying a list of visit records for a patient
 * in a table. The user can select a record clicking the hightlighted column on the row and see a modal with the details of the selected record.
 * This component uses the VTC Unlocked Package to retrieve HDR records. This component also uses the BaseLightningModal component to render the modal via the Health Data Service.
 *
 * @see services/healthDataService.js
 * @author Booz Allen
 * @module HDR
 */
/* eslint no-unused-expressions: ["error", { "allowShortCircuit": true }] */
// import { getRecord } from 'lightning/uiRecordApi';
import { LightningElement, track, api, wire } from 'lwc';
// componentDependencies such as labels, columns, and implicit apex methods
import { componentDependencies as service, errMessageTitle, errSubMessage } from './componentDependencies.js';
// wired methods
import getICN from '@salesforce/apex/VCC_lwc_utils.getICN';
import getHealthDataVTC from '@salesforce/apex/VCC_HistoricalVisitsController.fetchVisits';
import { MessageContext } from 'lightning/messageService';
// modal imports
import baseLightningModalComms from '@salesforce/messageChannel/baseLightningModalComms__c';
import getHealthDataConfig from '@salesforce/apex/VCC_HistoricalVisitsController.fetchHealthDataConfig';
import { dateFormatter } from 'c/utils';

export default class VccHistoricalVisits extends LightningElement {
    @api flexipageRegionWidth;
    @api objectApiName;
    @api recordId;
    @api useMockData; // Deprecated but needs to remain do deployment difficulties with removing it from flexipages
    @track selectedRecord;
    @track hdrData = [];
    @track dataSettings = {};
    @track personAccount = {};
    icn;
    genericError;
    hdrMessage;
    noResults = false;
    noConnection = false;
    maxRecordReached = false;
    isInitialSetupComplete = false;
    currentIndex = 0;
    state = {};
    totalRecordsDetails;
    messageChannel = baseLightningModalComms; // message channel needed to communicate between this component and components generated dynamically by BaseLightningModal
    columns = service.columns;
    vtcArgs; // args of the request sent to VTC
    actionsComponent = service.actionsComponent;
    max = 0;
    counter = 1;
    @track
    loadMoreOptions = [];
    startYear;
    patientBirthYear;
    calloutsPerformed = []; // batches of data returned via wire calls
    settings = service.settings; // has to be set so that the custom frame component can take this as a property on the html
    labels = { ...service.labels };
    hasError = false;
    errMessageTitle = errMessageTitle;
    errSubMessage = errSubMessage;

    /**
     * @description When a callout hits a limit exception, we store the batched callout requests in this array.
     * This is so that we can display the visit data table ONLY once all callouts have resolved.
     * @type {[]} Array of pending Visit requests. Used to keep track of batched visit callout requests.
     * @see handleMaxLimitReached
     * @see executeAsyncCalls
     * @see isLoading
     */
    pendingCallouts = [];

    /**
     * @description Boolean that determines if the spinner is spinning.
     * Causes the spinner to spin when....
     * The initial wire call to get data is pending
     * !!OR
     * One of the wire calls has failed, resulting in the splitting and batching of requests.
     * @return {boolean} returns true if all callouts and returned AND the initial wire call to get data has completed.
     *
     * @see pendingCallouts
     */
    get isLoading() {
        return !(this.isInitialSetupComplete && this.pendingCallouts?.length === 0);
    }
    async connectedCallback() {
        await service.setLabels.call(this, this.settings, 'visits');
    }

    /** wires, these are defined by the ordered they're called*/
    @wire(MessageContext)
    messageContext;

    /**
     * @description Gets ICN number for patient from recordId. If the start and stop date are available, add the icn and set the vtcArgs reactive property and trigger the callout
     * @param string recordId
     */
    @wire(getICN, { recordId: '$recordId' })
    wiredGetIcn({ data, error }) {
        if (data) {
            this.icn = data;
        }
        if (error) {
            console.error('error', error);
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
                stopDate: new Date(data.workstreamSettings.endDate).toISOString().split('T')[0],
                max: parseInt(data.workstreamSettings.max, 10)
            };
        }

        if (error) {
            this.logger(error);
        }
    }

    /**
     * @description Get Visits for the patient via wire after icn and workstream settings are retrieved
     * @param data records returned via wired VTC call
     * @param error
     */
    @wire(getHealthDataVTC, { args: '$vtcArgs' })
    async wiredCallout(value) {
        const { data, error } = value;
        if (data) {
            service.handleCalloutSuccess.call(this, data, this.vtcArgs);
            this.hdrData = !this.hdrData ? [] : this.hdrData.map(this.processRecord);
            this.isInitialSetupComplete = true;
        }

        if (error) {
            this.logger(error);
            this.isInitialSetupComplete = true;
            if (error?.body?.message === 'NO_RETRY_CMD') {
                this.hasError = true;
            } else {
                await service.handleCalloutError.call(this, error, this.vtcArgs);
            }
        }
    }

    /**
     * @description Processes the record returned from the VTC callout
     * @param record The record to process
     * @return The processed record with additional fields: providerName and dateTimeOfVisitFormattedString
     */
    processRecord(record = {}) {
        const primaryProvider = record?.providers?.find((provider) => provider.primary)?.name;
        return {
            ...record,
            providerName: record?.providers?.length && primaryProvider ? primaryProvider : '',
            dateTimeOfVisitFormattedString: dateFormatter.salesForceDateTimeStringToMMDDYYYYHHMM(record.xdateTime)
        };
    }

    /**
     * @description Invokes the close modal method on the health data service
     */
    closeModal() {
        service.closeModal.call(this);
    }

    /**
     * @description Capture the record selected and render a modal with the details of the selected record in the body and the pagination in the footer
     * @param event Event from BaseHDRFrame when a row is selected
     */

    handleRowSelected(event) {
        service.handleRowSelected.call(this, event, 'c-base-h-d-r-frame', 'c/vccHistoricalVisitsModal');
    }

    /**
     * @description On a pagination button click, update the selected record and the pagination string
     * @param {`object`} event Expecting an event from baseModal
     */
    nextValueChange(event) {
        service.nextValueChange.call(this, event, 'c-base-h-d-r-frame', 'c/vccHistoricalVisitsModal');
    }

    /**
     * @description Loads more data into this component, the start date of the previous request becomes the current stop date and the start date is set from the year returned in the event param
     * @param {`object`} event Expecting an year e.g. '2004'
     */
    handleLoadMore(event) {
        service.handleLoadMore.call(this, event);
    }

    /**
     * @description refreshes cached results asynchronously
     */
    async handleReloadHealthData() {
        this.isInitialSetupComplete = false;
        await service.refreshDataInBatchesAsync.call(this);
    }

    /**
     * @description breaks down a large request into a batch of smaller requests. The requests are run asynchronously
     */
    async handleMaxLimitReached(wiredCall) {
        const dateFieldForLimit = 'xdateTime'; // the date field your data is queried on

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
        this.pendingCallouts.push(...batchOfNewRequests);
        await this.executeAsyncCalls(batchOfNewRequests);
        this.setLoading(false);
    }

    /**
     * @description this method is called inside the handleMaxLimitReached as part of the batch of smaller requests
     */
    async executeAsyncCalls(requests) {
        const asyncCalls = await Promise.allSettled(
            requests.map((request) =>
                getHealthDataVTC({ args: request })
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
                    .finally(() => {
                        const indexOfRequestToRemove = this.pendingCallouts.findIndex(
                            (pendingRequest) =>
                                pendingRequest.startDate === request.startDate &&
                                pendingRequest.stopDate === request.stopDate
                        );
                        if (indexOfRequestToRemove !== -1) {
                            this.pendingCallouts.splice(indexOfRequestToRemove, 1);
                            this.pendingCallouts = [...this.pendingCallouts];
                        }
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
