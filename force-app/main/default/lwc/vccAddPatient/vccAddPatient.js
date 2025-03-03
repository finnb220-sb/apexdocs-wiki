import { LightningElement } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { newToastEvent, ToastPreset } from "./vccAddPatientHelper";
import { Result } from "c/vccResult";

import { searchCrm, SearchCrmParameters, searchMpi, SearchMpiParameters, addVeteran } from "c/vccAddPatientController";

import { ADD_PATIENT_RESULT_KIND } from "c/vccAddPatientSearchResult";

export default class VccAddPatient extends NavigationMixin(LightningElement) {
    isLoading = false;

    showSearch = true;
    showResults = false;

    searchResultKind;
    searchParameters = {};

    crmSearchResults = [];
    mpiSearchResults = [];

    cardTitle = "";

    // Declare minDOB and maxDOB, initialized as empty strings, to hold min and max dates for DOB input.
    minDOB = "";
    maxDOB = "";

    connectedCallback() {
        this.showPatientSearch = true;

        // Get current date
        const currentDate = new Date();
        // Set maxDOB as today's date
        this.maxDOB = currentDate.toISOString().split("T")[0];
        // Set minDOB as the date 150 years ago
        this.minDOB = new Date(currentDate.getFullYear() - 150, currentDate.getMonth(), currentDate.getDate()).toISOString().split("T")[0];
    }

    renderedCallback() {
        let addPatientSearch = this.template.querySelector("c-vcc-add-patient-search");
        if (addPatientSearch !== null) {
            this.cardTitle = "Add Veteran to CRM";
            addPatientSearch.setSearchParameters(this.searchParameters);
            return;
        }

        let addPatientSearchResult = this.template.querySelector("c-vcc-add-patient-search-result");
        if (addPatientSearchResult !== null) {
            if (this.searchResultKind === ADD_PATIENT_RESULT_KIND.CRM) {
                this.cardTitle = "CRM Results";
                addPatientSearchResult.setSearchResults(this.crmSearchResults);
            }
            if (this.searchResultKind === ADD_PATIENT_RESULT_KIND.MPI) {
                this.cardTitle = "External Results";
                addPatientSearchResult.setSearchResults(this.mpiSearchResults);
            }
            return;
        }
    }

    navigateToAccount(accountId) {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: accountId,
                objectApiName: "Account",
                actionName: "view"
            }
        });
    }

    async handleSearchCrm(event) {
        this.isLoading = true;
        try {
            this.searchParameters = event?.detail?.params;
            this.handleSearchCrmResult(await searchCrm(new SearchCrmParameters(event?.detail?.params)));
        } catch (e) {
            this.template.dispatchEvent(newToastEvent(ToastPreset.ERROR, e));
        }
        this.isLoading = false;
    }

    async handleSearchMpi() {
        this.isLoading = true;
        try {
            let params = { ...this.searchParameters };
            params.dob = params.dob ? params.dob.replace(/-/g, "") : "";
            this.handleSearchMpiResult(await searchMpi(new SearchMpiParameters(params)));
        } catch (e) {
            this.template.dispatchEvent(newToastEvent(ToastPreset.ERROR, e));
        }
        this.isLoading = false;
    }

    async handleAddVet(event) {
        this.isLoading = true;
        try {
            this.handleAddVetResult(await addVeteran(event?.detail?.selectedMpiResult));
        } catch (e) {
            this.template.dispatchEvent(newToastEvent(ToastPreset.ERROR, e));
        }
        this.isLoading = false;
    }

    handleSearchCrmResult(result) {
        let resultValue = result.value;
        if (Result.isErr(result)) {
            throw resultValue;
        }
        if (Result.isOk(result)) {
            if (Array.isArray(resultValue?.accountList)) {
                this.searchResultKind = ADD_PATIENT_RESULT_KIND.CRM;
                this.crmSearchResults = resultValue.accountList;
                this.showSearch = false;
                this.showResults = true;
            }
        }
    }

    handleSearchMpiResult(result) {
        let resultValue = result.value;
        if (Result.isErr(result)) {
            throw resultValue;
        }
        if (Result.isOk(result)) {
            if (Array.isArray(resultValue.allData)) {
                this.searchResultKind = ADD_PATIENT_RESULT_KIND.MPI;
                this.mpiSearchResults = resultValue.allData;
                //this is here to make the MPI results play nice with baseCompactCard
                this.mpiSearchResults.forEach((result) => {
                    result.FirstName = result.firstName;
                    result.LastName = result.lastName;
                    result.PersonBirthdate = result.dob;
                    result.Id = result.icn;
                });
            }
        }
    }

    handleAddVetResult(result) {
        let resultValue = result.value;
        if (Result.isErr(result)) {
            throw resultValue;
        }
        if (Result.isOk(result)) {
            if (resultValue.patientExists == true) {
                this.template.dispatchEvent(newToastEvent(ToastPreset.PATIENT_EXISTS));
            }
            if (resultValue.patientExists == false) {
                this.template.dispatchEvent(newToastEvent(ToastPreset.PATIENT_CREATED));
            }
            this.navigateToAccount(resultValue?.accountId);
        }
    }

    handleGoToAccount(event) {
        console.log(event.detail);
        let selectedCrmResult = event?.detail?.selectedCrmResult;
        this.navigateToAccount(selectedCrmResult?.Id);
    }

    handleBackToCrm() {
        this.isLoading = true;
        this.searchResultKind = ADD_PATIENT_RESULT_KIND.CRM;
        this.isLoading = false;
    }

    handleBackToSearch() {
        this.isLoading = true;
        this.mpiSearchResults = [];
        this.crmSearchResults = [];
        this.showSearch = true;
        this.showResults = false;
        this.isLoading = false;
    }
}
