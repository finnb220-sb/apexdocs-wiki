import { LightningElement, api, wire, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getSpecialistAvailability from "@salesforce/apex/pcScheduleShiftsController.getSpecialistAvailability";

export default class PcSpecialistAvailabilitySchedule extends LightningElement {
    @track showTable = false;
    availabilityLastModified;
    data;
    columns = [
        { label: "Day", fieldName: "day" },
        { label: "Start Time", fieldName: "start" },
        { label: "End Time", fieldName: "end" }
    ];

    @api teamMemberId;
    get teamMemberId() {
        return this.teamMemberId;
    }
    set teamMemberId(_teamMemberId) {
        if (_teamMemberId) {
            this.handleSelection(_teamMemberId);
        }
    }

    handleSelection(_teamMemberId) {
        if (_teamMemberId) {
            getSpecialistAvailability({ serviceTeamMemberId: _teamMemberId })
                .then((result) => {
                    this.availabilityLastModified = new Date(result[0].Availability__r.LastModifiedDate).toLocaleString();
                    let tempData = [];
                    result.forEach((element) => {
                        let row = {};
                        row.Id = element.Id;
                        row.day = element.PC_Day_of_Week__c;
                        row.start = this.msToTime(element.PC_Start__c);
                        row.end = this.msToTime(element.PC_End__c);
                        tempData.push(row);
                    });
                    this.data = tempData;
                    this.showTable = true;
                })
                .catch((error) => {
                    let title = "Warning";
                    let variant = "warning";
                    if (error.body && error.body.message.includes("Error")) {
                        title = "Error";
                        variant = "Error";
                    }
                    this.dispatchEvent(
                        new ShowToastEvent({
                            message: error.body ? error.body.message : error.message,
                            title: "Warning",
                            variant: "warning",
                            mode: "sticky"
                        })
                    );
                    this.showTable = false;
                });
        } else {
            this.showTable = false;
        }
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
}
