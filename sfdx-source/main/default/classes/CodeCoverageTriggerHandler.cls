/**
 * Author:Jaren Yach
 *  Created Date 05/27/2022
 *  Purpose: Trigger handler class for CodeCoverage__c
 */
public without sharing class CodeCoverageTriggerHandler {
    /**
     * Before Insert handler
     *
     * @param newList - List<CodeCoverage__c
     */
    public static void beforeInsert(List<CodeCoverage__c> newList) {
        assignDTCModule(newList);
    }

    /**
     * Assigns the dtc module to the CodeCoverage__c record.
     *
     * @param newList - List<CodeCoverage__c>
     */
    private static void assignDTCModule(List<CodeCoverage__c> newList) {
        Set<String> classNames = new Set<String>();
        for (CodeCoverage__c rec : newList) {
            classNames.add(rec.ApexClassOrTriggerName__c);
        }

        List<ModuleClass__c> classes = [SELECT Name, DTCModule__r.Name FROM ModuleClass__c WHERE Name IN :classNames];

        Map<String, ModuleClass__c> moduleClassMap = new Map<String, ModuleClass__c>();
        for (ModuleClass__c moduleTestClass : classes) {
            moduleClassMap.put(moduleTestClass.Name.toLowerCase(), moduleTestClass);
        }

        for (CodeCoverage__c rec : newList) {
            String key = rec.ApexClassOrTriggerName__c?.toLowerCase();
            if (String.isNotBlank(key) && moduleClassMap.containsKey(key)) {
                rec.DTCModule__c = moduleClassMap.get(key).DTCModule__r.Id;
            }
        }
    }
}
