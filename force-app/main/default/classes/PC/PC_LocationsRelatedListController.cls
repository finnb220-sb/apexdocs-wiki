/**
 * @description       : controller for pcLocationsRelatedList LWC component
 * @author            : WagnerJ@BAH
 * @group             :
 * @last modified on  : 01-12-2023
 * @last modified by  : WagnerJ@BAH
 **/
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.StdCyclomaticComplexity')
public with sharing class PC_LocationsRelatedListController {
    @TestVisible
    private static Boolean throwException = false;

    /**
     * @description Get list of locations for table display.
     * Locations are directly related to the Territory through TerritoryLocation junction and indirectly related to the territory through the Locations' child VISNs via VISNTerritory junctions and the ConsortiumTerritory-Consortium-ConsortiumVISN object schema.
     * View these four objects (Territory, Location, VISN, Consortium) and their junctions in the schema builder for a better understanding of the relationships.
     * Note: If FSL is enabled in an org, the standard Location object must use "Schema.Location" in all references. There is a System type called Location, and also a Schema type called Location. The latter is what you query for, but the former is the default assumed by the compiler, and it is currently unable to disambiguate.
     * @author WagnerJ@BAH | 01-12-2023
     * @param territoryId - the context territory's Salesforce ID
     * @param includeDirectVISNs - include locations related to VISNs directly related to the territory
     * @param includeIndirectVISNs - include locations related to VISNs indirectly related to the territory through Consortiums
     * @return PC_RelatedListHelper.RelatedListResults
     **/
    @AuraEnabled(cacheable=true)
    public static PC_RelatedListHelper.RelatedListResults getLocations(Id territoryId, Boolean includeDirectVISNs, Boolean includeIndirectVISNs) {
        try {
            Set<Id> relatedLocationIdSet = new Set<Id>();
            Set<Id> relatedVISNIdSet = new Set<Id>();
            Set<Id> relatedConsortiumIdSet = new Set<Id>();

            //---DIRECTLY RELATED LOCATIONS---//
            //get list of Locations directly related to the territory
            for (PC_Territory_Location__c tlJunction : [SELECT PC_Location__c FROM PC_Territory_Location__c WHERE PC_Territory__c = :territoryId WITH SECURITY_ENFORCED]) {
                relatedLocationIdSet.add(tlJunction.PC_Location__c);
            }
            //--------------------------------//

            //---DIRECTLY RELATED VISNs---//
            if (includeDirectVISNs) {
                //get list of Locations related to the territory via a related VISN that is directly related to the territory
                for (PC_VISNTerritory__c vtJunction : [SELECT PC_VISN__c FROM PC_VISNTerritory__c WHERE PC_Territory__c = :territoryId WITH SECURITY_ENFORCED]) {
                    relatedVISNIdSet.add(vtJunction.PC_VISN__c);
                }
                //----------------------------//
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
                    relatedVISNIdSet.add(cvJunction.PC_VISN__c);
                }
                //------------------------------//
            }

            List<Schema.Location> allLocations = [
                SELECT Id, Name, CreatedBy.Name, CreatedDate, VAF_Facility_ID__c, VISN_Lookup__c
                FROM Location
                WITH SECURITY_ENFORCED
                ORDER BY Name
                LIMIT 10000
            ];

            PC_RelatedListHelper.RelatedListResults results = new PC_RelatedListHelper.RelatedListResults();
            for (Schema.Location loc : allLocations) {
                PC_RelatedListHelper.RelatedListObject rlo = new PC_RelatedListHelper.RelatedListObject(loc);

                //set 'selected' and 'indirect' properties on wrapper object
                rlo.setRelatedProperties(relatedLocationIdSet, 'Id', false);
                rlo.setRelatedProperties(relatedVISNIdSet, 'VISN_Lookup__c', true);

                results.addToList(rlo);
            }

            //for testing error handling in Test Class
            if (throwException) {
                throw new PC_RelatedListHelper.RelatedListException('Testing getLocations catch block');
            }

            return results;
        } catch (Exception e) {
            log_LogService.log('PC_LocationsRelatedListController.getLocations Exception', log_LogService.LogType.ERROR, e);
            log_LogService.publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description After submit button press, creates and deletes Territory Location junctions based
     * on the users selections/deselections on the related list components table of Locations
     * @author WagnerJ@BAH | 01-20-2023
     * @param territoryId context territory
     * @param originalSelectedRecordIds Locations originally related to the territory on LWC load
     * @param selectedRecordIds Locations currently selected on the LWC table upon submit button press
     * @return String
     **/
    @AuraEnabled
    public static String saveRecords(Id territoryId, String originalSelectedRecordIds, String selectedRecordIds) {
        try {
            if (!(Schema.sObjectType.PC_Territory_Location__c.isCreateable() && Schema.sObjectType.PC_Territory_Location__c.isDeletable())) {
                throw new PC_CustomException(
                    'The current user does not have the correct Territory Location CRUD permissions required to perform this action. Please reach out to your System Administrator.'
                );
            }

            List<String> originalSelectedIdsSet = (List<String>) JSON.deserialize(originalSelectedRecordIds, List<String>.class);
            List<String> selectedIdsSet = (List<String>) JSON.deserialize(selectedRecordIds, List<String>.class);

            //get list of records Ids added to the selected list for creation
            Map<Id, PC_Territory_Location__c> recordToCreateMap = new Map<Id, PC_Territory_Location__c>();
            for (String selectedId : selectedIdsSet) {
                if (!originalSelectedIdsSet.contains(selectedId)) {
                    recordToCreateMap.put(selectedId, new PC_Territory_Location__c(PC_Territory__c = territoryId, PC_Location__c = selectedId));
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
            List<PC_Territory_Location__c> junctionsToDelete = [
                SELECT Id
                FROM PC_Territory_Location__c
                WHERE PC_Territory__c = :territoryId AND PC_Location__c IN :recordIdsToDelete
                WITH SECURITY_ENFORCED
            ];
            delete junctionsToDelete;

            //for testing error handling in Test Class
            if (throwException) {
                throw new PC_RelatedListHelper.RelatedListException('Testing saveRecords catch block');
            }

            String returnMessage = 'Created ' + recordToCreateMap.size() + ' record(s) and deleted ' + junctionsToDelete.size() + ' record(s). ';

            Integer indirectLocationDelCount = recordIdsToDelete.size() - junctionsToDelete.size();
            String cannotDeleteIndirectMsg = indirectLocationDelCount > 0
                ? indirectLocationDelCount + ' record(s) could not be deleted due to an indirect relationship with the territory.'
                : '';

            return returnMessage + cannotDeleteIndirectMsg;
        } catch (Exception e) {
            log_LogService.log('PC_LocationsRelatedListController.saveRecords Exception', log_LogService.LogType.ERROR, e);
            log_LogService.publish();
            throw new AuraHandledException(e.getMessage());
        }
    }
}
