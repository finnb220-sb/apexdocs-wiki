@isTest
public class VCC_SOT_OnboardingActvtyTriggerTest {
    static testMethod void testOnboardingActivityDuplicatePrevention() {
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
            VCC_Onboarding_Activity__c onboardingActivity1 = new VCC_Onboarding_Activity__c(Name = 'Readiness Activity for Admin for VISN 1');
            insert onboardingActivity1;
            VCC_Onboarding_Activity__c onboardingActivity2 = new VCC_Onboarding_Activity__c(Name = 'Readiness Activity for Admin for VISN 1');

            Test.startTest();
            Database.SaveResult duplicateOnboardingActivityResult = Database.insert(onboardingActivity2, false);
            Test.stopTest();

            //assert to check if result was successful
            System.assert(duplicateOnboardingActivityResult.isSuccess() == false, 'Result should not be successful');
            //assert that 1 error occurred
            System.assert(duplicateOnboardingActivityResult.getErrors().size() == 1);
        }
    }
}
