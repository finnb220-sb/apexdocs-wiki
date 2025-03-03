import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fullCalendar from '@salesforce/resourceUrl/FullCalendar';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';

/**
 * @description DATE_OPTIONS1 is used to define the start time of the timeslot for 508 compliance
 */
const DATE_OPTIONS1 = {
    weekday: undefined,
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    second: undefined
};
/**
 * @description DATE_OPTIONS2 is used to define the end time of the timeslot for 508 compliance. Only needed for hour and minutes of the date time, since the start time will give the year/month/day
 */
const DATE_OPTIONS2 = {
    weekday: undefined,
    year: undefined,
    month: undefined,
    day: undefined,
    hour: '2-digit',
    minute: '2-digit',
    second: undefined
};

/**
 * @description DATE_OPTIONS3 is used to format a date in this format: July 4
 */
const DATE_OPTIONS3 = {
    weekday: 'long',
    year: 'numeric',
    month: 'numeric',
    day: 'numeric',
    hour: undefined,
    minute: undefined,
    second: undefined
};

/**
 * @description Formatter for DATE_OPTIONS3
 */
const DATEFORMAT3 = new Intl.DateTimeFormat('en-US', DATE_OPTIONS3);

const VIEW_OPTIONS = ['timeGridDay', 'timeGridWeek', 'dayGridMonth'];

export default class FullCalendarComponent extends NavigationMixin(LightningElement) {
    //Public Properties
    @api patientIndicatedDate;
    @api providerTimeSlots;
    @api timeSlots;
    @api clinicOverbookingLimit;
    @api clinicDisplayStartTime;
    @api isVariableLengthAppointment = false;
    //Calendar properties
    calendar;
    @api calendarOptions;
    //Component Properties
    selectedTimeSlots = [];
    /**
     * @description This property is used when multiple time slots must be deselected at the same time. This happens when a user clicks a timeslot on a different day. I needed a way to store the element info of all the
     * currently selected time slots. All other instances of select/deselect will use the element instance passed into the function itself.
     */
    selectedTimeSlotElements = [];
    formattedTimeSlots = [];
    calendarLabel;
    fullCalendarInitialized = false;
    #handleEventClickCallBack;

    timeGridDayVariant = 'neutral';
    timeGridWeekVariant = 'neutral';
    dayGridMonthVariant = 'neutral';

    /**
     * @description connectedCallback for vccCalendar. Formats the timeslots for use in the Full Calendar cmp and then adds an
     * event listener to react to when a User selects an event.
     */
    connectedCallback() {
        this.setCurrentViewButtonVariant();
        this.formatTimeSlots();
        //this.dedupeTimeSlots(); This is commented out for the moment. It may be needed later.
        this.#handleEventClickCallBack = this.handleEventClick.bind(this);
        this.addEventListener('fceventclick', this.#handleEventClickCallBack);
    }

    /**
     * @description This method selects the correct button (Day,Week,Month) based on the view loaded on the calendar upon load of the component.
     */
    setCurrentViewButtonVariant() {
        if (this.calendarOptions.initialView) {
            this[this.calendarOptions.initialView + 'Variant'] = 'brand';
        }
    }

    /**
     * @description getter for a fullCalendar friendly string to control when the calendar display start time begins
     */
    get clinicDisplayStartTimeString() {
        let clinicDisplayStartTimeInteger = this.clinicDisplayStartTime || 8;
        return clinicDisplayStartTimeInteger + ':00:00';
    }

    /**
     * @description Formats the timeslots passed into the calendar into a structure that the calendar will accept
     */
    formatTimeSlots() {
        if (this.timeSlots.length) {
            this.timeSlots.map((slot) =>
                this.formattedTimeSlots.push({
                    start: slot?.startTimeISO,
                    end: slot?.endTimeISO,
                    variableLengthIndicator: slot?.variableLengthIndicator,
                    title: this.generateTimeSlotTitle(slot),
                    available: slot?.available,
                    numberOverbooked: slot?.numberOverBooked,
                    salesforceId: slot?.salesforceId,
                    id: this.generateUUID()
                })
            );
        }
    }

    /**
     * @description This method generates the title for the Time Slot based on whether the Slot is available or overbooked
     * @param {Object} slot The Time Slot to generate the title for
     * @returns {String} The title for the Time Slot
     */
    generateTimeSlotTitle(slot) {
        let title = '';
        if (slot == null) {
            return title;
        }
        if (slot.available === 0 && slot.numberOverBooked > 0) {
            title = 'Overbooked: ' + slot.numberOverBooked;
        } else if (slot.available >= 0) {
            title = 'Available: ' + slot.available;
        }
        return title;
    }

    /* Saving this code here in case it is needed later
    dedupeTimeSlots(){
        const deduplicated = new Set();
        //Ensure only one slot per start time
        this.formattedTimeSlots = this.formattedTimeSlots.filter((slot) => {
            const duplicate = deduplicated.has(slot.start.getTime());
            deduplicated.add(slot.start.getTime());
            return !duplicate;
        });
    }
        */

    /**
     * @description UUID generater is needed to assign a custom id to a timeslot. This allows us to remove timeslots from the selectedTimeSlots array that are deselected by id reference.
     * @returns A random UUID
     */
    generateUUID() {
        return '10000000-1000-4000-8000-100000000000'.replace(/[018]/g, (c) =>
            (+c ^ (crypto.getRandomValues(new Uint8Array(1))[0] & (15 >> (+c / 4)))).toString(16)
        );
    }

    /**
     * @description Loads the static resource for FullCalendar into the DOM and then kicks off the init of the component
     * @returns If the calendar is already rendered, return and do nothing
     */
    renderedCallback() {
        if (this.fullCalendarInitialized) {
            return;
        }
        this.fullCalendarInitialized = true;
        Promise.all([loadStyle(this, fullCalendar + '/lib/main.css'), loadScript(this, fullCalendar + '/lib/main.js')])
            .then(() => {
                this.init();
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading Calendar',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });
    }

    /**
     * @description Loads the FullCalendar.io cmp into the DOM with options specified
     */
    init() {
        let calendarEl = this.template.querySelector('.calendar');
        // eslint-disable-next-line no-undef
        this.calendar = new FullCalendar.Calendar(calendarEl, {
            initialView: this.calendarOptions.initialView,
            initialDate: new Date(this.calendarOptions.initialDate),
            businessHours: false,
            allDaySlot: false,
            contentHeight: 'auto',
            slotMinTime: this.clinicDisplayStartTimeString,
            slotMaxTime: '24:00:00',
            scrollTime: '14:00:00',
            slotEventOverlap: false,
            eventInteractive: true,
            expandRows: true,
            moreLinkClick: 'popover',
            stickyHeaderDates: true,
            eventTimeFormat: {
                hour: 'numeric',
                minute: '2-digit',
                meridiem: 'narrow'
            },
            timeZone: this.calendarOptions.timeZone,
            navLinks: true,
            navLinkDayClick: (date) => {
                const dayViewButton = this.template.querySelector('.day-view-button');
                dayViewButton.focus();
                this.dailyViewHandler(date);
            },
            events: this.formattedTimeSlots,
            eventClick: (info) => {
                const selectedEvent = new CustomEvent('fceventclick', { detail: info });
                this.dispatchEvent(selectedEvent);
            },
            headerToolbar: false
        });
        this.calendar.render();
        this.calendarLabel = this.calendar.view.title;
    }

    /**
     * @description helper method to execute steps that must be taken every time the view changes
     */
    viewChangeHandler() {
        this.calendarLabel = this.calendar.view.title;
        this.publishDateRangeChange();
        this.selectedTimeSlots = [];
        this.selectedTimeSlotElements = [];
        this.publishTimeSlots();
        this.selectDeselectViewButtons();
    }

    /**
     * @description This method toggles the variant of the view button that the user selects (Day, Week, or Month)
     */
    selectDeselectViewButtons() {
        VIEW_OPTIONS.forEach((view) => {
            this[view + 'Variant'] = view === this.calendar.view.type ? 'brand' : 'neutral';
        });
    }

    /**
     * @description nextHandler handles when the user navigates to the next date range in the calendar view. It also publishes the current view state of the calendar
     * so the parent component (vccScheduleAppointmentRequest) is aware of the current view state of the calendar.
     */
    nextHandler() {
        this.calendar.next();
        this.viewChangeHandler();
    }

    /**
     * @description previousHandler handles when the user navigates to the previous date range in the calendar view. It also publishes the current view state of the calendar
     * so the parent component (vccScheduleAppointmentRequest) is aware of the current view state of the calendar.
     */
    previousHandler() {
        this.calendar.prev();
        this.viewChangeHandler();
    }

    /**
     * @description dailyViewHandler handles when the user navigates to the timeGridDay view in the calendar. It also publishes the current view state of the calendar
     * so the parent component (vccScheduleAppointmentRequest) is aware of the current view state of the calendar.
     * @param date - the date object that is stored once an end-user clicks on a navLinkDay Hyperlink. When the Calendar shifts to Day View mode, the selected date will appear on the Calendar.
     *  navLinkDay documentation: https://fullcalendar.io/docs/v5/navLinkDayClick
     */
    dailyViewHandler(date) {
        this.calendar.changeView('timeGridDay', date);
        this.viewChangeHandler();
    }

    /**
     * @description weeklyViewHandler handles when the user navigates to the timeGridWeek view in the calendar. It also publishes the current view state of the calendar
     * so the parent component (vccScheduleAppointmentRequest) is aware of the current view state of the calendar.
     */
    weeklyViewHandler() {
        this.calendar.changeView('timeGridWeek');
        this.viewChangeHandler();
    }

    /**
     * @description monthlyViewHandler handles when the user navigates to the dayGridMonth view in the calendar. It also publishes the current view state of the calendar
     * so the parent component (vccScheduleAppointmentRequest) is aware of the current view state of the calendar.
     */
    monthlyViewHandler() {
        this.calendar.changeView('dayGridMonth');
        this.viewChangeHandler();
    }

    /**
     * @description today handles when the user navigates to today's date in the calendar with the Today button. It also publishes the current view state of the calendar
     * so the parent component (vccScheduleAppointmentRequest) is aware of the current view state of the calendar.
     */
    today() {
        this.calendar.today();
        this.viewChangeHandler();
    }

    /**
     * @description When the date range changes, this will publish an event about the view state of the calendar that will be received by the parent component to determine whether to retrieve more events. It also will
     * save the view type into the calendar options property to allow the calendar to remember its current state if rerendered.
     */
    publishDateRangeChange() {
        let event = new CustomEvent('daterangechange', {
            detail: {
                newStart: this.calendar.view.activeStart,
                newEnd: this.calendar.view.activeEnd,
                currentDate: this.calendar.getDate(),
                currentView: this.calendar.view.type
            }
        });
        this.dispatchEvent(event);
    }

    /**
     * @description Handles the selection of a TimeSlot by the user
     * @param {*} event Representative of the TimeSlot that was selected
     */
    handleEventClick(event) {
        let timeSlotInfo = event.detail;
        //use extendedProps to identify more info about the event
        let timeSlot = {
            start: timeSlotInfo.event?.start,
            end: timeSlotInfo.event?.end,
            salesforceId: timeSlotInfo.event?.extendedProps?.salesforceId,
            available: timeSlotInfo.event?.extendedProps?.available,
            numberOverbooked: timeSlotInfo.event?.extendedProps?.numberOverbooked,
            id: timeSlotInfo.event?.id
        };
        //Check if the Clinic has met its overbooking limit for the day of the TimeSlot that was selected. If the
        //clinic has met its overbooking limit for that day and the timeSlot no availability left, post error and return.
        if (this.clinicOverbookingLimit) {
            if (this.checkOverbookingLimit(timeSlot) && timeSlot?.available <= 0) {
                this.postError(
                    'Reached Overbooking Limit for ' + DATEFORMAT3.format(new Date(timeSlot.start)) + ' Unavailable'
                );
                return;
            }
        }
        //Check if the Time Slot the user clicked has the cardBorder. If not, proceed to select.
        if (!timeSlotInfo.el.classList.contains('cardBorder')) {
            //if this.selectedTimeSlots is empty, then just add the TimeSlot
            if (!this.selectedTimeSlots.length) {
                this.selectTimeSlot(timeSlotInfo, timeSlot);
                //if this.selectedTimeSlots is not empty, then we need to check for concurrency, and the variable length appointment indicator
            } else if (this.isVariableLengthAppointment === true) {
                this.checkTimeSlotsConcurrent(timeSlotInfo, timeSlot);
                //if variable length indicator is false, deselect the currently selected time slot, and select the new one
            } else if (this.isVariableLengthAppointment === false) {
                this.switchSelectedTimeSlots(timeSlotInfo, timeSlot);
            }
        } else {
            //check if the deselected slot is not in between two already selected slots
            if (this.selectedTimeSlots.length > 2) {
                if (this.checkDeselectValid(timeSlot)) {
                    this.deselectTimeSlot(timeSlotInfo, timeSlot);
                }
            } else {
                //deselect the TimeSlot, because the user clicked a Time Slot that is already selected
                this.deselectTimeSlot(timeSlotInfo, timeSlot);
            }
        }
        this.publishTimeSlots();
    }

    /**
     * @description This method determines whether the day of the selected Time Slot has reached the Clinic's max overbook limit
     * @param {Object} timeSlot The Time Slot to check against the Clinic's Max Overbook limit
     * @returns {Boolean} True or false determination of whether the day of selected Time Slot has reached max overbook
     */
    checkOverbookingLimit(timeSlot) {
        var overbooksOnDay = 0;
        let dateToCheck = new Date(timeSlot?.start).toDateString();
        this.formattedTimeSlots
            .filter((slot) => new Date(slot.start).toDateString() === dateToCheck)
            .forEach((slot) => {
                overbooksOnDay += slot?.numberOverbooked;
            });
        return overbooksOnDay >= this.clinicOverbookingLimit;
    }

    /**
     * @descrption switchSelectedTimeSlots is called when the user clicks on a different day than the time slot that is currently selected. This will deselect any currently selected time slots and
     * select the time slot that is on the different day.
     * @param {*} timeSlotInfo Used to access the element that represents the event that was selected
     * @param {*} timeSlot The object that represents the time slot information (start, end, etc.)
     */
    switchSelectedTimeSlots(timeSlotInfo, timeSlot) {
        this.selectedTimeSlots = [];
        this.selectedTimeSlotElements.map((element) => element.classList.remove('cardBorder'));
        this.selectedTimeSlotElements = [];
        this.selectedTimeSlotElements.push(timeSlotInfo.el);
        this.selectedTimeSlotElements.map((element) => element.classList.add('cardBorder'));
        this.selectedTimeSlots.push(timeSlot);
    }

    /**
     * @description selectTimeSlot selects the time slot that the user clicked
     * @param {*} timeSlotInfo Used to access the element that represents the event that was selected
     * @param {*} timeSlot The object that represents the time slot information (start, end, etc.)
     */
    selectTimeSlot(timeSlotInfo, timeSlot) {
        this.selectedTimeSlotElements.push(timeSlotInfo.el);
        timeSlotInfo.el.classList.add('cardBorder');
        this.selectedTimeSlots.push(timeSlot);
        //508 compliance!
        timeSlotInfo.el.setAttribute('aria-label', 'Selected ' + this.formatTimeSlot508(timeSlot));
    }

    /**
     * @description deSelectTimeSlot deselects the time slot that the user clicked
     * @param {*} timeSlotInfo Used to access the element that represents the event that was selected
     * @param {*} timeSlot The object that represents the time slot information (start, end, etc.)
     */
    deselectTimeSlot(timeSlotInfo, timeSlot) {
        this.selectedTimeSlots = this.selectedTimeSlots.filter(function (el) {
            return el.id !== timeSlot.id;
        });
        timeSlotInfo.el.classList.remove('cardBorder');
        //508 compliance!
        timeSlotInfo.el.setAttribute('aria-label', 'Deselected ' + this.formatTimeSlot508(timeSlot));
    }

    /**
     * @description formatTimeSlot508 returns the time slot in a human readable format
     * @param {*} timeSlot The time slot that the user clicked
     * @returns A string representing the time slot in a readable format
     */
    formatTimeSlot508(timeSlot) {
        const formatStart = new Intl.DateTimeFormat('en-US', DATE_OPTIONS1);
        const formatEnd = new Intl.DateTimeFormat('en-US', DATE_OPTIONS2);
        let timeSlotStart = formatStart.format(new Date(timeSlot.start));
        let timeSlotEnd = formatEnd.format(new Date(timeSlot.end));
        let timeSlotFormatted = timeSlotStart + ' to ' + timeSlotEnd;
        return timeSlotFormatted;
    }

    /**
     * @description If variable length appointments are accepted on the clinic, and the user selects more than one timeslot, this will check that the new time slot is concurrent with the old time slot. (ie. sequential)
     * It will also check if the user's new time slot is on a different day. If it is, it will call switchSelectedTimeSlots to switch to the new day. If the time slots are on the same day, but not concurrent, it will
     * post and error toast to notify the user. If the time slots are concurrent, it will select the timeslot.
     * @param {*} timeSlotInfo Used to access the element that represents the event that was selected
     * @param {*} timeSlot The object that represents the time slot information (start, end, etc.)
     */
    checkTimeSlotsConcurrent(timeSlotInfo, timeSlot) {
        let sortedTimeSlots = this.sortTimeSlotsByDateTime(this.selectedTimeSlots);
        let lastTimeSlotSelectedEndDate = new Date(sortedTimeSlots[sortedTimeSlots.length - 1].end);
        let firstTimeSlotSelectedStartDate = new Date(sortedTimeSlots[0].start);
        let newTimeSlotEndDate = new Date(timeSlot.end);
        let newTimeSlotStartDate = new Date(timeSlot.start);
        if (
            //Time Slots on separate days. Deselect all and select new timeslot.
            lastTimeSlotSelectedEndDate.getDay() !== newTimeSlotEndDate.getDay()
        ) {
            this.switchSelectedTimeSlots(timeSlotInfo, timeSlot);
        } else if (
            lastTimeSlotSelectedEndDate.getTime() !== newTimeSlotStartDate.getTime() &&
            firstTimeSlotSelectedStartDate.getTime() !== newTimeSlotEndDate.getTime()
        ) {
            //Time Slots not concurrent! Throw error.
            this.postError('Time Slots must be concurrent when selecting more than one.');
        } else {
            //Time Slots concurrent!
            this.selectedTimeSlotElements.push(timeSlotInfo.el);
            timeSlotInfo.el.classList.add('cardBorder');
            this.selectedTimeSlots.push(timeSlot);
        }
    }

    /**
     * @description checkDeselectValid determines whether a deselected timeslot is in between two selected timeslots. If it is, this method will return false.
     * @param {*} timeSlot
     * @returns {boolean}
     */
    checkDeselectValid(timeSlot) {
        let sortedTimeSlots = this.sortTimeSlotsByDateTime(this.selectedTimeSlots);
        let slotBefore = sortedTimeSlots.findIndex((slot) => {
            return slot.end.getTime() === timeSlot.start.getTime();
        });
        let slotAfter = sortedTimeSlots.findIndex((slot) => {
            return slot.start.getTime() === timeSlot.end.getTime();
        });
        if (slotBefore !== -1 && slotAfter !== -1) {
            return false;
        }
        return true;
    }

    /**
     *  @description Sorts timeslot objects by start time in descending order
     * @param {*} timeSlots A list of timeslots to sort
     * @returns A sorted array of time slots
     */
    sortTimeSlotsByDateTime(timeSlots) {
        let sortedTimeSlots = timeSlots.toSorted((timeSlotA, timeSlotB) => {
            const aStart = timeSlotA.start;
            const bStart = timeSlotB.start;
            if (aStart < bStart) {
                return -1;
            }
            if (aStart > bStart) {
                return 1;
            }
            return 0;
        });
        return sortedTimeSlots;
    }

    /**
     * @description postError is a helper function that will take in a message variable and publish a toast that contains the message.
     * @param {*} message The message to display in the error
     */
    postError(message) {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error',
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
    }

    /**
     * @description This function publishes the list of selected Time Slots to the parent component when a slot is selected and deselected.
     */
    publishTimeSlots() {
        const timeSlotEvent = new CustomEvent('selected', { detail: this.selectedTimeSlots });
        this.dispatchEvent(timeSlotEvent);
    }
}
