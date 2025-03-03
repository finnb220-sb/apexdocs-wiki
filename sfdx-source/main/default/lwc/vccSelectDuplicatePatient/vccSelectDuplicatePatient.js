import { LightningElement, track, api } from 'lwc';
import getSelectPatientData from '@salesforce/apex/VCC_PatientService.getSELECTPatientData';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { IntegrationType, getSiteIntegrationType, selectPatient } from 'c/vccDasController';

const DATE_OPTIONS = { weekday: undefined, year: 'numeric', month: 'short', day: 'numeric' };

export default class VccSelectDuplicatePatient extends LightningElement {
    @track SELECTData = [];
    @track DuplicateData = [];
    @track isLoading = true;
    @track hasError = false;
    @api providerLoginSiteCode; //facility site Id
    @api providerName;
    @api providerUserId;
    @api patientLocalSiteId; //facility site Id
    @api newPatientLocalIdVariable;
    @api isMocked; //deprecated DO NOT USE
    @api recordId;

    //508 Compliance: These values are used to assign unique ids to the HTML elements that make up each patient. They need to be assigned in order for the screen reader to read all the values of each patient. Before this assignment, the screen reader was not
    //reading every value of each patient. Used in conjunction with the aria-owns html attribute.
    htmlIds = [
        'patientnamelabel',
        'patientnamevalue',
        'ssnlabel',
        'ssnvalue',
        'pidlabel',
        'pidvalue',
        'doblabel',
        'dobvalue',
        'genderlabel',
        'gendervalue',
        'maritalstatuslabel',
        'maritalstatusvalue',
        'serviceconnectedlabel',
        'serviceconnectedvalue',
        'inpatientlabel',
        'inpatientvalue',
        'patienttypelabel',
        'patienttypevalue',
        'isveteranlabel',
        'isveteranvalue'
    ];

    @api
    set mviDuplicatesJSON(value) {
        this._mviDuplicatesJson = JSON.parse(value);
        this.DuplicateData = this._mviDuplicatesJson;
    }

    get mviDuplicatesJSON() {
        return this._mviDuplicatesJson;
    }

    async connectedCallback() {
        await this.selectCallout();
        //508 compliance: generateHtmlIds is used to generate unique Ids for each HTML element. Used by screen readers to read the values of each patient. The aria-owns HTML attribute references these ids.
        this.generateHtmlIds();
        this.isLoading = false;
    }

    async selectCallout() {
        try {
            let integrationType = await getSiteIntegrationType(String(this.providerLoginSiteCode).trim());
            let result;
            if (integrationType === IntegrationType.VDIF) {
                result = await getSelectPatientData({
                    providerLoginSiteCode: String(this.providerLoginSiteCode).trim(),
                    providerName: String(this.providerName).trim(),
                    providerUserId: String(this.providerUserId).trim(),
                    patientLocalPid: this.DuplicateData.map((data) => data.personId),
                    patientLocalSiteId: String(this.patientLocalSiteId).trim(),
                    recordId: this.recordId
                });
            } else if (integrationType === IntegrationType.DAS) {
                result = await selectPatient({
                    providerLoginSiteCode: String(this.providerLoginSiteCode).trim(),
                    providerName: String(this.providerName).trim(),
                    providerUserId: String(this.providerUserId).trim(),
                    patientLocalPid: this.DuplicateData.map((data) => data.personId),
                    patientLocalSiteId: String(this.patientLocalSiteId).trim(),
                    recordId: this.recordId
                });
            }
            this.SELECTData.push(...result);
            this.checkValid();
            this.modifySELECTCalloutReturn();
        } catch (error) {
            this.hasError = true;
            const logger = this.template.querySelector('c-logger');
            if (error instanceof Error) {
                logger.error(error.message);
                logger.error(error.stack);
            } else {
                logger.error(JSON.stringify(error));
            }
            logger.saveLog();
        } finally {
            this.isLoading = false;
        }
    }

    modifySELECTCalloutReturn() {
        if (this.SELECTData.length > 0) {
            for (var i = 0; i < this.SELECTData.length; i++) {
                if (this.SELECTData[i].dob != null) {
                    //Format DOB
                    let dateObject = new Date(this.SELECTData[i].dob);
                    this.SELECTData[i].dob = dateObject.toLocaleDateString('en-us', DATE_OPTIONS);
                }
                if (this.SELECTData[i].ssn != null) {
                    //Format SSN
                    this.SELECTData[i].ssn =
                        this.SELECTData[i].ssn.slice(0, 3) +
                        '-' +
                        this.SELECTData[i].ssn.slice(3, 5) +
                        '-' +
                        this.SELECTData[i].ssn.slice(5); //Add dashes
                }
            }
        }
    }

    checkValid() {
        //All PatientId's should be present in the response
        if (this.SELECTData.length > 0) {
            for (var i = 0; i < this.SELECTData.length; i++) {
                if (this.SELECTData[i].patientId == null) {
                    this.hasError = true;
                    const logger = this.template.querySelector('c-logger');
                    logger.error('Invalid Response. No PatientId/DFN.');
                    logger.saveLog();
                }
            }
        }
    }

    handleDuplicateSelection(evt) {
        let el = this.template.querySelectorAll('div');
        for (let i = 0; i < el.length; i++) {
            el[i].classList.remove('cardBorder');
        }
        if (this.newPatientLocalIdVariable == evt.target.dataset.id) {
            this.handleMouseOut(evt);
            this.newPatientLocalIdVariable = null;
            const attributeChangeEvent = new FlowAttributeChangeEvent(
                'newPatientLocalId',
                this.newPatientLocalIdVariable
            );
            this.dispatchEvent(attributeChangeEvent);
        } else {
            this.handleMouseOver(evt);
            this.newPatientLocalIdVariable = Number(evt.target.dataset.id);
            const attributeChangeEvent = new FlowAttributeChangeEvent(
                'newPatientLocalId',
                this.newPatientLocalIdVariable
            );
            this.dispatchEvent(attributeChangeEvent);
        }
    }

    handleMouseOver(evt) {
        let targetId = evt.target.dataset.id;
        this.template.querySelector(`[data-id="${targetId}"]`)?.classList.add('cardBorder');
    }

    handleMouseOut(evt) {
        let targetId = evt.target.dataset.id;
        if (this.newPatientLocalIdVariable != targetId) {
            this.template.querySelector(`[data-id="${targetId}"]`)?.classList.remove('cardBorder');
        }
    }

    handleNext() {
        if (this.isLoading == false) {
            if (this.newPatientLocalIdVariable != null || this.hasError === true) {
                const navigateNextEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent);
            } else {
                this.showToast('Please select a record to proceed', '', 'error', 'dismissible');
            }
        }
    }

    handlePrevious() {
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }

    showToast(ti, mes, vari, md) {
        const evt = new ShowToastEvent({
            title: ti,
            message: mes,
            variant: vari,
            mode: md
        });
        this.dispatchEvent(evt);
    }

    generateHtmlIds() {
        for (var i = 0; i < this.htmlIds.length; i++) {
            for (var j = 0; j < this.SELECTData.length; j++) {
                let htmlId = this.htmlIds[i];
                //Add property to SELECTData to make uniqueIds available within the HTML iterator
                this.SELECTData[j][htmlId] = htmlId + this.SELECTData[j].patientId;
                //Build the ariaOwnsValue string for each patient in SELECTData. This is used to assign reference between the aria-own attribute and the HTML elements
                this.SELECTData[j].ariaOwnsValue += this.SELECTData[j][htmlId] + ' ';
            }
        }
    }
}
