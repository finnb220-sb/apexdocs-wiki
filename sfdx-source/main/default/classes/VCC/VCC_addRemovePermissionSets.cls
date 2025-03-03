/**
 * @description this is the logic class for manipulating that adding and removing of permission sets for batch apex
 * @author BAH
 * @see VCR_UserRepo
 * @see VCR_PermissionSetRepo
 * @see VCR_PermissionSetAssignmentRepo
 */

public with sharing class VCC_addRemovePermissionSets implements ABS_BatchFinalizer {
    private List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();

    /**
     * @description property for the permSetRepoo object
     * provides access to the methods in the VCR_PermissionSetRepo class
     * so that it can be accessed in this class
     * @see VCR_PermissionSetRepo
     */
    @TestVisible
    private static VCR_PermissionSetRepo permSetRepo {
        get {
            return permSetRepo = permSetRepo ?? new VCR_PermissionSetRepo();
        }
        set;
    }

    /**
     * @description property for the permSetAssignRepo object
     * provides access to the methods in the VCR_PermissionSetAssignmentRepo class
     * so that it is accessed in this class
     * @see VCR_PermissionSetAssignment
     */
    @TestVisible
    private static VCR_PermissionSetAssignmentRepo permSetAssignRepo {
        get {
            return permSetAssignRepo = permSetAssignRepo ?? new VCR_PermissionSetAssignmentRepo();
        }
        set;
    }

    /**
     * @description This methods finds the requested permission set- confirms that it has not already been assigned to the user and assigns it
     * @param name The username of the user running batch apex class
     * @param permissionSetList The list of permission sets that the user would like to assign
     * @param apexClass The batch apex class that needs to run
     */

    public static void callBatchAddPermission(String name, Set<String> permissionSetList, String apexClass) {
        VCC_addRemovePermissionSets addRemovePerm = new VCC_addRemovePermissionSets();
        addRemovePerm.assignPermissioncallBatch(name, permissionSetList, apexClass);
    }

    /**
     * @description This methods finds the requested permission set- confirms that it has not already been assigned to the user and assigns it
     * @param sfUserId The Salesforce Id of the user running batch apex class
     * @param permissionSetList The list of permission sets that the user would like to assign
     * @param apexClass The batch apex class that needs to run
     */

    public void assignPermissioncallBatch(String sfUserId, Set<String> permissionSetList, String apexClass) {
        //Class Variables
        List<PermissionSet> neededPermSets = new List<PermissionSet>();
        Set<Id> assignments = new Set<Id>();

        String userId = sfUserId;

        //Returns List of PermissionsSet that needs to be added
        List<PermissionSet> setList = permSetRepo.getIdByName(permissionSetList);

        //Get a list of Current PermissionSetAssignment that the user currently has and store the PermissionSetId
        List<PermissionSetAssignment> permSetAssignment = permSetAssignRepo.fetchPermissionSetDetailsByUserId(userId);
        for (PermissionSetAssignment permSetAdd : permSetAssignment) {
            assignments.add(permSetAdd.PermissionSetId);
        }

        //Loop through the requested permission sets and the current permissions sets that the user has and filter out only the needed ones
        //If there are permission sets that are needed store that in a separate variable

        for (PermissionSet permSet : setList) {
            if (!assignments.contains(permSet.Id)) {
                neededPermSets.add(permSet);
            }
        }

        // If at least one permission set is needed- create a PermissionSetAssignment record for it
        if (neededPermSets.size() > 0) {
            for (PermissionSet setAssignments : neededPermSets) {
                PermissionSetAssignment permAssignment = new PermissionSetAssignment(
                    PermissionSetId = setAssignments.Id,
                    AssigneeId = userId
                );
                permissionSetAssignmentList.add(permAssignment);
            }

            // Insert the PermissionSetAssignment record
            permSetAssignRepo.assignPermissionSets(permissionSetAssignmentList);

            // Call the Batch Class you want to run
            Type apexClassInstance = Type.forName(apexClass);
            ABS_BatchExecutioner batchJob = (ABS_BatchExecutioner) apexClassInstance.newInstance();
            batchJob.setBatchFinalizer(this);
            Database.executeBatch(new VCC_GenericBatch(batchJob));

            //permSetAssignRepo.deleteUneededPermissions(permissionSetAssignmentList);
        } else {
            //If no PermissonSet is needed- just run the batch apex without assigning any permissions
            Type apexClassInstance = Type.forName(apexClass);
            ABS_BatchExecutioner batchJob = (ABS_BatchExecutioner) apexClassInstance.newInstance();
            Database.executeBatch(new VCC_GenericBatch(batchJob));
        }
    }

    /**
     * @description This property calls the finalize method that removes the added permission sets
     */
    public void finalize() {
        permSetAssignRepo.deleteUneededPermissions(permissionSetAssignmentList);
    }
}
