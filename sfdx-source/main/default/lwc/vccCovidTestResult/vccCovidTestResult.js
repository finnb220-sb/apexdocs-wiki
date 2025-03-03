import { LightningElement, api } from "lwc";
import getProblems from "@salesforce/apex/VCC_ProblemController.getProblems";
import noResultsMessage from "@salesforce/label/c.VCC_Generic_message_for_null_search_results";
import noResultsSubMessage from "@salesforce/label/c.VCC_Generic_sub_message_for_null_search_results";
import genericError from "@salesforce/label/c.VCC_Generic_Error";
import genericSubError from "@salesforce/label/c.VCC_Generic_Sub_error";

import { mockData } from "./mock.js";

export default class VccCovidTestResult extends LightningElement {
    @api recordId;
    @api useMockData;
    isInit = true;
    isShowSpinner = false;
    isEmpty = false;
    noConnection = false;

    covidTitle = "";
    problemsResults;

    connectedCallback() {
        if (!this.isInit) {
            return;
        }
        this.isInit = false;
        this.getproblemsJS();
    }

    @api
    getproblemsJS() {
        debugger;
        this.showLoding();
        this.problemLighntingReqWrp = {
            recordId: this.recordId,
            //recordId : 'test',
            facility: "613",
            startDate: "1950-01-01",
            endDate: "2050-01-01"
        };
        if (!this.useMockData) {
            getProblems({ problemReqWrp: this.problemLighntingReqWrp })
                .then((result) => {
                    this.processResult(result);
                })
                .catch((result) => {
                    console.log(result);
                });
        } else {
            let result = mockData;
            this.processResult(result);
        }
    }

    processResult(result) {
        console.log("Problems list", result);

        this.problemRes = result;
        let problemList = [];

        // does the response contain sites
        if (result?.problemModal && result?.problemModal?.sites) {
            // loop through sites and add sites with data to list
            for (let i = 0; i < result.problemModal.sites.length; i++) {
                if (result?.problemModal?.sites[i]?.results?.problems?.problem?.length) {
                    problemList.push(result.problemModal.sites[i].results.problems.problem);
                    break;
                }
            }
            // if we have at least one entry in the array, set the problem list
            if (problemList?.length) {
                problemList = problemList.flat();
                this.isEmpty = false;
            } else {
                this.isEmpty = true;
            }
        }

        problemList = problemList.slice();
        let counter = 0;

        let problemListTemp = [];
        for (let i = 0; i < problemList.length; i++) {
            let problemListEle = JSON.parse(JSON.stringify(problemList[i]));
            problemListEle.key = "Key" + i;
            problemListEle.name = problemListEle.name.value;
            problemListEle.onsetDate = problemListEle.onset.onSetDate;
            problemListEle.status = problemListEle.status.name;
            problemListEle.lastUpdated = problemListEle.updated.updatedDate;
            problemListEle.ICGCode = problemListEle.icd.value;
            problemListEle.description = problemListEle.icdd.value;
            if (problemListEle.onsetDate != undefined && problemListEle.onsetDate != null) problemListTemp.push(problemListEle);
        }

        problemListTemp.sort(function (a, b) {
            if (b.onsetDate == null) {
                return 0;
            }
            console.log("counter ", counter++);
            return new Date(b.onsetDate) - new Date(a.onsetDate);
        });

        let problemFinalResult = [];
        let past15DaysDate = new Date();
        past15DaysDate.setDate(past15DaysDate.getDate() - 15);
        for (let i = 0; i < problemListTemp.length; i++) {
            problemListTemp[i].key = "Key" + i;
            console.log("Problem Obj: ", problemListTemp[i]);
            if (past15DaysDate > new Date(problemListTemp[i].onsetDate)) {
                continue;
            }
            if (problemListTemp[i].icd.value == "U07.1") {
                //if(labList[i].type.value == 'CH'){
                problemFinalResult.push(problemListTemp[i]);
                break;
            }
        }
        console.log("problemFinalResult: ", problemFinalResult);
        if (!problemFinalResult.length) {
            this.isEmpty = true;
        }
        this.problemsResults = problemFinalResult;
        this.covidTitle = "VA-COVID 19-PCR Results (within past 14 days)";
        this.hideLoding();
    }

    showLoding() {
        this.isShowSpinner = true;
    }
    hideLoding() {
        this.isShowSpinner = false;
    }
}
