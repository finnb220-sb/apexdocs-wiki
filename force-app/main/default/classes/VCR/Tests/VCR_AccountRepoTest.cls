/**
 * @author Booz Allen Hamilton
 * @date 2/2/24
 *
 * @description  VCR_AccountRepo Tests
 *
 * @group Depeche Code
 * @modified October 17, 2024
 *
 * @see VCR_AccountRepo for class being tested
 *
 * NOTE: Suppressing warning for PMD.ApexUnitTestClassShouldHaveRunAs as there is no need to use System.RunAs for the
 *  Repository functional tests.
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest
public with sharing class VCR_AccountRepoTest {
    /**
     * @description This is a custom defaults class for handling PersonAccount field defaults to
     *  instantiate in the tests
     */
    public class TestPersonAccountDefaults implements VATEST_SObjectFactory.FieldDefaults {
        /**
         * @description Interface required method returning default values for fields
         * @param prototype SObject - any constructed SObject to populate
         * @return Map<Schema.SObjectField, Object> map of fields and default values
         */
        public Map<Schema.SObjectField, Object> getFieldDefaults(SObject prototype) {
            return new Map<Schema.SObjectField, Object>{
                Account.FirstName => 'Harry',
                Account.LastName => 'Potter',
                Account.RecordTypeId => Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                    .getRecordTypeInfosByDeveloperName()
                    .get('PersonAccount')
                    .getRecordTypeId(),
                Account.PersonEmail => 'harry@harrypotter.com'
            };
        }
    }

    /**
     * @description Build test data for use in test methods
     */
    @TestSetup
    private static void buildData() {
        getTestUser();
    }

    /**
     * @description builds test user using VATEST_UserBuilder
     * @return `User`
     */
    public static User getTestUser() {
        return new VATEST_UserBuilder()
            .withPermissionSet('MPI_E_Integration_User')
            .withPermissionSet('VAHC_Test_Data_Import')
            .withPermissionSet('Tele_EC_Read_Only')
            .withPermissionSet('MPIE_Authd_Data_Change')
            .withPermissionSet('VCC_Disable_Account_Validation_Rules')
            .withPermissionSet('DisableTriggersFlag')
            .withPermissionSet('Capstorm_Permission_set')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
    }

    /**
     * @description Inserts accounts using a data factory
     */
    public static void makeAccounts() {
        VATEST_SObjectFactory.createSObject(new Account(), 'VCR_AccountRepoTest.TestPersonAccountDefaults', true);
        VATEST_SObjectFactory.createSObject(new Account(Name = 'Test Non Person Account'), true);
    }

    /**
     * @description Test fetching PersonAccounts with Contact details for success path when there are no PersonAccounts
     */
    @IsTest
    static void unitTestFetchPersonAccountsWithContactInfoNoRecordsPositive() {
        makeAccounts();
        User testUser = [SELECT Id FROM User WHERE email = 'Testuser@test.example.com'][0];
        System.runAs(testUser) {
            Test.startTest();
            VCR_AccountRepo acctRepo = new VCR_AccountRepo();
            List<Account> testAccts = acctRepo.fetchPersonAccountsWithContactInfo();
            Test.stopTest();
            Assert.areEqual(
                1,
                testAccts.size(),
                'Expected one Account to be returned, but observed ' + testAccts.size()
            );
        }
    }

    /**
     * @description Test fetching PersonAccounts with Contact details for success path
     */
    @IsTest
    static void unitTestFetchPersonAccountsWithContactInfoPositive() {
        makeAccounts();
        User testUser = [SELECT Id FROM User WHERE email = 'Testuser@test.example.com'][0];
        System.runAs(testUser) {
            Test.startTest();
            VCR_AccountRepo acctRepo = new VCR_AccountRepo();
            List<Account> testAccts = acctRepo.fetchPersonAccountsWithContactInfo();
            Test.stopTest();
            Assert.areEqual(
                testAccts.size(),
                [SELECT COUNT() FROM Account WHERE IsPersonAccount = TRUE],
                'Failed to return number of Person Accounts.'
            );
            Account personAcct = testAccts[0];
            Assert.areEqual(
                'Harry',
                personAcct.FirstName,
                'Expected PersonAccount to be inserted with FirstName = "Harry" but observed PersonAccount with FirstName = ' +
                personAcct.FirstName
            );
        }
    }

    /**
     * @description Test fetching PersonAccounts with via ICN for success path
     */
    @IsTest
    static void unitTestFetchPersonAccountsViaICNPositive() {
        makeAccounts();
        User testUser = [SELECT Id FROM User WHERE email = 'Testuser@test.example.com'][0];
        System.runAs(testUser) {
            Test.startTest();
            List<Account> accts = new VCR_AccountRepo().fetchPersonAccountsViaICN(new Set<String>{ '2211' });
            Assert.areEqual(
                0,
                accts.size(),
                'Expected that the account repo does not return a match for the icn 2211 actual: ' + accts.size()
            );
            Test.stopTest();
        }
    }

    /**
     * @description Test fetching deceased PersonAccounts failure path
     */
    @IsTest
    static void unitFetchDeceasedPersonAccountsNegative() {
        makeAccounts();
        User testUser = [SELECT Id FROM User WHERE email = 'Testuser@test.example.com'][0];
        System.runAs(testUser) {
            Test.startTest();
            List<Account> accts = new VCR_AccountRepo()
                .fetchDeceasedPersonAccounts(new Set<String>{ SchemaHelper.GenerateIdFor(Account.SObjectType) });
            Assert.areEqual(
                0,
                accts.size(),
                'Expected that the account repo does not return a deceased account, actual: ' + accts.size()
            );
            Test.stopTest();
        }
    }

    /**
     * @description Test fetching deceased PersonAccounts success path
     */
    @IsTest
    static void unitFetchDeceasedPersonAccountsPositive() {
        makeAccounts();
        User testUser = [SELECT Id FROM User WHERE email = 'Testuser@test.example.com'][0];
        System.runAs(testUser) {
            String accountId = [SELECT Id FROM Account WHERE IsPersonAccount = TRUE LIMIT 1][0].Id;
            Test.startTest();
            List<Account> testAccts = new VCR_AccountRepo().fetchDeceasedPersonAccounts(new Set<String>{ accountId });
            Test.stopTest();
            Assert.areEqual(
                1,
                testAccts.size(),
                'Expected one deceased patient account to be returned. Observed: ' + testAccts.size()
            );
        }
    }

    /**
     * @description test inserting account with repo
     */
    @IsTest
    static void unitInsertAccountsAllOrNoneFalse() {
        makeAccounts();
        User testUser = [SELECT Id FROM User WHERE Email = 'Testuser@test.example.com'][0];
        VCR_AccountRepo repo = new VCR_AccountRepo();
        List<Account> accountList = new List<Account>();
        Account accountToInsert = new Account(
            FirstName = 'Test',
            LastName = 'Account',
            RecordTypeId = repo.recordTypeConstant.fromDeveloperName('PersonAccount').Id
        );
        accountList.add(accountToInsert);
        System.runAs(testUser) {
            Test.startTest();
            List<Database.SaveResult> results = repo.insertAccountsAllOrNoneFalse(accountList);
            for (Database.SaveResult result : results) {
                if (result.success) {
                    continue;
                } else {
                    Assert.fail(
                        'Expected insert to succeed but instead it failed with these errors ' + result.toString()
                    );
                }
            }
            Test.stopTest();
        }

        List<Account> insertedAccounts = [SELECT Id FROM Account WHERE LastName = 'Account'];
        Assert.areEqual(
            1,
            insertedAccounts.size(),
            'Expected account to be inserted. Observed: ' + insertedAccounts.size()
        );
    }

    /**
     * @description Test deleting account with repo
     */
    @IsTest
    static void unitDeleteAccountsAllOrNoneFalse() {
        makeAccounts();
        User testUser = [SELECT Id FROM User WHERE email = 'Testuser@test.example.com'][0];
        List<Account> testAccounts = [SELECT Id FROM Account WHERE IsPersonAccount = TRUE LIMIT 1];
        VCR_AccountRepo repo = new VCR_AccountRepo();
        System.runAs(testUser) {
            Test.startTest();
            repo.deleteAccountsAllOrNoneFalse(testAccounts);
            Test.stopTest();
            List<Account> deletedAccounts = [SELECT Id FROM Account WHERE IsPersonAccount = TRUE LIMIT 1];
            Assert.areNotEqual(
                testAccounts.size(),
                deletedAccounts.size(),
                'Expected no account to be returned. Observed: ' + deletedAccounts.size()
            );
        }
    }
}
