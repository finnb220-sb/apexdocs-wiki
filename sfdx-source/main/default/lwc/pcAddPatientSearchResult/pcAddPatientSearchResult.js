import { LightningElement, api } from 'lwc';
import noCRMResultsMsg from '@salesforce/label/c.VCC_No_CRM_Results';
import searchExternallyMsg from '@salesforce/label/c.VCC_Search_Externally';
import crmResults from './crmResults';
import mpiResults from './mpiResults';

export const ADD_PATIENT_RESULT_KIND = {
    CRM: 'CRM',
    MPI: 'MPI'
};

const KIND_TO_TEMPLATE_MAP = {
    CRM: crmResults,
    MPI: mpiResults
};

export default class PcAddPatientSearchResult extends LightningElement {
    settings = { icon: '' };

    //labels
    noCRMResultsMsg = noCRMResultsMsg;
    searchExternallyMsg = searchExternallyMsg;

    @api kind;
    searchResults = [];
    noResults = true;

    selectedCrmResult;
    selectedMpiResult;

    get isOpenCrmRecordDisabled() {
        if (typeof this.selectedCrmResult !== 'object' || this.selectedCrmResult == null) {
            return true;
        }
        return false;
    }

    get isAddVetDisabled() {
        if (typeof this.selectedMpiResult !== 'object' || this.selectedMpiResult == null) {
            return true;
        }
        return false;
    }

    render() {
        if (ADD_PATIENT_RESULT_KIND[this.kind] === undefined) {
            throw new Error('Invalid pcAddPatientSearchResult kind.');
        }
        return KIND_TO_TEMPLATE_MAP[this.kind];
    }

    connectedCallback() {
        if (this.kind === ADD_PATIENT_RESULT_KIND.CRM) {
            this.settings = { icon: 'standard:person_account' };
        } else if (this.kind === ADD_PATIENT_RESULT_KIND.MPI) {
            this.settings = { icon: 'standard:people' };
        }
    }

    @api
    setSearchResults(results) {
        if (!Array.isArray(results) || results.length === 0) {
            this.noResults = true;
            this.searchResults = [];
        } else {
            this.noResults = false;
            this.searchResults = results;
        }
    }

    handleCardClick(event) {
        if (this.kind === ADD_PATIENT_RESULT_KIND.CRM) {
            this.selectedCrmResult = event?.detail?.value;
        } else if (this.kind === ADD_PATIENT_RESULT_KIND.MPI) {
            this.selectedMpiResult = event?.detail?.value;
        }
    }

    /** Below methods dispatch events  */

    handleOpenRecordClick() {
        if (this.isOpenCrmRecordDisabled === true) {
            return;
        }
        this.template.dispatchEvent(
            new CustomEvent('gotoaccount', {
                detail: { selectedCrmResult: this.selectedCrmResult },
                bubbles: true,
                composed: true
            })
        );
    }

    handleViewPatientInfoClick() {
        this.template.dispatchEvent(
            new CustomEvent('gotopatientinfo', {
                detail: { selectedCrmResult: this.selectedCrmResult },
                bubbles: true,
                composed: true
            })
        );
    }

    handleBackToSearchClick() {
        this.template.dispatchEvent(new CustomEvent('backtosearch', { bubbles: true, composed: true }));
        this.selectedMpiResult = null;
        this.selectedCrmResult = null;
    }

    handleBackToCrmClick() {
        this.template.dispatchEvent(new CustomEvent('backtocrm', { bubbles: true, composed: true }));
        this.selectedMpiResult = null;
    }

    handleViewExternalClick() {
        this.template.dispatchEvent(new CustomEvent('searchmpi', { composed: true, bubbles: true }));
    }

    async handleAddVeteran() {
        if (this.isAddVetDisabled === true) {
            return;
        }
        let dob = this.selectedMpiResult?.dob;
        if (typeof dob === 'string') {
            let splitDob = dob.split('-');
            if (splitDob.length === 3) {
                // re-formatting DOB for use by MPI Package
                [splitDob[0], splitDob[1], splitDob[2]] = [splitDob[2], splitDob[0], splitDob[1]];
                dob = splitDob.join('-');
            }
        }
        this.template.dispatchEvent(
            new CustomEvent('addvet', {
                detail: {
                    selectedMpiResult: {
                        ...this.selectedMpiResult,
                        dob: dob
                    }
                },
                bubbles: true,
                composed: true
            })
        );
    }
}
