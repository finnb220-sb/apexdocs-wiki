/*
 * @description Test Class for VCC_SOT_ServiceUserAssignTriggerHandler
 *
 */
@isTest
public class VCC_SOT_ServiceUserAssignTrigHandTest {
    @isTest
    static void testdupSUAError() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'VAVET Base Profile'];

        User u = new User(
            Alias = 'standt',
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            FirstName = 'User',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'standarduser@testorg.com.test'
        );

        insert u;

        PermissionSet perm = [SELECT Id FROM PermissionSet WHERE PermissionSet.name = 'VCC_VAHC_SOT_User'];

        PermissionSetAssignment permAssign = new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = perm.id);

        insert permAssign;

        System.runAs(u) {
            VCC_SOT_User__c sotUser = new VCC_SOT_User__c(Name = 'TestTrigger User', VCC_VA_Email__c = 'triggertest@vatest.gov');

            insert sotUser;

            VCC_CRM_VISN_Service_Assignment__c newServiceVISNAssign = new VCC_CRM_VISN_Service_Assignment__c(VCC_CRM_Service_Picklist__c = 'Admin', VCC_VISN__c = '23');

            insert newServiceVISNAssign;

            VCC_Service_User_Assignment__c sua1 = new VCC_Service_User_Assignment__c(VCC_SOT_User__c = sotUser.id, VCC_CRM_VISN_Service_Assignment__c = newServiceVISNAssign.id);

            insert sua1;

            VCC_Service_User_Assignment__c sua2 = new VCC_Service_User_Assignment__c(VCC_SOT_User__c = sotUser.id, VCC_CRM_VISN_Service_Assignment__c = newServiceVISNAssign.id);

            Test.startTest();
            Database.SaveResult duplicateSuaResult = Database.insert(sua2, false);
            Test.stopTest();

            System.assert(duplicateSuaResult.isSuccess() == false, 'Result should not be successful');
            System.assert(duplicateSuaResult.getErrors().size() == 1, 'Result should not be successful');
        }
    }
}
