/**
 * @description test class for the PC_LocationBasedRoutingHelper class
 * @author      Booz Allen Hamilton
 * @see         PC_LocationBasedRoutingHelper
 */
@IsTest
private with sharing class PC_LocationBasedRoutingHelperTest {
    private final static PC_LocationBasedRoutingHelper ROUTING_HELPER_TEST;
    private final static User FLP_USER;
    static {
        //mixed DML error workaround
        System.runAs(new User(Id = UserInfo.getUserId())) {
            FLP_USER = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet('PrC_FLP_Users')
                .build(true);

            ROUTING_HELPER_TEST = new PC_LocationBasedRoutingHelper();
        }
    }

    /**
     * @description positive test of getAvailableSpecialistUserIds
     */
    @IsTest
    private static void unitGetAvailableSpecialistUserIdsPositive() {
        // Test data setup
        User runAsUser = FLP_USER;

        //Create Ids for specialist users
        Id specialistUserId1 = VATEST_IdFactory.get(User.class);

        /** SETUP USER SERVICE PRESENCE REPO STUB **/
        //Create fake return result in memory
        UserServicePresence expectedUserServicePresence1 = (UserServicePresence) VATEST_SObjectFactory.createSObject(
            new UserServicePresence(UserId = specialistUserId1)
        );

        PC_UserServicePresenceRepo stubbedUserServicePresenceRepo = (PC_UserServicePresenceRepo) new VATEST_StubBuilder(
                PC_UserServicePresenceRepo.class
            )
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getCurrentUserServicePresence')
            .withParameterTypes()
            //Tell the stub builder what to return
            .returning(new List<UserServicePresence>{ expectedUserServicePresence1 })
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_LocationBasedRoutingHelper.userServicePresenceRepo = stubbedUserServicePresenceRepo;

        Test.startTest();

        Set<Id> availableSpecialistUserIds;
        System.runAs(runAsUser) {
            availableSpecialistUserIds = ROUTING_HELPER_TEST.getAvailableSpecialistUserIds();
        }

        Test.stopTest();

        Assert.isTrue(
            availableSpecialistUserIds.contains(specialistUserId1),
            'Expected specialistUserId1 to be returned in the set of available specialists, but it was not.'
        );
    }

    /**
     * @description negative test of getAvailableSpecialistUserIds that should throw a query exception
     */
    @IsTest
    private static void unitGetAvailableSpecialistUserIdsQueryExceptionNegative() {
        // Test data setup
        User runAsUser = FLP_USER;

        String queryExceptionMessage = 'Test Query Exception';

        /** SETUP USER SERVICE PRESENCE REPO STUB **/
        PC_UserServicePresenceRepo stubbedUserServicePresenceRepo = (PC_UserServicePresenceRepo) new VATEST_StubBuilder(
                PC_UserServicePresenceRepo.class
            )
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getCurrentUserServicePresence')
            .withParameterTypes()
            //Tell the stub builder to throw a query exception
            .throwingException(new QueryException(queryExceptionMessage))
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_LocationBasedRoutingHelper.userServicePresenceRepo = stubbedUserServicePresenceRepo;

        Test.startTest();

        String caughtExceptionMessage;
        System.runAs(runAsUser) {
            try {
                ROUTING_HELPER_TEST.getAvailableSpecialistUserIds();
            } catch (Exception caughtException) {
                caughtExceptionMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        Assert.areEqual(
            queryExceptionMessage,
            caughtExceptionMessage,
            'Expected getCurrentUserServicePresence to throw a query exception, but it did not.'
        );
    }

    /**
     * @description negative test of getAvailableSpecialistUserIds that should throw an exception when no results are returned by the query
     */
    @IsTest
    private static void unitGetAvailableSpecialistUserIdsNoResultsNegative() {
        // Test data setup
        User runAsUser = FLP_USER;

        /** SETUP USER SERVICE PRESENCE REPO STUB **/
        PC_UserServicePresenceRepo stubbedUserServicePresenceRepo = (PC_UserServicePresenceRepo) new VATEST_StubBuilder(
                PC_UserServicePresenceRepo.class
            )
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getCurrentUserServicePresence')
            .withParameterTypes()
            //Tell the stub builder what to return
            .returning(new List<UserServicePresence>())
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_LocationBasedRoutingHelper.userServicePresenceRepo = stubbedUserServicePresenceRepo;

        Test.startTest();

        String caughtExceptionMessage;
        System.runAs(runAsUser) {
            try {
                ROUTING_HELPER_TEST.getAvailableSpecialistUserIds();
            } catch (Exception caughtException) {
                caughtExceptionMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        Assert.areEqual(
            'There are currently no specialists available in Omni-channel.',
            caughtExceptionMessage,
            'Expected getCurrentUserServicePresence to return no results and throw an exception, but it did not.'
        );
    }

    /**
     * @description positive test of retrieveCurrentAgentWorkCapacities
     */
    @IsTest
    private static void unitRetrieveCurrentAgentWorkCapacitiesPositive() {
        // Test data setup
        User runAsUser = FLP_USER;

        //Create Ids for specialist users
        Id specialistUserId1 = VATEST_IdFactory.get(User.class);

        /** SETUP AGENT WORK REPO STUB **/
        //Create fake return result in memory
        PC_AgentWorkRepo.AgentWorkCapacityWrapper expectedAgentWorkCapacity = new PC_AgentWorkRepo.AgentWorkCapacityWrapper(
            specialistUserId1,
            0.0
        );

        PC_AgentWorkRepo stubbedAgentWorkRepo = (PC_AgentWorkRepo) new VATEST_StubBuilder(PC_AgentWorkRepo.class)
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getAgentWorkCapacity')
            .withParameterTypes()
            //Tell the stub builder what to return
            .returning(new List<PC_AgentWorkRepo.AgentWorkCapacityWrapper>{ expectedAgentWorkCapacity })
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_LocationBasedRoutingHelper.agentWorkRepo = stubbedAgentWorkRepo;

        Test.startTest();

        Map<Id, Double> returnMap;
        System.runAs(runAsUser) {
            returnMap = ROUTING_HELPER_TEST.retrieveCurrentAgentWorkCapacities();
        }

        Test.stopTest();

        Assert.isTrue(
            returnMap.containsKey(specialistUserId1),
            'Expected specialistUserId1 to be returned in the map of specialist capacities, but it was not.'
        );
    }

    /**
     * @description negative test of retrieveCurrentAgentWorkCapacities that should throw a query exception
     */
    @IsTest
    private static void unitRetrieveCurrentAgentWorkCapacitiesNegative() {
        // Test data setup
        User runAsUser = FLP_USER;

        String queryExceptionMessage = 'Test Query Exception';

        /** SETUP AGENT WORK REPO STUB **/
        PC_AgentWorkRepo stubbedAgentWorkRepo = (PC_AgentWorkRepo) new VATEST_StubBuilder(PC_AgentWorkRepo.class)
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getAgentWorkCapacity')
            .withParameterTypes()
            //Tell the stub builder to throw a query exception
            .throwingException(new QueryException(queryExceptionMessage))
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_LocationBasedRoutingHelper.agentWorkRepo = stubbedAgentWorkRepo;

        Test.startTest();

        String caughtExceptionMessage;
        System.runAs(runAsUser) {
            try {
                ROUTING_HELPER_TEST.retrieveCurrentAgentWorkCapacities();
            } catch (Exception caughtException) {
                caughtExceptionMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        Assert.areEqual(
            queryExceptionMessage,
            caughtExceptionMessage,
            'Expected getAgentWorkCapacity to throw a query exception, but it did not.'
        );
    }

    /**
     * @description positive test of retrieveServiceLocationDetails
     */
    @IsTest
    private static void unitRetrieveServiceLocationDetailsPositive() {
        // Test data setup
        User runAsUser = FLP_USER;

        Id flpCurrentLocationId = VATEST_IdFactory.get(Schema.Location.class);

        /** SETUP PRC USER DETAIL REPO STUB **/
        //Create fake return result in memory (using JSON serialize/deserialize to set formula fields)
        Map<String, Object> toForceCastToPrcUserDetail = new Map<String, Object>();
        toForceCastToPrcUserDetail.put('User_ID__c', FLP_USER.Id);
        toForceCastToPrcUserDetail.put('Current_Location__c', flpCurrentLocationId);
        toForceCastToPrcUserDetail.put('Longitude__c', 55.9533);
        toForceCastToPrcUserDetail.put('Latitude__c', -3.1883);
        String intermediate = JSON.serialize(toForceCastToPrcUserDetail);
        PC_User__c expectedPrcUserDetail1 = (PC_User__c) JSON.deserialize(intermediate, PC_User__c.class);

        PC_PrcUserRepo stubbedPrcUserDetailRepo = (PC_PrcUserRepo) new VATEST_StubBuilder(PC_PrcUserRepo.class)
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('fetchPrcUserByUserId', Id.class)
            .withParameterValues(FLP_USER.Id)
            //Tell the stub builder what to return
            .returning(new List<PC_User__c>{ expectedPrcUserDetail1 })
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_LocationBasedRoutingHelper.prcUserDetailRepo = stubbedPrcUserDetailRepo;

        Test.startTest();

        Schema.Location returnedServiceLocation;
        System.runAs(runAsUser) {
            returnedServiceLocation = ROUTING_HELPER_TEST.retrieveServiceLocationDetails(FLP_USER.Id);
        }

        Test.stopTest();

        Assert.areEqual(
            flpCurrentLocationId,
            returnedServiceLocation.Id,
            'Expected the returned Location to be the same as the FLP\'s retrieved Service Location, but it was not.'
        );
    }

    /**
     * @description negative test of retrieveServiceLocationDetails where a null parameter is provided
     */
    @IsTest
    private static void unitRetrieveServiceLocationDetailsNullParameterNegative() {
        // Test data setup
        User runAsUser = FLP_USER;

        Test.startTest();

        String caughtExceptionMsg;
        System.runAs(runAsUser) {
            try {
                ROUTING_HELPER_TEST.retrieveServiceLocationDetails(null);
            } catch (Exception caughtException) {
                caughtExceptionMsg = caughtException.getMessage();
            }
        }

        Test.stopTest();

        Assert.areEqual(
            'No referring FLP User Id was provided to the retrieveServiceLocationDetails method',
            caughtExceptionMsg,
            'Expected an exception to be thrown indicating the provided FLP User Id parameter value was blank, but that exception was not thrown.'
        );
    }

    /**
     * @description negative test of retrieveServiceLocationDetails where an exception is thrown by the Prc User details query
     */
    @IsTest
    private static void unitRetrieveServiceLocationDetailsQueryExceptionNegative() {
        // Test data setup
        User runAsUser = FLP_USER;

        String queryExceptionMessage = 'Test Query Exception';

        /** SETUP PRC USER DETAIL REPO STUB **/
        PC_PrcUserRepo stubbedPrcUserDetailRepo = (PC_PrcUserRepo) new VATEST_StubBuilder(PC_PrcUserRepo.class)
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('fetchPrcUserByUserId', Id.class)
            .withParameterValues(FLP_USER.Id)
            //Tell the stub builder to throw a query exception
            .throwingException(new QueryException(queryExceptionMessage))
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_LocationBasedRoutingHelper.prcUserDetailRepo = stubbedPrcUserDetailRepo;

        Test.startTest();

        String caughtExceptionMsg;
        System.runAs(runAsUser) {
            try {
                ROUTING_HELPER_TEST.retrieveServiceLocationDetails(FLP_USER.Id);
            } catch (Exception caughtException) {
                caughtExceptionMsg = caughtException.getMessage();
            }
        }

        Test.stopTest();

        Assert.areEqual(
            queryExceptionMessage,
            caughtExceptionMsg,
            'Expected an a query exception to be thrown by the Prc User details query, but that exception was not thrown.'
        );
    }

    /**
     * @description negative test of retrieveServiceLocationDetails where no results are returned by the Prc User details query
     */
    @IsTest
    private static void unitRetrieveServiceLocationDetailsNoResultsNegative() {
        // Test data setup
        User runAsUser = FLP_USER;

        /** SETUP PRC USER DETAIL REPO STUB **/
        PC_PrcUserRepo stubbedPrcUserDetailRepo = (PC_PrcUserRepo) new VATEST_StubBuilder(PC_PrcUserRepo.class)
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('fetchPrcUserByUserId', Id.class)
            .withParameterValues(FLP_USER.Id)
            //Tell the stub builder what to return
            .returning(new List<PC_User__c>())
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_LocationBasedRoutingHelper.prcUserDetailRepo = stubbedPrcUserDetailRepo;

        Test.startTest();

        String caughtExceptionMsg;
        System.runAs(runAsUser) {
            try {
                ROUTING_HELPER_TEST.retrieveServiceLocationDetails(FLP_USER.Id);
            } catch (Exception caughtException) {
                caughtExceptionMsg = caughtException.getMessage();
            }
        }

        Test.stopTest();

        Assert.areEqual(
            'The referring FLP has not selected a current service location so routing calculations cannot begin.',
            caughtExceptionMsg,
            'Expected an exception indicating the FLP has no PrC User detail with a populated Current Location, but that exception was not thrown.'
        );
    }

    /**
     * @description positive test of retrieveApplicableHostLocationsForServiceLocationAndSpecialty
     */
    @IsTest
    private static void unitRetrieveApplicableHostLocationsForServiceLocationAndSpecialtyPositive() {
        // Test data setup
        User runAsUser = FLP_USER;

        Id flpServiceLocationId = VATEST_IdFactory.get(Schema.Location.class);
        Id ndthAgreementId = VATEST_IdFactory.get(PC_NDTH__c.class);
        Id cardiologistHostLocationId = VATEST_IdFactory.get(Schema.Location.class);
        String specialty = 'Cardiology';

        /** SETUP NDTH SERVICE LOCATION REPO STUB **/
        PC_NDTH_Service_Locations__c expectedNDTHServiceLocation = new PC_NDTH_Service_Locations__c(
            NDTH__c = ndthAgreementId
        );

        PC_NDTHServiceLocationRepo stubbedNDTHServiceLocationRepo = (PC_NDTHServiceLocationRepo) new VATEST_StubBuilder(
                PC_NDTHServiceLocationRepo.class
            )
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getNDTHServiceLocsFromLocId', Id.class)
            .withParameterValues(flpServiceLocationId)
            //Tell the stub builder what to return
            .returning(new List<PC_NDTH_Service_Locations__c>{ expectedNDTHServiceLocation })
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_LocationBasedRoutingHelper.ndthServiceLocationRepo = stubbedNDTHServiceLocationRepo;

        /** SETUP NDTH CLINICAL SERVICE REPO STUB **/
        PC_NDTH_Clinical_Services__c expectedNDTHClinicalService = new PC_NDTH_Clinical_Services__c(
            NDTH__c = ndthAgreementId
        );

        PC_NDTHClinicalServicesRepo stubbedNDTHClincalServiceRepo = (PC_NDTHClinicalServicesRepo) new VATEST_StubBuilder(
                PC_NDTHClinicalServicesRepo.class
            )
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getClinicalServicesFromNDTHsandSkills', Set<Id>.class, String.class)
            .withParameterValues(new Set<Id>{ ndthAgreementId }, specialty)
            //Tell the stub builder what to return
            .returning(new List<PC_NDTH_Clinical_Services__c>{ expectedNDTHClinicalService })
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_LocationBasedRoutingHelper.ndthClinicalServiceRepo = stubbedNDTHClincalServiceRepo;

        /** SETUP NDTH HOST LOCATION REPO STUB **/
        PC_NDTH_Host_Locations__c expectedNDTHHostLocation = new PC_NDTH_Host_Locations__c(
            Location__c = cardiologistHostLocationId
        );

        PC_NDTHHostLocationRepo stubbedNDTHHostLocationRepo = (PC_NDTHHostLocationRepo) new VATEST_StubBuilder(
                PC_NDTHHostLocationRepo.class
            )
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getHostLocationsFromNDTHs', Set<Id>.class)
            .withParameterValues(new Set<Id>{ ndthAgreementId })
            //Tell the stub builder what to return
            .returning(new List<PC_NDTH_Host_Locations__c>{ expectedNDTHHostLocation })
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_LocationBasedRoutingHelper.ndthHostLocationRepo = stubbedNDTHHostLocationRepo;

        Test.startTest();

        Set<Id> applicableHostLocations = new Set<Id>();
        System.runAs(runAsUser) {
            applicableHostLocations.addAll(
                ROUTING_HELPER_TEST.retrieveApplicableHostLocationsForServiceLocationAndSpecialty(
                    flpServiceLocationId,
                    specialty
                )
            );
        }

        Test.stopTest();

        Assert.isTrue(
            applicableHostLocations.contains(cardiologistHostLocationId),
            'Expected the Cardiologist\'s Host Location to be returned in the results of applicable host locations, but it was not'
        );
    }

    /**
     * @description negative test of retrieveApplicableHostLocationsForServiceLocationAndSpecialty where no results are returned
     */
    @IsTest
    private static void unitRetrieveApplicableHostLocationsForServiceLocationAndSpecialtyNoResultsNegative() {
        // Test data setup
        User runAsUser = FLP_USER;

        Id flpServiceLocationId = VATEST_IdFactory.get(Schema.Location.class);
        Id ndthAgreementId = VATEST_IdFactory.get(PC_NDTH__c.class);
        String specialty = 'Cardiology';

        /** SETUP NDTH SERVICE LOCATION REPO STUB **/
        PC_NDTH_Service_Locations__c expectedNDTHServiceLocation = new PC_NDTH_Service_Locations__c(
            NDTH__c = ndthAgreementId
        );

        PC_NDTHServiceLocationRepo stubbedNDTHServiceLocationRepo = (PC_NDTHServiceLocationRepo) new VATEST_StubBuilder(
                PC_NDTHServiceLocationRepo.class
            )
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getNDTHServiceLocsFromLocId', Id.class)
            .withParameterValues(flpServiceLocationId)
            //Tell the stub builder what to return
            .returning(new List<PC_NDTH_Service_Locations__c>{ expectedNDTHServiceLocation })
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_LocationBasedRoutingHelper.ndthServiceLocationRepo = stubbedNDTHServiceLocationRepo;

        /** SETUP NDTH CLINICAL SERVICE REPO STUB **/
        PC_NDTH_Clinical_Services__c expectedNDTHClinicalService = new PC_NDTH_Clinical_Services__c(
            NDTH__c = ndthAgreementId
        );

        PC_NDTHClinicalServicesRepo stubbedNDTHClincalServiceRepo = (PC_NDTHClinicalServicesRepo) new VATEST_StubBuilder(
                PC_NDTHClinicalServicesRepo.class
            )
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getClinicalServicesFromNDTHsandSkills', Set<Id>.class, String.class)
            .withParameterValues(new Set<Id>{ ndthAgreementId }, specialty)
            //Tell the stub builder what to return
            .returning(new List<PC_NDTH_Clinical_Services__c>{ expectedNDTHClinicalService })
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_LocationBasedRoutingHelper.ndthClinicalServiceRepo = stubbedNDTHClincalServiceRepo;

        /** SETUP NDTH HOST LOCATION REPO STUB **/
        PC_NDTHHostLocationRepo stubbedNDTHHostLocationRepo = (PC_NDTHHostLocationRepo) new VATEST_StubBuilder(
                PC_NDTHHostLocationRepo.class
            )
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getHostLocationsFromNDTHs', Set<Id>.class)
            .withParameterValues(new Set<Id>{ ndthAgreementId })
            //Tell the stub builder what to return
            .returning(new List<PC_NDTH_Host_Locations__c>())
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_LocationBasedRoutingHelper.ndthHostLocationRepo = stubbedNDTHHostLocationRepo;

        Test.startTest();

        String caughtExceptionMessage = '';
        System.runAs(runAsUser) {
            try {
                ROUTING_HELPER_TEST.retrieveApplicableHostLocationsForServiceLocationAndSpecialty(
                    flpServiceLocationId,
                    specialty
                );
            } catch (Exception caughtException) {
                caughtExceptionMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        Assert.isTrue(
            caughtExceptionMessage.contains('Host Locations'),
            'Expected an exception to be thrown due to finding no applicable host locations, but the expected exception was not thrown.'
        );
    }

    /**
     * @description negative test of retrieveApplicableHostLocationsForServiceLocationAndSpecialty where a query exception is thrown
     */
    @IsTest
    private static void unitRetrieveApplicableHostLocationsForServiceLocationAndSpecialtyQueryExceptionNegative() {
        // Test data setup
        User runAsUser = FLP_USER;

        Id flpServiceLocationId = VATEST_IdFactory.get(Schema.Location.class);
        String specialty = 'Cardiology';

        String queryExceptionMessage = 'Test Query Exception';

        /** SETUP NDTH SERVICE LOCATION REPO STUB **/
        PC_NDTHServiceLocationRepo stubbedNDTHServiceLocationRepo = (PC_NDTHServiceLocationRepo) new VATEST_StubBuilder(
                PC_NDTHServiceLocationRepo.class
            )
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getNDTHServiceLocsFromLocId', Id.class)
            .withParameterValues(flpServiceLocationId)
            //Tell the stub builder to throw an exception
            .throwingException(new QueryException(queryExceptionMessage))
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_LocationBasedRoutingHelper.ndthServiceLocationRepo = stubbedNDTHServiceLocationRepo;

        Test.startTest();

        String caughtExceptionMessage = '';
        System.runAs(runAsUser) {
            try {
                ROUTING_HELPER_TEST.retrieveApplicableHostLocationsForServiceLocationAndSpecialty(
                    flpServiceLocationId,
                    specialty
                );
            } catch (Exception caughtException) {
                caughtExceptionMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        Assert.areEqual(
            queryExceptionMessage,
            caughtExceptionMessage,
            'Expected a query exception to be thrown by the PC_NDTHServiceLocationRepo getNDTHServiceLocsFromLocId method, but the expected exception was not thrown.'
        );
    }

    /**
     * @description negative test of retrieveApplicableHostLocationsForServiceLocationAndSpecialty where the parameters are null
     */
    @IsTest
    private static void unitRetrieveApplicableHostLocationsForServiceLocationAndSpecialtyNullParamsNegative() {
        // Test data setup
        User runAsUser = FLP_USER;

        Test.startTest();

        String caughtExceptionMessage = '';
        System.runAs(runAsUser) {
            try {
                ROUTING_HELPER_TEST.retrieveApplicableHostLocationsForServiceLocationAndSpecialty(null, null);
            } catch (Exception caughtException) {
                caughtExceptionMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        Assert.areEqual(
            'No Service Location Id was provided to the retrieveApplicableHostLocationsForServiceLocationAndSpecialty method.',
            caughtExceptionMessage,
            'Expected an exception to be thrown indicating no Service Location parameter was provided, but the expected exception was not thrown.'
        );
    }

    /**
     * @description positive test of combineHostLocationsWithGeolocationData where a vaf address for one host location has a valid latitude and longitude and a schema address for another host location does not (which will hit the info log code)
     */
    @IsTest
    private static void unitCombineHostLocationsWithGeolocationDataPositive() {
        // Test data setup
        User runAsUser = FLP_USER;

        Id hostLocationId1 = VATEST_IdFactory.get(Schema.Location.class);
        Id hostLocationId2 = VATEST_IdFactory.get(Schema.Location.class);
        Set<Id> hostLocationIds = new Set<Id>{ hostLocationId1, hostLocationId2 };

        /** SETUP VAF ADDRESS REPO STUB **/
        VAF_Address__c expectedVafAddress = new VAF_Address__c(VAF_Longitude__c = 55.9533, VAF_Latitude__c = -3.1883);

        VCR_VAFAddressRepo stubbedVafAddressRepo = (VCR_VAFAddressRepo) new VATEST_StubBuilder(VCR_VAFAddressRepo.class)
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getMapOfLocIdToVafAddress', Set<Id>.class)
            .withParameterValues(hostLocationIds)
            //Tell the stub builder what to return
            .returning(new Map<Id, VAF_Address__c>{ hostLocationId1 => expectedVafAddress })
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_LocationBasedRoutingHelper.vafAddressRepo = stubbedVafAddressRepo;

        /** SETUP SCHEMA ADDRESS REPO STUB **/
        Schema.Address expectedSchemaAddress = new Schema.Address(VAF_Longitude__c = null, VAF_Latitude__c = null);

        VCR_AddressRepo stubbedAddressRepo = (VCR_AddressRepo) new VATEST_StubBuilder(VCR_AddressRepo.class)
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getMapOfLocIdToAddress', Set<Id>.class)
            .withParameterValues(hostLocationIds)
            //Tell the stub builder what to return
            .returning(new Map<Id, Schema.Address>{ hostLocationId2 => expectedSchemaAddress })
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_LocationBasedRoutingHelper.addressRepo = stubbedAddressRepo;

        Test.startTest();

        Map<Id, System.Location> returnedHostGeolocationDataMap = new Map<Id, System.Location>();
        System.runAs(runAsUser) {
            returnedHostGeolocationDataMap.putAll(
                ROUTING_HELPER_TEST.combineHostLocationsWithGeolocationData(hostLocationIds)
            );
        }

        Test.stopTest();

        Assert.isTrue(
            returnedHostGeolocationDataMap.containsKey(hostLocationId1),
            'Expected the first host location to be included in the returned map, but it was not.'
        );

        Assert.isFalse(
            returnedHostGeolocationDataMap.containsKey(hostLocationId2),
            'Expected the second host location to NOT be included in the returned map, but it was included.'
        );
    }

    /**
     * @description negative test of combineHostLocationsWithGeolocationData where a query exception is thrown
     */
    @IsTest
    private static void unitCombineHostLocationsWithGeolocationDataQueryExceptionNegative() {
        // Test data setup
        User runAsUser = FLP_USER;

        Id hostLocationId1 = VATEST_IdFactory.get(Schema.Location.class);
        Id hostLocationId2 = VATEST_IdFactory.get(Schema.Location.class);
        Set<Id> hostLocationIds = new Set<Id>{ hostLocationId1, hostLocationId2 };

        String queryExceptionMessage = 'Test Query Exception';

        /** SETUP VAF ADDRESS REPO STUB **/
        VCR_VAFAddressRepo stubbedVafAddressRepo = (VCR_VAFAddressRepo) new VATEST_StubBuilder(VCR_VAFAddressRepo.class)
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getMapOfLocIdToVafAddress', Set<Id>.class)
            .withParameterValues(hostLocationIds)
            //Tell the stub builder to throw a query exception
            .throwingException(new QueryException(queryExceptionMessage))
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_LocationBasedRoutingHelper.vafAddressRepo = stubbedVafAddressRepo;

        Test.startTest();

        String caughtExceptionMessage;
        System.runAs(runAsUser) {
            try {
                ROUTING_HELPER_TEST.combineHostLocationsWithGeolocationData(hostLocationIds);
            } catch (Exception caughtException) {
                caughtExceptionMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        Assert.areEqual(
            queryExceptionMessage,
            caughtExceptionMessage,
            'Expected a query exception to be thrown by the VAF Address query, but no query exception was thrown.'
        );
    }

    /**
     * @description negative test of combineHostLocationsWithGeolocationData where a null parameter is provided
     */
    @IsTest
    private static void unitCombineHostLocationsWithGeolocationDataNullParamsNegative() {
        // Test data setup
        User runAsUser = FLP_USER;

        Test.startTest();

        String caughtExceptionMessage = '';
        System.runAs(runAsUser) {
            try {
                ROUTING_HELPER_TEST.combineHostLocationsWithGeolocationData(null);
            } catch (Exception caughtException) {
                caughtExceptionMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        Assert.isTrue(
            caughtExceptionMessage.contains('Host Location Ids'),
            'Expected an exception to be thrown due to a null parameter, but the expected exception was not thrown.'
        );
    }

    /**
     * @description positive test of retrieveApplicableServiceResourceSkills
     */
    @IsTest
    private static void unitRetrieveApplicableServiceResourceSkillsPositive() {
        // Test data setup
        User runAsUser = FLP_USER;

        String specialty = 'Cardiology';

        Id hostLocationId1 = VATEST_IdFactory.get(Schema.Location.class);
        Id hostLocationId2 = VATEST_IdFactory.get(Schema.Location.class);
        Set<Id> hostLocationIds = new Set<Id>{ hostLocationId1, hostLocationId2 };

        Id specialistUserId1 = VATEST_IdFactory.get(User.class);
        Id specialistUserId2 = VATEST_IdFactory.get(User.class);
        Set<Id> availableSpecialistUserIds = new Set<Id>{ specialistUserId1, specialistUserId2 };

        /** SETUP VAF ADDRESS REPO STUB **/
        ServiceResourceSkill expectedServiceResourceSkill1 = new ServiceResourceSkill();
        ServiceResourceSkill expectedServiceResourceSkill2 = new ServiceResourceSkill();

        VCR_ServiceResourceSkillRepo stubbedServiceResourceSkillRepo = (VCR_ServiceResourceSkillRepo) new VATEST_StubBuilder(
                VCR_ServiceResourceSkillRepo.class
            )
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall(
                'getServiceResourceSkillsApplicableToNDTHRoutingCriteria',
                String.class,
                Set<Id>.class,
                Set<Id>.class
            )
            .withParameterValues(specialty, hostLocationIds, availableSpecialistUserIds)
            //Tell the stub builder what to return
            .returning(new List<ServiceResourceSkill>{ expectedServiceResourceSkill1, expectedServiceResourceSkill2 })
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_LocationBasedRoutingHelper.serviceResourceSkillRepo = stubbedServiceResourceSkillRepo;

        Test.startTest();

        List<ServiceResourceSkill> results;
        System.runAs(runAsUser) {
            results = ROUTING_HELPER_TEST.retrieveApplicableServiceResourceSkills(
                specialty,
                hostLocationIds,
                availableSpecialistUserIds
            );
        }

        Test.stopTest();

        Assert.isTrue(
            results.size() > 0,
            'Expected to return a list containing applicable service resource skills, but the list was empty.'
        );
    }

    /**
     * @description negative test of retrieveApplicableServiceResourceSkills where a query exception is thrown
     */
    @IsTest
    private static void unitRetrieveApplicableServiceResourceSkillsQueryExceptionNegative() {
        // Test data setup
        User runAsUser = FLP_USER;

        String specialty = 'Cardiology';

        Id hostLocationId1 = VATEST_IdFactory.get(Schema.Location.class);
        Id hostLocationId2 = VATEST_IdFactory.get(Schema.Location.class);
        Set<Id> hostLocationIds = new Set<Id>{ hostLocationId1, hostLocationId2 };

        Id specialistUserId1 = VATEST_IdFactory.get(User.class);
        Id specialistUserId2 = VATEST_IdFactory.get(User.class);
        Set<Id> availableSpecialistUserIds = new Set<Id>{ specialistUserId1, specialistUserId2 };

        String queryExceptionMessage = 'Test Query Exception';

        /** SETUP VAF ADDRESS REPO STUB **/
        VCR_ServiceResourceSkillRepo stubbedServiceResourceSkillRepo = (VCR_ServiceResourceSkillRepo) new VATEST_StubBuilder(
                VCR_ServiceResourceSkillRepo.class
            )
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall(
                'getServiceResourceSkillsApplicableToNDTHRoutingCriteria',
                String.class,
                Set<Id>.class,
                Set<Id>.class
            )
            .withParameterValues(specialty, hostLocationIds, availableSpecialistUserIds)
            //Tell the stub builder to throw a query exception
            .throwingException(new QueryException(queryExceptionMessage))
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_LocationBasedRoutingHelper.serviceResourceSkillRepo = stubbedServiceResourceSkillRepo;

        Test.startTest();

        String caughtExceptionMessage;
        System.runAs(runAsUser) {
            try {
                ROUTING_HELPER_TEST.retrieveApplicableServiceResourceSkills(
                    specialty,
                    hostLocationIds,
                    availableSpecialistUserIds
                );
            } catch (Exception caughtException) {
                caughtExceptionMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        Assert.areEqual(
            queryExceptionMessage,
            caughtExceptionMessage,
            'Expected a query exception to be thrown by getServiceResourceSkillsApplicableToNDTHRoutingCriteria, but it did not throw the exception.'
        );
    }

    /**
     * @description negative test of retrieveApplicableServiceResourceSkills where null parameter is provided
     */
    @IsTest
    private static void unitRetrieveApplicableServiceResourceSkillsNullsParamsNegative() {
        // Test data setup
        User runAsUser = FLP_USER;

        String specialty = 'Cardiology';

        Test.startTest();

        String caughtExceptionMessage = '';
        System.runAs(runAsUser) {
            try {
                ROUTING_HELPER_TEST.retrieveApplicableServiceResourceSkills(specialty, null, null);
            } catch (Exception caughtException) {
                caughtExceptionMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        Assert.isTrue(
            caughtExceptionMessage.contains('Host Location Set'),
            'Expected an exception to be thrown indicating that a null Host Location Set parameter was provided to the method, but that exception was not thrown.'
        );
    }
}
