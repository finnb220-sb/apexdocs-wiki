/**
 * @description       : Controller class for the visnsRelatedList LWC
 * @author            : WagnerJ@BAH
 * @group             :
 * @last modified on  : 01-20-2023
 * @last modified by  : WagnerJ@BAH
 **/
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class PC_VISNsRelatedListController {
    @TestVisible
    private static Boolean throwException = false;

    /**
     * @description gets a list of all VISNs that are directly (and possible indirectly) related to the supplied territory
     * Indirect VISNs are defined as VISNs that are related to the territory through a directly related Consortium
     * @author WagnerJ@BAH | 03-20-2023
     * @param territoryId
     * @param includeIndirectVISNs
     * @return PC_RelatedListHelper.RelatedListResults
     **/
    @AuraEnabled(cacheable=true)
    public static PC_RelatedListHelper.RelatedListResults getVISNs(Id territoryId, Boolean includeIndirectVISNs) {
        try {
            Set<Id> relatedVISNIdSet = new Set<Id>();
            Set<Id> relatedConsortiumIdSet = new Set<Id>();
            Set<Id> indirectRelatedVISNIdSet = new Set<Id>();

            //---DIRECTLY RELATED VISNs---//
            //get list of VISNs directly related to the territory
            for (PC_VISNTerritory__c vtJunction : [SELECT PC_VISN__c FROM PC_VISNTerritory__c WHERE PC_Territory__c = :territoryId WITH SECURITY_ENFORCED]) {
                relatedVISNIdSet.add(vtJunction.PC_VISN__c);
            }

            //---INDIRECTLY RELATED VISNs---//
            if (includeIndirectVISNs) {
                //get list of Consortiums directly related to the territory
                for (PC_Consortium_Territory__c ctJunction : [
                    SELECT PC_Consortium__c
                    FROM PC_Consortium_Territory__c
                    WHERE PC_Territory__c = :territoryId
                    WITH SECURITY_ENFORCED
                ]) {
                    relatedConsortiumIdSet.add(ctJunction.PC_Consortium__c);
                }

                //get list of VISNs related to the Consortiums that are directly related to the territory
                for (PC_ConsortiumVISN__c cvJunction : [SELECT PC_VISN__c FROM PC_ConsortiumVISN__c WHERE PC_Consortium__c IN :relatedConsortiumIdSet WITH SECURITY_ENFORCED]) {
                    indirectRelatedVISNIdSet.add(cvJunction.PC_VISN__c);
                }
                //------------------------------//
            }

            List<VISN__c> allVISNs = [
                SELECT Id, Name, CreatedBy.Name, CreatedDate, VISN_Number__c
                FROM VISN__c
                WITH SECURITY_ENFORCED
                ORDER BY VISN_Number__c
                LIMIT 10000
            ];

            PC_RelatedListHelper.RelatedListResults results = new PC_RelatedListHelper.RelatedListResults();
            for (VISN__c visn : allVISNs) {
                PC_RelatedListHelper.RelatedListObject rlo = new PC_RelatedListHelper.RelatedListObject(visn);

                //set 'selected' and 'indirect' properties on wrapper object
                rlo.setRelatedProperties(relatedVISNIdSet, 'Id', false);
                rlo.setRelatedProperties(indirectRelatedVISNIdSet, 'Id', true);

                results.addToList(rlo);
            }

            //for testing error handling in Test Class
            if (throwException) {
                throw new PC_RelatedListHelper.RelatedListException('Testing getVISNs catch block');
            }

            return results;
        } catch (Exception e) {
            log_LogService.log('PC_VISNsRelatedListController.getVISNs Exception', log_LogService.LogType.ERROR, e);
            log_LogService.publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description After submit button press, creates and deletes VISN Territory junctions based
     * on the users selections/deselections on the related list components table of VISNs
     * @author WagnerJ@BAH | 03-20-2023
     * @param territoryId
     * @param originalSelectedRecordIds
     * @param selectedRecordIds
     * @return String
     **/
    @AuraEnabled
    public static String saveRecords(Id territoryId, String originalSelectedRecordIds, String selectedRecordIds) {
        try {
            if (!(Schema.sObjectType.PC_VISNTerritory__c.isCreateable() && Schema.sObjectType.PC_VISNTerritory__c.isDeletable())) {
                throw new PC_CustomException(
                    'The current user does not have the correct VISN Territory CRUD permissions required to perform this action. Please reach out to your System Administrator.'
                );
            }

            List<String> originalSelectedIdsSet = (List<String>) JSON.deserialize(originalSelectedRecordIds, List<String>.class);
            List<String> selectedIdsSet = (List<String>) JSON.deserialize(selectedRecordIds, List<String>.class);

            //get list of records Ids added to the selected list for creation
            Map<Id, PC_VISNTerritory__c> recordToCreateMap = new Map<Id, PC_VISNTerritory__c>();
            for (String selectedId : selectedIdsSet) {
                if (!originalSelectedIdsSet.contains(selectedId)) {
                    recordToCreateMap.put(selectedId, new PC_VISNTerritory__c(PC_Territory__c = territoryId, PC_VISN__c = selectedId));
                }
            }
            insert recordToCreateMap.values();

            //get list of record Ids removed from the selected list for deletion
            Set<String> recordIdsToDelete = new Set<String>();
            for (String originalId : originalSelectedIdsSet) {
                if (!selectedIdsSet.contains(originalId)) {
                    recordIdsToDelete.add(originalId);
                }
            }
            List<PC_VISNTerritory__c> junctionsToDelete = [
                SELECT Id
                FROM PC_VISNTerritory__c
                WHERE PC_Territory__c = :territoryId AND PC_VISN__c IN :recordIdsToDelete
                WITH SECURITY_ENFORCED
            ];
            delete junctionsToDelete;

            //for testing error handling in Test Class
            if (throwException) {
                throw new PC_RelatedListHelper.RelatedListException('Testing saveRecords catch block');
            }

            String returnMessage = 'Created ' + recordToCreateMap.size() + ' record(s) and deleted ' + junctionsToDelete.size() + ' record(s). ';

            Integer indirectVISNDelCount = recordIdsToDelete.size() - junctionsToDelete.size();
            String cannotDeleteIndirectMsg = indirectVISNDelCount > 0
                ? indirectVISNDelCount + ' record(s) could not be deleted due to an indirect relationship with the territory.'
                : '';

            return returnMessage + cannotDeleteIndirectMsg;
        } catch (Exception e) {
            log_LogService.log('PC_LocationsRelatedListController.saveRecords Exception', log_LogService.LogType.ERROR, e);
            log_LogService.publish();
            throw new AuraHandledException(e.getMessage());
        }
    }
}
