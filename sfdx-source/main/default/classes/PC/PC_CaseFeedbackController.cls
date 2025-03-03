/**
 * @description       : controller class for pcCaseFeedback LWC component
 * @author            : WagnerJ@BAH
 * @group             :
 * @last modified on  : 07-25-2023
 * @last modified by  : WagnerJ@BAH
 **/
public without sharing class PC_CaseFeedbackController {
    /**
     * @description repository for custom PC Case Feedback Answer object
     */
    @TestVisible
    private static PC_CaseFeedbackAnswerRepo caseFeedbackAnswerRepo {
        get {
            if (caseFeedbackAnswerRepo == null) {
                caseFeedbackAnswerRepo = new PC_CaseFeedbackAnswerRepo();
            }
            return caseFeedbackAnswerRepo;
        }
        set;
    }
    /**
     * @description repository for custom PC Case object
     */
    @TestVisible
    private static PC_PrcCaseRepo prcCaseRepo {
        get {
            if (prcCaseRepo == null) {
                prcCaseRepo = new PC_PrcCaseRepo();
            }
            return prcCaseRepo;
        }
        set;
    }

    /**
     * @description check if feedback has already submitted submitted on this case for the specified role
     * @author WagnerJ@BAH | 07-25-2023
     * @param Id recordId
     * @param String role
     * @return Boolean
     **/
    @AuraEnabled(cacheable=true)
    public static Boolean getIsSubmitted(Id recordId, String role) {
        return [
                SELECT Id
                FROM PC_Case_Feedback_Answer__c
                WHERE
                    Provider_Connect_Case__c = :recordId
                    AND PC_Question__r.PC_Role__c = :role
                    AND PC_Question__r.PC_Active__c = TRUE
                WITH SECURITY_ENFORCED
                LIMIT 1
            ]
            .size() > 0;
    }

    /**
     * @description get a list of active case feedback questions for the specified role. The results are returned in pre-prepared feedback answer records for use on the front end.
     * @author WagnerJ@BAH | 07-25-2023
     * @param Id recordId
     * @param String role
     * @return List<PC_Case_Feedback_Answer__c>
     **/
    @AuraEnabled(cacheable=true)
    public static List<PC_Case_Feedback_Answer__c> getFeedbackQuestions(Id recordId, String role) {
        List<PC_Case_Feedback_Answer__c> feedbackAnswerList = new List<PC_Case_Feedback_Answer__c>();

        List<PC_Case_Feedback_Question__c> feedbackQuestionList = [
            SELECT Id, Name, PC_Question__c
            FROM PC_Case_Feedback_Question__c
            WHERE PC_Role__c = :role AND PC_Active__c = TRUE
            WITH SECURITY_ENFORCED
        ];

        for (PC_Case_Feedback_Question__c question : feedbackQuestionList) {
            feedbackAnswerList.add(
                new PC_Case_Feedback_Answer__c(
                    Provider_Connect_Case__c = recordId,
                    PC_Question__c = question.Id,
                    PC_Question__r = question,
                    PC_Answer__c = ''
                )
            );
        }

        return feedbackAnswerList;
    }

    /**
     * @description submit the feedback answers filled out by the user on the front end for insertion
     * @author WagnerJ@BAH | 07-25-2023
     * @param String feedbackAnswersJSON
     **/
    @AuraEnabled
    public static void submitFeedback(String feedbackAnswersJSON) {
        List<PC_Case_Feedback_Answer__c> feedbackAnswersList = (List<PC_Case_Feedback_Answer__c>) JSON.deserialize(
            feedbackAnswersJSON,
            List<PC_Case_Feedback_Answer__c>.class
        );

        //System.debug(feedbackAnswersList);

        try {
            if (!Schema.sObjectType.PC_Case_Feedback_Answer__c.isCreateable()) {
                throw new PC_CustomException(
                    'You do not have the permissions required to submit case feedback. Please contact your System Administrator for assistance.'
                );
            }
            insert feedbackAnswersList;
        } catch (Exception e) {
            log_LogService.log('PC_CaseFeedbackController.submitFeedback Exception', log_LogService.LogType.ERROR, e);
            log_LogService.publish();
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @description Get cases needing feedback for a specified individual (last 60 days)
     * @author Edwin Schaeffer | 07-27-2023
     * @param void
     * @return Map<Id, PC_Case__c>
     **/
    @AuraEnabled(cacheable=true)
    public static Map<Id, PC_Case__c> getCasesNeedingFeedback() {
        Id userId = UserInfo.getUserId();
        // Defining the PCP on a case as one who CREATED the case and the Specialist as one who OWNS the case.
        // Currently Specialists do not have access to the Provider Connect super screen to create cases.

        List<PC_Case__c> cases = prcCaseRepo.getRecentlyClosedCasesForUser(userId);

        Map<Id, PC_Case__c> caseMap = new Map<Id, PC_Case__c>(cases);

        List<PC_Case_Feedback_Answer__c> answers = caseFeedbackAnswerRepo.getFeedbackAnswersFromPrcCases(
            caseMap.keySet()
        );

        // If the user answered just one question as a PCP or Specialist, the Feedback is considered complete.
        for (PC_Case_Feedback_Answer__c ans : answers) {
            if (caseMap.containsKey(ans.Provider_Connect_Case__c)) {
                caseMap.remove(ans.Provider_Connect_Case__c);
            }
        }
        return caseMap;
    }
}
