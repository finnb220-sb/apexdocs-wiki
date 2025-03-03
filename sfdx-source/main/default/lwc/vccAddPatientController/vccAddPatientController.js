import apex_searchMpi from "@salesforce/apex/VCC_AddPatientController.searchMpi";
import apex_searchCrm from "@salesforce/apex/VCC_AddPatientController.searchCrm";
import apex_addVeteran from "@salesforce/apex/VCC_AddPatientController.addVeteran";
import { Result } from "c/vccResult";

class SearchParameters {
    ssn;
    dob;
    lastName;
    firstName;
    middleName;

    constructor({ ssn = "", dob = "", lastName = "", firstName = "", middleName = "" } = {}) {
        this.ssn = ssn;
        this.dob = dob;
        this.lastName = lastName;
        this.firstName = firstName;
        this.middleName = middleName;
    }
}

export class SearchCrmParameters extends SearchParameters {
    constructor(searchParameters = new SearchParameters()) {
        super(searchParameters);
    }
}

export class SearchMpiParameters extends SearchParameters {
    constructor(searchParameters = new SearchParameters()) {
        super(searchParameters);
    }
}

export async function searchMpi(params) {
    if (!(params instanceof SearchMpiParameters)) {
        throw new Error("Error: Parameters object must be an instance of SearchMpiParameters.");
    }
    return Result.fromApex(await apex_searchMpi({ params: params }));
}

export async function searchCrm(params) {
    if (!(params instanceof SearchCrmParameters)) {
        throw new Error("Error: Parameters object must be an instance of SearchCrmParameters.");
    }
    return Result.fromApex(await apex_searchCrm({ params: params }));
}

export async function addVeteran(params) {
    return Result.fromApex(await apex_addVeteran({ params: params }));
}
