/**
 * @author Booz Allen Hamilton
 * @date 03/27/2024
 * @description Component utilized for grabbing the MPI Data From the vccMPITabSet LWC to display
 * Primary Eligibility and Enrollment information within Omnistudio's Flexcards and Omniscript
 */
import { LightningElement, api, track, wire } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';
import vccOnPersonAccountRead from '@salesforce/messageChannel/vccOnPersonAccountRead__c';
import { subscribe, unsubscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';

export default class VccEnrollmentAndPrimaryEligibility extends OmniscriptBaseMixin(LightningElement) {
    @api flexcard;
    @api record;
    componentVisible = false;
    @api scheduleApptView = false;
    isLoading = true;
    //Patient Data
    mpiData;
    //LMS
    subscription = null;
    @wire(MessageContext)
    messageContext;
    initialized = false;
    @track enrollmentAndEligibilityInfo;

    /**
     * @description Subcribes to message channel to receive enrollment and Eligibility data from vccOnPersonAccountRead.
     * If Component is on a flex card or nested in a LWC, the component will be visible.
     */
    connectedCallback() {
        this.subscribeToMessageChannel();
        if (this.flexcard === 'flexcard' || this.scheduleApptView) {
            this.componentVisible = true;
        }
    }
    /**
     * @description Subcribes to message channel to receive enrollment and Eligibility data from vccOnPersonAccountRead.
     */
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                vccOnPersonAccountRead,
                (message) => {
                    if (message.mpiData) {
                        this.mpiData = message.mpiData;
                        this.handleEnrollmentAndEligibilityInfo();
                    }
                },
                { scope: APPLICATION_SCOPE }
            );
        }
    }
    /**
     * @description Upon render, component will request data from LMS Channel for MPI Data
     */
    renderedCallback() {
        this.handleMPIData();
    }
    /**
     * @description Publishes message to LMS to receive MPI Data.
     */
    getMPI() {
        const publisher = this.template.querySelector('c-vcc-l-m-s-publisher');
        const message = { callingFor: 'mpiData' };
        publisher.publishMessage('vccOnPersonAccountRead', message);
    }
    /**
     * @description unsubscribes to LMS
     */
    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    /**
     * @description if component was not previously initialized and doesn't have MPI Data, it will request MPI Data through LMS.
     */
    handleMPIData() {
        if (!this.initialized) {
            if (!this.mpiData) {
                this.getMPI();
            }
            this.isLoading = false;
            this.initialized = true;
        }
    }
    /**
     * @description handles MPI data and sets the values to enrollmentAndEligibilityInfo.
     * If componentVisible is false, then component is on an Omniscript and will send enrollmentAndEligibilityInfo to Omniscript.
     */
    handleEnrollmentAndEligibilityInfo() {
        this.enrollmentAndEligibilityInfo = {
            enrollment: this.mpiData.ee?.eeExtendedResponse?.enrollmentDetermination?.enrollmentStatus || '',
            eligibility: this.mpiData.ee?.eeExtendedResponse?.enrollmentDetermination?.primaryEligibility.type || ''
        };
        if (!this.componentVisible) {
            this.omniApplyCallResp(this.enrollmentAndEligibilityInfo);
        }
    }
    /**
     * @description handles formatting for enrollment data and changes formatting if component is on a Omnistudio Flexcard, or parent LWC
     */
    get enrollmentDivStyling() {
        let baseClasses = 'slds-col slds-size_1-of-2';
        return !this.scheduleApptView ? `${baseClasses} slds-p-left_x-small` : baseClasses;
    }
}
