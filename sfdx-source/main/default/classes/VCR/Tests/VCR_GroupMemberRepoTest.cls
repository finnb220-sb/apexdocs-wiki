/**
 * @description       : Test Class for VCR_GroupMemberRepo
 * @author            : Booz Allen Hamilton
 *
 * @see VCR_GroupMemberRepo
 **/
@IsTest
private with sharing class VCR_GroupMemberRepoTest {
    private static final String GROUP_NAME_STRING = 'Onboarding queue';
    private static final String GROUP_DEV_NAME_STRING = 'TUC_0_testgroup';
    private static final String GROUP_TYPE_STRING = 'Queue';

    /**
     * @description - Positive test case for fetchByUserOrGroupId()
     * Scenario covers a successful fetch of group member records using a provided user Id
     * @see VCR_GroupMemberRepo.fetchByUserOrGroupId()
     */
    @IsTest
    static void unitFetchByUserOrGroupIdPositive() {
        User testUser = VATEST_UserFactory.create(VATEST_UserPersonaEnum.Nurse, true);
        Group testGroup = (Group) VATEST_SObjectFactory.createSObject(
            new Group(Name = GROUP_NAME_STRING, DeveloperName = GROUP_DEV_NAME_STRING, Type = GROUP_TYPE_STRING),
            true
        );
        VATEST_SObjectFactory.createSObject(new GroupMember(GroupId = testGroup.Id, UserOrGroupId = testUser.Id), true);
        System.runAs(testUser) {
            Test.startTest();
            VCR_GroupMemberRepo repo = new VCR_GroupMemberRepo();
            List<GroupMember> groupMemberList = repo.fetchByUserOrGroupId(testUser.Id);
            Test.stopTest();
            Assert.isTrue(groupMemberList.size() > 0, 'Expected returned list to be greater than 0');
            GroupMember member = groupMemberList.get(0);
            Assert.areEqual(
                member.UserOrGroupId,
                testUser.Id,
                'Expected User ID and the returned Group Member UserOrGroupId to match'
            );
        }
    }

    /**
     * @description - Positive test case for fetchByUserOrGroupId()
     * Scenario covers a successful fetch of group member records using a provided user Id
     * @see VCR_GroupMemberRepo.fetchByUserOrGroupId()
     */
    @IsTest
    static void unitFetchByUserOrGroupIdMultipleGroupPositive() {
        User testUser = VATEST_UserFactory.create(VATEST_UserPersonaEnum.Nurse, true);
        Group testGroup = (Group) VATEST_SObjectFactory.createSObject(
            new Group(Name = GROUP_NAME_STRING, DeveloperName = GROUP_DEV_NAME_STRING, Type = GROUP_TYPE_STRING),
            true
        );
        Group testGroup2 = (Group) VATEST_SObjectFactory.createSObject(
            new Group(
                Name = GROUP_NAME_STRING + '1',
                DeveloperName = GROUP_DEV_NAME_STRING + '1',
                Type = GROUP_TYPE_STRING
            ),
            true
        );
        VATEST_SObjectFactory.createSObject(new GroupMember(GroupId = testGroup.Id, UserOrGroupId = testUser.Id), true);
        VATEST_SObjectFactory.createSObject(
            new GroupMember(GroupId = testGroup2.Id, UserOrGroupId = testUser.Id),
            true
        );
        System.runAs(testUser) {
            Test.startTest();
            VCR_GroupMemberRepo repo = new VCR_GroupMemberRepo();
            List<GroupMember> groupMemberList = repo.fetchByUserOrGroupId(testUser.Id);
            Test.stopTest();
            Assert.areEqual(2, groupMemberList.size(), 'Expected returned list to be 2');
        }
    }

    /**
     * @description - Negative test case for fetchByUserOrGroupId() covering empty inputs
     * @see VCR_GroupMemberRepo.fetchByUserOrGroupId()
     */
    @IsTest
    static void unitFetchByUserOrGroupIdEmptyNegative() {
        User testUser = VATEST_UserFactory.create(VATEST_UserPersonaEnum.Nurse, true);
        Group testGroup = (Group) VATEST_SObjectFactory.createSObject(
            new Group(Name = GROUP_NAME_STRING, DeveloperName = GROUP_DEV_NAME_STRING, Type = GROUP_TYPE_STRING),
            true
        );
        VATEST_SObjectFactory.createSObject(new GroupMember(GroupId = testGroup.Id, UserOrGroupId = testUser.Id), true);
        System.runAs(testUser) {
            Test.startTest();
            VCR_GroupMemberRepo repo = new VCR_GroupMemberRepo();
            try {
                repo.fetchByUserOrGroupId('');
                Assert.fail('Expected a string exception to occur, but the test proceeded and hit an Assert.fail()');
            } catch (StringException expectedException) {
                Assert.isTrue(
                    true,
                    'We asserted True due to catching a StringException, this message should not occur'
                );
            } catch (Exception wildException) {
                Assert.isTrue(false, 'Expected a string exception to occur, but found a wild exception');
            }
            Test.stopTest();
        }
    }

    /**
     * @description - Negative test case for fetchByUserOrGroupId() covering null inputs
     * @see VCR_GroupMemberRepo.fetchByUserOrGroupId()
     */
    @IsTest
    static void unitFetchByUserOrGroupIdNullNegative() {
        User testUser = VATEST_UserFactory.create(VATEST_UserPersonaEnum.Nurse, true);
        Group testGroup = (Group) VATEST_SObjectFactory.createSObject(
            new Group(Name = GROUP_NAME_STRING, DeveloperName = GROUP_DEV_NAME_STRING, Type = GROUP_TYPE_STRING),
            true
        );
        VATEST_SObjectFactory.createSObject(new GroupMember(GroupId = testGroup.Id, UserOrGroupId = testUser.Id), true);
        System.runAs(testUser) {
            Test.startTest();
            VCR_GroupMemberRepo repo = new VCR_GroupMemberRepo();
            List<GroupMember> groupMemberList = repo.fetchByUserOrGroupId(null);
            Test.stopTest();
            Assert.isTrue(groupMemberList.isEmpty(), 'Expected returned list to be empty');
        }
    }
}
