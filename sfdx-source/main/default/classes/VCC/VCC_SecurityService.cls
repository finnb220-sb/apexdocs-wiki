/**
 * VCC_SecurityService
 * @description Shared service for working with security.
 * @author Liberty
 * @date 12/17/2021
 */
@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class VCC_SecurityService {
    public static Boolean hasPermissionSet(Id userId, String permissionSetName) {
        Integer hasPermissionSet = [SELECT COUNT() FROM PermissionSetAssignment WHERE AssigneeId = :userId AND PermissionSet.Name = :permissionSetName];
        return (hasPermissionSet > 0) ? true : false;
    }

    public static List<PermissionSetGroup> getPermissionSetGroupsForUser(Id userId) {
        // Query for Permission Set Assignments for the given user
        List<PermissionSetAssignment> assignments = [
            SELECT Id, PermissionSetGroupId
            FROM PermissionSetAssignment
            WHERE AssigneeId = :userId
        ];

        // Collect the Permission Set Group Ids from the assignments
        Set<Id> permissionSetGroupIds = new Set<Id>();
        for (PermissionSetAssignment assignment : assignments) {
            permissionSetGroupIds.add(assignment.PermissionSetGroupId);
        }

        // Query for the Permission Set Groups based on the collected Ids
        List<PermissionSetGroup> permissionSetGroups = [
            SELECT Id, DeveloperName
            FROM PermissionSetGroup
            WHERE Id IN :permissionSetGroupIds
        ];

        return permissionSetGroups;
    }
}
