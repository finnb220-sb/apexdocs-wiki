/**
 * @author Booz Allen Hamilton
 * @description  VCR_VaIdentityRepo Tests
 * @group Depeche Code
 *
 * @see VCR_VaIdentityRepo for class being tested
 *
 */
@IsTest
public with sharing class VCR_VaIdentityRepoTest {
    /**
     * @description Build test data for use in test methods
     */
    @TestSetup
    private static void buildData() {
        getTestUser();
    }

    /**
     * @description creates and inserts a test user using VATEST_UserBuilder
     * @return  `User`
     */
    private static User getTestUser() {
        return new VATEST_UserBuilder()
            .withPermissionSet('MPI_E_Integration_User')
            .withPermissionSet('VAHC_Test_Data_Import')
            .withUserProfile('System Administrator')
            .withStandardData()
            .build(true);
    }

    /**
     * @description creates and inserts a test user using VATEST_UserBuilder
     * @return  `User`
     */
    private static User getNegativeTestUser() {
        return new VATEST_UserBuilder()
            .withPermissionSet('MPI_E_Integration_User')
            .withPermissionSet('VAHC_Test_Data_Import')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
    }

    /**
     * @description Inserts va_identities using a data factory
     */
    private static void makeVAIdentityRecs() {
        VATEST_SObjectFactory.createSObject(new VA_Identity__c(), true);
        VATEST_SObjectFactory.createSObject(new VA_Identity__c(First_Name__c = 'Bingus'), true);
    }

    @IsTest
    private static void unitConstructorOverridePositive() {
        User testUser = [SELECT Id FROM User WHERE email = 'Testuser@test.example.com'][0];
        System.runAs(testUser) {
            VCR_VaIdentityRepo repo = new VCR_VaIdentityRepo(true);
            Assert.isNotNull(repo, 'Expected VCR_VaIdentityRepo to be instantiated');
        }
    }
    /**
     * @description Test fetching VA_Identity__c records by id
     */
    @IsTest
    private static void funcFetchVAIdentityRecordsByIdsPositive() {
        makeVAIdentityRecs();
        String vaIdRecordId = [
            SELECT Id, First_Name__c
            FROM VA_Identity__c
            WHERE First_Name__c = 'Bingus'
            LIMIT 1
        ][0]
        .Id;
        User testUser = [SELECT Id FROM User WHERE email = 'Testuser@test.example.com'][0];
        System.runAs(testUser) {
            Test.startTest();
            VCR_VaIdentityRepo vaIdRepo = new VCR_VaIdentityRepo();
            List<VA_Identity__c> testVAIdRecords = vaIdRepo.fetchVAIdentityRecordsByIds(
                new Set<String>{ vaIdRecordId }
            );
            Test.stopTest();
            Assert.areEqual(
                1,
                testVAIdRecords.size(),
                'Expected 1 VA Identity record, but Observed ' + testVAIdRecords.size()
            );
        }
    }

    /**
     * @description Test updating VA identity record with repo
     */
    @IsTest
    private static void unitUpdateVAIdentityPositive() {
        makeVAIdentityRecs();
        User testUser = [SELECT Id FROM User WHERE email = 'Testuser@test.example.com'][0];
        String vaIdentityId = [SELECT Id FROM VA_Identity__c WHERE First_Name__c = 'Bingus' LIMIT 1][0].Id;
        List<VA_Identity__c> identitiesToUpdate = new List<VA_Identity__c>();
        VA_Identity__c myVAId = new VA_Identity__c(Id = vaIdentityId, First_Name__c = 'Dango');
        identitiesToUpdate.add(myVAId);
        VCR_VaIdentityRepo repo = new VCR_VaIdentityRepo();
        System.runAs(testUser) {
            Test.startTest();
            repo.updateVAIdentitiesAllOrNoneFalse(identitiesToUpdate);
            Test.stopTest();
            List<VA_Identity__c> updatedVAIds = [SELECT Id FROM VA_Identity__c WHERE First_Name__c = 'Dango' LIMIT 1];
            Assert.areEqual(
                1,
                updatedVAIds.size(),
                'Expected one VA Identity record to be returned. Observed: ' + updatedVAIds.size()
            );
        }
    }

    @IsTest
    private static void unitGetQueryLocatorUnsafePositive() {
        System.runAs(getTestUser()) {
            VCR_VaIdentityRepo repo = new VCR_VaIdentityRepo();
            Database.QueryLocator queryLocator = repo.getQueryLocatorUnsafe('SELECT Id FROM VA_Identity__c');
            Assert.isNotNull(queryLocator, 'Expected QueryLocator to be returned');
        }
    }

    @IsTest
    private static void unitGetQueryLocatorWithBindsPositive() {
        Map<String, Object> bindParams = new Map<String, Object>();
        bindParams.put('Alias__c', 'Some Alias');
        System.runAs(getTestUser()) {
            VCR_VaIdentityRepo repo = new VCR_VaIdentityRepo();
            Database.QueryLocator queryLocator = repo.getQueryLocatorWithBinds(
                'SELECT Id, Alias__c FROM VA_Identity__c',
                bindParams
            );
            Assert.isNotNull(queryLocator, 'Expected QueryLocator to be returned');
        }
    }
}
