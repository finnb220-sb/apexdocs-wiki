/* eslint-disable no-undef */
/* eslint-disable no-unused-vars */
/**
 * Modified From Salesforce Labs - Open Source Project - https://github.com/SalesforceLabs/Home-Child-Kanban/
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 * @description       : Controller Class for individual cards on the Kanban
 * @author            : Edwin Schaeffer
 * @group             : Booz Allen
 * @last modified on  : 03-29-2023
 * @last modified by  : Edwin Schaeffer
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   03-29-2023   Edwin Schaeffer                      Initial Version
 **/

({
    doInit: function (component, event, helper) {
        let lst = [];
        let rec = component.get('v.rec');
        let picklistVal = component.get('v.pval');
        let fieldList = component.get('v.fieldList').split(';');
        let fieldMap = component.get('v.fieldTypeMap');
        let objName = component.get('v.objName');

        let kwrap = component.get('v.kwrap');
        let statusList = kwrap.pickVals;
        let statusVals = [];
        for (let i = 0; i < statusList.length; i++) {
            let status = statusList[i];
            if (status !== component.get('v.currentStatus')) {
                let statusItem = {
                    label: status.replace('TED ', ''),
                    value: status
                };
                statusVals.push(statusItem);
            }
        }
        component.set('v.statusOptions', statusVals);
        for (let i = 0; i < fieldList.length; i++) {
            let key = fieldList[i];
            if (key !== 'Id' && key !== picklistVal) {
                let currentFieldMap = fieldMap[key];
                let currentFieldType = currentFieldMap.type;
                let currentValue = rec[key];
                if (!$A.util.isUndefinedOrNull(currentValue)) {
                    if (currentFieldType === 'REFERENCE') {
                        let relInfo = currentFieldMap.relationName.split('~*!');
                        let val = rec[relInfo[0]].Id;
                        let objpushName = relInfo[0].replace('__r', '__c');
                        if (val.startsWith('00G')) {
                            val = rec.Id;
                            objpushName = objName;
                        }
                        lst.push({ objName: objpushName, label: rec[relInfo[0]][relInfo[1]], val: val });
                    } else if (currentFieldType === 'CURRENCY') {
                        lst.push({
                            objName: objName,
                            label: $A.localizationService.getDefaultCurrencyFormat().format(currentValue),
                            val: rec.Id
                        });
                    } else if (currentFieldType === 'PERCENT') {
                        lst.push({ objName: objName, label: currentValue + '%', val: rec.Id });
                    } else if (currentFieldType === 'DATE') {
                        lst.push({
                            objName: objName,
                            label: $A.localizationService.formatDate(currentValue),
                            val: rec.Id
                        });
                    } else if (currentFieldType === 'DATETIME') {
                        lst.push({
                            objName: objName,
                            label: $A.localizationService.formatDate(currentValue, 'MMM DD YYYY, hh:mm a'),
                            val: rec.Id
                        });
                    } else if (currentFieldType === 'BOOLEAN') {
                        lst.push({ objName: objName, label: currentValue ? 'Yes' : 'No', val: rec.Id });
                    } else if (currentFieldType === 'DOUBLE') {
                        lst.push({ objName: objName, label: currentValue.toString(), val: rec.Id });
                    } else {
                        lst.push({ objName: objName, label: currentValue, val: rec.Id });
                    }
                }

                if (key === 'Name' || key === 'CaseNumber') {
                    component.set('v.namePos', i);
                }
            }
        }
        component.set('v.dList', lst);
    },

    handleLink: function (component, event, helper) {
        //initialize the service components
        let workspaceAPI = component.find('workspace');
        let navService = component.find('navService');
        let recId = event.currentTarget.dataset.value;
        let objName = event.currentTarget.dataset.objName;

        // set the pageReference object used to navigate to the component. Include any parameters in the state key.
        let pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: recId,
                objectApiName: objName,
                actionName: 'view'
            }
        };

        // handles checking for console and standard navigation and then navigating to the component appropriately
        workspaceAPI
            .isConsoleNavigation()
            .then(function (isConsole) {
                if (isConsole) {
                    workspaceAPI.openTab({
                        pageReference: pageReference,
                        focus: true
                    });
                } else {
                    navService.navigate(pageReference, false);
                }
            })
            .catch(function (error) {
                console.log(error);
            });
    },
    handleShowPopover: function (cmp, event, helper) {
        let recordId = event.currentTarget.dataset.value;
        let objName = event.currentTarget.dataset.objname;
        cmp.set('v.recordName', event.currentTarget.dataset.label);
        let currentTimer = cmp.get('v.timer');
        if (currentTimer) {
            window.clearTimeout(currentTimer);
            cmp.set('v.timer', null);
        }
        if (cmp.get('v.showPop')) {
            cmp.set('v.showPop', false);
        }
        //justification - legacy code, opens a popup modal based on card highlight
        // eslint-disable-next-line
        let timer = window.setTimeout(
            $A.getCallback(function () {
                try {
                    // ES - Popovers limited to just Case types for now
                    if (objName !== 'Case') {
                        return;
                    }
                    let action = cmp.get('c.loadRecord');
                    action.setParams({ recordId: recordId });
                    action.setCallback(this, function (response) {
                        let data = response.getReturnValue(),
                            values = [];
                        for (let i = 0; i < data.fields.length; i++) {
                            if (data.fields[i].apiName === 'CaseNumber') {
                                cmp.set('v.recordName', data.fields[i].label);
                                cmp.set('v.recordNameVal', data.fields[i].value);
                            } else if (data.fields[i].apiName !== 'Id') {
                                if (data.fields[i].apiName === 'TED_Birthdate__c') {
                                    let dateVal = data.fields[i].value;
                                    values.push({
                                        label: data.fields[i].label,
                                        value: new Date(dateVal).toLocaleDateString()
                                    });
                                } else {
                                    values.push({ label: data.fields[i].label, value: data.fields[i].value });
                                }
                            }
                        }

                        cmp.set('v.values', values);
                        cmp.set('v.objectName', data.objectName.toLowerCase());
                        cmp.set('v.isLoading', false);
                        cmp.set('v.showPop', true);
                    });
                    $A.enqueueAction(action);
                } catch (error) {
                    console.log('catching error crd controller');
                    console.error(error);
                }
            }),
            300
        );
        cmp.set('v.timer', timer);
    },
    handleMouseLeaveOrBlurElement: function (cmp, event, helper) {
        window.clearTimeout(cmp.get('v.timer'));
        cmp.set('v.timer', null);
    },
    closeDialog: function (cmp, event, helper) {
        cmp.set('v.showPop', false);
    },
    navToRec: function (component, event, helper) {
        let recId = event.target.id;
        if (recId && recId !== '') {
            let navEvt = $A.get('e.force:navigateToSObject');
            navEvt.setParams({
                recordId: recId
            });
            navEvt.fire();
        }
    },
    recActionSelected: function (component, event, helper) {
        let value = event.getParam('value');
        let eventId = event.getSource().get('v.value');

        if (value === 'Edit') {
            let editRecordEvent = $A.get('e.force:editRecord');
            editRecordEvent.setParams({
                recordId: eventId
            });
            editRecordEvent.fire();
        } else if (value === 'Delete') {
            let dObj = {};
            dObj.from = component.get('v.rec')[component.get('v.pval')];
            dObj.pos = parseInt(component.get('v.recPos'), 10);
            let kcevt = component.getEvent('kanbanChildDelReq');
            kcevt.setParams({
                KanbanChildDelete: dObj
            });
            kcevt.fire();
        } else if (value === 'MoveTo') {
            component.set('v.showModal', true);
            // eslint-disable-next-line
            setTimeout(
                $A.getCallback(() => {
                    helper.modalHelper(component, 'moveToModal', 'modalBkdrp', true);
                })
            );
        }
    },
    closeModal: function (component, event, helper) {
        component.set('v.showModal', false);
        // eslint-disable-next-line
        setTimeout(
            $A.getCallback(() => {
                helper.modalHelper(component, 'moveToModal', 'modalBkdrp', false);
            })
        );
        helper.resetAttributes(component);
    },
    handleStatus: function (component, event, helper) {
        // This will contain the string of the "value" attribute of the selected option
        let selectedOptionValue = event.getParam('value');
        component.set('v.statusSelected', selectedOptionValue);
        component.set('v.modalButtonDisable', false);
    },
    confirmModal: function (component, event, helper) {
        let currentStatus = component.get('v.currentStatus');
        let targetStatus = component.get('v.statusSelected');

        let data = { from: currentStatus, pos: parseInt(component.get('v.recPos'), 10), to: targetStatus };

        let kcevt = component.getEvent('kanbanChildChanged');
        kcevt.setParams({
            KanbanChildChange: data
        });
        helper.modalHelper(component, 'moveToModal', 'modalBkdrp', false);
        helper.resetAttributes(component);
        kcevt.fire();
    }
});
