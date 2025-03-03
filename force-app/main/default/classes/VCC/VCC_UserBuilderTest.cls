/**
 * @author Booz Allen Hamilton
 * @since 10/9/24
 * @description VCC_UserBuilderTest
 * @see
 */
@IsTest
private class VCC_UserBuilderTest {
    private static final VCC_UserBuilder SYSTEM_UNDER_TEST;
    private static final User RUN_AS_USER;

    static {
        SYSTEM_UNDER_TEST = new VCC_UserBuilder();
        RUN_AS_USER = SYSTEM_UNDER_TEST.withUserProfile('System Administrator').withStandardData().build(true);
    }

    /**
     * @description Test happy path for adding PSG for all configured Apex tests & mocks
     *  Expected behavior: New User will have a PS assignment for PSG.
     */
    @IsTest
    private static void funcItInstantiatesUserWithPermissionSetAssignmentOnConstructionPositive() {
        System.runAs(RUN_AS_USER) {
            Test.startTest();
            User resultingUser = new VCC_UserBuilder()
                .withStandardData()
                .withUserProfile('System Administrator')
                .build(true);
            Test.stopTest();
            Assert.areEqual(
                1,
                [
                    SELECT COUNT()
                    FROM PermissionSetAssignment
                    WHERE
                        PermissionSetGroup.DeveloperName = :VCC_UserBuilder.APEX_TEST_PERMISSION_SET_GROUP_NAME
                        AND AssigneeId = :resultingUser.Id
                ],
                'Expected a PermissionSetAssignment to be created for our test User but instead observed no PSA was created.'
            );
        }
    }

    @IsTest
    private static void unitItInstantiatesPermissionSetNamesOnConstructionPositive() {
        System.runAs(RUN_AS_USER) {
            Assert.areEqual(
                1,
                SYSTEM_UNDER_TEST.permissionSetNames.size(),
                'Expected User Builder to instantiate a Set with 1 default permission set group name on construction.'
            );
            Assert.areEqual(
                VCC_UserBuilder.APEX_TEST_PERMISSION_SET_GROUP_NAME,
                SYSTEM_UNDER_TEST.permissionSetNames.iterator().next(),
                'Expected User Builder to add a single PSG Name entry for \'' +
                    VCC_UserBuilder.APEX_TEST_PERMISSION_SET_GROUP_NAME +
                    '\' on construction.'
            );
        }
    }
}
