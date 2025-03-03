@IsTest
public with sharing class VCC_AccountSelectorTest {
    @IsTest
    private static void ctor() {
        Test.startTest();
        VCC_AccountSelector accountSelector = new VCC_AccountSelector();
        Test.stopTest();

        System.assert(accountSelector != null, 'Expected the class to be initialized.');
    }

    @IsTest
    private static void addSObjectFields() {
        Test.startTest();
        VCC_AccountSelector accountSelector = new VCC_AccountSelector();
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
        List<Account> accounts = new VCC_AccountSelector().selectById(new Set<Id>{ createdAccount.Id });
        Test.stopTest();

        System.assert(accounts != null);
        System.assertEquals(1, accounts.size(), 'Expected only 1 item in the list.');
        System.assertEquals(createdAccount.Id, accounts[0].Id, 'Expected Org Ids to match.');
    }

    @IsTest
    private static void selectByTaxId() {
        Account createdAccount = new Account(Name = 'selectByTaxId', HealthCloudGA__TaxId__c = '444444444');
        insert createdAccount;

        Test.startTest();
        List<Account> accounts = new VCC_AccountSelector().selectByTaxId(createdAccount.HealthCloudGA__TaxId__c);
        Test.stopTest();

        System.assert(accounts != null);
    }

    @IsTest
    private static void selectByICN() {
        String RecTypeId = [SELECT Id FROM RecordType WHERE Name = 'Person Account' AND SobjectType = 'Account'].Id;

        Account createdAccount = new Account(
            RecordTypeID = RecTypeId,
            FirstName = 'Test FName',
            LastName = 'Test LName',
            PersonMailingStreet = 'test@yahoo.com',
            PersonMailingPostalCode = '12345',
            PersonMailingCity = 'SFC',
            PersonEmail = 'test@yahoo.com',
            PersonHomePhone = '1234567',
            PersonMobilePhone = '12345678',
            VCC_MVI_External_Id__pc = '1013060957V646684'
        );
        insert createdAccount;

        Test.startTest();
        List<Account> accounts = new VCC_AccountSelector().selectByICN(new Set<String>{ createdAccount.VCC_MVI_External_Id__pc });
        Test.stopTest();

        System.assert(accounts != null);
        System.assertEquals(1, accounts.size(), 'Expected only 1 item in the list.');
        System.assertEquals(createdAccount.VCC_MVI_External_Id__pc, accounts[0].VCC_MVI_External_Id__pc, 'Expected External Ids to match.');
    }

    @IsTest
    private static void selectAccountsBySearchQuery() {
        String RecTypeId = [SELECT Id FROM RecordType WHERE Name = 'Person Account' AND SobjectType = 'Account'].Id;

        Account createdAccount = new Account(
            RecordTypeID = RecTypeId,
            FirstName = 'Test FName',
            LastName = 'Test LName',
            PersonMailingStreet = 'test@yahoo.com',
            PersonMailingPostalCode = '12345',
            PersonMailingCity = 'SFC',
            PersonEmail = 'test@yahoo.com',
            PersonHomePhone = '1234567',
            PersonMobilePhone = '12345678',
            VCC_MVI_External_Id__pc = '1013060957V646684'
        );
        insert createdAccount;

        Map<String, Object> params = new Map<String, Object>{ 'firstName' => 'Test FName', 'lastName' => 'Test LName' };
        VCC_QueryParams searchParams = new VCC_QueryParams();
        searchParams.queryParams.add(
            new VCC_QueryParam(Account.FirstName, VCC_QueryParam.QueryParamCondition.CONTAINS, VCC_QueryParam.QueryParamType.STRINGTYPE, (String) params.get('firstName'))
        );
        searchParams.queryParams.add(
            new VCC_QueryParam(Account.LastName, VCC_QueryParam.QueryParamCondition.CONTAINS, VCC_QueryParam.QueryParamType.STRINGTYPE, (String) params.get('lastName'))
        );

        Test.startTest();
        List<Account> accounts = new VCC_AccountSelector().selectAccountsBySearchQuery(searchParams);
        Test.stopTest();

        System.assert(accounts != null);
        System.assertEquals(1, accounts.size(), 'Expected only 1 item in the list.');
        System.assertEquals(createdAccount.Id, accounts[0].Id, 'Expected Org Ids to match.');
    }
}
