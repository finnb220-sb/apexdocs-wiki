import { LightningElement, api } from "lwc";

//case fields
/* eslint-disable */
import Status from "@salesforce/schema/Case.Status";
import VCC_Case_Type__c from "@salesforce/schema/Case.VCC_Case_Type__c";
import VCC_Case_Outcome__c from "@salesforce/schema/Case.VCC_Case_Outcome__c";
import VCC_Case_Sub_Type__c from "@salesforce/schema/Case.VCC_Case_Sub_Type__c";
import VCC_Follow_Up_Appt_Needed__c from "@salesforce/schema/Case.VCC_Follow_Up_Appt_Needed__c";
import Subject from "@salesforce/schema/Case.Subject";
import Reason from "@salesforce/schema/Case.Reason";
/* eslint-enable */
// the method to check if PNs are signed below
import unsignedProgressNotesOnCase from "@salesforce/apex/VCC_ProgressNoteController.unsignedProgressNotesOnCase";
import getCaseInfoWrapper from "@salesforce/apex/VCC_CaseController.getCaseInfoWrapper";
// the method to check if PNs are signed below
export default class VccCloseCaseV2 extends LightningElement {
    @api
    recordId;

    @api
    taskCheck;

    unsignedProgressNotes;
    caseInfo;
    isLoading = true;
    isError = false;
    initialized = false;

    connectedCallback() {}

    async renderedCallback() {
        if (this.initialized === true) {
            return;
        }
        this.initialized = true;

        try {
            this.unsignedProgressNotes = await unsignedProgressNotesOnCase({
                caseRecordId: this.recordId
            });
            let caseData = await getCaseInfoWrapper({
                recordId: this.recordId
            });

            caseData = JSON.parse(caseData);
            if (!caseData) {
                throw new Error("No data returned from getCaseInfoWrapper");
            }

            this.caseInfo = caseData;

            this.isError = false;
            this.isLoading = false;
        } catch (e) {
            this.isError = true;
            this.isLoading = false;
        }
    }
}
