/**
 * VCC_TrainingModeDataSelectorTest
 * @description Unit test for VCC_TrainingModeDataSelector class.
 * @author Liberty
 * @date 12/8/2021
 */
@IsTest
public with sharing class VCC_TrainingModeDataSelectorTest {
    @IsTest
    private static void ctor() {
        VCC_TrainingModeDataSelector trainingModeDataSelector;
        User testUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        List<String> permissionSets = new List<String>{ 'VCC_Trainee', 'VCC_Trainer' };
        DTCTestUtil.addPermSetsToUser(testUser, permissionSets);
        System.runAs(testUser) {
            Test.startTest();
            trainingModeDataSelector = new VCC_TrainingModeDataSelector();
            Test.stopTest();
        }
        System.assert(trainingModeDataSelector != null, 'Expected the class to be initialized.');
    }

    @IsTest
    private static void addSObjectFields() {
        Integer fieldCount;
        Integer newFieldCount;
        User testUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        List<String> permissionSets = new List<String>{ 'VCC_Trainee', 'VCC_Trainer' };
        DTCTestUtil.addPermSetsToUser(testUser, permissionSets);
        System.runAs(testUser) {
            Test.startTest();
            VCC_TrainingModeDataSelector trainingModeDataSelector = new VCC_TrainingModeDataSelector();
            fieldCount = trainingModeDataSelector.getSObjectFieldList().size();
            trainingModeDataSelector.addSObjectFields(new List<SObjectField>{ Account.LastModifiedDate });
            newFieldCount = trainingModeDataSelector.getSObjectFieldList().size();
            Test.stopTest();
        }
        System.assertEquals(fieldCount + 1, newFieldCount, 'Field count should have been increased by 1 field.');
    }

    @IsTest
    private static void selectById() {
        Account createdAccount = new Account(Name = 'selectById');
        insert createdAccount;
        VCC_Training_Mode_Data__c createdTrainingModeData = new VCC_Training_Mode_Data__c(Name = createdAccount.Name, Account__c = createdAccount.Id);
        insert createdTrainingModeData;

        List<VCC_Training_Mode_Data__c> trainingModeData;
        User testUser = VCC_TestDataFactory.insertUser('System Administrator');
        System.runAs(testUser) {
            Test.startTest();
            trainingModeData = new VCC_TrainingModeDataSelector().selectById(new Set<Id>{ createdTrainingModeData.Id });
            Test.stopTest();
        }
        System.assert(trainingModeData != null);
        System.assertEquals(1, trainingModeData.size(), 'Expected only 1 item in the list.');
        System.assertEquals(createdTrainingModeData.Id, trainingModeData[0].Id, 'Expected Org Ids to match.');
    }

    @IsTest
    private static void selectByAccountId() {
        Account createdAccount = new Account(Name = 'selectMedicationsByAccountId');
        insert createdAccount;

        Set<Id> accId = new Set<Id>();
        accId.add(createdAccount.Id);

        List<VCC_Training_Mode_Data__c> trainingModeData;
        User testUser = VCC_TestDataFactory.insertUser('System Administrator');
        System.runAs(testUser) {
            Test.startTest();
            trainingModeData = new VCC_TrainingModeDataSelector().selectByAccountId(accId);
            Test.stopTest();
        }
        Assert.isNotNull(trainingModeData, 'Expected class to be initialized');
    }
    @IsTest
    private static void selectByAccountIdAndType() {
        Account createdAccount = new Account(Name = 'selectMedicationsByAccountId');
        insert createdAccount;
        List<VCC_Training_Mode_Data__c> trainingModeData;
        User testUser = VCC_TestDataFactory.insertUser('System Administrator');
        System.runAs(testUser) {
            Test.startTest();
            trainingModeData = new VCC_TrainingModeDataSelector().selectByAccountIdAndType(createdAccount.Id, 'test');
            Test.stopTest();
        }
        Assert.isNotNull(trainingModeData, 'Expected class to be initialized');
    }

    @IsTest
    private static void selectMasterByAccountIdAndType() {
        Account createdAccount = new Account(Name = 'selectMedicationsByAccountId');
        insert createdAccount;
        List<VCC_Training_Mode_Data__c> trainingModeData;
        User testUser = VCC_TestDataFactory.insertUser('System Administrator');
        System.runAs(testUser) {
            Test.startTest();
            trainingModeData = new VCC_TrainingModeDataSelector().selectMasterByAccountIdAndType(createdAccount.Id, 'test');
            Test.stopTest();
        }
        Assert.isNotNull(trainingModeData, 'Expected class to be initialized');
    }
}
