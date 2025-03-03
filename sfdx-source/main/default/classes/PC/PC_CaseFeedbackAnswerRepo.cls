/**
 * @description Repository class for the Case Feedback Answer object to hold its respective query and DML logic
 * @author Booz Allen
 * @since  2024
 */
public with sharing class PC_CaseFeedbackAnswerRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for PC_CaseFeedbackAnswerRepo. Calls super constructor which sets this.sObjectType to 'PC_Case_Feedback_Answer__c'
     */
    public PC_CaseFeedbackAnswerRepo() {
        super(PC_Case_Feedback_Answer__c.sObjectType);
    }

    /**
     * @description     gets a list of Case Feedback that need to action for a specific Case
     * @param caseIds Set of Ids for the Cases to verify
     * @return 'List<PC_Case_Feedback_Answer__c>' list of Case Feedback Answers
     */
    public List<PC_Case_Feedback_Answer__c> getFeedbackAnswersFromPrcCases(Set<Id> caseIds) {
        String selectClause = 'SELECT Id,Provider_Connect_Case__c';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE Provider_Connect_Case__c IN :caseIds AND PC_Question__r.PC_Active__c = TRUE';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause;
        return (List<PC_Case_Feedback_Answer__c>) this.fetch(query, new Map<String, Object>{ 'caseIds' => caseIds });
    }
}
