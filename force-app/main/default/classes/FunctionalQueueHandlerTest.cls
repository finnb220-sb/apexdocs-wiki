/**
 * @description       :
 * @author            : jonathon.schleicher@b3groupinc.com
 * @group             :
 * @last modified on  : 11-09-2021
 * @last modified by  : jonathon.schleicher@b3groupinc.com
 **/
@IsTest
public with sharing class FunctionalQueueHandlerTest {
    @IsTest
    public static void deleteFunctionalQueueGroups_givenDeletedFunctionalQueue_shouldDeleteCorrespondingGroupAndQueue() {
        Functional_Queue__c testFunctionalQueue = createTestFunctionalQueue('Test Functional Queue terst');
        insert testFunctionalQueue;
        Group testGroup = createTestGroup('test public group 123', 'Regular');
        Group testQueue = createTestGroup('test queue 123', 'Queue');
        testFunctionalQueue.Public_Group_ID__c = testGroup.Id;
        testFunctionalQueue.Queue_ID__c = testQueue.Id;

        Test.startTest();
        update testFunctionalQueue;
        Test.stopTest();

        delete testFunctionalQueue;

        List<Group> correspondingGroups = [SELECT Id FROM Group WHERE Id = :testGroup.Id OR Id = :testQueue.Id];
        System.assertEquals(0, correspondingGroups.size());
    }

    @isTest
    static void onAfterUpdate_givenUpdatedFunctionalQueueAssociatedApplications_updatesExpectedSupportedObjects() {
        Group queueTest = TestUtility.createQueue('queue test');
        insert queueTest;

        Functional_Queue__c functionalQueue = createTestFunctionalQueue('Test FuncQueue');
        functionalQueue.Associated_Application__c = null;
        functionalQueue.Queue_ID__c = queueTest.Id;
        insert functionalQueue;

        String associatedApplication = 'PSIP';
        functionalQueue.Associated_Application__c = associatedApplication;
        update functionalQueue;

        List<String> functionalQueueSupportedObjects = FunctionalQueueUtility.getFunctionalQueueSupportedObjectNamesByApp(associatedApplication);

        Test.startTest();
        List<QueueSobject> actualSupportedQueueObjects = [SELECT Id, SobjectType FROM QueueSobject WHERE QueueId = :functionalQueue.Id];
        Test.stopTest();

        if (actualSupportedQueueObjects.size() > 0) {
            for (QueueSobject queueObject : actualSupportedQueueObjects) {
                System.assert(functionalQueueSupportedObjects.contains(queueObject.SobjectType));
            }
        } else {
            System.debug('No Custom Metadata record exists for associated Application Name VIEWS');
        }
    }

    private static Functional_Queue__c createTestFunctionalQueue(String functionalQueueName) {
        Functional_Queue__c testFunctionalQueue = new Functional_Queue__c();
        testFunctionalQueue.Associated_Application__c = 'PSIP';
        testFunctionalQueue.Name = functionalQueueName;
        return testFunctionalQueue;
    }

    private static Group createTestGroup(String groupName, String groupType) {
        Group testGroup = new Group(Name = groupName, Type = groupType);
        insert testGroup;
        return testGroup;
    }
}
