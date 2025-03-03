/**
 * @description Tests the VCR_bsConfigurationsAssignedUserRepo class
 * @author Booz Allen
 *
 * @see VCR_bsConfigurationsAssignedUserRepo for class being tested
 *
 * NOTE: Suppressing warning for PMD.ApexUnitTestClassShouldHaveRunAs as there is no need to use System.RunAs for the
 *  Repository functional tests.
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@isTest
public class VCR_bsConfigurationsAssignedUserRepoTest {
    /**
     * @description Test to ensure init of repo is not null
     */
    @IsTest
    private static void funcInitTestPositive() {
        Test.startTest();
        VCR_bsConfigurationsAssignedUserRepo configRepo = new VCR_bsConfigurationsAssignedUserRepo();
        Test.stopTest();

        Assert.isTrue(configRepo != null, 'Expected repo to be initialized but was not.');
    }

    /**
     * @description Test fetching E911 Metric Record with correspondiong contact id for success path
     */
    @IsTest
    private static void unitTestfetchAssociatedUserPositive() {
        Test.startTest();
        VCR_bsConfigurationsAssignedUserRepo configRepo = new VCR_bsConfigurationsAssignedUserRepo();
        List<cnx__Connects_Configuration_Assignment__c> results = configRepo.fetchAssociatedUser(UserInfo.getUserId());
        Test.stopTest();

        Assert.isTrue(results.size() < 1, 'Expected no record to be returned but ' + results.size() + ' were returned');
    }
}
