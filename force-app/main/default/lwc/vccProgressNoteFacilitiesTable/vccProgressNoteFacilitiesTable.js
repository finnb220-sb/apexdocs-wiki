import { api, LightningElement, track, wire } from 'lwc';
import retrieveVetInfo from '@salesforce/apex/VCC_OnPatientLoadController.retrieveVetInfo';
import { getRecord } from 'lightning/uiRecordApi';

/*const FIELDS = [
    'Case.AccountId',
];*/

export default class VccProgressNoteFacilitiesTable extends LightningElement {
    @api duplicateIsMocked;
    facilityDataSet = {};
    @api hasDuplicates;
    @api hidecheckboxcolumn;
    mpiData;
    @api mviDuplicates;
    @api set progressNoteAccountId(val) {
        if (val?.length && val.length >= 15) {
            this.doCallout(val);
        }
    }
    get progressNoteAccountId() {
        return this._progressNoteAccountId;
    }
    @api recordId;
    @api selectedFacilityPatientId;
    @api selectedFacilitySiteId;
    @api selectedFacilitySiteName;
    selectedFacilitySiteNameArray = [];
    @api skipInternalValidation;

    //#region deprecated
    //The package ancestory will have to be reset to delete these @api decorated properties
    @api flowCache;
    @api label;
    @api availFacilityLabel;
    @api unavailfacilitylabel;
    //////////////////////////////////////////////////////
    //#endregion

    @wire(getRecord, { recordId: '$recordId', fields: ['Case.AccountId'] })
    wiredCase({ error, data }) {
        if (data) {
            this.doCallout(data.fields.AccountId.value);
        } else if (error) {
            this.hasError = true;
        }
    }
    get accountId() {
        return this.record.fields.AccountId.value;
    }

    @track isLoading = true;
    @track hasError = false;

    connectedCallback() {
        if (
            typeof this.selectedFacilitySiteName == 'string' &&
            this.selectedFacilitySiteName !== '' &&
            Array.isArray(this.selectedFacilitySiteNameArray) &&
            this.selectedFacilitySiteNameArray.length === 0
        ) {
            this.selectedFacilitySiteNameArray.push(this.selectedFacilitySiteName);
        }
    }

    doCallout(recordId) {
        retrieveVetInfo({ recordId: recordId })
            .then((response) => {
                let { vets, vetsV3 } = { ...JSON.parse(JSON.stringify(response)) };
                if (vets) {
                    // no localPid, so throw error?
                    this.hasError = true;
                } else {
                    this.mpiData = vetsV3[0];
                }
                this.isLoading = false;
            })
            .catch((error) => {
                const logger = this.template.querySelector('c-logger');
                logger.error(JSON.stringify(error));
                logger.saveLog();
                this.hasError = true;
                this.isLoading = false;
            });
    }

    /**
     * @justification see 'When not to use it' section of https://github.com/salesforce/eslint-plugin-lwc/blob/v1.7.2/docs/rules/no-api-reassignments.md
     * If the component needs to reflect internal state changes via public property, this rule should not be used. A good example for this is a custom input component reflecting its internal value change to the value public property.
     */
    /* eslint-disable @lwc/lwc/no-api-reassignments */
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
    }

    handleRowSelect(event) {
        this.selectedFacilitySiteName = event.detail.row.facilityName;
        this.selectedFacilitySiteId = event.detail.row.facilityCode;
        this.mviDuplicates = undefined;
        this.checkDuplicates();
        this.selectedFacilityPatientId = event.detail.row.patientLocalPid;
    }
    /* eslint-enable */

    @api
    validate() {
        if (this.skipInternalValidation || (this.selectedFacilityPatientId && this.selectedFacilitySiteId)) {
            return { isValid: true };
        } else if (!this.selectedFacilityPatientId && this.selectedFacilitySiteId) {
            return {
                isValid: false,
                errorMessage: 'An error has occurred with the selected facility, please contact your administrator.'
            };
        }
        return {
            isValid: false,
            errorMessage: 'Please select a facility.'
        };
    }
}
