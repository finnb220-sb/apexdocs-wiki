import { LightningElement, api } from "lwc";

//helpers
import { parseInpatientData } from "./vccInpatientJsonHelper";
import ExposedPromise from "c/exposedPromise";
import LoggerMixin from "c/loggerMixin";
import { NavigationMixin } from "lightning/navigation";

//lightning-modal
import VccInpatientModal from "c/vccInpatientModal";

//controller
import { getsertRecentView, acknowledgeRecentView, RECENT_VIEW_TYPE } from "c/vccAccountPopupController";

//callout
import retrieveInPatientInfo from "@salesforce/apex/VCC_lwc_utils.retrieveInPatientInfo";

export default class VccInPatient extends NavigationMixin(LoggerMixin(LightningElement)) {
    @api
    recordId;

    recentView;
    inPatientCalloutResponse;

    initializedPromise;
    async renderedCallback() {
        try {
            if (this.initializedPromise instanceof Promise) {
                return;
            }
            this.initializedPromise = new ExposedPromise();

            this.recentView = await getsertRecentView({
                accountId: this.recordId,
                recentViewType: RECENT_VIEW_TYPE.InPatient
            });

            if (this.recentView.VCC_Type_In_Patient__c === true) {
                this.initializedPromise.resolve();
                return;
            }

            this.inPatientCalloutResponse = await retrieveInPatientInfo({ recordId: this.recordId });
            this.initializedPromise.resolve();
        } catch (e) {
            this.Logger.debug(JSON.stringify(e));
            this.initializedPromise.reject("vccInPatient component initialization failed.");
        }
    }

    @api
    async open(popupPromise) {
        try {
            await this.initializedPromise;

            if (this.recentView.VCC_Type_In_Patient__c === true) {
                popupPromise.resolve();
                return;
            }

            let inpatientList = parseInpatientData(this.inPatientCalloutResponse);

            this.inPatientCalloutResponse = null;
            //If inpatientList is empty, acknowledge then continue, else, show modal
            if (inpatientList.length == 0) {
                this.acknowledgeRecentView();
                popupPromise.resolve();
                return;
            }

            let result = await this.presentModal(inpatientList);

            if (result?.acknowledged === true) {
                this.acknowledgeRecentView();
                popupPromise.resolve();
                return;
            }
        } catch (e) {
            this.Logger.debug(String(e));
            this.Logger.debug(JSON.stringify(e));
            popupPromise.resolve();
        } finally {
            this.Logger.saveLog();
        }
    }

    navigateHome() {
        this[NavigationMixin.Navigate]({
            type: "standard__namedPage",
            attributes: {
                pageName: "home"
            }
        });
    }

    acknowledgeRecentView() {
        acknowledgeRecentView({
            accountId: this.recordId,
            recentViewType: RECENT_VIEW_TYPE.InPatient
        });
    }

    async presentModal(patientList = []) {
        return await VccInpatientModal.open({
            size: "small",
            description: "A pop-up modal window that displays if the patient is inpatient at a VAMC.",
            navigateHome: this.navigateHome.bind(this),
            patientList: patientList
        });
    }
}
