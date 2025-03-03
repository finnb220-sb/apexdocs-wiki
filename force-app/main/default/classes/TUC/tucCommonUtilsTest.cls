/**
 * @description Test class for tucCommonUtils. Please note that that the method tucCommonUtils.checkCustomPermission(String)
 * is tested in another test class and not covered here
 * @author Booz Allen
 * @see tucCommonUtils
 * @see tucGetUserDivisionInvocable
 */
@IsTest
with sharing class tucCommonUtilsTest {
    public static final String TEST_PERM_SET_GROUP = 'TED_Medical_Provider_Group';
    public static final String TEST_BASE_PROFILE = 'VAVET Base Profile';

    /**
     * @description Test tucCommonUtils.getUserDivisionVISN() - positive scenario
     */
    @IsTest
    static void unitTestGetVisnDivisionPositive() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet(TEST_PERM_SET_GROUP)
            .withUserProfile(TEST_BASE_PROFILE)
            .withStandardData()
            .build(false);
        doctorUser.Division = 'VISN 0';

        System.runAs(doctorUser) {
            VCR_UserRepo userRepoStub = (VCR_UserRepo) new VATEST_StubBuilder(VCR_UserRepo.class)
                .mockingMethodCall('fetchById')
                .withParameterTypes(Id.class, Set<String>.class)
                .withParameterValues(doctorUser.Id, new Set<String>{ 'Division' })
                .returning(doctorUser)
                .defineStub();
            tucCommonUtils.userRepoInstance = userRepoStub;

            Test.startTest();
            String currentUserDivision = tucCommonUtils.getUserDivisionVISN();
            Test.stopTest();
            Assert.areEqual(
                '0',
                currentUserDivision,
                'Expected test user division to be zero, but actual result is ' + currentUserDivision
            );
        }
    }

    /**
     * @description Test tucCommonUtils.getUserDivisionVISN() negative scenario by supplying an invalid division, which should result in an error.
     */
    @IsTest
    static void unitTestGetVisnDivisionNegative() {
        Boolean isError = false;
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet(TEST_PERM_SET_GROUP)
            .withUserProfile(TEST_BASE_PROFILE)
            .withStandardData()
            .build(false);
        doctorUser.Division = 'Invalid VISN';

        System.runAs(doctorUser) {
            Test.startTest();
            VCR_UserRepo userRepoStub = (VCR_UserRepo) new VATEST_StubBuilder(VCR_UserRepo.class)
                .mockingMethodCall('fetchById')
                .withParameterTypes(Id.class, Set<String>.class)
                .withParameterValues(doctorUser.Id, new Set<String>{ 'Division' })
                .returning(doctorUser)
                .defineStub();
            tucCommonUtils.userRepoInstance = userRepoStub;

            try {
                tucCommonUtils.getUserDivisionVISN();
            } catch (tucCommonUtils.TUCCommonUtilsException auraException) {
                isError = true;
            }
            Test.stopTest();
            Assert.areEqual(
                1,
                [SELECT Id FROM LogEntry__c].size(),
                'Expected to have 1 LogEntry__c record because of the invalid VISN value entered, but actual result was different from 1'
            );
            Assert.areEqual(
                true,
                isError,
                'an error is expected to be thrown ' +
                'when the user VISN (Division) is invalid, must have format VISN xx'
            );
        }
    }

    /**
     * @description Test tucGetUserDivisionInvocable.getUserDivisionVISNInvocable() - positive scenario only.
     * because it calls Test tucCommonUtils.getUserDivisionVISN()
     */
    @IsTest
    static void unitTestGetVISNDivisionInvocablePositive() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet(TEST_PERM_SET_GROUP)
            .withUserProfile(TEST_BASE_PROFILE)
            .withStandardData()
            .build(false);
        doctorUser.Division = 'VISN 0';

        System.runAs(doctorUser) {
            VCR_UserRepo userRepoStub = (VCR_UserRepo) new VATEST_StubBuilder(VCR_UserRepo.class)
                .mockingMethodCall('fetchById')
                .withParameterTypes(Id.class, Set<String>.class)
                .withParameterValues(doctorUser.Id, new Set<String>{ 'Division' })
                .returning(doctorUser)
                .defineStub();
            tucCommonUtils.userRepoInstance = userRepoStub;

            Test.startTest();
            List<String> currentUserVISNs = tucGetUserDivisionInvocable.getUserDivisionVISNInvocable();
            Assert.areEqual(
                '0',
                currentUserVISNs[0],
                'Expected test user division to be zero, but actual result is ' + currentUserVISNs[0]
            );
            Test.stopTest();
        }
    }
}
