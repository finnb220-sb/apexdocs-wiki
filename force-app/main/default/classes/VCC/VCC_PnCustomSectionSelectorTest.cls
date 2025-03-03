@isTest
public with sharing class VCC_PnCustomSectionSelectorTest {
    @isTest
    public static void instantiationTest() {
        Test.startTest();
        VCC_ProgressNoteCustomSectionSelector progressNoteCustomSectionSelector = new VCC_ProgressNoteCustomSectionSelector();
        Test.stopTest();

        Assert.isTrue(progressNoteCustomSectionSelector != null, 'Did not instantiate as expected.');
    }

    @isTest
    public static void addSObjectFieldsTest() {
        VCC_ProgressNoteCustomSectionSelector progressNoteCustomSectionSelector = new VCC_ProgressNoteCustomSectionSelector();

        Assert.isTrue(
            !progressNoteCustomSectionSelector.getSObjectFieldList()
                .contains(VCC_Progress_Note_Custom_Section__mdt.Label),
            'Selector already contains the field to test.'
        );

        Test.startTest();
        progressNoteCustomSectionSelector.addSObjectFields(
            new List<SObjectField>{ VCC_Progress_Note_Custom_Section__mdt.Label }
        );
        Test.stopTest();

        Assert.isTrue(
            progressNoteCustomSectionSelector.getSObjectFieldList()
                .contains(VCC_Progress_Note_Custom_Section__mdt.Label),
            'Selector did not add SObject field correctly.'
        );
    }

    @isTest
    public static void selectByIdsTest() {
        VCC_ProgressNoteCustomSectionSelector progressNoteCustomSectionSelector = new VCC_ProgressNoteCustomSectionSelector();
        VCC_Progress_Note_Custom_Section__mdt pnConfig = [
            SELECT Id
            FROM VCC_Progress_Note_Custom_Section__mdt
            LIMIT 1
        ];

        Test.startTest();
        List<VCC_Progress_Note_Custom_Section__mdt> pnConfigs = progressNoteCustomSectionSelector.selectByIds(
            new Set<Id>{ pnConfig.Id }
        );
        Test.stopTest();

        Assert.isTrue(pnConfigs.size() == 1, 'Expected one record returned.');
    }

    /*  @isTest
    public static void selectByParentConfig(){
        VCC_ProgressNoteCustomSectionSelector progressNoteCustomSectionSelector = new VCC_ProgressNoteCustomSectionSelector();
        VCC_Progress_Note_Parsing_Configuration__mdt pnConfig = [
            SELECT Id, Record_Type_API_Name__c
            FROM VCC_Progress_Note_Parsing_Configuration__mdt
            WHERE Record_Type_API_Name__c = 'VCC_Clinical_Triage_Note_Progress_Note'
            LIMIT 1
        ];

        System.assert(pnConfig != null, 'The config doesn\'t exist to test with, try another.');
        Test.startTest();
        List<VCC_Progress_Note_Custom_Section__mdt> testConfig = progressNoteCustomSectionSelector.selectByParentConfigId(pnConfig.Id);
        Test.stopTest();

        System.assert(testConfig != null, 'Expected one record returned.');
    } */

    @isTest
    public static void selectByParentConfig() {
        VCC_ProgressNoteCustomSectionSelector progressNoteCustomSectionSelector = new VCC_ProgressNoteCustomSectionSelector();
        VCC_Progress_Note_Configuration__mdt pnConfig = [
            SELECT Id, VCC_Record_Type_API_Name__c
            FROM VCC_Progress_Note_Configuration__mdt
            WHERE VCC_Record_Type_API_Name__c = 'VCC_Clinical_Triage_Note_Progress_Note'
            LIMIT 1
        ];

        Assert.isTrue(pnConfig != null, 'The config doesn\'t exist to test with, try another.');
        Test.startTest();
        List<VCC_Progress_Note_Custom_Section__mdt> testConfig = progressNoteCustomSectionSelector.selectByParentConfigId(
            pnConfig.Id
        );
        Test.stopTest();

        Assert.isTrue(testConfig != null, 'Expected one record returned.');
    }
}
