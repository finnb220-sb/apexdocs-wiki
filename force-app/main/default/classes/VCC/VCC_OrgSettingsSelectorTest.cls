/**
 * VCC_OrgSettingsSelectorTest
 * @description Test for VCC_OrgSettingsSelector class.
 * @author Liberty
 * @date 12/1/2021
 */
@IsTest
private with sharing class VCC_OrgSettingsSelectorTest {
    @testSetup
    static void makeData() {
        VCC_TestDataFactory.insertUser('System Administrator');
    }

    /**
     * @description create a test user for running tests
     * @return A test user
     */
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
    }

    @IsTest
    private static void ctor() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_OrgSettingsSelector orgSettingsSelector = new VCC_OrgSettingsSelector();
            Test.stopTest();

            System.assert(orgSettingsSelector != null, 'Expected the class to be initialized.');
        }
    }

    @IsTest
    private static void addSObjectFields() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_OrgSettingsSelector orgSettingsSelector = new VCC_OrgSettingsSelector();
            Integer fieldCount = orgSettingsSelector.getSObjectFieldList().size();
            orgSettingsSelector.addSObjectFields(new List<SObjectField>{ Account.LastModifiedDate });
            Integer newFieldCount = orgSettingsSelector.getSObjectFieldList().size();
            Test.stopTest();

            System.assertEquals(fieldCount + 1, newFieldCount, 'Field count should have been increased by 1 field.');
        }
    }

    @IsTest
    private static void selectById() {
        VCC_Org_Settings__mdt queriedOrgSettings = [SELECT Id, vccOrgId__c, vccType__c FROM VCC_Org_Settings__mdt LIMIT 1];
        System.runAs(getTestUser()) {
            Test.startTest();
            List<VCC_Org_Settings__mdt> orgSettings = new VCC_OrgSettingsSelector().selectById(new Set<Id>{ queriedOrgSettings.Id });
            Test.stopTest();

            System.assert(orgSettings != null, 'Expected org settings should have a value');
            System.assertEquals(1, orgSettings.size(), 'Expected only 1 item in the list.');
            System.assertEquals(queriedOrgSettings.vccOrgId__c, orgSettings[0].vccOrgId__c, 'Expected Org Ids to match.');
        }
    }

    @IsTest
    private static void selectByOrgId() {
        System.runAs(getTestUser()) {
            VCC_Org_Settings__mdt queriedOrgSettings = [SELECT Id, vccOrgId__c, vccType__c FROM VCC_Org_Settings__mdt LIMIT 1];

            Test.startTest();
            VCC_Org_Settings__mdt orgSettings = new VCC_OrgSettingsSelector().selectByOrgId(queriedOrgSettings.vccOrgId__c);
            Test.stopTest();

            System.assert(orgSettings != null, 'Expected org settins to have been created');
            System.assertEquals(queriedOrgSettings.vccOrgId__c, orgSettings.vccOrgId__c, 'Expected Org Ids to match.');
        }
    }
}
