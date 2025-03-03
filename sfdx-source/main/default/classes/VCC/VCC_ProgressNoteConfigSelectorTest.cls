@isTest
public with sharing class VCC_ProgressNoteConfigSelectorTest {
    @testSetup
    static void makeData() {
        VCC_TestDataFactory.insertUser('System Administrator');
    }
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
    }
    @isTest
    public static void instantiationTest() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_ProgressNoteConfigSelector progressNoteConfigSelector = new VCC_ProgressNoteConfigSelector();
            Test.stopTest();

            System.assert(progressNoteConfigSelector != null, 'Did not instantiate as expected.');
        }
    }

    @isTest
    public static void addSObjectFieldsTest() {
        System.runAs(getTestUser()) {
            VCC_ProgressNoteConfigSelector progressNoteConfigSelector = new VCC_ProgressNoteConfigSelector();

            System.assert(
                !progressNoteConfigSelector.getSObjectFieldList().contains(VCC_Progress_Note_Configuration__mdt.MasterLabel),
                'Selector already contains the field to test.'
            );

            Test.startTest();
            progressNoteConfigSelector.addSObjectFields(new List<SObjectField>{ VCC_Progress_Note_Configuration__mdt.MasterLabel });
            Test.stopTest();

            System.assert(
                progressNoteConfigSelector.getSObjectFieldList().contains(VCC_Progress_Note_Configuration__mdt.MasterLabel),
                'Selector did not add SObject field correctly.'
            );
        }
    }

    @isTest
    public static void selectByIdsTest() {
        System.runAs(getTestUser()) {
            VCC_ProgressNoteConfigSelector progressNoteConfigSelector = new VCC_ProgressNoteConfigSelector();
            VCC_Progress_Note_Configuration__mdt pnConfig = [
                SELECT Id
                FROM VCC_Progress_Note_Configuration__mdt
                LIMIT 1
            ];

            Test.startTest();
            List<VCC_Progress_Note_Configuration__mdt> pnConfigs = progressNoteConfigSelector.selectByIds(new Set<Id>{ pnConfig.Id });
            Test.stopTest();

            System.assert(pnConfigs.size() == 1, 'Expected one record returned.');
        }
    }

    @isTest
    public static void selectByRecordTypeAPINameTestSuccess() {
        System.runAs(getTestUser()) {
            VCC_ProgressNoteConfigSelector progressNoteConfigSelector = new VCC_ProgressNoteConfigSelector();
            VCC_Progress_Note_Configuration__mdt pnConfig = [
                SELECT Id, VCC_Record_Type_API_Name__c
                FROM VCC_Progress_Note_Configuration__mdt
                WHERE VCC_Record_Type_API_Name__c = 'VCC_Tier_I_Progress_Note'
                LIMIT 1
            ];

            System.assert(pnConfig != null, 'The config doesn\'t exist to test with, try another.');
            Test.startTest();
            VCC_Progress_Note_Configuration__mdt testConfig = progressNoteConfigSelector.selectByRecordTypeAPIName('VCC_Tier_I_Progress_Note');
            Test.stopTest();

            System.assert(testConfig != null, 'Expected one record returned.');
            System.assert(testConfig.VCC_Record_Type_API_Name__c == pnConfig.VCC_Record_Type_API_Name__c, 'Mismatch.');
        }
    }

    @isTest
    public static void selectByRecordTypeAPINameTestFail() {
        System.runAs(getTestUser()) {
            VCC_ProgressNoteConfigSelector progressNoteConfigSelector = new VCC_ProgressNoteConfigSelector();

            Test.startTest();
            VCC_Progress_Note_Configuration__mdt testConfig = progressNoteConfigSelector.selectByRecordTypeAPIName('fakename');
            Test.stopTest();

            System.assert(testConfig == null, 'Expected null.');
        }
    }

    @isTest
    public static void selectByNameTest() {
        System.runAs(getTestUser()) {
            VCC_ProgressNoteConfigSelector progressNoteConfigSelector = new VCC_ProgressNoteConfigSelector();
            VCC_Progress_Note_Configuration__mdt pnConfig = [
                SELECT Id, VCC_Record_Type_API_Name__c
                FROM VCC_Progress_Note_Configuration__mdt
                WHERE VCC_Record_Type_API_Name__c = 'VCC_Tier_I_Progress_Note'
                LIMIT 1
            ];

            System.assert(pnConfig != null, 'The config doesn\'t exist to test with, try another.');
            Test.startTest();
            VCC_Progress_Note_Configuration__mdt testConfig = progressNoteConfigSelector.selectByName('Tier_I_Config');
            Test.stopTest();

            System.assert(testConfig != null, 'Expected one record returned.');
            System.assert(testConfig.VCC_Record_Type_API_Name__c == pnConfig.VCC_Record_Type_API_Name__c, 'Mismatch.');
        }
    }
}
