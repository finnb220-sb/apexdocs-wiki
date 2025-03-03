/**
 * @description Tests the VCR_PermissionSetRepoTest class
 * @author Booz Allen
 *
 * @see VCR_PermissionSetRepo for class being tested
 */

@IsTest
public with sharing class VCR_PermissionSetRepoTest {
    //test reference constants
    private static final User ADMIN_USER;
    //test data
    private static final Set<String> PERMISSIONS = new Set<String>{ 'VAHC_Standard_VCC_User' };
    static {
        ADMIN_USER = new VATEST_UserBuilder()
            .withUserProfile('System Administrator')
            .withPermissionSets(PERMISSIONS)
            .withStandardData()
            .build(true);
    }

    /**
     * @description Test if the VCR_PermissionSetRepo was instantiated
     */
    @IsTest
    static void unitTestConstructorPositive() {
        System.runAs(ADMIN_USER) {
            Test.startTest();
            VCR_PermissionSetRepoTest repo = new VCR_PermissionSetRepoTest();
            Test.stopTest();
            Assert.isNotNull(repo, 'Expected constructor to properly instantiate a VCR_PermissionSetRepoTest');
        }
    }
    /**
     * @description Tests if we can retrieve all the permission sets assigned to a specific used based on a permission name
     */
    @IsTest
    static void unitfetchPermissionByName() {
        System.runAs(ADMIN_USER) {
            Set<String> permissions = new Set<String>();

            PermissionSet permission = [
                SELECT Id, Name
                FROM PermissionSet
                LIMIT 1
            ];

            permissions.add(permission.Name);

            Test.startTest();
            VCR_PermissionSetRepo repo = new VCR_PermissionSetRepo();
            List<PermissionSet> permissionList = repo.getIdByName(permissions);
            Test.stopTest();
            Assert.areEqual(permissionList.size(), 1, 'Expected to find a permission with given name');
        }
    }
}
