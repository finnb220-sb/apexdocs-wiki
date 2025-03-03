/**
 * @description Tests the VCC_addRemovePermissionSetsTest class
 * @author Booz Allen
 * @see VCC_addRemovePermissionSets for class being tested
 */

@isTest
public with sharing class VCC_addRemovePermissionSetsTest {
    //test reference constants
    private static final User ADMIN_USER;
    //test data
    private static final Set<String> PERMISSIONS = new Set<String>{
        'VAHC_Standard_VCC_User',
        'VAHC_Write_Clinical_Triage_Progress_Note'
    };
    static {
        ADMIN_USER = new VATEST_UserBuilder()
            .withUserProfile('System Administrator')
            .withPermissionSets(PERMISSIONS)
            .withStandardData()
            .build(true);
    }

    /**
     * @description Test if the VCR_PermissionSetAssignmentRepo was instantiated
     */
    @IsTest
    static void unitTestConstructorPermSetAssRepo() {
        System.runAs(ADMIN_USER) {
            Test.startTest();
            VCR_PermissionSetAssignmentRepo repo = new VCR_PermissionSetAssignmentRepo();
            Test.stopTest();
            Assert.isNotNull(repo, 'Expected constructor to properly instantiate a VCR_PermissionSetAssignmentRepo');
        }
    }

    /**
     * @description Test if the VCR_PermissionSetRepo was instantiated
     */
    @IsTest
    static void unitTestConstructorPermSetRepo() {
        System.runAs(ADMIN_USER) {
            Test.startTest();
            VCR_PermissionSetRepoTest repo = new VCR_PermissionSetRepoTest();
            Test.stopTest();
            Assert.isNotNull(repo, 'Expected constructor to properly instantiate a VCR_PermissionSetRepoTest');
        }
    }

    /**
     * @description Test if the VCR_UserRepo was instantiated
     */
    @IsTest
    static void unitTestConstructorPositiveUserRepo() {
        System.runAs(ADMIN_USER) {
            Test.startTest();
            VCR_UserRepo repo = new VCR_UserRepo();
            Test.stopTest();
            Assert.isNotNull(repo, 'Expected constructor to properly instantiate a VCR_UserRepo');
        }
    }

    /**
     * @description Test if the Permission Set can be added ans removed was instantiated
     */
    @IsTest
    static void unitTestaddRemovePermcallBatch() {
        Set<String> userPermissions = new Set<String>();
        System.runAs(ADMIN_USER) {
            PermissionSet perm = new PermissionSet(label = 'VCC Test Permissions', name = 'VCC_Test_Permissions');
            insert perm;

            PermissionSet permSet = [
                SELECT Id, Name
                FROM PermissionSet
                WHERE Name LIKE '%VCC_Test_Permissions%'
                LIMIT 1
            ];

            Set<String> permissionSetList = new Set<String>{ permSet.Name };
            String apexClass = 'VCC_CaseMetricLogic';
            Test.startTest();
            VCC_addRemovePermissionSets.callBatchAddPermission(userInfo.getUserId(), permissionSetList, apexClass);
            Test.stopTest();
            //Assert Permission Set is removed
            PermissionSetAssignment[] testPsa = [
                SELECT Id, permissionsetid
                FROM PermissionSetAssignment
                WHERE permissionsetid = :permSet.Id
                LIMIT 1
            ];

            Assert.areEqual(0, testPsa.size(), 'Expected Permission set to no longer be assigned');
        }
    }

    /**
     * @description Tests if the Permission Set is not needed
     */
    @IsTest
    static void unitTestnoPermAdded() {
        Set<String> userPermissions = new Set<String>();
        System.runAs(ADMIN_USER) {
            PermissionSetAssignment psa = [
                SELECT Id, permissionsetid
                FROM PermissionSetAssignment
                WHERE AssigneeId = :Userinfo.getUserId()
                LIMIT 1
            ];
            PermissionSet permissions = [SELECT Id, Name FROM PermissionSet WHERE Id = :psa.permissionsetid];
            Set<String> permissionSetList = new Set<String>{ permissions.name };
            String apexClass = 'VCC_CaseMetricLogic';
            Test.startTest();
            VCC_addRemovePermissionSets.callBatchAddPermission(userInfo.getUserId(), permissionSetList, apexClass);
            Test.stopTest();
            PermissionSetAssignment[] testPsa = [
                SELECT Id, permissionsetid
                FROM PermissionSetAssignment
                WHERE AssigneeId = :Userinfo.getUserId()
                LIMIT 1
            ];
            for (PermissionSetAssignment testPsa2 : testPsa) {
                userPermissions.add(testPsa2.permissionsetid);
            }
            //Assert that original permission set is still there and did not get removed
            Assert.isTrue(
                userPermissions.contains(permissions.Id),
                'Expected Permission Set to still be assigned to user'
            );
        }
    }
}
