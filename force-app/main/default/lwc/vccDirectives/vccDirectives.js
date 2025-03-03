import { LightningElement, track, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

import getNotes from '@salesforce/apex/VCC_ProgressNoteController.fetchNotes';
import getDirectives from '@salesforce/apex/VCC_ProgressNoteController.fetchDirectives';

import getICN from '@salesforce/apex/VCC_lwc_utils.getICN';
import getHealthDataConfig from '@salesforce/apex/VCC_DirectivesController.fetchHealthDataConfig';

import maxRecordMessage from '@salesforce/label/c.VCC_max_Record_Limit';
import { componentDependencies as service } from './componentDependencies.js';
import { groupBy } from 'c/helpersLWC';

const FIELDS = ['Account.VCC_MVI_External_Id__pc'];
const NO_RETRY_CMD = 'NO_RETRY_CMD';

export default class VccDirectives extends LightningElement {
    componentTitle = 'Directives';
    hasError = false;
    startDate;
    @track pendingRequests = [];
    @track list = [];
    @track fullResponse = {};
    @track listByCategory = {};
    @track listByYear = {};
    @track listByFacility = {};
    @track mostRecent = [];
    @track full;
    allDirectivesReturned = false;
    allNotesReturned = false;
    done = false;
    errMessageTitle = service.errMessageTitle;
    errSubMessage = service.errSubMessage;
    @track intial;
    @track all = [];
    @track years = [];
    @track facilities = [];
    @track categories = [];
    @track picklistValues = [];
    @track firstSet = [];
    @track displayMessage;
    @track exceptionMessage;
    icn;
    max;
    dataSettings = {};
    hdrMessage;
    @track filterValues = {
        years: null,
        facilities: null,
        categories: null,
        full: null
    };

    @track properties = {
        view: 'list',
        target: null,
        filter: false
    };

    /**context consts */
    @api recordId;
    @api objectApiName;
    @api flexipageRegionWidth;

    /**
     * context obj that stores properties about the metadata that invokes this component,
     * Is passed down to children components
     */
    context = {
        id: '',
        sObject: '',
        flexipageRegionWidth: ''
    };

    @track processedData = {};

    //max record details
    maxRecordReached = false;
    maxErrorCheck = false;
    maxRecordMessage = maxRecordMessage;
    customMessage;

    vtcArgs; // args for vtc call
    vtcDirectiveArgs; //args for directives call
    @track
    actionsComponent = service.actionsComponent;
    patientBirthYear;

    settings = service.settings;
    labels = { ...service.labels };
    calloutsPerformed = []; // batches of data returned via wire calls

    /**
     * @description getter for isLoading, whether the component is still loading
     */
    get isLoading() {
        return !(
            this.allNotesReturned &&
            this.allDirectivesReturned &&
            this.pendingRequests &&
            this.pendingRequests.length === 0
        );
    }
    isDirectives = true;
    /**
     * @description the connected callback, sets the labels of the service which among other things defaults the note shown to the user
     */
    async connectedCallback() {
        await service.setLabels.call(this, service.settings, 'directives');
    }

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
     * @description Gets patient birth year, and workstream settings, the data required to perform calls to VTC for notes and directives
     * @param string icn to query DB against
     */
    @wire(getHealthDataConfig, { icn: '$icn' })
    wiredHDRConfig({ data, error }) {
        if (data) {
            this.startDate = data.workstreamSettings.startDate;
            this.patientBirthYear = data.patientBirthYear;
            service.setLoadMoreOptions.call(this, data);
            this.context = {
                id: this.icn,
                sObject: this.objectApiName,
                flexipageRegionWidth: this.flexipageRegionWidth
            };

            this.vtcArgs = {
                icn: this.icn,
                startDate: new Date(data.workstreamSettings.startDate).toISOString().split('T')[0],
                stopDate: new Date(data.workstreamSettings.endDate).toISOString().split('T')[0],
                max: parseInt(data.workstreamSettings.max, 10)
            };
            this.vtcDirectiveArgs = {
                icn: this.icn,
                startDate: this.patientBirthYear ? this.patientBirthYear + '-01-01' : null,
                max: parseInt(data.workstreamSettings.max, 10)
            };
        }

        if (error) {
            console.error('error', error);
        }
    }

    initialWiredCallIsFinished = false;

    @track
    hdrData = [];
    /**
     * @description Get Visits for the patient via wire after icn and workstream settings are retrieved
     * @param data records returned via wired VTC call
     * @param error
     */

    @wire(getNotes, { args: '$vtcArgs' })
    async wiredNotes(value) {
        const { data, error } = value;
        if (data) {
            await this.handleSuccess(data, this.vtcArgs, 'notes');
            this.allNotesReturned = true;
        }

        if (error) {
            console.error('error', error);
            if (error.body?.message === NO_RETRY_CMD) {
                this.allNotesReturned = true;
                this.hasError = true;
            } else {
                await this.executeAsyncCalls(service.createRequests(this.vtcArgs));
            }
            this.allNotesReturned = true;
        }
    }

    /**
     * @description Get Visits for the patient via wire after icn and workstream settings are retrieved
     * @param data records returned via wired VTC call
     * @param error
     */

    @wire(getDirectives, { args: '$vtcDirectiveArgs' })
    async wiredDirectives(value) {
        const { data, error } = value;
        if (data) {
            await this.handleSuccess(data, this.vtcDirectiveArgs, 'directives');
            this.allDirectivesReturned = true;
        }

        if (error) {
            console.error('error', error);
            if (error.body?.message === NO_RETRY_CMD) {
                this.allDirectivesReturned = true;
                //need to display the error message
            } else {
                await this.executeAsyncCalls(service.createRequests(this.vtcArgs));
            }
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    account({ error, data }) {
        if (data) {
            this.icn = data.fields.VCC_MVI_External_Id__pc.value;
        } else {
            console.error('Failed to Fetch ICN with WIRE', error);
        }
    }

    get singleView() {
        return this.properties.view === 'single';
    }

    get listView() {
        return this.properties.view === 'list';
    }

    get emptyView() {
        return this.properties.view === 'empty';
    }

    get errorMsg() {
        return 'No records returned';
    }

    handleChange(event) {
        this.allNotesReturned = false;
        this.allDirectivesReturned = false;
        this.properties.target = event.detail.id;
        this.properties.view = event.detail.view;
        // Disabling eslint because removing setTimeout may have some unknown impacts and needs to be fleshed out with a story
        // eslint-disable-next-line
        setTimeout(() => {
            this.allNotesReturned = true;
            this.allDirectivesReturned = true;
        }, 250);
    }

    handleFilterClicked(event) {
        this.properties.filter = event.detail.filter;
    }

    handleListUpdate(event) {
        this.list = JSON.parse(event.detail);
        this.properties.target = this.list[0].vtcId;
    }
    /**
     * @description Handles refresh button click and spinners
     */
    async handleRefresh() {
        this.allNotesReturned = false;
        this.allDirectivesReturned = false;
        await service.refreshDataInBatchesAsync.call(this);
    }

    /**
     * @description breaks down a large request into a batch of smaller requests. The requests are run asynchronously
     */

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

    async handleMaxLimitReached(wiredCall, endpointCalled) {
        if (this.refs?.hdrFrame && this.allNotesReturned && this.allDirectivesReturned) {
            this.refs?.hdrFrame?.setListLoading(true);
        }
        const dateFieldForLimit = 'dateCreatedFormatted';

        // per the logic above, create a new request that spans the date range of all sites that hit max
        const maxHitDateRangeRequest = wiredCall.cachedResult.sites
            .filter((site) => site.records.length === wiredCall.args.max)
            .flatMap((site) => site.records) // flatten the results
            .sort((a, b) => new Date(b[dateFieldForLimit]) - new Date(a[dateFieldForLimit]))
            .reduce(
                (acc, record, index, arr) => {
                    if (index === 0) {
                        acc.stopDate = record[dateFieldForLimit].split('T')[0];
                    }
                    if (index === arr.length - 1) {
                        acc.startDate = wiredCall.args.startDate;
                    }
                    return acc;
                },
                { ...this.vtcArgs, max: 1000 }
            );

        maxHitDateRangeRequest.max = 1000;

        // take the request created above and batch it into easier to use requests
        const batchOfNewRequests = service.createRequests(maxHitDateRangeRequest);
        await this.executeAsyncCalls(batchOfNewRequests, endpointCalled);
    }

    /**
     * @description runs calls async and determines which handler to pass response to, either success or error
     * @param Batch of requests to run async
     */
    async executeAsyncCalls(requests, endpointCalled) {
        if (requests === null) {
            return;
        }
        this.pendingRequests.push(...requests); // no need to check pendingRequest as it is initialized to an array on line 21
        let asyncCalls;
        switch (endpointCalled) {
            case 'notes':
                asyncCalls = await Promise.allSettled(
                    requests.map((request) =>
                        getNotes({ args: request })
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
                                const indexOfRequest = this.pendingRequests.findIndex(
                                    (pendingRequest) =>
                                        pendingRequest.startDate === request.startDate &&
                                        pendingRequest.stopDate === request.stopDate
                                );
                                if (indexOfRequest === -1) {
                                    return;
                                }
                                this.pendingRequests.splice(indexOfRequest, 1);
                                this.pendingRequests = [...this.pendingRequests];
                            })
                    )
                );
                break;

            case 'directives':
                asyncCalls = await Promise.allSettled(
                    requests.map((request) =>
                        getDirectives({ args: request })
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
                                const indexOfRequest = this.pendingRequests.findIndex(
                                    (pendingRequest) =>
                                        pendingRequest.startDate === request.startDate &&
                                        pendingRequest.stopDate === request.stopDate
                                );
                                if (indexOfRequest === -1) {
                                    return;
                                }
                                this.pendingRequests.splice(indexOfRequest, 1);
                                this.pendingRequests = [...this.pendingRequests];
                            })
                    )
                );

                break;

            default:
            // do nothing because only 2 scenarios that are possible are notes or directives.
        }
        // there are instances where it will be fulfilled and have an error
        try {
            asyncCalls?.forEach((result) => {
                if (result.status === 'fulfilled' && !result?.value?.hasError) {
                    this.handleSuccess(result?.value?.response, result?.value?.request, endpointCalled);
                } else {
                    this.handleError(result?.value?.response, result?.value?.request, endpointCalled);
                }
            });
        } catch (error) {
            this.logger(error);
        }
        // loop through the array of promises and determine which handler each promise should go to
    }

    /**
     * @description Loads more data into this component, the start date of the previous request becomes the current stop date and the start date is set from the year returned in the event param
     * @param {`object`} event Expecting an year e.g. '2004'
     */
    async handleLoadMore(event) {
        this.setLoading(true);
        service.handleLoadMore.call(this, event);
    }

    /**
     * @description invoke refreshApex on batches returned by wired callouts
     */
    async handleReloadHealthData() {
        this.allNotesReturned = false;
        this.allDirectivesReturned = false;
        await service.refreshDataInBatchesAsync.call(this);
        this.allNotesReturned = true;
        this.allDirectivesReturned = true;
    }

    /**
     * @param data Success request of HTTP call
     * @param request the request of the HTTP call, used to determine whether or not we need to batch again
     * @param endpointCalled the endpoint that is called
     */
    async handleSuccess(data, request, endpointCalled) {
        let hitsMaxBoundry = false;
        let tempList = this.list ? this.list : [];
        const wiredCall = {
            args: request,
            cachedResult: data
        };

        for (const key of Object.keys(data.sites)) {
            // expected that this only be set once, after its true it shouldn't be set again
            if (!hitsMaxBoundry && data.sites[key].records.length === request.max) {
                hitsMaxBoundry = true;
            }
            if (endpointCalled === 'directives' && data.sites[key].records.length) {
                tempList.push(...data.sites[key].records);
            } else {
                //filter result to only display Directives
                for (const record of data.sites[key].records) {
                    if (this.checkIsDirective(record) === true) {
                        tempList.push(record);
                    }
                }
            }
        }
        if (this.list?.length) {
            this.list = service.dedupe([...tempList], 'vtcId');
            this.list = this.list !== undefined ? this.list.sort() : [];

            this.initial = this.list;

            this.processedData = {
                facility: groupBy([...this.list], 'facilityName'),
                type: groupBy([...this.list], 'typeName'),
                all: this.list
            };
        }
        if (endpointCalled === 'notes') {
            service.updateHDRMessage.call(this);
        }

        if (hitsMaxBoundry) {
            this.handleMaxLimitReached(wiredCall, endpointCalled);
            return;
        }

        if (this.refs?.hdrFrame) {
            this.refs.hdrFrame.setListLoading(false);
            this.setLoading(false);
        }
    }

    /**
     * @param data Payload of error, if the error is a limit error, we assume that the call was too large, and thus we break it up.
     * @param request Request that produced this bad call
     */
    handleError(data, request, endpointCalled) {
        if (data.body?.message === 'RETRY_CMD') {
            this.executeAsyncCalls(service.createRequests(request), endpointCalled);
        }
    }

    /**
     * @description invokes the setLoading method on the dynamically generated actions component
     * @param loading state of loading on actions component
     */
    setLoading(loading) {
        if (this.refs?.hdrFrame) {
            this.refs?.hdrFrame?.invokePublicMethodsInActionsComponent([{ methodName: 'setLoading', args: [loading] }]);
        }
    }

    checkIsDirective(record) {
        const directivesTitles = ['consent', 'dnr', 'advance', 'directive', 'release', 'power of attorney'];

        // check for directives titles
        let titleTest = directivesTitles.map((title) => record.localTitle.toLowerCase().includes(title)).includes(true);

        const isDirectiveType =
            record.typeName.toLowerCase().includes('advanced directive') ||
            record.typeName.toLowerCase().includes('advance directive');
        return isDirectiveType || titleTest;
    }
    /**
     * @description Fetches the dependent custom nebula logger LWC and that will be used for logging.
     * @param {*} incomingError - object/string that represents the error that has occurred
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
