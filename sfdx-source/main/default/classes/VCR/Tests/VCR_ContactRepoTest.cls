/**
 * @author Booz Allen Hamilton
 * @date 2/14/24
 * @description  Tests for VCR_ContactRepo class.
 * @group Depeche Code
 * @see VCR_ContactRepo
 *
 * NOTE: Suppressing warning for PMD.ApexUnitTestClassShouldHaveRunAs as there is no need to use System.RunAs for the
 *  Repository functional tests.
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest
public class VCR_ContactRepoTest {
    /**
     * @description Test fetchById() for success path
     */
    @IsTest
    static void unitTestConstructorPositive() {
        Test.startTest();
        VCR_ContactRepo repo = new VCR_ContactRepo();
        Test.stopTest();
        Assert.isNotNull(repo, 'Expected constructor to properly instantiate a VCR_ContactRepo');
    }

    /**
     * @description Test getContactFromAccountIdPositive() when a contact record exists for the given account id
     */
    @IsTest
    static void funcGetContactFromAccountIdPositive() {
        Account acc = (Account) VATEST_SObjectFactory.createSObject(new Account(Name = 'Test Account'), true);
        VATEST_SObjectFactory.createSObject(new Contact(AccountId = acc.Id), true);
        Test.startTest();
        VCR_ContactRepo repo = new VCR_ContactRepo();
        List<Contact> result = repo.getContactFromAccountId(acc.Id);
        Test.stopTest();

        Assert.areEqual(result.size(), 1, 'Expected a single record to be retrieved but was not');
        Assert.areEqual(
            result[0].AccountId,
            acc.Id,
            'Expected retrieved record to have a matching account id but retrieved another record'
        );
    }

    /**
     * @description Test getContactFromAccountIdNegative() when a contact record does not exists for the given account id
     */
    @IsTest
    static void funcGetContactFromAccountIdNegative() {
        Account acc = (Account) VATEST_SObjectFactory.createSObject(new Account(Name = 'Test Account'), true);
        Test.startTest();
        VCR_ContactRepo repo = new VCR_ContactRepo();
        List<Contact> result = repo.getContactFromAccountId(acc.Id);
        Test.stopTest();

        Assert.areEqual(result.size(), 0, 'Expected no records to be retrieved but list is not empty');
    }

    /**
     * @description Test retrieving contacts when given a list of account ids positive
     */
    @IsTest
    static void funcGetContactFromAccountSetPositive() {
        Account acc1 = (Account) VATEST_SObjectFactory.createSObject(new Account(Name = 'Test Account'), true);
        Account acc2 = (Account) VATEST_SObjectFactory.createSObject(new Account(Name = 'Test Account2'), true);
        Set<String> accountIds = new Set<String>{ acc1.Id, acc2.Id };
        VATEST_SObjectFactory.createSObject(new Contact(AccountId = acc1.Id), true);
        VATEST_SObjectFactory.createSObject(new Contact(AccountId = acc2.Id), true);
        Test.startTest();
        VCR_ContactRepo repo = new VCR_ContactRepo();
        List<Contact> results = repo.getContactFromAccountSet(accountIds);
        Test.stopTest();

        Assert.areEqual(results.size(), 2, 'Expected two records to be retrieved but instead got ' + results.size());
        for (Contact contactRecord : results) {
            Assert.isTrue(
                accountIds.contains(contactRecord.AccountId),
                'Expected retrieved record to have a matching account id but instead got ' + contactRecord
            );
        }
    }

    /**
     * @description Test retrieving contact when given a list of ICNs positive
     */
    @IsTest
    static void funcGetContactFromIcnSetPositive() {
        Account acc1 = (Account) VATEST_SObjectFactory.createSObject(new Account(Name = 'Test Account1'), true);
        Account acc2 = (Account) VATEST_SObjectFactory.createSObject(new Account(Name = 'Test Account2'), true);
        Set<String> icnTestSet = new Set<String>{ '1234', '5678' };
        VATEST_SObjectFactory.createSObject(new Contact(AccountId = acc1.Id, VCC_MVI_External_Id__c = '1234'), true);
        VATEST_SObjectFactory.createSObject(new Contact(AccountId = acc2.Id, VCC_MVI_External_Id__c = '5678'), true);

        Test.startTest();
        VCR_ContactRepo repo = new VCR_ContactRepo();
        List<Contact> results = repo.getContactFromIcnSet(icnTestSet);
        Test.stopTest();
        Assert.areEqual(results.size(), 2, 'Expected two records to be retrieved but instead got ' + results.size());
        for (Contact contactRecord : results) {
            Assert.isTrue(
                icnTestSet.contains(contactRecord.VCC_MVI_External_Id__c),
                'Expected retrieved record to have a matching ICN but instead got ' + contactRecord
            );
        }
    }
}
