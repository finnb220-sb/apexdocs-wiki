/**
 * @description This the main component that is making the callout and holds all the crucial information for the component. When on an Account flexipage, it will separate the Appointment results into "upcoming" & "historical" for easier UX, BUT is standalone on the Progress Note flexipage (for the users that need that component)
 */
import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import CreatedBy_FIELD from '@salesforce/schema/VCC_Progress_Note__c.CreatedById';
import Signed_FIELD from '@salesforce/schema/VCC_Progress_Note__c.VCC_Signed__c';
import { componentDependencies as service, errMessageTitle, errSubMessage } from './componentDependencies.js';
import getICN from '@salesforce/apex/VCC_lwc_utils.getICN';
import getAppointmentsVTC from '@salesforce/apex/VCC_AppointmentController.fetchAppointments';
import getHealthDataConfig from '@salesforce/apex/VCC_AppointmentController.fetchHealthDataConfig';
import { MessageContext } from 'lightning/messageService';
import baseLightningModalComms from '@salesforce/messageChannel/baseLightningModalComms__c';
import { CurrentPageReference } from 'lightning/navigation';
import { dateFormatter, dateHelper } from 'c/utils';
import TIME_ZONE from '@salesforce/i18n/timeZone';

export default class VccAppointment extends LightningElement {
    /**private props*/
    _addToNoteOptions = {};
    _columnsForAddToNote = [];
    /**api non-setaddToNoteDefaultOptionster props*/
    @api addToNoteOptions;
    @api columnsForAddToNote;
    @api labDisclaimer;
    @api isApptCallTracking = false;

    @api flexipageRegionWidth;
    @api objectApiName;
    @api recordId;
    _recordId;

    @track isShowSpinner;
    @track selectedRecord;
    @track hdrData = [];
    @track dataSettings = {};
    @track upcoming = [];
    @track historical = [];
    @track showUpcoming = true;

    // exposed attribute for tab visibility
    @api displayUpcomingTab = false;
    @api displayHistoricalTab = false;

    /** empty state */
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
    @track onAccountPage = false;
    errMessageTitle = errMessageTitle;
    errSubMessage = errSubMessage;

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
    actionsComponent = service.actionsComponent; // grabs the actionsComponent object from the component dependencies
    patientBirthYear; // holds patient year to dynamically create the load more options until that year
    settings = service.settings;
    labels = { ...service.labels };
    calloutsPerformed = []; // batches of data returned via wire calls
    firstRunCC = true; //prevent recursion of adding columns when the connected callback runs

    /** Lifecycle Hooks */
    async connectedCallback() {
        this.isShowSpinner = true;
        await service.setLabels.call(this, service.settings, 'appointments');
        service.settingAddToNoteValues.call(this, service.addToNoteDefaultOptions, service.addToNoteDefaultColumns);

        //Add column to table if LWC is child of vccProgressNoteAppointment.lwc and column doesn't already exist
        let selectApptColumnExists = false;
        this.columns.forEach((column) => {
            if (column.typeAttributes?.name === 'selectAppt') {
                selectApptColumnExists = true;
            }
        });
        if (this.isApptCallTracking && !selectApptColumnExists) {
            this.columns.unshift({
                type: 'button-icon',
                fixedWidth: 40,
                typeAttributes: {
                    iconName: 'utility:add',
                    name: 'selectAppt',
                    title: 'Select Appointment',
                    alternativeText: 'Select Appointment'
                }
            });
        }
    }

    /** wires, these are defined by the ordered they're called*/
    @wire(MessageContext)
    messageContext;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.onAccountPage = currentPageReference.attributes.objectApiName === 'Account';
        }
    }

    /** Methods */
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
            let userTimeZone = TIME_ZONE;
            let stopDate = dateFormatter.toEN_USShortDate(new Date(), userTimeZone);
            if (this.isApptCallTracking) {
                stopDate = dateFormatter.en_UStoYyyyMMDD(stopDate);
            } else {
                let farFutureDate = dateHelper.getFarFutureDate(new Date());
                stopDate = dateFormatter.newDatetoYyyyMMDD(farFutureDate);
            }
            this.vtcArgs = {
                icn: this.icn,
                startDate: dateFormatter.newDatetoYyyyMMDD(data.workstreamSettings.startDate),
                stopDate: stopDate
            };
        }

        if (error) {
            this.logger(error);
        }
    }

    /**
     * @description Get data for the patient via wire after icn and workstream settings are retrieved
     * @param data records returned via wired VTC call
     * @param error
     */
    @wire(getAppointmentsVTC, { args: '$vtcArgs' })
    async wiredCallout(value) {
        const { data, error } = value;
        if (data) {
            service.handleCalloutSuccess.call(this, data, this.vtcArgs);
            this.hdrData = this.getSortedHdrDataByAppointmentDateTimeAndBuildProperties();

            if (this.onAccountPage) {
                let { upcoming, historical } = this.separateData(this.hdrData);
                if (upcoming) {
                    this.upcoming = upcoming;
                }
                if (historical) {
                    this.historical = historical;
                }
            }
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
        const actionName = event.detail.actionName;
        const row = event.detail;

        if (actionName === 'selectAppt') {
            this.handleSelectAppt(row);
        } else {
            service.handleRowSelected.call(this, event, 'c-base-h-d-r-frame', 'c/vccAppointmentDetails');
        }
    }

    /**
     * @description pass value to parent vccProgressNoteAppointment.lwc
     * @param row selected from row selected event
     */
    handleSelectAppt(row) {
        let selectedAppt = `${row.appointmentDateTimeString || ''} - ${row.locationIdentifierName || ''} - ${row.division || ''} - ${row.locationOfficialVAName || ''} - ${row.status || ''}`;

        const custEvent = new CustomEvent('selectedapptevent', {
            detail: selectedAppt
        });
        this.dispatchEvent(custEvent);
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
        service.nextValueChange.call(this, event, 'c-base-h-d-r-frame', 'c/vccAppointmentDetails');
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
        const dateFieldForLimit = 'appointmentDateTime'; // the date field your data is queried on
        // const dateFieldForLimit = 'dateTimeVal'; // the date field your data is queried on

        this.setLoading(true);

        const maxHitDateRangeRequest = wiredCall.cachedResult.sites
            .filter((site) => site.records.length === wiredCall.args.max)
            .flatMap((site) => site.records)
            ?.sort((a, b) => new Date(b[dateFieldForLimit]) - new Date(a[dateFieldForLimit]))
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
                getAppointmentsVTC({ args: request })
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
     * @description Sorts the Appointments by the appointment date in descending order. It will also build the properties needed in the object: appointmentDateTimeString, providerName and providerTitle
     * @returns Object[] returns an array of Appointments objects sorted by the appointment date
     */
    getSortedHdrDataByAppointmentDateTimeAndBuildProperties() {
        if (!this.hdrData) {
            return [];
        }

        return this.hdrData
            .sort((a, b) => new Date(a.appointmentDateTime) - new Date(b.appointmentDateTime))
            .map((record) => {
                return {
                    ...record,
                    appointmentDateTimeString: dateFormatter.salesForceDateTimeStringToMMDDYYYYHHMM(
                        record.appointmentDateTime
                    ),
                    providerName:
                        record.providers !== null && record.providers !== undefined && record.providers.length
                            ? record.providers[0].name
                            : '',
                    providerTitle:
                        record.providers !== null && record.providers !== undefined && record.providers.length
                            ? record.providers[0].siteName
                            : ''
                };
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

    /**
     * @description separate out the full HDR response into "upcoming" & "historical" arrays
     * @param {Array} incomingData the full HDR response
     * @returns {Object}
     * @returns {Array} upcoming - the upcoming appointments
     * @returns {Array} historical - the historical appointments
     */
    separateData(incomingData) {
        let upcoming = [];
        let historical = [];

        // guard statement, if incomingData is not an array or an empty array then return empty arrays
        if (!Array.isArray(incomingData) || incomingData.length === 0) {
            return { upcoming, historical };
        }

        // we dont know what timezone appointments are in so in Apex we just make them UTC (or GMT)
        // because of that, we want our currentDate to be 'UTC' (but its not actually) so we can compare them below apples to apples
        // also, adjusting currentDate timezone to be based on the user record as opposed to the browsers timezone
        let currentDate = dateHelper.asUtc(new Date(new Date().toLocaleString('en-US', { timeZone: TIME_ZONE })));
        currentDate.setUTCHours(0, 0, 0, 0);

        incomingData.forEach((appointment) => {
            const apptDate = new Date(appointment.appointmentDateTime);
            apptDate.setUTCHours(0, 0, 0, 0);

            if (apptDate >= currentDate) {
                upcoming.push(appointment);
            } else {
                historical.push(appointment);
            }
        });
        return { upcoming, historical };
    }

    handleActiveTab(event) {
        const tabSelected = event?.target?.dataset?.tab;

        switch (tabSelected) {
            case 'upcoming':
                this.currentTable = 'upcoming';
                this.showUpcoming = true;
                break;

            case 'historical':
                this.currentTable = 'historical';
                this.showUpcoming = false;
                break;

            default:
        }
    }
}
