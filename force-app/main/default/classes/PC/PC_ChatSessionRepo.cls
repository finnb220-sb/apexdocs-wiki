/**
 * @description Repository class for the PC_Chat_Session__c object to hold its respective query and DML logic.
 * @author Booz Allen
 * @since 2024
 */
public inherited sharing class PC_ChatSessionRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for PC_ChatSessionRepo. Calls super constructor which sets this.sObjectType to 'PC_Chat_Session__c'
     */
    public PC_ChatSessionRepo() {
        super(PC_Chat_Session__c.sObjectType);
    }

    /**
     * @description     used to grab chat session headers to determine any chats related to a PrC Case
     * @param prcCaseId SF Id of the PrC Case
     * @return          `List<PC_Chat_Session__c>` list of chat sessions related to the PrC Case
     */
    public List<PC_Chat_Session__c> fetchPcChatSessionByPrcCaseId(Id prcCaseId) {
        Map<String, Object> bindParams = new Map<String, Object>{ 'prcCaseId' => prcCaseId };

        String selectClause = 'SELECT Id';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE Provider_Connect_Case__c = :prcCaseId';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause;
        return (List<PC_Chat_Session__c>) this.fetch(query, bindParams);
    }

    /**
     * @description        grabs all open chat sessions related to the provided PrC Cases
     * @param prcCaseIdSet Set of PrC Case Ids
     * @return             `List<PC_Chat_Session__c>` list of resultant open chat sessions related to the PrC Cases provided as input
     */
    public List<PC_Chat_Session__c> fetchOpenPcChatSessionByPrcCaseIds(Set<Id> prcCaseIdSet) {
        Map<String, Object> bindParams = new Map<String, Object>{ 'prcCaseIdSet' => prcCaseIdSet };

        String selectClause = 'SELECT Id';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE Provider_Connect_Case__c IN :prcCaseIdSet AND PC_Is_Closed__c = FALSE';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause;
        return (List<PC_Chat_Session__c>) this.fetch(query, bindParams);
    }
}
