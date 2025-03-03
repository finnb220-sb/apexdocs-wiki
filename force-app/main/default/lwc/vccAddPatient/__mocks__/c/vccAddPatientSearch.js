import { LightningElement, api } from 'lwc';

export default class VccAddPatientSearch extends LightningElement {
    searchParameters;

    @api
    setSearchParameters(searchParameters) {
        this.searchParameters = searchParameters;
    }

    @api
    getSearchParameters() {
        return this.searchParameters;
    }
}
