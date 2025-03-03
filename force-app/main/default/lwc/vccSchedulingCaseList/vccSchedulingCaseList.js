import { LightningElement, track, api } from "lwc";
import getCaseList from "@salesforce/apex/VCC_SchedulingCasesListController.getCaseList";
export default class VccSchedulingCaseList extends LightningElement {
    componentTitle = "My VISN MSA Queue";
    @api flexipageRegionWidth;
    isInit = true;

    currentIndex = 0;
    totalRecordsDetails;

    @track caseList = [];
    @track isShowSpinner = false;
    @track totalRecords = 0;
    @api pageSize = 5;
    @track currentPage = 1;

    _caseList = [];
    _caseListTemp = [];

    _sortItems = "Follow-Up Appt Needed";
    _oldSortItems = "followUpApptHours";
    _sortcase = "Desc";

    noResults = false;

    columns = [
        {
            label: "Case Number",
            fieldName: "caseURL",
            type: "url",
            typeAttributes: {
                label: {
                    fieldName: "caseNumber"
                }
            },
            sortable: true
        },
        {
            label: "Follow-Up Appt Needed",
            fieldName: "followUpAppt",
            type: "text",
            sortable: true
        },
        {
            label: "Contact Name",
            fieldName: "contactURL",
            type: "url",
            typeAttributes: {
                label: {
                    fieldName: "contactName"
                }
            },
            sortable: true
        },
        /*
        { label: "Case Record Type", fieldName: "recordType", type: "text", sortable: true },
        {
            label: "Case Type",
            fieldName: "caseType",
            type: "text",
            sortable: true
        },
        {
            label: "Case Sub Type",
            fieldName: "caseSubType",
            type: "text",
            sortable: true
        },
        */
        {
            label: "Subject",
            fieldName: "subjectURL",
            type: "url",
            typeAttributes: {
                label: {
                    fieldName: "subject"
                }
            }
        },
        {
            label: "Status",
            fieldName: "status",
            type: "text",
            sortable: true
        },
        {
            label: "Date/Time Opened",
            fieldName: "dateTimeOpened",
            type: "date",
            typeAttributes: {
                day: "2-digit",
                month: "2-digit",
                year: "numeric",
                hour: "2-digit",
                minute: "2-digit",
                second: "2-digit",
                hour12: true
            },
            sortable: true
        },
        {
            label: "Case Owner Alias",
            fieldName: "caseOwnerAlias",
            type: "text",
            sortable: true
        }
    ];
    defaultSortDirection = "asc";
    sortDirection = "asc";
    sortedBy;
    secondSortedBy = "dateTimeOpened";

    connectedCallback() {
        this.getCaseListJS();
        if (!this.isInit) {
            return;
        }
        this.isInit = false;
        debugger;
    }

    @api
    getCaseListJS() {
        debugger;
        this.showLoding();

        getCaseList()
            .then((result) => {
                this.processResult(result);
            })
            .catch((result) => {
                console.log(result);
                this.noConnection = true;
                this.hideLoding();
            });
    }

    processResult(result) {
        this._caseList = result;
        //this.caseList = result;
        this._caseListTemp = JSON.parse(JSON.stringify(result));
        if (!this._caseList.length) {
            this.noResults = true;
            this.hideLoding();
            return;
        }
        let counter = 0;
        let caseList = result;
        this.noResults = false;
        this.totalRecords = caseList.length;
        this.setRecords();
        this.hideLoding();
    }

    handlePageChange(event) {
        debugger;
        this.currentPage = event.detail;
        this.setRecords();
    }

    setRecords() {
        debugger;
        let caseList = this._caseListTemp;
        let startPageIndex;
        let currentPage = this.currentPage - 1;
        if (currentPage == 0) {
            startPageIndex = currentPage;
        } else {
            startPageIndex = currentPage * this.pageSize;
        }

        let endPageIndex = startPageIndex + this.pageSize;
        caseList = caseList.slice(startPageIndex, endPageIndex);
        this.caseList = caseList;
    }

    onHandleSort(event) {
        const { fieldName, sortDirection } = event.detail;
        this.sortData(fieldName, sortDirection);
        this.sortDirection = sortDirection;
        this.sortedBy = fieldName;
        console.log(typeof fieldName);
        console.log(fieldName);
        // if (fieldName === 'enteredDateStr'){
        //     this.secondSortedBy = 'Date';
        // }
        console.log(this.sortedBy);
        // const { fieldName, sortDirection } = event.detail;
        // this.sortData(fieldName, sortDirection);
        // this.sortDirection = sortDirection;

        switch (fieldName) {
            case "followUpApptHours":
                this.secondSortedBy = "dateTimeOpened";
                this._sortItems = "Follow Up Appointment Interval";
                break;
            case "caseNumber":
                this.secondSortedBy = "";
                this._sortItems = "Case Number";
                break;
            case "status":
                this.secondSortedBy = "";
                this._sortItems = "Status";
                break;
            case "contactName":
                this.secondSortedBy = "";
                this._sortItems = "Contact Name";
                break;
            case "recordType":
                this.secondSortedBy = "";
                this._sortItems = "Case Record Type";
                break;
            case "caseType":
                this.secondSortedBy = "";
                this._sortItems = "Case Type";
                break;
            case "caseSubType":
                this.secondSortedBy = "";
                this._sortItems = "Case Sub Type";
                break;
            case "dateTimeOpened":
                this.secondSortedBy = "";
                this._sortItems = "Date/Time Opened";
                break;
        }
    }

    sortData(fieldName, sortDirection) {
        debugger;
        let sortResult = [...this._caseList];
        let parser = (v) => v;
        let column = this.columns.find((c) => c.fieldName === fieldName);
        if (column.type === "date" || column.type === "datetime") {
            parser = (v) => v && new Date(v);
        }
        if (fieldName == "followUpAppt") {
            fieldName = "followUpApptHours";
        }

        let sortMult = sortDirection === "asc" ? 1 : -1;
        this._caseListTemp = sortResult.sort((a, b) => {
            let a1 = parser(a[fieldName]),
                b1 = parser(b[fieldName]);
            let r1 = a1 < b1,
                r2 = a1 === b1;
            return r2 ? 0 : r1 ? -sortMult : sortMult;
        });
        this.setRecords();
    }

    showLoding() {
        this.isShowSpinner = true;
    }
    hideLoding() {
        this.isShowSpinner = false;
    }

    handlePageChange(event) {
        debugger;
        this.currentPage = event.detail;
        this.setRecords();
    }

    reset() {
        debugger;
        this.totalRecords = this._caseListTemp.length;
        this.currentPage = 1;
    }

    get isSmall() {
        return this.flexipageRegionWidth == "SMALL";
    }
    get isMedium() {
        return this.flexipageRegionWidth == "MEDIUM";
    }
}
