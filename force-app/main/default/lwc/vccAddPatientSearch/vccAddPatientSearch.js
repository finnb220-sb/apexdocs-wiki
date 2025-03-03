import { LightningElement, api } from "lwc";
import vccAddPatient_SSN_Regex from "@salesforce/label/c.vccAddPatient_SSN_Regex";
import vccAddPatient_pattern_mismatch_message from "@salesforce/label/c.vccAddPatient_pattern_mismatch_message";
import vccAddPatient_Greater_Than_Two_Regex from "@salesforce/label/c.vccAddPatient_Greater_Than_Two_Regex";
import vccAddPatient_Greater_Than_Two_Message from "@salesforce/label/c.vccAddPatient_Greater_Than_Two_Message";
import vccAddPatient_Date_of_Birth_Max from "@salesforce/label/c.vccAddPatient_Date_of_Birth_Max";
import vccAddPatient_Date_of_Birth_Min from "@salesforce/label/c.vccAddPatient_Date_of_Birth_Min";

export default class VccAddPatientSearch extends LightningElement {
    vccAddPatient_SSN_Regex = vccAddPatient_SSN_Regex;
    vccAddPatient_pattern_mismatch_message = vccAddPatient_pattern_mismatch_message;
    vccAddPatient_Greater_Than_Two_Regex = vccAddPatient_Greater_Than_Two_Regex;
    vccAddPatient_Greater_Than_Two_Message = vccAddPatient_Greater_Than_Two_Message;
    // Variables for min and max date
    vccAddPatient_Date_of_Birth_Max = vccAddPatient_Date_of_Birth_Max;
    vccAddPatient_Date_of_Birth_Min = vccAddPatient_Date_of_Birth_Min;
    maxDate;
    minDate;

    @api
    setSearchParameters(params) {
        //? populating previous search values
        const inputFields = this.template.querySelectorAll("lightning-input");
        if (inputFields) {
            inputFields.forEach((field) => {
                if (field.dataset.name === "firstName") field.value = params?.firstName;
                if (field.dataset.name === "lastName") field.value = params?.lastName;
                if (field.dataset.name === "middleName") field.value = params?.middleName;
                if (field.dataset.name === "ssn") field.value = params?.ssn;
                if (field.dataset.name === "dob") field.value = params?.dob;
            });
        }
    }

    connectedCallback() {
        // Set the max and min dates for DOB
        this.setMaxAndMinDates();
    }

    setMaxAndMinDates() {
        // Get today's date
        const today = new Date();

        // Set max date as today
        this.maxDate = this.formatDate(today);

        // Set min date as 150 years before today
        const minDate = new Date();
        minDate.setFullYear(minDate.getFullYear() - 150);
        this.minDate = this.formatDate(minDate);
    }

    formatDate(date) {
        // Format a date as YYYY-MM-DD
        let month = "" + (date.getMonth() + 1),
            day = "" + date.getDate(),
            year = date.getFullYear();

        if (month.length < 2) month = "0" + month;
        if (day.length < 2) day = "0" + day;

        return [year, month, day].join("-");
    }

    handleViewCRMClick() {
        let params = {};
        this.template.querySelectorAll("lightning-input").forEach((inputElement) => {
            if (inputElement.checkValidity() === false) {
                inputElement.reportValidity();
                return;
            }
            params[inputElement.dataset.name] = inputElement.value;
        });
        // there are 5 inputs, all should be valid
        if (Object.keys(params).length < 5) {
            return;
        }

        this.template.dispatchEvent(new CustomEvent("searchcrm", { detail: { params: params }, composed: true, bubbles: true }));
    }

    handleClearInputClick() {
        const inputFields = this.template.querySelectorAll("lightning-input");
        if (inputFields) inputFields.forEach((field) => (field.value = null));
    }
}
