// Assign all the Health Cloud related permission sets to all users with System Administrator profile
List<Id> permissionSetIds = new List<Id>(new Map<Id, PermissionSet>([SELECT Id FROM PermissionSet WHERE Name IN ('HealthCloudAdmin','HealthCloudApexAuraAccess','HealthCloudApi','HealthCloudPermissionSetLicense','HealthCloudStandard','HealthCloudWaveAdmin','HealthCloudWaveIntegration','Encryption','HLS_SFCC_Integration')]).keySet());
delete [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId IN :permissionSetIds];
List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
List<User> adminUsers = [SELECT Id, Name FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE];
for (User adminUser : adminUsers) {
    for (Id permissionSetId : permissionSetIds) {
        permissionSetAssignments.add(new PermissionSetAssignment(PermissionSetId = permissionSetId, AssigneeId = adminUser.Id));
    }
}
insert permissionSetAssignments;