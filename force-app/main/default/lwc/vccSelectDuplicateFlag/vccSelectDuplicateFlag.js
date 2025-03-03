import { LightningElement, track, api } from 'lwc';
import retrieveVetInfo from '@salesforce/apex/VCC_OnPatientLoadController.retrieveVetInfo';

export default class VccSelectDuplicateFlag extends LightningElement {
    @track hasDuplicates = true;
    @api recordId;

    mpiData;

    @track isLoading = true;
    @track hasError = false;

    connectedCallback() {
        this.doCallout(this.recordId);
    }

    doCallout(recordId) {
        console.log('Callout Activated');
        retrieveVetInfo({ recordId: recordId })
            .then((response) => {
                let { vets, vetsV3 } = { ...JSON.parse(JSON.stringify(response)) };
                if (vets) {
                    // no localPid, so throw error?
                    this.hasError = true;
                } else {
                    this.mpiData = vetsV3[0];
                    console.log('MPI Data Flags:', this.mpiData);
                }
                this.isLoading = false;
            })
            .catch((error) => {
                console.log(error);
                this.hasError = true;
                this.isLoading = false;
            });
    }
}
