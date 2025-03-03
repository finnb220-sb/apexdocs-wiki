import { LightningElement, api } from 'lwc';

export const ADD_PATIENT_RESULT_KIND = {
    CRM: 'CRM',
    MPI: 'MPI'
};

export default class VccAddPatientSearchResult extends LightningElement {
    @api searchResults;
    @api kind;

    @api
    setSearchResults(searchResults) {
        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
        this.searchResults = searchResults;
    }
}
