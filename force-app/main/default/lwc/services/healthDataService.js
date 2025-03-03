// need to add this below so the "!!" can be used to determine if an incoming value is truthy or not
/* eslint no-extra-boolean-cast: 0 */

/**
 * @description Service class for shared functionality across HDR Components
 * @author Booz Allen
 *
 * NOTE: This is not a class as these functions are not meant to be related to each other or share any sort of state
 * NOTE: Some of these methods invoke and manipulate lwc class methods and properties reference the "this" keyword.
 * Exporting es5 functions is a good use case for this scenario.
 *
 */

import noResultsMessage from '@salesforce/label/c.VCC_Generic_message_for_null_search_results';
import noResultsSubMessage from '@salesforce/label/c.VCC_Generic_sub_message_for_null_search_results';
import genericError from '@salesforce/label/c.VCC_Generic_Error';
import genericSubError from '@salesforce/label/c.VCC_Generic_Sub_error';
import maxRecordMessage from '@salesforce/label/c.VCC_max_Record_Limit';
import hdrDateRangeMessageLabel from '@salesforce/label/c.VCC_HDR_Date_Range_Message';
import hdrDirectivesMessageLabel from '@salesforce/label/c.VCC_HDR_Directives_Message';
import hdrDirectivesMessage2Label from '@salesforce/label/c.VCC_HDR_Directives_Message2';
import hdrDateRangeLoadMoreMessageLabel from '@salesforce/label/c.VCC_HDR_Date_Range_Message_Load_More';
import getSettings from '@salesforce/apex/VCC_WorkstreamSettingsController.getSettings'; // not wired therefore can be imported here
import BaseLightningModal from 'c/baseLightningModal';
import userId from '@salesforce/user/Id';
import { publish } from 'lightning/messageService';
import isTedMPUser from '@salesforce/customPermission/TED_Medical_Provider';
import isTedRNUser from '@salesforce/userPermission/c__TED_Registered_Nurse';
import hasMSAPermission from '@salesforce/customPermission/VCC_MSA';
import hasPharmI_Permission from '@salesforce/customPermission/VCC_Pharmacy_Tier_I';
import hasPharmII_Permission from '@salesforce/customPermission/VCC_Pharmacy_Tier_II';
import hasPharmIII_Permission from '@salesforce/customPermission/VCC_Pharmacy_Tier_III';
import hasRegisteredNursePermission from '@salesforce/customPermission/VCC_Registered_Nurse';
import hasMedicalProviderPermission from '@salesforce/customPermission/VCC_Medical_Provider';
import { uniqueVals, getToday, chunk } from 'c/helpersLWC';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { datatableHelper, dateFormatter } from 'c/utils';

export const sortList = datatableHelper.sortFlatList;
export const dedupe = uniqueVals;
export const chunkData = chunk;
export const isTedMP = isTedMPUser;
export const isTedRN = isTedRNUser;
export const isMP = hasMedicalProviderPermission;
export const isMSA = hasMSAPermission;
export const isPharmI = hasPharmI_Permission;
export const isPharmII = hasPharmII_Permission;
export const isPharmIII = hasPharmIII_Permission;
export const isRN = hasRegisteredNursePermission;
export const currentUserId = userId;
export const isMedicalProvider = hasMedicalProviderPermission;
export const labels = {
    noResultsMessage,
    noResultsSubMessage,
    genericError,
    genericSubError,
    maxRecordMessage,
    hdrDateRangeMessageLabel
};

export const modalButtons = [
    {
        variant: 'Brand',
        label: 'Submit'
    }
];

export async function setLabels(settings, hdrType) {
    this.labels.noResultsMessage = noResultsMessage.replace('{0}', settings.title);
    this.labels.noConnectionMessage = genericError.replace('{0}', 'Connection Error');
    this.labels.noResultsSubMessage = noResultsSubMessage;
    this.labels.noConnectionSubMessage = genericSubError;

    // call workstream settings and set the dataSettings property
    this.dataSettings = await getSettings({ dataType: hdrType });
    this.hdrMessage = hdrDateRangeMessageLabel
        .replace('{1}', this.dataSettings.endDate)
        .replace('{2}', this.dataSettings.startDate);
}

export function setCalloutDateParameters() {
    // set callout date parameters used in wired api call
    this.vtcCalloutDateParameters = {
        ...this.vtcCalloutDateParameters,
        startDate: new Date(this.dataSettings.startDate).toISOString().split('T')[0], // converting mm/dd/yyyy to ISO format
        stopDate: new Date(this.dataSettings.endDate).toISOString().split('T')[0] // converting mm/dd/yyyy to ISO format
    };
}

/**
 * @description set the showAddToNote value to the desired funcitonality setting
 *  @param Boolean - the desired value for displaying the Add to Note button on Progress Note
 */
export function setShowAddToNoteOption(showAddToNote) {
    this.actionsComponent = {
        ...this.actionsComponent,
        props: {
            ...this.actionsComponent.props,
            showAddToNote: showAddToNote,
            isOnProgressNote: true,
            placeholderString: 'Select year' //? shorter placeholder to minimize width on add to note
        }
    };
}

/**
 * @description
 *  <p>
 *      Using the start year and birth year of the patient, set the load more options for the dropdown on the frame component
 *  </p>
 *  @param {`object`} - object with patient birthyear and callout start year, sets the range for valid values to load back from
 */
export function setLoadMoreOptions({ patientBirthYear, calloutStartYear }) {
    this.actionsComponent = {
        ...this.actionsComponent,
        props: {
            ...this.actionsComponent.props,
            options: []
        }
    };

    for (let i = parseInt(calloutStartYear, 10); i > parseInt(patientBirthYear, 10) - 1; i--) {
        this.actionsComponent.props.options.push({ label: i, value: i });
    }
}

/**
 * @description retrieves and stores Base HDR Frame state
 * then identify the index of the selected record
 *
 * NOTE: This function is a traditional function and not an arrow function, this is so that we can access the 'this' context from the perspective of the calling component
 */

export function getHDRFrameState(frameComponentName) {
    const frameComponent = this.template.querySelector(`${frameComponentName}`);

    if (frameComponent) {
        this.state = frameComponent.getState();
        this.currentIndex = this.state.displayList.findIndex((record) => record.vtcId === this.selectedRecord.vtcId);
    }
}

/**
 * @description Boilerplate method for creating a modal using BaseLightningModal
 * @param body Component to be rendered in the body of the modal
 * @param header Component to be rendered in the header of the modal
 * @param footer  Footer component to be rendered in the footer of the modal
 * @param listeners List of listeners to be added to the modal
 *
 * NOTE: This function is a traditional function and not an arrow function, this is so that we can access the 'this' context from the perspective of the calling component
 *
 */

export function renderBaseLightningModal({ body, header, footer, listeners, size }) {
    const modalToRender = {
        bodyComponentToRender: !!body
            ? {
                  name: body.name,
                  props: body.props
              }
            : null,
        footerComponentToRender: !!footer
            ? {
                  name: footer.name,
                  props: footer.props
              }
            : null,
        headerComponentToRender: !!header
            ? {
                  name: header.name,
                  props: header.props
              }
            : null,
        size: size || 'small'
    };

    if (listeners?.length) {
        for (const listener of listeners) {
            modalToRender[listener.name] = (event) => {
                listener.method.call(this, event);
            };
        }
    }

    BaseLightningModal.open(modalToRender);
}

/**
 * @description On a pagination button click, update the selected record and the pagination string
 * @param {`object`} event Expecting an event from baseModal
 *
 */
export function nextValueChange(event, hdrFrameComponentName, detailComponentName) {
    event.stopPropagation();

    // get the state of the custom frame component, aka get the list of records currently displayed, their sort, and other info
    try {
        getHDRFrameState.call(this, hdrFrameComponentName);
    } catch (error) {
        console.error('error retrieving the state of the custom frame component', error);
        return;
    }

    // update the current index based on the direction of the pagination
    switch (event.detail.operation.direction) {
        case 'next':
            if (this.currentIndex < this.state.displayList.length - 1) {
                this.currentIndex += 1;
            }
            break;
        case 'previous':
            if (this.currentIndex > 0) {
                this.currentIndex -= 1;
            }
            break;
        case 'first':
            this.currentIndex = 0;
            break;
        case 'last':
            this.currentIndex = this.state.displayList.length - 1;
            break;
        default: // do nothing
    }

    // "1 of 4" for example, the current record and the total number of records displayed in the table "frame"
    this.totalRecordsDetails = this.currentIndex + 1 + '  of  ' + this.state.displayList.length;
    // set the new selected record based on the current index
    this.selectedRecord = this.state.displayList[this.currentIndex];

    // call the setBasePaginationString method to update the pagination string on the modal
    // call the setSelectedRecord method on the radiologyDetails component to update the record details on the modal

    // TODO: Need a middle layer here so that devs can use this easier
    try {
        callPublicMethodsThroughModal.call(this, [
            {
                componentName: 'c/basePaginationString',
                methodName: 'setPaginationString',
                methodArgs: [this.totalRecordsDetails]
            },
            {
                componentName: 'c/basePaginationString',
                methodName: 'setCurrentIndex',
                methodArgs: [this.currentIndex]
            },
            {
                componentName: detailComponentName,
                methodName: 'setSelectedRecord',
                methodArgs: [this.selectedRecord]
            }
        ]);
    } catch (error) {
        console.error('error calling public methods through modal', error);
    }
}

/**
 * @description close rendered Modal
 */

export function closeModal() {
    const closeModalMethod = [
        {
            componentName: 'c/baseLightningModal',
            methodName: 'handleClose',
            methodArgs: [null]
        }
    ];

    callPublicMethodsThroughModal.call(this, closeModalMethod);
}

/**
 * @description executes a list of public methods on the dynamically generated components in baseLightningModal
 * @param {`array`} listOfMethodsToRun Expecting an array of objects with the component name, method name on the component, and the arguments for the method
 *
 */
export function callPublicMethodsThroughModal(listOfMethodsToRun) {
    publish(this.messageContext, this.messageChannel, { methodCalls: listOfMethodsToRun });
}

/**
 * @description sets add to note values for the calling component
 * @param {`object`} addToNoteDefaultOptions Expecting an object with default options for add to note
 */
export function settingAddToNoteValues(addToNoteDefaultOptions, addToNoteDefaultColumns) {
    //? set options config for add to note
    if (this.addToNoteOptions) {
        this._addToNoteOptions = JSON.parse(this.addToNoteOptions);
    } else {
        this._addToNoteOptions = addToNoteDefaultOptions;
    }

    //? sets columns for add to note
    if (this.columnsForAddToNote) {
        this._columnsForAddToNote = JSON.parse(this.columnsForAddToNote);
    } else {
        this._columnsForAddToNote = addToNoteDefaultColumns;
    }
}

/**
 * @description Invokes the buttonPressed method on the baseAddToNoteFrame component
 */

export function handleAddToNoteSubmit() {
    const callAddToNoteButtonPress = [
        {
            componentName: 'c/baseAddToNoteFrame',
            methodName: 'buttonPressed',
            methodArgs: [true]
        }
    ];
    callPublicMethodsThroughModal.call(this, callAddToNoteButtonPress);
}

/**
 * @description Activate the Add to Note button depending on criteria from baseAddToNoteFrame
 * @param event {`object`} Event from baseAddToNoteFrame, expected that event.detail be a boolean that indicates if the submit button in the footer should be disabled or not
 */

export function handleAddToNoteActivation(event) {
    const activateAddToNoteButton = [
        {
            componentName: 'c/baseButtonList',
            methodName: 'modifyButtons',
            methodArgs: [[{ name: 'submitaddtonote', disabled: event.detail }]]
        }
    ];

    callPublicMethodsThroughModal.call(this, activateAddToNoteButton);
}

/**
 * @description Creates the add to note modal with the appropriate footer and listeners
 * @param {`string`} size Size of the modal
 */
export function handleAddToNoteModalOpen(size = 'small') {
    const listeners = [
        {
            name: 'onsubmitaddtonote',
            method: this.handleAddToNoteSubmit
        },
        {
            name: 'onaddtonoteselected',
            method: this.handleAddToNoteActivation
        },
        {
            name: 'onclosemodal',
            method: this.closeModal
        }
    ];

    const body = {
        name: 'c/baseAddToNoteFrame',
        props: {
            options: this._addToNoteOptions,
            settings: this.settings,
            columns: this._columnsForAddToNote,
            incomingRecordId: this.recordId,
            pageSize: 11,
            list: datatableHelper.sortHDRData(
                [...this.hdrData],
                datatableHelper.getColumn(
                    this.columns ?? [],
                    this._addToNoteOptions.initialSort.field ?? this.defaultSortedBy
                ),
                this._addToNoteOptions.initialSort.direction ?? this.defaultSortedDirection
            ),
            sortedBy: this._addToNoteOptions.initialSort.field ?? this.defaultSortedBy,
            sortedDirection: this._addToNoteOptions.initialSort.direction ?? this.defaultSortedDirection
        }
    };

    const footer = {
        name: 'c/baseButtonList',
        props: {
            buttons: [
                {
                    name: 'submitaddtonote',
                    buttonProps: {
                        label: 'Submit',
                        value: 'submit',
                        name: 'submitaddtonote',
                        variant: 'brand',
                        disabled: true
                    }
                }
            ]
        }
    };

    renderBaseLightningModal.call(this, { body, footer, listeners, size });
}

/**
 * @description Capture the record selected and render a modal with the details of the selected record in the body and the pagination in the footer
 * @param event Event from BaseHDRFrame when a row is selected
 * @param hdrFrameComponentName Name of the custom frame component to query state from
 * @param detailComponentName Name of the detail component to render in the modal
 */
export function handleRowSelected(event, hdrFrameComponentName, detailComponentName) {
    this.selectedRecord = event.detail;
    getHDRFrameState.call(this, hdrFrameComponentName); // put this somewhere else
    this.totalRecordsDetails = this.currentIndex + 1 + '  of  ' + this.state.displayList.length;
    const listeners = [
        {
            name: 'onnavclick',
            method: this.nextValueChange
        },
        {
            name: 'onclose',
            method: this.closeModal
        }
    ];

    const propsObject = { selectedRecord: this.selectedRecord };
    // Problem Details has a table in the detail that needs the columns passed in
    if (detailComponentName === 'c/vccProblemDetails' || detailComponentName === 'c/vccAllergyDetails') {
        propsObject.commentColumns = this.detailComponentColumns;
    }
    const body = {
        name: detailComponentName,
        props: propsObject
    };
    const footer = {
        name: 'c/basePaginationString',
        props: {
            paginationString: this.totalRecordsDetails,
            currentRecordIndex: this.currentIndex,
            totalRecords: this.state.displayList.length
        }
    };

    renderBaseLightningModal.call(this, { body, footer, listeners, size: 'small' });
}

/**
 * @description updates the "hdrMessage" greeting above datatable
 */
export function updateHDRMessage() {
    let startDate = new Date(this.vtcArgs.startDate);
    const options = {
        year: 'numeric',
        month: 'numeric',
        day: 'numeric',
        timeZone: 'UTC'
    };

    if (this.isDirectives && (isMP || isPharmII || isPharmIII)) {
        this.hdrMessage = hdrDirectivesMessageLabel
            .replace('{1}', startDate.toLocaleDateString('en-US', options))
            .replace('{2}', getToday().en);
    } else if (this.isDirectives) {
        this.hdrMessage = hdrDirectivesMessage2Label
            .replace('{1}', startDate.toLocaleDateString('en-US', options))
            .replace('{2}', getToday().en);
    }

    // checking for Load More Personas
    // MP, Pharm II and Pharm III should view the new note
    else if (isMP || isPharmII || isPharmIII) {
        this.hdrMessage = hdrDateRangeLoadMoreMessageLabel
            .replace('{1}', startDate.toLocaleDateString('en-US', options))
            .replace('{2}', getToday().en);
    }
}

/**
 *
 * @description holds boileplate for creating a toast event
 * @param title - title for toast
 * @param variant - toast variant
 * @param message - message in toast
 * @return Built Toast Event
 */
export const createToastEvent = ({ title, variant, message }) => {
    return new ShowToastEvent({
        title: title,
        variant: variant || 'info',
        message: message,
        mode: 'sticky'
    });
};

/**
 * @description Asynchronously check/refresh the cache of callouts.
 */
export async function refreshDataInBatchesAsync() {
    this.setLoading(true);
    try {
        const vtcArgsBeforeBatching = { ...this.vtcArgs };
        // perform the refresh calls in batches of 5 and async to each other
        const batchPromises = chunkData(this.calloutsPerformed, 5).map(async (batch) => {
            await Promise.all(
                batch.map(async (callout) => {
                    this.vtcArgs = callout.vtcArgs;
                    await refreshApex(callout.cachedResult);
                })
            );
        });

        await Promise.all(batchPromises); // after batching is done
        this.vtcArgs = { ...vtcArgsBeforeBatching }; // set vtcArgs to its state prior to batching
        this.dispatchEvent(
            createToastEvent({ title: 'Success!', variant: 'success', message: 'Health Data Refreshed' })
        );
    } catch (error) {
        console.error('error reloading data from cache', error);
        createToastEvent({ title: 'Error!', variant: 'error', message: 'Refreshing Cached Health Data Failed' });
    } finally {
        this.refs?.hdrFrame?.resetSortedDefaultValues();
        this.setLoading(false);
        this.calloutsPerformed = [];
    }
}

/**
 * @description Handles the "load more" event. Sets the params for a new callout with the start and stop date params set per the last call and year in the "event.detail" property.
 *
 * @param event - year to load data back to e.g. "2018" - loads any records up until Jan 1, 2018
 */
export function handleLoadMore(event) {
    const { value } = event.detail;
    // if the year is greater than the start date year, then we can update the start date
    if (+value > +{ ...this.vtcArgs }.startDate.split('-')[2]) {
        const currentStartDateSplit = { ...this.vtcArgs }.startDate.split('-');
        this.vtcArgs = {
            icn: this.icn,
            startDate: `${value}-01-01`,
            stopDate: currentStartDateSplit.join('-')
        };

        setLoadMoreOptions.call(this, {
            patientBirthYear: this.patientBirthYear,
            calloutStartYear: +this.vtcArgs.startDate.split('-')[0]
        });

        this.refs.hdrFrame.invokePublicMethodsInActionsComponent([
            {
                methodName: 'setOptions',
                args: [this.actionsComponent.props.options]
            },
            {
                methodName: 'setLoading',
                args: [true]
            }
        ]);

        refreshApex(this.wiredCallout);

        if (this.wiredNotes) {
            refreshApex(this.wiredNotes);
        }

        if (this.wiredDirectives) {
            refreshApex(this.wiredDirectives);
        }
    }
}

/**
 * @description Takes a request, calculates its date range, and creates an array of requests that span said date range.
 */
export function createRequests(request, chunks = 5) {
    const startDate = new Date(request.startDate);
    const stopDate = new Date(request.stopDate);
    const totalDays = Math.ceil((stopDate - startDate) / (1000 * 60 * 60 * 24));
    const daysPerChunk = Math.ceil(totalDays / chunks);
    const requests = [];

    for (let i = 0; i < totalDays; i += daysPerChunk) {
        const chunkStartDate = new Date(startDate.getTime() + i * 24 * 60 * 60 * 1000);
        let chunkStopDate = new Date(startDate.getTime() + (i + daysPerChunk) * 24 * 60 * 60 * 1000);

        if (chunkStopDate > stopDate) {
            chunkStopDate = stopDate;
        }

        const newRequest = {
            ...request,
            startDate: chunkStartDate.toISOString().split('T')[0],
            stopDate: chunkStopDate.toISOString().split('T')[0]
        };
        requests.push(newRequest);

        if (chunkStopDate >= stopDate) {
            break;
        }
    }

    return requests.reverse();
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

// TODO: identify if a callout has hit the max logic

/**
 * @description Takes a request for a wire fetch VTC call, breaks it up into 5 smaller requests, then calls them asynchronously. Useful for handling "max" logic.
 */
export function chunkBigCalloutAndRunAsync() {
    createRequests.call(this, this.vtcArgs).forEach((request) => {
        this.vtcArgs = request;
        refreshApex(this.wiredCallout);
    });
}

/**
 * @description A generic success handler function, intended to be usable by VAHC HDR LWCs.
 * - Call this function from any `wiredCallout`, and/or when looping over the asyncCalls array in `executeAsyncCalls()`
 * - This function will flatten the HDR data (the sites' records) a return a single list of data
 * @param data `Object[]` The raw payload returned from HDR
 * @param request `Object` The JSON object that provided arguments to whatever Apex method performed a callout to HDR
 * - e.g. `this.vtcArgs`
 * @returns {Promise<void>}
 * - While this function does not return its Promise, it does assign a value to `this.hdrData`
 * @example
 * //a generified HDR callout
 * wire(getHDRData, { args: '$vtcArgs' })
 *  async wiredCallout(value) {
 *      const { data, error } = value;
 *      if (data) {
 *          await service.handleCalloutSuccess.call(this, data, this.vtcArgs);
 *      }
 *      if (error) {
 *          //optionally do other error handling locally to LWC
 *          await service.handleCalloutError.call(this, error, this.vtcArgs);
 *      }
 *  }
 */
export async function handleCalloutSuccess(data, request) {
    let hitsMaxBoundary = false;

    const wiredCall = {
        args: request,
        cachedResult: data
    };
    this.calloutsPerformed.push(wiredCall);

    for (const key of Object.keys(data.sites)) {
        // expected that this only be set once, after its true it shouldn't be set again
        if (!hitsMaxBoundary && data.sites[key].records.length === this.vtcArgs.max) {
            hitsMaxBoundary = true;
        }
        this.hdrData = this.hdrData !== undefined ? this.hdrData : []; // ensuring this.hdrData is instantiated
        if (data.sites[key].records.length !== 0) {
            this.hdrData.push(...data.sites[key].records);
        }
    }
    this.hdrData = this.hdrData !== undefined ? dedupe([...this.hdrData], 'vtcId') : []; // this triggers re-render
    updateHDRMessage.call(this);

    if (hitsMaxBoundary) {
        this.handleMaxLimitReached(wiredCall);
    } else {
        this.hdrData = processRecordsBaseline.call(this, [...this.hdrData]);
    }

    if (this.refs?.hdrFrame) {
        this.setLoading(false);
    }
}

/**
 * @description This is a general data-scrubbing function for the flat array of data passed to a lightning-datatable (or to baseHDRFrame).
 * - Adds formatted string representations of any date/datetime columns. (via `processRecord()`)
 * - Sorts data according to configured onload sorting behavior.
 * @param data `Object[]` a flat array of data
 * @return `Object[]` the input data, scrubbed and sorted
 */
export function processRecordsBaseline(data = []) {
    //find any date columns, or button columns whose typeAttributes.type indicate it's a "date" button
    const dateColumns = (this.columns ?? []).filter(
        (column) =>
            dateFormatter.DATATABLE_DATE_TYPES.includes(column.type) ||
            (column.type === 'button' && dateFormatter.DATATABLE_DATE_TYPES.includes(column.typeAttributes?.type))
    );

    //if the LWC for "this" context has a processRecord() function, execute it after executing processRecordBaseLine
    const haveLocalProcessRecordFunction = typeof this.processRecord === 'function';
    data = data.map((record) => {
        let baselineRecord = processRecordBaseline(record, dateColumns, this.formattedFieldNameMap ?? {});
        return haveLocalProcessRecordFunction ? this.processRecord(baselineRecord) : baselineRecord;
    });

    //sort the data either by the current sortedBy and sortedDirection properties in baseHDRFrame, or by the default sorting configuration
    return datatableHelper.sortHDRData(
        data,
        datatableHelper.getColumn(this.columns ?? [], this.refs?.hdrFrame?.sortedBy ?? this.defaultSortedBy),
        this.refs?.hdrFrame?.sortedDirection ?? this.refs?.hdrFrame?.sortDirection ?? this.defaultSortedDirection
    );
}

/**
 * @description Processes a single record
 * - Formats any date columns on the record, given an array of dateColumns
 * @param record `Object` a JSON object; an HDR record we would show in a datatable
 * @param dateColumns `Object[]` an array of 'date' or 'date-local' type columns for a lightning-datatable
 * @param formattedFieldNameMap `Object` an optional JSON object with keys matching columns' fieldName values and values representing what new property should be added to the return value to hold the date's formatted String value
 * @return `Object` the original record, plus any newly-added formatted date columns
 */
export function processRecordBaseline(record = {}, dateColumns = [], formattedFieldNameMap = {}) {
    return {
        ...(record ?? {}),
        ...formatRecordDateColumns(record, dateColumns ?? [], formattedFieldNameMap ?? {})
    };
}

/**
 * @description Given provided record and array of date columns, this function formats those columns' values from the source record and returns a new object containing ONLY the formatted String values
 * - See the examples in this documentation regarding how to use this function in conjunction with the object spread operator to make a copy of a record that includes the newly-formatted datetime String values
 * - The actual datetime String formatting is performed by `c/utils/dateFormatter.salesForceDateTimeStringToMMDDYYYYHHMM()`
 * @param record `Object` a JSON object; an HDR record we would show in a datatable
 * @param dateColumns `Object[]` an array of 'date' or 'date-local' type columns for a lightning-datatable
 * @param formattedFieldNameMap `Object` an optional JSON object with keys matching date columns' fieldName values and values representing what new property should be added to the return value to hold the date's formatted String value
 * - for example: A date column with fieldName "CreatedDate" and a formattedFieldNameMap such as `{CreatedDate: 'TheFormattedCreatedDate'} results in a "TheFormattedCreatedDate" property on the result object
 * - If this parameter is not specified, a date column's fieldName results in a new property on the result object of `fieldName + 'String'`
 * @return `Object` a new object whose properties are those specified by the formattedFieldNameMap and/or the date/date-local columns' fieldNames with 'String' appended to the end
 * @example
 * // returns `{CreatedDate: '2024-08-25T19:25:56.000+0000 (Eastern Daylight Time)', CreatedDateString: '8/25/2024'}`
 * // note the 'date-local' column type results in ignoring the Timestamp in the formatting operation
 * const record = {CreatedDate: '2024-08-25T19:25:56.000+0000 (Eastern Daylight Time)'};
 * const dateColumns = [{label: 'Created Date', fieldName: 'CreatedDate', type: 'date-local'}];
 * let newRecord = {...record, ...formatRecordDateColumns(record, dateColumns)};
 * @example
 * // returns `{CreatedDate: '2024-08-25T19:25:56.000+0000 (Eastern Daylight Time)', TheFormattedCreatedDate: '8/25/2024, 7:25 PM'}`
 * const record = {CreatedDate: '2024-08-25T19:25:56.000+0000 (Eastern Daylight Time)'};
 * const dateColumns = [{label: 'Created Date', fieldName: 'CreatedDate', type: 'date'}];
 * let newRecord = {...record, ...formatRecordDateColumns(record, dateColumns, {CreatedDate: 'TheFormattedCreatedDate'})};
 * @see `c/utils/dateFormatter.salesForceDateTimeStringToMMDDYYYYHHMM()`
 */
export function formatRecordDateColumns(record = {}, dateColumns = [], formattedFieldNameMap = {}) {
    return record
        ? dateColumns.reduce((result, column) => {
              const { fieldName, type, typeAttributes } = column;
              const dateOnly = type === dateFormatter.DATE_LOCAL || typeAttributes?.type === dateFormatter.DATE_LOCAL;
              const newFieldName = formattedFieldNameMap[fieldName] ?? fieldName + 'String';
              result[newFieldName] = dateOnly
                  ? dateFormatter.formatDateTimeStringToMMDDYYYY(record[fieldName])
                  : dateFormatter.salesForceDateTimeStringToMMDDYYYYHHMM(record[fieldName]);
              return result;
          }, {})
        : {};
}

export async function handleCalloutError(error, request) {
    if (error.body?.message === 'RETRY_CMD') {
        await this.executeAsyncCalls(createRequests(request));
    } else {
        this.hasError = true;
    }
}
