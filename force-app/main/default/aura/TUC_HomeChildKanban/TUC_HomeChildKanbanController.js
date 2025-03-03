/* eslint-disable no-undef */
/* eslint-disable no-unused-vars */
/**
 * Modified From Salesforce Labs - Open Source Project - https://github.com/SalesforceLabs/Home-Child-Kanban/
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 * @description       : Class used as a controller for Kanban Board (Use Case so far is only far Case)
 * @author            : Edwin Schaeffer
 * @group             : Booz Allen
 * @last modified on  : 11-10-2023
 * @last modified by  : Blake Rowan
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   03-29-2023   Edwin Schaeffer                      Initial Version
 * 1.1   06-14-2023   Blake Rowan                          Adding in logic for a close modal, and moving update record to Helper
 * 1.2   07-28-2023   Blake Rowan                          Adds in logic gates for status changes, and adds in specific actions for some actions
 * 1.3   10-16-2023   Blake Rowan                          Changes out the status filter from an exclude line to an include line to give proper ordering on the columns
 * 1.4   10-19-2023   Blake Rowan                          Adding Logic to check for MP Custom Permissions and disable MP Encounter for non-MP
 * 1.5   11-10-2023   Blake Rowan                          Efficiency updates to cut out unneeded variables
 **/

({
    doInit: function (component, event, helper) {
        let kanbanConfigId = component.get('v.kanbanConfigId');
        let action = component.get('c.getKanbanConfig');
        action.setCallback(this, function (res) {
            if (res.getState() === 'SUCCESS') {
                let returnVal = res.getReturnValue();
                if (!kanbanConfigId) {
                    let obj = returnVal;
                    component.set('v.simpleRecord', obj);
                    let record = {};
                    let fields = {};
                    for (const key of Object.keys(obj)) {
                        fields[key] = { value: obj[key] };
                    }
                    record.fields = fields;
                    component.set('v.record', record);
                }
                const logger = component.find('logger');
                try {
                    $A.enqueueAction(component.get('c.handleGetVISNFilter'));
                } catch (error) {
                    logger.error(error).addTag('Kanban Controller doInit');
                    logger.error(kanbanConfigId).addTag('Kanban Config Id');
                } finally {
                    logger.saveLog();
                }
            }
        });
        $A.enqueueAction(action);
        helper.subscribeToPlatformEvent(component);
        helper.checkPermSet(component, 'Tele_EC_TCT_User', 'v.tctPermCheck');
        helper.checkPermSet(component, 'TED_Medical_Provider', 'v.doctorPermCheck');
    },

    /**
     * @description - Retrieves the VISN filter for the user and stores it in a component variable
     * @param component - The component for the Aura
     * @param event - The event passed in (if needed)
     * @param helper - The helper javascript class (if needed)
     **/
    handleGetVISNFilter: function (component, event, helper) {
        let action = component.get('c.getVISNFilter');
        action.setCallback(this, function (res) {
            if (res.getState() === 'SUCCESS') {
                let returnVal = res.getReturnValue();
                component.find('iptVISN').set('v.value', returnVal);
                const logger = component.find('logger');
                try {
                    $A.enqueueAction(component.get('c.handleRecordUpdated'));
                } catch (error) {
                    logger.error(error).addTag('Kanban Controller handleGetVISNFilter');
                    logger.saveLog();
                }
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * @description - This method is the main class that gathers up VISN data, and kicks off the getKanban in the Apex controller class
     *                to fill out case data on the Kanban UI. called in the init processes and the refresh processes.
     * @param component - The component for the Aura
     * @param event - The event passed in (if needed)
     * @param helper - The helper javascript class (if needed)
     **/
    handleRecordUpdated: function (component, event, helper) {
        component.set('v.isLoading', true);
        let currentRec = component.get('v.record');
        if (event && event.getParams().changeType === 'LOADED') {
            return;
        }
        if (!$A.util.isUndefinedOrNull(currentRec)) {
            let recFlds = currentRec.fields;
            let VISNfilterVal = '';
            if (recFlds.Home_Object_Name__c.value === 'Case') {
                let visnVal = component.find('iptVISN').get('v.value');

                if (visnVal.includes(',')) {
                    VISNfilterVal = visnVal.split(',');
                } else {
                    VISNfilterVal = visnVal;
                }
            }
            if (event) {
                let evtSrc = event.getSource();
                if (evtSrc.getLocalId() === 'refreshButton') {
                    helper.spinnerHelper(component, true);
                    $A.util.addClass(evtSrc, 'refreshSpin');
                    window.setTimeout(
                        $A.getCallback(function () {
                            const logger = component.find('logger');
                            try {
                                $A.util.removeClass(evtSrc, 'refreshSpin');
                            } catch (error) {
                                logger.error(error).addTag('Kanban Controller handleRecordUpdated');
                            } finally {
                                logger.saveLog();
                            }
                        }),
                        400
                    );
                }
            }
            let objName = recFlds.Home_Object_Name__c.value;
            let objFields = recFlds.Fields_To_Display_on_Card__c.value;
            let kanbanPicklistField = recFlds.Kanban_Group_By__c.value;
            let IncVal = recFlds.Values_To_Include_for_Group_By__c.value;
            let IncFVal = IncVal ? IncVal.split(';') : '';
            if (IncFVal !== '') {
                for (let i = 0; i < IncFVal.length; i++) {
                    IncFVal[i] = IncFVal[i].trim();
                }
            }
            if (objName && objFields && kanbanPicklistField) {
                let action = component.get('c.getKanban');
                action.setParams({
                    visnFilterValues: VISNfilterVal
                });
                action.setCallback(this, function (resp) {
                    helper.spinnerHelper(component, false);
                    if (resp.getState() === 'SUCCESS') {
                        let rVal = resp.getReturnValue();
                        component.set('v.isSuccess', rVal.isSuccess);
                        component.set('v.isLoading', false);
                        if (rVal.isSuccess) {
                            for (let i = 0; i < rVal.records.length; i++) {
                                rVal.records[i].kanbanfield = rVal.records[i][kanbanPicklistField];
                            }
                            component.set('v.kwrap', rVal);
                        } else {
                            component.set('v.errorMessage', rVal.errorMessage);
                        }
                    } else {
                        component.set('v.isLoading', false);
                    }
                });
                $A.enqueueAction(action);
            }
        }
    },
    childChanged: function (component, event, helper) {
        helper.modalHelper(component, 'flowModal', 'modalBkdrp', false);
        let data = event.getParam('KanbanChildChange');
        if (data.to !== data.from) {
            component.set('v.dataTo', data);
            component.set('v.modalButtonDisable', false);
            let keyword = 'Update';
            if (data.to === component.get('v.statusClose')) {
                component.set('v.targetClose', true);
                keyword = 'Close';
            }
            component.set('v.modalTitle', keyword + ' Record');
            component.set('v.modalMessage', 'Are you sure you want to ' + keyword + ' this record?');
            component.set('v.modalButtonLabel', keyword);

            helper.modalHelper(component, 'genModal', 'modalBkdrp', true);
        }
    },
    childDelete: function (component, event, helper) {
        let data = event.getParam('KanbanChildDelete');
        component.set('v.delInfo', data);
        component.set('v.modalTitle', 'Delete Record');
        component.set('v.modalMessage', 'Are you sure you want to delete this record?');
        component.set('v.modalButtonLabel', 'Delete');
        component.set('v.targetDelete', true);
        component.set('v.modalButtonDisable', false);

        helper.modalHelper(component, 'genModal', 'modalBkdrp', true);
    },

    /**
     * @description - Starts a delete action against the target record
     * @param component - The component for the Aura
     * @param event - The event passed in (if needed)
     * @param helper - The helper javascript class (if needed)
     **/
    deleteTargetRecord: function (component, event, helper) {
        helper.modalHelper(component, 'genModal', 'modalBkdrp', false);
        helper.spinnerHelper(component, true);
        let data = component.get('v.delInfo');
        let recsMap = component.get('v.kwrap');
        let rec = recsMap.records[data.from][data.pos];
        let action = component.get('c.deleteRecord');
        action.setParams({
            deleteTarget: rec
        });
        action.setCallback(this, function (res) {
            helper.spinnerHelper(component, false);

            //add a return check to see if the error message is returned and if the toast message should reflect securities

            let state = res.getState();
            let toastEvent = $A.get('e.force:showToast');
            if (state === 'SUCCESS') {
                recsMap.records[data.from].splice(data.pos, 1);
                toastEvent.setParams({
                    title: 'Success',
                    type: 'success',
                    mode: 'sticky',
                    message: 'The record has been delete successfully.'
                });
                toastEvent.fire();
                component.set('v.kwrap', recsMap);
            } else if (state === 'ERROR') {
                let errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        em = errors[0].message;
                    }
                } else {
                    em = 'An Unknown Error Occured';
                }
                toastEvent.setParams({
                    title: 'Error',
                    type: 'error',
                    mode: 'sticky',
                    message: em
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        helper.resetAttributes(component);
    },
    closeModal: function (component, event, helper) {
        helper.modalHelper(component, 'genModal', 'modalBkdrp', false);
        helper.modalHelper(component, 'flowModal', 'modalBkdrp', false);
        helper.resetAttributes(component);
    },
    initiateNewRecordCreation: function (component, event, helper) {
        let recordId = component.get('v.recordId');
        if ($A.util.isUndefinedOrNull(recordId)) {
            let simpleRecord = component.get('v.simpleRecord');
            let createRecordEvent = $A.get('e.force:createRecord');
            createRecordEvent.setParams({
                entityApiName: simpleRecord.For_Object__c
            });
            createRecordEvent.fire();
        } else {
            let simpleRecord = component.get('v.simpleRecord');
            let createRecordEvent = $A.get('e.force:createRecord');
            let recObj = {};
            recObj[simpleRecord.Relation_Field__c] = recordId;
            createRecordEvent.setParams({
                entityApiName: simpleRecord.Child_Object__c,
                defaultFieldValues: recObj
            });
            createRecordEvent.fire();
        }
    },
    confirmModal: function (component, event, helper) {
        let data = component.get('v.dataTo');
        let runFlow = false;
        if (component.get('v.targetDelete')) {
            $A.enqueueAction(component.get('c.deleteTargetRecord'));
        } else {
            if (data.to === component.get('v.statusReadyForMP')) {
                if (component.get('v.tctPermCheck')) {
                    if (data.from === component.get('v.statusCallback') || data.from === component.get('v.statusNew')) {
                        component.set('v.readyForMpNurse', true);
                        runFlow = true;
                    }
                } else {
                    if (data.from === component.get('v.statusNurseEncounter')) {
                        component.set('v.readyForMpNurse', true);
                        runFlow = true;
                    } else if (data.from === component.get('v.statusMPEncounter')) {
                        component.set('v.reassignToQueue', true);
                        runFlow = true;
                    }
                }
            } else if (
                component.get('v.tctPermCheck') &&
                (data.to === component.get('v.statusMPEncounter') ||
                    data.to === component.get('v.statusNurseEncounter') ||
                    data.to === component.get('v.statusNew'))
            ) {
                runFlow = false;
                $A.enqueueAction(component.get('c.updateStatus'));
            } else if (data.to === component.get('v.statusNew') || data.to === component.get('v.statusCallback')) {
                component.set('v.reassignToQueue', true);
                runFlow = true;
            } else if (component.get('v.targetClose')) {
                if (component.get('v.doctorPermCheck')) {
                    component.set('v.closeCaseFlowMP', true);
                    runFlow = true;
                } else if (component.get('v.tctPermCheck')) {
                    runFlow = false;
                    $A.enqueueAction(component.get('c.updateStatus'));
                } else {
                    component.set('v.closeCaseFlowRN', true);
                    runFlow = true;
                }
            }

            if (runFlow) {
                let recsMap = component.get('v.kwrap');
                let rec = recsMap.records[data.from][data.pos];
                helper.modalHelper(component, 'genModal', 'modalBkdrp', false);
                helper.modalHelper(component, 'flowModal', 'modalBkdrp', true);

                if (component.get('v.readyForMpNurse')) {
                    let flow = component.find('readyForMpFlow');
                    let inputVariables = [
                        {
                            name: 'recordId',
                            type: 'String',
                            value: rec.Id
                        }
                    ];
                    flow.startFlow('TED_Ready_for_Consultation', inputVariables);
                } else if (component.get('v.reassignToQueue')) {
                    let flow = component.find('reassignToQueueFlow');
                    let inputVariables = [
                        {
                            name: 'recordId',
                            type: 'String',
                            value: rec.Id
                        },
                        {
                            name: 'destinationStatus',
                            type: 'String',
                            value: data.to
                        }
                    ];
                    flow.startFlow('TED_Re_Assign_to_Queue', inputVariables);
                } else if (component.get('v.closeCaseFlowMP')) {
                    let flow = component.find('closeCaseFlowAsMP');
                    let inputVariables = [
                        {
                            name: 'recordId',
                            type: 'String',
                            value: rec.Id
                        }
                    ];
                    flow.startFlow('TED_Close_Tele_EC_Case_MP', inputVariables);
                } else if (component.get('v.closeCaseFlowRN')) {
                    let flow = component.find('closeCaseFlowAsRN');
                    let inputVariables = [
                        {
                            name: 'recordId',
                            type: 'String',
                            value: rec.Id
                        }
                    ];
                    flow.startFlow('TED_Close_Tele_EC_Case_RN', inputVariables);
                }
            } else {
                $A.enqueueAction(component.get('c.updateStatus'));
            }
        }
    },
    flowChange: function (component, event, helper) {
        if (event.getParam('status') === 'FINISHED') {
            helper.modalHelper(component, 'flowModal', 'modalBkdrp', false);
            helper.resetAttributes(component);
            //$A.enqueueAction(component.get('c.updateStatus'));
        }
    },
    updateStatus: function (component, event, helper) {
        let data = component.get('v.dataTo');
        helper.modalHelper(component, 'genModal', 'modalBkdrp', false);

        //owner check first
        let updateOwner = false;
        let doctorBreak = false;
        let tctBreak = false;

        if (
            component.get('v.tctPermCheck') &&
            (data.to !== component.get('v.statusCallback') || data.to !== component.get('v.statusReadyForMP'))
        ) {
            tctBreak = true;
        } else {
            if (data.to === component.get('v.statusMPEncounter')) {
                if (component.get('v.doctorPermCheck')) {
                    if (
                        data.from === component.get('v.statusNew') ||
                        data.from === component.get('v.statusReadyForMP')
                    ) {
                        updateOwner = true;
                    }
                } else {
                    doctorBreak = true;
                }
            }
            if (data.to === component.get('v.statusNurseEncounter')) {
                if (data.from === component.get('v.statusNew')) {
                    updateOwner = true;
                }
            }
        }

        if (doctorBreak || tctBreak) {
            component.set('v.modalTitle', 'Insufficient Permissions');
            component.set('v.modalMessage', 'You do not have permission to update to ' + data.to);
            component.set('v.modalButtonLabel', 'Close');
            component.set('v.modalButtonDisable', true);

            helper.modalHelper(component, 'genModal', 'modalBkdrp', true);
        } else {
            if (updateOwner) {
                let userId = $A.get('$SObjectType.CurrentUser.Id');
                helper.updateRecordWField(component, data, 'OwnerId', userId);
            }
            helper.updateRecord(component, data);
            helper.resetAttributes(component);
        }
    }
});
