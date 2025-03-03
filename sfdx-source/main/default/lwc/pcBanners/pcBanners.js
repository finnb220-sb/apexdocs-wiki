import { LightningElement, wire, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { getRecord } from "lightning/uiRecordApi";
import getCasesNeedingFeedback from "@salesforce/apex/PC_CaseFeedbackController.getCasesNeedingFeedback";
import fullName from "@salesforce/schema/User.Name";
import userTimeZone from "@salesforce/schema/User.TimeZoneSidKey";
import userLocale from "@salesforce/schema/User.LocaleSidKey";
import Id from "@salesforce/user/Id";

export default class PcBanners extends NavigationMixin(LightningElement) {
    @api recordId = Id;
    showFeedbackBanner = false;
    numberOfPendingFeedbacks = 0;
    currentUser = {};
    currentTime;

    @wire(getRecord, { recordId: "$recordId", fields: [fullName, userTimeZone, userLocale] })
    userDetails({ error, data }) {
        if (data) {
            this.currentUser = { Id: data.id, Name: data.fields.Name.value, TimeZone: data.fields.TimeZoneSidKey.value, Locale: data.fields.LocaleSidKey.value.replace("_", "-") };
        } else if (error) {
            this.error = error;
        }
    }

    connectedCallback() {
        this.currentTime = new Date();
    }

    @wire(getCasesNeedingFeedback)
    getCases(result) {
        this.result = result;
        if (result.data) {
            let tempData = result.data;
            this.numberOfPendingFeedbacks = Object.keys(tempData).length;
            if (this.numberOfPendingFeedbacks > 0) {
                this.showFeedbackBanner = true;
            } else {
                this.showFeedbackBanner = false;
            }
        } else if (result.error) {
            this.showFeedbackBanner = false;
            this.numberOfPendingFeedbacks = 0;
        }
    }

    get isFeedbackPending() {
        return this.showFeedbackBanner;
    }

    get currentUserTime() {
        let myDate = new Date(this.currentTime.toLocaleString(this.currentUser.Locale, { timeZone: this.currentUser.TimeZone }));
        const monthMap = new Map([
            [0, "January"],
            [1, "February"],
            [2, "March"],
            [3, "April"],
            [4, "May"],
            [5, "June"],
            [6, "July"],
            [7, "August"],
            [8, "September"],
            [9, "October"],
            [10, "November"],
            [11, "December"]
        ]);
        const dayMap = new Map([
            [1, "Monday"],
            [2, "Tuesday"],
            [3, "Wednesday"],
            [4, "Thursday"],
            [5, "Friday"],
            [6, "Saturday"],
            [7, "Sunday"]
        ]);
        let hh = myDate.getHours() < 10 ? "0" + myDate.getHours() : myDate.getHours();
        let mm = myDate.getMinutes() < 10 ? "0" + myDate.getMinutes() : myDate.getMinutes();
        return dayMap.get(myDate.getDay()) + " " + monthMap.get(myDate.getMonth()) + " " + myDate.getDate() + ", " + myDate.getFullYear() + " " + hh + ":" + mm;
    }

    navigateToUser(event) {
        let id = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: id,
                objectApiName: "User",
                actionName: "view"
            }
        });
    }

    navigateToPendingFeedbackList() {
        this[NavigationMixin.Navigate]({
            type: "standard__navItemPage",
            attributes: {
                apiName: "PC_Feedback"
            }
        });
    }

    handleFeedbackBannerClose() {
        this.showFeedbackBanner = false;
    }
}
