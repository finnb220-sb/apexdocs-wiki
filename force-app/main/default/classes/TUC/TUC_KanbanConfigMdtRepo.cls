/**
 * @description This repository is for the TUC_Kanban_Config__mdt Metadata.
 * @author Booz Allen Hamilton
 *
 * @see VTC_BaseRepo
 * @see TUC_KanbanConfigMdtRepoTest
 */
public virtual inherited sharing class TUC_KanbanConfigMdtRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for TUC_KanbanConfigMdtRepo. Calls super constructor which sets this.sObjectType to
     * TUC_Kanban_Config__mdt
     */
    public TUC_KanbanConfigMdtRepo() {
        super(TUC_Kanban_Config__mdt.sObjectType);
    }

    /**
     * @description - This method is responsible for fetching the controlling metadata record.
     * @param metadataDevName - The Dev Name of a desired TUC_Kanban_Config__mdt
     *
     * @return TUC_Kanban_Config__mdt - The metadata record that controls the kanban board.
     */
    public TUC_Kanban_Config__mdt fetchControllingMetadataRecord(String metadataDevName) {
        if (String.isBlank(metadataDevName)) {
            return null;
        }
        String selectClause = 'SELECT Id,DeveloperName,Fields_To_Display_on_Card__c,Fields_To_Display_on_Popup__c,Field_Type_Map__c,Home_Object_Name__c,Included_Recordtype_Developer_names__c,Kanban_Group_By__c,SOQL_limit_for_closed_statuses__c,SOQL_limit_for_open_statuses__c,Statuses_to_sort_by_TUC_wait_time__c,Values_To_Exclude_From_Group_By__c,Values_To_Include_for_Group_By__c ';
        String fromClause = 'FROM TUC_Kanban_Config__mdt ';
        String whereClause = 'WHERE DeveloperName = :metadataDevName LIMIT 1';
        String query = selectClause + fromClause + whereClause;
        Map<String, Object> bindParams = new Map<String, Object>{ 'metadataDevName' => metadataDevName };
        List<TUC_Kanban_Config__mdt> metadataList = this.fetch(query, bindParams);
        TUC_Kanban_Config__mdt metadataToReturn;
        if (!metadataList.isEmpty()) {
            metadataToReturn = metadataList.get(0);
        }
        return metadataToReturn;
    }
}
