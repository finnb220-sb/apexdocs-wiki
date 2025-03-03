/**
 * @description       : Test Class for VCR_GroupRepo
 * @author            : Booz Allen Hamilton
 *
 * @see VCR_GroupRepo
 **/
@IsTest
private with sharing class VCR_GroupRepoTest {
    private static final String GROUP_NAME_STRING = 'Onboarding queue';
    private static final String GROUP_DEV_NAME_STRING = 'TUC_0_testgroup';
    private static final String GROUP_TYPE_STRING = 'Queue';

    /**
     * @description - Positive test case for fetchByDeveloperName()
     * Scenario covers a successful fetch of a group record
     * @see VCR_GroupRepo.fetchByDeveloperName()
     */
    @IsTest
    static void unitFetchByDeveloperNamePositive() {
        Group testGroup = (Group) VATEST_SObjectFactory.createSObject(
            new Group(Name = GROUP_NAME_STRING, DeveloperName = GROUP_DEV_NAME_STRING, Type = GROUP_TYPE_STRING),
            true
        );
        System.runAs(VATEST_UserFactory.create(VATEST_UserPersonaEnum.Nurse, true)) {
            Test.startTest();
            VCR_GroupRepo repo = new VCR_GroupRepo();
            Group groupRecord = repo.fetchByDeveloperName(GROUP_DEV_NAME_STRING);
            Test.stopTest();
            Assert.isNotNull(groupRecord, 'Expected returned group to not be null');
            Assert.areEqual(testGroup.Id, groupRecord.Id, 'Expected the group IDs to match');
        }
    }

    /**
     * @description - Negative test case for fetchByDeveloperName()
     * Scenario covers a null response due to a mismatching input
     * @see VCR_GroupRepo.fetchByDeveloperName()
     */
    @IsTest
    static void unitFetchByDeveloperNameWrongNegative() {
        VATEST_SObjectFactory.createSObject(
            new Group(Name = GROUP_NAME_STRING, DeveloperName = GROUP_DEV_NAME_STRING, Type = GROUP_TYPE_STRING),
            true
        );
        System.runAs(VATEST_UserFactory.create(VATEST_UserPersonaEnum.Nurse, true)) {
            Test.startTest();
            VCR_GroupRepo repo = new VCR_GroupRepo();
            Group groupRecord = repo.fetchByDeveloperName(GROUP_DEV_NAME_STRING + '1');
            Test.stopTest();
            Assert.isNull(groupRecord, 'Expected returned group to be null');
        }
    }

    /**
     * @description - Negative test case for fetchByDeveloperName()
     * Scenario covers a null response due to empty input
     * @see VCR_GroupRepo.fetchByDeveloperName()
     */
    @IsTest
    static void unitFetchByDeveloperNameEmptyNegative() {
        System.runAs(VATEST_UserFactory.create(VATEST_UserPersonaEnum.Nurse, true)) {
            Test.startTest();
            VCR_GroupRepo repo = new VCR_GroupRepo();
            Group groupRecord = repo.fetchByDeveloperName('');
            Test.stopTest();
            Assert.isNull(groupRecord, 'Expected returned group to be null');
        }
    }

    /**
     * @description - Negative test case for fetchByDeveloperName()
     * Scenario covers a null response due to null input
     * @see VCR_GroupRepo.fetchByDeveloperName()
     */
    @IsTest
    static void unitFetchByDeveloperNameNullNegative() {
        System.runAs(VATEST_UserFactory.create(VATEST_UserPersonaEnum.Nurse, true)) {
            Test.startTest();
            VCR_GroupRepo repo = new VCR_GroupRepo();
            Group groupRecord = repo.fetchByDeveloperName(null);
            Test.stopTest();
            Assert.isNull(groupRecord, 'Expected returned group to be null');
        }
    }

    /**
     * @description - Positive test case for fetchByGroupIdList()
     * Scenario covers a successful fetch of group records using an idList
     * @see VCR_GroupRepo.fetchByGroupIdList()
     */
    @IsTest
    static void unitFetchByGroupIdListPositive() {
        Group testGroup = (Group) VATEST_SObjectFactory.createSObject(
            new Group(Name = GROUP_NAME_STRING, DeveloperName = GROUP_DEV_NAME_STRING, Type = GROUP_TYPE_STRING),
            true
        );
        System.runAs(VATEST_UserFactory.create(VATEST_UserPersonaEnum.Nurse, true)) {
            Test.startTest();
            List<Id> groupIdList = new List<Id>{ testGroup.Id };
            VCR_GroupRepo repo = new VCR_GroupRepo();
            List<Group> groupList = repo.fetchByGroupIdList(groupIdList);
            Test.stopTest();
            Assert.isTrue(groupList.size() > 0, 'Expected returned list to be greater than 0');
        }
    }

    /**
     * @description - Negative test case for fetchByGroupIdList()
     * Scenario covers a fetch of an empty list due to empty list input
     * @see VCR_GroupRepo.fetchByGroupIdList()
     */
    @IsTest
    static void unitFetchByGroupIdListEmptyNegative() {
        System.runAs(VATEST_UserFactory.create(VATEST_UserPersonaEnum.Nurse, true)) {
            Test.startTest();
            VCR_GroupRepo repo = new VCR_GroupRepo();
            List<Group> groupList = repo.fetchByGroupIdList(new List<Id>{});
            Test.stopTest();
            Assert.isTrue(groupList.isEmpty(), 'Expected returned list to be empty');
        }
    }

    /**
     * @description - Negative test case for fetchByGroupIdList()
     * Scenario covers a fetch of an empty list due to null input
     * @see VCR_GroupRepo.fetchByGroupIdList()
     */
    @IsTest
    static void unitFetchByGroupIdListNullNegative() {
        System.runAs(VATEST_UserFactory.create(VATEST_UserPersonaEnum.Nurse, true)) {
            Test.startTest();
            VCR_GroupRepo repo = new VCR_GroupRepo();
            List<Group> groupList = repo.fetchByGroupIdList(null);
            Test.stopTest();
            Assert.isTrue(groupList.isEmpty(), 'Expected returned list to be empty');
        }
    }
}
