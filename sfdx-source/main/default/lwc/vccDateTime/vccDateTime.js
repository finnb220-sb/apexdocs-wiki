/**
 * @description The purpose of vccDateTime is to allow dynamic rendering of Date Time values based on a passed in Time and Time Zone. Primarily created for use in the VCCUpcomingAppointmentsChildCard FlexCard, as we needed a way to
 * dynamically render the Start Date Time of the Appointment in the Time Zone of the Clinic in which the Appointment will take place.
 */
import { LightningElement, api } from 'lwc';
import { getTimezoneValue } from 'c/vccVistaTimeZoneHelper';
export default class VccDateTime extends LightningElement {
    @api timezone;
    @api time;

    /**
     * @description getter for the Salesforce Time Zone
     * @returns {string} sfTimeZone - Time Zone that is consumable by lightning-formatted-date-time standard component
     */
    get sfTimeZone() {
        return getTimezoneValue(this.timezone) || 'UTC';
    }
}
