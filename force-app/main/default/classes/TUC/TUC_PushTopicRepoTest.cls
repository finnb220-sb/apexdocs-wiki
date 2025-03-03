/**
 * @description Tests the TUC_PushTopicRepo class
 * @author Booz Allen Hamilton
 *
 * @see TUC_PushTopicRepo for class being tested
 *
 */
@isTest
private with sharing class TUC_PushTopicRepoTest {
    private static final String PUSH_TOPIC_CHANNEL_NAME_STRING = 'TeleTopic_Test';
    private static final String DOCTOR_PERM_SET_NAME = 'TED_Medical_Provider_Group';
    private static final String VAVET_BASE_PROFILE_NAME = 'VAVET Base Profile';

    @isTest
    private static void unitInitialSanityCheck() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet(DOCTOR_PERM_SET_NAME)
            .withUserProfile(VAVET_BASE_PROFILE_NAME)
            .withStandardData()
            .build(true);
        System.runAs(doctorUser) {
            List<PushTopic> pushTopicList = [
                SELECT Id, Name
                FROM PushTopic
                WHERE Name = :PUSH_TOPIC_CHANNEL_NAME_STRING
            ];
            Assert.areEqual(0, pushTopicList.size(), 'Expected an empty list');
        }
    }

    @isTest
    private static void unitPushTopicPositive() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet(DOCTOR_PERM_SET_NAME)
            .withUserProfile(VAVET_BASE_PROFILE_NAME)
            .withStandardData()
            .build(true);
        System.runAs(doctorUser) {
            TUC_PushTopicRepo pushTopicRepo = new TUC_PushTopicRepo();
            pushTopicRepo.setTeleECKanbanPushTopic(PUSH_TOPIC_CHANNEL_NAME_STRING);
            List<PushTopic> pushTopicList = [
                SELECT Id, Name
                FROM PushTopic
                WHERE Name = :PUSH_TOPIC_CHANNEL_NAME_STRING
            ];
            Assert.areEqual(1, pushTopicList.size(), 'Expected a new push topic to be created');
        }
    }

    @isTest
    private static void unitPushTopicDoubleInputPositive() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet(DOCTOR_PERM_SET_NAME)
            .withUserProfile(VAVET_BASE_PROFILE_NAME)
            .withStandardData()
            .build(true);
        System.runAs(doctorUser) {
            TUC_PushTopicRepo pushTopicRepo = new TUC_PushTopicRepo();
            pushTopicRepo.setTeleECKanbanPushTopic(PUSH_TOPIC_CHANNEL_NAME_STRING);
            List<PushTopic> pushTopicList = [
                SELECT Id, Name
                FROM PushTopic
                WHERE Name = :PUSH_TOPIC_CHANNEL_NAME_STRING
            ];
            Assert.areEqual(1, pushTopicList.size(), 'Expected a new push topic to be created');
            pushTopicRepo.setTeleECKanbanPushTopic(PUSH_TOPIC_CHANNEL_NAME_STRING);
            pushTopicList = [
                SELECT Id, Name
                FROM PushTopic
                WHERE Name = :PUSH_TOPIC_CHANNEL_NAME_STRING
            ];
            Assert.areEqual(1, pushTopicList.size(), 'Expected the number of push topic channels to remain the same');
        }
    }

    @isTest
    private static void unitPushTopicEmptyNegative() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet(DOCTOR_PERM_SET_NAME)
            .withUserProfile(VAVET_BASE_PROFILE_NAME)
            .withStandardData()
            .build(true);
        System.runAs(doctorUser) {
            TUC_PushTopicRepo pushTopicRepo = new TUC_PushTopicRepo();
            pushTopicRepo.setTeleECKanbanPushTopic('');
            List<PushTopic> pushTopicList = [
                SELECT Id, Name
                FROM PushTopic
                WHERE Name = :PUSH_TOPIC_CHANNEL_NAME_STRING
            ];
            Assert.areEqual(
                0,
                pushTopicList.size(),
                'Expected there to be no new Push Topic Channels created, but found ' +
                    pushTopicList.size() +
                    ' new Push Topic Channels.'
            );
        }
    }

    @isTest
    private static void unitPushTopicNullNegative() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet(DOCTOR_PERM_SET_NAME)
            .withUserProfile(VAVET_BASE_PROFILE_NAME)
            .withStandardData()
            .build(true);
        System.runAs(doctorUser) {
            TUC_PushTopicRepo pushTopicRepo = new TUC_PushTopicRepo();
            pushTopicRepo.setTeleECKanbanPushTopic(null);
            List<PushTopic> pushTopicList = [
                SELECT Id, Name
                FROM PushTopic
                WHERE Name = :PUSH_TOPIC_CHANNEL_NAME_STRING
            ];
            Assert.areEqual(
                0,
                pushTopicList.size(),
                'Expected there to be no new Push Topic Channels created, but found ' +
                    pushTopicList.size() +
                    ' new Push Topic Channels.'
            );
        }
    }
}
