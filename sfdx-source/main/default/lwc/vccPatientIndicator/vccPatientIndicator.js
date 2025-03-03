import { LightningElement, track, api, wire } from "lwc";
import getICN from "@salesforce/apex/VCC_lwc_utils.getICN";
import getWorkstreamSettings from "@salesforce/apex/VCC_WorkstreamSettingsController.getWorkstreamSettings";
import getMedsWithParams from "@salesforce/apex/VCC_MedsListController.getMedsWithParams";

export default class VccPatientIndicator extends LightningElement {
    showError;
    showSpinner = true;

    columns = [
        { label: "Facility", fieldName: "id" },
        { label: "Eligibility", fieldName: "eligibility" },
        { label: "Conditions", fieldName: "conditions", wrapText: true },
        { label: "SC%", fieldName: "sc" }
    ];

    @track messageData = [];
    @api recordId;
    _icn;
    defaultStartDate;

    /**
     * @description Gets ICN number for patient from recordId
     * @param string recordId
     */
    @wire(getICN, { recordId: "$recordId" })
    wiredGetIcn(value) {
        if (value.data) {
            setTimeout(() => {
                this._icn = value.data;
            }, 3000);
        }
    }

    /**
     * @description  gets workstream settings for user and sets default startDate
     */
    @wire(getWorkstreamSettings)
    wiredGetSettings(value) {
        if (value.data) {
            this.defaultStartDate = new Date(new Date().setMonth(new Date().getMonth() - value.data.VCC_Meds_Duration__c)).toISOString().split("T", 1)[0];
        }
    }
    /**
     * @description Gets medslist based on ICN Number and selected start date VCC_MedsListController.getMedsWithParams.
     * Calls send message with medsList data
     * @param string ICN Number
     * @param string medicationList startDate
     */
    @wire(getMedsWithParams, { icn: "$_icn", startDate: "$defaultStartDate" })
    wiredGetMedsWithParams(value) {
        if (value.data) {
            this.showSpinner = false;
            this.handleMessage(value.data);
        } else if (value.error) {
            this.showSpinner = false;
            this.showError = true;
        }
    }

    handleMessage(message) {
        const hdrData = message.v1;

        if (hdrData.sites && hdrData.sites.length) {
            for (let site of hdrData.sites) {
                let sId = site?.siteSupplemental?.facility;
                let sEName = site?.siteSupplemental?.eligibility?.printName;
                let sConditions = site?.siteSupplemental?.serviceConnected?.conditions?.condition;
                let sPercent = site?.siteSupplemental?.serviceConnected?.percentage;

                if (site && sEName) {
                    let siteInfo = {};
                    siteInfo.id = sId;
                    siteInfo.eligibility = sEName;
                    siteInfo.conditions =
                        sConditions && sConditions.length
                            ? sConditions.reduce((prev, value) => {
                                  return prev ? prev + ", " + value : value;
                              }, "")
                            : " - ";
                    siteInfo.sc = sPercent ? sPercent : " - ";
                    this.messageData.push(siteInfo);
                }
            }
        }
    }
}
