/* eslint no-unused-expressions: ["error", { "allowShortCircuit": true }] */
import { LightningElement, track, api, wire } from 'lwc';
import { componentDependencies as service, errMessageTitle, errSubMessage } from './componentDependencies.js';
// wired methods
import getICN from '@salesforce/apex/VCC_lwc_utils.getICN';
import getConsultsVTC from '@salesforce/apex/VCC_ConsultController.fetchConsults';
import getHealthDataConfig from '@salesforce/apex/VCC_ConsultController.fetchHealthDataConfig';
import { MessageContext } from 'lightning/messageService';
// modal imports
import baseLightningModalComms from '@salesforce/messageChannel/baseLightningModalComms__c';

export default class VccConsult extends LightningElement {
    /**private props*/
    _addToNoteOptions = {};
    _columnsForAddToNote = [];
    /**api non-setaddToNoteDefaultOptionster props*/
    @api addToNoteOptions;
    @api columnsForAddToNote;
    @api consultDisclaimer;
    @api flexipageRegionWidth;
    @api objectApiName;
    @api recordId;
    @api useMockData; // Deprecated
    /**tracked props*/
    @track isShowSpinner;
    @track selectedRecord;
    @track hdrData = [];
    @track dataSettings = {};

    /**props*/
    icn;
    startDate;
    stopDate;
    isEmpty = false;
    hasError = false;
    genericError = service.labels.genericError;
    hdrMessage;
    noResults = false;
    noConnection = false;
    currentIndex = 0;
    state = {};
    totalRecordsDetails;
    maxRecordReached = false;
    maxErrorCheck = false;
    maxRecordMessage = service.labels.maxRecordMessage;
    maxRecordMessage2;
    customMessage;
    messageChannel = baseLightningModalComms;
    columns = service.columns;
    vtcArgs; // args for vtc call
    // tempArgs; // object that is built up during wire calls used to build vtcArgs
    @track
    actionsComponent = service.actionsComponent;
    patientBirthYear;
    errMessageTitle = errMessageTitle;
    errSubMessage = errSubMessage;

    settings = service.settings;
    labels = { ...service.labels };
    calloutsPerformed = []; // batches of data returned via wire calls

    vtcCalloutDateParameters = {
        // set on connectedCallback after getWorkstreamSettings is implicitly called
        startDate: null,
        stopDate: null
    };

    /**
     * @description sets the loading spinner, and sets the labels for messages and add to note functionality
     */
    async connectedCallback() {
        this.isShowSpinner = true;
        await service.setLabels.call(this, service.settings, 'consults');
        service.settingAddToNoteValues.call(this, service.addToNoteDefaultOptions, service.addToNoteDefaultColumns);
        service.setCalloutDateParameters.call(this);

        // this is required to be called as either true or false since this component is on the Progress Note page
        if (this.objectApiName === 'VCC_Progress_Note__c') {
            service.setShowAddToNoteOption.call(this, false);
        }
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
                stopDate: new Date(data.workstreamSettings.endDate).toISOString().split('T')[0],
                max: parseInt(data.workstreamSettings.max, 10)
            };
            this.dataSettings = data.workstreamSettings;
        }

        if (error) {
            this.logger(error);
        }
    }

    /**
     * @description Get Consults for the patient via wire after icn and workstream settings are retrieved
     * @param value records returned via wired VTC call
     */
    @wire(getConsultsVTC, { args: '$vtcArgs' })
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
     * @description Invoke the save functionality in baseAddToNoteFrame
     * @param event
     */
    handleAddToNoteSubmit(event) {
        event.stopPropagation();
        service.handleAddToNoteSubmit.call(this);
    }
    /**
     * @description Activate the Add to Note button depending on criteria from baseAddToNoteFrame
     * @param event dispatched by the actions component
     */
    handleAddToNoteActivation(event) {
        event.stopPropagation();
        service.handleAddToNoteActivation.call(this, event);
    }
    /**
     * @description Open the Add to Note modal
     */
    handleAddToNoteModalOpen() {
        service.handleAddToNoteModalOpen.call(this);
    }

    /**
     * @description Capture the record selected and render a modal with the details of the selected record in the body and the pagination in the footer
     * @param event Event from BaseHDRFrame when a row is selected
     */
    handleRowSelected(event) {
        service.handleRowSelected.call(this, event, 'c-base-h-d-r-frame', 'c/vccConsultDetails');
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
     *
     */
    nextValueChange(event) {
        service.nextValueChange.call(this, event, 'c-base-h-d-r-frame', 'c/vccConsultDetails');
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
        const dateFieldForLimit = 'requestedFormatted'; // the date field your data is queried on

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
     * @description this method is called inside the handleMaxLimitReached as part of the batch of smaller requests
     */
    async executeAsyncCalls(requests) {
        const asyncCalls = await Promise.allSettled(
            requests.map((request) =>
                getConsultsVTC({ args: request })
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
