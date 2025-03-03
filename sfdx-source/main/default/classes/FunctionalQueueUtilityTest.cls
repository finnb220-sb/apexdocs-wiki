/**
 * @description       :
 * @author            : jonathon.schleicher@b3groupinc.com
 * @group             :
 * @last modified on  : 10-26-2021
 * @last modified by  : jonathon.schleicher@b3groupinc.com
 **/
@IsTest
private class FunctionalQueueUtilityTest {
    @isTest
    static void createQueueGroupIfAssociatedFunctionalQueueIsNonExistent_givenRelatedFunctionalQueueIdsWithoutCorrespondingGroup_createsCorrespondingGroupAndQueueAndUpdatesFunctionalQueue() {
        Functional_Queue__c testFunctionalQueue = new Functional_Queue__c();
        testFunctionalQueue.Name = 'test func q';
        testFunctionalQueue.Associated_Application__c = 'PSIP';
        insert testFunctionalQueue;
        Set<Id> functionalQueueIds = new Set<Id>{ testFunctionalQueue.Id };

        Test.startTest();
        FunctionalQueueUtility.createQueueGroupIfAssociatedFunctionalQueueIsNonExistent(functionalQueueIds);
        Test.stopTest();

        List<Group> correspondingGroups = [SELECT Id, Name FROM Group WHERE Name = :testFunctionalQueue.Name AND Type = 'Regular'];
        Functional_Queue__c updatedFunctionalQueue = [SELECT Id, Name, Public_Group_ID__c, Queue_ID__c FROM Functional_Queue__c WHERE Id = :testFunctionalQueue.Id];

        System.assertEquals(1, correspondingGroups.size());
        System.assertEquals(updatedFunctionalQueue.Public_Group_ID__c, correspondingGroups[0].Id);
    }

    @isTest
    static void getFunctionalQueuesMapByIds_givenFunctionalQueueIds_returnsExpectedMap() {
        Functional_Queue__c testFunctionalQueue = new Functional_Queue__c();
        testFunctionalQueue.Name = 'test func q';
        insert testFunctionalQueue;
        Set<Id> functionalQueueIds = new Set<Id>{ testFunctionalQueue.Id };

        Test.startTest();
        Map<Id, Functional_Queue__c> functionalQueuesMap = FunctionalQueueUtility.getFunctionalQueuesMapByIds(functionalQueueIds);
        Test.stopTest();

        System.assertEquals(testFunctionalQueue.Name, functionalQueuesMap.get(testFunctionalQueue.Id).Name);
    }

    @isTest
    static void getSubFunctionalQueuesByParentFunctionalQueueIds_givenParentFunctionalQueueIds_returnsExpectedSubFunctionalQueues() {
        Functional_Queue__c parentFunctionalQueue = new Functional_Queue__c();
        parentFunctionalQueue.Name = 'test func q';
        parentFunctionalQueue.Associated_Application__c = 'PSIP';
        insert parentFunctionalQueue;

        Functional_Queue__c childFunctionalQueue = new Functional_Queue__c();
        childFunctionalQueue.Name = 'test child func q';
        childFunctionalQueue.Associated_Application__c = 'PSIP';
        insert childFunctionalQueue;

        Set<Id> functionalQueueIds = new Set<Id>();
        functionalQueueIds.add(parentFunctionalQueue.Id);
        functionalQueueIds.add(childFunctionalQueue.Id);
        FunctionalQueueUtility.createQueueGroupIfAssociatedFunctionalQueueIsNonExistent(functionalQueueIds);

        Sub_Functional_Queue__c subFunctionalQueue = new Sub_Functional_Queue__c();
        subFunctionalQueue.Sub_Functional_Queue__c = childFunctionalQueue.Id;
        subFunctionalQueue.Parent_Functional_Queue__c = parentFunctionalQueue.Id;
        insert subFunctionalQueue;

        Test.startTest();
        List<Sub_Functional_Queue__c> subFunctionalQueues = FunctionalQueueUtility.getSubFunctionalQueuesByParentFunctionalQueueIds(functionalQueueIds);
        Test.stopTest();

        System.assertEquals(childFunctionalQueue.Id, subFunctionalQueues[0].Sub_Functional_Queue__c);
    }

    @isTest
    static void getFunctionalQueuesByIds_givenFunctionalQueueIds_returnsExpectedFunctionalQueues() {
        Functional_Queue__c testFunctionalQueue = new Functional_Queue__c();
        testFunctionalQueue.Name = 'test func q';
        insert testFunctionalQueue;
        Set<Id> functionalQueueIds = new Set<Id>{ testFunctionalQueue.Id };

        Test.startTest();
        List<Functional_Queue__c> functionalQueues = FunctionalQueueUtility.getFunctionalQueuesByIds(functionalQueueIds);
        Test.stopTest();

        System.assertEquals(testFunctionalQueue.Name, functionalQueues[0].Name);
        System.assertEquals(1, functionalQueues.size());
    }

    @isTest
    static void createGroupMemberByGroupIdAndUserOrGroupId_givenGroupIdAndUserOrGroupId_returnsExpectedGroupMember() {
        Id groupId = TestUtility.getFakeId(Group.SObjectType, 0);
        Id userOrGroupId = TestUtility.getFakeId(User.SObjectType, 0);

        Test.startTest();
        GroupMember viewsGroupMember = FunctionalQueueUtility.createGroupMemberByGroupIdAndUserOrGroupId(groupId, userOrGroupId);
        Test.stopTest();

        System.assertEquals(groupId, viewsGroupMember.GroupId);
        System.assertEquals(userOrGroupId, viewsGroupMember.UserOrGroupId);
    }

    @isTest
    static void getGroupMembersByGroupIds_givenGroupMemberIds_returnsExpectedGroupMembers() {
        Group testGroup = TestUtility.createGroup('test group name');
        insert testGroup;
        Group memberTestGroup = TestUtility.createGroup('member group name');
        insert memberTestGroup;

        GroupMember testGroupMember = new GroupMember(UserOrGroupId = memberTestGroup.Id, GroupId = testGroup.Id);
        insert testGroupMember;

        Set<Id> groupIds = new Set<Id>{ testGroupMember.GroupId };

        Test.startTest();
        List<GroupMember> groupMembers = FunctionalQueueUtility.getGroupMembersByGroupIds(groupIds);
        Test.stopTest();

        System.assertEquals(memberTestGroup.Id, groupMembers[0].UserOrGroupId);
    }

    @isTest
    static void addSerializedSupportedObjectsToQueue_givenSerializedQueueSObjects_savesExpectedQueueSObjects() {
        Group testQueue = TestUtility.createQueue('test queue');
        insert testQueue;

        QueueSobject queueObject = FunctionalQueueUtility.buildQueueSobjectByQueueIdAndSupportedObjectName('Case', testQueue.Id);
        List<QueueSobject> queueSobjects = new List<QueueSobject>{ queueObject };
        String serializedSupportedObjects = JSON.serialize(queueSobjects);

        Test.startTest();
        FunctionalQueueUtility.addSerializedSupportedObjectsToQueue(serializedSupportedObjects);
        Test.stopTest();

        List<QueueSobject> actualQueueSobjects = FunctionalQueueUtility.getQueueSObjectsByQueueIds(new Set<Id>{ testQueue.Id });
        System.assertEquals(1, actualQueueSobjects.size());
        System.assertEquals('Case', actualQueueSobjects[0].SobjectType);
    }

    @isTest
    static void deleteSerializedSupportedQueueObjects_givenSerializedQueueSObjects_deletesExpectedQueueSObjects() {
        Group testQueue = TestUtility.createQueue('test queue');
        insert testQueue;

        QueueSobject queueObject = FunctionalQueueUtility.buildQueueSobjectByQueueIdAndSupportedObjectName('Case', testQueue.Id);
        insert queueObject;

        List<QueueSobject> queueSobjectsToDelete = new List<QueueSobject>{ queueObject };
        String serializedSupportedObjectsToDelete = JSON.serialize(queueSobjectsToDelete);

        Test.startTest();
        FunctionalQueueUtility.deleteSerializedSupportedQueueObjects(serializedSupportedObjectsToDelete);
        Test.stopTest();

        List<QueueSobject> actualQueueSobjects = FunctionalQueueUtility.getQueueSObjectsByQueueIds(new Set<Id>{ testQueue.Id });
        System.assertEquals(0, actualQueueSobjects.size());
    }

    @isTest
    static void buildQueueSobjectByQueueIdAndSupportedObjectName_givenSupportedObjectNameAndQueueId_buildsExpectedQueueSObject() {
        Id queueId = TestUtility.getFakeId(QueueSobject.getSObjectType(), 0);
        String objectName = 'Case';

        Test.startTest();
        QueueSobject queueSobject = FunctionalQueueUtility.buildQueueSobjectByQueueIdAndSupportedObjectName(objectName, queueId);
        Test.stopTest();

        System.assertEquals(queueId, queueSobject.QueueId);
        System.assertEquals(objectName, queueSobject.SobjectType);
    }

    @isTest
    static void getSubFunctionalQueuesByIds_givenSubFunctionalQueueIdSet_returnsExpectedSubFunctionalQueues() {
        Functional_Queue__c parentFunctionalQueue = new Functional_Queue__c();
        parentFunctionalQueue.Name = 'test func q';
        parentFunctionalQueue.Associated_Application__c = 'PSIP';
        insert parentFunctionalQueue;

        Functional_Queue__c childFunctionalQueue = new Functional_Queue__c();
        childFunctionalQueue.Name = 'test child func q';
        childFunctionalQueue.Associated_Application__c = 'PSIP';
        insert childFunctionalQueue;

        User testUser = TestUtility.buildTestUserByFirstAndLastName('test', 'last');
        insert testUser;
        Account acc = TestUtility.createAccount('acc name');
        insert acc;

        Contact testContact = TestUtility.createContact(testUser.Id, 'last name ', acc.Id);
        insert testContact;

        Functional_Queue_Member__c functionalQueueMember = new Functional_Queue_Member__c();
        functionalQueueMember.Functional_Queue__c = childFunctionalQueue.Id;
        functionalQueueMember.Contact_Member__c = testContact.Id;
        insert functionalQueueMember;

        Test.startTest();
        Sub_Functional_Queue__c subFunctionalQueue;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            subFunctionalQueue = new Sub_Functional_Queue__c();
            subFunctionalQueue.Parent_Functional_Queue__c = parentFunctionalQueue.Id;
            subFunctionalQueue.Sub_Functional_Queue__c = childFunctionalQueue.Id;
            insert subFunctionalQueue;
        }

        Set<Id> subFunctionalQueueIdSet = new Set<Id>{ subFunctionalQueue.Id };
        List<Sub_Functional_Queue__c> actualSubFunctionalQueues = FunctionalQueueUtility.getSubFunctionalQueuesByIds(subFunctionalQueueIdSet);
        Test.stopTest();

        System.assertEquals(1, actualSubFunctionalQueues.size());
    }

    @isTest
    static void getQueueSObjectsByQueueIds_givenQueueIdsSet_returnsExpectedQueueSObjects() {
        Group testQueue = TestUtility.createQueue('test Queue');
        insert testQueue;
        QueueSobject queueSobject = FunctionalQueueUtility.buildQueueSobjectByQueueIdAndSupportedObjectName('Case', testQueue.Id);
        insert queueSobject;

        Test.startTest();
        List<QueueSobject> actualQueueSobjects = FunctionalQueueUtility.getQueueSObjectsByQueueIds(new Set<Id>{ queueSobject.QueueId });
        Test.stopTest();

        System.assertEquals(1, actualQueueSobjects.size());
    }

    // @isTest
    // static void getFunctionalQueueSupportedObjectsCustomMetaDataByAppNames_givenApplicationNames_returnsExpectedCustomMetaDataRecords() {

    //     Test.startTest();
    //         List<FunctionalQueue_Supported_Objects_By_App__mdt> functionalQueueSupportedObjectsByApps = FunctionalQueueUtility.getFunctionalQueueSupportedObjectsCustomMetaDataByAppNames(new Set<String>{'PSIP'});
    //     Test.stopTest();

    //     if (actualSupportedQueueObjects.size() > 0 ) {
    //         System.assertEquals(1, functionalQueueSupportedObjectsByApps.size());
    //     } else {
    //         System.debug('No Custom Metadata record exists for associated Application Name VIEWS');
    //     }
    // }

    @isTest
    static void deleteSharingRulesGivenFunctionalQueues_givenFunctionalQueue_shouldDeleteSharingRulesRelatedToFQ() {
        User testUser = TestUtility.buildTestUserByFirstAndLastName('Test', 'test123');
        insert testUser;

        Functional_Queue__c testFunctionalQueue = new Functional_Queue__c(Name = 'test');
        insert testFunctionalQueue;

        insert new Functional_Queue__share(ParentId = testFunctionalQueue.Id, UserOrGroupId = testUser.Id, AccessLevel = 'Edit', RowCause = 'Manual');

        Test.startTest();
        FunctionalQueueUtility.deleteSharingRulesGivenFunctionalQueues(new List<Functional_Queue__c>{ testFunctionalQueue });
        Test.stopTest();

        List<Functional_Queue__share> result = [SELECT Id FROM Functional_Queue__share WHERE ParentId = :testFunctionalQueue.Id AND RowCause = 'Manual'];
        System.assert(result.isEmpty());
    }
}
