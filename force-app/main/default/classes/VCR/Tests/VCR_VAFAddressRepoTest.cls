/**
 * @description test class for VCR_VAFAddressRepo
 * @author      Booz Allen
 * @since       2024
 * @see         VCR_VAFAddressRepo
 */

@IsTest
public class VCR_VAFAddressRepoTest {
    @TestSetup
    private static void testSetup() {
        Schema.Location locdata = (Schema.Location) VATEST_SObjectFactory.createSObject(
            new Schema.Location(Name = 'Test', LocationType = 'Test', VAF_Facility_ID__c = 'test'),
            true
        );

        VATEST_SObjectFactory.createSObject(
            new VAF_Address__C(
                VAF_Longitude__c = 42,
                VAF_Latitude__c = 56,
                VAF_Facility__c = locdata.Id,
                VAF_Type__c = 'Physical',
                VAF_Is_Decommissioned__c = false
            ),
            true
        );
    }

    /**
     * @description positive test of getAddressListFromLocId method
     */
    @IsTest
    private static void funcGetAddressListFromLocIdTestPositive() {
        // Test data setup
        VCR_VAFAddressRepo addressRepo = new VCR_VAFAddressRepo();
        Id locationId = [SELECT Id FROM Location].Id;
        User runAsUser = generateUserWithAccess();
        // Actual test
        Test.startTest();

        List<VAF_Address__c> addressList;
        System.runAs(runAsUser) {
            addressList = addressRepo.getAddressListFromLocId(new Set<Id>{ locationId });
        }

        Test.stopTest();

        Assert.isTrue(addressList.size() > 0, 'Address not retrieved successfully.');
    }

    /**
     * @description positive test of getMapOfLocIdToVafAddress method
     */
    @IsTest
    private static void funcGetMapOfLocIdToVafAddressTestPositive() {
        // Test data setup
        VCR_VAFAddressRepo addressRepo = new VCR_VAFAddressRepo();
        Id locationId = [SELECT Id FROM Location].Id;
        User runAsUser = generateUserWithAccess();
        // Actual test
        Test.startTest();

        Map<Id, VAF_Address__c> locToAddressMap;
        System.runAs(runAsUser) {
            locToAddressMap = addressRepo.getMapOfLocIdToVafAddress(new Set<Id>{ locationId });
        }

        Test.stopTest();

        Assert.isTrue(
            locToAddressMap.containsKey(locationId),
            'Location to VAF Address Map not retrieved successfully.'
        );
    }

    /**
     * @description negative test of getMapOfLocIdToVafAddress method that should throw an exception on query execution due to lack of access
     */
    @IsTest
    private static void funcGetMapOfLocIdToVafAddressTestNegative() {
        // Test data setup
        VCR_VAFAddressRepo addressRepo = new VCR_VAFAddressRepo();
        Id locationId = [SELECT Id FROM Location].Id;
        Boolean hasFailure = false;

        //user with basic access - No access to Address
        VATEST_UserBuilder pcTestWithoutAccessBuilder = new VATEST_UserBuilder();
        pcTestWithoutAccessBuilder.withUserProfile('VAVET Base Profile').withStandardData().build(true);
        User runAsUser = pcTestWithoutAccessBuilder.resultingUser;

        // Actual test
        Test.startTest();

        System.runAs(runAsUser) {
            try {
                addressRepo.getMapOfLocIdToVafAddress(new Set<Id>{ locationId });
            } catch (Exception exc) {
                hasFailure = true;
            }
        }

        Test.stopTest();

        Assert.isTrue(
            hasFailure,
            'Expected the test to throw an exception during the VAF Address query execution due to lack of access.'
        );
    }

    /**
     * @description This method to prepare a test user record
     * @return User Return test user for this test class
     **/
    private static User generateUserWithAccess() {
        return new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .withPermissionSet('PrC_FLP_Users')
            .build(true);
    }
}
