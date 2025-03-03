/* eslint-disable dot-notation */
/* eslint-disable no-case-declarations */
// need to suppress the dot-notation eslint rule  as properties might have a space in them like "BLOOD PRESSURE"
// TODO: refactor the handle row selected method to not declare variables in switch cases

import { LightningElement, api, track, wire } from 'lwc';
// componentDependencies such as labels, columns, and implicit apex methods
import { componentDependencies as service, errMessageTitle, errSubMessage } from './componentDependencies.js';
// wired methods
import getICN from '@salesforce/apex/VCC_lwc_utils.getICN';
import getHealthDataVTC from '@salesforce/apex/VCC_PatientVitalsController.fetchVitals';
import { MessageContext } from 'lightning/messageService';
// modal imports
import baseLightningModalComms from '@salesforce/messageChannel/baseLightningModalComms__c';
import getHealthDataConfig from '@salesforce/apex/VCC_PatientVitalsController.fetchHealthDataConfig';

export default class VccVitals extends LightningElement {
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
    @track selectedRecord;
    @track hdrData = [];
    @track dataSettings = {};
    initialWiredCallIsFinished = false;
    errMessageTitle = errMessageTitle;
    errSubMessage = errSubMessage;

    loading;

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
    customMessage;
    messageChannel = baseLightningModalComms;
    columns = service.columns;
    vtcArgs; // args for vtc call
    @track
    actionsComponent = service.actionsComponent;
    patientBirthYear;

    settings = service.settings;
    labels = { ...service.labels };
    calloutsPerformed = []; // batches of data returned via
    // wire calls

    /** wires, these are defined by the ordered they're called*/
    @wire(MessageContext)
    messageContext;

    @track
    additionalData = {};

    @track
    tableDisplayData = [];

    @track
    graphConfig = {
        labels: [],
        datasets: [],
        options: null
    };

    title = '';
    chartTitle = '';
    referenceRange = false;

    @track
    selectedMeasurements = [];

    async connectedCallback() {
        this.loading = true;
        await service.setLabels.call(this, service.settings, 'vitals');
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

            // this is required to be called as either true or false since this component is on the Progress Note page
            if (this.objectApiName === 'VCC_Progress_Note__c') {
                service.setShowAddToNoteOption.call(this, false);
            }

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
     * @description Get Visits for the patient via wire after icn and workstream settings are retrieved
     * @param data records returned via wired VTC call
     * @param error
     */
    @wire(getHealthDataVTC, { args: '$vtcArgs' })
    async wiredCallout(value) {
        const { data, error } = value;
        if (data) {
            this.calloutsPerformed.push({
                args: this.vtcArgs,
                cachedResult: value
            });
            this.handleSuccess(data, this.vtcArgs);
        }

        if (error) {
            this.logger(error);
            this.loading = false;
            if (error?.body?.message === 'NO_RETRY_CMD') {
                this.hasError = true;
            } else {
                await service.handleCalloutError.call(this, error, this.vtcArgs);
            }
        }
    }

    /**
     * @description render chart based on the vital type clicked
     * @param event expects a vitals record with the name of the action that invoked this event
     */

    isBloodPressure;
    vitalTypeSelected;
    handleRowSelected(event) {
        this.isBloodPressure = false;
        let chartOptions;
        switch (event.detail.actionName) {
            case 'DateTimeButtonClicked':
                service.handleRowSelected.call(this, event, 'c-base-h-d-r-frame', 'c/vccVitalsDateDetails');
                return;

            case 'WeightButtonClicked':
                this.componentToRender = 'c/VccVitalsWeightDetails';
                this.title = 'Patient Weight Vitals';
                this.chartTitle = "A chart showing the patient's weight vitals across dates";
                this.referenceRange = false;
                service.setUpGraph.call(this, { vitalType: 'WEIGHT', chartType: 'line', chartColor: '#E1BE6A' });
                this.vitalTypeSelected = 'WEIGHT';
                break;

            case 'TemperatureButtonClicked':
                this.componentToRender = 'c/vccVitalsTemperatureDetails';
                this.title = 'Patient Temperature Vitals';
                this.chartTitle = "A chart showing the patient's temperature vitals across dates";
                this.referenceRange = true;
                service.setUpGraph.call(this, { vitalType: 'TEMPERATURE', chartType: 'line', chartColor: '#D41159' });
                this.vitalTypeSelected = 'TEMPERATURE';
                break;

            case 'RespirationButtonClicked':
                this.componentToRender = 'c/vccVitalsGenericDetails';
                this.title = 'Patient Respiration Vitals';
                this.chartTitle = "A chart showing the patient's respiration vitals across dates";
                this.referenceRange = true;
                service.setUpGraph.call(this, { vitalType: 'RESPIRATION', chartType: 'line', chartColor: '#40B0A6' });
                this.vitalTypeSelected = 'RESPIRATION';
                break;

            case 'PulseButtonClicked':
                this.componentToRender = 'c/vccVitalsGenericDetails';
                this.title = 'Patient Pulse Vitals';
                this.chartTitle = "A chart showing the patient's pulse vitals across dates";
                this.referenceRange = true;
                service.setUpGraph.call(this, { vitalType: 'PULSE', chartType: 'line', chartColor: '#994F00' });
                this.vitalTypeSelected = 'PULSE';
                break;

            case 'BMIButtonClicked':
                this.componentToRender = 'c/vccVitalsBMIDetails';
                this.title = 'Patient BMI Vitals';
                this.chartTitle = "A chart showing the patient's BMI vitals across dates";
                this.referenceRange = false;
                this.vitalTypeSelected = 'WEIGHT';
                // bmi exists on WEIGHT records in the additional details array, need to iterate and select "bmi" on weight records instead of "value" like the other line charts

                // gather data
                const bodyMassIndexDataset = [
                    {
                        label: 'Body Mass Index (BMI)',
                        data: this.additionalData['WEIGHT']
                            .map((weightReading) => {
                                // remove any non-integer characters so we can process data as nums
                                if (weightReading.bmi.includes('*')) {
                                    return parseFloat(weightReading.bmi.split('*')[0], 10);
                                }

                                return parseFloat(weightReading.bmi, 10);
                            })
                            .slice(0, 5),
                        backgroundColor: '#E1BE6A',
                        borderColor: 'gold',
                        fill: false
                    }
                ];

                // chart options
                chartOptions = {
                    legend: {
                        display: true,
                        position: 'bottom',
                        align: 'center'
                    },
                    scales: {
                        xAxes: [
                            {
                                offset: true,
                                padding: 3
                            }
                        ]
                    }
                };

                service.setUpGraph.call(this, {
                    vitalType: 'WEIGHT',
                    chartType: 'line',
                    datasets: bodyMassIndexDataset,
                    options: chartOptions
                });
                break;

            case 'BloodPressureButtonClicked':
                this.componentToRender = 'c/vccVitalsBloodPressureDetails';
                this.isBloodPressure = true;
                this.title = 'Patient Blood Pressure Vitals';
                this.chartTitle = "A chart showing the patient's blood pressure vitals across dates";
                this.referenceRange = true;
                this.vitalTypeSelected = 'BLOOD PRESSURE';
                // create blood pressure datasets
                const bloodPressureDataSets = [
                    {
                        label: 'Systolic',
                        data: this.additionalData['BLOOD PRESSURE']
                            .map((bloodPressureReading) => {
                                // return the top number in a reading that looks like this 122/86
                                return bloodPressureReading.value.split('/')[0];
                            })
                            .slice(0, 5),
                        backgroundColor: '#E66100',
                        fill: true
                    },
                    {
                        label: 'Diastolic',
                        data: this.additionalData['BLOOD PRESSURE']
                            .map((bloodPressureReading) => {
                                // return the bottom number in a reading that looks like this 122/86
                                return bloodPressureReading.value.split('/')[1];
                            })
                            .slice(0, 5),
                        backgroundColor: '#5D3A9B',
                        fill: true
                    }
                ];
                // probably boilerplate?  TODO: Investigate if we should abstract this elsewhere
                chartOptions = {
                    scales: {
                        yAxes: [
                            {
                                display: true,
                                ticks: {
                                    suggestedMin: 40,
                                    beginAtZero: false
                                }
                            }
                        ]
                    },
                    legend: {
                        display: true,
                        position: 'bottom',
                        align: 'center'
                    }
                };

                service.setUpGraph.call(this, {
                    vitalType: 'BLOOD PRESSURE',
                    chartType: 'bar',
                    datasets: bloodPressureDataSets,
                    options: chartOptions
                });
                break;

            default:
                return; // don't render if we don't satisfy a case above
        }

        // select the addy prop, filter against an id

        this.selectedMeasurements = [...this.additionalData[this.vitalTypeSelected]]
            .map((vital) => {
                if (vital.name === 'BLOOD PRESSURE') {
                    const systolicCalculatedReading = service.calculateReading({
                        high: vital.high.split('/')[0],
                        low: vital.low.split('/')[0],
                        value: vital.value.split('/')[0]
                    });

                    const diastolicCalculatedReading = service.calculateReading({
                        high: vital.high.split('/')[1],
                        low: vital.low.split('/')[1],
                        value: vital.value.split('/')[1]
                    });

                    return {
                        ...vital,
                        diastolicCalculatedReading: diastolicCalculatedReading,
                        systolicCalculatedReading: systolicCalculatedReading,
                        systolic: vital.value.split('/')[0],
                        diastolic: vital.value.split('/')[1]
                    };
                }

                return {
                    ...vital,
                    ...service.calculateReading({ ...vital })
                };
            })
            .slice(0, 5);

        service.renderGraphFrame.call(this);
    }

    async handleMaxLimitReached(wiredCall) {
        this.loading = true;

        const dateFieldForLimit = 'taken';
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
                        acc.startDate = record[dateFieldForLimit].split('T')[0];
                    }
                    return acc;
                },
                { ...this.vtcArgs, max: 1000 }
            );

        maxHitDateRangeRequest.max = 1000;
        // take the request created above and batch it into easier to use requests
        const batchOfNewRequests = service.createRequests(maxHitDateRangeRequest);
        await this.executeAsyncCalls(batchOfNewRequests);
        this.loading = false; // this aint doing shit rn
    }

    /**
     * @description runs calls async and determines which handler to pass response to, either success or error
     * @param Batch of requests to run async
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
            )
        );
        // loop through the array of promises and determine which handler each promise should go to
        asyncCalls.forEach((result) => {
            if (result.status === 'fulfilled') {
                if (result.value.hasError) {
                    this.handleError(result.value.response, result.value.request); // TODO: limit this recursion
                } else {
                    this.handleSuccess(result.value.response, result.value.request);
                }
            } else {
                this.handleError.call(this, result.value.response, result.request);
            }
        });
    }

    /**
     * @description Loads more data into this component, the start date of the previous request becomes the current stop date and the start date is set from the year returned in the event param
     * @param {`object`} event Expecting an year e.g. '2004'
     */
    async handleLoadMore(event) {
        service.handleLoadMore.call(this, event);
    }

    /**
     * @description invoke refreshApex on batches returned by wired callouts
     */
    async handleReloadHealthData() {
        this.loading = true;
        await service.refreshDataInBatchesAsync.call(this);
        this.tableDisplayData.sort((a, b) => new Date(b.taken) - new Date(a.taken));
        this.loading = false;
    }
    /**
     * @param data Success request of HTTP call
     * @param request the request of the HTTP call, used to determine whether or not we need to batch again
     */
    handleSuccess(data, request) {
        let hitsMaxBoundary = false;

        const wiredCall = {
            args: request,
            cachedResult: data
        };

        for (const key of Object.keys(data.sites)) {
            if (!hitsMaxBoundary && data.sites[key].records.length === this.vtcArgs.max) {
                hitsMaxBoundary = true;
            }
            this.hdrData = this.hdrData !== undefined ? this.hdrData : []; // ensuring this.hdrData is instantiated
            if (data.sites[key].records.length !== 0) {
                this.hdrData.push(...data.sites[key].records);
            }
        }
        this.hdrData = this.hdrData !== undefined ? service.dedupe([...this.hdrData], 'vtcId') : []; // trigger re-render
        if (this.tableDisplayData) {
            this.tableDisplayData.push(...service.formatForDatatable(data));
        }
        this.tableDisplayData =
            this.tableDisplayData !== undefined ? service.dedupe([...this.tableDisplayData].flat(), 'vtcId') : [];

        if (!this.initialWiredCallIsFinished) {
            this.additionalData = data.additionalData;
        } else {
            let updatedAdditionalData = { ...this.additionalData };

            for (const [vitalName, arrayOfMeasurements] of Object.entries(data.additionalData)) {
                if (!arrayOfMeasurements?.length || !vitalName) {
                    continue;
                }

                updatedAdditionalData = {
                    ...updatedAdditionalData,
                    [vitalName]: updatedAdditionalData[vitalName]
                        ? [...updatedAdditionalData[vitalName], ...arrayOfMeasurements]
                        : arrayOfMeasurements
                };
            }

            // Deduplicate each vital's measurements after merging
            for (const vitalName of Object.keys(updatedAdditionalData)) {
                updatedAdditionalData[vitalName] = service.dedupe(updatedAdditionalData[vitalName], 'id');
            }
            this.additionalData = updatedAdditionalData;

            this.setLoading(false);
            this.loading = false;
        }

        service.updateHDRMessage.call(this);

        if (hitsMaxBoundary) {
            this.handleMaxLimitReached(wiredCall);
            return;
        }
        this.loading = false;
        this.initialWiredCallIsFinished = true;
    }

    /**
     * @param data Payload of error, if the error is a limit error, we assume that the call was to large, and thus we break it up.
     * @param request Request that produced this bad call
     */
    handleError(data, request) {
        if (data.body?.message?.toLowerCase().includes('gatewaytimeout')) {
            this.executeAsyncCalls(service.createRequests(request));
            return;
        }
        switch (data.body.exceptionType) {
            case 'System.LimitException':
                this.executeAsyncCalls(service.createRequests(request));
                break;
            // chunk the request and attempt call againsetLoading
            default:
            // don't do anything on default
        }
    }

    /**
     * @description Invokes the close modal method on the health data service
     */
    closeModal() {
        service.closeModal.call(this);
    }

    /**
     * @description invokes the setLoading method on the dynamically generated actions component
     * @param loading state of loading on actions component
     */
    setLoading(loading) {
        this.refs?.hdrFrame?.invokePublicMethodsInActionsComponent([{ methodName: 'setLoading', args: [loading] }]);
    }

    /**
     * @description On a pagination button click, update the selected record and the pagination string
     * @param {`object`} event Expecting an event from baseModal
     *
     */
    nextValueChange(event) {
        service.nextValueChange.call(this, event, 'c-base-h-d-r-frame', 'c/vccVitalsDateDetails');
    }

    /**
     * @description Fetches the dependent custom nebula logger LWC that will be used for logging
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
