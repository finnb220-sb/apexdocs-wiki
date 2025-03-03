/**
 * @description Tests the VCR_OrderRepoTest class
 * @author Booz Allen Hamilton
 *
 * @see VCR_OrgRepo for class being tested
 */
@IsTest
public with sharing class VCR_OrgRepoTest {
    @IsTest
    static void unitItConstructsPositive() {
        User vaVetUser = createTestUser();
        System.runAs(vaVetUser) {
            Test.startTest();
            VCR_OrgRepo repo = new VCR_OrgRepo();
            Test.stopTest();
            Assert.isNotNull(repo, 'Expected VCR_OrgRepo to have an argless constructor.');
        }
    }
    @IsTest
    static void unitItDoesNotQueryWhenOrgInfoIsSet() {
        Organization expectedOrgInfo = (Organization) VATEST_SObjectFactory.createSObject(new Organization());
        System.runAs(createTestUser()) {
            Test.startTest();
            VCR_OrgRepo.privateOrgInfo = (Organization) VATEST_SObjectFactory.createSObject(expectedOrgInfo);
            VCR_OrgRepo repo = new VCR_OrgRepo();
            Integer beforeOrgInfoQueryCount = Limits.getQueries();
            Organization actualOrgInfo = repo.orgInfo;
            Integer afterOrgInfoQueryCount = Limits.getQueries();
            Test.stopTest();
            Assert.areEqual(
                beforeOrgInfoQueryCount,
                afterOrgInfoQueryCount,
                'Expected VCR_OrgRepo to not query when org info is set.'
            );
            Assert.areEqual(actualOrgInfo, expectedOrgInfo, 'Expected VCR_OrgRepo to return stubbed value.');
        }
    }
    @IsTest
    static void funcItReturnsOrgInfoWhenNullPositive() {
        System.runAs(createTestUser()) {
            Test.startTest();
            VCR_OrgRepo repo = new VCR_OrgRepo();
            Test.stopTest();
            Assert.isNotNull(repo.orgInfo, 'Expected VCR_OrgRepo to implicitly return orgInfo when referenced.');
        }
    }

    private static User createTestUser() {
        return new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
    }
}
