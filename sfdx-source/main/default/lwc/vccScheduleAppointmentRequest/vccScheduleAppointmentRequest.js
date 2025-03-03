/**
 * @description This lwc is designed to schedule an Appointment Request. In the VAHC App, under the appointments tab on a patient account record, there is an Appointment Requests tab. Here you can see and act on
 * appointment requests. If you select the "Schedule Appointment Request" button on the Appointment Request flexcard (this is OmniStudio), it will process a flyout to this lwc, where the appointment request will be passed into
 * the apptRequest property. In this component,  it will load the initial TimeSlots(ClinicScheduleSlots) available for the Clinic that was associated with the appointment request, then pass them to the vccCalendar lwc, where
 * they will be displayed for selection.
 * @author Booz Allen Hamilton
 * @since 3/25/2024
 */
import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';
import fetchTimeslots from '@salesforce/apex/VCC_ScheduleAppointmentRequestController.fetchTimeslots';
import getClinicsByProvider from '@salesforce/apex/VCC_ScheduleAppointmentRequestController.getClinicsByProvider';
import searchExistingAppointments from '@salesforce/apex/VCC_ScheduleAppointmentRequestController.searchExistingAppointments';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { existingApptFound } from './vccHandleExistingApptTimeSlot';
import { loadStyle } from 'lightning/platformResourceLoader';
import toastCSS from '@salesforce/resourceUrl/toastCSS';
import { clinicTimezoneDateSetter } from './vccClinicTimezoneDateSetter';

const DATE_OPTIONS = { weekday: undefined, year: 'numeric', month: 'short', day: 'numeric' };

export default class VccScheduleAppointmentRequest extends OmniscriptBaseMixin(LightningElement) {
    //Omni properties
    @api apptRequest;
    ////////////////
    //Patient, Clinic, and Facility variables
    timeSlotSelected = false;
    //selectedTimeSlots represents the time slots that are currently selected
    selectedTimeslots = [];
    //clinicDetails represents the Clinic Info retrieved by the getClinicByIEN callout
    clinicDetails;
    //clinicIEN represents the IEN of the Clinic currently being viewed
    clinicIEN;
    //clinicName represents the Name of the Clinic currently being viewed
    clinicName;
    //clinicVistaTimeZone represents the VistA TimeZone Name of the Clinic currently being viewed
    clinicVistaTimeZone;
    //clinicTimezoneSettings represents Today's date in the Clinic's Timezone as well as IANA Timezone Format
    clinicTimezoneSettings;
    //clinicStopCodeNumber represents the Stop Code of the Clinic currently being viewed
    clinicStopCodeNumber;
    //timeSlots represents the time slots that are currently being viewed in the Calendar
    // checks if calculateInitialSearch has occurred or not.
    calculatedInitialSearch = false;
    patientIndicatedDate;
    timeSlots = [];
    facilityCode;
    facilityData;
    providerIEN;
    providerName;
    @track existingAppointments = [];
    @track formattedClinicsByProvider;
    @track formattedClinicsByClinicGroup;
    @api recordId;
    //Date Variables
    startDate;
    stopDate;
    oldestStartDateRetrieved;
    newestStopDateRetrieved;
    userViewStart;
    userViewEnd;
    today;
    //State preservation variables
    showCalendar = false;
    searchedClinicIEN;
    searchedClinicName;
    selectedClinicGroupClinicIEN;
    selectedClinicGroupClinicName;
    selectedProviderClinicIEN;
    selectedProviderClinicName;
    activeTab = 'Clinic';
    //Calendar Options
    calendarDate;
    calendarView;
    //Notification variables
    message;
    loading = false;

    @track isCSSLoaded = false;
    /**
     * @description renderedCallBack to Import toastCSS for allowing Line Breaks in Toast message.
     */
    renderedCallback() {
        if (this.isCSSLoaded) {
            return;
        }
        loadStyle(this, toastCSS).then(() => {
            this.isCSSLoaded = true;
        });
    }

    /**
     * @description connectedCallback will push the clinicIEN associated with the appointment request to an array that is passed to the apex controller, and it will calculate the search timeframe based on the DateValue
     * (Patient Indicated Date). It then calls getTimeSlots, which will initiate the Apex controller for returning the TimeSlots. Also sets initial calendar options such as date and view.
     **/
    connectedCallback() {
        //initial Calendar Options
        this.patientIndicatedDate = new Date(this.apptRequest?.DateValue);
        this.calendarView = 'timeGridWeek';
        this.clinicIEN = this.apptRequest?.ClinicIEN;
        this.providerIEN = this.apptRequest?.ProviderIEN;
        this.facilityCode = this.apptRequest?.FacilityStationId;
        this.clinicName = this.apptRequest?.ClinicName;
        this.searchExistingAppointments();
        if (this.apptRequest.RequestedBy === 'Provider') {
            this.getClinicsByProvider();
        }
    }

    /**
     * @description calculateInitialSearchTimeframe takes in the PatientIndicatedDate and calculates a 40-day search window around the patientIndicatedDate.
     *   adjusting the start date to ensure it does not fall before today's date.
     *   The default search timeframe is 20 days behind, and 20 days after the patient indicated date.
     *   If the current date is later than the patient indicated date, then use the current date for the start date.
     * @param {String} dateValue The date to calculate one month behind and one month after.
     **/
    calculateInitialSearchTimeframe(dateValue) {
        let patientIndicatedDate = new Date(dateValue);
        let start = patientIndicatedDate;
        let end = patientIndicatedDate <= this.today ? new Date() : new Date(dateValue);
        // Calculate the start date as 20 days before the initial start date: If this calculated date is earlier than today, set the start date to today
        this.startDate = new Date(start.setDate(start.getDate() - 20)) <= this.today ? this.today : start;
        // Calculate the stop date as 20 days after the end date
        this.stopDate = new Date(end.setDate(end.getDate() + 20));
        this.oldestStartDateRetrieved = this.startDate;
        this.newestStopDateRetrieved = this.stopDate;
    }

    /**
     * @description calculateNewSearchTimeframe is invoked when the user navigates to a date range view in the calendar that is outside of the current loaded timeframe
     * of TimeSlots. If the user navigates backward to a date range view that is before the current loaded timeframe, it will calculate one month behind the old startDate.
     * If the user navigates forward to a date range view that is after the current loaded timeframe, it will calculate one month after the old stopDate. It then kicks off
     * another search of Time Slots.
     * @param {String} direction Can be backward or forward. This is determined by the handleDateRangeChange function.
     **/
    calculateNewSearchTimeFrame(direction) {
        switch (direction) {
            case 'backward':
                this.stopDate = new Date(this.startDate);
                this.startDate =
                    new Date(this.startDate.setMonth(this.startDate.getMonth() - 1)) <= this.today
                        ? this.today
                        : this.startDate;
                this.oldestStartDateRetrieved = this.startDate;
                break;
            case 'forward':
                this.startDate = new Date(this.stopDate);
                this.stopDate = new Date(this.stopDate.setMonth(this.stopDate.getMonth() + 1));
                this.newestStopDateRetrieved = this.stopDate;
                break;
            default:
        }
        this.fetchTimeslots();
    }
    /**
     * @description handleSetClinicDetails receives the Clinic Data from vccClinicDetails to store values in properties
     * clinic's timezone is retrieved and utilized to set up the today property based on the Timezone of the clinic
     * @param {event} event - clinic data retrieved from vccClinicDetails
     **/
    handleSetClinicDetails(event) {
        if (!event || !event.detail || !event.detail.clinicDetails) {
            this.showToast("Unable to retrieve Clinic's Details", '', 'error', 'sticky');
            return;
        }
        this.clinicDetails = event.detail.clinicDetails;
        this.clinicStopCodeNumber = this.clinicDetails?.primaryStopCode;
        this.clinicVistaTimeZone = this.clinicDetails?.timezone;
        ///Set up Calendar's Today date based on Clinic's Timezone:
        this.clinicTimezoneSettings = clinicTimezoneDateSetter(this.clinicVistaTimeZone);
        if (this.clinicTimezoneSettings && this.clinicTimezoneSettings.clinicDate) {
            this.today = this.clinicTimezoneSettings.clinicDate;
        }

        if (!this.calculatedInitialSearch) {
            this.calendarDate = this.patientIndicatedDate >= this.today ? this.patientIndicatedDate : this.today;
            this.userViewStart = this.calendarDate;
            this.calculateInitialSearchTimeframe(this.calendarDate);
            this.calculatedInitialSearch = true;
        }
        this.fetchTimeslots();
    }

    /**
     * @description stores the parameters for searching Clinic and Provider Time Slots to be used in Apex callouts in fetchTimeSlots() and getClinicsByProvider()
     */
    get timeSlotParams() {
        return {
            startDate: this.startDate,
            stopDate: this.stopDate,
            clinicIEN: this.clinicIEN,
            providerIEN: this.providerIEN,
            facilityCode: this.facilityCode
        };
    }

    /**
     * @description stores the parameters for the calendar, so that subsequent rerender's on the calendar render as the proper state
     */
    get calendarOptions() {
        return {
            initialDate: this.calendarDate,
            initialView: this.calendarView,
            timeZone: this.clinicTimezoneSettings.timeZone
        };
    }

    /**
     * @description determines if this is not a Recall Appointment Request, so the Clinic Search component as well as the Provider and Clinic Group tabs can be rerendered
     */
    get isNotRecallAppointmentRequest() {
        return this.apptRequest?.AppointmentRequestType !== 'PtCSch';
    }

    /**
     * @description searches All Scheduled Appointments associated with Patient
     *  by utilizing record Id and stores in existingAppointments.
     */
    async searchExistingAppointments() {
        try {
            let result = await searchExistingAppointments({
                patientId: this.recordId
            });

            this.existingAppointments = result;
        } catch (error) {
            this.handleLoggerError(error);
        }
    }

    /**
     * @description fetchTimeSlots makes the call to the Apex controller to get the time slots available for the clinic on the appointment request. If no clinics are found, it will initiate a toast message stating that
     * no records were found between the search dates.
     **/
    async fetchTimeslots() {
        try {
            this.loading = true;
            let result = await fetchTimeslots({
                timeSlotParams: this.timeSlotParams
            });
            this.handleTimeSlotResult(result);
            this.loading = false;
        } catch (error) {
            this.handleLoggerError(error);
        } finally {
            this.loading = false;
            this.showCalendar = true;
        }
    }

    /**
     * @description getClinicsByProvider makes call to the Apex controller to retrieve Clinics that the Provider is associated with.
     **/
    async getClinicsByProvider() {
        try {
            this.loading = true;
            this.activeTab = 'Provider';
            let result = await getClinicsByProvider({
                timeSlotParams: this.timeSlotParams
            });
            // If endpoint doesn't return clinics, attach clinic associated with Appointment Request to result.
            if (result === null && this.clinicIEN && this.clinicName) {
                result = [];
                result.push({
                    id: this.clinicIEN,
                    name: this.clinicName
                });
            }
            this.handleClinicsByProviderSearchResult(result);
        } catch (error) {
            this.handleLoggerError(error);
        } finally {
            this.loading = false;
        }
    }

    /**
     * @description Handles the logic of sorting the array based on the Clinic in the Appointment Request
     * @param {*} result
     */
    handleClinicsByProviderSearchResult(result) {
        this.formattedClinicsByProvider = result.map((clinic) => {
            return {
                AssociatedClinicIEN: clinic.id,
                AssociatedClinicName: clinic.name
            };
        });
        this.handleProviderClinicListOrder();
    }

    /**
     * @description handles the results for function fetchTimeSlots to show if Timeslots are available or not.
     * @param result - passed from fetchTimeSlots after Apex Callout is made. Stores results from apex methods.
     */
    handleTimeSlotResult(result) {
        let resultSlots;
        resultSlots = result?.records[0]?.slots;
        if (!resultSlots?.length) {
            this.showToast(
                'No time slots available between ' +
                    this.startDate.toLocaleDateString('en-us', DATE_OPTIONS) +
                    ' and ' +
                    this.stopDate.toLocaleDateString('en-us', DATE_OPTIONS),
                '',
                'info',
                'sticky'
            );
        } else {
            this.timeSlots = [...this.timeSlots, ...resultSlots];
            let deDupSlots = new Set();
            this.timeSlots = this.timeSlots.filter((slot) => {
                // Format the slot's startTimeISO in the clinic's time zone
                let slotStartDate = clinicTimezoneDateSetter(this.clinicVistaTimeZone, slot.startTimeISO);
                // Check if the slot's start time is not a duplicate and is not in the past compared to today
                if (!deDupSlots.has(slotStartDate.clinicDate.getTime()) && this.today <= slotStartDate.clinicDate) {
                    deDupSlots.add(slotStartDate.clinicDate.getTime());
                    return true;
                }
                return false;
            });
        }
    }

    /**
     * @description handleDateRangeChange is a handler function that is used when the user changes the date range of the calendar. When the date range changes, we should
     * check the current date range of their view against the timeslots that are currently loaded into the calendar. If the view is outside of the range of timeslots that are
     * loaded, we need to load more timeslots. This function will set the start and end date of the timeSlotParams property to one month further, and call getTimeSlots again
     * to get more timeslots. Also, since the calendar will be re-rendered, it saves the user's current date and view that is set on the calendar, and saves it in calendarOptions.
     * @param {Object} event
     */
    handleDateRangeChange(event) {
        this.userViewStart = new Date(event.detail.newStart);
        this.userViewEnd = new Date(event.detail.newEnd);
        this.calendarDate = new Date(event.detail.currentDate);
        this.calendarView = event.detail.currentView;

        //User navigates backwards from the PID. View Start date less than oldestStartDateRetrieved, but greater than or equal to this.today's date. Get more TimeSlots.
        if (this.userViewStart < this.oldestStartDateRetrieved && this.userViewStart >= this.today) {
            this.startDate = this.oldestStartDateRetrieved;
            this.calculateNewSearchTimeFrame('backward');
        }
        //User navigates forwards from the PID. View end date greater than newestStopDateRetrieved. Get more TimeSlots.
        if (this.userViewEnd > this.newestStopDateRetrieved) {
            this.stopDate = this.newestStopDateRetrieved;
            this.calculateNewSearchTimeFrame('forward');
        }
    }

    //TODO: Figure out if we need to run a deduplication on retrieved TimeSlots
    /*
    isEverythingUnique(arr, key) {
        const uniques = new Set(arr.map((item) => item[key]));
        return [...uniques].length === arr.length;
    }
    deduplicateTimeslots() {}
    */

    /**
     * @description showToast is a generic function that accepts the parameters that customize a standard OOB toast message
     * @param {String} ti Represents the title property
     * @param {String} mes Represents the message property
     * @param {String} vari Represents the variant property (eg. info, warning, error)
     * @param {String} md Represents the mode property (eg. sticky, pester, dismissible )
     **/
    showToast(ti, mes, vari, md) {
        const evt = new ShowToastEvent({
            title: ti,
            message: mes,
            variant: vari,
            mode: md
        });
        this.dispatchEvent(evt);
    }

    /**
     * @description handleSelectedTimeSlot is an event handler function for the selectedtimeslot event published by the vccCalendar component.
     * @param {Object} event Represents the TimeSlot that was selected in the vccCalendar component. This will set the selectedTimeSlots property to the selected records, then
     * pass them to the vccScheduleAppointment component to create the Appointment record.
     **/
    handleSelectedTimeSlot(event) {
        this.selectedTimeslots = event.detail;
        if (this.selectedTimeslots.length > 0 && this.existingAppointments.length > 0) {
            let existingAppt = existingApptFound(this.selectedTimeslots, this.existingAppointments);
            if (existingAppt.toastMessage !== '') {
                this.handleTimeslotOnExistingAppt(existingAppt);
            }
        }
    }

    /**
     * @description handleClinicTabActive performs actions that must occur every time the user navigates back to the Clinic tab.
     */
    handleClinicTabActive() {
        if (this.activeTab !== 'Clinic') {
            this.clinicIEN = this.searchedClinicIEN || this.apptRequest?.ClinicIEN;
            this.clinicName = this.searchedClinicName || this.apptRequest?.ClinicName;
            this.emptyAndFetchTimeslots();
            this.activeTab = 'Clinic';
        }
    }

    /**
     * @description handleClinicGroupTabActive performs actions that must occur every time the user navigates back to the Clinic Group tab.
     */
    handleClinicGroupTabActive() {
        if (this.activeTab !== 'Clinic Group') {
            if (this.selectedClinicGroupClinicIEN) {
                this.clinicIEN = this.selectedClinicGroupClinicIEN;
                this.clinicName = this.selectedClinicGroupClinicName;
                this.emptyAndFetchTimeslots();
            }
            this.activeTab = 'Clinic Group';
        }
    }

    /**
     * @description handleProviderTabActive performs actions that must occur every time the user navigates back to the Provider tab.
     */
    handleProviderTabActive() {
        if (this.activeTab !== 'Provider') {
            if (this.selectedProviderClinicIEN) {
                this.clinicIEN = this.selectedProviderClinicIEN;
                this.clinicName = this.selectedProviderClinicName;
                this.emptyAndFetchTimeslots();
            }
            this.activeTab = 'Provider';
        }
    }

    /**
     * @description Displays Toast Message when a Time Slot is selected on a date of an existing appointment.
     * @param existingAppt - holds the toast messsage and formatted dates
     **/
    handleTimeslotOnExistingAppt(existingAppt) {
        this.showToast(
            `WARNING! The patient has other scheduled appointments on ${existingAppt.formattedselectedTimeslots}.`,
            existingAppt.toastMessage,
            'warning',
            'sticky'
        );
    }

    /**
     * @description handleBackToCalendar is an event handler function for the backtocalendar event published by the vccScheduleAppointment component. It will return the user to the calendar from the vccScheduleAppointment lwc
     **/
    handleBackToCalendar() {
        this.timeSlotSelected = false;
        this.selectedTimeslots = [];
    }

    /**
     * @description handleChangeClinic is an event handler function that allows the user to switch the clinic, and then view that clinic's TimeSlots instead of the clinic associated with the Appointment Request.
     **/
    handleChangeClinic(event) {
        if (!event || !event.detail || !event.detail.clinicId || !event.detail.clinicName) {
            this.showToast('Unable to retrieve Clinic', '', 'error', 'sticky');
            return;
        }
        this.showCalendar = false;
        this.clinicIEN = event.detail.clinicId;
        this.clinicName = event.detail.clinicName;
        if (event.detail?.state === 'ClinicGroup') {
            this.selectedClinicGroupClinicIEN = this.clinicIEN;
            this.selectedClinicGroupClinicName = this.clinicName;
        }
        if (event.detail?.state === 'Provider') {
            this.selectedProviderClinicIEN = this.clinicIEN;
            this.selectedProviderClinicName = this.clinicName;
            this.handleProviderClinicListOrder();
        }
        this.emptyAndFetchTimeslots();
    }

    /**
     * @description handleProviderClinicListOrder handles the order of the Provider's associated clinics that displays of the calendar
     * The Clinic IEN that is currently set in this.clinicIen will be set first in the array.
     **/
    handleProviderClinicListOrder() {
        //Find Where clinicIEN is in the Selected Provider's Clinic
        const indexToPrioritize = this.formattedClinicsByProvider.findIndex(
            (item) => item.AssociatedClinicIEN === this.clinicIEN
        );
        // If clinicIEN isn't first in the index, set it to first
        // ex. clinicIEN = 200, formattedClinicsByProvider = [{AssociatedClinicName = clinic1, AssociatedClinicIEN = 100}, {AssociatedClinicName = clinic2, AssociatedClinicIEN = 200}]
        //  => formattedClinicsByProvider = [{AssociatedClinicName = clinic2, AssociatedClinicIEN = 200}, {AssociatedClinicName = clinic1, AssociatedClinicIEN = 100}]
        if (indexToPrioritize !== -1 && indexToPrioritize !== 0) {
            const clinicToPrioritize = this.formattedClinicsByProvider.splice(indexToPrioritize, 1)[0];
            this.formattedClinicsByProvider.unshift(clinicToPrioritize);
        }
        this.clinicIEN = this.formattedClinicsByProvider[0].AssociatedClinicIEN;
        this.clinicName = this.formattedClinicsByProvider[0].AssociatedClinicName;
    }

    /**
     * @description handleSelectClinic is an event handler function that allows the user to switch the clinic under the Clinic tab to a Clinic that was searched for by vccClinicLookup
     **/
    handleSelectClinic(event) {
        if (!event || !event.detail || !event.detail.selectedClinic) {
            this.showToast('Unable to select this Clinic', '', 'error', 'sticky');
            return;
        }
        this.showCalendar = false;
        let selectedClinic = event.detail.selectedClinic;
        this.clinicIEN = selectedClinic.id;
        this.searchedClinicIEN = selectedClinic.id;
        this.searchedClinicName = selectedClinic.name;
        this.clinicName = selectedClinic.name;
        this.emptyAndFetchTimeslots();
    }

    /**
     * @description Change handler for when a user selects a different Provider. Implements actions that must be taken every time a Provider is switched.
     * @param {*} event
     */
    handleSelectProvider(event) {
        let selectedProvider = event.detail.selectedProvider;
        this.providerIEN = selectedProvider.ien;
        this.providerName = selectedProvider.name;
        this.calculateInitialSearchTimeframe(this.userViewStart);
        this.getClinicsByProvider(this.providerIEN);
    }

    /**
     * @description handleDefaultProvider is used to provide a default providerIEN when the Appointment Request is Requested by Patient. The vccClinicDetails lwc will pass the first providerIEN in its fullProviderList array
     * back to this component via an event. This component will use the IEN to populate the initial list of Providers for the Provider tab.
     */
    handleDefaultProvider(event) {
        if (!this.providerIEN) {
            this.providerIEN = event.detail?.providerIEN;
            this.providerName = event.detail?.providerName;
            this.activeTab = 'Clinic';
        }
    }

    /**
     * @description postError is a helper function that will take in a message variable and publish a toast that contains the message.
     * @param {*} message The message to display in the error
     */
    postError(message) {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error'
        });
        this.dispatchEvent(evt);
    }
    /**
     * @description Handles the navigation to the confirmation screen. If no time slots have been selected, it throws an error.
     */
    handleNavigateToConfirmationScreen() {
        if (this.selectedTimeslots.length) {
            this.timeSlotSelected = true;
        } else {
            this.postError('Please select a Time Slot to continue.');
        }
    }

    /**
     * @description This method is called when a Clinic Group is selected in vccClinicGroupLookup. It kicks off the retrieve of the Clinics for the Clinic Group
     * @param {*} event
     */
    handleSelectClinicGroup(event) {
        this.selectedClinicGroup = event.detail.selectedClinicGroup;
        this.formattedClinicsByClinicGroup = this.selectedClinicGroup.resources;
        this.clinicIEN = this.formattedClinicsByClinicGroup[0].ien;
        this.activeTab = 'Clinic Group';
        this.emptyAndFetchTimeslots();
    }

    /**
     * @description handles Errors in callouts and saves logs utilizing Logger
     * @param {*} error - The error that occurred which is logged.
     */
    handleLoggerError(error) {
        const logger = this.template.querySelector('c-logger');
        if (error instanceof Error) {
            logger.error(error.message);
            logger.error(error.stack);
        } else {
            logger.error(JSON.stringify(error));
        }
        logger.saveLog();
    }
    /**
     * @description clears out timeslots from timeSlots and selectedTimeSlots arrays
     * Sets search time frame from the position where end user is on the Calendar.
     */
    emptyTimeSlots() {
        this.timeSlots = [];
        this.selectedTimeslots = [];
        this.calculateInitialSearchTimeframe(this.userViewStart);
    }
    /**
     * @description clears out time slots from timeSlots and selectedTimeSlots arrays and fetches new timeslots
     */
    emptyAndFetchTimeslots() {
        this.emptyTimeSlots();
        this.fetchTimeslots();
    }
}
