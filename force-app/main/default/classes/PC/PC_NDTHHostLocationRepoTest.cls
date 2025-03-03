/**
 * @description test class for PC_NDTHHostLocationRepo
 * @author      Booz Allen
 * @since       2024
 * @see         PC_NDTHHostLocationRepo
 */
@IsTest
private with sharing class PC_NDTHHostLocationRepoTest {
    private final static PC_NDTHHostLocationRepo REPO_TO_TEST;
    private final static User FLP_USER;
    static {
        //mixed DML error workaround
        System.runAs(new User(Id = UserInfo.getUserId())) {
            FLP_USER = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet('PrC_FLP_Users')
                .build(true);

            REPO_TO_TEST = new PC_NDTHHostLocationRepo();
        }
    }

    /**
     * @description test setup for re-usable data
     */
    @testSetup
    private static void testSetup() {
        //create NDTH data
        PC_NDTH__c ndth = (PC_NDTH__c) VATEST_SObjectFactory.createSObject(
            new PC_NDTH__c(NDTH_Name__c = 'Test Telehealth Hub', Type__c = 'TOS', Is_Active__c = true),
            true
        );

        Schema.Location location1 = (Schema.Location) VATEST_SObjectFactory.createSObject(
            new Schema.Location(
                Name = 'Test Location1',
                RecordTypeId = Schema.SObjectType.Location.getRecordTypeInfosByName()
                    .get('VA Facility')
                    .getRecordTypeId(),
                VAF_Facility_Type__c = 'va_health_facility',
                LocationType = 'Site',
                VAF_Facility_ID__c = '100'
            ),
            true
        );

        VATEST_SObjectFactory.createSObject(
            new PC_NDTH_Host_Locations__c(NDTH__c = ndth.Id, Location__c = location1.Id, Is_Active__c = true),
            true
        );
    }

    /**
     * @description positive test of getSpecialistLocationIdsForNDTHsWithEmptyResultHandling method (and incidentally also the getSpecialistLocationIdsForNDTHs method)
     */
    @IsTest
    private static void funcGetSpecialistLocationIdsForNDTHsPositive() {
        // Test data setup
        Id ndthId = [SELECT Id FROM PC_NDTH__c WHERE NDTH_Name__c = 'Test Telehealth Hub' LIMIT 1].Id;

        User runAsUser = FLP_USER;

        VATEST_SObjectFactory.createSObject(
            new PC_NDTH__Share(
                ParentId = ndthId,
                UserOrGroupId = runAsUser.Id,
                RowCause = 'Manual',
                AccessLevel = 'Read'
            ),
            true
        );

        // Actual test
        Test.startTest();

        Set<Id> results;
        System.runAs(runAsUser) {
            results = REPO_TO_TEST.getSpecialistLocationIdsForNDTHsWithEmptyResultHandling(new Set<Id>{ ndthId });
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(
            results.size() > 0,
            'Expected the Test Telehealth Hub\'s host locations to be retrieved successfully, but they were not.'
        );
    }

    /**
     * @description negative test of getSpecialistLocationIdsForNDTHsWithEmptyResultHandling method that should thrown an exception due to no query results
     */
    @IsTest
    private static void funcGetSpecialistLocationIdsForNDTHsNegative() {
        // Test data setup
        User runAsUser = FLP_USER;

        Id ndthId = [SELECT Id FROM PC_NDTH__c WHERE NDTH_Name__c = 'Test Telehealth Hub' LIMIT 1].Id;

        //delete all existing host location junctions tied to our test NDTH
        delete [SELECT ID FROM PC_NDTH_Host_Locations__c WHERE NDTH__c = :ndthId];

        Boolean threwError = false;

        // Actual test
        Test.startTest();

        System.runAs(runAsUser) {
            try {
                REPO_TO_TEST.getSpecialistLocationIdsForNDTHsWithEmptyResultHandling(new Set<Id>{ ndthId });
            } catch (Exception caughtException) {
                threwError = true;
            }
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(
            threwError,
            'Expected the getSpecialistLocationIdsForNDTHsWithEmptyResultHandling method to throw an exception due to no results from the query, but no exception was thrown.'
        );
    }
}
