/**
 * @description test class for PC_CaseFeedbackController
 * @author      Booz Allen
 * @since       2024
 * @see         PC_CaseFeedbackController
 **/
@IsTest
private class PC_CaseFeedbackController_Test {
    @testSetup
    private static void testSetup() {
        User runAsFLPUser = generateUserWithAccess('PrC_FLP_Users');

        System.runAs(runAsFLPUser) {
            PC_ProviderConnectController.createCase('Cardiology', 'Test Details', '987654321', 'Chat', '1234567890');
            PC_ProviderConnectController.createCase('Cardiology', 'Test Details 2', '987654322', 'Chat', '1234567891');
        }
    }

    /**
     * @description test method for getIsSubmitted
     * @author WagnerJ@BAH | 07-25-2023
     **/
    @IsTest
    private static void unitTestGetIsSubmittedPositive() {
        // Test data setup
        PC_Case__c case1 = [SELECT ID FROM PC_Case__c LIMIT 1];

        Boolean submittedStatus;

        User runAsUser = generateUserAndCaseFeedbackSetupData('FLP');

        VATEST_SObjectFactory.createSObject(
            new PC_Case__Share(
                ParentId = case1.Id,
                UserOrGroupId = runAsUser.Id,
                RowCause = 'Manual',
                AccessLevel = 'Read'
            ),
            true
        );

        // Actual test
        Test.startTest();

        System.runAs(runAsUser) {
            submittedStatus = PC_CaseFeedbackController.getIsSubmitted(case1.Id, 'FLP');
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(!submittedStatus, 'PC Case should not be submitted since no FLP feedback exists for the case');
    }

    /**
     * @description test method for getFeedbackQuestions
     * @author WagnerJ@BAH | 07-25-2023
     **/
    @IsTest
    private static void unitTestGetFeedbackQuestionsPositive() {
        // Test data setup
        PC_Case__c case1 = [SELECT ID FROM PC_Case__c LIMIT 1];

        List<PC_Case_Feedback_Answer__c> results;

        User runAsUser = generateUserAndCaseFeedbackSetupData('Specialist');

        VATEST_SObjectFactory.createSObject(
            new PC_Case__Share(
                ParentId = case1.Id,
                UserOrGroupId = runAsUser.Id,
                RowCause = 'Manual',
                AccessLevel = 'Read'
            ),
            true
        );

        // Actual test
        Test.startTest();

        System.runAs(runAsUser) {
            results = PC_CaseFeedbackController.getFeedbackQuestions(case1.Id, 'Specialist');
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(results.size() == 2, 'There should be two Specialist questions.');
    }

    /**
     * @description negative test method for submitFeedback
     * @author WagnerJ@BAH | 07-25-2023
     **/
    @IsTest
    private static void unitTestSubmitFeedbackNegative() {
        // Test data setup
        PC_Case__c case1 = [SELECT ID FROM PC_Case__c WITH SECURITY_ENFORCED LIMIT 1];

        User runAsUser = generateUserAndCaseFeedbackSetupData('FLP');

        List<PC_Case_Feedback_Answer__c> feedbackList = PC_CaseFeedbackController.getFeedbackQuestions(case1.Id, 'FLP');

        String errorMessage = '';

        VATEST_SObjectFactory.createSObject(
            new PC_Case__Share(
                ParentId = case1.Id,
                UserOrGroupId = runAsUser.Id,
                RowCause = 'Manual',
                AccessLevel = 'Read'
            ),
            true
        );

        // Actual test
        Test.startTest();

        System.runAs(runAsUser) {
            try {
                //throw insert error because no answer provided
                String feedbackJSON = JSON.serialize(feedbackList);
                PC_CaseFeedbackController.submitFeedback(feedbackJSON);
            } catch (Exception e) {
                errorMessage = e.getMessage();
            }
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(
            String.isNotBlank(errorMessage),
            'An error should be returned because no answer was provided on the feedback answers that were attempted to be inserted.'
        );
    }

    /**
     * @description positive test method for submitFeedback
     * @author WagnerJ@BAH | 07-25-2023
     **/
    @IsTest
    private static void unitTestSubmitFeedbackPositive() {
        // Test data setup
        PC_Case__c case1 = [SELECT ID FROM PC_Case__c WITH SECURITY_ENFORCED LIMIT 1];

        User runAsUser = generateUserAndCaseFeedbackSetupData('FLP');

        List<PC_Case_Feedback_Answer__c> feedbackList = PC_CaseFeedbackController.getFeedbackQuestions(case1.Id, 'FLP');

        VATEST_SObjectFactory.createSObject(
            new PC_Case__Share(
                ParentId = case1.Id,
                UserOrGroupId = runAsUser.Id,
                RowCause = 'Manual',
                AccessLevel = 'Read'
            ),
            true
        );

        // Actual test
        Test.startTest();

        System.runAs(runAsUser) {
            //add answer to feedback
            for (PC_Case_Feedback_Answer__c feedback : feedbackList) {
                feedback.PC_Answer__c = 'Yes';
            }
            String feedbackJSON = JSON.serialize(feedbackList);
            PC_CaseFeedbackController.submitFeedback(feedbackJSON);
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(
            PC_CaseFeedbackController.getIsSubmitted(case1.Id, 'FLP'),
            'This case should have an answer to the FLP feedback question.'
        );
    }
    /**
     * @description test method for getCasesNeedingFeedback
     * @author Edwin Schaeffer | 07-28-2023
     **/
    @IsTest
    private static void unitTestGetCasesNeedingFeedbackPositive() {
        User runAsUser = generateUserAndCaseFeedbackSetupData('FLP');

        System.runAs(runAsUser) {
            PC_Case__c testCase = PC_ProviderConnectController.createCase(
                'Cardiology',
                'Test Details 3',
                '987654321',
                'Chat',
                '1234567890'
            );

            List<PC_Case_Feedback_Answer__c> feedbackList = PC_CaseFeedbackController.getFeedbackQuestions(
                testCase.Id,
                'FLP'
            );

            //add answer to feedback
            for (PC_Case_Feedback_Answer__c feedback : feedbackList) {
                feedback.PC_Answer__c = 'Yes';
            }
            String feedbackJSON = JSON.serialize(feedbackList);
            PC_CaseFeedbackController.submitFeedback(feedbackJSON);

            //close case after feedback given
            testCase.Status__c = 'Closed';
            update testCase;
        }

        Test.startTest();

        Map<Id, PC_Case__c> caseMap;
        System.runAs(runAsUser) {
            caseMap = PC_CaseFeedbackController.getCasesNeedingFeedback();
        }

        Test.stopTest();

        Assert.isTrue(caseMap.size() == 0, 'The incorrect amount of cases require feedback still.');
    }

    /**
     * @description helper method to generate an test user with the specified permission set groupfor use in test methods
     * @param       permissionSetGroupName api name of the permission set group to give the user
     * @return      `User` Salesforce user with the appropriate permission set group
     */
    private static User generateUserWithAccess(String permissionSetGroupName) {
        //PrC_FLP_Users 'PrC-PC_Case_Feedback_Question-AdminUser-CRE' PrC_Specialist_Users
        return new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .withPermissionSet(permissionSetGroupName)
            .build(true);
    }

    /**
     * @description    generates the specified user and their respective Case Feedback questions for testing purposes
     * @param userType FLP or Specialist
     * @return         `User`
     */
    private static User generateUserAndCaseFeedbackSetupData(String userType) {
        User runAsUser;
        User runAsCaseFeedbackUser;
        //mixed DML error workaround
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            runAsCaseFeedbackUser = generateUserWithAccess('PrC-PC_Case_Feedback_Question-AdminUser-CRE');
        }

        if (userType.equalsIgnoreCase('FLP')) {
            //mixed DML error workaround
            System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
                runAsUser = generateUserWithAccess('PrC_FLP_Users');
            }
            System.runAs(runAsCaseFeedbackUser) {
                PC_Case_Feedback_Question__c flpQuestion1 = (PC_Case_Feedback_Question__c) VATEST_SObjectFactory.createSObject(
                    new PC_Case_Feedback_Question__c(
                        PC_Active__c = true,
                        PC_Question__c = 'Did you enjoy this interaction FLP?',
                        PC_Role__c = 'FLP'
                    ),
                    true
                );

                VATEST_SObjectFactory.createSObject(
                    new PC_Case_Feedback_Question__Share(
                        ParentId = flpQuestion1.Id,
                        UserOrGroupId = runAsUser.Id,
                        RowCause = 'Manual',
                        AccessLevel = 'Read'
                    ),
                    true
                );
            }
        } else {
            //mixed DML error workaround
            System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
                runAsUser = generateUserWithAccess('PrC_Specialist_Users');
            }

            System.runAs(runAsCaseFeedbackUser) {
                PC_Case_Feedback_Question__c specialistQuestion1 = (PC_Case_Feedback_Question__c) VATEST_SObjectFactory.createSObject(
                    new PC_Case_Feedback_Question__c(
                        PC_Active__c = true,
                        PC_Question__c = 'Did you enjoy this interaction Specialist 1?',
                        PC_Role__c = 'Specialist'
                    ),
                    true
                );
                PC_Case_Feedback_Question__c specialistQuestion2 = (PC_Case_Feedback_Question__c) VATEST_SObjectFactory.createSObject(
                    new PC_Case_Feedback_Question__c(
                        PC_Active__c = true,
                        PC_Question__c = 'Did you enjoy this interaction Specialist 2?',
                        PC_Role__c = 'Specialist'
                    ),
                    true
                );

                VATEST_SObjectFactory.createSObject(
                    new PC_Case_Feedback_Question__Share(
                        ParentId = specialistQuestion1.Id,
                        UserOrGroupId = runAsUser.Id,
                        RowCause = 'Manual',
                        AccessLevel = 'Read'
                    ),
                    true
                );

                VATEST_SObjectFactory.createSObject(
                    new PC_Case_Feedback_Question__Share(
                        ParentId = specialistQuestion2.Id,
                        UserOrGroupId = runAsUser.Id,
                        RowCause = 'Manual',
                        AccessLevel = 'Read'
                    ),
                    true
                );
            }
        }

        return runAsUser;
    }
}
