/**
 * @description Test class for VCR_ExternalVaLinksRepo
 * @author Booz Allen Hamilton
 *
 * @see VCR_ExternalVaLinksRepo
 *
 */
@IsTest
public with sharing class VCR_ExternalVaLinksRepoTest {
    private static final User STANDARD_TEST_USER;
    static {
        STANDARD_TEST_USER = new VATEST_UserBuilder()
            .withStandardData()
            .withUserProfile('Standard User')
            .withPermissionSet('VAHC_Standard_VCC_User')
            .build(true);
    }

    /**
     * @description Test constructor for success path
     */
    @IsTest
    private static void unitTestConstructorPositive() {
        System.runAs(STANDARD_TEST_USER) {
            Test.startTest();
            VCR_ExternalVaLinksRepo repo = new VCR_ExternalVaLinksRepo();
            Test.stopTest();
            Assert.isNotNull(repo, 'Expected constructor to properly instantiate a VCR_ExternalVaLinksRepo');
        }
    }

    /**
     * @description Test getVALinksFromAudience() when an external link exists for the given criteria
     */
    @IsTest
    private static void unitGetVALinksFromAudiencePositive() {
        System.runAs(STANDARD_TEST_USER) {
            Test.startTest();
            VCR_ExternalVaLinksRepo repo = new VCR_ExternalVaLinksRepo();
            List<External_VA_Link__mdt> result = repo.getVALinksFromAudience(new List<String>{ 'All' }, 1);
            Test.stopTest();

            Assert.areEqual(result.size(), 1, 'Expected a single record to be retrieved but was not');
            Assert.areEqual(
                result[0].DeveloperName,
                'Launch_WebVRAM',
                'Expected to retrieve a single External Link record but did not'
            );
        }
    }

    /**
     * @description Test getVALinksFromAudience() when an external links exists for the given criteria
     */
    @IsTest
    private static void unitGetVALinksFromAudienceMultiplePositive() {
        System.runAs(STANDARD_TEST_USER) {
            Test.startTest();
            VCR_ExternalVaLinksRepo repo = new VCR_ExternalVaLinksRepo();
            List<External_VA_Link__mdt> result = repo.getVALinksFromAudience(new List<String>{ 'All', 'VCC' }, 2);
            Test.stopTest();

            Assert.areEqual(result.size(), 2, 'Expected two records to be retrieved but was not');
        }
    }

    /**
     * @description Test getVALinksFromAudience() when an external link does not exist
     */
    @IsTest
    private static void unitGetVALinksFromAudienceNegative() {
        System.runAs(STANDARD_TEST_USER) {
            Test.startTest();
            VCR_ExternalVaLinksRepo repo = new VCR_ExternalVaLinksRepo();
            List<External_VA_Link__mdt> result = repo.getVALinksFromAudience(new List<String>{ 'All' }, 100);
            Test.stopTest();

            Assert.areEqual(result.size(), 5, 'Expected 5 records');
        }
    }
}
