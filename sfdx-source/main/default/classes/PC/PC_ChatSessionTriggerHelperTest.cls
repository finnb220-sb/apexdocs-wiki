/**
 * @description test class for PC_ChatSessionTriggerHelper
 * @author      Booz Allen
 * @since       2024
 * @see         PC_ChatSessionTriggerHelper
 **/
@IsTest
public class PC_ChatSessionTriggerHelperTest {
    /**
     * @description Method to positively test clearSessionCacheData method
     * @author George Elias | 07-06-2022
     * @return  void
     **/
    @IsTest
    public static void unitClearSessionCacheDataTestPositive() {
        User runAsFLPUser = generateUserWithAccess('PrC_FLP_Users');
        Cache.OrgPartition orgPart;
        PC_Chat_Session__c chatSession = new PC_Chat_Session__c();

        System.runAs(runAsFLPUser) {
            //This Case creation kicks off automation that is being validated subsequently
            PC_ProviderConnectController.createCase('Cardiology', 'Test Details', '987654321', 'Chat', '1234567890');
            chatSession = [SELECT Id, PC_Is_Closed__c FROM PC_Chat_Session__c LIMIT 1];
            PC_ChatController.saveChatterMessage(chatSession.Id, 'Test', null);

            Test.startTest();
            chatSession.PC_Is_Closed__c = true;
            update chatSession;
            orgPart = Cache.Org.getPartition('local.pcChat');
            Test.stopTest();
        }

        System.Assert.isTrue(false == orgPart.contains(chatSession.Id), 'Expected chat Session to be Closed');
    }

    /**
     * @description helper method to generate an FLP test user for use in test methods
     * @return      `User` FLP salesforce user with the appropriate permission set group
     */
    private static User generateUserWithAccess(String permissionSetName) {
        return new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .withPermissionSet(permissionSetName)
            .build(true);
    }
}
