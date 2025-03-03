/**
 * @description Resides on the Lightning Record Page for Future Renewal Request Tasks:
 * 1. Displays the task info
 * 2. Allows Users to create Progress Notes from the task(TierI User -> TierI Note, TierII or III user -> TierI or TierII note )
 * 3. Calls VCC_TaskMedicationController to do the logic of creating a Progress Note
 * @author Booz Allen Hamilton
 */
import { LightningElement, wire, api } from 'lwc';
import RTModal from 'c/vccMedsTaskRenewalRecordTypeModal';
import { NavigationMixin } from 'lightning/navigation';
import getTableData from '@salesforce/apex/VCC_TaskMedicationController.getTableData';
import createProgressNoteFromTask from '@salesforce/apex/VCC_TaskMedicationController.createProgressNoteFromTask';
import checkCaseForUnsignedPNs from '@salesforce/apex/VCC_TaskMedicationController.checkCaseForUnsignedPNs';
import { columns, fullColumns, preTextHeader } from './constants';
import currentUserId from '@salesforce/user/Id';
import { subscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import vccUIUpdate from '@salesforce/messageChannel/vccUIUpdate__c';
import hasPharmTierII from '@salesforce/customPermission/VCC_Pharmacy_Tier_II';
import hasPharmTierIII from '@salesforce/customPermission/VCC_Pharmacy_Tier_III';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class VccMedsTaskRenewalList extends NavigationMixin(LightningElement) {
    @api recordId;

    columns = columns;
    deactivateButton = true; //? own the task & task is open
    displaySpinner = false;
    noRecords = false;
    data;
    _originalDescription;
    selectedRows;
    simplifiedSelectedRows = [];
    caseId;
    keyField = 'medication';
    rtRadioValue = 'VCC_Tier_I_Progress_Note';
    rtId = '';

    labels = {
        noResultsMessage: 'No Medications for Renewal found on this Task'
    };

    subscription = null;
    @wire(MessageContext)
    messageContext;

    getTaskInfo(record) {
        getTableData({ recId: record })
            .then((data) => {
                this.caseId = data[0].WhatId;
                //? check the current user owns this task & the Task Status is Open
                if (data[0].OwnerId === currentUserId && data[0].Status === 'Open') {
                    this.deactivateButton = false;
                } else {
                    this.deactivateButton = true;
                }

                if (!data[0]?.Description) return;
                if (!this.isJsonString(data[0]?.Description)) {
                    this.noRecords = true;
                    return;
                }
                let tempData = JSON.parse(data[0]?.Description);
                this._originalDescription = tempData;
                let tempList = [];
                //? handle which state the description is in (Array of meds or Object with or without a meds & selectedRows)
                let tempArrayOfMeds = tempData?.meds ? tempData.meds : tempData;
                tempArrayOfMeds.forEach((row) => {
                    let tempObj = {};
                    tempObj.medication = this.convertJSONtoAddToNoteStyleString(row);
                    tempObj.fullData = row;
                    tempList.push(tempObj);
                });
                //? if completed then the description will have selectedRows. Populate those and deactivate the checkboxes
                this.isCompleted = data[0].Status === 'Completed';
                if (this.isCompleted) {
                    this.simplifiedSelectedRows = tempData?.selectedRows;
                }
                this.data = tempList;
            })
            .catch((error) => {
                this.nebulaLogger(error);
                this.data = undefined;
            });
    }

    connectedCallback() {
        this.getTaskInfo(this.recordId);
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                vccUIUpdate,
                (message) => {
                    if (message.recordId === this.recordId) {
                        this.getTaskInfo(this.recordId);
                    }
                },
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    simplifySelectedRows(arr) {
        return arr.map((row) => row[this.keyField]);
    }

    isJsonString(str) {
        try {
            JSON.parse(str);
        } catch (e) {
            return false;
        }
        return true;
    }

    handleRowSelection(event) {
        if (this.isCompleted) {
            //? don't allow table clicks
            this.template.querySelector('lightning-datatable').selectedRows = this.simplifiedSelectedRows;
        } else {
            let tempArr = event.detail.selectedRows;
            this.selectedRows = tempArr;
            this.simplifiedSelectedRows = this.simplifySelectedRows(tempArr);
        }
    }

    async handleClick() {
        if (this.selectedRows?.length === 0 || !this.selectedRows) {
            this.showToast(
                'Error',
                'Please select medications to create a progress note, or mark the task as No Longer Needed if applicable.',
                'error',
                'sticky'
            );
            return;
        }

        //TODO throw error if all progress notes on case are signed before creating a new one.
        let hasUnsignedProgressNotes = await checkCaseForUnsignedPNs({ caseId: this.caseId });
        if (hasUnsignedProgressNotes) {
            let url = await this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.caseId,
                    objectApiName: 'Case',
                    actionName: 'view'
                }
            });
            this.showToast(
                'Error',
                'Please ensure all progress notes on {0} {1} are signed before creating a new one.',
                'error',
                'sticky',
                ['Case', { url, label: this.caseId }]
            );
            return;
        }
        /** this block checks if a user has TierII or TierIII pharm permissions
         * if they do it opens a modal allowing them to select what Tier of Progress Note to create
         * this modal captures their selection, which is passed to the apex controller further down the chain
         * if the user does not have the required permissions, a TierI note is created by default
         */
        if (hasPharmTierII || hasPharmTierIII) {
            await RTModal.open({
                headerLabel: 'New Progress Note',
                size: 'small'
            }).then((result) => {
                this.rtRadioValue = result;
            });
        }
        if (this.rtRadioValue === undefined) {
            return;
        }
        this.displaySpinner = true;
        // call Apex to create PN
        try {
            let response = await this.createProgressNote(this.selectedRows);
            //? await response
            if (response) {
                let url = await this[NavigationMixin.GenerateUrl]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: response.Id,
                        objectApiName: 'VCC_Progress_Note__c',
                        actionName: 'view'
                    }
                });
                const lmsPublisher = this.template.querySelector('c-vcc-l-m-s-publisher');
                const message = { recordId: this.recordId, componentName: 'auraRefreshComponent' };
                lmsPublisher.publishMessage('vccUIUpdate', message);
                const message2 = { recordId: this.recordId, componentName: 'vccTaskRelated' };
                lmsPublisher.publishMessage('vccUIUpdate', message2);
                this.showToast(
                    'Success',
                    'Progress Note Successfully created, click {0} to view',
                    'success',
                    'sticky',
                    [{ url, label: 'here' }]
                );
            }
        } catch (err) {
            this.nebulaLogger(err);
            this.showToast('Error!', 'An unexpected error has occurred.', 'error', 'sticky');
        }
        //? reset values
        this.deactivateButton = true;
        this.displaySpinner = false;
    }

    nebulaLogger(incomingError) {
        const logger = this.template.querySelector('c-logger');
        if (!logger) return;
        logger.error(JSON.stringify(incomingError));
        logger.saveLog();
    }

    async createProgressNote(selectedRows) {
        let dashIndex = selectedRows[0]?.fullData?.facilityName.indexOf('-');
        let pnFacility = selectedRows[0]?.fullData?.facilityName.substring(dashIndex + 2).slice(0, 3);

        //? check for controlled values
        let medIsControlledList = [];
        selectedRows.forEach((row) => {
            medIsControlledList.push(row.fullData.csSchedule !== 1 && row.fullData.csSchedule !== '');
        });
        let containsControlled = medIsControlledList.includes(true);
        let containsNonControlled = medIsControlledList.includes(false);
        let newDescription = this.buildNewDescription();
        let pnString = this.createPNText(preTextHeader, selectedRows);
        //pass in a map instead of 7 params
        const inputMap = {
            pnString: pnString,
            controlled: containsControlled,
            nonControlled: containsNonControlled,
            recordId: this.recordId,
            newDescription: newDescription,
            facilityName: pnFacility,
            recordTypeName: this.rtRadioValue
        };
        let response = await createProgressNoteFromTask({
            paramsFromLWC: inputMap
        });
        return response;
    }

    buildNewDescription() {
        let obj = {};
        obj.meds = this._originalDescription;
        obj.selectedRows = this.simplifiedSelectedRows;
        return JSON.stringify(obj);
    }

    createPNText(header, array) {
        let result = array
            .map((row) => {
                return row.medication + '\n';
            })
            .join(' \n');
        return header + result;
    }

    // //? need preTextHeader
    // //TODO get it from workstreamsettings???
    // let preTextHeader = "Rx # - Medication Name - Fill Qty - Last Fill Date - Refills Remaining - Expiration Date - SIG - Provider Comments - Facility - Status - Indication \n";

    convertJSONtoAddToNoteStyleString(object) {
        //? iterate over the object and spit out the values with " - " between them
        let valueStringPart = fullColumns
            .map((col) => {
                for (let keys in object) {
                    if (Object.hasOwn(object, keys)) {
                        let fieldToCheck = col.fieldName;
                        if (fieldToCheck === keys) {
                            return object[keys] === undefined ? '' : object[keys];
                        }
                    }
                }
                return '';
            })
            .join(' - ');

        //? {medication: "medication as a string"}

        return valueStringPart;
    }

    showToast(title, message, variant, mode, messageData = []) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode,
            messageData: messageData
        });
        this.dispatchEvent(event);
    }
}
