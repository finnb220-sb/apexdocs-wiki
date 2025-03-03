/**
 * @description       :
 * @author            : jonathon.schleicher@b3groupinc.com
 * @group             :
 * @last modified on  : 10-21-2021
 * @last modified by  : jonathon.schleicher@b3groupinc.com
 **/
public without sharing class FunctionalQueueMemberHandler {
    public void OnBeforeInsert(List<Functional_Queue_Member__c> newFunctionalQueueMembers) {
        Set<Id> relatedFunctionalQueueIds = getRelatedFunctionalQueueIds(newFunctionalQueueMembers);
        FunctionalQueueUtility.createQueueGroupIfAssociatedFunctionalQueueIsNonExistent(relatedFunctionalQueueIds);

        Map<Id, Set<Id>> functionalQueueToContactsMap = getFunctionalQueueToContactsMap(relatedFunctionalQueueIds);
        for (Functional_Queue_Member__c newMember : newFunctionalQueueMembers) {
            if (memberIsDuplicate(functionalQueueToContactsMap, newMember)) {
                newMember.addError('This contact is already a member of this functional queue.');
            }
        }
    }

    public void OnAfterInsert(List<Functional_Queue_Member__c> newFunctionalQueueMembers) {
        Set<Id> newMemberIds = new Set<Id>();
        for (Functional_Queue_Member__c newMember : newFunctionalQueueMembers) {
            newMemberIds.add(newMember.Id);
        }
        addNewMembersToCorrespondingGroups(newMemberIds);
    }

    public void OnBeforeDelete(List<Functional_Queue_Member__c> deletedFunctionalQueueMembers) {
        Set<Id> groupMemberIdsToDelete = getGroupMemberIdsToDelete(deletedFunctionalQueueMembers);
        deleteFunctionalQueueGroupMembers(groupMemberIdsToDelete);
    }

    /*****************************************************************************
     *  Returns a set of any Functional Queue IDs related to the newly created
     *  functional queue members
     ****************************************************************************/
    private Set<Id> getRelatedFunctionalQueueIds(List<Functional_Queue_Member__c> functionalQueueMembers) {
        Set<Id> functionalQueueIds = new Set<Id>();
        for (Functional_Queue_Member__c member : functionalQueueMembers) {
            functionalQueueIds.add(member.Functional_Queue__c);
        }
        return functionalQueueIds;
    }

    /*****************************************************************************
     *  Returns a map that correlates functional queues to their respective
     *  existing member contact IDs in order to make it easy to check for dupes
     ****************************************************************************/
    private Map<Id, Set<Id>> getFunctionalQueueToContactsMap(Set<Id> functionalQueueIds) {
        List<Functional_Queue_Member__c> existingFunctionalQueueMembers = [
            SELECT Contact_Member__c, Functional_Queue__c
            FROM Functional_Queue_Member__c
            WHERE Functional_Queue__c IN :functionalQueueIds
        ];
        Map<Id, Set<Id>> functionalQueueToContactsMap = new Map<Id, Set<Id>>();
        for (Functional_Queue_Member__c existingMember : existingFunctionalQueueMembers) {
            if (functionalQueueToContactsMap.containsKey(existingMember.Functional_Queue__c)) {
                functionalQueueToContactsMap.get(existingMember.Functional_Queue__c).add(existingMember.Contact_Member__c);
            } else {
                functionalQueueToContactsMap.put(existingMember.Functional_Queue__c, new Set<Id>{ existingMember.Contact_Member__c });
            }
        }

        return functionalQueueToContactsMap;
    }

    /*****************************************************************************
     *  Checks the functionalQueueToContactsMap if the new functional queue
     *  member contact matches an existing contact on the same functional queue
     ****************************************************************************/
    private Boolean memberIsDuplicate(Map<Id, Set<Id>> functionalQueueToContactsMap, Functional_Queue_Member__c functionalQueueMember) {
        if (functionalQueueToContactsMap.containsKey(functionalQueueMember.Functional_Queue__c)) {
            return functionalQueueToContactsMap.get(functionalQueueMember.Functional_Queue__c).contains(functionalQueueMember.Contact_Member__c);
        }
        return false;
    }

    /*****************************************************************************
     *  Creates the corresponding group members for each of the new functional
     *  queue member IDs
     ****************************************************************************/
    @future
    public static void addNewMembersToCorrespondingGroups(Set<Id> newFunctionalQueueMemberIds) {
        List<Functional_Queue_Member__c> newFunctionalQueueMembers = [
            SELECT
                Functional_Queue__c,
                Functional_Queue__r.Queue_ID__c,
                Functional_Queue__r.Public_Group_ID__c,
                Contact_Member__c,
                Contact_Member__r.User_ID__c,
                RecordType.DeveloperName
            FROM Functional_Queue_Member__c
            WHERE Id IN :newFunctionalQueueMemberIds
        ];
        List<GroupMember> newMembersToInsert = new List<GroupMember>();
        for (Functional_Queue_Member__c newQueueMember : newFunctionalQueueMembers) {
            newMembersToInsert.add(
                FunctionalQueueUtility.createGroupMemberByGroupIdAndUserOrGroupId(
                    newQueueMember.Functional_Queue__r.Public_Group_ID__c,
                    newQueueMember.Contact_Member__r.User_ID__c
                )
            );
        }

        insert newMembersToInsert;
    }

    /*****************************************************************************
     *  Returns a set of IDs that represent the group members that correspond
     *  to deleted Functional Queue Members
     *  -  Query for functional queue member merge fields to get corresponding
     *       group and user IDs
     *  -  Query for group members that belong to the relevant public groups
     *  -  Loop through deleted functional queue members to match them to
     *     corresponding group members
     ****************************************************************************/
    private Set<Id> getGroupMemberIdsToDelete(List<Functional_Queue_Member__c> deletedFunctionalQueueMembers) {
        Set<Id> deletedMemberIds = new Set<Id>();
        for (Functional_Queue_Member__c deletedMember : deletedFunctionalQueueMembers) {
            deletedMemberIds.add(deletedMember.Id);
        }
        List<Functional_Queue_Member__c> membersToRemove = [
            SELECT Functional_Queue__r.Public_Group_ID__c, Contact_Member__r.User_ID__c
            FROM Functional_Queue_Member__c
            WHERE Id IN :deletedMemberIds
        ];

        Set<Id> relatedGroupIds = new Set<Id>();
        for (Functional_Queue_Member__c deletedMember : membersToRemove) {
            relatedGroupIds.add(deletedMember.Functional_Queue__r.Public_Group_ID__c);
        }
        List<GroupMember> relatedGroupMembers = [SELECT UserOrGroupId, GroupId FROM GroupMember WHERE GroupId IN :relatedGroupIds];

        Set<Id> groupMemberIdsToDelete = new Set<Id>();
        for (Functional_Queue_Member__c deletedMember : membersToRemove) {
            for (GroupMember relatedGroupMember : relatedGroupMembers) {
                if (
                    relatedGroupMember.UserOrGroupId == deletedMember.Contact_Member__r.User_ID__c &&
                    relatedGroupMember.GroupId == deletedMember.Functional_Queue__r.Public_Group_ID__c
                ) {
                    groupMemberIdsToDelete.add(relatedGroupMember.Id);
                }
            }
        }
        return groupMemberIdsToDelete;
    }

    @future
    public static void deleteFunctionalQueueGroupMembers(Set<Id> groupMemberIds) {
        List<GroupMember> groupMembersToDelete = [SELECT Id FROM GroupMember WHERE Id IN :groupMemberIds];
        delete groupMembersToDelete;
    }
}
