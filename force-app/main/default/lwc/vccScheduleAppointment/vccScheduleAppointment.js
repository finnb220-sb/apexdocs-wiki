/**
 * @description vccScheduleAppointment acts as the confirmation screen, and the success screen when scheduling an appointment. It is responsible for showing the User their Time Slot
 * selections, Clinic, and patient eligibility data, as well as calling the apex method for creating the appointment.
 * @author Booz Allen Hamilton
 * @since 4/25/2024
 */
import { LightningElement, api, wire } from 'lwc';
import { subscribe, unsubscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import vccOnPersonAccountRead from '@salesforce/messageChannel/vccOnPersonAccountRead__c';
import closeApptRequest from '@salesforce/apex/VCC_ScheduleAppointmentController.closeApptRequest';
import createAppointment from '@salesforce/apex/VCC_ScheduleAppointmentController.createAppointment';
import getAppointmentTypes from '@salesforce/apex/VCC_ScheduleAppointmentController.getAppointmentTypes';
import callIntegrationProcedure from '@salesforce/apex/VCC_ScheduleAppointmentController.callIntegrationProcedure';
import runningUserCanScheduleIntoClinic from '@salesforce/apex/VCC_ScheduleAppointmentController.runningUserCanScheduleIntoClinic';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import pubsub from 'omnistudio/pubsub';
import { convertToUTC } from './vccConvertToUTC';
import LoggerMixin from 'c/loggerMixin';

export default class VccScheduleAppointment extends LoggerMixin(LightningElement) {
    //public properties
    @api selectedtimeslots;
    @api apptRequest;
    @api clinicIEN;
    @api clinicName;
    @api clinicTimeZone;
    @api clinicIANATimeZone;
    @api clinicStopCodeNumber;
    @api recordId;
    showSuccessScreen = false;
    //Appointment Properties
    selectedEligibility;
    appointmentComments;
    appointmentTypes;
    selectedAppointmentType;
    appointmentRequestType;
    sortedTimeSlots;
    serviceConnectedEligibilityException = 'SERVICE CONNECTED 50% to 100%';
    //Patient Data
    mpiData;
    //Component properties
    scheduleApptView = true;
    loading = false;
    //LMS
    subscription = null;
    @wire(MessageContext)
    messageContext;
    initialized = false;
    apptId;

    /**
     * @description getter for appointmentParams. It constructs an object used to format the appointmentParams for creating the appointment based on the user's selections.
     */
    get appointmentParams() {
        return {
            eligibilityOfVisit: this.selectedEligibility,
            note: this.appointmentComments,
            apptId: this.apptId,
            apptRequestId: this.apptRequest.Id,
            apptRequestVistaId: this.apptRequest.RequestVistaId,
            apptType: this.selectedAppointmentType,
            start: this.startTime,
            xEnd: this.endTime,
            duration: this.duration,
            patientICN: this.apptRequest.PatientICN,
            patientDFN: this.apptRequest.PatientDFN,
            salesforcePatientId: this.recordId,
            salesforceContactId: this.apptRequest.PersonContactId,
            facilityStationId: this.apptRequest.FacilityStationId,
            facilityStationName: this.apptRequest.FacilityName,
            clinicIEN: this.clinicIEN,
            clinicName: this.clinicName,
            //clinicStopCodeName: ,
            clinicStopCodeNumber: this.clinicStopCodeNumber,
            providerIEN: this.apptRequest.ProviderIEN,
            providerName: this.apptRequest.ProviderName,
            timeZone: this.clinicTimeZone,
            slotsToUpdate: this.slotsToUpdate
        };
    }

    /**
     * @description getter for benefitEligibilityOptions. This is used to retrieve the options from the mpiData that the user will be able to select in a picklist format.
     */
    get benefitEligibilityOptions() {
        let options = [];
        options.push({
            label: this.mpiData?.ee?.eeExtendedResponse?.enrollmentDetermination?.primaryEligibility?.type,
            value: this.mpiData?.ee?.eeExtendedResponse?.enrollmentDetermination?.primaryEligibility?.type
        });
        this.mpiData.ee?.eeExtendedResponse?.enrollmentDetermination?.secondaryEligibilities?.map((eligibility) =>
            options.push({ label: eligibility.type, value: eligibility.type })
        );
        this.mpiData.ee?.eeExtendedResponse?.enrollmentDetermination?.otherEligibilities?.map((eligibility) =>
            options.push({ label: eligibility.type, value: eligibility.type })
        );

        return options;
    }

    /**
     * @description The start time of the earliest Time Slot selected
     */
    get startTime() {
        //Set to start time of earliest timeslot selected.
        //sortedTimeSlots will always have a timeslot since a timeslot selection is necessary to enter vccScheduleAppointment
        let firstTimeslot = this.sortedTimeSlots[0]?.start.toISOString().replace('Z', '');
        let startTimeUTC = convertToUTC(firstTimeslot, this.clinicIANATimeZone);
        return startTimeUTC;
    }

    /**
     * @description The end time of the latest Time Slot selected
     */
    get endTime() {
        //sortedTimeSlots will always have a timeslot since a timeslot selection is necessary to enter vccScheduleAppointment
        let lastTimeslot = this.sortedTimeSlots[this.sortedTimeSlots.length - 1]?.end.toISOString().replace('Z', '');
        let endTimeUTC = convertToUTC(lastTimeslot, this.clinicIANATimeZone);
        return endTimeUTC;
    }

    /**
     * @description Calculates the duration of the appointment in minutes
     */
    get duration() {
        let diff = Math.abs(this.endTime - this.startTime);
        let minutes = Math.floor(diff / 1000 / 60);
        return minutes;
    }

    /**
     * @description Formats the duration property for display in the html
     */
    get durationMinutes() {
        return this.duration + ' minutes';
    }

    /**
     * @description Creates an array of objects representing the Mock VCC_Clinic_Schedule_Slot__c record(s) selected by the user. This property is used to reserve the mock Time Slots in Salesforce.
     */
    get slotsToUpdate() {
        let slotArray = [];
        this.selectedtimeslots.map((slot) =>
            slotArray.push({ salesforceId: slot.salesforceId, available: slot.available })
        );
        return slotArray;
    }

    /**
     * @description This is used to supply valid values for the appointment type field. Picklist format.
     */
    setAppointmentTypeOptions() {
        this.getAppointmentTypeOptions();
        //Pre-select the Appointment Type that was used in the Appointment Request after the values have loaded.
        this.selectedAppointmentType = this.apptRequest?.AppointmentType;
    }

    async getAppointmentTypeOptions() {
        this.loading = true;
        try {
            let result = await getAppointmentTypes({
                appointmentRequestType: this.appointmentRequestType,
                vistaSiteId: this.apptRequest.FacilityStationId
            });
            if (result) {
                this.appointmentTypes = result;
                if (!this.appointmentTypes.length) {
                    this.postError('No Appointment Types found for this facility.');
                }
            }
        } catch (error) {
            this.postError('Appointment Types failed to load.');
            const logger = this.template.querySelector('c-logger');
            if (error instanceof Error) {
                logger.error(error.message);
                logger.error(error.stack);
            } else {
                logger.error(JSON.stringify(error));
            }
            logger.saveLog();
        } finally {
            this.loading = false;
        }
    }

    /**
     * @description This function contains the logic needed to decide which set of options and labels are needed for displaying Appointment Types.
     * Returns true if the Appointment Request Type is APPT or RTC. If the Appointment Request Type is not APPT or RTC, it will return false.
     * @returns Boolean
     */
    checkAppointmentRequestType() {
        if (this.appointmentRequestType === 'APPT' || this.appointmentRequestType === 'RTC') {
            return true;
        }
        return false;
    }

    /**
     * @description getter for the label used for the appointment type field.
     */
    get appointmentTypeLabel() {
        if (this.checkAppointmentRequestType()) {
            return 'Appointment Type';
        }

        return 'PtCSch Appointment Type';
    }

    /**
     * @description getter for the error message displayed when the appointment type field is not populated.
     */
    get appointmentTypeErrorMessage() {
        if (this.checkAppointmentRequestType()) {
            return 'Select an appointment type before continuing.';
        }

        return 'Select a PtCSch appointment type before continuing.';
    }

    /**
     * @description connectedCallback for vccScheduleAppointment. It subscribes to the vccOnPersonAccountRead message channel, sets initial properties to display in the html,
     * and sorts the timeslots by date time
     *
     */
    connectedCallback() {
        this.subscribeToMessageChannel();
        this.appointmentComments = this.apptRequest.Comments;
        this.appointmentRequestType = this.apptRequest.AppointmentRequestType;
        this.setAppointmentTypeOptions();
        this.sortTimeSlotsByDateTime(this.selectedtimeslots);
    }

    /**
     * @description renderedCallback for vccScheduleAppointment. Used to get the MPI data from the vccOnPersonAccountRead component by calling this.getMPI.
     */
    renderedCallback() {
        if (!this.initialized) {
            this.getMPI();
            this.initialized = true;
        }
    }

    /**
     * @description Used to get the MPI data through the publishMessage funcation on vccLMSPublisher.
     */
    getMPI() {
        const publisher = this.template.querySelector('c-vcc-l-m-s-publisher');
        const message = { callingFor: 'mpiData' };
        publisher.publishMessage('vccOnPersonAccountRead', message);
    }

    /**
     * @description disconnectedCallback for vccScheduleAppointment. Used to unsubscribe from the message channel.
     */
    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
        if (this.showSuccessScreen) {
            this.closeApptRequest();
        }
    }

    /**
     * @description Used to subscribe to the vccOnPersonAccountRead message channel for getting the mpiData.
     */
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                vccOnPersonAccountRead,
                (message) => {
                    if (message.mpiData) {
                        this.mpiData = message.mpiData;
                    }
                },
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    /**
     * @description Sorts the Time Slots based on start date descending.
     */
    sortTimeSlotsByDateTime(timeSlots) {
        this.sortedTimeSlots = timeSlots.toSorted((timeSlotA, timeSlotB) => {
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
    }

    /**
     * @description Change handler for Benefit/Eligibility
     */
    handleBenefitEligibilityChange(event) {
        if (event && event.detail.value) {
            this.selectedEligibility = event.detail.value;
            if (this.selectedEligibility !== this.serviceConnectedEligibilityException) {
                this.selectedEligibility = this.selectedEligibility.toUpperCase();
            }
            this.template.querySelector('[data-id="eligibilityError"]').classList.add('slds-hidden');
            this.template.querySelector('[data-id="eligibility"]').classList.remove('slds-has-error');
        }
    }

    /**
     * @description Change handler for Appointment Comments
     */
    handleAppointmentCommentsChange(event) {
        this.appointmentComments = event.detail.value;
        if (this.appointmentComments.length === 80) {
            this.template.querySelector('[data-id="commentsError"]').classList.remove('slds-hidden');
        } else {
            this.template.querySelector('[data-id="commentsError"]').classList.add('slds-hidden');
        }
    }

    /**
     * @description Change handler for Appointment Type
     */
    handleAppointmentTypeChange(event) {
        this.selectedAppointmentType = event.detail.value;
        this.template.querySelector('[data-id="appointmentTypeError"]').classList.add('slds-hidden');
        this.template.querySelector('[data-id="appointmentType"]').classList.remove('slds-has-error');
    }

    /**
     * @description Used to call the Apex Method createAppointment on VCC_ScheduleAppointmentRequestController. Also, checks that required fields are filled before continuing.
     */
    handleScheduleAppointment() {
        const eligibilityValue = this.template.querySelector('[data-id="eligibility"]').value;
        const appointmentTypeValue = this.template.querySelector('[data-id="appointmentType"]').value;
        if (eligibilityValue && appointmentTypeValue) {
            this.createAppointment();
        } else {
            if (!eligibilityValue) {
                this.template.querySelector('[data-id="eligibilityError"]').classList.remove('slds-hidden');
                this.template.querySelector('[data-id="eligibility"]').classList.add('slds-has-error');
            }

            if (!appointmentTypeValue) {
                this.template.querySelector('[data-id="appointmentTypeError"]').classList.remove('slds-hidden');
                this.template.querySelector('[data-id="appointmentType"]').classList.add('slds-has-error');
            }
        }
    }

    /**
     * @description Handler for navigating back to the calendar view.
     */
    handleBackToCalendar() {
        let backEvent = new CustomEvent('backtocalendar');
        this.dispatchEvent(backEvent);
    }

    /**
     * @description createAppointment makes the call to the Apex controller to create the Appointment based on the appointmentParams
     **/
    async createAppointment() {
        try {
            this.loading = true;
            if (
                !(await runningUserCanScheduleIntoClinic({
                    clinicIen: this.clinicIEN,
                    vistaSiteId: this.appointmentParams.facilityStationId
                }))
            ) {
                this.postError("You must have permission to schedule into this clinic's grid.");
                return;
            }
            this.apptId = await createAppointment({
                params: JSON.stringify(this.appointmentParams)
            });
            if (typeof this.apptId === 'string' && this.apptId.length > 0) {
                this.showSuccessScreen = true;
                this.callIntegrationProcedure();
            }
        } catch (error) {
            let errorMessage = JSON.stringify(error.body.message);
            if (errorMessage.includes('Code not Found')) {
                errorMessage = `The Eligibility Code: ${this.selectedEligibility} was not Accepted. Please choose a different Eligibility`;
            } else {
                //Extracts the value of the "message" field
                //If the "message" field is found it is stored in index 1, the extracted value replaces the original errorMessage. Otherwise, errorMessage is set to a general error.
                const match = errorMessage.match(/\\"message\\":\\"(.*?)\\"/);
                errorMessage = match && match.length > 1 ? match[1] : 'Appointment failed to schedule';
            }

            this.postError(`Error: ${errorMessage}`);
            this.showSuccessScreen = false;
            if (error instanceof Error) {
                this.Logger.error(error?.body?.message);
                this.Logger.error(error.stack);
            } else {
                this.Logger.error(JSON.stringify(error));
            }
            this.Logger.saveLog();
        } finally {
            this.loading = false;
        }
    }
    /**
     * @description closeApptRequest makes the call to the Apex controller to set the status of the associated Appointment Request to Closed
     * As well as sends a pubsub message to the VCC_UpcomingAppointmentRequestCard flex card to refresh its flexcard list.
     **/
    closeApptRequest() {
        try {
            closeApptRequest({
                params: JSON.stringify(this.appointmentParams)
            });
            pubsub.fire('omniscript_action', 'data');
        } catch (error) {
            this.postError('Appointment Request failed to Update status to closed.');
            const logger = this.template.querySelector('c-logger');
            if (error instanceof Error) {
                logger.error(error.message);
                logger.error(error.stack);
            } else {
                logger.error(JSON.stringify(error));
            }
            logger.saveLog();
        }
    }

    /**
     * @description Calls the getCreateCase Integration Procedure that is responsible for updating or creating a case associated with this Scheduling Action.
     */
    callIntegrationProcedure() {
        try {
            callIntegrationProcedure({
                params: this.appointmentParams
            });
        } catch (error) {
            this.postError('The associated Case failed to create/update.');
            const logger = this.template.querySelector('c-logger');
            if (error instanceof Error) {
                logger.error(error.message);
                logger.error(error.stack);
            } else {
                logger.error(JSON.stringify(error));
            }
            logger.saveLog();
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
            variant: 'error',
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
    }

    /**
     * @description Handler for closing the OmniStudio flexcard modal.
     */
    handleCloseModal() {
        this.dispatchEvent(new CustomEvent('close_modal', { bubbles: true, composed: true }));
    }
}
