/* eslint no-unused-expressions: ["error", { "allowShortCircuit": true }] */
import { LightningElement, track, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import CreatedBy_FIELD from '@salesforce/schema/VCC_Progress_Note__c.CreatedById';
import Signed_FIELD from '@salesforce/schema/VCC_Progress_Note__c.VCC_Signed__c';

// componentDependencies such as labels, columns, and implicit apex methods
import { componentDependencies as service, errMessageTitle, errSubMessage } from './componentDependencies.js';
// wired methods
import getICN from '@salesforce/apex/VCC_lwc_utils.getICN';
import getLabsVTC from '@salesforce/apex/VCC_LabController.fetchLabs';
import getHealthDataConfig from '@salesforce/apex/VCC_LabController.fetchHealthDataConfig';
import { MessageContext } from 'lightning/messageService';
// modal imports
import baseLightningModalComms from '@salesforce/messageChannel/baseLightningModalComms__c';
import { dateFormatter } from 'c/utils';

export default class VccLab extends LightningElement {
    /**private props*/
    _addToNoteOptions = {};
    _columnsForAddToNote = [];
    /**api non-setaddToNoteDefaultOptionster props*/
    @api addToNoteOptions;
    @api columnsForAddToNote;
    @api labDisclaimer;
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
    tempArgs; // object that is built up during wire calls used to build vtcArgs
    @track
    actionsComponent = service.actionsComponent;
    patientBirthYear;
    errMessageTitle = errMessageTitle;
    errSubMessage = errSubMessage;

    settings = service.settings;
    labels = { ...service.labels };
    calloutsPerformed = []; // batches of data returned via wire calls

    /**
     * @description sets the loading spinner, and sets the labels for messages and add to note functionality
     */
    async connectedCallback() {
        this.isShowSpinner = true;
        await service.setLabels.call(this, service.settings, 'labs');
        service.settingAddToNoteValues.call(this, service.addToNoteDefaultOptions, service.addToNoteDefaultColumns);
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
                stopDate: new Date(data.workstreamSettings.endDate).toISOString().split('T')[0]
            };
        }

        if (error) {
            this.logger(error);
        }
    }

    /**
     * @description If the passed in record has a comment, replace the various new line characters with a double `\n`
     * so that we can effect a decent line-wrap function from pre-formatted text.
     * @param record VTCLabs record
     * @return String - the line wrapped comment.
     */
    lineWrapRecordComment(record) {
        if (!record?.comment) {
            return '';
        }
        return record.comment
            .split(/\r?\n/g)
            .map((s) => s.trim())
            .join('\n\n');
    }

    /**
     * @description Get Labs for the patient via wire after icn and workstream settings are retrieved
     * @param data
     * @param error
     */
    @wire(getLabsVTC, { args: '$vtcArgs' })
    async wiredCallout(value) {
        const { data, error } = value;
        if (data) {
            service.handleCalloutSuccess.call(this, data, this.vtcArgs);
            this.hdrData = !this.hdrData
                ? []
                : this.hdrData
                      .sort((a, b) => {
                          a = a.collected ? Date.parse(a.collected) : 0;
                          b = b.collected ? Date.parse(b.collected) : 0;
                          return b - a;
                      })
                      .map((record) => {
                          return {
                              ...record,
                              comment: this.lineWrapRecordComment(record),
                              collectedDateString: dateFormatter.salesForceDateTimeStringToMMDDYYYYHHMM(
                                  record?.collected
                              )
                          };
                      });
        }

        if (error) {
            this.logger(error);
            this.isShowSpinner = false;
            if (error?.body?.message === 'NO_RETRY_CMD') {
                this.hasError = true;
            } else {
                await service.handleCalloutError.call(this, error, this.vtcArgs);
            }
        }

        this.isShowSpinner = false;
    }

    /**
     * @description Wire to getRecord to build the logic for use of Add to Note
     * @param error
     * @param data
     */
    @wire(getRecord, { recordId: '$recordId', fields: [CreatedBy_FIELD, Signed_FIELD] })
    progressNote({ error, data }) {
        // this will fail cleanly on an Account record since the fields are not present for that recordId

        if (this.objectApiName !== 'VCC_Progress_Note__c') {
            return;
        }

        if (error) {
            this.logger(error);
        } else if (data) {
            // this is required to be called as either true or false since this component is on the Progress Note page
            service.setShowAddToNoteOption.call(
                this,
                // If the user owns the record and the record is not signed, show the Add to Note button
                data.fields.CreatedById.value === service.currentUserId && !data.fields.VCC_Signed__c.value
            );
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
        service.handleRowSelected.call(this, event, 'c-base-h-d-r-frame', 'c/vccLabDetails');
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
        service.nextValueChange.call(this, event, 'c-base-h-d-r-frame', 'c/vccLabDetails');
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

    // algorithm of max logic
    // if callout hits max logic
    // we are going to identify the earliest and latest dates on the data set that returned with the max hit e.g. identify the "ends"
    // then we are going to create a new callout request with that date range and generate a new max
    // then we are going to break the new request into smaller requests with the new max generated above
    // if any of the new requests hit the mex, recurse

    // algorithm of request timed out
    // break up the request into smaller requests, with a smaller max
    // identify any sites that set off the max and zero in on their date ranges
    // create a new request with the info from above
    // batch the request from above and then run async

    /**
     * @description breaks down a large request into a batch of smaller requests. The requests are run asynchronously
     */
    async handleMaxLimitReached(wiredCall) {
        const dateFieldForLimit = 'collected'; // the date field your data is queried on

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
                getLabsVTC({ args: request })
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
