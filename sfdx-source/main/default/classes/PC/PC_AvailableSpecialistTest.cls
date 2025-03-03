/**
 * @description Test class for PC_AvailableSpecialist
 * @author      Booz Allen Hamilton
 * @see         PC_AvailableSpecialist
 */
@IsTest
private with sharing class PC_AvailableSpecialistTest {
    private final static User FLP_USER;
    private final static User SPECIALIST_USER;
    static {
        //mixed DML error workaround
        System.runAs(new User(Id = UserInfo.getUserId())) {
            FLP_USER = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet('PrC_FLP_Users')
                .build(true);
            SPECIALIST_USER = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet('PrC_Specialist_Users')
                .build(true);
        }
    }

    /**
     * @description positive test of getSpecialistResourceUserId getter method
     */
    @IsTest
    static void unitGetSpecialistResourceUserIdPositive() {
        Test.startTest();

        String returnedSpecialistResourceUserId;
        System.runAs(FLP_USER) {
            PC_AvailableSpecialist testWrapper = new PC_AvailableSpecialist(
                new ServiceResource(RelatedRecordId = SPECIALIST_USER.Id),
                null,
                null
            );
            returnedSpecialistResourceUserId = testWrapper.getSpecialistResourceUserId();
        }

        Test.stopTest();

        Assert.areEqual(
            SPECIALIST_USER.Id,
            returnedSpecialistResourceUserId,
            'Expected the returned Specialist Salesforce User Id to be the same as the SPECIALIST_USER Id, but it was not.'
        );
    }

    /**
     * @description positive test of calculateDistanceFromServiceLocation method
     */
    @IsTest
    static void unitCalculateDistanceFromServiceLocationPositive() {
        System.Location hostLocationGeoData = System.Location.newInstance(10.0, 10.0);
        System.Location serviceLocationGeoData = System.Location.newInstance(11.0, 11.0);

        Double expectedDistance = System.Location.getDistance(
            hostLocationGeoData,
            serviceLocationGeoData,
            PC_AvailableSpecialist.DISTANCE_UNIT
        );

        Test.startTest();

        Double actualDistance = 0.0;
        System.runAs(FLP_USER) {
            PC_AvailableSpecialist testWrapper = new PC_AvailableSpecialist(
                new ServiceResource(RelatedRecordId = SPECIALIST_USER.Id),
                hostLocationGeoData,
                null
            );
            actualDistance = testWrapper.calculateDistanceFromServiceLocation(serviceLocationGeoData);
        }

        Test.stopTest();

        Assert.areEqual(
            expectedDistance,
            actualDistance,
            'Expected the returned calculated distance between the Specialist Host Location and the provided Service Location to be equal to the expected distance value, but it was not.'
        );
    }

    /**
     * @description negative test of calculateDistanceFromServiceLocation method with null input parameter
     */
    @IsTest
    static void unitCalculateDistanceFromServiceLocationNegative() {
        System.Location hostLocationGeoData = System.Location.newInstance(10.0, 10.0);

        Test.startTest();

        Double returnedDistance = 0.0;
        System.runAs(FLP_USER) {
            PC_AvailableSpecialist testWrapper = new PC_AvailableSpecialist(
                new ServiceResource(RelatedRecordId = SPECIALIST_USER.Id),
                hostLocationGeoData,
                null
            );
            returnedDistance = testWrapper.calculateDistanceFromServiceLocation(null);
        }

        Test.stopTest();

        Assert.areEqual(
            PC_AvailableSpecialist.MAX_DISTANCE,
            returnedDistance,
            'Expected the returned calculated distance to be equal to the Max Distance due to a null parameter, but it was not.'
        );
    }

    /**
     * @description positive test of Comparable interface's compareTo method via sorting
     */
    @IsTest
    static void unitCompareToPositive() {
        System.Location hostLocationGeoDataFarthest = System.Location.newInstance(10.0, 10.0);
        System.Location hostLocationGeoDataClosest = System.Location.newInstance(10.9, 10.9);
        System.Location serviceLocationGeoData = System.Location.newInstance(11.0, 11.0);

        Double capacityHalfLoad = 10;
        Double capacityNoLoad = 0;

        PC_AvailableSpecialist testWrapperHalfLoadFarthest = new PC_AvailableSpecialist(
            new ServiceResource(RelatedRecordId = SPECIALIST_USER.Id),
            hostLocationGeoDataFarthest,
            capacityHalfLoad
        );
        testWrapperHalfLoadFarthest.calculateDistanceFromServiceLocation(serviceLocationGeoData);

        //test equal
        PC_AvailableSpecialist testWrapperHalfLoadFarthest2 = new PC_AvailableSpecialist(
            new ServiceResource(RelatedRecordId = SPECIALIST_USER.Id),
            hostLocationGeoDataFarthest,
            capacityHalfLoad
        );
        testWrapperHalfLoadFarthest2.calculateDistanceFromServiceLocation(serviceLocationGeoData);

        //best specialist (no case-load and closest distance)
        PC_AvailableSpecialist testWrapperBestSpecialist = new PC_AvailableSpecialist(
            new ServiceResource(RelatedRecordId = SPECIALIST_USER.Id),
            hostLocationGeoDataClosest,
            capacityNoLoad
        );
        testWrapperBestSpecialist.calculateDistanceFromServiceLocation(serviceLocationGeoData);

        PC_AvailableSpecialist testWrapperNoLoadFarthest = new PC_AvailableSpecialist(
            new ServiceResource(RelatedRecordId = SPECIALIST_USER.Id),
            hostLocationGeoDataFarthest,
            capacityNoLoad
        );
        testWrapperNoLoadFarthest.calculateDistanceFromServiceLocation(serviceLocationGeoData);

        PC_AvailableSpecialist testWrapperHalfLoadClosest = new PC_AvailableSpecialist(
            new ServiceResource(RelatedRecordId = SPECIALIST_USER.Id),
            hostLocationGeoDataClosest,
            capacityHalfLoad
        );
        testWrapperHalfLoadClosest.calculateDistanceFromServiceLocation(serviceLocationGeoData);

        //wrapper list order is like this in order to hit every line of compareTo method during sort()
        List<PC_AvailableSpecialist> testWrapperList = new List<PC_AvailableSpecialist>{
            testWrapperHalfLoadFarthest,
            testWrapperHalfLoadFarthest2,
            testWrapperBestSpecialist,
            testWrapperNoLoadFarthest,
            testWrapperHalfLoadClosest
        };

        Test.startTest();

        System.runAs(FLP_USER) {
            testWrapperList.sort();
        }

        Test.stopTest();

        Assert.areEqual(
            testWrapperBestSpecialist,
            testWrapperList[0],
            'Expected the following Available Specialist wrapper to be listed first in the list: ' +
                testWrapperBestSpecialist +
                ', but it was not: ' +
                testWrapperList
        );
    }
}
