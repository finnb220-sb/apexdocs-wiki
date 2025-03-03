/**
 * VCC_TrainingModeDataTemplateSelectorTest
 * @description Unit test for VCC_TrainingModeDataTemplateSelector class.
 * @author Liberty
 * @date 12/9/2021
 */
@IsTest
public with sharing class VCC_TrainingModeDataTemplateSelectorTest {
    @IsTest
    private static void ctor() {
        Test.startTest();
        VCC_TrainingModeDataTemplateSelector trainingModeDataTemplateSelector = new VCC_TrainingModeDataTemplateSelector();
        Test.stopTest();

        System.assert(trainingModeDataTemplateSelector != null, 'Expected the class to be initialized.');
    }

    @IsTest
    private static void addSObjectFields() {
        Test.startTest();
        VCC_TrainingModeDataTemplateSelector trainingModeDataTemplateSelector = new VCC_TrainingModeDataTemplateSelector();
        Integer fieldCount = trainingModeDataTemplateSelector.getSObjectFieldList().size();
        trainingModeDataTemplateSelector.addSObjectFields(new List<SObjectField>{ Account.LastModifiedDate });
        Integer newFieldCount = trainingModeDataTemplateSelector.getSObjectFieldList().size();
        Test.stopTest();

        System.assertEquals(fieldCount + 1, newFieldCount, 'Field count should have been increased by 1 field.');
    }

    @IsTest
    private static void selectById() {
        Account createdAccount = new Account(Name = 'selectById');
        insert createdAccount;
        StaticResource createdTrainingModeTemplateData = [SELECT Id, Name, Body FROM StaticResource LIMIT 1];

        Test.startTest();
        List<StaticResource> trainingModeTemplateData = new VCC_TrainingModeDataTemplateSelector().selectById(new Set<Id>{ createdTrainingModeTemplateData.Id });
        Test.stopTest();

        System.assert(trainingModeTemplateData != null);
        System.assertEquals(1, trainingModeTemplateData.size(), 'Expected only 1 item in the list.');
        System.assertEquals(createdTrainingModeTemplateData.Id, trainingModeTemplateData[0].Id, 'Expected Ids to match.');
    }

    @IsTest
    private static void selectAll() {
        Integer trainingModeTemplateCount = [SELECT COUNT() FROM StaticResource WHERE Name LIKE 'VCC_TrainingTemplate%'];

        Test.startTest();
        List<StaticResource> trainingModeTemplateData = new VCC_TrainingModeDataTemplateSelector().selectAll();
        Test.stopTest();

        System.assert(trainingModeTemplateData != null);
        System.assertEquals(trainingModeTemplateCount, trainingModeTemplateData.size(), 'Expected the list sizes to match.');
    }
}
