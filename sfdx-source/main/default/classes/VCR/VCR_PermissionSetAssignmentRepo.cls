/**
 * @description This repository is for PermissionSetAssignment Database Operations.
 */
public inherited sharing class VCR_PermissionSetAssignmentRepo extends VTC_BaseRepo {
    /**
     * @description Constructor that sets the sObjectType of the repo to PermissionSetAssignment
     */
    public VCR_PermissionSetAssignmentRepo() {
        super(PermissionSetAssignment.sObjectType);
    }
    /**
     * @description This method returns a list of PermissionSetAssignment
     * @param userId This is the specific userId that we will use to search the PermissionSetAssignment Object
     * @return Returns List of PermissionSet Assignment based on the given userId of type string
     */
    public List<PermissionSetAssignment> fetchPermissionSetDetailsByUserId(String userId) {
        return fetch(
            'SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :userId',
            new Map<String, Object>{ 'userId' => userId }
        );
    }

    /**
     * @description This method returns a list of PermissionSetAssignment
     * @param permissionSetList This is the list of Permission Set to be added to the database
     * @return List of Database.SaveResult, results of the create operation
     */

    public List<Database.SaveResult> assignPermissionSets(List<PermissionSetAssignment> permissionSetList) {
        return this.doCreate(permissionSetList);
    }

    /**
     * @description This method deletes list of unneeded permissions
     * @param permissionSetList The list of unneeded permission sets to delete
     * @return List of PermissionSetAssignment to delete
     */

    public List<Database.DeleteResult> deleteUneededPermissions(List<PermissionSetAssignment> permissionSetList) {
        return this.doDelete(permissionSetList);
    }
}
