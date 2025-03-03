/**
 * @description       : Controller class for the consortiumsRelatedList LWC
 * @author            : WagnerJ@BAH
 * @group             :
 * @last modified on  : 01-20-2023
 * @last modified by  : WagnerJ@BAH
 **/
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class PC_ConsortiumsRelatedListController {
    @TestVisible
    private static Boolean throwException = false;

    /**
     * @description gets a list of all Consortiums that are directly related to the supplied territory
     * in correct format for display in related list table on the LWC
     * @author WagnerJ@BAH | 03-20-2023
     * @param territoryId
     * @return PC_RelatedListHelper.RelatedListResults
     **/
    @AuraEnabled(cacheable=true)
    public static PC_RelatedListHelper.RelatedListResults getConsortiums(Id territoryId) {
        try {
            Set<Id> relatedConsortiumIdSet = new Set<Id>();

            //get list of Consortiums directly related to the territory
            for (PC_Consortium_Territory__c ctJunction : [SELECT PC_Consortium__c FROM PC_Consortium_Territory__c WHERE PC_Territory__c = :territoryId WITH SECURITY_ENFORCED]) {
                relatedConsortiumIdSet.add(ctJunction.PC_Consortium__c);
            }

            List<PC_Consortium__c> allConsortiums = [
                SELECT Id, Name, CreatedBy.Name, CreatedDate
                FROM PC_Consortium__c
                WITH SECURITY_ENFORCED
                ORDER BY Name
                LIMIT 10000
            ];

            PC_RelatedListHelper.RelatedListResults results = new PC_RelatedListHelper.RelatedListResults();
            for (PC_Consortium__c con : allConsortiums) {
                PC_RelatedListHelper.RelatedListObject rlo = new PC_RelatedListHelper.RelatedListObject(con);

                //set 'selected' property on wrapper object
                rlo.setRelatedProperties(relatedConsortiumIdSet, 'Id', false);

                results.addToList(rlo);
            }

            //for testing error handling in Test Class
            if (throwException) {
                throw new PC_RelatedListHelper.RelatedListException('Testing getConsortiums catch block');
            }

            return results;
        } catch (Exception e) {
            log_LogService.log('PC_ConsortiumsRelatedListController.getConsortiums Exception', log_LogService.LogType.ERROR, e);
            log_LogService.publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description After submit button press, creates and deletes Consortium  Territory junctions based
     * on the users selections/deselections on the related list components table of Consortiums
     * @author WagnerJ@BAH | 03-20-2023
     * @param territoryId
     * @param originalSelectedRecordIds
     * @param selectedRecordIds
     * @return String
     **/
    @AuraEnabled
    public static String saveRecords(Id territoryId, String originalSelectedRecordIds, String selectedRecordIds) {
        try {
            if (!(Schema.sObjectType.PC_Consortium_Territory__c.isCreateable() && Schema.sObjectType.PC_Consortium_Territory__c.isDeletable())) {
                throw new PC_CustomException(
                    'The current user does not have the correct Consortium Territory CRUD permissions required to perform this action. Please reach out to your System Administrator.'
                );
            }

            List<String> originalSelectedIdsSet = (List<String>) JSON.deserialize(originalSelectedRecordIds, List<String>.class);
            List<String> selectedIdsSet = (List<String>) JSON.deserialize(selectedRecordIds, List<String>.class);

            //get list of records Ids added to the selected list for creation
            Map<Id, PC_Consortium_Territory__c> recordToCreateMap = new Map<Id, PC_Consortium_Territory__c>();
            for (String selectedId : selectedIdsSet) {
                if (!originalSelectedIdsSet.contains(selectedId)) {
                    recordToCreateMap.put(selectedId, new PC_Consortium_Territory__c(PC_Territory__c = territoryId, PC_Consortium__c = selectedId));
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
            List<PC_Consortium_Territory__c> junctionsToDelete = [
                SELECT Id
                FROM PC_Consortium_Territory__c
                WHERE PC_Territory__c = :territoryId AND PC_Consortium__c IN :recordIdsToDelete
                WITH SECURITY_ENFORCED
            ];
            delete junctionsToDelete;

            //for testing error handling in Test Class
            if (throwException) {
                throw new PC_RelatedListHelper.RelatedListException('Testing saveRecords catch block');
            }

            String returnMessage = 'Created ' + recordToCreateMap.size() + ' record(s) and deleted ' + junctionsToDelete.size() + ' record(s). ';

            return returnMessage;
        } catch (Exception e) {
            log_LogService.log('PC_ConsortiumsRelatedListController.saveRecords Exception', log_LogService.LogType.ERROR, e);
            log_LogService.publish();
            throw new AuraHandledException(e.getMessage());
        }
    }
}
