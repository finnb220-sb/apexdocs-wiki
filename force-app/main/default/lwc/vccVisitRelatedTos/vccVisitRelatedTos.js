/**
 * @description This LWC displays the service connected percentage, rated disabilities, and picklist fields for service connected conditions.
 * @author Booz Allen Hamilton
 */
import { api, LightningElement, track, wire } from 'lwc';
import PROGRESS_NOTE_OBJECT from '@salesforce/schema/VCC_Progress_Note__c';
import MST from '@salesforce/schema/VCC_Progress_Note__c.VCC_Military_Sexual_Trauma__c';
import CV from '@salesforce/schema/VCC_Progress_Note__c.VCC_Combat_Veteran__c';
import AO from '@salesforce/schema/VCC_Progress_Note__c.VCC_Agent_Orange_Exposure__c';
import IR from '@salesforce/schema/VCC_Progress_Note__c.VCC_Ionizing_Radiation_Exposure__c';
import EC from '@salesforce/schema/VCC_Progress_Note__c.VCC_Southwest_Asia_Conditions__c';
import SHD from '@salesforce/schema/VCC_Progress_Note__c.VCC_Shipboard_Hazard_Defense__c';
import SC from '@salesforce/schema/VCC_Progress_Note__c.VCC_Service_Connected_Condition__c';
import HNC from '@salesforce/schema/VCC_Progress_Note__c.VCC_Head_and_or_Neck_Cancer__c';
import retrieveVetInfo from '@salesforce/apex/VCC_OnPatientLoadController.retrieveVetInfo';
import { getRecord } from 'lightning/uiRecordApi';
import ACCOUNTID from '@salesforce/schema/VCC_Progress_Note__c.VCC_Case__r.AccountId';

const visitRelatedToMap = {
    serviceConnected: SC,
    combatVeteran: CV,
    agentorangeExposure: AO,
    ionizingradiationExposure: IR,
    // "southwestasiaConditions": EC,
    shipboardhazardandDefence: SHD,
    mst: MST,
    headandneckCancer: HNC,
    persiangulfExposure: EC
};

const fieldToVistaOutputMap = {
    VCC_Military_Sexual_Trauma__c: 'MST',
    VCC_Combat_Veteran__c: 'CV',
    VCC_Agent_Orange_Exposure__c: 'AO',
    VCC_Ionizing_Radiation_Exposure__c: 'IR',
    VCC_Southwest_Asia_Conditions__c: 'EC',
    VCC_Shipboard_Hazard_Defense__c: 'SHD',
    VCC_Service_Connected_Condition__c: 'SC',
    VCC_Head_and_or_Neck_Cancer__c: 'HNC'
    // 'VCC_Persian_Gulf_Exposure__c' : 'EC' //unsure about this one
};

export default class VccVisitRelatedTos extends LightningElement {
    /** Properties */
    objectApiName = PROGRESS_NOTE_OBJECT;
    visitRelatedToMap = visitRelatedToMap;
    fieldToVistaOutputMap = fieldToVistaOutputMap;
    isLoading = true;
    hasError = false;
    fields = [];
    recordTypeId;

    @api get relatedToOutput() {
        return this._relatedToOutput;
    }
    _relatedToOutput = '';

    @track
    mpiData;

    serviceConnected;
    ratedDisabilities = [];
    accountIdValue;

    /** Properties with getters/setters */
    @api set visitRelatedTos(val) {
        if (val && typeof val == 'string') {
            let attemptedJSON = JSON.parse(val);
            val = attemptedJSON;
        }
        if (val && typeof val == 'object' && !Array.isArray(val)) {
            this._visitRelatedTos = val;
            this.processVisitRelatedTos();
        }
    }
    get visitRelatedTos() {
        return this._visitRelatedTos;
    }

    @api set recordId(val) {
        if (val && typeof val == 'string' && val.length >= 15 && val.length <= 18) {
            this._recordId = val;
            this.processVisitRelatedTos();
        }
    }
    get recordId() {
        return this._recordId;
    }

    @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNTID] })
    wiredAccount({ error, data }) {
        if (data) {
            this.accountIdValue = data.fields.VCC_Case__r.value.fields.AccountId.value;
            this.mpiCallout();
            this.hasError = undefined;
        } else if (error) {
            this.hasError = error;
            this.accountIdValue = undefined;
        }
    }

    renderedCallback() {
        var elements = this.template.querySelectorAll('lightning-input-field');
        for (let i = 0; i < elements.length; i++) {
            if (elements[i].fieldName === 'VCC_Combat_Veteran__c' && elements[i].value === null) {
                //If combat veteran field is displayed and value is not previously set, set value to "Yes"
                elements[i].value = 'Yes';
            }
        }
    }

    /** Initialization */
    processVisitRelatedTos() {
        if (this.visitRelatedTos && this.recordId) {
            for (let vrt in this.visitRelatedTos) {
                if (this.visitRelatedTos[vrt] === true) {
                    this.fields.push(this.visitRelatedToMap[vrt]);
                }
            }
        }
    }

    async mpiCallout() {
        try {
            const response = await retrieveVetInfo({
                recordId: this.accountIdValue
            });

            this.mpiData = JSON.parse(JSON.stringify(response)).vetsV3[0];

            if (this.mpiData.ee.serviceConnectedPercentage) {
                this.serviceConnected = this.mpiData.ee.serviceConnectedPercentage;
            }

            if (Array.isArray(this.mpiData.ee.ratedDisabilities) && this.mpiData.ee.ratedDisabilities.length !== 0) {
                this.ratedDisabilities = this.mpiData.ee.ratedDisabilities.map((disability) => {
                    return {
                        key: crypto.randomUUID(),
                        ...disability
                    };
                });
            }

            if (!this.mpiData) {
                this.hasError = true;
            }
        } catch (error) {
            this.hasError = true;
        }
        this.isLoading = false;
    }

    /** Event Handlers */

    /** ---------------FLOW ONLY-------------
     *  leveraging the fact that the flow calls 'validate'
     *  when the user presses 'next' to run all final
     *  validations and submit the form.
     *  Note: Be sure to check that the flow is not
     *  updating the record and overwriting the fields.
     * --------------------------------------*/
    @api
    validate() {
        let inputFields = this.template.querySelectorAll('lightning-input-field');
        if (inputFields.length > 0) {
            let relatedToString = '';
            for (let e of inputFields) {
                if (!e.value) {
                    return {
                        isValid: false,
                        errorMessage: 'Please complete all fields.'
                    };
                }
                relatedToString +=
                    (relatedToString ? ',' : '') +
                    this.fieldToVistaOutputMap[e.fieldName] +
                    '^' +
                    (e.value === 'Yes' ? '1' : '') +
                    (e.value === 'No' ? '0' : '');
            }
            this._relatedToOutput = relatedToString;
            this.template.querySelector('lightning-record-edit-form').submit();
        }
        return { isValid: true };
    }
}
