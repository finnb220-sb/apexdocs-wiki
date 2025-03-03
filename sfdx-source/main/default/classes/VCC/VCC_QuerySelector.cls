/**
 * @description Provides common queries for VCC.
 */
public with sharing class VCC_QuerySelector {
    @TestVisible
    private static VCR_PermissionSetAssignmentRepo permSetRepo {
        get {
            if (permSetRepo == null) {
                permSetRepo = new VCR_PermissionSetAssignmentRepo();
            }
            return permSetRepo;
        }
        set;
    }

    /**
     * @description Fetches the assigned permission sets for a given user by Id.
     * @param userId
     * @return List<String>
     */
    public static List<String> getAssignedPermissionSetNames(String userId) {
        List<String> permissionSetNames = new List<String>();
        for (PermissionSetAssignment permissionSetObj : permSetRepo.fetchPermissionSetDetailsByUserId(userId)) {
            permissionSetNames.add(permissionSetObj.PermissionSet.Name);
        }
        return permissionSetNames;
    }

    /**
     * @description Get the national id for a given contact.
     * @param recordId Id of progress note, case or account record
     * @return      `String` returns the contact's national id VCC_MVI_External_Id__pc
     */
    public static String getContactNationalID(String recordId) {
        String sObjName = ID.valueOf(recordId).getSObjectType().getDescribe().getName();
        if (sObjName == 'VCC_Progress_Note__c') {
            return [
                SELECT VCC_Case__r.Account.VCC_MVI_External_Id__pc
                FROM VCC_Progress_Note__c
                WHERE Id = :recordId
                WITH USER_MODE
            ][0]
            .VCC_Case__r.Account.VCC_MVI_External_Id__pc;
        } else if (sObjName == 'Case') {
            return [
                SELECT Account.VCC_MVI_External_Id__pc
                FROM Case
                WHERE Id = :recordId
                WITH USER_MODE
            ][0]
            .Account.VCC_MVI_External_Id__pc;
        } else {
            return [
                SELECT VCC_MVI_External_Id__pc
                FROM Account
                WHERE Id = :recordId
                WITH USER_MODE
            ][0]
            .VCC_MVI_External_Id__pc;
        }
    }
}
