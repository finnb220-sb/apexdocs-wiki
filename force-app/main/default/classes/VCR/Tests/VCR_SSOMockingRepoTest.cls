/**
 * @description Tests the VCR_SSOMockingRepo class
 * @author Booz Allen
 *
 * @see VCR_SSOMockingRepo for class being tested
 */
@IsTest
private class VCR_SSOMockingRepoTest {
    private static final User SYS_ADMIN;
    final static User VAVET_BASE;
    private static final VCR_SSOMockingRepo SYSTEM_UNDER_TEST;
    final static Id ORG_ID;
    static {
        VAVET_BASE = new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
        SYS_ADMIN = new VATEST_UserBuilder()
            .withUserProfile('System Administrator')
            .withStandardData()
            .setFields(User.TimeZoneSidKey, UserInfo.getTimeZone().getID())
            .build(true);
        SYSTEM_UNDER_TEST = new VCR_SSOMockingRepo();
        ORG_ID = VATEST_IdFactory.get('Organization');
    }

    @IsTest
    private static void funcInitialization() {
        VCR_SSOMockingRepo orgSettingsRepo;
        System.runAs(SYS_ADMIN) {
            Test.startTest();
            orgSettingsRepo = new VCR_SSOMockingRepo();
            Test.stopTest();
        }
        Assert.isTrue(orgSettingsRepo != null, 'Expected class to be initialized.');
    }

    @IsTest
    private static void funcFetchByOrgIdPositive() {
        VCR_SSOMockingRepo repo = new VCR_SSOMockingRepo();
        List<VCC_Org_Settings__mdt> orgSettings;
        System.runAs(SYS_ADMIN) {
            Test.startTest();
            orgSettings = repo.fetchByOrgId(UserInfo.getOrganizationId());
            Test.stopTest();

            Assert.isNotNull(orgSettings, 'Expected valid non-null model to be returned.');
            Assert.isTrue(orgSettings.size() > 0, 'Expected valid non-null model to be returned.');
            Assert.isNotNull(orgSettings[0], 'Expected valid non-null model to be returned.');
            Assert.isNotNull(orgSettings[0].Id, 'Expected valid non-null model to be returned.');
            Assert.isNotNull(orgSettings[0].Enable_SSO_Mocking__c, 'Expected valid non-null model to be returned.');
        }
    }
    @IsTest
    private static void funcFetchByOrgIdNegative() {
        VCR_SSOMockingRepo repo = new VCR_SSOMockingRepo();
        List<VCC_Org_Settings__mdt> orgSettings;
        System.runAs(SYS_ADMIN) {
            Test.startTest();

            orgSettings = repo.fetchByOrgId(UserInfo.getUserId());
            Test.stopTest();
        }
        Assert.isTrue(orgSettings.isEmpty() == true, 'Expected valid null model to be returned.');
    }
}
