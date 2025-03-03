/**
 * @description test class for PC_ChatStreamController
 * @author      Booz Allen Hamilton
 * @see         PC_ChatStreamController
 */
@IsTest
private with sharing class PC_ChatStreamControllerTest {
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
     * @description sets up the stubbed repos and their mocked methods for the ProviderConnectcontroller getSkills method utilized by PC_ChatStreamController invokePushTopic method
     */
    private static void setupProviderConnectControllerMocks() {
        //Set routing to default skill-based routing from the utility class
        PC_PrcConfigSettingsUtility.ndthRoutingEnabled = false;
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;

        //---- Set up ProviderConnectController repos ----//
        //Create available specialist and their specialty and location
        Id specialistUserId = SPECIALIST_USER.Id;
        Id specialistLocationId = VATEST_IdFactory.get(Type.forName('Schema.Location'));
        String specialtyCardiology = 'Cardiology';

        String chatChannelSkill = 'Chat';

        /** SETUP SERVICE RESOURCE SKILL REPO STUB **/
        ServiceResource expectedServiceResource = (ServiceResource) VATEST_SObjectFactory.createSObject(
            new ServiceResource(
                Id = VATEST_IdFactory.get(Type.forName('ServiceResource')),
                RelatedRecordId = specialistUserId,
                PC_Location__c = specialistLocationId
            )
        );

        //Cardiology service resource skill for service resource
        Skill expectedSkillCardiology = (Skill) VATEST_SObjectFactory.createSObject(
            new Skill(Id = VATEST_IdFactory.get(Type.forName('Skill')), MasterLabel = specialtyCardiology)
        );

        ServiceResourceSkill expectedServiceResourceSkill = (ServiceResourceSkill) VATEST_SObjectFactory.createSObject(
            new ServiceResourceSkill(
                SkillLevel = 1.0,
                SkillId = expectedSkillCardiology.Id,
                Skill = expectedSkillCardiology,
                ServiceResourceId = expectedServiceResource.Id,
                ServiceResource = expectedServiceResource
            )
        );

        //Chat channel service resource skill for service resource
        Skill expectedSkillChat = (Skill) VATEST_SObjectFactory.createSObject(
            new Skill(Id = VATEST_IdFactory.get(Type.forName('Skill')), MasterLabel = chatChannelSkill)
        );

        ServiceResourceSkill expectedServiceResourceSkill2 = (ServiceResourceSkill) VATEST_SObjectFactory.createSObject(
            new ServiceResourceSkill(
                SkillLevel = 1.0,
                SkillId = expectedSkillChat.Id,
                Skill = expectedSkillChat,
                ServiceResourceId = expectedServiceResource.Id,
                ServiceResource = expectedServiceResource
            )
        );

        PC_ServiceResourceSkillRepo stubbedServiceResourceSkillRepo = (PC_ServiceResourceSkillRepo) new VATEST_StubBuilder(
                PC_ServiceResourceSkillRepo.class
            )
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getServiceResourceSkills')
            .withParameterTypes()
            //Tell the stub builder what to return
            .returning(new List<ServiceResourceSkill>{ expectedServiceResourceSkill, expectedServiceResourceSkill2 }) //Needs to be in skill alphabetical order
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_ProviderConnectController.serviceResourceSkillRepo = stubbedServiceResourceSkillRepo;

        /** SETUP USER SERVICE PRESENCE REPO STUB **/
        UserServicePresence expectedUserServicePresence = (UserServicePresence) VATEST_SObjectFactory.createSObject(
            new UserServicePresence(UserId = specialistUserId)
        );

        PC_UserServicePresenceRepo stubbedUserServicePresenceRepo = (PC_UserServicePresenceRepo) new VATEST_StubBuilder(
                PC_UserServicePresenceRepo.class
            )
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getCurrentUserServicePresence')
            .withParameterTypes()
            //Tell the stub builder what to return
            .returning(new List<UserServicePresence>{ expectedUserServicePresence })
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_ProviderConnectController.userPresenceRepo = stubbedUserServicePresenceRepo;

        /** SETUP AGENT WORK REPO STUB **/
        PC_AgentWorkRepo.AgentWorkCapacityWrapper expectedAgentWorkAggregate = new PC_AgentWorkRepo.AgentWorkCapacityWrapper(
            specialistUserId,
            0.0
        );

        PC_AgentWorkRepo stubbedAgentWorkRepo = (PC_AgentWorkRepo) new VATEST_StubBuilder(PC_AgentWorkRepo.class)
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('getAgentWorkCapacity')
            .withParameterTypes()
            //Tell the stub builder what to return
            .returning(new List<PC_AgentWorkRepo.AgentWorkCapacityWrapper>{ expectedAgentWorkAggregate })
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_ProviderConnectController.agentWorkRepo = stubbedAgentWorkRepo;
    }

    /**
     * @description positive test of invokePushTopic where the input parameter has a valid UserServicePresence record
     */
    @IsTest
    private static void unitInvokePushTopicFromUserServicePresencePositive() {
        // Test data setup
        setupProviderConnectControllerMocks();

        /** SETUP AW PUSH EVENT REPO **/
        PC_AWPushEvent__c expectedAWPushEventQueried = new PC_AWPushEvent__c(OwnerId = SPECIALIST_USER.Id);
        PC_AWPushEvent__c expectedAWPushEventProcessed = new PC_AWPushEvent__c(
            OwnerId = SPECIALIST_USER.Id,
            CaseClosedJSON__c = '',
            CaseClosedByName__c = '',
            CaseClosedStatus__c = '',
            NewCaseOwner__c = '',
            NewOwnerTitle__c = '',
            NewOwnerCity__c = '',
            NewOwnerState__c = '',
            NewOwnerEmail__c = '',
            NewOwnerMediumPhotoUrl__c = '',
            NewOwnerDepartment__c = '',
            SkillName__c = 'Cardiology',
            HasPresence__c = true,
            ConsultantsOnline__c = 1,
            MinCapacity__c = 0.0,
            PatientSpecificDisabled__c = true,
            GeneralDisabled__c = false
        );

        PC_AWPushEventRepo mockedAWPushEventRepo = (PC_AWPushEventRepo) new VATEST_StubBuilder(PC_AWPushEventRepo.class)
            .mockingMethodCall('getAWPushEventsByOwners', Set<String>.class)
            .withParameterValues(new Set<String>{ SPECIALIST_USER.Id })
            .returning(new List<PC_AWPushEvent__c>{ expectedAWPushEventQueried })
            .defineStub();

        PC_AWPushEventRepo mockedAWPushEventSystemRepo = (PC_AWPushEventRepo) new VATEST_StubBuilder(
                PC_AWPushEventRepo.class
            )
            .mockingMethodCall('performUpsertUnsafe', List<PC_AWPushEvent__c>.class)
            .withParameterValues(new List<PC_AWPushEvent__c>{ expectedAWPushEventProcessed })
            .returning()
            .defineStub();

        PC_ChatStreamController.awPushEventRepo = mockedAWPushEventRepo;
        PC_ChatStreamControllerSysHelper.awPushEventRepo = mockedAWPushEventSystemRepo;

        /** SETUP USER REPO */
        VCR_UserRepo mockedUserRepo = (VCR_UserRepo) new VATEST_StubBuilder(VCR_UserRepo.class)
            .mockingMethodCall('fetchUsersByIds', Set<String>.class)
            .withParameterValues(new Set<String>{ SPECIALIST_USER.Id })
            .returning(new List<User>{ SPECIALIST_USER })
            .defineStub();

        PC_ChatStreamController.userRepo = mockedUserRepo;

        /** SETUP FLOW INPUT PARAMETER */
        PC_ChatStreamController.InvokePushTopicFlowInput uspInputValid = new PC_ChatStreamController.InvokePushTopicFlowInput();
        uspInputValid.userServicePresence = new UserServicePresence(
            UserId = SPECIALIST_USER.Id,
            PC_Specialty__c = 'Cardiology'
        );

        PC_ChatStreamController.InvokePushTopicFlowInput uspInputInvalid = new PC_ChatStreamController.InvokePushTopicFlowInput();
        uspInputInvalid.userServicePresence = new UserServicePresence(UserId = null, PC_Specialty__c = 'Cardiology');

        List<PC_ChatStreamController.InvokePushTopicFlowInput> uspInputList = new List<PC_ChatStreamController.InvokePushTopicFlowInput>{
            uspInputValid,
            uspInputInvalid
        };

        // Actual test
        List<PC_AWPushEvent__c> results;
        System.runAs(SPECIALIST_USER) {
            Test.startTest();

            results = PC_ChatStreamController.invokePushTopic(uspInputList);

            Test.stopTest();
        }

        // Asserts
        Assert.isNotNull(results, 'Expected the returned list of upserted AW Push Events to not be null, but it was.');
        Assert.isFalse(
            results.isEmpty(),
            'Expected the returned list of upserted AW Push Events to not be empty, but it was.'
        );
    }

    /**
     * @description positive test of invokePushTopic where the input parameter has a valid AgentWork and PrC Case record
     */
    @IsTest
    private static void unitInvokePushTopicFromAgentWorkPositive() {
        // Test data setup
        setupProviderConnectControllerMocks();

        /** SETUP AW PUSH EVENT REPO **/
        PC_AWPushEvent__c expectedAWPushEventQueried = new PC_AWPushEvent__c(OwnerId = SPECIALIST_USER.Id);
        PC_AWPushEvent__c expectedAWPushEventProcessed = new PC_AWPushEvent__c(
            OwnerId = SPECIALIST_USER.Id,
            CaseClosedJSON__c = '',
            CaseClosedByName__c = '',
            CaseClosedStatus__c = '',
            NewCaseOwner__c = '',
            NewOwnerTitle__c = '',
            NewOwnerCity__c = '',
            NewOwnerState__c = '',
            NewOwnerEmail__c = '',
            NewOwnerMediumPhotoUrl__c = '',
            NewOwnerDepartment__c = '',
            SkillName__c = 'Cardiology',
            HasPresence__c = true,
            ConsultantsOnline__c = 1,
            MinCapacity__c = 0.0,
            PatientSpecificDisabled__c = true,
            GeneralDisabled__c = false
        );

        PC_AWPushEventRepo mockedAWPushEventRepo = (PC_AWPushEventRepo) new VATEST_StubBuilder(PC_AWPushEventRepo.class)
            .mockingMethodCall('getAWPushEventsByOwners', Set<String>.class)
            .withParameterValues(new Set<String>{ SPECIALIST_USER.Id })
            .returning(new List<PC_AWPushEvent__c>{ expectedAWPushEventQueried })
            .defineStub();

        PC_AWPushEventRepo mockedAWPushEventSystemRepo = (PC_AWPushEventRepo) new VATEST_StubBuilder(
                PC_AWPushEventRepo.class
            )
            .mockingMethodCall('performUpsertUnsafe', List<PC_AWPushEvent__c>.class)
            .withParameterValues(new List<PC_AWPushEvent__c>{ expectedAWPushEventProcessed })
            .returning()
            .defineStub();

        PC_ChatStreamController.awPushEventRepo = mockedAWPushEventRepo;
        PC_ChatStreamControllerSysHelper.awPushEventRepo = mockedAWPushEventSystemRepo;

        /** SETUP USER REPO */
        VCR_UserRepo mockedUserRepo = (VCR_UserRepo) new VATEST_StubBuilder(VCR_UserRepo.class)
            .mockingMethodCall('fetchUsersByIds', Set<String>.class)
            .withParameterValues(new Set<String>{ SPECIALIST_USER.Id })
            .returning(new List<User>{ SPECIALIST_USER })
            .defineStub();

        PC_ChatStreamController.userRepo = mockedUserRepo;

        /** SETUP FLOW INPUT PARAMETER */
        PC_ChatStreamController.InvokePushTopicFlowInput awInput = new PC_ChatStreamController.InvokePushTopicFlowInput();
        awInput.agentWork = new AgentWork(UserId = SPECIALIST_USER.Id);
        awInput.pcCase = new PC_Case__c(Specialty__c = 'Cardiology');

        List<PC_ChatStreamController.InvokePushTopicFlowInput> awInputList = new List<PC_ChatStreamController.InvokePushTopicFlowInput>{
            awInput
        };

        // Actual test
        List<PC_AWPushEvent__c> results;
        System.runAs(SPECIALIST_USER) {
            Test.startTest();

            results = PC_ChatStreamController.invokePushTopic(awInputList);

            Test.stopTest();
        }

        // Asserts
        Assert.isNotNull(results, 'Expected the returned list of upserted AW Push Events to not be null, but it was.');
        Assert.isFalse(
            results.isEmpty(),
            'Expected the returned list of upserted AW Push Events to not be empty, but it was.'
        );
    }

    /**
     * @description negative test of invokePushTopic where the input parameters are null
     */
    @IsTest
    private static void unitInvokePushTopicNullInputNegative() {
        // Test data setup

        String expectedExceptionMessage = 'invokePushTopic input list cannot be null.';
        String caughtExceptionMessage = '';
        System.runAs(SPECIALIST_USER) {
            // Actual test
            Test.startTest();
            try {
                PC_ChatStreamController.invokePushTopic(null);
            } catch (PC_CustomException caughtException) {
                caughtExceptionMessage = caughtException.getMessage();
            }

            Test.stopTest();
        }

        // Asserts
        Assert.areEqual(
            expectedExceptionMessage,
            caughtExceptionMessage,
            'Expected a PC_CustomException to be thrown noting that the input list cannot be null, but a different exception was thrown.'
        );
    }

    /**
     * @description positive test of createSkillStatusMap
     */
    @IsTest
    private static void unitCreateSkillStatusMapPositive() {
        setupProviderConnectControllerMocks();

        Map<String, PC_ProviderConnectController.SkillStatus> skillStatusMap;
        System.runAs(SPECIALIST_USER) {
            Test.startTest();

            skillStatusMap = PC_ChatStreamController.createSkillStatusMap();

            Test.stopTest();
        }

        Assert.isFalse(
            skillStatusMap.isEmpty(),
            'Expected the returned skillStatusMap to be populated, but it was not.'
        );
        Assert.isTrue(
            skillStatusMap.containsKey('Cardiology'),
            'Expected the returned skillStatusMap to contain "Cardiology", but it did not.'
        );
    }

    /**
     * @description positive test of getOwnerIdToMostRecentAWPushEventMap
     */
    @IsTest
    private static void unitGetOwnerIdToMostRecentAWPushEventMapPositive() {
        PC_AWPushEvent__c expectedAWPushEvent = new PC_AWPushEvent__c(OwnerId = SPECIALIST_USER.Id);

        PC_AWPushEventRepo mockedAWPushEventRepo = (PC_AWPushEventRepo) new VATEST_StubBuilder(PC_AWPushEventRepo.class)
            .mockingMethodCall('getAWPushEventsByOwners', Set<String>.class)
            .withParameterValues(new Set<String>{ SPECIALIST_USER.Id })
            .returning(new List<PC_AWPushEvent__c>{ expectedAWPushEvent })
            .defineStub();

        PC_ChatStreamController.awPushEventRepo = mockedAWPushEventRepo;

        Map<String, PC_AWPushEvent__c> result;
        System.runAs(SPECIALIST_USER) {
            Test.startTest();

            result = PC_ChatStreamController.getOwnerIdToMostRecentAWPushEventMap(
                new Set<String>{ SPECIALIST_USER.Id }
            );

            Test.stopTest();
        }
        Assert.isTrue(
            result.containsKey(expectedAWPushEvent.OwnerId),
            'Expected the returned map to contain the AW Push Event\'s OwnerId, but it did not.'
        );
    }

    /**
     * @description negative test of getOwnerIdToMostRecentAWPushEventMap that should throw a query expection
     */
    @IsTest
    private static void unitGetOwnerIdToMostRecentAWPushEventMapNegative() {
        String queryExceptionMessage = 'Query Exception message';

        PC_AWPushEventRepo mockedAWPushEventRepo = (PC_AWPushEventRepo) new VATEST_StubBuilder(PC_AWPushEventRepo.class)
            .mockingMethodCall('getAWPushEventsByOwners', Set<String>.class)
            .withParameterValues(new Set<String>{ SPECIALIST_USER.Id })
            .throwingException(new QueryException(queryExceptionMessage))
            .defineStub();

        PC_ChatStreamController.awPushEventRepo = mockedAWPushEventRepo;

        String caughtExceptionMessage = '';
        System.runAs(SPECIALIST_USER) {
            Test.startTest();

            try {
                PC_ChatStreamController.getOwnerIdToMostRecentAWPushEventMap(new Set<String>{ SPECIALIST_USER.Id });
            } catch (PC_CustomException caughtException) {
                caughtExceptionMessage = caughtException.getMessage();
            }

            Test.stopTest();
        }

        Assert.areEqual(
            queryExceptionMessage,
            caughtExceptionMessage,
            'Expected the getOwnerIdToMostRecentAWPushEventMap to throw and catch a QueryException and then re-throw it as a PC_CustomException, but it did not.'
        );
    }

    /**
     * @description positive test of getSfIdToUserMap
     */
    @IsTest
    private static void unitGetSfIdToUserMapPositive() {
        // Test data setup
        VCR_UserRepo mockedUserRepo = (VCR_UserRepo) new VATEST_StubBuilder(VCR_UserRepo.class)
            .mockingMethodCall('fetchUsersByIds', Set<String>.class)
            .withParameterValues(new Set<String>{ SPECIALIST_USER.Id })
            .returning(new List<User>{ SPECIALIST_USER })
            .defineStub();

        PC_ChatStreamController.userRepo = mockedUserRepo;

        // Actual test
        Map<Id, User> result;
        System.runAs(SPECIALIST_USER) {
            Test.startTest();

            result = PC_ChatStreamController.getSfIdToUserMap(new Set<String>{ SPECIALIST_USER.Id });

            Test.stopTest();
        }

        // Asserts
        Assert.isTrue(
            result.containsKey(SPECIALIST_USER.Id),
            'Expected the returned map to contain the Specialist User\'s Id, but it did not.'
        );
    }

    /**
     * @description negative test of getSfIdToUserMap that should throw and catch a QueryException and then rethrow it as a PC_CustomException
     */
    @IsTest
    private static void unitGetSfIdToUserMapNegative() {
        // Test data setup
        String queryExceptionMessage = 'Query Exception Message';

        VCR_UserRepo mockedUserRepo = (VCR_UserRepo) new VATEST_StubBuilder(VCR_UserRepo.class)
            .mockingMethodCall('fetchUsersByIds', Set<String>.class)
            .withParameterValues(new Set<String>{ SPECIALIST_USER.Id })
            .throwingException(new QueryException(queryExceptionMessage))
            .defineStub();

        PC_ChatStreamController.userRepo = mockedUserRepo;

        // Actual test
        String caughtExceptionMessage = '';
        System.runAs(SPECIALIST_USER) {
            Test.startTest();

            try {
                PC_ChatStreamController.getSfIdToUserMap(new Set<String>{ SPECIALIST_USER.Id });
            } catch (PC_CustomException caughtException) {
                caughtExceptionMessage = caughtException.getMessage();
            }

            Test.stopTest();
        }

        // Asserts
        Assert.areEqual(
            queryExceptionMessage,
            caughtExceptionMessage,
            'Expected the getSfIdToUserMap method to throw a Query Exception, but it did not.'
        );
    }

    /**
     * @description positive test of createSuperScreenPTs that should return the pcSuperScreen push topic
     */
    @IsTest
    private static void unitCreateSuperScreenPTsPositive() {
        // Test data setup
        PushTopic expectedPushTopic = new PushTopic(
            Name = PC_ChatStreamController.PC_SUPER_SCREEN_PUSH_TOPIC_NAME,
            ApiVersion = PC_ChatStreamController.PC_SUPER_SCREEN_PUSH_TOPIC_API_VERSION,
            NotifyForOperationUndelete = false,
            NotifyForOperationDelete = false,
            NotifyForOperationCreate = true,
            NotifyForOperationUpdate = true,
            NotifyForFields = PC_ChatStreamController.PC_SUPER_SCREEN_PUSH_TOPIC_NOTIFY_TYPE,
            Query = PC_ChatStreamController.PC_SUPER_SCREEN_PUSH_TOPIC_QUERY
        );

        VCR_PushTopicRepo mockedPushTopicRepo = (VCR_PushTopicRepo) new VATEST_StubBuilder(VCR_PushTopicRepo.class)
            .mockingMethodCall('getMostRecentPushTopicByName', String.class)
            .withParameterValues(PC_ChatStreamController.PC_SUPER_SCREEN_PUSH_TOPIC_NAME)
            .returning(expectedPushTopic)
            .mockingMethodCall('doCreate', SObject.class)
            .withParameterValues(expectedPushTopic)
            .returning()
            .defineStub();

        PC_ChatStreamController.pushTopicRepo = mockedPushTopicRepo;

        PushTopic result;
        System.runAs(FLP_USER) {
            // Actual test
            Test.startTest();

            result = PC_ChatStreamController.createSuperScreenPTs();

            Test.stopTest();
        }

        // Asserts
        Assert.areEqual(
            expectedPushTopic.Name,
            result.Name,
            'Expected the name of the push topic returned to be equal to pcSuperScreen, but observed a different pushTopic returned'
        );
    }

    /**
     * @description negative test of createSuperScreenPTs that should throw and catch a Query exception that is then re-thrown as a PC_CustomException
     */
    @IsTest
    private static void unitCreateSuperScreenPTsNegative() {
        // Test data setup
        String queryExceptionMessage = 'Query Exception message';

        VCR_PushTopicRepo mockedPushTopicRepo = (VCR_PushTopicRepo) new VATEST_StubBuilder(VCR_PushTopicRepo.class)
            .mockingMethodCall('getMostRecentPushTopicByName', String.class)
            .withParameterValues(PC_ChatStreamController.PC_SUPER_SCREEN_PUSH_TOPIC_NAME)
            .throwingException(new QueryException(queryExceptionMessage))
            .defineStub();

        PC_ChatStreamController.pushTopicRepo = mockedPushTopicRepo;

        String caughtExceptionMessage = '';
        System.runAs(FLP_USER) {
            // Actual test
            Test.startTest();
            try {
                PC_ChatStreamController.createSuperScreenPTs();
            } catch (PC_CustomException caughtException) {
                caughtExceptionMessage = caughtException.getMessage();
            }

            Test.stopTest();
        }

        // Asserts
        Assert.areEqual(
            queryExceptionMessage,
            caughtExceptionMessage,
            'Expected a query exception to be thrown by getMostRecentPushTopicByName, but a different exception was thrown.'
        );
    }
}
