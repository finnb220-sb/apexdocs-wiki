@isTest
public with sharing class VCC_TestConfigurationDataSelectorTest {
    @isTest
    public static void instantiationTest() {
        Test.startTest();
        VCC_TestConfigurationDataSelector testConfigurationDataSelector = new VCC_TestConfigurationDataSelector();
        Test.stopTest();

        System.assert(testConfigurationDataSelector != null, 'Did not instantiate as expected.');
    }

    @isTest
    public static void addSObjectFieldsTest() {
        VCC_TestConfigurationDataSelector testConfigurationDataSelector = new VCC_TestConfigurationDataSelector();

        System.assert(!testConfigurationDataSelector.getSObjectFieldList().contains(VCC_Test_Configuration_Data__c.SystemModstamp), 'Selector already contains the field to test.');

        Test.startTest();
        testConfigurationDataSelector.addSObjectFields(new List<SObjectField>{ VCC_Test_Configuration_Data__c.SystemModstamp });
        Test.stopTest();

        System.assert(testConfigurationDataSelector.getSObjectFieldList().contains(VCC_Test_Configuration_Data__c.SystemModstamp), 'Selector did not add SObject field correctly.');
    }

    @IsTest
    static void selectVdifTestPatientDataTest() {
        VCC_Test_Configuration_Data__c config = new VCC_Test_Configuration_Data__c(
            RecordTypeId = VCC_Test_Configuration_Data__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Vdif_Test_Patient').getRecordTypeId(),
            VCC_Service__c = 'Admin',
            VCC_Site_Code__c = '984',
            VCC_Org_Type__c = (new VCC_OrgSettingsSelector()).selectByOrgId(UserInfo.getOrganizationId()).vccType__c,
            VCC_Note_Title_IEN__c = 'test',
            VCC_ICN__c = 'test'
        );

        VCC_Test_Configuration_Data__c config2 = new VCC_Test_Configuration_Data__c(
            RecordTypeId = VCC_Test_Configuration_Data__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Vdif_Test_Patient').getRecordTypeId(),
            VCC_Service__c = 'PharmacyI',
            VCC_Site_Code__c = '984',
            VCC_Org_Type__c = (new VCC_OrgSettingsSelector()).selectByOrgId(UserInfo.getOrganizationId()).vccType__c,
            VCC_Note_Title_IEN__c = 'test',
            VCC_ICN__c = 'test'
        );

        VCC_Test_Configuration_Data__c config3 = new VCC_Test_Configuration_Data__c(
            RecordTypeId = VCC_Test_Configuration_Data__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Vdif_Test_Patient').getRecordTypeId(),
            VCC_Service__c = 'PharmacyI',
            VCC_Site_Code__c = '983',
            VCC_Org_Type__c = (new VCC_OrgSettingsSelector()).selectByOrgId(UserInfo.getOrganizationId()).vccType__c,
            VCC_Note_Title_IEN__c = 'test',
            VCC_ICN__c = 'test'
        );

        insert new List<VCC_Test_Configuration_Data__c>{ config, config2, config3 };

        Test.startTest();
        VCC_TestConfigurationDataSelector testConfigurationDataSelector = new VCC_TestConfigurationDataSelector();
        List<VCC_Test_Configuration_Data__c> testConfigDataList = testConfigurationDataSelector.selectVdifTestPatientData(new List<String>{ '984' });
        System.assert(testConfigDataList[0].Id == config.Id, 'Expected matching Id\'s');
        System.assert(testConfigDataList[1].Id == config2.Id, 'Expected matching Id\'s');
        System.assert(testConfigDataList.size() == 2, 'Expected list of size 2.');
        Test.stopTest();
    }

    @IsTest
    static void selectVdifTestPatientDataByServiceAndSiteTest() {
        VCC_Test_Configuration_Data__c config2 = new VCC_Test_Configuration_Data__c(
            RecordTypeId = VCC_Test_Configuration_Data__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Vdif_Test_Patient').getRecordTypeId(),
            VCC_Service__c = 'PharmacyI',
            VCC_Site_Code__c = '985',
            VCC_Org_Type__c = (new VCC_OrgSettingsSelector()).selectByOrgId(UserInfo.getOrganizationId()).vccType__c,
            VCC_Note_Title_IEN__c = 'test',
            VCC_ICN__c = 'test'
        );
        insert config2;

        Test.startTest();
        System.assert((new VCC_TestConfigurationDataSelector()).selectVdifTestPatientDataByServiceAndSite('985', 'PharmacyI')[0].Id == config2.Id, 'Expected Id\'s to match.');
        Test.stopTest();
    }
}
