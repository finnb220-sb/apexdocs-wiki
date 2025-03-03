/**
 * @description test class for PC_CaseFeedbackController
 * @author      Booz Allen
 * @since       2024
 * @see         PC_ManagerController
 **/
@IsTest
public class PC_ManagerController_Test {
    /**
     * @description Method to create test data for unit tests
     * @author George Elias | 07-06-2022
     * @return  void
     **/
    static void makeData() {
        List<String> channels = new List<String>{ 'Chat', 'Teams', 'Phone' };
        List<Skill> lsChannelSKills = [SELECT Id FROM Skill WHERE MasterLabel IN :channels LIMIT 3];
        User specialistUser;
        User specialistManagerUser;
        User runAsFLPUser;

        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            specialistUser = generateUserWithAccess('PrC_Specialist_Users', 'Test PC Manager');
            specialistManagerUser = generateUserWithAccess('PrC_Specialist_Manager_Users', 'Test Manager');
            runAsFLPUser = generateUserWithAccess('PrC_FLP_Users', 'flp User');
        }
        System.runAs(specialistManagerUser) {
            ServiceResource pcSR = PC_TestDataFactory.createServiceResource(
                specialistUser.Id,
                specialistUser.LastName,
                'Cardiology'
            );
            PC_TestDataFactory.createServiceResourceSkill(pcSR.Id, lsChannelSKills[0].Id);
        }

        ServicePresenceStatus sps = [
            SELECT Id
            FROM ServicePresenceStatus
            WHERE DeveloperName = 'PC_Available_Provider_Connect'
            LIMIT 1
        ];

        // ES - IsRunningTest_DO_NOT_USE__c is to mitigate problems in the flow when deploying the test class due to the known issue with OmniChannel
        UserServicePresence usp = new UserServicePresence(
            UserId = specialistUser.Id,
            ServicePresenceStatusId = sps.Id,
            IsRunningTest_DO_NOT_USE__c = true
        );
        insert usp;

        System.runAs(runAsFLPUser) {
            PC_ProviderConnectController.createCase('Cardiology', 'Test Details', '987654321', 'Chat', '1234567890');
            PC_ProviderConnectController.createCase('Cardiology', 'Test Details', '987654321', 'Chat', '1234567890');
        }

        PC_TestDataFactory.mockCaseCriteriaSharing([SELECT Id, CreatedById FROM Case], specialistUser.Id);

        Id pcRtId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByName()
            .get('Provider Connect Resource')
            .getRecordTypeId();
        PC_TestDataFactory.mockResourceCriteriaSharing(
            [SELECT Id, CreatedById FROM ServiceResource WHERE RecordTypeId = :pcRtId],
            specialistUser.Id
        );

        System.runAs(runAsFLPUser) {
            List<PC_Case__c> lsCase = [SELECT Id FROM PC_Case__c];
            lsCase[0].OwnerId = specialistUser.Id;
            lsCase[1].OwnerId = specialistUser.Id;
            lsCase[1].Status__c = 'Closed Resolved';
            update lsCase;
        }
    }

    /**
     * @description Method to positively test getAgentHistory method
     * @author George Elias | 07-06-2022
     * @return  void
     **/
    @IsTest
    public static void unitGetAgentHistoryTestPositive() {
        makeData();
        User specialist = [SELECT Id FROM User WHERE LastName = 'Test PC Manager' LIMIT 1];

        System.runAs(specialist) {
            Test.startTest();
            List<PC_ManagerController.AgentHistory> lsAH = PC_ManagerController.getAgentHistory();
            Test.stopTest();
            System.assert(lsAH[0].agentId == specialist.Id, 'Special and Agent Id is not a match');
        }
    }

    /**
     * @description Method to negatively test getAgentHistory method
     * @author George Elias | 07-06-2022
     * @return  void
     **/
    @IsTest
    public static void unitGetAgentHistoryTestNegative() {
        try {
            List<PC_ManagerController.AgentHistory> lsAH = PC_ManagerController.getAgentHistory();
            System.assert(false);
        } catch (Exception e) {
            System.assert(true);
        }
    }

    /**
     * @description helper method to generate an test user with the specified permission set groupfor use in test methods
     * @param       permissionSetGroupName api name of the permission set group to give the user
     * @param       lastName Controller class executes with last name = 'Test PC Manager'
     * @return      `User` Salesforce user with the appropriate permission set group
     */
    private static User generateUserWithAccess(String permissionSetGroupName, String lastName) {
        VATEST_UserBuilder pcTestUser = new VATEST_UserBuilder();
        pcTestUser.withPermissionSet(permissionSetGroupName).withUserProfile('VAVET Base Profile').withStandardData();
        pcTestUser.resultingUser.LastName = lastName;
        return pcTestUser.build(true);
    }
}
