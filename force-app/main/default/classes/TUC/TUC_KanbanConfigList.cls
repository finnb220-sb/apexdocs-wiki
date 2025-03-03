/**
 * Modified From Salesforce Labs - Open Source Project - https://github.com/SalesforceLabs/Home-Child-Kanban/
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 * @description       : Used in Conjunction with a Flexipage to easily configure the Kanban
 * @author            : Edwin Schaeffer
 * @group             : Booz Allen
 * @last modified on  : 03-29-2023
 * @last modified by  : Edwin Schaeffer
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   03-29-2023   Edwin Schaeffer                      Initial Version
 **/
global with sharing class TUC_KanbanConfigList extends VisualEditor.DynamicPickList {
    global override VisualEditor.DataRow getDefaultValue() {
        TUC_Kanban_Config__mdt klist = [SELECT Id, MasterLabel FROM TUC_Kanban_Config__mdt ORDER BY SystemModstamp DESC LIMIT 1][0];
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(string.valueOf(klist.MasterLabel), string.valueOf(klist.id));
        return defaultValue;
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        List<TUC_Kanban_Config__mdt> klist = [SELECT MasterLabel FROM TUC_Kanban_Config__mdt];
        VisualEditor.DynamicPickListRows myValues = new VisualEditor.DynamicPickListRows();
        for (TUC_Kanban_Config__mdt k : klist) {
            myValues.addRow(new VisualEditor.DataRow(string.valueOf(k.MasterLabel), string.valueOf(k.id)));
        }
        return myValues;
    }
}
