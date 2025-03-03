@IsTest
public with sharing class VCC_TrainingModeAccountSelectorTest {
    @IsTest
    private static void ctor() {
        Test.startTest();
        VCC_TrainingModeAccountSelector accountSelector = new VCC_TrainingModeAccountSelector();
        Test.stopTest();

        System.assert(accountSelector != null, 'Expected the class to be initialized.');
    }

    @IsTest
    private static void addSObjectFields() {
        Test.startTest();
        VCC_TrainingModeAccountSelector accountSelector = new VCC_TrainingModeAccountSelector();
        Integer fieldCount = accountSelector.getSObjectFieldList().size();
        accountSelector.addSObjectFields(new List<SObjectField>{ Account.LastModifiedDate });
        Integer newFieldCount = accountSelector.getSObjectFieldList().size();
        Test.stopTest();

        System.assertEquals(fieldCount + 1, newFieldCount, 'Field count should have been increased by 1 field.');
    }

    @IsTest
    private static void selectById() {
        Account createdAccount = new Account(Name = 'selectById');
        insert createdAccount;

        Test.startTest();
        List<Account> accounts = new VCC_TrainingModeAccountSelector().selectById(new Set<Id>{ createdAccount.Id });
        Test.stopTest();

        System.assert(accounts != null);
        System.assertEquals(1, accounts.size(), 'Expected only 1 item in the list.');
        System.assertEquals(createdAccount.Id, accounts[0].Id, 'Expected Org Ids to match.');
    }

    @IsTest
    private static void selectTrainingAccountsByOwnerIdWithCases() {
        Account createdAccount = new Account(Name = 'selectByOwnerId', Is_Training_Account__c = true);
        insert createdAccount;

        Test.startTest();
        List<Account> accounts = new VCC_TrainingModeAccountSelector().selectTrainingAccountsByOwnerIdWithCases(new Set<Id>{ UserInfo.getUserId() });
        Test.stopTest();

        System.assert(accounts != null);
        System.assertEquals(1, accounts.size(), 'Expected only 1 item in the list.');
        System.assertEquals(createdAccount.Id, accounts[0].Id, 'Expected Org Ids to match.');
    }
}
