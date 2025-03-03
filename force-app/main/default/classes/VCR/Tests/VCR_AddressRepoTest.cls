/**
 * @description test class for VCR_AddressRepo
 * @author      Booz Allen
 * @since       2024
 * @see         VCR_AddressRepo
 */
@IsTest
private class VCR_AddressRepoTest {
    @TestSetup
    private static void testSetup() {
        Schema.Location locdata = (Schema.Location) VATEST_SObjectFactory.createSObject(
            new Schema.Location(Name = 'Test', LocationType = 'Test', VAF_Facility_ID__c = 'test'),
            true
        );

        VATEST_SObjectFactory.createSObject(
            new Schema.Address(
                VAF_Longitude__c = 42,
                VAF_Latitude__c = 56,
                ParentId = locdata.Id,
                LocationType = 'Site',
                AddressType = 'Physical',
                VAF_Is_Decommissioned__c = false
            ),
            true
        );
        //Workaround for mixed dml error
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            VATEST_UserBuilder pcTestFLPWithAccessBuilder = new VATEST_UserBuilder();
            pcTestFLPWithAccessBuilder.withUserProfile('VAVET Base Profile').withStandardData();
            pcTestFLPWithAccessBuilder.resultingUser.LastName = 'WithAccess_PC_FLP';
            pcTestFLPWithAccessBuilder.withPermissionSet('PrC_FLP_Users');
            pcTestFLPWithAccessBuilder.build(true);
        }
    }

    /**
     * @description positive test of the fetchAddressById method
     */
    @IsTest
    private static void funcFetchAddressByIdTestPositive() {
        // Test data setup
        VCR_AddressRepo addressRepo = new VCR_AddressRepo();
        Id addressId = [SELECT Id FROM Address].Id;
        User runAsUser = [SELECT Id FROM User WHERE LastName = 'WithAccess_PC_FLP'];

        // Actual test
        Test.startTest();

        List<Schema.Address> addressList;
        System.runAs(runAsUser) {
            addressList = addressRepo.fetchAddressById(addressId);
        }

        Test.stopTest();

        Assert.isTrue(addressList != null && addressList.size() > 0, 'Address not retrieved successfully.');
    }

    /**
     * @description positive test of the getAddressListFromLocId method
     */
    @IsTest
    private static void funcGetAddressListFromLocIdTestPositive() {
        // Test data setup
        VCR_AddressRepo addressRepo = new VCR_AddressRepo();
        Id locationId = [SELECT Id FROM Location].Id;
        User runAsUser = [SELECT Id FROM User WHERE LastName = 'WithAccess_PC_FLP'];

        // Actual test
        Test.startTest();

        List<Schema.Address> addressList;
        System.runAs(runAsUser) {
            addressList = addressRepo.getAddressListFromLocId(new Set<Id>{ locationId });
        }

        Test.stopTest();

        Assert.isTrue(addressList.size() > 0, 'Address not retrieved successfully.');
    }

    /**
     * @description positive test of the getMapOfLocIdToAddress method
     */
    @IsTest
    private static void funcGetMapOfLocIdToAddressTestPositive() {
        // Test data setup
        VCR_AddressRepo addressRepo = new VCR_AddressRepo();
        Id locationId = [SELECT Id FROM Location].Id;
        User runAsUser = [SELECT Id FROM User WHERE LastName = 'WithAccess_PC_FLP'];

        // Actual test
        Test.startTest();

        Map<Id, Schema.Address> locToAddressMap;
        System.runAs(runAsUser) {
            locToAddressMap = addressRepo.getMapOfLocIdToAddress(new Set<Id>{ locationId });
        }

        Test.stopTest();

        Assert.isTrue(locToAddressMap.containsKey(locationId), 'Location to Address Map not retrieved successfully.');
    }

    /**
     * @description Negative test of the getMapOfLocIdToAddress method that throws an exception during the query
     */
    @IsTest
    private static void funcGetMapOfLocIdToAddressTestNegative() {
        // Test data setup
        VCR_AddressRepo addressRepo = new VCR_AddressRepo();
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
                addressRepo.getMapOfLocIdToAddress(new Set<Id>{ locationId });
            } catch (Exception exc) {
                hasFailure = true;
            }
        }

        Test.stopTest();

        Assert.isTrue(
            hasFailure,
            'Expected the test to throw an exception during the Address query execution due to lack of access.'
        );
    }
}
