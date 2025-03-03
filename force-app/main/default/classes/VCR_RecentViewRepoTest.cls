/**
 * @author Booz Allen Hamilton
 * @description  Tests for VCR_RecentViewRepo class.
 * @group Booz Allen
 * @see VCR_RecentViewRepo
 */
@IsTest
public with sharing class VCR_RecentViewRepoTest {
    private static final User STANDARD_USER;

    static {
        STANDARD_USER = new VATEST_UserBuilder()
            .withUserProfile('Standard User')
            .withPermissionSet('VAHC_Standard_VCC_User')
            .withStandardData()
            .build(true);
    }

    /**
     * @description test repo instantiation
     */
    @IsTest
    static void unitTestConstructorPositive() {
        System.runAs(STANDARD_USER) {
            VCR_RecentViewRepo repo;
            Test.startTest();
            repo = new VCR_RecentViewRepo();
            Test.stopTest();
            Assert.isNotNull(repo, 'Expected constructor to properly instantiate a VCR_RecentViewRepo');
        }
    }

    /**
     * @description test getRecentViewFromUser() positive
     */
    @IsTest
    static void unitTestGetRecentViewFromUserPositive() {
        System.runAs(STANDARD_USER) {
            VCR_RecentViewRepo repo = new VCR_RecentViewRepo();
            List<VCC_Recent_View__c> recentViewList = new List<VCC_Recent_View__c>();
            Test.startTest();
            recentViewList = repo.getRecentViewFromUser();
            Test.stopTest();
            Assert.isNotNull(recentViewList, 'Expected recentViewList to not be null');
        }
    }

    /**
     * @description test getRecentViewFromUser() negative
     */
    @IsTest
    static void unitTestGetRecentViewFromUserNegative() {
        System.runAs(STANDARD_USER) {
            VCR_RecentViewRepo repo = new VCR_RecentViewRepo();
            List<VCC_Recent_View__c> recentViewList = new List<VCC_Recent_View__c>();
            Test.startTest();
            recentViewList = repo.getRecentViewFromUser();
            delete recentViewList;
            recentViewList = repo.getRecentViewFromUser();
            Test.stopTest();
            Assert.isNotNull(recentViewList, 'Expected recentViewList to be null');
            Assert.areEqual(recentViewList.size(), 0, 'Expected recentViewList to be null');
        }
    }
}
