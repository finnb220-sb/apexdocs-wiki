/* eslint-disable no-undef */
/**
 * Modified From Salesforce Labs - Open Source Project - https://github.com/SalesforceLabs/Home-Child-Kanban/
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 * @description       : Class used as a Helper for Kanban Board (Used for Case Types)
 * @author            : Edwin Schaeffer
 * @group             : Booz Allen
 * @last modified on  : 11-16-2023
 * @last modified by  : Blake Rowan
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   03-29-2023   Edwin Schaeffer                      Initial Version
 * 1.1   06-14-2023   Blake Rowan                          Adding in logic for a close modal, and moving update record to Helper
 * 1.2   06-14-2023   Blake Rowan                          Adds in support for new modal, and some spacing updates
 * 1.3   10-19-2023   Blake Rowan                          Adds a helper method to check if the user has the MP Custom Permission
 * 1.5   11-10-2023   Blake Rowan                          Efficiency updates to cut out unneeded variables and stop refresh if available cases page is unfocused
 * 1.5   11-16-2023   Blake Rowan                          Swaps out platform event subscription for a push topic subscription
 **/
({
    modalHelper: function (component, modal, backdrop, tf) {
        let mdl = component.find(modal).getElement();
        let bkdrp = component.find(backdrop).getElement();
        if (tf) {
            $A.util.addClass(mdl, 'slds-fade-in-open');
            $A.util.addClass(bkdrp, 'slds-backdrop_open');
            mdl.focus();
        } else {
            $A.util.removeClass(mdl, 'slds-fade-in-open');
            $A.util.removeClass(bkdrp, 'slds-backdrop_open');
        }
    },
    checkPermSet: function (component, userPermName, componentCheckName) {
        let action = component.get('c.checkCustomPermission');
        action.setParams({
            permName: userPermName
        });
        action.setCallback(this, function (res) {
            let errorCatch = false;
            let errors;
            try {
                if (res.getState() === 'SUCCESS') {
                    component.set(componentCheckName, res.getReturnValue());
                } else if (res.getState() === 'ERROR') {
                    errorCatch = true;
                    errors = res.getError();
                }
            } catch (error) {
                errorCatch = true;
            }

            if (errorCatch) {
                let errorMessage = 'An Unknown Error Occured';
                if (errors && errors[0] && errors[0].message) {
                    errorMessage = errors[0].message;
                }
                let toastEvent = $A.get('e.force:showToast');
                toastEvent.setParams({
                    title: 'Error',
                    type: 'error',
                    mode: 'sticky',
                    message: errorMessage
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    spinnerHelper: function (component, tf) {
        let spinner = component.find('spinner');
        if (tf) {
            $A.util.removeClass(spinner, 'slds-hide');
        } else {
            $A.util.addClass(spinner, 'slds-hide');
        }
    },
    subscribeToPlatformEvent: function (component) {
        let topic = '/topic/TeleECCaseStatusTopic';
        //console.log('channel: '+channel);
        const replayId = -1;

        const empApi = component.find('empApi');

        //A callback function that's invoked for every event received
        const ptCallback = function () {
            //console.log('topic callback case update');

            let workspaceAPI = component.find('workspace');
            if (
                !$A.util.isUndefinedOrNull(workspaceAPI) &&
                !$A.util.isUndefinedOrNull(workspaceAPI.getFocusedTabInfo())
            ) {
                workspaceAPI
                    .getFocusedTabInfo()
                    .then(function (response) {
                        //console.log('workspace: '+JSON.stringify(response));
                        //console.log('workspace url: '+response.url);
                        if (response.url === undefined) {
                            //console.log('Navigation page is focused');
                            $A.enqueueAction(component.get('c.handleRecordUpdated'));
                        } else {
                            //console.log('Navigation is not selected, not running update.');
                        }
                    })
                    .catch(function (error) {
                        console.log(error);
                    });
            } else {
                //console.log('Workspace or focused tab is undefined');
            }
        };

        empApi.subscribe(topic, replayId, ptCallback).then(function () {
            //console.log("Subscribed to topic: " + topic);
        });

        const errorHandler = function () {
            //console.error("Received error ", JSON.stringify(message));
        };

        //A callback function that's called when an error response is received from the server for the handshake, connect, subscribe, and unsubscribe meta channels.
        empApi.onError(errorHandler);
    },
    updateRecord: function (component, data) {
        if (data.from !== data.to) {
            //helper.spinnerHelper(component, true);
            let recFlds = component.get('v.record').fields;
            let recsMap = component.get('v.kwrap');
            let rec = recsMap.records[data.from][data.pos];
            let nameInToast;
            let simpleRecord = component.get('v.simpleRecord');
            if (!$A.util.isUndefinedOrNull(simpleRecord.Name_Field__c) && simpleRecord.Name_Field__c !== 'false') {
                if ($A.util.isUndefinedOrNull(rec[simpleRecord.Name_Field__c])) {
                    nameInToast = 'Case';
                } else {
                    nameInToast = rec[simpleRecord.Name_Field__c];
                }
            } else {
                nameInToast = 'Case';
            }
            let kfld = recFlds.Kanban_Group_By__c.value;
            //   ES - n/a for any Booz Allen scenario - yet - Left for future use case
            /*   let sfield = recFlds.Summarize_By__c.value;
                
                if(rec[sfield] && !isNaN(rec[sfield])){
                    let smap = recsMap.rollupData;
                    smap[data.from] = smap[data.from] - rec[sfield];
                    smap[data.to] = smap[data.to] + rec[sfield];
                    recsMap.rollupData = smap;
                } 
            */

            rec[kfld] = data.to;
            recsMap.records[data.to].unshift(rec);
            recsMap.records[data.from].splice(data.pos, 1);

            component.set('v.kwrap', recsMap);
            let toastEvent = $A.get('e.force:showToast');
            let action = component.get('c.updateRecord');
            action.setParams({
                recordId: rec.Id,
                recordField: kfld,
                recordValue: data.to
            });
            action.setCallback(this, function (res) {
                try {
                    //helper.spinnerHelper(component, false);
                    if (res.getState() === 'SUCCESS' && res.getReturnValue() === 'true') {
                        toastEvent.setParams({
                            title: 'Success!',
                            type: 'success',
                            mode: 'sticky',
                            message: nameInToast + ' moved to ' + data.to
                        });
                        toastEvent.fire();
                    } else {
                        let em = 'An Unknown Error Occured';
                        if (res.getState() === 'SUCCESS' && res.getReturnValue() !== 'true') {
                            em = res.getReturnValue();
                        } else if (res.getState() === 'ERROR') {
                            let errors = res.getError();
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    em = errors[0].message;
                                }
                            } else {
                                em = 'An Unknown Error Occured';
                            }
                        }
                        toastEvent.setParams({
                            title: 'Error',
                            type: 'error',
                            mode: 'sticky',
                            message: em
                        });
                        toastEvent.fire();
                        rec[kfld] = data.from;
                        recsMap.records[data.to].splice(0, 1);
                        recsMap.records[data.from].splice(data.pos, 0, rec);
                        component.set('v.kwrap', recsMap);
                    }
                } catch (error) {
                    console.log('catching error main helper updaterec');
                    console.error(error);
                }
            });
            $A.enqueueAction(action);
        }
    },
    updateRecordWField: function (component, data, field, value) {
        //console.log('field: '+field);
        //console.log('value: '+value);
        let recFlds = component.get('v.record').fields;
        let recsMap = component.get('v.kwrap');
        let rec = recsMap.records[data.from][data.pos];
        let kfld = recFlds.Kanban_Group_By__c.value;
        let action = component.get('c.updateRecord');
        action.setParams({
            recordId: rec.Id,
            recordField: field,
            recordValue: value
        });
        action.setCallback(this, function (res) {
            try {
                //helper.spinnerHelper(component, false);
                if (res.getState() === 'SUCCESS' && res.getReturnValue() === 'true') {
                    //console.log('success');
                } else {
                    /*
                    let em = 'An Unknown Error Occured';
                    if(res.getState() === 'SUCCESS' && res.getReturnValue() != 'true'){
                        em = res.getReturnValue();
                    }else if(res.getState() === 'ERROR'){
                        let errors = res.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                em = errors[0].message;
                            }
                        } else {
                            em = 'An Unknown Error Occured';
                        }
                    }
                    console.log('error: '+em);
                    */
                    rec[kfld] = data.from;
                    recsMap.records[data.to].splice(0, 1);
                    recsMap.records[data.from].splice(data.pos, 0, rec);
                    component.set('v.kwrap', recsMap);
                }
            } catch (error) {
                console.log('catching error main helper updaterec wField');
                console.error(error);
            }
        });
        $A.enqueueAction(action);
    },
    resetAttributes: function (component) {
        component.set('v.delInfo', null);
        component.set('v.hasDetail', false);
        component.set('v.modalButtonDisable', false);

        component.set('v.targetDelete', false);
        component.set('v.targetClose', false);

        component.set('v.readyForMpNurse', false);
        component.set('v.reassignToQueue', false);

        component.set('v.closeCaseFlowMP', false);
        component.set('v.closeCaseFlowRN', false);
    }
});
