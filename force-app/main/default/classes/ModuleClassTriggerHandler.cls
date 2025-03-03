/**
 * Author:Jaren Yach
 *  Created Date 05/20/2022
 *  Purpose: Trigger handler class for ModuleClass__c
 */
public without sharing class ModuleClassTriggerHandler {
    /**
     * After Insert handler
     *
     * @param newList - List<ModuleClass__c
     * @param newMap Map<Id, ModuleClass__c>
     */
    public static void afterInsert(List<ModuleClass__c> newList, Map<Id, ModuleClass__c> newMap) {
        assignModules(newList);
    }

    /**
     * After Update handler
     *
     * @param newList - List<ModuleClass__c
     * @param oldList - List<ModuleClass__c
     * @param newMap - Map<Id, ModuleClass__c>
     * @param oldMap - Map<Id, ModuleClass__c>
     */
    public static void afterUpdate(List<ModuleClass__c> newList, List<ModuleClass__c> oldList, Map<Id, ModuleClass__c> newMap, Map<Id, ModuleClass__c> oldMap) {
        assignModules(newList);
    }

    /**
     * Assigns dtc module on Test_Run_Method_Result__c records that have the same apex class.
     *
     * @param newList - List<ModuleClass__c>
     */
    private static void assignModules(List<ModuleClass__c> newList) {
        Map<String, ModuleClass__c> classMap = new Map<String, ModuleClass__c>();
        for (ModuleClass__c mtc : newList) {
            classMap.put(mtc.Name.toLowerCase(), mtc);
        }

        List<Test_Run_Method_Result__c> testRunMethodResults = [
            SELECT Id, Apex_Class__c
            FROM Test_Run_Method_Result__c
            WHERE Apex_Class__c IN :classMap.keySet() AND DTCModule__c = NULL
        ];
        List<CodeCoverage__c> coverageRecs = [
            SELECT Id, ApexClassOrTriggerName__c
            FROM CodeCoverage__c
            WHERE ApexClassOrTriggerName__c IN :classMap.keySet() AND DTCModule__c = NULL
        ];

        List<SObject> updateList = new List<SObject>();
        for (Test_Run_Method_Result__c trmr : testRunMethodResults) {
            String key = trmr.Apex_Class__c?.toLowerCase();
            if (String.isNotBlank(key) && classMap.containsKey(key)) {
                trmr.DTCModule__c = classMap.get(key).DTCModule__c;
                updateList.add(trmr);
            }
        }

        for (CodeCoverage__c cc : coverageRecs) {
            String key = cc.ApexClassOrTriggerName__c?.toLowerCase();
            if (String.isNotBlank(key) && classMap.containsKey(key)) {
                cc.DTCModule__c = classMap.get(key).DTCModule__c;
                updateList.add(cc);
            }
        }

        if (updateList.size() > 0) {
            update updateList;
        }
    }
}
