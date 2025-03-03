/**
 * @description Test class for the PC_LocationBasedRouting class
 * @author      Booze Allen Hamilton
 * @see         PC_LocationBasedRouting
 */
@IsTest
private with sharing class PC_LocationbasedRoutingTest {
    private final static PC_LocationBasedRouting ROUTING_DRIVER_TEST;
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

            ROUTING_DRIVER_TEST = new PC_LocationBasedRouting();
        }
    }

    /**
     * @description positive test of getNearestAvailableSpecialist
     */
    @IsTest
    private static void unitGetNearestAvailableSpecialistPositive() {
        // Test data setup
        User runAsUser = FLP_USER;

        Id flpServiceLocationId = VATEST_IdFactory.get(Schema.Location.class);
        String specialty = 'Cardiology';

        Set<Id> availableSpecialistUserIds = new Set<Id>{ SPECIALIST_USER.Id };

        Map<Id, Double> userIdToTotalCapacityMap = new Map<Id, Double>{ SPECIALIST_USER.Id => 0.0 };

        Schema.Location referrerServiceLocation = new Schema.Location(
            Id = flpServiceLocationId,
            Latitude = -3.1883,
            Longitude = 55.9533
        );

        Id cardiologistHostLocationId = VATEST_IdFactory.get(Schema.Location.class);
        Set<Id> applicableHostLocationIds = new Set<Id>{ cardiologistHostLocationId };

        System.Location hostLocationWithGeolocation = System.Location.newInstance(-0.1276, 51.5072);
        Map<Id, System.Location> hostLocationGeolocationMap = new Map<Id, System.Location>{
            cardiologistHostLocationId => hostLocationWithGeolocation
        };

        ServiceResource cardiologistResource = new ServiceResource(
            Id = VATEST_IdFactory.get(ServiceResource.class),
            RelatedRecordId = SPECIALIST_USER.Id,
            PC_Location__c = cardiologistHostLocationId
        );
        ServiceResourceSkill cardiologistServiceResourceSkill = new ServiceResourceSkill(
            ServiceResourceId = cardiologistResource.Id,
            ServiceResource = cardiologistResource
        );
        List<ServiceResourceSkill> applicableServiceResourceSkills = new List<ServiceResourceSkill>{
            cardiologistServiceResourceSkill
        };

        /** SETUP PC_LocationBasedRoutingHelper STUB **/
        PC_LocationBasedRoutingHelper stubbedRoutingHelper = (PC_LocationBasedRoutingHelper) new VATEST_StubBuilder(
                PC_LocationBasedRoutingHelper.class
            )
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getAvailableSpecialistUserIds')
            .withParameterTypes()
            //Tell the stub builder what to return
            .returning(availableSpecialistUserIds)

            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('retrieveCurrentAgentWorkCapacities')
            .withParameterTypes()
            //Tell the stub builder what to return
            .returning(userIdToTotalCapacityMap)

            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('retrieveServiceLocationDetails', String.class)
            .withParameterValues(FLP_USER.Id)
            //Tell the stub builder what to return
            .returning(referrerServiceLocation)

            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('retrieveApplicableHostLocationsForServiceLocationAndSpecialty', Id.class, String.class)
            .withParameterValues(flpServiceLocationId, specialty)
            //Tell the stub builder what to return
            .returning(applicableHostLocationIds)

            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('combineHostLocationsWithGeolocationData', Set<Id>.class)
            .withParameterValues(applicableHostLocationIds)
            //Tell the stub builder what to return
            .returning(hostLocationGeolocationMap)

            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('retrieveApplicableServiceResourceSkills', String.class, Set<Id>.class, Set<Id>.class)
            .withParameterValues(specialty, applicableHostLocationIds, availableSpecialistUserIds)
            //Tell the stub builder what to return
            .returning(applicableServiceResourceSkills)
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_LocationBasedRouting.routingHelper = stubbedRoutingHelper;

        Test.startTest();

        String returnedSpecialistUserId;
        System.runAs(runAsUser) {
            returnedSpecialistUserId = ROUTING_DRIVER_TEST.getNearestAvailableSpecialist(FLP_USER.Id, specialty);
        }

        Test.stopTest();

        Assert.areEqual(
            SPECIALIST_USER.Id,
            returnedSpecialistUserId,
            'Expected the Specialist User Id of the available Cardiologist to be returned, but it was not.'
        );
    }

    /**
     * @description negative test of getNearestAvailableSpecialist with null specialty paramater value
     */
    @IsTest
    private static void unitGetNearestAvailableSpecialistNullParamsNegative() {
        // Test data setup
        User runAsUser = FLP_USER;

        Test.startTest();

        String caughtExceptionMessage = '';
        System.runAs(runAsUser) {
            try {
                ROUTING_DRIVER_TEST.getNearestAvailableSpecialist(FLP_USER.Id, null);
            } catch (Exception caughtException) {
                caughtExceptionMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        Assert.isTrue(
            caughtExceptionMessage.contains('No Specialty'),
            'Expected an exception to be thrown due to a null specialty parameter, but that exception was not thrown.'
        );
    }
}
