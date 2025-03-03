/**
 * @author Booz Allen
 * @since 05/2024
 * @description Test class for VCR_VAHCe911CustomSettingRepo
 * @see VCR_VAHCe911CustomSettingRepo
 *
 *  NOTE: Suppressing warning for PMD.ApexUnitTestClassShouldHaveRunAs as there is no need to use System.RunAs for the
 *  Repository functional tests.
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest
private class VCR_VAHCe911CustomSettingRepoTest {
    /**
     * @description Test constructor for success path
     */
    @IsTest
    private static void unitTestConstructorPositive() {
        Test.startTest();
        VCR_VAHCe911CustomSettingRepo repo = new VCR_VAHCe911CustomSettingRepo();
        Test.stopTest();
        Assert.isNotNull(repo, 'Expected constructor to properly instantiate a VCR_VAHCe911CustomSettingRepo');
    }

    /**
     * @description Test getAlle911CustomSettingsRecords(), usually should always have an org default
     */
    @IsTest
    private static void funcGetAlle911CustomSettingsRecordsPositive() {
        VATEST_SObjectFactory.createSObject(new VAHC_E911_Settings__c(e911_Enabled__c = true), true);

        Test.startTest();
        VCR_VAHCe911CustomSettingRepo repo = new VCR_VAHCe911CustomSettingRepo();
        List<VAHC_E911_Settings__c> result = repo.getAlle911CustomSettingsRecords();
        Test.stopTest();

        Assert.areEqual(result.size(), 1, 'Expected a single record to be retrieved but did not');
        Assert.areEqual(
            result[0].e911_Enabled__c,
            true,
            'Expected to retrieved record to have e911_enabled set to true but was not'
        );
    }
    //Not possible for a negative case unless the custom setting does not exist in the org
}
