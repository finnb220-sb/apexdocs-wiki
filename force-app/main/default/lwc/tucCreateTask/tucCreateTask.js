import { LightningElement, api } from "lwc";
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from "lightning/flowSupport";

export default class TucCreateTask extends LightningElement {
    @api AvailableSubjects = [
        "Columbia +",
        "COV test only",
        "COVID Rx/T2T",
        "Culture",
        "Lab",
        "Pharmacy",
        "Radiology",
        "Travel",
        "Follow Up Appointment or Consult Confirmed",
        "Other"
    ]; //An array of available subject options
    @api SelectedSubject; // The subject selected by the user
    @api SelectedDueDate;
    @api SelectedOrderDate;
    @api SpecificOrder;
    @api CommentsProgress;
    @api SelectedSubjectError;

    Subject = "";
    SubjectOptions = [];
    DefaultDueDate;

    connectedCallback() {
        //Populating Subject
        this.SubjectOptions = this.AvailableSubjects.map((Subject) => {
            return { label: Subject, value: Subject };
        });

        //Used to Set Selected Order Date default to Today
        const tempToday = new Date();
        //Get month pulls 0-11, so the +1 is to set the text value correct
        let tempMonth = tempToday.getMonth() + 1;
        let tempDay = tempToday.getDate();

        if (tempMonth < 10) {
            tempMonth = "0" + tempMonth;
        }
        if (tempDay < 10) {
            tempDay = "0" + tempDay;
        }
        this.SelectedOrderDate = tempToday.getFullYear() + "-" + tempMonth + "-" + tempDay;
    }

    //Handling changes to the subject field
    handleSubjectChange(event) {
        this.SelectedSubject = event.detail.value;
        const attributeChangeEvent = new FlowAttributeChangeEvent("SelectedSubject", this.SelectedSubject);

        this.setDefaultDueDate(); //Calling Default Date to set the Task Due Date
        //resetting Selected Subject Error when a Subject is selected
        this.SelectedSubjectError = "";
        this.dispatchEvent(attributeChangeEvent);
    }

    //Handling Due Date
    handleDueDateChange(event) {
        this.SelectedDueDate = event.detail.value;
        const attributeChangeEvent = new FlowAttributeChangeEvent("SelectedDueDate", this.SelectedDueDate);
        this.dispatchEvent(attributeChangeEvent);
    }

    //Handling Order Date
    handleOrderDateChange(event) {
        this.SelectedOrderDate = event.detail.value;
        const attributeChangeEvent = new FlowAttributeChangeEvent("SelectedOrderDate", this.SelectedOrderDate);
        this.dispatchEvent(attributeChangeEvent);
    }

    //Handling Specific Order
    handleSpecificOrderChange(event) {
        this.SpecificOrder = event.detail.value;
        const attributeChangeEvent = new FlowAttributeChangeEvent("SpecificOrder", this.SpecificOrder);
        this.dispatchEvent(attributeChangeEvent);
    }

    //Handling Comments/Progress
    handleCommentsProgressChange(event) {
        this.CommentsProgress = event.detail.value;
        const attributeChangeEvent = new FlowAttributeChangeEvent("CommentsProgress", this.CommentsProgress);
        this.dispatchEvent(attributeChangeEvent);
    }

    //Used to Set the Default Date for Task Due Date
    setDefaultDueDate() {
        const tempToday = new Date();

        switch (this.SelectedSubject) {
            //Colbumia + = Today + 24 Hours
            case "Columbia +":
                tempToday.setDate(tempToday.getDate() + 1);
                break;
            //COV test only = Today + 24 Hours
            case "COV test only":
                tempToday.setDate(tempToday.getDate() + 1);
                break;
            //COVID Rx/T2t = Today + 24 Hours
            case "COVID Rx/T2T":
                tempToday.setDate(tempToday.getDate() + 1);
                break;
            //Culture = Today + 2 Weeks
            case "Culture":
                tempToday.setDate(tempToday.getDate() + 14);
                break;
            //Lab = Today + 2 Weeks
            case "Lab":
                tempToday.setDate(tempToday.getDate() + 14);
                break;
            //Pharmacy = Today + 2 Weeks
            case "Pharmacy":
                tempToday.setDate(tempToday.getDate() + 14);
                break;
            //Radiology = Today + 2 Weeks
            case "Radiology":
                tempToday.setDate(tempToday.getDate() + 14);
                break;
            //Travel = Today + 24 Hours
            case "Travel":
                tempToday.setDate(tempToday.getDate() + 1);
                break;
            //Defualt covers 'Other' and 'Follow Up Appointment or Consult Confirmed'
            default:
                this.DefaultDueDate = "";
                break;
        }
        //If not 'Other' or 'Follow Up Appointment or Consult Confirmed' then take the date that would of been set above in the switch and format it correctly
        if (!(this.SelectedSubject === "Other" || this.SelectedSubject === "Follow Up Appointment or Consult Confirmed")) {
            let tempMonth = tempToday.getMonth() + 1;
            let tempDay = tempToday.getDate();

            if (tempMonth < 10) {
                tempMonth = "0" + tempMonth;
            }
            if (tempDay < 10) {
                tempDay = "0" + tempDay;
            }
            this.DefaultDueDate = tempToday.getFullYear() + "-" + tempMonth + "-" + tempDay;
        }
        //Sets the Selected Date so the user can see the change.
        this.SelectedDueDate = this.DefaultDueDate;
    }

    handleSave() {
        //Error Message and check if subject was selected
        if (!this.SelectedSubject) {
            this.SelectedSubjectError = "ERROR: Please select a choice.";
            return;
        }
        //Specifically if a Due Date is not selected at all, this is because the flow is attempting to set a Due Date. This can be replaced/removed with the tech debt
        //So setting Selected Due Date to TODAY();
        if (this.SelectedDueDate === "") {
            const tempToday = new Date();
            //Get month pulls 0-11, so the +1 is to set the text value correct
            tempToday.setDate(tempToday.getDate() + 14);

            let tempMonth = tempToday.getMonth() + 1;
            let tempDay = tempToday.getDate();

            if (tempMonth < 10) {
                tempMonth = "0" + tempMonth;
            }
            if (tempDay < 10) {
                tempDay = "0" + tempDay;
            }
            this.SelectedDueDate = tempToday.getFullYear() + "-" + tempMonth + "-" + tempDay;
        }
        //Else Save/Run rest of flow
        else {
            const nextNavigationEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(nextNavigationEvent);
        }
    }
}
