import { LightningElement, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getChartData from "@salesforce/apex/PC_AvailabilityGanttChart.getChartData";

export default class PcAvailabilityGanttChart extends LightningElement {
    // navigation
    @track formattedStartDate; // Title (Date Range)
    @track hours = []; // Dates (Header)
    dateShift = 1; // determines how many days we shift by

    // options
    @track datePickerString; // Date Navigation
    @track view = {
        slotSize: 1,
        slots: 24
    };
    @track startDate;
    @track skills = [];
    chartType = "National";

    connectedCallback() {
        this.setStartDate(new Date());
    }

    /*** Navigation ***/
    setStartDate(_startDate) {
        if (_startDate instanceof Date && !isNaN(_startDate)) {
            _startDate.setHours(0, 0, 0, 0);
            this.startDate = _startDate;
            this.datePickerString = _startDate.toISOString();
            this.formattedStartDate = _startDate.toLocaleDateString("en-US", {
                month: "long",
                day: "numeric",
                year: "numeric"
            });

            this.setDateHeaders();
            this.handleRefresh();
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    message: "Invalid Date",
                    variant: "error"
                })
            );
        }
    }

    setDateHeaders() {
        let today = new Date();
        today.setHours(0, 0, 0, 0);
        today = today.getTime();

        let hours = {};
        let hour1 = {
            class: "slds-col slds-p-vertical_x-small slds-m-top_x-small lwc-timeline_day",
            label: "0000"
        };
        hours["A"] = {
            days: []
        };
        hours["A"].days.push(hour1);

        for (let hour = 100, charCode = "B"; hour <= 2300; hour += 100, charCode = String.fromCharCode(charCode.charCodeAt() + 1)) {
            let curHour = hour + "";
            if (hour < 1000) {
                curHour = "0" + hour;
            }
            let hr = {
                class: "slds-col slds-p-vertical_x-small slds-m-top_x-small lwc-timeline_day",
                label: curHour
            };
            hours[charCode] = {
                days: []
            };
            hours[charCode].days.push(hr);
        }
        // reorder index
        this.hours = Object.values(hours);
    }

    navigateToToday() {
        this.setStartDate(new Date());
        this.handleRefresh();
    }

    navigateToPrevious() {
        let _startDate = new Date(this.startDate);
        _startDate.setDate(_startDate.getDate() - this.dateShift);

        this.setStartDate(_startDate);
        this.handleRefresh();
    }

    navigateToNext() {
        let _startDate = new Date(this.startDate);
        _startDate.setDate(_startDate.getDate() + this.dateShift);

        this.setStartDate(_startDate);
        this.handleRefresh();
    }

    navigateToDay(event) {
        this.setStartDate(new Date(event.target.value + "T00:00:00"));
        this.handleRefresh();
    }

    /*** /Navigation ***/
    handleRefresh() {
        let self = this;
        let month, day, year;
        month = self.startDate.getMonth() + 1;
        day = self.startDate.getDate();
        year = self.startDate.getFullYear();
        let strDate = month + "/" + day + "/" + year;
        getChartData({
            startDateStr: strDate
        })
            .then((data) => {
                data.skills.forEach(function (newResource) {
                    for (let i = 0; i < self.skills.length; i++) {
                        if (self.skills[i].Id === newResource.Id) {
                            self.skills[i] = newResource;
                            return;
                        }
                    }
                    self.skills.push(newResource);
                });
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: error.body ? error.body.message : error.message,
                        variant: "error"
                    })
                );
            });
    }
}
