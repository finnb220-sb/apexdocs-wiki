/**
 * @description Radiology List Component for VAHC. This component is responsible for displaying a list of radiology records for a patient
 * in a table. The user can select a record clicking the highlighted column on the row and see a modal with the details of the selected record.
 * This component uses the VTC Unlocked Package to retrieve HDR records. This component also uses the BaseLightningModal component to render the modal via the Health Data Service.
 *
 * @see services/healthDataService.js
 * @author Booz Allen
 * @module HDR
 */
/* eslint no-unused-expressions: ["error", { "allowShortCircuit": true }] */
import { LightningElement, track, api, wire } from 'lwc';
// componentDependencies such as labels, columns, and implicit apex methods
import { componentDependencies as service, errMessageTitle, errSubMessage } from './componentDependencies.js';
// wired methods
import getICN from '@salesforce/apex/VCC_lwc_utils.getICN';
import getRadiologyVTC from '@salesforce/apex/VCC_RadiologyController.fetchRadiology';
import getHealthDataConfig from '@salesforce/apex/VCC_RadiologyController.fetchHealthDataConfig';
import { MessageContext } from 'lightning/messageService';

// modal imports
import baseLightningModalComms from '@salesforce/messageChannel/baseLightningModalComms__c';

export default class VccRediologyList extends LightningElement {
    @api flexipageRegionWidth;
    @api objectApiName;
    @api recordId;
    @api useMockData; // Deprecated but needs to remain due to deployment difficulties with removing it from flexipages
    @track isShowSpinner;
    @track selectedRecord;
    @track hdrData = [];
    @track dataSettings = {};
    @track personAccount = {};
    icn;
    genericError;
    hdrMessage;
    noResults = false;
    noConnection = false;
    currentIndex = 0;
    state = {};
    totalRecordsDetails;
    messageChannel = baseLightningModalComms; // message channel needed to communicate between this component and components generated dynamically by BaseLightningModal
    columns = service.columns;
    vtcArgs; // args for vtc call
    tempArgs; // object that is built up during wire calls used to build vtcArgs
    @track
    actionsComponent = service.actionsComponent;
    patientBirthYear;
    hasError = false;
    errMessageTitle = errMessageTitle;
    errSubMessage = errSubMessage;

    settings = service.settings;
    labels = { ...service.labels };
    calloutsPerformed = [];

    /**
     * @description Lifecycle hook that runs when the component is connected to the DOM.
     * Initializes labels and shows the spinner until the initialization is complete.
     * @returns {Promise<void>}
     */
    async connectedCallback() {
        this.isShowSpinner = true;
        await service.setLabels.call(this, service.settings, 'radiology');
    }

    /**
     * @description Gets the default sorting field.
     * @returns {string|undefined} The field to sort by, if defined.
     */
    get defaultSortedBy() {
        return this.dataSettings?.sortBy;
    }

    /**
     * @description Gets the default sorting direction.
     * @returns {string|undefined} The sorting direction, if defined.
     */
    get defaultSortedDirection() {
        return this.dataSettings?.sortDirection;
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
            const logger = this.template.querySelector('c-logger');
            logger.error(JSON.stringify(error));
            logger.saveLog();
        }
    }

    /**
     * @description Gets ICN number for patient from recordId. If the start and stop date are available, add the icn and set the vtcArgs reactive property and trigger the callout
     * @param string recordId
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
            this.dataSettings = data.workstreamSettings;
        }

        if (error) {
            const logger = this.template.querySelector('c-logger');
            logger.error(JSON.stringify(error));
            logger.saveLog();
        }
    }

    /**
     * @description Adds the 'providerName' property to a single record
     * - called by `healthDataService.processRecordsBaseline()` function
     * @param record `Object` a record from HDR that we'll show in the datatable
     * @return {{providerName: *}} `Object` that same record, now with an additional "providerName" property
     */
    processRecord(record = {}) {
        return {
            ...record,
            providerName: record?.provider?.name
        };
    }

    /**
     * @description Get Radiologies for the patient via wire after icn and workstream settings are retrieved
     * @param data Data returned from VTC.
     * @param error Exception returned from VTC or other error.
     */
    @wire(getRadiologyVTC, { args: '$vtcArgs' })
    async wiredCallout(value) {
        const { data, error } = value;
        if (data) {
            await service.handleCalloutSuccess.call(this, data, this.vtcArgs);
            this.isShowSpinner = false;
        }

        if (error) {
            this.logger(error);
            this.isShowSpinner = false;
            if (error?.body?.message === 'NO_RETRY_CMD') {
                this.hasError = true;
            } else {
                await service.handleCalloutError.call(this, error, this.vtcArgs);
            }
            this.isShowSpinner = false;
        }
    }

    /**
     * @description Capture the record selected and render a modal with the details of the selected record in the body and the pagination in the footer
     * @param event Event from BaseHDRFrame when a row is selected
     */
    handleRowSelected(event) {
        service.handleRowSelected.call(this, event, 'c-base-h-d-r-frame', 'c/vccRadiologyDetails');
    }

    /**
     * @description Invokes the close modal method on the health data service
     */
    closeModal() {
        service.closeModal.call(this);
    }

    /**
     * @description On a pagination button click, update the selected record and the pagination string
     * @param {`object`} event Expecting an event from baseModal
     */
    nextValueChange(event) {
        service.nextValueChange.call(this, event, 'c-base-h-d-r-frame', 'c/vccRadiologyDetails');
    }

    /**
     * @description Loads more data into this component, the start date of the previous request becomes the current stop date and the start date is set from the year returned in the event param
     * @param {`object`} event Expecting an year e.g. '2004'
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
        await this.executeAsyncCalls(batchOfNewRequests);
        this.setLoading(false);
    }

    /**
     * @description executes an array of async calls and handles them based on whether or not they were fulfilled
     */
    async executeAsyncCalls(requests) {
        const asyncCalls = await Promise.allSettled(
            requests.map((request) =>
                getRadiologyVTC({ args: request })
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
