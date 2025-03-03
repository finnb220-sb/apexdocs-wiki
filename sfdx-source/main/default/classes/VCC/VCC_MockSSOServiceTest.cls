/**
 * Deprecated 9/15/2022 see VCC_MockSSOServiceV2Test
 */
@isTest
public with sharing class VCC_MockSSOServiceTest {
    @testSetup
    static void makeData() {
        VCC_TestDataFactory.insertUser('System Administrator');
    }
    /**
     * @description create a test user for running tests
     * @return A test user
     **/
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
    }
    @isTest
    public static void isMockSSOEnabledTest() {
        System.runAs(getTestUser()) {
            VCC_Org_Settings__mdt orgSettings = (new VCC_OrgSettingsSelector()).selectByOrgId(UserInfo.getOrganizationId());
            Test.startTest();
            if (orgSettings != null) {
                System.assert(VCC_MockSSOService.isMockSSOEnabled() == orgSettings.Enable_SSO_Mocking__c, 'Result does not match org settings.');
            } else {
                System.assert(VCC_MockSSOService.isMockSSOEnabled() == false, 'Expected false.');
            }
            Test.stopTest();
        }
    }

    @isTest
    public static void getMockSSOSettingTestSad() {
        System.runAs(getTestUser()) {
            VCC_Mock_SSO_Settings__c msso;
            VCC_MockSSOService.MockSSOException expectedException;

            Test.startTest();
            try {
                msso = VCC_MockSSOService.getMockSSOSetting();
            } catch (VCC_MockSSOService.MockSSOException e) {
                expectedException = e;
            }
            Test.stopTest();

            System.assert(expectedException != null, 'Expected exception.');
            System.assert(msso == null, 'Expected value as null.');
        }
    }

    @isTest
    public static void getMockSSOSettingTestUser() {
        System.runAs(getTestUser()) {
            VCC_Mock_SSO_Settings__c userSetting = new VCC_Mock_SSO_Settings__c(
                VCC_SSO_Token__c = 'user',
                VCC_VistA_Instance__c = 'test',
                VCC_DUZ__c = 'test',
                SetupOwnerId = UserInfo.getUserId()
            );
            insert userSetting;
            VCC_Mock_SSO_Settings__c msso;

            Test.startTest();
            msso = VCC_MockSSOService.getMockSSOSetting();
            Test.stopTest();

            System.assert(msso.VCC_SSO_Token__c == 'user', 'Expected user setting.');
        }
    }

    @isTest
    public static void getMockSSOSettingTestProfile() {
        System.runAs(getTestUser()) {
            VCC_Mock_SSO_Settings__c profileSetting = new VCC_Mock_SSO_Settings__c(
                VCC_SSO_Token__c = 'profile',
                VCC_VistA_Instance__c = 'test',
                VCC_DUZ__c = 'test',
                SetupOwnerId = UserInfo.getProfileId()
            );
            insert profileSetting;
            VCC_Mock_SSO_Settings__c msso;

            Test.startTest();
            msso = VCC_MockSSOService.getMockSSOSetting();
            Test.stopTest();

            System.assert(msso.VCC_SSO_Token__c == 'profile', 'Expected profile setting.');
        }
    }

    @isTest
    public static void getMockSSOSettingTestOrg() {
        System.runAs(getTestUser()) {
            VCC_Mock_SSO_Settings__c orgSetting = new VCC_Mock_SSO_Settings__c(
                VCC_SSO_Token__c = 'org',
                VCC_VistA_Instance__c = 'test',
                VCC_DUZ__c = 'test',
                SetupOwnerId = UserInfo.getOrganizationId()
            );
            insert orgSetting;
            VCC_Mock_SSO_Settings__c msso;

            Test.startTest();
            msso = VCC_MockSSOService.getMockSSOSetting();
            Test.stopTest();

            System.assert(msso.VCC_SSO_Token__c == 'org', 'Expected org setting.');
        }
    }

    @isTest
    public static void getTokenTestHappy() {
        System.runAs(getTestUser()) {
            VCC_Mock_SSO_Settings__c tokenSetting = new VCC_Mock_SSO_Settings__c(
                VCC_SSO_Token__c = 'token',
                VCC_VistA_Instance__c = 'test',
                VCC_DUZ__c = 'test',
                SetupOwnerId = UserInfo.getOrganizationId()
            );
            insert tokenSetting;

            String token;
            Test.startTest();
            token = VCC_MockSSOService.getMockSSOToken();
            Test.stopTest();

            System.assert(token == 'token', 'Expected token.');
        }
    }
}
