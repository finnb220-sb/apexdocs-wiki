/* eslint-disable no-unused-vars */
/**
 * Modified From Salesforce Labs - Open Source Project - https://github.com/SalesforceLabs/Home-Child-Kanban/
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 * @description       : Class used as a controller for Columns in the Kanban Board (Used for Case Types)
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
        let pickVal = component.get("v.pickvalue");
        component.set("v.recs", component.get("v.recsMap")[pickVal]);
        component.set("v.colLabel", pickVal.replace("TED ", ""));
    },
    allowDrop: function (component, event, helper) {
        event.preventDefault();
    },
    drag: function (component, event, helper) {
        var co = { from: event.currentTarget.parentElement.getAttribute("data-Pick-Val"), pos: event.currentTarget.value };
        event.dataTransfer.setData("text", JSON.stringify(co));
    },
    drop: function (component, event, helper) {
        event.preventDefault();
        var data = JSON.parse(event.dataTransfer.getData("text"));
        data.to = event.currentTarget.getAttribute("data-Pick-Val");
        component.set("v.goingTo", event.currentTarget.getAttribute("data-Pick-Val"));

        var kcevt = component.getEvent("kanbanChildChanged");
        kcevt.setParams({
            KanbanChildChange: data
        });
        kcevt.fire();

        var ulEle = component.find("hckCol").getElement();
        if (!ulEle.scrollTop == 0) ulEle.scrollTop = 0;
    },
    recordsChanged: function (component, event, helper) {
        component.set("v.recs", component.get("v.recsMap")[component.get("v.pickvalue")]);
        helper.countUpHelper(component);
    },
    sLoaded: function (component, event, helper) {
        helper.countUpHelper(component);
    }
});
