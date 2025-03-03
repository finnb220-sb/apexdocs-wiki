@IsTest
public without sharing class VCC_PermissionHelperTest {
    public static void giveUserPermission(Id userId, string permissionSetName) {
        User admin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];
        System.runAs(admin) {
            Id standardMsaUserId = [SELECT Id FROM PermissionSetGroup WHERE PermissionSetGroup.DeveloperName = :permissionSetName].id;

            List<PermissionSetAssignment> permSets = [
                SELECT Id, AssigneeId, PermissionSetGroupId
                FROM PermissionSetAssignment
                WHERE AssigneeId = :userId AND PermissionSetGroupId = :standardMsaUserId
            ];

            if (permSets.isEmpty() == null) {
                PermissionSetAssignment permSetAssignment = new PermissionSetAssignment();
                permSetAssignment.AssigneeId = userId;
                permSetAssignment.PermissionSetGroupId = standardMsaUserId;

                Database.insert(permSetAssignment);
            }
        }

    }
}
