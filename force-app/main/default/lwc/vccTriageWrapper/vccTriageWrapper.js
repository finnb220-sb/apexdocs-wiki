import { LightningElement, api } from 'lwc';
import LightningAlert from 'lightning/alert';
import { createClient } from 'c/vccMessageChannel';
import { updateRecord } from 'lightning/uiRecordApi';

import apex_getVitals from '@salesforce/apex/VCC_TriageController.getVitals';
import apex_getTriageStatus from '@salesforce/apex/VCC_TriageController.getTriageStatus';

class TriageInstance {
    uuid;
    messageChannelClient;
    recordId;
    destroyCallback;

    constructor(recordId) {
        this.constructorValidation(recordId);
        this.uuid = crypto.randomUUID();
        this.recordId = recordId;
        this.messageChannelClient = createClient(this.uuid, (msg) => this.handleMessage(msg), true);
    }

    constructorValidation(recordId) {
        if (recordId == null || recordId === undefined || typeof recordId !== 'string') {
            throw new Error('Record id not found.');
        }
    }

    async close() {
        await this.messageChannelClient.sendRequestTo('txccState', {
            action: 'triageComplete'
        });
        this.messageChannelClient.close();
    }

    async open() {
        await this.messageChannelClient.sendRequestTo('txccState', {
            action: 'triageStarted',
            recordId: this.recordId,
            clientName: this.uuid
        });
    }

    onDestory(f) {
        this.destroyCallback = f;
    }

    handleMessage(msg) {
        switch (msg.payload.action) {
            case 'destroy':
                this.destroyCallback();
                msg.reply(true);
                break;
            default:
                break;
        }
    }
}

export default class VccTriageWrapper extends LightningElement {
    @api
    enableWarnings;

    @api
    recordId;

    triageInstance;

    isLoading = true;
    isStartable = false;
    isStarted = false;
    isNotStartableReason = '';
    triageStatus;

    async connectedCallback() {
        try {
            this.triageStatus = await apex_getTriageStatus({ recordId: this.recordId });
            this.isStartable = this.triageStatus.isStartable;
            this.isNotStartableReason = this.triageStatus.isNotStartableReason;
            this.isLoading = false;
            let logger = this.template.querySelector('c-logger');
            if (logger != null) {
                logger.debug(this.triageStatus);
            }
        } catch (e) {
            this.isNotStartableReason = e.message;
        }
    }

    async disconnectedCallback() {
        this.isLoading = true;
        this.isStartable = false;
        this.isStarted = false;
        this.isNotStartableReason = '';
        this.triageStatus = null;
        if (this.triageInstance instanceof TriageInstance) {
            await this.triageInstance.close();
            this.triageInstance = null;
        }
    }

    async handleStartTriage() {
        this.isLoading = true;
        if (this.triageInstance instanceof TriageInstance) {
            return;
        }
        let vitals = await this.getVitals();
        if (vitals.VCC_Triage_Complete__c === true) {
            return;
        }
        this.isStarted = true;
        if (this.enableWarnings === true) {
            this.triageInstance = new TriageInstance(this.recordId);
            this.triageInstance.onDestory(() => {
                this.endTriage();
            });
            await this.triageInstance.open();
        }
        /*eslint-disable-next-line @lwc/lwc/no-async-operation */
        setTimeout(async () => {
            this.startTriage(vitals);
            this.isLoading = false;
        }, 1000);
    }

    async getVitals() {
        let records = await apex_getVitals({ recordId: this.recordId });
        if (Array.isArray(records) && records.length === 1) {
            return records[0];
        }

        let logger = this.template.querySelector('c-logger');
        if (logger != null) {
            logger.debug('Failed to get vitals for triage.');
        }
        return null;
    }

    startTriage(vitals) {
        try {
            if (typeof vitals === 'object') {
                let triObj = vitals;
                let startObject = {};

                // required fields
                startObject.gender =
                    triObj.VCC_Gender__c === 'Male' || triObj.VCC_Gender__c === 'M'
                        ? 'M'
                        : triObj.VCC_Gender__c === 'Female' || triObj.VCC_Gender__c === 'F'
                          ? 'F'
                          : undefined;
                startObject.dob = new Date(triObj.VCC_Date_of_Birth__c);
                // vitals
                this.objBuilder(startObject, 'height', triObj.VCC_Height__c);
                this.objBuilder(startObject, 'weight', triObj.VCC_Weight__c);
                this.objBuilder(startObject, 'systolicBloodPressure', triObj.VCC_Systolic_Blood_Pressure__c);
                this.objBuilder(startObject, 'diastolicBloodPressure', triObj.VCC_Diastolic_Blood_Pressure__c);
                this.objBuilder(startObject, 'temperature', triObj.VCC_Temperature__c);
                this.objBuilder(startObject, 'serumGlucose', triObj.VCC_Serum_Glucose__c);
                this.objBuilder(startObject, 'respiratoryRate', triObj.VCC_Respiratory_Rate__c);
                this.objBuilder(startObject, 'o2', triObj.VCC_Pulse_Oximetry__c);
                this.objBuilder(startObject, 'pulse', triObj.VCC_Pulse__c);

                this.template.querySelector('c-dshi-txcc').start(startObject);
            }
        } catch (e) {
            let logger = this.template.querySelector('c-logger');
            if (logger != null) {
                logger.debug('Unable to start triage.');
                logger.debug(e.message);
            }
        }
    }

    async endTriage() {
        this.template.querySelector('c-dshi-txcc').doResetComponent();
        await this.disconnectedCallback();
        this.connectedCallback();
    }

    async handleTriageComplete(e) {
        e.stopPropagation();
        this.isLoading = true;
        let { cc, triageNote, systemRfi, systemRfl } = e.detail;
        await updateRecord({
            fields: {
                Id: this.recordId,
                VCC_Triage_Complete__c: true,
                VCC_Triage_Note__c: '⠀\n\rDecision Support Tool Used: TXCC \n\r' + triageNote,
                VCC_Chief_Complaint__c: cc,
                VCC_System_RFI__c: systemRfi,
                VCC_System_RFL__c: systemRfl,
                VCC_Logistical_Recommendation_WHEN__c: systemRfi,
                VCC_Logistical_Recommendation_WHERE__c: systemRfl
            }
        });
        this.isTriageComplete = true;
        await this.disconnectedCallback();
        this.connectedCallback();
    }

    handleTriageError(e) {
        e.stopPropagation();
        LightningAlert.open({
            theme: 'warning',
            message: e.detail,
            label: 'Triage Error'
        });
    }

    async handleTriageAbort(e) {
        e.stopPropagation();
        await this.disconnectedCallback();
        this.connectedCallback();
    }

    objBuilder(obj, field, val) {
        if (val === undefined || val == null || val === '') {
            return obj;
        }
        obj[field] = val;
        return obj;
    }
}
