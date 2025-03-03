/**
 * @description Test class for PC_ProviderConnectController.
 * @author      Booz Allen
 * @since       2022
 * @group       Provider Connect
 * @see         PC_ProviderConnectController
 **/
@IsTest
public with sharing class PC_ProviderConnectControllerTest {
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
     * @description Method to create test data for unit tests (LEGACY ONLY) (e.g. createCase and togglePause)
     **/
    @TestSetup
    public static void makeData() {
        User flpUser;
        User specialist;

        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            // ----Setup users for legacy test methods ---- //
            flpUser = new VATEST_UserBuilder()
                .withPermissionSet('PrC_FLP_Users')
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .setFields(User.LastName, 'Test PC Provider')
                .build(true);

            specialist = new VATEST_UserBuilder()
                .withPermissionSet('PrC_Specialist_Users')
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .setFields(User.LastName, 'Test PC Specialist')
                .build(true);
        }

        // ---- Setup Specialist related records for legacy test methods ---- //
        //New functionality - on insert Specialists will have Chat added as a Skill

        Skill cardiologySkill = [
            SELECT Id, MasterLabel
            FROM Skill
            WHERE DeveloperName = 'PC_Cardiology'
            LIMIT 1
        ];

        //NOTE: A service resource skill is auto generated based on the Assigned Specialty
        VATEST_SObjectFactory.createSObject(
            new ServiceResource(
                Name = specialist.LastName,
                RelatedRecordId = specialist.Id,
                PC_Assigned_Specialty__c = cardiologySkill.MasterLabel,
                ResourceType = 'A',
                IsActive = true,
                RecordTypeId = new VCR_ServiceResourceRepo().recordTypeConstant.fromDeveloperName('PC_Resource').Id
            ),
            true
        );
    }

    /**
     * @description test for positive getSkills test from FLP perspective when neither NDTH nor VISN Routing are enabled, which defaults to skill-based routing
     */
    @IsTest
    private static void unitGetSkillsDefaultRoutingFLPPositive() {
        //Set routing to default skill-based routing from the utility class
        PC_PrcConfigSettingsUtility.ndthRoutingEnabled = false;
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;

        //Create FLP running user and location
        User runAsUser = FLP_USER;

        //Create available specialists and their specialties
        Id specialistUserId = VATEST_IdFactory.get(Type.forName('User'));
        String specialtyCardiology = 'Cardiology';
        Id specialistUserId2 = VATEST_IdFactory.get(Type.forName('User'));
        String specialtyNeurology = 'Neurology';
        Id specialistUserId3 = VATEST_IdFactory.get(Type.forName('User'));
        String specialtyDental = 'Dental';
        Id specialistUserId4 = VATEST_IdFactory.get(Type.forName('User'));
        String specialtyPhysicalTherapy = 'Physical Therapy';

        //Create Id for specialists location
        Id specialistLocationId = VATEST_IdFactory.get(Type.forName('Schema.Location'));

        /** SETUP SERVICE RESOURCE SKILL REPO STUB **/
        //create fake return result in memory

        //Cardiology service resource skill for service resource 1
        Skill expectedSkill = (Skill) VATEST_SObjectFactory.createSObject(new Skill(MasterLabel = specialtyCardiology));

        ServiceResource expectedServiceResource = (ServiceResource) VATEST_SObjectFactory.createSObject(
            new ServiceResource(RelatedRecordId = specialistUserId, PC_Location__c = specialistLocationId)
        );

        ServiceResourceSkill expectedServiceResourceSkill = (ServiceResourceSkill) VATEST_SObjectFactory.createSObject(
            new ServiceResourceSkill(
                SkillLevel = 1.0,
                SkillId = expectedSkill.Id,
                Skill = expectedSkill,
                ServiceResourceId = expectedServiceResource.Id,
                ServiceResource = expectedServiceResource
            )
        );

        //Neurology service resource skill for service resource 2
        Skill expectedSkill2 = (Skill) VATEST_SObjectFactory.createSObject(new Skill(MasterLabel = specialtyNeurology));

        ServiceResource expectedServiceResource2 = (ServiceResource) VATEST_SObjectFactory.createSObject(
            new ServiceResource(RelatedRecordId = specialistUserId2, PC_Location__c = specialistLocationId)
        );

        ServiceResourceSkill expectedServiceResourceSkill2 = (ServiceResourceSkill) VATEST_SObjectFactory.createSObject(
            new ServiceResourceSkill(
                SkillLevel = 1.0,
                SkillId = expectedSkill2.Id,
                Skill = expectedSkill2,
                ServiceResourceId = expectedServiceResource2.Id,
                ServiceResource = expectedServiceResource2
            )
        );

        //Dental service resource skill for service resource 3
        Skill expectedSkill3 = (Skill) VATEST_SObjectFactory.createSObject(new Skill(MasterLabel = specialtyDental));

        ServiceResource expectedServiceResource3 = (ServiceResource) VATEST_SObjectFactory.createSObject(
            new ServiceResource(RelatedRecordId = specialistUserId3, PC_Location__c = specialistLocationId)
        );

        ServiceResourceSkill expectedServiceResourceSkill3 = (ServiceResourceSkill) VATEST_SObjectFactory.createSObject(
            new ServiceResourceSkill(
                SkillLevel = 1.0,
                SkillId = expectedSkill3.Id,
                Skill = expectedSkill3,
                ServiceResourceId = expectedServiceResource3.Id,
                ServiceResource = expectedServiceResource3
            )
        );

        //Physical Therapy service resource skill for service resource 4
        Skill expectedSkill4 = (Skill) VATEST_SObjectFactory.createSObject(
            new Skill(MasterLabel = specialtyPhysicalTherapy)
        );

        ServiceResource expectedServiceResource4 = (ServiceResource) VATEST_SObjectFactory.createSObject(
            new ServiceResource(RelatedRecordId = specialistUserId4, PC_Location__c = specialistLocationId)
        );

        ServiceResourceSkill expectedServiceResourceSkill4 = (ServiceResourceSkill) VATEST_SObjectFactory.createSObject(
            new ServiceResourceSkill(
                SkillLevel = 1.0,
                SkillId = expectedSkill4.Id,
                Skill = expectedSkill4,
                ServiceResourceId = expectedServiceResource4.Id,
                ServiceResource = expectedServiceResource4
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
                new List<ServiceResourceSkill>{
                    expectedServiceResourceSkill,
                    expectedServiceResourceSkill3,
                    expectedServiceResourceSkill2,
                    expectedServiceResourceSkill4
                }
            ) //Needs to be in skill alphabetical order
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_ProviderConnectController.serviceResourceSkillRepo = stubbedServiceResourceSkillRepo;

        /** SETUP USER SERVICE PRESENCE REPO STUB **/
        //Create fake return result in memory
        UserServicePresence expectedUserServicePresence = (UserServicePresence) VATEST_SObjectFactory.createSObject(
            new UserServicePresence(UserId = specialistUserId)
        );

        UserServicePresence expectedUserServicePresence2 = (UserServicePresence) VATEST_SObjectFactory.createSObject(
            new UserServicePresence(UserId = specialistUserId2)
        );

        UserServicePresence expectedUserServicePresence3 = (UserServicePresence) VATEST_SObjectFactory.createSObject(
            new UserServicePresence(UserId = specialistUserId3)
        );

        UserServicePresence expectedUserServicePresence4 = (UserServicePresence) VATEST_SObjectFactory.createSObject(
            new UserServicePresence(UserId = specialistUserId4)
        );

        PC_UserServicePresenceRepo stubbedUserServicePresenceRepo = (PC_UserServicePresenceRepo) new VATEST_StubBuilder(
                PC_UserServicePresenceRepo.class
            )
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getCurrentUserServicePresence')
            .withParameterTypes()
            //Tell the stub builder what to return
            .returning(
                new List<UserServicePresence>{
                    expectedUserServicePresence,
                    expectedUserServicePresence2,
                    expectedUserServicePresence3,
                    expectedUserServicePresence4
                }
            )
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_ProviderConnectController.userPresenceRepo = stubbedUserServicePresenceRepo;

        /** SETUP AGENT WORK REPO STUB **/
        //Create fake return result in memory
        PC_AgentWorkRepo.AgentWorkCapacityWrapper expectedAgentWorkAggregate = new PC_AgentWorkRepo.AgentWorkCapacityWrapper(
            specialistUserId,
            0.0
        );

        PC_AgentWorkRepo.AgentWorkCapacityWrapper expectedAgentWorkAggregate2 = new PC_AgentWorkRepo.AgentWorkCapacityWrapper(
            specialistUserId2,
            10.0
        );

        PC_AgentWorkRepo.AgentWorkCapacityWrapper expectedAgentWorkAggregate3 = new PC_AgentWorkRepo.AgentWorkCapacityWrapper(
            specialistUserId3,
            15.0
        );

        PC_AgentWorkRepo.AgentWorkCapacityWrapper expectedAgentWorkAggregate4 = new PC_AgentWorkRepo.AgentWorkCapacityWrapper(
            specialistUserId4,
            20.0
        );

        PC_AgentWorkRepo stubbedAgentWorkRepo = (PC_AgentWorkRepo) new VATEST_StubBuilder(PC_AgentWorkRepo.class)
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getAgentWorkCapacity')
            .withParameterTypes()
            //Tell the stub builder what to return
            .returning(
                new List<PC_AgentWorkRepo.AgentWorkCapacityWrapper>{
                    expectedAgentWorkAggregate,
                    expectedAgentWorkAggregate2,
                    expectedAgentWorkAggregate3,
                    expectedAgentWorkAggregate4
                }
            )
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_ProviderConnectController.agentWorkRepo = stubbedAgentWorkRepo;

        // Actual test
        Test.startTest();

        List<PC_ProviderConnectController.SkillStatus> skillStatusResults;
        System.runAs(runAsUser) {
            skillStatusResults = PC_ProviderConnectController.getSkills();
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(
            skillStatusResults != null && !skillStatusResults.isEmpty(),
            'Skill and status wrapper rows for availability matrix table not retrieved and generated successfully.'
        );
    }

    /**
     * @description test for positive getSkills test from FLP perspective when NDTH Agreement routing is enabled
     */
    @IsTest
    private static void unitGetSkillsNDTHRoutingFLPPositive() {
        //Set routing to default skill-based routing from the utility class
        PC_PrcConfigSettingsUtility.ndthRoutingEnabled = true;
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;

        //Create FLP running user and location
        User runAsUser = FLP_User;

        Id runAsUserLocationId = VATEST_IdFactory.get(Type.forName('Schema.Location'));

        //Create available specialists and their specialties
        Id specialistUserId = VATEST_IdFactory.get(Type.forName('User'));
        String specialtyCardiology = 'Cardiology';
        Id specialistUserId2 = VATEST_IdFactory.get(Type.forName('User'));
        String specialtyNeurology = 'Neurology';
        Id specialistUserId3 = VATEST_IdFactory.get(Type.forName('User'));
        String specialtyDental = 'Dental';
        Id specialistUserId4 = VATEST_IdFactory.get(Type.forName('User'));
        String specialtyPhysicalTherapy = 'Physical Therapy';

        //Create Id for specialists location
        Id specialistLocationId = VATEST_IdFactory.get(Type.forName('Schema.Location'));

        //ID for NDTH agreement header
        Id ndthAgreementHeaderId = VATEST_IdFactory.get(Type.forName('PC_NDTH__c'));

        /** SETUP PRC USER REPO STUB **/
        //Create the fake PC User in memory
        PC_User__c expectedPrcUser = (PC_User__c) VATEST_SObjectFactory.createSObject(
            new PC_User__c(OwnerId = runAsUser.Id, User_ID__c = runAsUser.Id, Current_Location__c = runAsUserLocationId)
        );

        PC_PrcUserRepo stubbedPrcUserRepo = (PC_PrcUserRepo) new VATEST_StubBuilder(PC_PrcUserRepo.class)
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('fetchPrcUserByUserId', Id.class)
            .withParameterValues(expectedPrcUser.User_ID__c)
            //Tell the stub builder what to return
            .returning(new List<PC_User__c>{ expectedPrcUser })
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_ProviderConnectController.prcUserRepo = stubbedPrcUserRepo;

        //Inject the stubbed repo into the Controller
        PC_ProviderConnectControllerHelper.prcUserRepo = stubbedPrcUserRepo;

        /** SETUP SERVICE RESOURCE REPO STUB **/
        //Not needed for FLP user test

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

        PC_NDTH_Clinical_Services__c expectedNDTHClinicalService3 = (PC_NDTH_Clinical_Services__c) VATEST_SObjectFactory.createSObject(
            new PC_NDTH_Clinical_Services__c(NDTH__c = ndthAgreementHeaderId, PC_Specialty__c = specialtyDental)
        );

        PC_NDTH_Clinical_Services__c expectedNDTHClinicalService4 = (PC_NDTH_Clinical_Services__c) VATEST_SObjectFactory.createSObject(
            new PC_NDTH_Clinical_Services__c(
                NDTH__c = ndthAgreementHeaderId,
                PC_Specialty__c = specialtyPhysicalTherapy
            )
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
                    expectedNDTHClinicalService2.PC_Specialty__c,
                    expectedNDTHClinicalService3.PC_Specialty__c,
                    expectedNDTHClinicalService4.PC_Specialty__c
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

        /** SETUP SERVICE RESOURCE SKILL REPO STUB **/
        //create fake return result in memory

        //Cardiology service resource skill for service resource 1
        Skill expectedSkill = (Skill) VATEST_SObjectFactory.createSObject(new Skill(MasterLabel = specialtyCardiology));

        ServiceResource expectedServiceResource = (ServiceResource) VATEST_SObjectFactory.createSObject(
            new ServiceResource(RelatedRecordId = specialistUserId, PC_Location__c = specialistLocationId)
        );

        ServiceResourceSkill expectedServiceResourceSkill = (ServiceResourceSkill) VATEST_SObjectFactory.createSObject(
            new ServiceResourceSkill(
                SkillLevel = 1.0,
                SkillId = expectedSkill.Id,
                Skill = expectedSkill,
                ServiceResourceId = expectedServiceResource.Id,
                ServiceResource = expectedServiceResource
            )
        );

        //Neurology service resource skill for service resource 2
        Skill expectedSkill2 = (Skill) VATEST_SObjectFactory.createSObject(new Skill(MasterLabel = specialtyNeurology));

        ServiceResource expectedServiceResource2 = (ServiceResource) VATEST_SObjectFactory.createSObject(
            new ServiceResource(RelatedRecordId = specialistUserId2, PC_Location__c = specialistLocationId)
        );

        ServiceResourceSkill expectedServiceResourceSkill2 = (ServiceResourceSkill) VATEST_SObjectFactory.createSObject(
            new ServiceResourceSkill(
                SkillLevel = 1.0,
                SkillId = expectedSkill2.Id,
                Skill = expectedSkill2,
                ServiceResourceId = expectedServiceResource2.Id,
                ServiceResource = expectedServiceResource2
            )
        );

        //Dental service resource skill for service resource 3
        Skill expectedSkill3 = (Skill) VATEST_SObjectFactory.createSObject(new Skill(MasterLabel = specialtyDental));

        ServiceResource expectedServiceResource3 = (ServiceResource) VATEST_SObjectFactory.createSObject(
            new ServiceResource(RelatedRecordId = specialistUserId3, PC_Location__c = specialistLocationId)
        );

        ServiceResourceSkill expectedServiceResourceSkill3 = (ServiceResourceSkill) VATEST_SObjectFactory.createSObject(
            new ServiceResourceSkill(
                SkillLevel = 1.0,
                SkillId = expectedSkill3.Id,
                Skill = expectedSkill3,
                ServiceResourceId = expectedServiceResource3.Id,
                ServiceResource = expectedServiceResource3
            )
        );

        //Physical Therapy service resource skill for service resource 4
        Skill expectedSkill4 = (Skill) VATEST_SObjectFactory.createSObject(
            new Skill(MasterLabel = specialtyPhysicalTherapy)
        );

        ServiceResource expectedServiceResource4 = (ServiceResource) VATEST_SObjectFactory.createSObject(
            new ServiceResource(RelatedRecordId = specialistUserId4, PC_Location__c = specialistLocationId)
        );

        ServiceResourceSkill expectedServiceResourceSkill4 = (ServiceResourceSkill) VATEST_SObjectFactory.createSObject(
            new ServiceResourceSkill(
                SkillLevel = 1.0,
                SkillId = expectedSkill4.Id,
                Skill = expectedSkill4,
                ServiceResourceId = expectedServiceResource4.Id,
                ServiceResource = expectedServiceResource4
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
                new List<ServiceResourceSkill>{
                    expectedServiceResourceSkill,
                    expectedServiceResourceSkill3,
                    expectedServiceResourceSkill2,
                    expectedServiceResourceSkill4
                }
            ) //Needs to be in skill alphabetical order
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getServiceResourceSkillsNDTHRouting', Set<String>.class, Set<Id>.class)
            .withParameterValues(
                new Set<String>{ specialtyCardiology, specialtyNeurology, specialtyDental, specialtyPhysicalTherapy },
                new Set<Id>{ specialistLocationId }
            )
            //Tell the stub builder what to return
            .returning(
                new List<ServiceResourceSkill>{
                    expectedServiceResourceSkill,
                    expectedServiceResourceSkill3,
                    expectedServiceResourceSkill2,
                    expectedServiceResourceSkill4
                }
            )
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_ProviderConnectController.serviceResourceSkillRepo = stubbedServiceResourceSkillRepo;

        /** SETUP USER SERVICE PRESENCE REPO STUB **/
        //Create fake return result in memory
        UserServicePresence expectedUserServicePresence = (UserServicePresence) VATEST_SObjectFactory.createSObject(
            new UserServicePresence(UserId = specialistUserId)
        );

        UserServicePresence expectedUserServicePresence2 = (UserServicePresence) VATEST_SObjectFactory.createSObject(
            new UserServicePresence(UserId = specialistUserId2)
        );

        UserServicePresence expectedUserServicePresence3 = (UserServicePresence) VATEST_SObjectFactory.createSObject(
            new UserServicePresence(UserId = specialistUserId3)
        );

        UserServicePresence expectedUserServicePresence4 = (UserServicePresence) VATEST_SObjectFactory.createSObject(
            new UserServicePresence(UserId = specialistUserId4)
        );

        PC_UserServicePresenceRepo stubbedUserServicePresenceRepo = (PC_UserServicePresenceRepo) new VATEST_StubBuilder(
                PC_UserServicePresenceRepo.class
            )
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getCurrentUserServicePresence')
            .withParameterTypes()
            //Tell the stub builder what to return
            .returning(
                new List<UserServicePresence>{
                    expectedUserServicePresence,
                    expectedUserServicePresence2,
                    expectedUserServicePresence3,
                    expectedUserServicePresence4
                }
            )
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_ProviderConnectController.userPresenceRepo = stubbedUserServicePresenceRepo;

        /** SETUP AGENT WORK REPO STUB **/
        //Create fake return result in memory
        PC_AgentWorkRepo.AgentWorkCapacityWrapper expectedAgentWorkAggregate = new PC_AgentWorkRepo.AgentWorkCapacityWrapper(
            specialistUserId,
            0.0
        );

        PC_AgentWorkRepo.AgentWorkCapacityWrapper expectedAgentWorkAggregate2 = new PC_AgentWorkRepo.AgentWorkCapacityWrapper(
            specialistUserId2,
            10.0
        );

        PC_AgentWorkRepo.AgentWorkCapacityWrapper expectedAgentWorkAggregate3 = new PC_AgentWorkRepo.AgentWorkCapacityWrapper(
            specialistUserId3,
            15.0
        );

        PC_AgentWorkRepo.AgentWorkCapacityWrapper expectedAgentWorkAggregate4 = new PC_AgentWorkRepo.AgentWorkCapacityWrapper(
            specialistUserId4,
            20.0
        );

        PC_AgentWorkRepo stubbedAgentWorkRepo = (PC_AgentWorkRepo) new VATEST_StubBuilder(PC_AgentWorkRepo.class)
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getAgentWorkCapacity')
            .withParameterTypes()
            //Tell the stub builder what to return
            .returning(
                new List<PC_AgentWorkRepo.AgentWorkCapacityWrapper>{
                    expectedAgentWorkAggregate,
                    expectedAgentWorkAggregate2,
                    expectedAgentWorkAggregate3,
                    expectedAgentWorkAggregate4
                }
            )
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_ProviderConnectController.agentWorkRepo = stubbedAgentWorkRepo;

        // Actual test
        Test.startTest();

        List<PC_ProviderConnectController.SkillStatus> skillStatusResults;
        System.runAs(runAsUser) {
            skillStatusResults = PC_ProviderConnectController.getSkills('lwc');
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(
            skillStatusResults != null && !skillStatusResults.isEmpty(),
            'Skill and status wrapper rows for availability matrix table not retrieved and generated successfully.'
        );
    }

    /**
     * @description positive test of legacy createCase method entry
     */
    @IsTest
    static void unitCreateCasePositive() {
        //Set routing to default skill-based routing from the utility class
        PC_PrcConfigSettingsUtility.ndthRoutingEnabled = false;
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;

        User provider = [SELECT Id FROM User WHERE LastName = 'Test PC Provider' LIMIT 1];

        System.runAs(provider) {
            PC_ProviderConnectController.createCase('Cardiology', 'Test Details', 'Chat', '1234567890');

            List<PC_Case__c> lsCase = [SELECT Id FROM PC_Case__c LIMIT 2];

            Assert.areEqual(1, lsCase.size(), 'Expected one PrC Case to be created.');
        }
    }

    /**
     * @description negative test of legacy createCase method entry
     */
    @IsTest
    static void unitCreateCaseNegative() {
        //Set routing to default skill-based routing from the utility class
        PC_PrcConfigSettingsUtility.ndthRoutingEnabled = false;
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;

        User provider = [SELECT Id FROM User WHERE LastName = 'Test PC Provider' LIMIT 1];

        Boolean hasException = false;
        System.runAs(provider) {
            try {
                PC_ProviderConnectController.createCase('Cardiology', 'Test', 'Test', 'Test');
            } catch (AuraHandledException caughtException) {
                hasException = true;
            }
        }

        Assert.isTrue(hasException, 'Expected createCase to throw an exception.');
    }

    /**
     * @description Method to positively test getAssignedAgent method by returning the agent and chat assigned to the PC Case
     **/
    @IsTest
    static void unitGetAssignedAgentPositive() {
        //Set routing to default skill-based routing from the utility class
        PC_PrcConfigSettingsUtility.ndthRoutingEnabled = false;
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;

        User runAsUser = FLP_USER;

        Id pcCaseId = VATEST_IdFactory.get(Type.forName('PC_Case__c'));
        Id specialistUserId = VATEST_IdFactory.get(Type.forName('User'));
        Id serviceChannelId = VATEST_IdFactory.get(Type.forName('ServiceChannel'));
        Id pcChatSessionId = VATEST_IdFactory.get(Type.forName('PC_Chat_Session__c'));

        PC_AgentWorkRepo mockedAgentWorkRepo = (PC_AgentWorkRepo) new VATEST_StubBuilder(PC_AgentWorkRepo.class)
            .mockingMethodCall('getAgentWorkByCaseId', Id.class)
            .withParameterValues(pcCaseId)
            .returning(
                new AgentWork(
                    UserId = specialistUserId,
                    WorkItemId = pcCaseId,
                    ServiceChannelId = serviceChannelId,
                    CapacityWeight = 0
                )
            )
            .defineStub();

        PC_PrcCaseShareRepo mockedPrcCaseShareRepo = (PC_PrcCaseShareRepo) new VATEST_StubBuilder(
                PC_PrcCaseShareRepo.class
            )
            .mockingMethodCall('performCreateUnsafe', SObject.class)
            .withParameterValues(
                new PC_Case__Share(ParentId = pcCaseId, UserOrGroupId = runAsUser.Id, AccessLevel = 'Edit')
            )
            .returning()
            .defineStub();

        PC_PrcCaseRepo mockedCaseRepo = (PC_PrcCaseRepo) new VATEST_StubBuilder(PC_PrcCaseRepo.class)
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(pcCaseId, new Set<String>{ 'Id', 'Channel__c' })
            .returning(new PC_Case__c(Id = pcCaseId, Channel__c = 'Chat'))
            .defineStub();

        PC_ChatSessionRepo mockedPcChatSessionRepo = (PC_ChatSessionRepo) new VATEST_StubBuilder(
                PC_ChatSessionRepo.class
            )
            .mockingMethodCall('fetchPcChatSessionByPrcCaseId', Id.class)
            .withParameterValues(pcCaseId)
            .returning(new List<PC_Chat_Session__c>{ new PC_Chat_Session__c(Id = pcChatSessionId) })
            .defineStub();

        Map<String, Object> toForceCastToUser = new Map<String, Object>();
        toForceCastToUser.put('Id', specialistUserId);
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
                specialistUserId,
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

        PC_ProviderConnectController.agentWorkRepo = mockedAgentWorkRepo;
        PC_ProviderConnectController.prcCaseRepo = mockedCaseRepo;
        PC_ProviderConnectControllerHelper.prcCaseRepo = mockedCaseRepo;
        PC_ProviderConnectControllerSystemHelper.prcCaseShareRepo = mockedPrcCaseShareRepo;
        PC_ProviderConnectController.pcChatSessionRepo = mockedPcChatSessionRepo;
        PC_ProviderConnectControllerHelper.pcChatSessionRepo = mockedPcChatSessionRepo;
        PC_ProviderConnectControllerHelper.userRepo = mockedUserRepo;

        Map<String, Object> results;
        System.runAs(runAsUser) {
            results = PC_ProviderConnectController.getAssignedAgent(pcCaseId);
        }

        Assert.areEqual(
            testAgent,
            results.get('agent'),
            'Expected the assigned agent record to be returned in the result map'
        );
        Assert.areEqual(
            pcChatSessionId,
            results.get('chatId'),
            'Expected the PC Chat Session related to the PC Case to be returned in the result map'
        );
    }

    /**
     * @description Method to negatively test getAssignedAgent method by providing the method with a null parameter to force the PC_CustomException to throw
     **/
    @IsTest
    static void unitGetAssignedAgentBlankCaseIdNegative() {
        //Set routing to default skill-based routing from the utility class
        PC_PrcConfigSettingsUtility.ndthRoutingEnabled = false;
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;

        User runAsUser = FLP_USER;

        String expectedExceptionMessage = 'Case Id cannot be blank.';

        String raisedExceptionMessage;
        System.runAs(runAsUser) {
            try {
                PC_ProviderConnectController.getAssignedAgent(null);
            } catch (PC_CustomException caughtException) {
                raisedExceptionMessage = caughtException.getMessage();
            }
        }

        Assert.areEqual(
            expectedExceptionMessage,
            raisedExceptionMessage,
            'Expected a PC_CustomException to be thrown by getAssignedAgent when provided a null input parameter for caseId'
        );
    }

    /**
     * @description Method to negatively test getAssignedAgent method by throwing a generic Exception
     **/
    @IsTest
    static void unitGetAssignedAgentGenericExceptionNegative() {
        //Set routing to default skill-based routing from the utility class
        PC_PrcConfigSettingsUtility.ndthRoutingEnabled = false;
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;

        User runAsUser = FLP_USER;

        Id pcCaseId = VATEST_IdFactory.get(Type.forName('PC_Case__c'));

        String expectedExceptionMessage = 'generic Exception Message';

        PC_AgentWorkRepo mockedAgentWorkRepo = (PC_AgentWorkRepo) new VATEST_StubBuilder(PC_AgentWorkRepo.class)
            .mockingMethodCall('getAgentWorkByCaseId', Id.class)
            .withParameterValues(pcCaseId)
            .throwingException(new HandledException(expectedExceptionMessage))
            .defineStub();

        PC_ProviderConnectController.agentWorkRepo = mockedAgentWorkRepo;

        String raisedExceptionMessage;
        System.runAs(runAsUser) {
            try {
                PC_ProviderConnectController.getAssignedAgent(pcCaseId);
            } catch (AuraHandledException caughtException) {
                raisedExceptionMessage = caughtException.getMessage();
            }
        }

        Assert.areEqual(
            expectedExceptionMessage,
            raisedExceptionMessage,
            'Expected a generic Exception to be thrown by getAssignedAgent'
        );
    }

    /**
     * @description Method to negatively test getAssignedAgent method by throwing a Query Exception
     **/
    @IsTest
    static void unitGetAssignedAgentQueryExceptionNegative() {
        //Set routing to default skill-based routing from the utility class
        PC_PrcConfigSettingsUtility.ndthRoutingEnabled = false;
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;

        User runAsUser = FLP_USER;

        Id pcCaseId = VATEST_IdFactory.get(Type.forName('PC_Case__c'));

        String expectedExceptionMessage = 'Query Exception Message';

        PC_AgentWorkRepo mockedAgentWorkRepo = (PC_AgentWorkRepo) new VATEST_StubBuilder(PC_AgentWorkRepo.class)
            .mockingMethodCall('getAgentWorkByCaseId', Id.class)
            .withParameterValues(pcCaseId)
            .throwingException(new QueryException(expectedExceptionMessage))
            .defineStub();

        PC_ProviderConnectController.agentWorkRepo = mockedAgentWorkRepo;

        String raisedExceptionMessage;
        System.runAs(runAsUser) {
            try {
                PC_ProviderConnectController.getAssignedAgent(pcCaseId);
            } catch (AuraHandledException caughtException) {
                raisedExceptionMessage = caughtException.getMessage();
            }
        }

        Assert.areEqual(
            expectedExceptionMessage,
            raisedExceptionMessage,
            'Expected a Query Exception to be thrown by getAssignedAgent'
        );
    }

    /**
     * @description Method to negatively test getAssignedAgent method by throwing a DML Exception
     **/
    @IsTest
    static void unitGetAssignedAgentDmlExceptionNegative() {
        //Set routing to default skill-based routing from the utility class
        PC_PrcConfigSettingsUtility.ndthRoutingEnabled = false;
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;

        User runAsUser = FLP_USER;

        String expectedExceptionMessage = 'Dml Exception Message';

        Id pcCaseId = VATEST_IdFactory.get(Type.forName('PC_Case__c'));
        Id specialistUserId = VATEST_IdFactory.get(Type.forName('User'));
        Id serviceChannelId = VATEST_IdFactory.get(Type.forName('ServiceChannel'));

        PC_AgentWorkRepo mockedAgentWorkRepo = (PC_AgentWorkRepo) new VATEST_StubBuilder(PC_AgentWorkRepo.class)
            .mockingMethodCall('getAgentWorkByCaseId', Id.class)
            .withParameterValues(pcCaseId)
            .returning(
                new AgentWork(
                    UserId = specialistUserId,
                    WorkItemId = pcCaseId,
                    ServiceChannelId = serviceChannelId,
                    CapacityWeight = 5
                )
            )
            .defineStub();

        PC_PrcCaseShareRepo mockedPrcCaseShareRepo = (PC_PrcCaseShareRepo) new VATEST_StubBuilder(
                PC_PrcCaseShareRepo.class
            )
            .mockingMethodCall('performCreateUnsafe', SObject.class)
            .withParameterValues(
                new PC_Case__Share(ParentId = pcCaseId, UserOrGroupId = runAsUser.Id, AccessLevel = 'Edit')
            )
            .throwingException(new DmlException(expectedExceptionMessage))
            .defineStub();

        PC_ProviderConnectController.agentWorkRepo = mockedAgentWorkRepo;
        PC_ProviderConnectControllerSystemHelper.prcCaseShareRepo = mockedPrcCaseShareRepo;

        String raisedExceptionMessage;
        System.runAs(runAsUser) {
            try {
                PC_ProviderConnectController.getAssignedAgent(pcCaseId);
            } catch (AuraHandledException caughtException) {
                raisedExceptionMessage = caughtException.getMessage();
            }
        }

        Assert.areEqual(
            expectedExceptionMessage,
            raisedExceptionMessage,
            'Expected a Dml Exception to be thrown by getAssignedAgent'
        );
    }

    /**
     * @description positive test of cancelCaseRoutingError to ensure that the method successfully cancels a PC Case and sets the specialist notes indicating the attempted assignee was double booked
     */
    @IsTest
    static void unitCancelCaseRoutingErrorPositive() {
        //Set routing to default skill-based routing from the utility class
        PC_PrcConfigSettingsUtility.ndthRoutingEnabled = false;
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;

        User provider = FLP_USER;

        PC_PrcCaseRepo realCaseRepo = new PC_PrcCaseRepo();

        PC_Case__c testCase = (PC_Case__c) VATEST_SObjectFactory.createSObject(
            new PC_Case__c(
                RecordTypeId = realCaseRepo.recordTypeConstant.fromDeveloperName('Provider_Connect_Case').Id,
                Case_Details__c = 'Test Details',
                Subject__c = 'Chat - Test PC Provider',
                Specialty__c = 'Cardiac Surgery',
                Status__c = 'Open',
                Channel__c = 'Chat',
                Callback_Number__c = null,
                Patient_Account__c = null,
                isRunningTest_DO_NOT_USE__c = true
            )
        );

        PC_Case__c clonedCase = testCase.clone(true, true, true, true);
        clonedCase.Status__c = 'Cancelled';
        clonedCase.Specialist_Notes__c = 'Cancelled Reason:\nDouble booked';

        PC_PrcCaseRepo mockedCaseRepo = (PC_PrcCaseRepo) new VATEST_StubBuilder(PC_PrcCaseRepo.class)
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class, Set<String>.class)
            .withParameterValues(testCase.Id, new Set<String>{ 'Closed__c' })
            .returning(testCase)
            .mockingMethodCall('doUpdate')
            .withParameterTypes(SObject.class)
            .withParameterValues(clonedCase)
            .returning()
            .defineStub();

        PC_ProviderConnectController.prcCaseRepo = mockedCaseRepo;

        System.runAs(provider) {
            Test.startTest();

            PC_ProviderConnectController.cancelCaseRoutingError(testCase.Id);

            Test.stopTest();
        }

        Assert.areEqual('Cancelled', testCase.Status__c, 'Expected the PC Case to be Cancelled.');
        Assert.areEqual(
            'Cancelled Reason:\nDouble booked',
            testCase.Specialist_Notes__c,
            'Expected the PC Case Specialist Notes field to be updated.'
        );
    }

    /**
     * @description negative test of cancelCaseRoutingError to ensure it throws an exception when a null input is provided
     */
    @IsTest
    static void unitCancelCaseRoutingErrorBlankInputNegative() {
        //Set routing to default skill-based routing from the utility class
        PC_PrcConfigSettingsUtility.ndthRoutingEnabled = false;
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;

        User provider = FLP_USER;

        String expectedExceptionMessage = 'Provided PC Case Id cannot be blank.';

        String raisedExceptionMessage;

        Test.startTest();

        System.runAs(provider) {
            try {
                PC_ProviderConnectController.cancelCaseRoutingError(null);
            } catch (PC_CustomException caughtException) {
                raisedExceptionMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        Assert.areEqual(
            expectedExceptionMessage,
            raisedExceptionMessage,
            'Expected a custom exception to be thrown when input is null indicating that the Provided PC Case Id cannot be blank..'
        );
    }

    /**
     * @description negative test of cancelCaseRoutingError to ensure it throws an exception the retrieved PC Case is already closed
     */
    @IsTest
    static void unitCancelCaseRoutingErrorAlreadyClosedNegative() {
        //Set routing to default skill-based routing from the utility class
        PC_PrcConfigSettingsUtility.ndthRoutingEnabled = false;
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;

        User provider = FLP_USER;

        Id caseId = VATEST_IdFactory.get(Type.forName('PC_Case__c'));

        Map<String, Object> toForceCastToPcCase = new Map<String, Object>();
        toForceCastToPcCase.put('Closed__c', true);
        String intermediate = JSON.serialize(toForceCastToPcCase);
        PC_Case__c testCase = (PC_Case__c) JSON.deserialize(intermediate, PC_Case__c.class);
        testCase.Id = caseId;

        PC_PrcCaseRepo mockedCaseRepo = (PC_PrcCaseRepo) new VATEST_StubBuilder(PC_PrcCaseRepo.class)
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class, Set<String>.class)
            .withParameterValues(caseId, new Set<String>{ 'Closed__c' })
            .returning(testCase)
            .defineStub();

        PC_ProviderConnectController.prcCaseRepo = mockedCaseRepo;

        String expectedExceptionMessage = 'This case is already closed. Please refresh the page.';

        String raisedExceptionMessage;

        Test.startTest();

        System.runAs(provider) {
            try {
                PC_ProviderConnectController.cancelCaseRoutingError(caseId);
            } catch (Exception caughtException) {
                raisedExceptionMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        Assert.areEqual(
            expectedExceptionMessage,
            raisedExceptionMessage,
            'Expected a custom exception to be thrown when the PC Case is already closed.'
        );
    }

    /**
     * @description negative test of cancelCaseRoutingError to ensure a DML exception is thrown
     */
    @IsTest
    static void unitCancelCaseRoutingErrorDmlExceptionNegative() {
        //Set routing to default skill-based routing from the utility class
        PC_PrcConfigSettingsUtility.ndthRoutingEnabled = false;
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;

        User provider = SPECIALIST_USER;

        Id caseId = VATEST_IdFactory.get(Type.forName('PC_Case__c'));

        String expectedExceptionMessage = 'DML Exception Message.';

        Map<String, Object> toForceCastToPcCase = new Map<String, Object>();
        toForceCastToPcCase.put('Closed__c', false);
        String intermediate = JSON.serialize(toForceCastToPcCase);
        PC_Case__c testCase = (PC_Case__c) JSON.deserialize(intermediate, PC_Case__c.class);
        testCase.Id = caseId;

        PC_PrcCaseRepo mockedCaseRepo = (PC_PrcCaseRepo) new VATEST_StubBuilder(PC_PrcCaseRepo.class)
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class, Set<String>.class)
            .withParameterValues(caseId, new Set<String>{ 'Closed__c' })
            .throwingException(new DmlException(expectedExceptionMessage))
            .defineStub();

        PC_ProviderConnectController.prcCaseRepo = mockedCaseRepo;

        Test.startTest();

        String caughtMessage;
        System.runAs(provider) {
            try {
                PC_ProviderConnectController.cancelCaseRoutingError(caseId);
            } catch (AuraHandledException caughtException) {
                caughtMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        Assert.areEqual(
            expectedExceptionMessage,
            caughtMessage,
            'Expected a DML exception to be thrown by cancelCaseRoutingError.'
        );
    }

    /**
     * @description negative test of cancelCaseRoutingError to ensure a Query exception is thrown
     */
    @IsTest
    static void unitCancelCaseRoutingErrorQueryExceptionNegative() {
        //Set routing to default skill-based routing from the utility class
        PC_PrcConfigSettingsUtility.ndthRoutingEnabled = false;
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;

        User provider = SPECIALIST_USER;

        Id caseId = VATEST_IdFactory.get(Type.forName('PC_Case__c'));

        String expectedExceptionMessage = 'Query Exception Message.';

        PC_PrcCaseRepo mockedCaseRepo = (PC_PrcCaseRepo) new VATEST_StubBuilder(PC_PrcCaseRepo.class)
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class, Set<String>.class)
            .withParameterValues(caseId, new Set<String>{ 'Closed__c' })
            .throwingException(new QueryException(expectedExceptionMessage))
            .defineStub();

        PC_ProviderConnectController.prcCaseRepo = mockedCaseRepo;

        Test.startTest();

        String caughtMessage;
        System.runAs(provider) {
            try {
                PC_ProviderConnectController.cancelCaseRoutingError(caseId);
            } catch (AuraHandledException caughtException) {
                caughtMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        Assert.areEqual(
            expectedExceptionMessage,
            caughtMessage,
            'Expected a Query exception to be thrown by cancelCaseRoutingError.'
        );
    }

    /**
     * @description negative test of cancelCaseRoutingError to ensure a generic Exception exception is thrown
     */
    @IsTest
    static void unitCancelCaseRoutingErrorGenericExceptionNegative() {
        //Set routing to default skill-based routing from the utility class
        PC_PrcConfigSettingsUtility.ndthRoutingEnabled = false;
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;

        User provider = SPECIALIST_USER;

        Id caseId = VATEST_IdFactory.get(Type.forName('PC_Case__c'));

        String expectedExceptionMessage = 'generic Exception Message.';

        Map<String, Object> toForceCastToPcCase = new Map<String, Object>();
        toForceCastToPcCase.put('Closed__c', false);
        String intermediate = JSON.serialize(toForceCastToPcCase);
        PC_Case__c testCase = (PC_Case__c) JSON.deserialize(intermediate, PC_Case__c.class);
        testCase.Id = caseId;

        PC_PrcCaseRepo mockedCaseRepo = (PC_PrcCaseRepo) new VATEST_StubBuilder(PC_PrcCaseRepo.class)
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class, Set<String>.class)
            .withParameterValues(caseId, new Set<String>{ 'Closed__c' })
            .throwingException(new HandledException(expectedExceptionMessage))
            .defineStub();

        PC_ProviderConnectController.prcCaseRepo = mockedCaseRepo;

        Test.startTest();

        String caughtMessage;
        System.runAs(provider) {
            try {
                PC_ProviderConnectController.cancelCaseRoutingError(caseId);
            } catch (AuraHandledException caughtException) {
                caughtMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        Assert.areEqual(
            expectedExceptionMessage,
            caughtMessage,
            'Expected a generic exception to be thrown by cancelCaseRoutingError.'
        );
    }
    /**
     * @description Method to test Pause/Resume functionality
     **/
    @IsTest
    static void unitTogglePausePositive() {
        //Set routing to default skill-based routing from the utility class
        PC_PrcConfigSettingsUtility.ndthRoutingEnabled = false;
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;

        User specialist = [SELECT Id FROM User WHERE LastName = 'Test PC Specialist' LIMIT 1];
        User frontLineProvider = [SELECT Id FROM User WHERE LastName = 'Test PC Provider' LIMIT 1];
        List<Id> caseIds = new List<Id>();
        System.runAs(frontLineProvider) {
            PC_Case__c prcCase1 = PC_ProviderConnectController.createCase(
                'Cardiology',
                'Test Details',
                'Chat',
                '1234567890'
            );
            prcCase1.OwnerId = specialist.Id;
            PC_Case__c prcCase2 = PC_ProviderConnectController.createCase(
                'Dental',
                'Test Details',
                'Chat',
                '1234567890'
            );
            prcCase2.OwnerId = specialist.Id;
            update new List<PC_Case__c>{ prcCase1, prcCase2 };
            caseIds.add(prcCase1.Id);
            caseIds.add(prcCase2.Id);
        }
        System.runAs(specialist) {
            Assert.isTrue(
                PC_ProviderConnectController.togglePauseChat(caseIds, 'Test'),
                'Expected togglePauseChat to run successfully and return true.'
            );
        }
    }

    /**
     * @description positive test of isUserPaused to ensure true is returned when the user is marked as available in omni-channel
     */
    @IsTest
    private static void unitIsUserPausedTruePositive() {
        // Test data setup

        //Create Specialist (agent) running user
        User runAsUser = SPECIALIST_USER;

        PC_UserServicePresenceRepo mockedUserServicePresenceRepo = (PC_UserServicePresenceRepo) new VATEST_StubBuilder(
                PC_UserServicePresenceRepo.class
            )
            .mockingMethodCall('getCurrentUserServicePresenceForRunningUser')
            .withParameterTypes()
            .returning(
                new List<UserServicePresence>{
                    new UserServicePresence(
                        UserId = runAsUser.Id,
                        ServicePresenceStatus = new ServicePresenceStatus(
                            DeveloperName = 'PC_Available_Provider_Connect'
                        )
                    )
                }
            )
            .defineStub();

        PC_ProviderConnectController.userPresenceRepo = mockedUserServicePresenceRepo;

        // Actual test
        Test.startTest();

        Boolean result;
        System.runAs(runAsUser) {
            result = PC_ProviderConnectController.isUserPaused();
        }

        Test.stopTest();

        // Asserts
        Assert.isNotNull(result, 'isUserPaused should have returned false since the user is available.');
        Assert.isFalse(result, 'isUserPaused should have returned false since the user is available.');
    }

    /**
     * @description positive test of isUserPaused to ensure false is returned when the user is marked as wrapping up in omni-channel
     */
    @IsTest
    private static void unitIsUserPausedFalsePositive() {
        // Test data setup

        //Create Specialist (agent) running user
        User runAsUser = SPECIALIST_USER;

        PC_UserServicePresenceRepo mockedUserServicePresenceRepo = (PC_UserServicePresenceRepo) new VATEST_StubBuilder(
                PC_UserServicePresenceRepo.class
            )
            .mockingMethodCall('getCurrentUserServicePresenceForRunningUser')
            .withParameterTypes()
            .returning(
                new List<UserServicePresence>{
                    new UserServicePresence(
                        UserId = runAsUser.Id,
                        ServicePresenceStatus = new ServicePresenceStatus(DeveloperName = 'PC_Wrap_Up')
                    )
                }
            )
            .defineStub();

        PC_ProviderConnectController.userPresenceRepo = mockedUserServicePresenceRepo;

        // Actual test
        Test.startTest();

        Boolean result;
        System.runAs(runAsUser) {
            result = PC_ProviderConnectController.isUserPaused();
        }

        Test.stopTest();

        // Asserts
        Assert.isNotNull(result, 'isUserPaused should have returned true since the user is wrapping up.');
        Assert.isTrue(result, 'isUserPaused should have returned true since the user is wrapping up.');
    }

    /**
     * @description positive test for createPcSpecialistUnavailability to ensure that the Specialty and the running FLP User's Location and VISN data are correctly tracked when creating a Specialist Unavailability record
     */
    @IsTest
    private static void unitCreatePcSpecialistUnavailabilityTestPositive() {
        // Test data setup

        //Create FLP running user and location
        User runAsUser = FLP_USER;

        Id pcUserId = VATEST_IdFactory.get(Type.forName('PC_User__c'));
        Id locationId = VATEST_IdFactory.get(Type.forName('Schema.Location'));

        PC_PrcUserRepo mockPrcUserRepo = (PC_PrcUserRepo) new VATEST_StubBuilder(PC_PrcUserRepo.class)
            .mockingMethodCall('fetchPrcUserByUserIdWithSelectFields', Id.class, Set<String>.class)
            .withParameterValues(runAsUser.Id, new Set<String>{ 'Current_Location__c', 'User_ID__r.Division' })
            .returning(
                new List<PC_User__c>{
                    new PC_User__c(
                        Id = pcUserId,
                        Current_Location__c = locationId,
                        User_ID__r = new User(Division = 'VISN 1')
                    )
                }
            )
            .defineStub();

        PC_Specialist_Unavailability__c inputPSU = new PC_Specialist_Unavailability__c(
            PC_Specialty__c = 'Cardiology',
            PC_VISN__c = 'VISN 1',
            FLP_Current_Location__c = locationId
        );

        PC_SpecialistUnavailabilityRepo mockSpecialistUnavailabilityRepo = (PC_SpecialistUnavailabilityRepo) new VATEST_StubBuilder(
                PC_SpecialistUnavailabilityRepo.class
            )
            .mockingMethodCall('insertPCSpecialistUnavailability', PC_Specialist_Unavailability__c.class)
            .withParameterValues(inputPSU)
            .returning(inputPSU)
            .defineStub();

        PC_ProviderConnectController.prcUserRepo = mockPrcUserRepo;
        PC_ProviderConnectController.pcSpecialistUnavailabilityRepo = mockSpecialistUnavailabilityRepo;

        // Actual test
        Test.startTest();

        PC_Specialist_Unavailability__c result;
        System.runAs(runAsUser) {
            result = PC_ProviderConnectController.createPcSpecialistUnavailability('Cardiology');
        }

        Test.stopTest();

        // Asserts
        Assert.areEqual(
            'Cardiology',
            result.PC_Specialty__c,
            'Expected the returned Specialist Unavailability record to have a Specialty of \'Cardiology\''
        );
        Assert.areEqual(
            'VISN 1',
            result.PC_VISN__c,
            'Expected the returned Specialist Unavailability record to have a VISN of \'VISN 1\''
        );
        Assert.areEqual(
            locationId,
            result.FLP_Current_Location__c,
            'Expected the returned Specialist Unavailability record to have a FLP Current Location equal to the running user FLP\'s current location'
        );
    }

    /**
     * @description negative test for createPcSpecialistUnavailability by throwing a DmlException
     */
    @IsTest
    private static void unitCreatePcSpecialistUnavailabilityDmlExceptionNegative() {
        // Test data setup

        //Create FLP running user and location
        User runAsUser = FLP_USER;

        Id pcUserId = VATEST_IdFactory.get(Type.forName('PC_User__c'));
        Id locationId = VATEST_IdFactory.get(Type.forName('Schema.Location'));

        PC_PrcUserRepo mockPrcUserRepo = (PC_PrcUserRepo) new VATEST_StubBuilder(PC_PrcUserRepo.class)
            .mockingMethodCall('fetchPrcUserByUserIdWithSelectFields', Id.class, Set<String>.class)
            .withParameterValues(runAsUser.Id, new Set<String>{ 'Current_Location__c', 'User_ID__r.Division' })
            .returning(
                new List<PC_User__c>{
                    new PC_User__c(
                        Id = pcUserId,
                        Current_Location__c = locationId,
                        User_ID__r = new User(Division = 'VISN 1')
                    )
                }
            )
            .defineStub();

        PC_Specialist_Unavailability__c inputPSU = new PC_Specialist_Unavailability__c(
            PC_Specialty__c = 'Cardiology',
            PC_VISN__c = 'VISN 1',
            FLP_Current_Location__c = locationId
        );

        PC_SpecialistUnavailabilityRepo mockSpecialistUnavailabilityRepo = (PC_SpecialistUnavailabilityRepo) new VATEST_StubBuilder(
                PC_SpecialistUnavailabilityRepo.class
            )
            .mockingMethodCall('insertPCSpecialistUnavailability', PC_Specialist_Unavailability__c.class)
            .withParameterValues(inputPSU)
            .throwingException(new DmlException('DML Exception Message'))
            .defineStub();

        PC_ProviderConnectController.prcUserRepo = mockPrcUserRepo;
        PC_ProviderConnectController.pcSpecialistUnavailabilityRepo = mockSpecialistUnavailabilityRepo;

        // Actual test
        Test.startTest();

        String exceptionMessage;
        System.runAs(runAsUser) {
            try {
                PC_ProviderConnectController.createPcSpecialistUnavailability('Cardiology');
            } catch (AuraHandledException caughtException) {
                exceptionMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        // Asserts
        Assert.areEqual('DML Exception Message', exceptionMessage, 'Expected a DmlException to be thrown');
    }

    /**
     * @description negative test for createPcSpecialistUnavailability by throwing a QueryException
     */
    @IsTest
    private static void unitCreatePcSpecialistUnavailabilityQueryExceptionNegative() {
        // Test data setup

        //Create FLP running user and location
        User runAsUser = FLP_USER;

        PC_PrcUserRepo mockPrcUserRepo = (PC_PrcUserRepo) new VATEST_StubBuilder(PC_PrcUserRepo.class)
            .mockingMethodCall('fetchPrcUserByUserIdWithSelectFields', Id.class, Set<String>.class)
            .withParameterValues(runAsUser.Id, new Set<String>{ 'Current_Location__c', 'User_ID__r.Division' })
            .throwingException(new QueryException('Query Exception Message'))
            .defineStub();

        PC_ProviderConnectController.prcUserRepo = mockPrcUserRepo;

        // Actual test
        Test.startTest();

        String exceptionMessage;
        System.runAs(runAsUser) {
            try {
                PC_ProviderConnectController.createPcSpecialistUnavailability('Cardiology');
            } catch (AuraHandledException caughtException) {
                exceptionMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        // Asserts
        Assert.areEqual('Query Exception Message', exceptionMessage, 'Expected a QueryException to be thrown');
    }

    /**
     * @description negative test for createPcSpecialistUnavailability by throwing a generic Exception
     */
    @IsTest
    private static void unitCreatePcSpecialistUnavailabilityGenericExceptionTestNegative() {
        // Test data setup

        //Create FLP running user and location
        User runAsUser = FLP_USER;

        PC_PrcUserRepo mockPrcUserRepo = (PC_PrcUserRepo) new VATEST_StubBuilder(PC_PrcUserRepo.class)
            .mockingMethodCall('fetchPrcUserByUserIdWithSelectFields', Id.class, Set<String>.class)
            .withParameterValues(runAsUser.Id, new Set<String>{ 'Current_Location__c', 'User_ID__r.Division' })
            .throwingException(new PC_CustomException('Generic Exception Message'))
            .defineStub();

        PC_ProviderConnectController.prcUserRepo = mockPrcUserRepo;

        // Actual test
        Test.startTest();

        String exceptionMessage;
        System.runAs(runAsUser) {
            try {
                PC_ProviderConnectController.createPcSpecialistUnavailability('Cardiology');
            } catch (AuraHandledException caughtException) {
                exceptionMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        // Asserts
        Assert.areEqual('Generic Exception Message', exceptionMessage, 'Expected a generic Exception to be thrown');
    }
}
