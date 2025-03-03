/**
 * @description       :
 * @author            : jonathon.schleicher@b3groupinc.com
 * @group             :
 * @last modified on  : 10-25-2021
 * @last modified by  : jonathon.schleicher@b3groupinc.com
 **/
public without sharing class SubFunctionalQueueHandler {
    // Staging Reference Properties
    Set<Id> parentFunctionalQueueIds;
    Map<Id, Set<Id>> functionalQueueIdToSubFunctionalQueueIdsMap;
    Set<Id> subFunctionalQueueIds;
    Set<Id> subFunctionalQueueIdsToDelete;
    Set<Id> subFunctionalCorrespondingGroupIds;
    Map<Id, Set<Id>> parentSubFunctionalQueuesSetMap;

    // DML Reference Properties
    Set<Id> relatedGroupMemberIdsToDelete;

    public void OnBeforeInsert(List<Sub_Functional_Queue__c> subFunctionalQueues) {
        stageRelatedPropertiesAndDataForBeforeInsert(subFunctionalQueues);

        for (Sub_Functional_Queue__c subFunctionalQueue : subFunctionalQueues) {
            applyBeforeInsertLogic(subFunctionalQueue);
        }
    }

    public void OnAfterInsert(List<Sub_Functional_Queue__c> subFunctionalQueues) {
        stageRelatedPropertiesAndDataForAfterInsert(subFunctionalQueues);
        performDMLOperationsForAfterInsert();
    }

    public void OnBeforeDelete(List<Sub_Functional_Queue__c> deletedSubFunctionalQueues) {
        stageRelatedPropertiesForBeforeDelete(deletedSubFunctionalQueues);
        performDMLOperationsForBeforeDelete();
    }

    private void stageRelatedPropertiesAndDataForBeforeInsert(List<Sub_Functional_Queue__c> subFunctionalQueues) {
        stagingIterationForBeforeInsert(subFunctionalQueues);
        createAssociatedGroupIfNonExistent();
        stageParentFunctionalQueuesOfNewSubFunctionalQueuesWithFieldValues();
        buildFunctionalQueueIdToSubFunctionalQueueIdsMap();
    }

    private void stageRelatedPropertiesAndDataForAfterInsert(List<Sub_Functional_Queue__c> subFunctionalQueues) {
        stagingIterationForAfterInsert(subFunctionalQueues);
    }

    private void stageRelatedPropertiesForBeforeDelete(List<Sub_Functional_Queue__c> deletedSubFunctionalQueues) {
        stagingIterationForBeforeDelete(deletedSubFunctionalQueues);
        stageCorrespondingGroupMembersToDelete();
    }

    private void stagingIterationForBeforeInsert(List<Sub_Functional_Queue__c> subFunctionalQueues) {
        for (Sub_Functional_Queue__c subFunctionalQueue : subFunctionalQueues) {
            appendParentFunctionalQueueSet(subFunctionalQueue.Parent_Functional_Queue__c);
            appendSubFunctionalQueueSet(subFunctionalQueue.Sub_Functional_Queue__c);
        }
    }

    private void stagingIterationForAfterInsert(List<Sub_Functional_Queue__c> subFunctionalQueues) {
        for (Sub_Functional_Queue__c subFunctionalQueue : subFunctionalQueues) {
            appendSubFunctionalQueueSet(subFunctionalQueue.Id);
        }
    }

    private void stagingIterationForBeforeDelete(List<Sub_Functional_Queue__c> deletedSubFunctionalQueues) {
        for (Sub_Functional_Queue__c subFunctionalQueue : deletedSubFunctionalQueues) {
            appendDeletedSubFunctionalQueueSet(subFunctionalQueue);
        }
    }

    private void stageCorrespondingGroupMembersToDelete() {
        List<Sub_Functional_Queue__c> subFunctionalQueues = FunctionalQueueUtility.getSubFunctionalQueuesByIds(subFunctionalQueueIdsToDelete);

        Set<Id> parentGroupIds = new Set<Id>();
        for (Sub_Functional_Queue__c subFunctionalQueue : subFunctionalQueues) {
            parentGroupIds.add(subFunctionalQueue.Parent_Functional_Queue__r.Public_Group_ID__c);
        }

        List<GroupMember> parentGroupMembers = FunctionalQueueUtility.getGroupMembersByGroupIds(parentGroupIds);
        relatedGroupMemberIdsToDelete = new Set<Id>();
        for (Sub_Functional_Queue__c subFunctionalQueue : subFunctionalQueues) {
            for (GroupMember member : parentGroupMembers) {
                if (
                    member.UserOrGroupId == subFunctionalQueue.Sub_Functional_Queue__r.Public_Group_ID__c &&
                    member.GroupId == subFunctionalQueue.Parent_Functional_Queue__r.Public_Group_ID__c
                ) {
                    relatedGroupMemberIdsToDelete.add(member.Id);
                }
            }
        }
    }

    private void applyBeforeInsertLogic(Sub_Functional_Queue__c subFunctionalQueue) {
        addErrorIfSubFunctionalQueueExistsOnFunctionalQueue(subFunctionalQueue);
        addErrorIfCircularReferenceAttempt(subFunctionalQueue);
        addErrorIfAttemptingToAddFunctionalQueueToItself(subFunctionalQueue);
    }

    private void appendSubFunctionalQueueSet(Id subFunctionalQueueId) {
        if (subFunctionalQueueIds == null) {
            subFunctionalQueueIds = new Set<Id>();
        }
        subFunctionalQueueIds.add(subFunctionalQueueId);
    }

    private void appendParentFunctionalQueueSet(Id parentFunctionalQueueId) {
        if (parentFunctionalQueueIds == null) {
            parentFunctionalQueueIds = new Set<Id>();
        }
        parentFunctionalQueueIds.add(parentFunctionalQueueId);
    }

    private void appendDeletedSubFunctionalQueueSet(Sub_Functional_Queue__c deletedSubFunctionalQueue) {
        if (subFunctionalQueueIdsToDelete == null) {
            subFunctionalQueueIdsToDelete = new Set<Id>();
        }
        subFunctionalQueueIdsToDelete.add(deletedSubFunctionalQueue.Id);
    }

    private void createAssociatedGroupIfNonExistent() {
        FunctionalQueueUtility.createQueueGroupIfAssociatedFunctionalQueueIsNonExistent(parentFunctionalQueueIds);
    }

    /*****************************************************************************
     *  Returns a map that correlates functional queues to their respective
     *  existing member contact IDs in order to make it easy to check for dupes
     ****************************************************************************/
    private void buildFunctionalQueueIdToSubFunctionalQueueIdsMap() {
        List<Sub_Functional_Queue__c> existingSubFunctionalQueues = FunctionalQueueUtility.getSubFunctionalQueuesByParentFunctionalQueueIds(parentFunctionalQueueIds);

        functionalQueueIdToSubFunctionalQueueIdsMap = new Map<Id, Set<Id>>();
        for (Sub_Functional_Queue__c subFunctionalQueue : existingSubFunctionalQueues) {
            if (functionalQueueIdToSubFunctionalQueueIdsMap.containsKey(subFunctionalQueue.Parent_Functional_Queue__c)) {
                functionalQueueIdToSubFunctionalQueueIdsMap.get(subFunctionalQueue.Parent_Functional_Queue__c).add(subFunctionalQueue.Sub_Functional_Queue__c);
            } else {
                functionalQueueIdToSubFunctionalQueueIdsMap.put(subFunctionalQueue.Parent_Functional_Queue__c, new Set<Id>{ subFunctionalQueue.Sub_Functional_Queue__c });
            }
        }
    }

    private void stageParentFunctionalQueuesOfNewSubFunctionalQueuesWithFieldValues() {
        List<Sub_Functional_Queue__c> subFunctionalQueues = FunctionalQueueUtility.getSubFunctionalQueuesByParentFunctionalQueueIds(subFunctionalQueueIds);
        parentSubFunctionalQueuesSetMap = new Map<Id, Set<Id>>();

        for (Sub_Functional_Queue__c subFunctionalQueue : subFunctionalQueues) {
            if (parentSubFunctionalQueuesSetMap.containsKey(subFunctionalQueue.Parent_Functional_Queue__c)) {
                parentSubFunctionalQueuesSetMap.get(subFunctionalQueue.Parent_Functional_Queue__c).add(subFunctionalQueue.Sub_Functional_Queue__c);
            } else {
                parentSubFunctionalQueuesSetMap.put(subFunctionalQueue.Parent_Functional_Queue__c, new Set<Id>{ subFunctionalQueue.Sub_Functional_Queue__c });
            }
        }
    }

    private void addErrorIfSubFunctionalQueueExistsOnFunctionalQueue(Sub_Functional_Queue__c subFunctionalQueue) {
        if (isDuplicateSubQueueOfFunctionalQueue(subFunctionalQueue)) {
            subFunctionalQueue.addError('This Sub Functional Queue is already a member of this Functional Queue.');
        }
    }

    private void addErrorIfCircularReferenceAttempt(Sub_Functional_Queue__c subFunctionalQueue) {
        if (
            parentSubFunctionalQueuesSetMap.containsKey(subFunctionalQueue.Sub_Functional_Queue__c) &&
            parentSubFunctionalQueuesSetMap.get(subFunctionalQueue.Sub_Functional_Queue__c).contains(subFunctionalQueue.Parent_Functional_Queue__c)
        ) {
            subFunctionalQueue.addError(
                'The Sub Functional Queue you are attempting to add will cause a circular reference error as it already contains the Functional Queue you are attempting to add it to.'
            );
        }
    }

    private void addErrorIfAttemptingToAddFunctionalQueueToItself(Sub_Functional_Queue__c subFunctionalQueue) {
        if (subFunctionalQueue.Parent_Functional_Queue__c == subFunctionalQueue.Sub_Functional_Queue__c) {
            subFunctionalQueue.addError('You cannot add a Functional Queue to itself.');
        }
    }

    private Boolean isDuplicateSubQueueOfFunctionalQueue(Sub_Functional_Queue__c subFunctionalQueue) {
        if (functionalQueueIdToSubFunctionalQueueIdsMap.containsKey(subFunctionalQueue.Parent_Functional_Queue__c)) {
            return functionalQueueIdToSubFunctionalQueueIdsMap.get(subFunctionalQueue.Parent_Functional_Queue__c).contains(subFunctionalQueue.Sub_Functional_Queue__c);
        }

        return false;
    }

    private void setSubFunctionalQueueIds(List<Sub_Functional_Queue__c> subFunctionalQueues) {
        subFunctionalQueueIds = new Set<Id>();
        for (Sub_Functional_Queue__c subFunctionalQueue : subFunctionalQueues) {
            subFunctionalQueueIds.add(subFunctionalQueue.Id);
        }
    }

    private void performDMLOperationsForAfterInsert() {
        insertCorrespondingGroupMembersWithFutureCall(subFunctionalQueueIds);
    }

    private void performDMLOperationsForBeforeDelete() {
        deleteCorrespondingGroupMembersBySubFunctionalQueueIdsWithFutureCall(relatedGroupMemberIdsToDelete);
    }

    @Future
    private static void insertCorrespondingGroupMembersWithFutureCall(Set<Id> subFunctionalQueueIds) {
        List<Sub_Functional_Queue__c> subFunctionalQueues = FunctionalQueueUtility.getSubFunctionalQueuesByIds(subFunctionalQueueIds);
        List<GroupMember> correspondingGroupMembersToInsert = new List<GroupMember>();
        for (Sub_Functional_Queue__c subFunctionalQueue : subFunctionalQueues) {
            if (subFunctionalQueue.Parent_Functional_Queue__r.Public_Group_ID__c != null && subFunctionalQueue.Sub_Functional_Queue__r.Public_Group_ID__c != null) {
                correspondingGroupMembersToInsert.add(createCorrespondingGroupBySubFunctionalQueue(subFunctionalQueue));
            }
        }

        insert correspondingGroupMembersToInsert;
    }

    private static GroupMember createCorrespondingGroupBySubFunctionalQueue(Sub_Functional_Queue__c subFunctionalQueue) {
        return FunctionalQueueUtility.createGroupMemberByGroupIdAndUserOrGroupId(
            subFunctionalQueue.Parent_Functional_Queue__r.Public_Group_ID__c,
            subFunctionalQueue.Sub_Functional_Queue__r.Public_Group_ID__c
        );
    }

    @Future
    private static void deleteCorrespondingGroupMembersBySubFunctionalQueueIdsWithFutureCall(Set<Id> groupMemberIdsToDelete) {
        List<GroupMember> groupMembersToDelete = [SELECT Id FROM GroupMember WHERE Id IN :groupMemberIdsToDelete];
        delete groupMembersToDelete;
    }
}
