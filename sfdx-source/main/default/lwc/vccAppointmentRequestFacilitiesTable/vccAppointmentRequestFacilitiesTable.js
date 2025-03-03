/**
 * @description vccAppointmentRequestFacilitiesTable loads mpiData for the patient by publishing to the vccOnPersonAccountRead LMS channel, then passes the mpiData to the vccPreferredFaciliies lwc so the user can select
 * an available facility. Upon selection, and event is published to the vccAppointmentRequestFacilities which is listened to by the vccClinicLookupOmni lwc. That component uses the selected siteId to search related Clinics.
 * @author Booz Allen Hamilton
 * @since 4/25/2024
 */
import { api, LightningElement, track, wire } from 'lwc';
import { subscribe, unsubscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';
import vccOnPersonAccountRead from '@salesforce/messageChannel/vccOnPersonAccountRead__c';

export default class VccAppointmentRequestFacilitiesTable extends OmniscriptBaseMixin(LightningElement) {
    //omni properties must be all lowercase. These are used to cache data in the user's OmniScript session to reuse if the user navigates back and forth from step to step
    @api accountid;
    @api omnimpidata;
    @api selectedfacilityname;
    @api selectedfacilityid;
    ///////////////////////////////////////
    selectedFacilityPatientId;
    selectedFacilitySiteId;
    selectedFacilitySiteName = [];
    hasDuplicates;
    mviDuplicates;
    @track mpiData;
    @track isLoading = false;
    @track hasError = false;
    //LMS
    subscription = null;
    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    /**
     * @description renderedCallback for vccAppointmentRequestFacilitiesTable. Used to get the MPI data from the vccOnPersonAccountRead component by calling this.getMPI.
     */
    renderedCallback() {
        if (!this.initialized) {
            if (this.omnimpidata) {
                this.mpiData = this.omnimpidata;
                this.selectedFacilitySiteName.push(this.selectedfacilityname);
            } else {
                this.loading = true;
                this.getMPI();
            }
        }
        this.initialized = true;
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
     * @description disconnectedCallback for vccAppointmentRequestFacilitiesTable. Used to unsubscribe from the message channel.
     */
    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
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
                        this.loading = false;
                    }
                },
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    /* Not needed yet, but may be necessary if we run into duplicate patient problems like the Sign Progress Note flow did.
    checkDuplicates() {
        let filteredMPI = this.mpiData.mvi.medicalCenterFacilities.filter(
            (facility) => facility.facilityId === this.selectedFacilitySiteId
        );
        if (filteredMPI.length > 1) {
            this.hasDuplicates = true;
            this.mviDuplicates = JSON.stringify(filteredMPI);
        }
        //Matt Z.- CCCM-11511 Adding an else statement to account for Users switching from one facility to another
        else {
            this.hasDuplicates = false;
        }
    }*/

    handleRowSelect(event) {
        this.selectedFacilitySiteName = [event.detail.row.facilityName];
        this.selectedFacilitySiteId = event.detail.row.facilityCode;
        this.mviDuplicates = undefined;
        this.selectedFacilityPatientId = event.detail.row.patientLocalPid;

        //pass selectedrow back to OmniScript property
        let omniData = {
            selectedFacilityName: this.selectedFacilitySiteName[0],
            selectedFacilityId: this.selectedFacilitySiteId,
            selectedFacilityNamePlusId: this.selectedFacilitySiteName[0] + ' - ' + this.selectedFacilitySiteId,
            patientDFN: this.selectedFacilityPatientId
        };
        if (!this.omnimpidata) {
            omniData.mpiData = this.mpiData;
        }
        this.omniApplyCallResp(omniData);
        const publisher = this.template.querySelector('c-vcc-l-m-s-publisher');
        const message = { facilityId: this.selectedFacilitySiteId };
        publisher.publishMessage('vccAppointmentRequestFacilities', message);
    }
}
