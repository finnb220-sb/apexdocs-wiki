import { LightningElement, api } from "lwc";
// TODO: spinners
// import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from "@salesforce/apex";
import { updateRecord, deleteRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

//import getCallTrackingList from '@salesforce/apex/VCC_ProgressNoteController.getCallTrackingList'
// import PROGRESSNOTE_FIELD from '@salesforce/schema/VCC_Call_Tracking__c.VCC_Progress_Note__c';
import ID_FIELD from "@salesforce/schema/VCC_Call_Tracking__c.Id";
import CALLDATETIME_FIELD from "@salesforce/schema/VCC_Call_Tracking__c.VCC_Call_Date_Time__c";

// const actions = [
//     { label: 'Delete', name: 'delete' }
// ];

const columns = [
    {
        label: "Call Date/Time",
        fieldName: "VCC_Call_Date_Time__c",
        type: "date",
        typeAttributes: {
            year: "numeric",
            month: "long",
            day: "2-digit",
            hour: "2-digit",
            minute: "2-digit"
        },
        editable: true,
        hideDefaultActions: true,
        wrapText: true
    },
    // { type: 'action', typeAttributes: { rowActions: actions, menuAlignment: 'left' } }
    // { label: 'Name', fieldName: 'Name'},
    {
        type: "button-icon",
        fixedWidth: 40,
        typeAttributes: {
            iconName: "utility:delete",
            name: "delete",
            title: "Delete",
            alternativeText: "delete",
            iconClass: "slds-icon-text-error"
        }
    }
];

export default class VccProgressNoteCallTracking extends LightningElement {
    // fields = [PROGRESSNOTE_FIELD, CALLDATETIME_FIELD];
    callDateTimeField = CALLDATETIME_FIELD;

    // @api objectApiName = 'VCC_Call_Tracking__c';
    @api objectApiName = "VCC_Call_Tracking__c";
    // progress note record id
    // @api recordId = 'a1XBZ000000FlV32AK';
    @api recordId;
    callTrackingId;
    // call tracking records
    wiredRecords;
    data;
    columns = columns;
    draftValues = [];

    // @wire(getCallTrackingList, { recordId: '$recordId' }) wiredRecords({ error, data }) {
    //     if (data) {
    //         console.log('mgs data',data);
    //         this.records = data;
    //     } else if (error) {
    //         // TODO
    //         console.log('mgs error',error);
    //     }
    // }
    /*
    @wire(getCallTrackingList, { recordId: '$recordId' })
    wiredRecords( value ) {

        this.wiredRecords = value;
        const { data, error } = value;
        if (data) {
            console.log('mgs data',data);
            this.data = data;
        } else if (error) {
            console.log('mgs error',error);
        }
    }
    */

    // @wire(getCallTrackingList, { recordId: '$recordId' })
    // records;

    handleSubmit(event) {
        console.log("mgs handleSubmit event", event);
        event.preventDefault(); // stop the form from submitting
        // populate master-detail parent record automatically
        const fields = event.detail.fields;
        fields.VCC_Progress_Note__c = this.recordId;
        this.template.querySelector("lightning-record-edit-form").submit(fields);
    }

    handleSuccess(event) {
        this.callTrackingId = event.detail.id;
        console.log("mgs refreshing!!!!");
        refreshApex(this.wiredRecords);
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Success",
                message: "Record created successfully",
                variant: "success"
            })
        );
    }

    // Resetting the Form
    // handleReset(event) {
    //     const inputFields = this.template.querySelectorAll(
    //         'lightning-input-field'
    //     );
    //     if (inputFields) {
    //         inputFields.forEach(field => {
    //             field.reset();
    //         });
    //     }
    // }

    // delete row action
    handleRowAction(event) {
        // const action = event.detail.action;
        // console.log('mgs action',action);
        // const row = event.detail.row;
        // console.log('mgs row',row);
        // switch (action.name) {
        //     case 'delete':
        //         console.log('mgs delete switch');
        //         const rows =a;
        //         const rowIndex = rows.indexOf(row);
        //         rows.splice(rowIndex, 1);
        //         this.data = rows;
        //         break;
        // }
        console.log("mgs event.detail.action", event.detail.action);
        console.log("mgs event.detail.action.name", event.detail.action.name);
        console.log("mgs event.detail.row", event.detail.row);
        console.log("mgs event.detail.row.Id", event.detail.row.Id);

        if (event.detail.action.name === "delete") {
            console.log("mgs in the delete IFFFFF");

            let deleteId = event.detail.row.Id;
            console.log("mgs deleteId", deleteId);
            deleteRecord(deleteId)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message: "Record deleted successfully",
                            variant: "success"
                        })
                    );
                    // TODO refresh apex...
                    refreshApex(this.wiredRecords);

                    // // To delete the record from UI
                    // for(let opp in this.lstOppotunities){
                    //     if(this.lstOppotunities[opp].Id == deleteId){
                    //         this.lstOppotunities.splice(opp, 1);
                    //         break;
                    //     }
                    // }
                })
                .catch((error) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error handling the record",
                            message: error.body.message,
                            variant: "error"
                        })
                    );
                });
        }
    }

    // handle inline editing
    handleSave(event) {
        console.log("mgs handle Save!", event);
        console.log("mgs this.draftValues", this.draftValues);
        const fields = {};
        fields[ID_FIELD.fieldApiName] = event.detail.draftValues[0].Id;
        fields[CALLDATETIME_FIELD.fieldApiName] = event.detail.draftValues[0].VCC_Call_Date_Time__c;

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Call tracking updated",
                        variant: "success"
                    })
                );
                // Display fresh data in the datatable
                return refreshApex(this.wiredRecords).then(() => {
                    // Clear all draft values in the datatable
                    this.draftValues = [];
                });
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error updating or reloading record",
                        message: error.body.message,
                        variant: "error"
                    })
                );
            });
    }
}
