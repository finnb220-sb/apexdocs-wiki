/**
 * Author:Jaren Yach
 *  Created Date 05/20/2022
 *  Purpose: Trigger handler class for Test_Run_Method_Result__c
 */
public without sharing class TestRunMethodResultTriggerHandler {
    /**
     * Before Insert handler
     *
     * @param newList - List<Test_Run_Method_Result__c
     */
    public static void beforeInsert(List<Test_Run_Method_Result__c> newList) {
        assignDTCModule(newList);
    }

    /**
     * Assigns the dtc module to the Test_Run_Method_Result__c record.
     *
     * @param newList - List<Test_Run_Method_Result__c>
     */
    private static void assignDTCModule(List<Test_Run_Method_Result__c> newList) {
        Set<String> classNames = new Set<String>();
        for (Test_Run_Method_Result__c rec : newList) {
            classNames.add(rec.Apex_Class__c);
        }

        List<ModuleClass__c> classes = [SELECT Name, DTCModule__r.Name FROM ModuleClass__c WHERE Name IN :classNames];

        Map<String, ModuleClass__c> moduleClassMap = new Map<String, ModuleClass__c>();
        for (ModuleClass__c moduleTestClass : classes) {
            moduleClassMap.put(moduleTestClass.Name.toLowerCase(), moduleTestClass);
        }

        for (Test_Run_Method_Result__c rec : newList) {
            String key = rec.Apex_Class__c?.toLowerCase();
            if (String.isNotBlank(key) && moduleClassMap.containsKey(key)) {
                rec.DTCModule__c = moduleClassMap.get(key).DTCModule__r.Id;
            }
        }
    }
}
