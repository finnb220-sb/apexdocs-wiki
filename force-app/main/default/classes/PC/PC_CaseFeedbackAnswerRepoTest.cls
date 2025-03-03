/**
 * @description Test class for PC_PrcCaseRepo
 * @author      Booz Allen
 * @since       2024
 * @see         PC_CaseFeedbackAnswerRepo
 */
@IsTest
private class PC_CaseFeedbackAnswerRepoTest {
    /**
     * @description Test repo class contructor
     */
    @IsTest
    static void unitTestConstructorPositive() {
        User flpUser = generateUserWithAccess('PrC_FLP_Users');

        PC_CaseFeedbackAnswerRepo repo;
        System.runAs(flpUser) {
            Test.startTest();
            repo = new PC_CaseFeedbackAnswerRepo();
            Test.stopTest();
        }

        Assert.isNotNull(repo, 'Expected constructor to properly instantiate a PC_CaseFeedbackAnswerRepo class object');
        Assert.isTrue(
            String.valueOf(repo).containsIgnoreCase('VTC_BaseRepo.sObjectType=PC_Case_Feedback_Answer__c'),
            'Expected the SObject type to be PrC Case'
        );
    }

    /**
     * @description Test repo class method that returns PC Case Feedback Answers where related PC Feedback Question is active and is filtered by a Set of PrC Case ids
     */
    @IsTest
    private static void funcGetFeedbackAnswerForFeedbackQuestions() {
        User adminUser = generateUserWithAccess('PrC-PC_Case_Feedback_Question-AdminUser-CRE');
        User flpUser = generateUserWithAccess('PrC_FLP_Users');

        PC_Case__c prcCase;
        PC_Case_Feedback_Question__c flpQuestion;

        System.runAs(adminUser) {
            flpQuestion = (PC_Case_Feedback_Question__c) VATEST_SObjectFactory.createSObject(
                new PC_Case_Feedback_Question__c(
                    PC_Active__c = true,
                    PC_Question__c = 'Did you enjoy this interaction FLP?',
                    PC_Role__c = 'FLP'
                ),
                true
            );

            VATEST_SObjectFactory.createSObject(
                new PC_Case_Feedback_Question__Share(
                    ParentId = flpQuestion.Id,
                    UserOrGroupId = flpUser.Id,
                    RowCause = 'Manual',
                    AccessLevel = 'Read'
                ),
                true
            );
        }
        System.runAs(flpUser) {
            prcCase = PC_ProviderConnectController.createCase(
                'Cardiology',
                'Test Details',
                '987654321',
                'Chat',
                '1234567890'
            );

            List<PC_Case_Feedback_Answer__c> feedbackList = PC_CaseFeedbackController.getFeedbackQuestions(
                prcCase.Id,
                'FLP'
            );

            for (PC_Case_Feedback_Answer__c feedback : feedbackList) {
                feedback.PC_Answer__c = 'Yes';
            }
            String feedbackJSON = JSON.serialize(feedbackList);
            PC_CaseFeedbackController.submitFeedback(feedbackJSON);
        }

        PC_CaseFeedbackAnswerRepo caseFeedbackAnswerRepo = new PC_CaseFeedbackAnswerRepo();
        List<PC_Case_Feedback_Answer__c> results;

        // Actual test
        Test.startTest();
        System.runAs(flpUser) {
            results = caseFeedbackAnswerRepo.getFeedbackAnswersFromPrcCases(new Set<Id>{ prcCase.Id });
        }

        Test.stopTest();
        // Asserts
        Assert.isTrue(results.size() > 0, 'Unable to retreive Case Feedback Answer successfully');
    }

    /**
     * @description helper method to generate an test user with the specified permission set group for use in test methods
     * @param       permissionSetGroupName api name of the permission set group to give the user
     * @return      `User` Salesforce user with the appropriate permission set group
     */
    private static User generateUserWithAccess(String permissionSetGroupName) {
        VATEST_UserBuilder pcTestUser = new VATEST_UserBuilder();
        pcTestUser.withPermissionSet(permissionSetGroupName).withUserProfile('VAVET Base Profile').withStandardData();
        return pcTestUser.build(true);
    }
}
