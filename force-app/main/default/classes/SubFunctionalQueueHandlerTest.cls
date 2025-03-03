/**
 * @description       :
 * @author            : jonathon.schleicher@b3groupinc.com
 * @group             :
 * @last modified on  : 10-25-2021
 * @last modified by  : jonathon.schleicher@b3groupinc.com
 **/
@IsTest
private class SubFunctionalQueueHandlerTest {
    @isTest
    static void onBeforeInsert_givenNewSubFunctionalQueuesThatAlreadyExistsOnFunctionalQueue_addsDuplicateSubFunctionalQueueError() {
        Functional_Queue__c parentFunctionalQueue = new Functional_Queue__c();
        parentFunctionalQueue.Name = 'test func q';
        insert parentFunctionalQueue;

        Functional_Queue__c childFunctionalQueue = new Functional_Queue__c();
        childFunctionalQueue.Name = 'test child func q';
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
        Sub_Functional_Queue__c duplicateSubFunctionalQueue = new Sub_Functional_Queue__c();
        duplicateSubFunctionalQueue.Sub_Functional_Queue__c = childFunctionalQueue.Id;
        duplicateSubFunctionalQueue.Parent_Functional_Queue__c = parentFunctionalQueue.Id;
        try {
            insert duplicateSubFunctionalQueue;
        } catch (Exception e) {
            System.assert(e.getMessage().contains('This Sub Functional Queue is already a member of this Functional Queue.'));
        }
        Test.stopTest();
    }

    @isTest
    static void onBeforeInsert_givenNewSubFunctionalQueuesThatContainsParentFunctionalQueueAsASubFunctionalQueue_addsCircularReferenceError() {
        Functional_Queue__c parentFunctionalQueue = new Functional_Queue__c();
        parentFunctionalQueue.Name = 'test func q';
        insert parentFunctionalQueue;

        Functional_Queue__c childFunctionalQueue = new Functional_Queue__c();
        childFunctionalQueue.Name = 'test child func q';
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
        Sub_Functional_Queue__c circularReferenceSubFunctionalQueue = new Sub_Functional_Queue__c();
        circularReferenceSubFunctionalQueue.Sub_Functional_Queue__c = parentFunctionalQueue.Id;
        circularReferenceSubFunctionalQueue.Parent_Functional_Queue__c = childFunctionalQueue.Id;
        try {
            insert circularReferenceSubFunctionalQueue;
        } catch (Exception e) {
            System.assert(
                e.getMessage()
                    .contains(
                        'The Sub Functional Queue you are attempting to add will cause a circular reference error as it already contains the Functional Queue you are attempting to add it to.'
                    )
            );
        }
        Test.stopTest();
    }

    @isTest
    static void onBeforeInsert_givenNewSubFunctionalQueuesThatIsTheSameFunctionalQueueBeingAddedTo_addsCannotAddItselfError() {
        Functional_Queue__c parentFunctionalQueue = new Functional_Queue__c();
        parentFunctionalQueue.Name = 'test func q';
        insert parentFunctionalQueue;

        Set<Id> functionalQueueIds = new Set<Id>();
        functionalQueueIds.add(parentFunctionalQueue.Id);
        FunctionalQueueUtility.createQueueGroupIfAssociatedFunctionalQueueIsNonExistent(functionalQueueIds);

        Test.startTest();
        Sub_Functional_Queue__c selfSubFunctionalQueue = new Sub_Functional_Queue__c();
        selfSubFunctionalQueue.Sub_Functional_Queue__c = parentFunctionalQueue.Id;
        selfSubFunctionalQueue.Parent_Functional_Queue__c = parentFunctionalQueue.Id;
        try {
            insert selfSubFunctionalQueue;
        } catch (Exception e) {
            System.assert(e.getMessage().contains('You cannot add a Functional Queue to itself.'));
        }
        Test.stopTest();
    }

    @isTest
    static void onAfterInsert_givenNewSubFunctionalQueues_insertsExpectedCorrespondingGroupMembersToFunctionalQueuesCorrespondingGroup() {
        Functional_Queue__c parentFunctionalQueue = new Functional_Queue__c();
        parentFunctionalQueue.Name = 'test func q';
        insert parentFunctionalQueue;

        Functional_Queue__c childFunctionalQueue = new Functional_Queue__c();
        childFunctionalQueue.Name = 'test child func q';
        insert childFunctionalQueue;

        Set<Id> functionalQueueIds = new Set<Id>();
        functionalQueueIds.add(parentFunctionalQueue.Id);
        functionalQueueIds.add(childFunctionalQueue.Id);
        FunctionalQueueUtility.createQueueGroupIfAssociatedFunctionalQueueIsNonExistent(functionalQueueIds);

        Sub_Functional_Queue__c subFunctionalQueue = new Sub_Functional_Queue__c();
        subFunctionalQueue.Sub_Functional_Queue__c = childFunctionalQueue.Id;
        subFunctionalQueue.Parent_Functional_Queue__c = parentFunctionalQueue.Id;

        Test.startTest();
        insert subFunctionalQueue;
        Test.stopTest();

        Set<Id> subFunctionalQueueIds = new Set<Id>{ subFunctionalQueue.Id };
        List<Sub_Functional_Queue__c> updatedSubFunctionalQueue = FunctionalQueueUtility.getSubFunctionalQueuesByIds(subFunctionalQueueIds);
        Id groupId = updatedSubFunctionalQueue[0].Parent_Functional_Queue__r.Public_Group_ID__c;
        Set<Id> groupIds = new Set<Id>{ groupId };
        List<GroupMember> correspondingGroupMembers = FunctionalQueueUtility.getGroupMembersByGroupIds(groupIds);

        System.assertEquals(1, correspondingGroupMembers.size());
    }

    @isTest
    static void onBeforeDelete_givenDeletedSubFunctionalQueues_deletesCorrespondingGroupMembersFromCorrespondingFunctionalQueueGroups() {
        Functional_Queue__c parentFunctionalQueue = new Functional_Queue__c();
        parentFunctionalQueue.Name = 'test func q';
        insert parentFunctionalQueue;

        Functional_Queue__c childFunctionalQueue = new Functional_Queue__c();
        childFunctionalQueue.Name = 'test child func q';
        insert childFunctionalQueue;

        Set<Id> functionalQueueIds = new Set<Id>();
        functionalQueueIds.add(parentFunctionalQueue.Id);
        functionalQueueIds.add(childFunctionalQueue.Id);
        FunctionalQueueUtility.createQueueGroupIfAssociatedFunctionalQueueIsNonExistent(functionalQueueIds);

        Sub_Functional_Queue__c subFunctionalQueue = new Sub_Functional_Queue__c();
        subFunctionalQueue.Sub_Functional_Queue__c = childFunctionalQueue.Id;
        subFunctionalQueue.Parent_Functional_Queue__c = parentFunctionalQueue.Id;
        insert subFunctionalQueue;

        Set<Id> subFunctionalQueueIds = new Set<Id>{ subFunctionalQueue.Id };
        List<Sub_Functional_Queue__c> updatedSubFunctionalQueue = FunctionalQueueUtility.getSubFunctionalQueuesByIds(subFunctionalQueueIds);

        Test.startTest();
        delete subFunctionalQueue;
        Test.stopTest();

        Id groupId = updatedSubFunctionalQueue[0].Parent_Functional_Queue__r.Public_Group_ID__c;
        Set<Id> groupIds = new Set<Id>{ groupId };
        List<GroupMember> correspondingGroupMembers = FunctionalQueueUtility.getGroupMembersByGroupIds(groupIds);

        System.assertEquals(0, correspondingGroupMembers.size());
    }
}
