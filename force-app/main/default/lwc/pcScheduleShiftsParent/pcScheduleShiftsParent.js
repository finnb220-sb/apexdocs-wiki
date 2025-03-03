import { LightningElement, api, wire, track } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Name from "@salesforce/schema/PC_Service__c.Name";
import getNext7DaysShifts from "@salesforce/apex/pcScheduleShiftsController.getNext7DaysShifts";
import updateShift from "@salesforce/apex/pcScheduleShiftsController.updateShift";
import deleteShift from "@salesforce/apex/pcScheduleShiftsController.deleteShift";
import getSpecialities from "@salesforce/apex/pcScheduleShiftsController.getSpecialities";

import isManager from "@salesforce/customPermission/PC_Service_Manager";

export default class PcScheduleShiftsParent extends LightningElement {
    @api recordId;
    recordName;
    serviceResourceName;
    serviceResourceIdModal;
    @track showTable = false;
    pcServiceId;
    startTime;
    endTime;
    columnNameMap = {};
    dateModal;
    minDate;
    shiftIdModal;
    @track daysOfTheWeek = [];
    @track today;
    @track teamMemberId;
    @track data = [];

    get isAManager() {
        return isManager;
    }

    get isEditDisabled() {
        return !isManager;
    }

    @wire(getRecord, { recordId: "$recordId", fields: [Name] })
    getPCRecord({ error, data }) {
        if (data) {
            this.recordName = data.fields.Name.value;
            this.pcServiceId = this.recordId;
        } else if (error) {
            this.error = error;
        }
    }
    connectedCallback() {
        let today = new Date();
        today.setHours(0);
        this.today = today.toISOString();
        this.dateRange = this.getDateRange(today);
        this.getTableData(today);
    }
    getTableData(date) {
        let month, day, year;
        month = date.getMonth() + 1;
        day = date.getDate();
        year = date.getFullYear();
        let strDate = month + "/" + day + "/" + year;
        getNext7DaysShifts({ startDay: strDate, pcServiceId: this.recordId })
            .then((result) => {
                this.setTableData(result, this);
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: error.body ? error.body.message : error.message,
                        title: "Error",
                        variant: "error",
                        mode: "sticky"
                    })
                );
            });
    }
    handlePrevious() {
        this.toggleWeek(-7);
    }

    handleNext() {
        this.toggleWeek(7);
    }

    handleSelect(event) {
        this.teamMemberId = event.detail;
    }
    handleSubmit() {
        let shiftDate = this.template.querySelector('[data-id="shiftDate"]');
        let startTimeField = this.template.querySelector('[data-id="startTime"]');
        let endTimeField = this.template.querySelector('[data-id="endTime"]');
        let startTime = startTimeField.value;
        let endTime = endTimeField.value;
        let dateSelected = shiftDate.value ? new Date(shiftDate.value) : null;
        if (endTime < startTime) {
            this.notifyUser("Error", "The Shift End Time cannot be less than the Start Time. If this is for third shift, create two shift records.", "error");
            return;
        } else if (!dateSelected) {
            shiftDate.setCustomValidity("Date is required");
            this.notifyUser("Error", "Please supply a date of the shift.", "error");
            return;
        } else if (dateSelected < new Date(this.minDate)) {
            this.notifyUser("Error", "Date must not be in the past.", "error");
            return;
        } else {
            shiftDate.setCustomValidity("");
            let month, day, year;
            let date = new Date();
            month = date.getMonth() + 1;
            day = date.getDate();
            year = date.getFullYear();
            let strDate = month + "/" + day + "/" + year;
            let pcShiftMap = {};
            pcShiftMap.pcShiftId = this.shiftIdModal;
            pcShiftMap.startTime = startTime;
            pcShiftMap.endTime = endTime;
            pcShiftMap.shiftDate = dateSelected;
            pcShiftMap.startDay = strDate;
            pcShiftMap.pcServiceId = this.recordId;
            updateShift(pcShiftMap)
                .then((results) => {
                    this.notifyUser("Success", "Shift has been updated", "success");
                    this.setTableData(results, this);
                })
                .catch((error) => {
                    this.notifyUser("Error", "An error occured while trying to insert the Shift: " + error.body ? error.body.message : error.message, "error");
                });
        }
        shiftDate.reportValidity();
        this.closeModal();
    }
    handleDelete() {
        let month, day, year;
        let date = new Date();
        month = date.getMonth() + 1;
        day = date.getDate();
        year = date.getFullYear();
        let strDate = month + "/" + day + "/" + year;
        let pcShiftMap = {};
        pcShiftMap.pcShiftId = this.shiftIdModal;
        pcShiftMap.startDay = strDate;
        pcShiftMap.pcServiceId = this.recordId;
        deleteShift(pcShiftMap)
            .then((results) => {
                this.notifyUser("Success", "Shift has been deleted", "success");
                this.setTableData(results, this);
            })
            .catch((error) => {
                this.notifyUser("Error", "An error occured while trying to insert the Shift: " + error.body ? error.body.message : error.message, "error");
            });
        this.closeModal();
    }
    resetTable() {}
    handleDayChange() {
        this.toggleWeek(0);
    }

    handleInsertShift(event) {
        this.setTableData(event.detail, this);
    }

    setTableData(data, comp) {
        comp.daysOfTheWeek = [];
        comp.data = [];
        let specialityColumn = {};
        specialityColumn.label = "Speciality";
        specialityColumn.fieldName = "speciality";
        specialityColumn.initialWidth = 150;
        comp.daysOfTheWeek.push(specialityColumn);
        let specialistColumn = {};
        specialistColumn.label = "Specialist";
        specialistColumn.fieldName = "serviceResourceName";
        specialistColumn.initialWidth = 150;
        comp.daysOfTheWeek.push(specialistColumn);
        for (const property in data) {
            let counter = 0;
            data[property].forEach((element) => {
                let column = {};
                let serviceDate = "serviceDate" + counter;
                let typeA = { label: { fieldName: serviceDate }, variant: "base" };
                column.label = element.serviceDateString; //PTEMSPC-473 used to make make LWC column header date in "Day of Week" M/dd format
                column.hideDefaultActions = true; //PTEMSPC-473 hides wrap/clip text column dropdowns
                column.fieldName = "link" + counter;
                column.initialWidth = 113;
                column.type = "button";
                column.typeAttributes = typeA;
                column.target = "_blank";
                comp.daysOfTheWeek.push(column);
                this.columnNameMap[serviceDate] = element.serviceDate;
                counter++;
            });
            if (counter) break;
        }
        for (const property in data) {
            let counter2 = 0;
            data[property].forEach((element) => {
                if (element.shifts) {
                    element.shifts.forEach((shift) => {
                        let row = {};
                        row["link" + counter2] = "/" + shift.Id;
                        row["serviceDate" + counter2] = this.msToTime(shift.PC_Start_Time__c) + " - " + this.msToTime(shift.PC_End_Time__c);
                        row.serviceResourceName = element.serviceResourceName;
                        row.serviceResourceId = element.serviceResourceId;
                        row.rowId = counter2;
                        this.data.push(row);
                    });
                }
                counter2++;
            });
        }
        // flatten table
        let serviceResourceIdSet = new Set();
        this.data.forEach((element) => {
            serviceResourceIdSet.add(element.serviceResourceId);
        });
        let serviceResourceArray = Array.from(serviceResourceIdSet);
        let specialistShiftArray = [];
        const dataTemp = this.data.map((a) => ({ ...a }));
        getSpecialities({ serviceResourceIds: serviceResourceArray })
            .then((res) => {
                const newDataTemp = dataTemp.map((item) => {
                    return { ...item, speciality: res[item.serviceResourceId] };
                });
                serviceResourceArray.forEach(function (element) {
                    let specialistShiftMap = {};
                    for (let i = 0; i < newDataTemp.length; i++) {
                        if (element == newDataTemp[i].serviceResourceId) {
                            specialistShiftMap["serviceResourceId"] = newDataTemp[i].serviceResourceId;
                            specialistShiftMap["serviceResourceName"] = newDataTemp[i].serviceResourceName;
                            specialistShiftMap["speciality"] = newDataTemp[i].speciality;
                            for (let j = 0; j < 7; j++) {
                                if (!Object.prototype.hasOwnProperty.call(specialistShiftMap, "serviceDate" + j)) {
                                    if (newDataTemp[i]["serviceDate" + j]) {
                                        specialistShiftMap["serviceDate" + j] = newDataTemp[i]["serviceDate" + j];
                                        specialistShiftMap["link" + j] = newDataTemp[i]["link" + j];
                                    }
                                } else {
                                    if (newDataTemp[i]["serviceDate" + j]) {
                                        specialistShiftArray.push(newDataTemp[i]);
                                    }
                                }
                            }
                        }
                    }
                    specialistShiftArray.push(specialistShiftMap);
                });
                this.data = specialistShiftArray;
                this.showTable = true;
            })
            .catch((err) => {
                console.log(err);
            });
    }

    addDays(date, days) {
        var result = new Date(date);
        result.setDate(result.getDate() + days);
        return result;
    }

    getDateRange(date) {
        const months = ["Jan.", "Feb.", "Mar.", "Apr.", "May.", "Jun.", "Jul.", "Aug.", "Sep.", "Oct.", "Nov.", "Dec."];
        let newDate = this.addDays(date, 6);
        let beginDate = months[date.getMonth()] + " " + date.getDate();
        let endDate = months[newDate.getMonth()] + " " + newDate.getDate();
        return beginDate + " - " + endDate;
    }

    handleRowAction(event) {
        let fieldName = event.detail.action.label.fieldName;
        let row = event.detail.row;
        let fullRange = event.detail.row[fieldName].split("-");
        this.serviceResourceName = row.serviceResourceName;
        this.serviceResourceIdModal = row.serviceResourceId;
        this.startTime = fullRange[0].trim();
        this.endTime = fullRange[1].trim();
        let dateString = this.columnNameMap[fieldName];
        let dateParts = dateString.split("-");
        this.dateModal = new Date(dateParts[0] + "/" + dateParts[1] + "/" + dateParts[2]).toISOString();
        this.minDate = new Date().toISOString().slice(0, 10);
        let lastIndex = fieldName.substring(fieldName.length - 1);
        this.shiftIdModal = row["link" + lastIndex].substring(1);
        this.openModal();
    }

    msToTime(s) {
        let ms = s % 1000;
        s = (s - ms) / 1000;
        let secs = s % 60;
        s = (s - secs) / 60;
        let mins = s % 60;
        let hrs = (s - mins) / 60;
        hrs = hrs < 10 ? "0" + hrs : hrs;
        mins = mins < 10 ? "0" + mins : mins;
        return hrs + ":" + mins;
    }
    notifyUser(title, message, variant) {
        if (this.notifyViaAlerts) {
            // Notify via alert
            // eslint-disable-next-line no-alert
            alert(`${title}\n${message}`);
        } else {
            // Notify via toast (only works in LEX)
            const toastEvent = new ShowToastEvent({ title, message, variant });
            this.dispatchEvent(toastEvent);
        }
    }

    openModal() {
        this.template.querySelector(".viewAllModal").open(this.template.host);
    }
    closeModal() {
        this.template.querySelector(".viewAllModal").close(this.template.host);
    }

    getDayIndex(pcDate, daySelected) {
        for (var i = 1; i < 7; i++) {
            let tempDate = new Date(daySelected);
            if (pcDate.getTime() === this.addDays(tempDate, i).getTime()) {
                return i;
            }
        }
        return -1;
    }

    toggleWeek(daysForward) {
        let daySelected = this.template.querySelector('[data-id="daySelected"]').value;
        if (daySelected) {
            let newDaySelectedDate;
            if (daySelected.indexOf("T") != -1) {
                newDaySelectedDate = daySelected.substring(0, daySelected.indexOf("T"));
            } else {
                newDaySelectedDate = daySelected;
            }

            let daySelectedDate = new Date(newDaySelectedDate);
            let daySelectedDateWithTZOffset = new Date(daySelectedDate.getTime() - daySelectedDate.getTimezoneOffset() * -60000); //PTEMSPC-474 added timezone offset so correct day is calculated for date picker and date range

            let sevenDaysForward = this.addDays(daySelectedDateWithTZOffset, daysForward);
            let month, day, year;
            month = sevenDaysForward.getMonth() + 1;
            day = sevenDaysForward.getDate();
            year = sevenDaysForward.getFullYear();
            let strDate = year + "-" + month + "-" + day;
            this.today = strDate;
            this.getTableData(sevenDaysForward);
            this.dateRange = this.getDateRange(sevenDaysForward);
        }
    }
}
