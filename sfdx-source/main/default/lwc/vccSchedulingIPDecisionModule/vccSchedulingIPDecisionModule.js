/**
 * @description This lwc is designed to listen for mpiData from vccOnPersonAccountRead. On receipt, it will parse out the patients known facilities, then call an Integration Procedure with a custom event
 * containing the facilities data. This lwc is a child component of the OpenAppointmentRequests and UpcomingAppointments Flexcards, and are configured to listen for this event which will call the correct Integration Procedure.
 * @author Booz Allen Hamilton
 */
import { LightningElement, api, wire } from 'lwc';
import { subscribe, unsubscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import vccOnPersonAccountRead from '@salesforce/messageChannel/vccOnPersonAccountRead__c';
import pubsub from 'omnistudio/pubsub';
import { MPISharedState } from 'c/vccMPISharedState';
import schedulingUser from '@salesforce/customPermission/VAHC_Scheduling_User';
export default class VccSchedulingIPDecisionModule extends LightningElement {
    @api schedulingTab;
    patientFacilities;
    calloutComplete;
    //LMS
    subscription = null;
    @wire(MessageContext)
    messageContext;
    mpiData;
    /**
     * @description connectedCallback for vccSchedulingIPDecisionModule. The user permission check ensures that
     * the MPISharedState object will only be called if the state of the user interface ensures it will return data. Non-scheduling
     * users will need to click the Appointments tab to see the data, as well as a scheduling user that has navigated to the
     * Upcoming Appointments tab. We only call this under these two scenarios, as the mpiData from vccOnPersonAccountRead will be updated
     * with the latest by this time. Also subscribes to the lms channel for the mpiData.
     */
    connectedCallback() {
        if (!schedulingUser || (schedulingUser && this.schedulingTab === 'UpcomingAppointments')) {
            this.mpiData = MPISharedState.getData();
            if (this.mpiData) {
                this.handleMPIData();
            }
        }
        this.subscribeToMessageChannel();
    }

    /**
     * @description Used to subscribe to the vccOnPersonAccountRead message channel for getting the mpiData. Waits for the callout to complete from vccOnPersonAccountRead before proceeding with the MPI Data. Logic included to allow the mpiData to pass through
     * if the user is a Scheduling user and they have switched to the Upcoming Appointments tab.
     */
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                vccOnPersonAccountRead,
                (message) => {
                    if (message.mpiData) {
                        this.mpiData = message.mpiData;
                        this.handleMPIData();
                    }
                },
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    /**
     * @description disconnectedCallback for vccSchedulingIPDecisionModule. Used to unsubscribe from the message channel.
     */
    disconnectedCallback() {
        this.mpiData = null;
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    /**
     * handleMPIData takes in the mpiData, and sets the patientFacilities property to a comma-delimited string of the patient's known facilities
     * @param {object} mpiData
     */
    handleMPIData() {
        if (
            this.mpiData.mvi.medicalCenterFacilities !== null &&
            this.mpiData.mvi.medicalCenterFacilities instanceof Array
        ) {
            this.patientFacilities = this.mpiData.mvi.medicalCenterFacilities.map((facility) => {
                let facilityString = facility.facilityId + '|' + facility.facilityName;
                facilityString = facilityString.replace(/,/g, '');
                return facilityString;
            });
            if (this.patientFacilities.length === 1) {
                this.patientFacilities = this.patientFacilities[0] + ',';
            } else {
                this.patientFacilities = this.patientFacilities.join(',');
            }
            this.handleCallIntegrationProcedure();
        }
    }

    /**
     * @description This method is used to decide which Integration Procedure to call based on which tab the user has landed on.
     */
    handleCallIntegrationProcedure() {
        if (this.schedulingTab === 'OpenAppointmentRequests') {
            pubsub.fire('schedulingIPChannel', 'getAppointmentsAndAppointmentRequests', {
                facilities: this.patientFacilities
            });
        } else if (this.schedulingTab === 'UpcomingAppointments') {
            pubsub.fire('schedulingIPChannel', 'getAppointments', { facilities: this.patientFacilities });
        }
        unsubscribe(this.subscription);
        this.subscription = null;
    }
}
