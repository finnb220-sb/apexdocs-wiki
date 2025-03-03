/**
 * @description vccClinicTabs is used to display an array of Clinics in a lightning-tabset. On select, the component will publish an event to its parent to get the clinic details and the clinics timeslots for the calendar.
 * Used for both Provider and Clinic Groups to allow selection of Clinics.
 * @author Booz Allen Hamilton
 * @since 5/1/2024
 */
import { LightningElement, api, track } from 'lwc';

export default class VccClinicTabs extends LightningElement {
    @track clinics = [];
    @api siteId;
    @api state;
    initialRender = true;

    /**
     * @description renderedCallback for vccClinicTabs. Upon initial render, the component will choose the first clinic in the clinics array to set as the active tab.
     */
    renderedCallback() {
        if (this.clinics[0]?.ien) {
            this.template.querySelector('lightning-tabset').activeTabValue = this.clinics[0].ien;
        }
    }

    /**
     * @description Obligatory getter. No functional purpose.
     */
    get formattedClinicsByClinicGroup() {
        return this.clinics;
    }

    /**
     * @description setter for formattedClinicsByClinicGroup. Transforms the list of clinics into a common format to be read by both the iterator in the html and the vccClinicDetails component.
     */
    @api
    set formattedClinicsByClinicGroup(value) {
        if (value) {
            this.clinics = value.map((clinic) => {
                return {
                    name: clinic.name,
                    ien: clinic.ien
                };
            });
        }
    }

    /**
     * @description Obligatory getter. No functional purpose.
     */
    get formattedClinicsByProvider() {
        return this.clinics;
    }

    /**
     * @description setter for formattedClinicsByProvider. Transforms the list of clinics into a common format to be read by both the iterator in the html and the vccClinicDetails component.
     */
    @api
    set formattedClinicsByProvider(value) {
        if (value) {
            this.clinics = value.map((clinic) => {
                return {
                    name: clinic.AssociatedClinicName,
                    ien: clinic.AssociatedClinicIEN
                };
            });
        }
    }

    /**
     * @description handleTimeSlotRetrieval publishes an event to the parent component only if it is not the initial render. The TimeSlot initial load is handled in the parent component when the clinics are retrieved.
     * Subsequent changes of a clinic will call this method to get their TimeSlots.
     * @param {*} event
     */
    handleTimeSlotRetrieval(event) {
        if (this.initialRender && this.clinics[0]?.ien) {
            this.template.querySelector('lightning-tabset').activeTabValue = this.clinics[0].ien;
        }
        if (!this.initialRender) {
            const clinicId = event.target.value;
            const clinicName = event.target.label;
            const clinicEvent = new CustomEvent('clinicselect', {
                detail: {
                    clinicId: clinicId,
                    clinicName: clinicName,
                    state: this.state
                }
            });
            this.dispatchEvent(clinicEvent);
        } else {
            this.initialRender = false;
        }
    }

    /**
     * @description This method passes the Clinic details/info from vccClinicDetails to vccScheduleAppointmentRequest
     * @param {Object} event
     */
    handlePassClinicDetails(event) {
        let clinicInfo = event.detail.clinicDetails;
        this.dispatchEvent(new CustomEvent('clinicdetails', { detail: { clinicDetails: clinicInfo } }));
    }
}
