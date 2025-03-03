import { LightningElement, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";
import getCasesNeedingFeedback from "@salesforce/apex/PC_CaseFeedbackController.getCasesNeedingFeedback";

export default class PcFeedbackList extends LightningElement {
    @track showSurvey = false;
    @track showSpinner = true;
    @track showEmpty = false;

    data = [];

    columns = [
        {
            label: "PrC Case",
            fieldName: "caseUrl",
            type: "url",
            typeAttributes: {
                label: {
                    fieldName: "Name"
                },
                target: "_self"
            }
        },
        {
            type: "date",
            label: "Consult Date",
            fieldName: "CreatedDate",
            typeAttributes: {
                day: "numeric",
                month: "numeric",
                year: "numeric",
                hour: "2-digit",
                minute: "2-digit"
            }
        },
        { label: "Specialty", fieldName: "Specialty__c" },
        { label: "Channel", fieldName: "Channel__c" }
    ];

    @wire(getCasesNeedingFeedback)
    getCases(result) {
        this.result = result;
        if (result.data) {
            let tempData = result.data;
            if (this.objIsEmpty(tempData)) {
                this.showEmpty = true;
                return;
            } else {
                this.showEmpty = false;
            }
            this.data = [];
            for (let key in tempData) {
                if (Object.prototype.hasOwnProperty.call(tempData, key)) {
                    let record = Object.assign({}, tempData[key]);
                    console.log(record);
                    record.caseUrl = "/lightning/r/" + key + "/view";
                    this.data.push(record);
                }
            }
            this.data.sort(function (a, b) {
                return new Date(b.CreatedDate) - new Date(a.CreatedDate);
            });
        } else if (result.error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: "Something went wrong retrieving cases, please contact your system administrator.\n" + JSON.stringify(result.error),
                    variant: "error"
                })
            );
        }
        this.showSpinner = false;
    }

    handleRowAction(event) {
        // const actionName = event.detail.action.name;
        const row = event.detail.row;
        this.currentId = row.Id;
        this.currentCaseName = row.CaseNumber;
        this.showSurvey = true;
    }

    closeSurvey() {
        this.showSpinner = true;
        this.showSurvey = false;
        this.handleRefresh();
    }

    handleRefresh() {
        refreshApex(this.result);
        this.showSpinner = false;
    }
    objIsEmpty(obj) {
        for (const prop in obj) {
            if (Object.prototype.hasOwnProperty.call(obj, prop)) {
                return false;
            }
        }
        return true;
    }
}
