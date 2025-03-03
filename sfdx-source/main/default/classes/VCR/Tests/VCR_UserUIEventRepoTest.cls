/**
 * @author Booz Allen
 * @since 05/2024
 * @description Test class for VCR_UserUIEventRepo
 * @see VCR_UserUIEventRepo
 *
 *  NOTE: Suppressing warning for PMD.ApexUnitTestClassShouldHaveRunAs as there is no need to use System.RunAs for the
 *  Repository functional tests.
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest
public with sharing class VCR_UserUIEventRepoTest {
    /**
     * @description Test constructor for success path
     */
    @IsTest
    private static void unitTestConstructorPositive() {
        Test.startTest();
        VCR_UserUIEventRepo repo = new VCR_UserUIEventRepo();
        Test.stopTest();
        Assert.isNotNull(repo, 'Expected constructor to properly instantiate a VCR_RecordTypeRepo');
    }
}
