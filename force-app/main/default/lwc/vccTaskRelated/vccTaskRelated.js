import { LightningElement, api, wire } from "lwc";
import getRelatedTaskDetail from "@salesforce/apex/VCC_TaskMedicationController.getRelatedTaskDetail";
import { subscribe, MessageContext, APPLICATION_SCOPE } from "lightning/messageService";
import vccUIUpdate from "@salesforce/messageChannel/vccUIUpdate__c";

const columns = [
    { label: "Subject", fieldName: "recordLink4", type: "url", typeAttributes: { label: { fieldName: "Subject" }, target: "_self", linkify: true } },
    {
        label: "Due Date",
        fieldName: "DueDate",
        type: "date",
        cellAttributes: { alignment: "left" },
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        }
    },
    { label: "Status", fieldName: "Status" },
    { label: "Related To", fieldName: "recordLink", type: "url", typeAttributes: { label: { fieldName: "CaseNumber" }, target: "_self", linkify: true } },
    { label: "Assigned To", fieldName: "recordLink2", type: "url", typeAttributes: { label: { fieldName: "OwnerId" }, target: "_self", linkify: true } },
    { label: "Created By", fieldName: "recordLink3", type: "url", typeAttributes: { label: { fieldName: "CreatedById" }, target: "_self", linkify: true } },
    {
        label: "Created Date",
        fieldName: "CreatedDate",
        type: "date",
        cellAttributes: { alignment: "left" },
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric",
            hour: "numeric",
            minute: "numeric",
            hour12: true
        }
    }
];

export default class VccTaskRelated extends LightningElement {
    @api recordId;
    sdata;
    columns = columns;
    noRecords = false;
    title = "Future Renewal Tasks";
    refreshHandlerID;

    labels = {
        noResultsMessage: "There are no related tasks to display"
    };

    get taskTitle() {
        return "Future Renewal Tasks" + (this.sdata?.length ? " (" + this.sdata?.length + ")" : " (0)");
    }

    subscription = null;
    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                vccUIUpdate,
                (message) => {
                    if (message.componentName === "vccTaskRelated") {
                        this.getTaskDetails(this.recordId);
                    }
                },
                { scope: APPLICATION_SCOPE }
            );
        }
        this.getTaskDetails();
        this.setUpColumns();
    }

    setUpColumns() {
        // remove Related To column if on Case or PN if present
        const relatedToPresent = this.columns.find((obj) => obj.label === "Related To");
        if (relatedToPresent && (this.recordId.startsWith("500") || this.recordId.startsWith("a1a"))) {
            this.columns.splice(3, 1);
        }
        // add Related To column if on Account or Task
        else if (!relatedToPresent && (this.recordId.startsWith("001") || this.recordId.startsWith("00T"))) {
            let relatedToObj = {
                label: "Related To",
                fieldName: "recordLink",
                type: "url",
                typeAttributes: { label: { fieldName: "CaseNumber" }, target: "_self", linkify: true }
            };
            this.columns.splice(3, 0, relatedToObj);
        }
    }

    getTaskDetails() {
        let sWhatid = this.recordId;
        getRelatedTaskDetail({ recId: sWhatid })
            .then((data) => {
                let ObjData = JSON.parse(JSON.stringify(data));
                ObjData.forEach((Record) => {
                    Record.recordLink = "/" + Record.WhatId;
                    if (Record.WhatId.startsWith("a1a")) {
                        //do PN name
                        Record.CaseNumber = Record?.What?.Name;
                    } else {
                        //do caseNumber
                        Record.CaseNumber = Record?.What?.CaseNumber;
                    }
                    Record.recordLink2 = "/" + Record.OwnerId;
                    Record.OwnerId = Record.Owner.Name;
                    Record.recordLink3 = "/" + Record.CreatedBy.Id;
                    Record.CreatedById = Record.CreatedBy.Name;
                    Record.recordLink4 = "/" + Record.Id;
                    //Record.Subject = Record.Subject;
                });
                this.data = ObjData;
                this.sdata = ObjData;
                if (this.sdata?.length === 0) this.noRecords = true;
                if (this.sdata?.length >= 15) {
                    this.template.querySelector(".tableDiv")?.classList?.add("scrollTable");
                }
            })
            .catch((err) => {
                this.nebulaLogger(err);
            });
    }

    nebulaLogger(incomingError) {
        const logger = this.template.querySelector("c-logger");
        if (!logger) return;
        logger.error(JSON.stringify(incomingError));
        logger.saveLog();
    }
}
