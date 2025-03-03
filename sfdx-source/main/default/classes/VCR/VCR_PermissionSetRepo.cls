/**
 * @description This repository class is for the "PermissionSet" standard object database operations
 * @author Booz Allen
 */
public with sharing class VCR_PermissionSetRepo extends VTC_BaseRepo {
    /**
     * @description Constructor
     */
    public VCR_PermissionSetRepo() {
        super(PermissionSet.SObjectType);
    }

    /**
     * @description Gets Id of Permission Sets based on the names of permissions
     * @param permissionNames The names of the PermissionSet whose Id you want to fetch
     * @return List of Permission Sets by name specified
     */
    public List<PermissionSet> getIdByName(Set<String> permissionNames) {
        return fetch(
            'SELECT Id, Name FROM PermissionSet WHERE Name IN :permissionNames',
            new Map<String, Object>{ 'permissionNames' => permissionNames }
        );
    }
}
