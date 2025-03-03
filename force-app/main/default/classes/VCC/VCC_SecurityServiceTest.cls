/**
 * VCC_SecurityServiceTest
 * @description Test for VCC_SecurityService class.
 * @author Liberty
 * @date 12/20/2021
 */
@IsTest
public with sharing class VCC_SecurityServiceTest {
    @IsTest
    private static void hasPermissionSet() {
        Test.startTest();
        Boolean hasPermissionSet = VCC_SecurityService.hasPermissionSet(UserInfo.getUserId(), 'Fake_Permission');
        Test.stopTest();

        System.assertEquals(false, hasPermissionSet, 'Expected the user does not have the permission set.');
    }

    @IsTest
    private static void getPermissionSetGroupsForUser() {
        Test.startTest();
        List<PermissionSetGroup> permissionSetGroups = VCC_SecurityService.getPermissionSetGroupsForUser(UserInfo.getUserId());
        Test.stopTest();

        System.assert(permissionSetGroups != null, 'Expected the list to be initialized.');
    }
}
