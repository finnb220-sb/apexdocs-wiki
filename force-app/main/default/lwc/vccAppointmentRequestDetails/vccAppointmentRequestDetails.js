/**
 * @description vccAppointmentRequestDetails holds the details of the Appointment Request for viewing by the User when they are scheduling an appointment. Parent component is vccScheduleAppointmentRequest
 */
import { LightningElement, api } from 'lwc';
export default class VccAppointmentRequestDetails extends LightningElement {
    @api apptRequest;
    activeSections = ['ApptRequest'];
    isRTCOrderType;

    /**
     * @description connectedCallback for vccAppointmentRequestDetails. Checks if the Appointment Request Type is RTC Order to conditionally render the Prerequisites field in the html
     */
    connectedCallback() {
        this.isRTCOrderType = this.apptRequest?.AppointmentRequestType === 'RTC';
    }

    /**
     * @description getter for formatting the Created Date in format MM/DD/YYYY
     */
    get createdDateFormatted() {
        let dateSplit = this.apptRequest?.CreatedDate?.split('-');
        if (Array.isArray(dateSplit) && dateSplit.length === 3) {
            //parseInt removes leading zeroes
            return `${parseInt(dateSplit[1], 10)}/${parseInt(dateSplit[2], 10)}/${dateSplit[0]}`;
        }
        return '';
    }
}
