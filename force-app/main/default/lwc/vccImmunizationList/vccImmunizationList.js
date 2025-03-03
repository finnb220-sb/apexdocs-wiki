import { LightningElement, track, api, wire } from 'lwc';

import { componentDependencies as service, errMessageTitle, errSubMessage } from './componentDependencies.js';
// wired methods
import getICN from '@salesforce/apex/VCC_lwc_utils.getICN';
import getImmunizationsVTC from '@salesforce/apex/VCC_ImmunizationController.fetchImmunizations';
import getHealthDataConfig from '@salesforce/apex/VCC_ImmunizationController.fetchHealthDataConfig';
import { getRecord } from 'lightning/uiRecordApi';
import CreatedBy_FIELD from '@salesforce/schema/VCC_Progress_Note__c.CreatedById';
import Signed_FIELD from '@salesforce/schema/VCC_Progress_Note__c.VCC_Signed__c';
import { MessageContext } from 'lightning/messageService';
// modal imports
import baseLightningModalComms from '@salesforce/messageChannel/baseLightningModalComms__c';

const NULL_STRING = 'null';
const NULL_NULL_STRING = `${NULL_STRING} ${NULL_STRING}`;
const EMPTY_STRING = '';

export default class VccImmunizationList extends LightningElement {
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
    noResults = false;
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
    actionsComponent = service.actionsComponent; // grabs the actionsComponent object from the component dependencies
    patientBirthYear; // holds patient year to dynamically create the load more options until that year
    calloutsPerformed = []; // batches of data returned via wire calls
    errMessageTitle = errMessageTitle;
    errSubMessage = errSubMessage;

    vtcCalloutDateParameters = {
        // set on connectedCallback after getWorkstreamSettings is implicitly called
        startDate: null,
        stopDate: null
    };

    settings = service.settings;
    labels = { ...service.labels };

    async connectedCallback() {
        this.isShowSpinner = true;
        await service.setLabels.call(this, service.settings, 'immunizations');
        service.settingAddToNoteValues.call(this, service.addToNoteDefaultOptions, service.addToNoteDefaultColumns);
        service.setCalloutDateParameters.call(this);
    }

    /**
     * @description Gets the default sorting field.
     * @return {string|undefined} The field to sort by, if defined.
     */
    get defaultSortedBy() {
        return this.dataSettings?.sortBy;
    }
    /**
     * @description Gets the default sorting direction.
     * @return {string|undefined} The sorting direction, if defined.
     */
    get defaultSortedDirection() {
        return this.dataSettings?.sortDirection;
    }

    /** wires, these are defined by the ordered they're called*/
    @wire(MessageContext)
    messageContext;

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
                startDate: new Date(data.workstreamSettings.startDate).toISOString().split('T')[0], // ex: "2023-12-17"
                stopDate: new Date(data.workstreamSettings.endDate).toISOString().split('T')[0] // ex: "2024-06-17"
            };
            this.dataSettings = data.workstreamSettings;
        }

        if (error) {
            this.logger(error);
        }
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
     * @description Get Visits for the patient via wire after icn and workstream settings are retrieved
     * @param data records returned via wired VTC call
     * @param error
     */
    @wire(getImmunizationsVTC, { args: '$vtcArgs' })
    async wiredCallout(value) {
        let { data, error } = value;
        if (data) {
            await service.handleCalloutSuccess.call(this, this.replaceNullStringsWithEmptyStrings(data), this.vtcArgs);
            this.isShowSpinner = false;
        }

        if (error) {
            this.logger(error);
            if (error?.body?.message === 'NO_RETRY_CMD') {
                this.hasError = true;
            } else {
                await service.handleCalloutError.call(this, error, this.vtcArgs);
            }
            this.isShowSpinner = false;
        }
    }

    /**
     * @description modifies given object to replace "null" and "null null" strings with truly empty strings
     * @param data `Object`
     * @returns `Object` the same object, with null tokens replaced by empty strings
     */
    replaceNullStringsWithEmptyStrings(data = {}) {
        return JSON.parse(
            JSON.stringify(data).replaceAll(NULL_STRING, EMPTY_STRING).replaceAll(NULL_NULL_STRING, EMPTY_STRING)
        );
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
     * @param event
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
        const dateFieldForLimit = 'administeredDate'; // the date field your data is queried on

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
                getImmunizationsVTC({ args: request })
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
                    service.handleCalloutSuccess.call(
                        this,
                        this.replaceNullStringsWithEmptyStrings(result.value.response),
                        result.value.request
                    );
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
     * @description Capture the record selected and render a modal with the details of the selected record in the body and the pagination in the footer
     * @param event Event from BaseHDRFrame when a row is selected
     */
    handleRowSelected(event) {
        service.handleRowSelected.call(this, event, 'c-base-h-d-r-frame', 'c/vccImmunizationDetails');
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
        service.nextValueChange.call(this, event, 'base-h-d-r-frame', 'c/vccImmunizationDetails');
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
