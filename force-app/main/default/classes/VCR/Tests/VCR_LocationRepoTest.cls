/**
 * @author Booz Allen Hamilton
 * @date 5/28/24
 * @description  Tests for VCR_LocationRepo class.
 * @see VCR_LocationRepo
 *
 * NOTE: Suppressing warning for PMD.ApexUnitTestClassShouldHaveRunAs as there is no need to use System.RunAs for the
 *  Repository functional tests.
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest
public class VCR_LocationRepoTest {
    static final string TEST_LOCATION_EXTERNAL_ID = 'vha_988';
    @TestSetup
    private static void buildData() {
        VATEST_SObjectFactory.createSObject(
            new Schema.Location(
                Name = 'Test Location',
                VAF_Facility_ID__c = TEST_LOCATION_EXTERNAL_ID,
                Common_Name__c = 'TestCommonName'
            ),
            true
        );
    }
    /**
     * @description Test fetchById() for success path
     */
    @IsTest
    static void unitTestConstructorPositive() {
        Test.startTest();
        VCR_LocationRepo repo = new VCR_LocationRepo();
        Test.stopTest();
        Assert.isNotNull(repo, 'Expected constructor to properly instantiate a VCR_LocationRepo');
    }
    /**
     * @description Grabs the location and compares it against the repository.
     */

    @IsTest
    static void unitTestfetchLocationsByExternalId() {
        Test.startTest();
        List<Schema.Location> expectedLocations = [SELECT Id, Name, Common_Name__c, VAF_Facility_ID__c FROM Location];
        VCR_LocationRepo repo = new VCR_LocationRepo();
        List<Schema.Location> testLocations = repo.fetchLocationsByExternalId(
            new Set<String>{ TEST_LOCATION_EXTERNAL_ID }
        );
        Test.stopTest();
        Assert.areEqual(expectedLocations[0].Id, testLocations[0].Id, 'Querey test locations should be equal');
    }
}
