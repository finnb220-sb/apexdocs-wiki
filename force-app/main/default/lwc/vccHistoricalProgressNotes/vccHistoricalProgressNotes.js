import { api, LightningElement, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getHealthDataVTC from '@salesforce/apex/VCC_ProgressNoteController.fetchNotes';
import getICN from '@salesforce/apex/VCC_lwc_utils.getICN';
import getHealthDataConfig from '@salesforce/apex/VCC_ProgressNoteController.fetchHealthDataConfig';
import maxRecordMessage from '@salesforce/label/c.VCC_max_Record_Limit';
import { componentDependencies as service } from './componentDependencies.js';
import { groupBy } from 'c/helpersLWC';
import { assignAuthor } from './helpers.js';

const FIELDS = ['Account.VCC_MVI_External_Id__pc'];
const NO_RETRY_CMD = 'NO_RETRY_CMD';

export default class VccHistoricalProgressNotes extends LightningElement {
    hasError = false;
    hasLimitError = false;
    startDate;
    stopDate;
    maxRecordMessage = maxRecordMessage;
    customMessage;
    componentTitle = 'EHR Progress Notes';
    errMessageTitle = service.errMessageTitle;
    errSubMessage = service.errSubMessage;
    @track pendingRequests = [];
    @track list = [];
    @track fullResponse = {};
    @track listByCategory = {};
    @track listByYear = {};
    @track listByFacility = {};
    @track mostRecent = [];
    @track full;
    done = false;
    @track intial;
    @track all = [];
    @track years = [];
    @track facilities = [];
    @track categories = [];
    @track picklistValues = [];
    @track firstSet = [];
    @track errorDisplayMessage;
    @track exceptionMessage;
    @track errorDataAvailable;
    icn;

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
    @api errorMessage;
    @api isDebugMode;

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

    // columns = service.columns;
    vtcArgs; // args for vtc call
    tempArgs; // object that is built up during wire calls used to build vtcArgs
    @track
    actionsComponent = service.actionsComponent;
    patientBirthYear;

    settings = service.settings;
    labels = { ...service.labels };
    calloutsPerformed = []; // batches of data returned via wire calls

    get isLoading() {
        return !(this.initialWiredCallIsFinished && this.pendingRequests && this.pendingRequests.length === 0);
    }
    /**
     * @description the connected callback, sets the labels of the service which among other things defaults the note shown to the user
     */
    async connectedCallback() {
        await service.setLabels.call(this, service.settings, 'ehr_progress_notes');
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
     * @description Gets patient birth year, and workstream settings, the data required to perform calls to VTC
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
        }

        if (error) {
            console.error('error', error);
        }
    }

    initialWiredCallIsFinished = false;

    @track
    hdrData = [];
    /**
     * @description Get Notes for the patient via wire after icn and workstream settings are retrieved
     * @param data records returned via wired VTC call
     * @param error
     */

    @wire(getHealthDataVTC, { args: '$vtcArgs' })
    async wiredCallout(value) {
        const { data, error } = value;
        if (data) {
            await this.handleSuccess(data, this.vtcArgs);
            if (this.refs?.hdrFrame) {
                this.setLoading(false);
            }
        }

        if (error) {
            console.error('error', error);
            if (error.body?.message === NO_RETRY_CMD) {
                this.initialWiredCallIsFinished = true;
                this.hasError = true;
            } else {
                await this.executeAsyncCalls(service.createRequests(this.vtcArgs));
            }
            this.initialWiredCallIsFinished = true;
        }
    }

    /**
     * @description full async callout that returns all historical progress notes for a patient.
     * @returns {object} Full Historical Progress Notes Callout
     */
    reorderAddendums(progressNoteList) {
        let focusList = progressNoteList.sites[0].data.items;

        for (let i = 0; i < focusList.length; i++) {
            focusList[i].text = focusList[i].text.concat(
                focusList[i].text.splice(1, focusList[i].text.length).reverse()
            );
        }

        return progressNoteList;
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
        this.initialWiredCallIsFinished = false;
        this.properties.target = event.detail.id;
        this.properties.view = event.detail.view;
        // Disabling eslint because removing setTimeout may have some unknown impacts and needs to be fleshed out with a story
        // eslint-disable-next-line
        setTimeout(() => {
            this.initialWiredCallIsFinished = true;
        }, 250);
    }

    handleDateChange(event) {
        let targetName = event.target.name;
        if (targetName === 'startDate') {
            this.startDate = event.target.value;
        } else if (targetName === 'stopDate') {
            this.stopDate = event.target.value;
        }
    }

    handleDateClick() {
        this.hasLimitError = false;
        this.hasError = false;
        this.properties.view = 'list';
        this.connectedCallbackHandler().then(() => {});
    }

    handleFilterClicked(event) {
        this.properties.filter = event.detail.filter;
    }

    handleListUpdate(event) {
        this.list = JSON.parse(event.detail);
        this.properties.target = this.list[0].vtcId;
    }

    handleRefresh() {
        this.list = this.firstSet;
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

    async handleMaxLimitReached(wiredCall) {
        if (this.refs.hdrFrame && this.initialWiredCallIsFinished) {
            this.refs.hdrFrame.setListLoading(true);
        }

        const dateFieldForLimit = 'dateCreated';

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
        await this.executeAsyncCalls(batchOfNewRequests);
        this.refs?.hdrFrame?.setListLoading(false);
        this.setLoading(false);
    }

    /**
     * @description runs calls async and determines which handler to pass response to, either success or error
     * @param Batch of requests to run async
     */
    async executeAsyncCalls(requests) {
        requests.forEach((request) => {
            this.pendingRequests.push(request);
        });
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
                        const indexOfRequest = this.pendingRequests.findIndex(
                            (pendingRequest) =>
                                pendingRequest.startDate === request.startDate &&
                                pendingRequest.stopDate === request.stopDate
                        );
                        if (indexOfRequest === -1) {
                            return;
                        }
                        this.pendingRequests.splice(indexOfRequest, 1);
                    })
            )
        );
        // loop through the array of promises and determine which handler each promise should go to
        asyncCalls?.forEach((result) => {
            if (result.status === 'fulfilled' && !result?.value?.hasError) {
                this.handleSuccess(result?.value?.response, result?.value?.request);
            } else {
                this.handleError(result?.value?.response, result?.value?.request);
            }
        });
    }

    /**
     * @description Loads more data into this component, the start date of the previous request becomes the current stop date and the start date is set from the year returned in the event param
     * @param {`object`} event Expecting an year e.g. '2004'
     */
    async handleLoadMore(event) {
        this.initialWiredCallIsFinished = false;
        await service.handleLoadMore.call(this, event);
        if (this.actionsComponent?.props && event?.detail?.value) {
            this.actionsComponent.props.selectedValue = +event.detail.value;
        }
    }

    /**
     * @description invoke refreshApex on batches returned by wired callouts
     */
    async handleReloadHealthData() {
        this.initialWiredCallIsFinished = false;
        await service.refreshDataInBatchesAsync.call(this);
        this.initialWiredCallIsFinished = true;
    }

    /**
     * @param data Success request of HTTP call
     * @param request the request of the HTTP call, used to determine whether or not we need to batch again
     */
    async handleSuccess(data, request) {
        let hitsMaxBoundry = false;

        const wiredCall = {
            args: request,
            cachedResult: data
        };
        for (const key of Object.keys(data.sites)) {
            // expected that this only be set once, after its true it shouldn't be set again
            if (!hitsMaxBoundry && data.sites[key].records.length === request.max) {
                hitsMaxBoundry = true;
            }

            this.list.push(...data.sites[key].records);
        }
        if (this.list?.length) {
            this.list = service.dedupe([...this.list], 'vtcId');
            this.list = assignAuthor(this.list);
            this.initial = this.sortList(this.list);

            this.processedData = {
                facility: groupBy([...this.list], 'facilityName'),
                type: groupBy([...this.list], 'typeName'),
                all: this.list
            };

            this.properties.target = this.list[0].vtcId;
        }

        service.updateHDRMessage.call(this);
        if (hitsMaxBoundry) {
            this.handleMaxLimitReached(wiredCall);
            return;
        }

        if (this.refs?.hdrFrame) {
            this.refs.hdrFrame.setListLoading(false);
        }
        this.initialWiredCallIsFinished = true;
    }

    /**
     * @description sorts progress notes by date using the timestamp property from newest to oldest (descending)
     * @param list list of progress notes.
     * @returns sorted list of progress notes, OR an empty array if the list is null or undefined
     */
    sortList(list) {
        if (!list) {
            return [];
        }
        return list.sort((a, b) => {
            a = a.timestamp ? new Date(a.timestamp) : 0;
            b = b.timestamp ? new Date(b.timestamp) : 0;
            return b - a;
        });
    }

    /**
     * @param data Payload of error, if the error is a limit error, we assume that the call was to large, and thus we break it up.
     * @param request Request that produced this bad call
     */
    handleError(data, request) {
        if (data.body?.message === 'RETRY_CMD') {
            this.executeAsyncCalls(service.createRequests(request));
        }
    }

    /**
     * @description invokes the setLoading method on the dynamically generated actions component
     * @param loading state of loading on actions component
     */
    setLoading(loading) {
        this.refs?.hdrFrame?.invokePublicMethodsInActionsComponent([{ methodName: 'setLoading', args: [loading] }]);
    }
}
