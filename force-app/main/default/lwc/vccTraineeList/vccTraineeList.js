import { LightningElement, wire, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import searchUsers from "@salesforce/apex/VCC_TraineeListController.searchUsers";
import searchByDivision from "@salesforce/apex/VCC_TraineeListController.searchByDivision";
import searchByTitle from "@salesforce/apex/VCC_TraineeListController.searchByTitle";
import searchByRange from "@salesforce/apex/VCC_TraineeListController.searchByRange";
import resetTrainingDataForUsers from "@salesforce/apex/VCC_TraineeListController.resetTrainingDataForUsers";
import checkJobStatus from "@salesforce/apex/VCC_TraineeListController.checkJobStatus";

const columns = [
    { label: "Id", fieldName: "Id" },
    { label: "First Name", fieldName: "FirstName" },
    { label: "Last Name", fieldName: "LastName" },
    { label: "Title", fieldName: "Title" },
    { label: "Division", fieldName: "Division" },
    { label: "Username", fieldName: "Username" },
    { label: "Email", fieldName: "Email" },
    { label: "Employee Number", fieldName: "EmployeeNumber" }
];

export default class VccTraineeList extends LightningElement {
    searchKey = "";
    divisionKey = "";
    titleKey = "";
    startingNumber = "";
    endingNumber = "";
    @track users = null;
    columns = columns;
    isLoading = false;
    isRunningReset = false;
    @track selectedRows = [];
    asyncJobId;
    statusMessage = "Initializing";
    @track progress = 0;
    error;

    connectedCallback() {
        this.setIsLoading(false);
    }

    resetForm() {
        this.searchKey = "";
        this.divisionKey = "";
        this.startingNumber = "";
        this.endingNumber = "";
        this.users = [];
        this.selectedRows = [];
        this.isLoading = false;
        this.isRunningReset = false;
    }

    setIsLoading(isLoading) {
        this.isLoading = isLoading;
    }

    // Events
    handleTab1Active(event) {
        this.handleSearch();
    }

    handleTab2Active(event) {
        this.handleSearchByTitle();
    }

    handleTab3Active(event) {
        this.handleSearchByDivision();
    }

    handleTab4Active(event) {
        this.handleSearchByRange();
    }

    handleSearchStrChanged(event) {
        this.searchKey = event.target.value;
        this.handleSearch();
    }

    handleDivisionStrChanged(event) {
        this.divisionKey = event.target.value;
        this.handleSearchByDivision();
    }

    handleTitleStrChanged(event) {
        this.titleKey = event.target.value;
        this.handleSearchByTitle();
    }

    handleStartingNumberChanged(event) {
        this.startingNumber = event.target.value;
        this.handleSearchByRange();
    }

    handleEndingNumberChanged(event) {
        this.endingNumber = event.target.value;
        this.handleSearchByRange();
    }

    handleRowSelection(event) {
        this.selectedRows = this.getFields(event.detail.selectedRows, "Id");
    }

    // Actions
    handleSearch() {
        this.users = null;
        this.selectedRows = [];
        if (this.searchKey != null && this.searchKey !== "" && this.searchKey.length >= 2) {
            this.setIsLoading(true);
            searchUsers({ searchKey: this.searchKey })
                .then((result) => {
                    console.log(JSON.stringify(result));
                    this.users = result;
                    this.error = undefined;
                })
                .catch((error) => {
                    this.error = error;
                    this.users = undefined;
                })
                .finally(() => {
                    this.setIsLoading(false);
                });
        }
    }

    handleSearchByDivision() {
        this.users = null;
        this.selectedRows = [];
        if (this.divisionKey != null && this.divisionKey !== "" && this.divisionKey.length >= 2) {
            this.setIsLoading(true);
            searchByDivision({ divisionKey: this.divisionKey })
                .then((result) => {
                    this.users = result;
                    this.error = undefined;
                })
                .catch((error) => {
                    this.error = error;
                    this.users = undefined;
                })
                .finally(() => {
                    this.setIsLoading(false);
                });
        }
    }

    handleSearchByTitle() {
        this.users = null;
        this.selectedRows = [];
        if (this.titleKey != null && this.titleKey !== "" && this.titleKey.length >= 2) {
            this.setIsLoading(true);
            searchByTitle({ titleKey: this.titleKey })
                .then((result) => {
                    this.users = result;
                    this.error = undefined;
                })
                .catch((error) => {
                    this.error = error;
                    this.users = undefined;
                })
                .finally(() => {
                    this.setIsLoading(false);
                });
        }
    }

    handleSearchByRange() {
        this.users = null;
        this.selectedRows = [];
        if (this.startingNumber != null && this.startingNumber !== "" && this.endingNumber != null && this.endingNumber !== "" && this.startingNumber <= this.endingNumber) {
            this.setIsLoading(true);
            searchByRange({ startingNumber: this.startingNumber, endingNumber: this.endingNumber })
                .then((result) => {
                    this.users = result;
                    this.error = undefined;
                })
                .catch((error) => {
                    this.error = error;
                    this.users = undefined;
                })
                .finally(() => {
                    this.setIsLoading(false);
                });
        }
    }

    handleResetTrainingDataForSelectedUsers() {
        this.isRunningReset = true;
        resetTrainingDataForUsers({ userIds: this.selectedRows })
            .then((result) => {
                this.asyncJobId = result;
                this._interval = setInterval(() => {
                    this.checkJobStatus();
                }, 200);
            })
            .catch((error) => {
                //
            })
            .finally(() => {});
    }

    getFields(input, field) {
        let output = [];
        for (let i = 0; i < input.length; ++i) output.push(input[i][field]);
        return output;
    }

    checkJobStatus() {
        checkJobStatus({ asyncApexJobId: this.asyncJobId })
            .then((result) => {
                this.asyncApexJob = result;
                this.progress = this.progress === 100 ? 0 : this.progress + 5;
                if (this.asyncApexJob.Status === "Processing") {
                    this.statusMessage = this.asyncApexJob.Status + " " + this.asyncApexJob.JobItemsProcessed + " of " + this.asyncApexJob.TotalJobItems + " item(s)";
                } else {
                    this.statusMessage = this.asyncApexJob.Status;
                }
                if (this.asyncApexJob.Status === "Completed") {
                    clearInterval(this._interval);
                    this.isRunningReset = false;
                    const evt = new ShowToastEvent({
                        title: "Reset Training Data",
                        message: "Reset of training data completed successfully.",
                        variant: "success"
                    });
                    this.dispatchEvent(evt);
                    /*window.location.href = "/lightning/o/Account/list?filterName=My_Accounts";*/
                }
                if (this.asyncApexJob.Status === "Aborted") {
                    clearInterval(this._interval);
                    this.isRunningReset = false;
                    const evt = new ShowToastEvent({
                        title: "Reset Training Data",
                        message: "This job was aborted.",
                        variant: "error"
                    });
                    this.dispatchEvent(evt);
                    /*window.location.href = "/lightning/o/Account/list?filterName=My_Accounts";*/
                }
            })
            .catch((error) => {
                this.isRunningReset = false;
            })
            .finally(() => {});
    }
}
