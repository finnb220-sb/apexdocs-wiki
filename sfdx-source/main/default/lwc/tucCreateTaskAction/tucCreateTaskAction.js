import { LightningElement, api, wire } from "lwc";
import { FlowAttributeChangeEvent } from "lightning/flowSupport";
import { CloseActionScreenEvent } from "lightning/actions";
import createTask from "@salesforce/apex/tucCreateTaskActionController.createTask";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getFieldValue, getRecord } from "lightning/uiRecordApi";
import TASK_WHO_ID from "@salesforce/schema/Case.ContactId";

export default class TucCreateTaskAction extends LightningElement {
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

    @api recordId;
    @api objectApiName;

    //Getting Case Id and Contact.Id that is on the case
    @wire(getRecord, {
        recordId: "$recordId",
        fields: [TASK_WHO_ID]
    })
    case; //Used in the save method for getting the TASK_WHO_ID

    Subject = "";
    SubjectOptions = [];
    DefaultDueDate;
    isSpinner = false;

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

        //Setting default, so if user doesn't enter anything, the insert works still.
        this.SpecificOrder = "";
        this.CommentsProgress = "";
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

    //Handling
    handleChange(event) {
        event.preventDefault();
        let tempName = event.target.name;
        let tempValue = event.detail.value;

        switch (tempName) {
            case "TaskDueDate":
                this.SelectedDueDate = tempValue;
                break;
            case "TaskOrderDate":
                this.SelectedOrderDate = tempValue;
                break;
            case "SpecificOrder":
                this.SpecificOrder = tempValue;
                break;
            case "CommentsProgress":
                this.CommentsProgress = tempValue;
                break;
        }
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
            //Follow Up Appointment or Consult Confirmed = Today + 24 Hours
            case "Follow Up Appointment or Consult Confirmed":
                tempToday.setDate(tempToday.getDate() + 1);
                break;
            //Other = Today + 24 Hours
            case "Other":
                tempToday.setDate(tempToday.getDate() + 1);
                break;
        }

        let tempMonth = tempToday.getMonth() + 1;
        let tempDay = tempToday.getDate();

        if (tempMonth < 10) {
            tempMonth = "0" + tempMonth;
        }
        if (tempDay < 10) {
            tempDay = "0" + tempDay;
        }

        this.DefaultDueDate = tempToday.getFullYear() + "-" + tempMonth + "-" + tempDay;

        //Sets the Selected Date so the user can see the change.
        this.SelectedDueDate = this.DefaultDueDate;
    }

    handleSave() {
        this.isSpinner = true;
        //Error Message and check if subject was selected
        if (!this.SelectedSubject) {
            this.SelectedSubjectError = "ERROR: Please select a choice.";
            this.isSpinner = false;
            return;
        }

        if (getFieldValue(this.case.data, TASK_WHO_ID) === null) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: "ERROR: Please add a Patient to the Case before creating a Task.",
                    variant: "error"
                })
            );
            this.isSpinner = false;
            return;
        }

        //Save/Run the createTask method
        createTask({
            whatId: this.recordId,
            SelectedSubject: this.SelectedSubject,
            SelectedOrderDate: this.SelectedOrderDate,
            SelectedDueDate: this.SelectedDueDate,
            SpecificOrder: this.SpecificOrder,
            CommentsProgress: this.CommentsProgress,
            vccCase: this.recordId,
            whoId: getFieldValue(this.case.data, TASK_WHO_ID)
        })
            .then((result) => {
                console.log("Result \n", result);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Task has been Created",
                        variant: "success"
                    })
                );
                this.isSpinner = false;
                this.closeAction();
            })
            .catch((error) => {
                console.log("Error \n", error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: "There was an error in Creating a Task",
                        variant: "error"
                    })
                );
            })
            .finally(() => {
                this.isSpinner = false;
                this.closeAction();
            });
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}
