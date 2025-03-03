import { api, LightningElement } from 'lwc';
export default class VccMPITabset extends LightningElement {
    @api
    mpiData;
    @api
    vccRecordId;
    @api
    pendingMeds;

    esr;
    mvi;

    isLoading = true;
    hasError = false;
    error;

    vaProfileContactInfo;
    vaProfileAssociatedPersons;
    vaProfile;

    initialized = false;
    renderedCallback() {
        if (this.initialized === true) {
            return;
        }
        if (typeof this.mpiData !== 'object' || this.mpiData === null) {
            return;
        }

        this.initialized = true;

        this.esr = this.mpiData.ee;
        this.mvi = this.mpiData.mvi;
        this.vaProfile = this.mpiData.vaProfileV2;
        this.vaProfileContactInfo = this.vaProfile?.vaProfileContactInfo;
        this.vaProfileAssociatedPersons = this.vaProfile?.vaProfileAssociatedPersons;

        this.isLoading = false;
    }
}
