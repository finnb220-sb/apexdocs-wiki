@isTest
public with sharing class VCC_MockSSOSettingsSelectorTest {
    @TestSetup
    static void makeData() {
        VCC_TestDataFactory.insertUser('System Administrator');
        VCC_Mock_SSO_Settings__c userSetting = new VCC_Mock_SSO_Settings__c(
            VCC_SSO_Token__c = 'user',
            VCC_VistA_Instance__c = 'test',
            VCC_DUZ__c = 'test',
            SetupOwnerId = UserInfo.getUserId()
        );
        VCC_Mock_SSO_Settings__c profileSetting = new VCC_Mock_SSO_Settings__c(
            VCC_SSO_Token__c = 'profile',
            VCC_VistA_Instance__c = 'test',
            VCC_DUZ__c = 'test',
            SetupOwnerId = UserInfo.getProfileId()
        );
        VCC_Mock_SSO_Settings__c orgSetting = new VCC_Mock_SSO_Settings__c(
            VCC_SSO_Token__c = 'org',
            VCC_VistA_Instance__c = 'test',
            VCC_DUZ__c = 'test',
            SetupOwnerId = UserInfo.getOrganizationId()
        );

        insert new List<VCC_Mock_SSO_Settings__c>{ userSetting, profileSetting, orgSetting };
    }
    /**
     * @description create a test user for running tests
     * @return A test user
     **/
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
    }

    @isTest
    public static void addSObjectFieldsTest() {
        System.runAs(getTestUser()) {
            VCC_MockSSOSettingsSelector mssoSelector = new VCC_MockSSOSettingsSelector();
            System.assert(!mssoSelector.getSObjectFieldList().contains(VCC_Mock_SSO_Settings__c.SystemModStamp), 'SObject field list already contains this field.');
            Test.startTest();
            mssoSelector.addSObjectFields(new List<SObjectField>{ VCC_Mock_SSO_Settings__c.SystemModStamp });
            Test.stopTest();
            System.assert(mssoSelector.getSObjectFieldList().contains(VCC_Mock_SSO_Settings__c.SystemModStamp), 'SObject field was not added as expected.');
        }
    }
    @isTest
    public static void selectByIdsTest() {
        System.runAs(getTestUser()) {
            VCC_MockSSOSettingsSelector mssoSelector = new VCC_MockSSOSettingsSelector();
            VCC_Mock_SSO_Settings__c msso = mssoSelector.selectOrgDefault();
            List<VCC_Mock_SSO_Settings__c> settings;
            Test.startTest();
            settings = mssoSelector.selectByIds(new Set<Id>{ msso.Id });
            Test.stopTest();

            System.assert(settings.size() == 1, 'Unexpected number of records returned.');
            System.assert(settings[0].Id == msso.Id, 'Returned Id does not match.');
        }
    }
    @isTest
    public static void selectByUserIdTest() {
        System.runAs(getTestUser()) {
            VCC_MockSSOSettingsSelector mssoSelector = new VCC_MockSSOSettingsSelector();
            System.assert(mssoSelector.selectByUserId(UserInfo.getUserId()) != null, 'Expected a record returned.');
        }
    }
    @isTest
    public static void selectByProfileIdTest() {
        System.runAs(getTestUser()) {
            VCC_MockSSOSettingsSelector mssoSelector = new VCC_MockSSOSettingsSelector();
            System.assert(mssoSelector.selectByProfileId(UserInfo.getProfileId()) != null, 'Expected a record returned.');
        }
    }
    @isTest
    public static void selectOrgDefaultTest() {
        System.runAs(getTestUser()) {
            VCC_MockSSOSettingsSelector mssoSelector = new VCC_MockSSOSettingsSelector();
            System.assert(mssoSelector.selectOrgDefault() != null, 'Expected a record returned.');
        }
    }
}
