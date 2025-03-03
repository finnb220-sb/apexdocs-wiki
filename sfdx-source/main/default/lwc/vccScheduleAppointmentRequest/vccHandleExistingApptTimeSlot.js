/**
 * @description function that handles Date formatting for Selected Time Slot and Existing Appt found on same day of Time Slot
 * Formats Dates to MM/DD/YY Format and builds message to be utilized in Toast Notification
 */
import { getTimezoneValue } from 'c/vccVistaTimeZoneHelper';
export function existingApptFound(selectedTimeslots, existingAppointments) {
    const selectedTimeSlotsDate = selectedTimeslots[0].start.toISOString().slice(0, 10);
    let matchingDatesFound = [];

    matchingDatesFound = existingAppointments.filter((existingAppointment) => {
        const appointmentDateStr = existingAppointment.VCC_Appointment_Start__c.slice(0, 10);
        return appointmentDateStr === selectedTimeSlotsDate;
    });
    const options = {
        month: '2-digit',
        day: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        timeZoneName: 'short'
    };
    let formattedselectedTimeslots = selectedTimeslots[0].start.toLocaleDateString('en-US', {
        month: '2-digit',
        day: '2-digit',
        year: 'numeric'
    });
    let toastMessage = '';
    if (matchingDatesFound.length > 0) {
        matchingDatesFound.forEach((appointment, index) => {
            const startDate = new Date(appointment.VCC_Appointment_Start__c);
            const endDate = new Date(appointment.VCC_Appointment_End__c);
            let timezoneValue;
            timezoneValue = getTimezoneValue(appointment.VCC_Time_Zone__c) || 'UTC';
            options.timeZone = timezoneValue;

            const formattedStartDate = startDate.toLocaleString('en-US', options);
            const formattedEndDate = endDate.toLocaleString('en-US', options);
            const lineBreak = index < matchingDatesFound.length - 1 ? '\n' : '';
            toastMessage += `\n ${appointment.VCC_Clinic_Name__c}: ${formattedStartDate} to ${formattedEndDate}. Duration: ${appointment.VCC_Duration__c}${lineBreak}`;
        });
    }
    return {
        formattedselectedTimeslots,
        toastMessage
    };
}
