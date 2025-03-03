import { LightningElement, track, api } from "lwc";
import getOperatingHours from "@salesforce/apex/pcServiceOperatingHoursController.getOperatingHours";

import { NavigationMixin } from "lightning/navigation";

import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";

const HOURS_COLUMNS = [
    { label: "DAY", fieldName: "DayOfWeek" },
    { label: "HOURS", fieldName: "Timeslot" }
];

const EXCEPTIONS_COLUMNS = [
    { label: "Name", fieldName: "Name" },
    { label: "Date", fieldName: "DateOf" },
    { label: "Day", fieldName: "DayOfWeek" },
    { label: "Start Time", fieldName: "StartTime" },
    { label: "End Time", fieldName: "EndTime" }
];

export default class PcServiceOperatingHours extends NavigationMixin(LightningElement) {
    @api title;
    @api recordId;
    @api refreshTimer;
    @track timezone;
    @track opHoursId;
    @track hoursData;
    hoursColumns = HOURS_COLUMNS;
    @track exceptionsData;
    exceptionsColumns = EXCEPTIONS_COLUMNS;
    selectedRows;

    isLoading = true;
    isShow = true;
    isDisabled = true;
    hasData = false;
    hasHours = false;
    isSelected = false;
    _interval;
    msg;

    connectedCallback() {
        this.fetchOperatingHours();
    }

    fetchOperatingHours() {
        getOperatingHours({
            serviceId: this.recordId
        })
            .then((result) => {
                this.error = undefined;
                this.isLoading = false;
                if (result === undefined || result.length === 0) {
                    //console.log('No Service Info found');
                    this.msg = "No Service Info found";
                    this.isShow = false;
                    this.hasData = false;
                } else if (result.opHoursId === undefined || result.opHoursId.length === 0) {
                    //console.log('No Operating Hour Info found');
                    this.msg = "No Operating Hour Info found";
                    this.isShow = false;
                    this.hasData = false;
                } else {
                    //console.log('Service and Operating Hour info found successfully');
                    this.hasData = true;
                    this.isShow = true;
                    this.timezone = result.Timezone;
                    this.opHoursId = result.opHoursId;
                    if (result.TimeSlots === undefined || result.TimeSlots.length === 0) {
                    } else {
                        //console.log('Time Slots found successfully');
                        this.hasHours = true;
                        this.hoursData = result.TimeSlots;
                    }
                    if (result.Exceptions === undefined || result.Exceptions.length === 0) {
                    } else {
                        //console.log('Exceptions found successfully');
                        this.exceptionsData = result.Exceptions;
                    }
                }
            })
            .catch((error) => {
                this.error = error;
                this.records = undefined;
                this.isLoading = false;
                this.isShow = false;
                this.msg = "There is an issue while fetching data";
                //console.log(' --> '+JSON.stringify(this.error.message));
            });
    }

    handleRowSelection() {
        this.selectedRows = this.template.querySelector("lightning-datatable[data-recid=hoursTable]").selectedRows;
        //console.log('selectedRows: ' + this.selectedRows);
        if (this.selectedRows.length == 0) {
            this.isSelected = false;
        } else {
            this.isSelected = true;
            //console.log('selectedRows0: ' + this.selectedRows[0]);
        }
    }

    editOperatingHours() {
        if (this.isSelected) {
            //console.log('selectedRows: ' + this.selectedRows[0]);
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: this.selectedRows[0],
                    objectApiName: "Time_Slot__c",
                    actionName: "edit"
                }
            });
            this.template.querySelector("lightning-datatable[data-recid=hoursTable]").selectedRows = [];
            //console.log('waiting to refresh');
            setTimeout(() => {
                this.reloadComponent();
            }, this.refreshTimer * 1000); //not how I wanted it, will need to implement a modal driven approach later
        }
    }

    createNewException() {
        const defaultValues = encodeDefaultFieldValues({
            PC_Operating_Hours__c: this.opHoursId,
            PC_Service__c: this.recordId
        });

        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: "PC_Exception__c",
                actionName: "new"
            },
            state: {
                nooverride: "1",
                defaultFieldValues: defaultValues,
                navigationLocation: "RELATED_LIST"
            }
        });
        //console.log('waiting to refresh');
        setTimeout(() => {
            this.reloadComponent();
        }, this.refreshTimer * 1000); //not how I wanted it, will need to implement a modal driven approach later
    }

    reloadComponent() {
        //console.log('refreshing');
        this.isLoading = true;
        this.isShow = true;
        this.isDisabled = true;
        this.hasData = false;
        this.hasHours = false;
        this.isSelected = false;
        this.template.querySelector("lightning-datatable[data-recid=hoursTable]").selectedRows = [];
        this.fetchOperatingHours();
    }
}
