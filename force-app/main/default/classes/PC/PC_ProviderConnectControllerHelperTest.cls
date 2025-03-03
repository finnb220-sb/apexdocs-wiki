/**
 * @description Test class for PC_ProviderConnectControllerHelper.
 * @author      Booz Allen
 * @since       2025
 * @group       Provider Connect
 * @see         PC_ProviderConnectControllerHelper
 **/
@IsTest
private with sharing class PC_ProviderConnectControllerHelperTest {
    private final static User FLP_USER;
    private final static User SPECIALIST_USER;
    static {
        //mixed DML error workaround
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
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
     * @description test for positive getSkillAvailability test from FLP perspective when NDTH enabled
     */
    @IsTest
    private static void unitGetSkillAvailabilityPositive() {
        //Set routing to default skill-based routing from the utility class
        PC_PrcConfigSettingsUtility.ndthRoutingEnabled = true;
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;

        //Create FLP running user and location
        User runAsUser = FLP_USER;

        //Create available specialists and their specialties
        Id cardioSpecialistUserId = VATEST_IdFactory.get(Type.forName('User'));
        String specialtyCardiology = 'Cardiology';
        Id neuroSpecialistUserId = VATEST_IdFactory.get(Type.forName('User'));
        String specialtyNeurology = 'Neurology';

        //Create Id for specialists location
        Id specialistLocationId = VATEST_IdFactory.get(Type.forName('Schema.Location'));

        /** SETUP SERVICE RESOURCE SKILL REPO STUB **/
        //create fake return result in memory

        //Cardiology service resource skill for service resource 1
        Skill expectedCardiologySkill = (Skill) VATEST_SObjectFactory.createSObject(
            new Skill(MasterLabel = specialtyCardiology)
        );

        ServiceResource expectedServiceResourceForSpecialist = (ServiceResource) VATEST_SObjectFactory.createSObject(
            new ServiceResource(RelatedRecordId = cardioSpecialistUserId, PC_Location__c = specialistLocationId)
        );

        ServiceResourceSkill expectedServiceResourceCardioSkill = (ServiceResourceSkill) VATEST_SObjectFactory.createSObject(
            new ServiceResourceSkill(
                SkillLevel = 1.0,
                SkillId = expectedCardiologySkill.Id,
                Skill = expectedCardiologySkill,
                ServiceResourceId = expectedServiceResourceForSpecialist.Id,
                ServiceResource = expectedServiceResourceForSpecialist
            )
        );

        //Neurology service resource skill for service resource 2
        Skill expectedNeurologySkill = (Skill) VATEST_SObjectFactory.createSObject(
            new Skill(MasterLabel = specialtyNeurology)
        );

        ServiceResource expectedServiceResourceForNeuroSpecialist = (ServiceResource) VATEST_SObjectFactory.createSObject(
            new ServiceResource(RelatedRecordId = neuroSpecialistUserId, PC_Location__c = specialistLocationId)
        );

        ServiceResourceSkill expectedServiceResourceNeuroSkill = (ServiceResourceSkill) VATEST_SObjectFactory.createSObject(
            new ServiceResourceSkill(
                SkillLevel = 1.0,
                SkillId = expectedNeurologySkill.Id,
                Skill = expectedNeurologySkill,
                ServiceResourceId = expectedServiceResourceForNeuroSpecialist.Id,
                ServiceResource = expectedServiceResourceForNeuroSpecialist
            )
        );

        PC_ServiceResourceSkillRepo stubbedServiceResourceSkillRepo = (PC_ServiceResourceSkillRepo) new VATEST_StubBuilder(
                PC_ServiceResourceSkillRepo.class
            )
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getServiceResourceSkills')
            .withParameterTypes()
            //Tell the stub builder what to return
            .returning(
                new List<ServiceResourceSkill>{ expectedServiceResourceCardioSkill, expectedServiceResourceNeuroSkill }
            )
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_ProviderConnectControllerHelper.serviceResourceSkillRepo = stubbedServiceResourceSkillRepo;

        /** SETUP USER SERVICE PRESENCE REPO STUB **/
        //Create fake return result in memory
        UserServicePresence expectedUserServicePresence = (UserServicePresence) VATEST_SObjectFactory.createSObject(
            new UserServicePresence(UserId = cardioSpecialistUserId)
        );

        UserServicePresence expectedUserServicePresence2 = (UserServicePresence) VATEST_SObjectFactory.createSObject(
            new UserServicePresence(UserId = neuroSpecialistUserId)
        );

        PC_UserServicePresenceRepo stubbedUserServicePresenceRepo = (PC_UserServicePresenceRepo) new VATEST_StubBuilder(
                PC_UserServicePresenceRepo.class
            )
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getCurrentUserServicePresence')
            .withParameterTypes()
            //Tell the stub builder what to return
            .returning(new List<UserServicePresence>{ expectedUserServicePresence, expectedUserServicePresence2 })
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_ProviderConnectController.userPresenceRepo = stubbedUserServicePresenceRepo;

        // Actual test
        List<ServiceResourceSkill> relevantSkillsList = new List<ServiceResourceSkill>{
            expectedServiceResourceCardioSkill,
            expectedServiceResourceNeuroSkill
        };
        List<UserServicePresence> presences = new List<UserServicePresence>{
            expectedUserServicePresence,
            expectedUserServicePresence2
        };

        PC_AgentWorkRepo.AgentWorkCapacityWrapper expectedAgentWorkAggregate = new PC_AgentWorkRepo.AgentWorkCapacityWrapper(
            cardioSpecialistUserId,
            0.0
        );
        PC_AgentWorkRepo.AgentWorkCapacityWrapper expectedAgentWorkAggregate2 = new PC_AgentWorkRepo.AgentWorkCapacityWrapper(
            neuroSpecialistUserId,
            10.0
        );

        List<PC_AgentWorkRepo.AgentWorkCapacityWrapper> agentWorks = new List<PC_AgentWorkRepo.AgentWorkCapacityWrapper>{
            expectedAgentWorkAggregate,
            expectedAgentWorkAggregate2
        };

        Test.startTest();

        List<PC_ProviderConnectController.SkillStatus> skillStatusResults;
        System.runAs(runAsUser) {
            skillStatusResults = PC_ProviderConnectControllerHelper.getSkillAvailability(
                relevantSkillsList,
                presences,
                agentWorks
            );
        }

        Test.stopTest();

        /////////////////////// Asserts
        Assert.isTrue(
            skillStatusResults != null && !skillStatusResults.isEmpty(),
            'Skill and status wrapper rows for availability matrix table not retrieved and generated successfully.'
        );
    }

    /**
     * @description Method to positively test consolidateStatusTypes method by returning a single list of combined General Skills and Patient Specific Skills
     **/
    @IsTest
    static void unitConsolidateStatusTypesPositive() {
        //Set routing to default skill-based routing from the utility class
        PC_PrcConfigSettingsUtility.ndthRoutingEnabled = true;
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;

        //Create FLP running user and location
        User runAsUser = FLP_USER;

        PC_ProviderConnectController.SkillStatus genstatus = new PC_ProviderConnectController.SkillStatus();
        genstatus.skillName = 'Cardiology';
        genstatus.hasPresence = true;
        genstatus.minCapacity = 0;
        genstatus.openCases = new List<Case>();
        genstatus.consultantsOnline = 1;
        genstatus.patientSpecificDisabled = false;
        genstatus.generalDisabled = false;

        PC_ProviderConnectController.SkillStatus patientSpecificStatus = new PC_ProviderConnectController.SkillStatus();
        patientSpecificStatus.skillName = 'Cardiology';
        patientSpecificStatus.hasPresence = true;
        patientSpecificStatus.minCapacity = 0;
        patientSpecificStatus.openCases = new List<Case>();
        patientSpecificStatus.consultantsOnline = 1;
        patientSpecificStatus.patientSpecificDisabled = false;
        patientSpecificStatus.generalDisabled = false;

        PC_ProviderConnectController.SkillStatus patientSpecificStatus2 = new PC_ProviderConnectController.SkillStatus();
        patientSpecificStatus2.skillName = 'Dental';
        patientSpecificStatus2.hasPresence = true;
        patientSpecificStatus2.minCapacity = 0;
        patientSpecificStatus2.openCases = new List<Case>();
        patientSpecificStatus2.consultantsOnline = 1;
        patientSpecificStatus2.patientSpecificDisabled = false;
        patientSpecificStatus2.generalDisabled = false;

        List<PC_ProviderConnectController.SkillStatus> generalStatuses = new List<PC_ProviderConnectController.SkillStatus>{
            genstatus
        };
        List<PC_ProviderConnectController.SkillStatus> patientSpecificStatuses = new List<PC_ProviderConnectController.SkillStatus>{
            patientSpecificStatus,
            patientSpecificStatus2
        };

        Test.startTest();

        List<PC_ProviderConnectController.SkillStatus> skillStatusResults;
        System.runAs(runAsUser) {
            skillStatusResults = PC_ProviderConnectControllerHelper.consolidateStatusTypes(
                generalStatuses,
                patientSpecificStatuses
            );
        }

        Test.stopTest();

        /////////////////////// Asserts
        Assert.isTrue(
            skillStatusResults != null && !skillStatusResults.isEmpty(),
            'Skill and status wrapper rows for availability matrix table not retrieved and generated successfully.'
        );
    }

    /**
     * @description Method to positively test getRelevantSkillPatientSpecific method by returning a list of ServiceResourceSkill
     **/
    @IsTest
    static void unitGetRelevantSkillPatientSpecificPositive() {
        //Set routing to default skill-based routing from the utility class
        PC_PrcConfigSettingsUtility.ndthRoutingEnabled = true;
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;

        //Create FLP running user and location
        User runAsUser = FLP_USER;

        Id runAsUserLocationId = VATEST_IdFactory.get(Type.forName('Schema.Location'));

        //Create Id for specialists location
        Id specialistLocationId = VATEST_IdFactory.get(Type.forName('Schema.Location'));

        //ID for NDTH agreement header
        Id ndthAgreementHeaderId = VATEST_IdFactory.get(Type.forName('PC_NDTH__c'));

        /** SETUP PRC USER REPO STUB **/
        //Create the fake PC User in memory
        PC_User__c expectedPrcUser = (PC_User__c) VATEST_SObjectFactory.createSObject(
            new PC_User__c(OwnerId = runAsUser.Id, User_ID__c = runAsUser.Id, Current_Location__c = runAsUserLocationId)
        );

        //Create available specialists and their specialties
        Id cardioSpecialistUserId = VATEST_IdFactory.get(Type.forName('User'));
        String specialtyCardiology = 'Cardiology';
        String specialtyNeurology = 'Neurology';

        PC_PrcUserRepo stubbedPrcUserRepo = (PC_PrcUserRepo) new VATEST_StubBuilder(PC_PrcUserRepo.class)
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('fetchPrcUserByUserId', Id.class)
            .withParameterValues(expectedPrcUser.User_ID__c)
            //Tell the stub builder what to return
            .returning(new List<PC_User__c>{ expectedPrcUser })
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_ProviderConnectControllerHelper.prcUserRepo = stubbedPrcUserRepo;

        /** SETUP NDTH SERVICE LOCATION REPO STUB **/
        //Create fake return result in memory
        PC_NDTH_Service_Locations__c expectedNDTHServiceLocation = (PC_NDTH_Service_Locations__c) VATEST_SObjectFactory.createSObject(
            new PC_NDTH_Service_Locations__c(Location__c = runAsUserLocationId, NDTH__c = ndthAgreementHeaderId)
        );

        PC_NDTHServiceLocationRepo stubbedNdthServiceLocationRepo = (PC_NDTHServiceLocationRepo) new VATEST_StubBuilder(
                PC_NDTHServiceLocationRepo.class
            )
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getNDTHsIdSetFromLocation', Id.class)
            .withParameterValues(expectedNDTHServiceLocation.Location__c)
            //Tell the stub builder what to return
            .returning(new Set<Id>{ expectedNDTHServiceLocation.NDTH__c })
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_ProviderConnectControllerHelper.ndthServiceLocationRepo = stubbedNdthServiceLocationRepo;

        /** SETUP NDTH CLINICAL SERVICES REPO STUB **/
        //Create fake return result in memory
        PC_NDTH_Clinical_Services__c expectedNDTHClinicalService = (PC_NDTH_Clinical_Services__c) VATEST_SObjectFactory.createSObject(
            new PC_NDTH_Clinical_Services__c(NDTH__c = ndthAgreementHeaderId, PC_Specialty__c = specialtyCardiology)
        );

        PC_NDTH_Clinical_Services__c expectedNDTHClinicalService2 = (PC_NDTH_Clinical_Services__c) VATEST_SObjectFactory.createSObject(
            new PC_NDTH_Clinical_Services__c(NDTH__c = ndthAgreementHeaderId, PC_Specialty__c = specialtyNeurology)
        );

        PC_NDTHClinicalServicesRepo stubbedNdthClinicalServicesRepo = (PC_NDTHClinicalServicesRepo) new VATEST_StubBuilder(
                PC_NDTHClinicalServicesRepo.class
            )
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getSpecialtiesForNDTHs', Set<Id>.class)
            .withParameterValues(new Set<Id>{ ndthAgreementHeaderId })
            //Tell the stub builder what to return
            .returning(
                new Set<String>{
                    expectedNDTHClinicalService.PC_Specialty__c,
                    expectedNDTHClinicalService2.PC_Specialty__c
                }
            )
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_ProviderConnectControllerHelper.ndthClinicalServicesRepo = stubbedNdthClinicalServicesRepo;

        /** SETUP NDTH CLINICAL SERVICES REPO STUB **/
        //Create fake return result in memory
        PC_NDTH_Host_Locations__c expectedNDTHHostLocation = (PC_NDTH_Host_Locations__c) VATEST_SObjectFactory.createSObject(
            new PC_NDTH_Host_Locations__c(NDTH__c = ndthAgreementHeaderId, Location__c = specialistLocationId)
        );

        PC_NDTHHostLocationRepo stubbedNdthHostLocationRepo = (PC_NDTHHostLocationRepo) new VATEST_StubBuilder(
                PC_NDTHHostLocationRepo.class
            )
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getSpecialistLocationIdsForNDTHs', Set<Id>.class)
            .withParameterValues(new Set<Id>{ expectedNDTHHostLocation.NDTH__c })
            //Tell the stub builder what to return
            .returning(new Set<Id>{ expectedNDTHHostLocation.Location__c })
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_ProviderConnectControllerHelper.ndthHostLocationRepo = stubbedNdthHostLocationRepo;

        //Cardiology service resource skill for service resource 1
        Skill expectedCardiologySkill = (Skill) VATEST_SObjectFactory.createSObject(
            new Skill(Id = VATEST_IdFactory.get(Type.forName('Skill')), MasterLabel = specialtyCardiology)
        );

        ServiceResource expectedServiceResourceForSpecialist = (ServiceResource) VATEST_SObjectFactory.createSObject(
            new ServiceResource(
                Id = VATEST_IdFactory.get(Type.forName('ServiceResource')),
                RelatedRecordId = cardioSpecialistUserId,
                PC_Location__c = specialistLocationId
            )
        );

        ServiceResourceSkill expectedServiceResourceCardioSkill = (ServiceResourceSkill) VATEST_SObjectFactory.createSObject(
            new ServiceResourceSkill(
                SkillLevel = 1.0,
                SkillId = expectedCardiologySkill.Id,
                Skill = expectedCardiologySkill,
                ServiceResourceId = expectedServiceResourceForSpecialist.Id,
                ServiceResource = expectedServiceResourceForSpecialist
            )
        );

        PC_ServiceResourceSkillRepo stubbedServiceResourceSkillRepo = (PC_ServiceResourceSkillRepo) new VATEST_StubBuilder(
                PC_ServiceResourceSkillRepo.class
            )
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getServiceResourceSkills')
            .withParameterTypes()
            //Tell the stub builder what to return
            .returning(new List<ServiceResourceSkill>{ expectedServiceResourceCardioSkill }) //Needs to be in skill alphabetical order
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getServiceResourceSkillsNDTHRouting', Set<String>.class, Set<Id>.class)
            .withParameterValues(
                new Set<String>{ specialtyCardiology, specialtyNeurology },
                new Set<Id>{ specialistLocationId }
            )
            //Tell the stub builder what to return
            .returning(new List<ServiceResourceSkill>{ expectedServiceResourceCardioSkill })
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_ProviderConnectControllerHelper.serviceResourceSkillRepo = stubbedServiceResourceSkillRepo;

        List<ServiceResourceSkill> serviceResourceSkillResults;
        Test.startTest();
        System.runAs(runAsUser) {
            serviceResourceSkillResults = PC_ProviderConnectControllerHelper.getRelevantSkillPatientSpecific();
        }

        Test.stopTest();

        /////////////////////// Asserts
        Assert.isTrue(
            serviceResourceSkillResults != null && !serviceResourceSkillResults.isEmpty(),
            'Service Resource Skills were not retreived successfully.'
        );
    }

    /**
     * @description positive test of getAgentInfoMap method that should return the specialist user info and chat session id test data based on the provided agent work record
     */
    @IsTest
    static void unitGetAgentInfoMapPositive() {
        String pcChatSessionId = VATEST_IdFactory.get(Type.forName('PC_Chat_Session__c'));

        String pcCaseId = VATEST_IdFactory.get(Type.forName('PC_Case__c'));
        PC_Case__c pcCaseRecord = (PC_Case__c) VATEST_SObjectFactory.createSObject(
            new PC_Case__c(Id = pcCaseId, Channel__c = 'Chat')
        );

        AgentWork agentWorkRecord = (AgentWork) VATEST_SObjectFactory.createSObject(
            new AgentWork(UserId = SPECIALIST_USER.Id, WorkItemId = pcCaseId)
        );

        //STUB & MOCKS for repo classes used
        PC_PrcCaseShareRepo mockedPrcCaseShareRepo = (PC_PrcCaseShareRepo) new VATEST_StubBuilder(
                PC_PrcCaseShareRepo.class
            )
            .mockingMethodCall('performCreateUnsafe', SObject.class)
            .withParameterValues(
                new PC_Case__Share(ParentId = pcCaseId, UserOrGroupId = FLP_USER.Id, AccessLevel = 'Edit')
            )
            .returning()
            .defineStub();

        PC_PrcCaseRepo mockedCaseRepo = (PC_PrcCaseRepo) new VATEST_StubBuilder(PC_PrcCaseRepo.class)
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(pcCaseId, new Set<String>{ 'Id', 'Channel__c' })
            .returning(pcCaseRecord)
            .defineStub();

        PC_ChatSessionRepo mockedPcChatSessionRepo = (PC_ChatSessionRepo) new VATEST_StubBuilder(
                PC_ChatSessionRepo.class
            )
            .mockingMethodCall('fetchPcChatSessionByPrcCaseId', Id.class)
            .withParameterValues(pcCaseId)
            .returning(new List<PC_Chat_Session__c>{ new PC_Chat_Session__c(Id = pcChatSessionId) })
            .defineStub();

        Map<String, Object> toForceCastToUser = new Map<String, Object>();
        toForceCastToUser.put('Id', SPECIALIST_USER.Id);
        toForceCastToUser.put('Name', 'Harry Potter');
        toForceCastToUser.put('MediumPhotoUrl', 'https://example.com/medium/imageUrl.jpg');
        toForceCastToUser.put('email', 'Jon.Jakob@TheGingleHeimers.com');
        toForceCastToUser.put('Street', '123 Sesame St');
        toForceCastToUser.put('City', 'Gotham');
        toForceCastToUser.put('State', 'Alabma');
        toForceCastToUser.put('PostalCode', '98601');
        toForceCastToUser.put('Title', 'Batman');
        toForceCastToUser.put('Department', 'Gotham City Poilice');
        toForceCastToUser.put('Division', 'VISN 1');
        String intermediate = JSON.serialize(toForceCastToUser);
        User testAgent = (User) JSON.deserialize(intermediate, User.class);

        VCR_UserRepo mockedUserRepo = (VCR_UserRepo) new VATEST_StubBuilder(VCR_UserRepo.class)
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(
                SPECIALIST_USER.Id,
                new Set<String>{
                    'Id',
                    'Name',
                    'MediumPhotoUrl',
                    'Email',
                    'Street',
                    'City',
                    'State',
                    'PostalCode',
                    'Title',
                    'Department',
                    'Division'
                }
            )
            .returning(testAgent)
            .defineStub();

        PC_ProviderConnectControllerSystemHelper.prcCaseShareRepo = mockedPrcCaseShareRepo;

        PC_ProviderConnectControllerHelper.prcCaseRepo = mockedCaseRepo;
        PC_ProviderConnectControllerHelper.pcChatSessionRepo = mockedPcChatSessionRepo;
        PC_ProviderConnectControllerHelper.userRepo = mockedUserRepo;

        Map<String, Object> result;
        System.runAs(FLP_USER) {
            Test.startTest();
            result = PC_ProviderConnectControllerHelper.getAgentInfoMap(agentWorkRecord);
            Test.stopTest();
        }

        Assert.areEqual(
            testAgent,
            result.get('agent'),
            'Expected the test agent to be returned in the result map, but it was not.'
        );

        Assert.areEqual(
            pcChatSessionId,
            result.get('chatId'),
            'Expected the test chat session Id to be returned in the result map, but it was not.'
        );
    }

    /**
     * @description Method to positively test createNewChatCache method
     **/
    @IsTest
    static void unitCreateNewChatCachePositive() {
        String chatSessionId = VATEST_IdFactory.get(Type.forName('PC_Chat_Session__c'));

        System.runAs(FLP_USER) {
            Test.startTest();
            PC_ProviderConnectControllerHelper.createNewChatCache(chatSessionId);
            Test.stopTest();
        }

        Assert.isTrue(
            Cache.Org.getPartition('local.pcChat').contains(chatSessionId),
            'Expected the local.pcChat org partition to contain the test chatSessionId, but it did not'
        );
    }

    /**
     * @description Method to negatively test checkUnavailableValue method where the skill is disabled for general cases
     **/
    @IsTest
    static void unitCheckUnavailableValueNegative() {
        PC_ProviderConnectController.SkillStatus desiredSkillStatus = new PC_ProviderConnectController.SkillStatus();
        desiredSkillStatus.generalDisabled = true;

        Boolean threwError = false;
        System.runAs(FLP_USER) {
            Test.startTest();
            try {
                PC_ProviderConnectControllerHelper.checkUnavailableValue(desiredSkillStatus, true);
            } catch (Exception caughtException) {
                threwError = true;
            }
            Test.stopTest();
        }

        Assert.isTrue(
            threwError,
            'Expected an exception to be thrown because the Specialist has become unavailable (assigned to a Case).'
        );
    }
}
