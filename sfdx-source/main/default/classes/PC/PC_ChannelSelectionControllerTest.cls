/**
 * @description Test class for PC_ChannelSelectionController
 * @author      Booz Allen Hamilton
 * @since       2024
 * @see         PC_ChannelSelectionController
 **/
@IsTest
private class PC_ChannelSelectionControllerTest {
    private final static User SPECIALIST_USER;
    static {
        //mixed DML error workaround
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            SPECIALIST_USER = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet('PrC_Specialist_Users')
                .build(true);
        }
    }

    /**
     * @description positive test of getChannelAvailability that ensures all channel skills are returned and set to true (aka specialist is available for all channel types)
     */
    @IsTest
    static void unitGetChannelAvailabilityTestPositive() {
        User specialist = SPECIALIST_USER;

        List<String> lsChannelNames = new List<String>{ 'PC_Phone', 'PC_Teams', 'PC_Chat' };

        PC_ServiceResourceRepo mockServiceRepo = (PC_ServiceResourceRepo) new VATEST_StubBuilder(
                PC_ServiceResourceRepo.class
            )
            .mockingMethodCall('getServiceResourcesRunningUser')
            .withParameterTypes()
            .returning(new List<ServiceResource>{ new ServiceResource() })
            .defineStub();

        PC_ServiceResourceSkillRepo mockServiceResourceSkillRepo = (PC_ServiceResourceSkillRepo) new VATEST_StubBuilder(
                PC_ServiceResourceSkillRepo.class
            )
            .mockingMethodCall('getServiceResourceSkillsExcluding')
            .withParameterTypes(List<String>.class)
            .withParameterValues(lsChannelNames)
            .returning(new List<ServiceResourceSkill>{ new ServiceResourceSkill() })
            .mockingMethodCall('getServiceResourceSkillsIncluding')
            .withParameterTypes(List<String>.class)
            .withParameterValues(lsChannelNames)
            .returning(
                new List<ServiceResourceSkill>{
                    new ServiceResourceSkill(Skill = new Skill(DeveloperName = lsChannelNames[0])),
                    new ServiceResourceSkill(Skill = new Skill(DeveloperName = lsChannelNames[1])),
                    new ServiceResourceSkill(Skill = new Skill(DeveloperName = lsChannelNames[2]))
                }
            )
            .defineStub();

        PC_ChannelSelectionController.serviceResourceSkillRepo = mockServiceResourceSkillRepo;
        PC_ChannelSelectionController.serviceResourceRepo = mockServiceRepo;

        PC_ChannelSelectionController.AvailableChannels channels;
        System.runAs(specialist) {
            channels = PC_ChannelSelectionController.getChannelAvailability();
        }

        Boolean checkAvailable = channels.chat == true && channels.teams == true && channels.phone == true;
        Assert.isTrue(checkAvailable, 'Expected all channels to be marked as available.'); //all channels are available be default
    }

    /**
     * @description negative test of getChannelAvailability that ensures a custom exception is thrown if the user does not have a related service resource or channel skills
     */
    @IsTest
    static void unitGetChannelAvailabilityCustomExceptionTestNegative() {
        User specialist = SPECIALIST_USER;

        List<String> lsChannelNames = new List<String>{ 'PC_Phone', 'PC_Teams', 'PC_Chat' };

        PC_ServiceResourceRepo mockServiceRepo = (PC_ServiceResourceRepo) new VATEST_StubBuilder(
                PC_ServiceResourceRepo.class
            )
            .mockingMethodCall('getServiceResourcesRunningUser')
            .withParameterTypes()
            .returning(new List<ServiceResource>())
            .defineStub();

        PC_ServiceResourceSkillRepo mockServiceResourceSkillRepo = (PC_ServiceResourceSkillRepo) new VATEST_StubBuilder(
                PC_ServiceResourceSkillRepo.class
            )
            .mockingMethodCall('getServiceResourceSkillsExcluding')
            .withParameterTypes(List<String>.class)
            .withParameterValues(lsChannelNames)
            .returning(new List<ServiceResourceSkill>())
            .defineStub();

        PC_ChannelSelectionController.serviceResourceSkillRepo = mockServiceResourceSkillRepo;
        PC_ChannelSelectionController.serviceResourceRepo = mockServiceRepo;

        Boolean hasException = false;
        System.runAs(specialist) {
            try {
                PC_ChannelSelectionController.getChannelAvailability();
            } catch (AuraHandledException auraException) {
                hasException = true;
            }
        }

        Assert.isTrue(
            hasException,
            'Expected a custom exception due to the user not having a related service resource or channel skills.'
        );
    }

    /**
     * @description negative test of getChannelAvailability that ensures a query exception is thrown by the service resource repo call
     */
    @IsTest
    static void unitGetChannelAvailabilityQueryExceptionTestNegative() {
        User specialist = SPECIALIST_USER;

        List<String> lsChannelNames = new List<String>{ 'PC_Phone', 'PC_Teams', 'PC_Chat' };

        PC_ServiceResourceRepo mockServiceRepo = (PC_ServiceResourceRepo) new VATEST_StubBuilder(
                PC_ServiceResourceRepo.class
            )
            .mockingMethodCall('getServiceResourcesRunningUser')
            .withParameterTypes()
            .throwingException(new QueryException())
            .defineStub();

        PC_ServiceResourceSkillRepo mockServiceResourceSkillRepo = (PC_ServiceResourceSkillRepo) new VATEST_StubBuilder(
                PC_ServiceResourceSkillRepo.class
            )
            .mockingMethodCall('getServiceResourceSkillsExcluding')
            .withParameterTypes(List<String>.class)
            .withParameterValues(lsChannelNames)
            .returning(new List<ServiceResourceSkill>())
            .defineStub();

        PC_ChannelSelectionController.serviceResourceSkillRepo = mockServiceResourceSkillRepo;
        PC_ChannelSelectionController.serviceResourceRepo = mockServiceRepo;

        Boolean hasException = false;
        System.runAs(specialist) {
            try {
                PC_ChannelSelectionController.getChannelAvailability();
            } catch (AuraHandledException auraException) {
                hasException = true;
            }
        }

        Assert.isTrue(
            hasException,
            'Expected a query exception due to the user not having a related service resource or channel skills.'
        );
    }

    /**
     * @description negative test of getChannelAvailability that ensures a generic exception is thrown by the service resource repo call
     */
    @IsTest
    static void unitGetChannelAvailabilityGenericExceptionTestNegative() {
        User specialist = SPECIALIST_USER;

        List<String> lsChannelNames = new List<String>{ 'PC_Phone', 'PC_Teams', 'PC_Chat' };

        PC_ServiceResourceRepo mockServiceRepo = (PC_ServiceResourceRepo) new VATEST_StubBuilder(
                PC_ServiceResourceRepo.class
            )
            .mockingMethodCall('getServiceResourcesRunningUser')
            .withParameterTypes()
            .throwingException(new AuraHandledException('Generic Exception'))
            .defineStub();

        PC_ServiceResourceSkillRepo mockServiceResourceSkillRepo = (PC_ServiceResourceSkillRepo) new VATEST_StubBuilder(
                PC_ServiceResourceSkillRepo.class
            )
            .mockingMethodCall('getServiceResourceSkillsExcluding')
            .withParameterTypes(List<String>.class)
            .withParameterValues(lsChannelNames)
            .returning(new List<ServiceResourceSkill>())
            .defineStub();

        PC_ChannelSelectionController.serviceResourceSkillRepo = mockServiceResourceSkillRepo;
        PC_ChannelSelectionController.serviceResourceRepo = mockServiceRepo;

        Boolean hasException = false;
        System.runAs(specialist) {
            try {
                PC_ChannelSelectionController.getChannelAvailability();
            } catch (AuraHandledException auraException) {
                hasException = true;
            }
        }

        Assert.isTrue(
            hasException,
            'Expected a generic exception due to the user not having a related service resource or channel skills.'
        );
    }

    /**
     * @description Method to positively test setChannelAvailability method via setting the channel availability for Chat off and on (while offline)
     **/
    @IsTest
    static void unitSetChannelAvailabilityWhileOfflineTestPositive() {
        User specialist = SPECIALIST_USER;

        Id testSkillId = VATEST_IdFactory.get(Type.forName('Skill'));
        Id testServiceResourceId = VATEST_IdFactory.get(Type.forName('ServiceResource'));
        Id testServiceResourceSkillId = VATEST_IdFactory.get(Type.forName('ServiceResourceSkill'));

        PC_UserServicePresenceRepo mockUserServicePresenceRepo = (PC_UserServicePresenceRepo) new VATEST_StubBuilder(
                PC_UserServicePresenceRepo.class
            )
            .mockingMethodCall('getCurrentUserServicePresenceForRunningUser')
            .withParameterTypes()
            .returning(new List<UserServicePresence>())
            .defineStub();

        VCR_SkillRepo mockSkillRepo = (VCR_SkillRepo) new VATEST_StubBuilder(VCR_SkillRepo.class)
            .mockingMethodCall('getSkillByLabel', String.class)
            .withParameterValues('Chat')
            .returning(new Skill(Id = testSkillId))
            .defineStub();

        PC_ServiceResourceRepo mockServiceRepo = (PC_ServiceResourceRepo) new VATEST_StubBuilder(
                PC_ServiceResourceRepo.class
            )
            .mockingMethodCall('getServiceResourcesRunningUser')
            .withParameterTypes()
            .returning(new List<ServiceResource>{ new ServiceResource(Id = testServiceResourceId) })
            .defineStub();

        PC_ServiceResourceSkillRepo mockServiceResourceSkillRepo = (PC_ServiceResourceSkillRepo) new VATEST_StubBuilder(
                PC_ServiceResourceSkillRepo.class
            )
            .mockingMethodCall('getServiceResourceSkillsByLabel')
            .withParameterTypes(String.class)
            .withParameterValues('Chat')
            .returning(new List<ServiceResourceSkill>{ new ServiceResourceSkill(Id = testServiceResourceSkillId) })
            .defineStub();

        PC_ServiceResourceSkillRepo mockServiceResourceSkillRepoUnsafe = (PC_ServiceResourceSkillRepo) new VATEST_StubBuilder(
                PC_ServiceResourceSkillRepo.class
            )
            .mockingMethodCall('performDeleteUnsafe', List<ServiceResourceSkill>.class)
            .withParameterValues(
                new List<ServiceResourceSkill>{ new ServiceResourceSkill(Id = testServiceResourceSkillId) }
            )
            .returning()
            .mockingMethodCall('performCreateUnsafe', List<ServiceResourceSkill>.class)
            .withParameterValues(
                new List<ServiceResourceSkill>{
                    new ServiceResourceSkill(
                        SkillId = testSkillId,
                        ServiceResourceId = testServiceResourceId,
                        EffectiveStartDate = Date.today(),
                        SkillLevel = 1
                    )
                }
            )
            .returning()
            .defineStub();

        PC_ChannelSelectionController.userPresenceRepo = mockUserServicePresenceRepo;
        PC_ChannelSelectionController.serviceResourceSkillRepo = mockServiceResourceSkillRepo;
        PC_ChannelSelectionControllerSysHelper.serviceResourceSkillRepo = mockServiceResourceSkillRepoUnsafe;
        PC_ChannelSelectionController.skillRepo = mockSkillRepo;
        PC_ChannelSelectionController.serviceResourceRepo = mockServiceRepo;

        Test.startTest();

        String result;
        System.runAs(specialist) {
            result = PC_ChannelSelectionController.setChannelAvailability('Chat', false);
            Assert.areEqual('success', result, 'Expected a success result');

            result = PC_ChannelSelectionController.setChannelAvailability('Chat', true);
            Assert.areEqual('success', result, 'Expected a success result');
        }

        Test.stopTest();
    }

    /**
     * @description Method to positively test setChannelAvailability method when user is online (indicated by a IsCurrentState = True UserServicePresence related to their user)
     **/
    @IsTest
    static void unitSetChannelAvailabilityWhileOnlineTestPositive() {
        User specialist = SPECIALIST_USER;

        PC_UserServicePresenceRepo mockUserServicePresenceRepo = (PC_UserServicePresenceRepo) new VATEST_StubBuilder(
                PC_UserServicePresenceRepo.class
            )
            .mockingMethodCall('getCurrentUserServicePresenceForRunningUser')
            .withParameterTypes()
            .returning(
                new List<UserServicePresence>{
                    new UserServicePresence(
                        UserId = specialist.Id,
                        ServicePresenceStatus = new ServicePresenceStatus(
                            DeveloperName = 'PC_Available_Provider_Connect'
                        )
                    )
                }
            )
            .defineStub();

        PC_ChannelSelectionController.userPresenceRepo = mockUserServicePresenceRepo;

        Test.startTest();

        String result;
        System.runAs(specialist) {
            result = PC_ChannelSelectionController.setChannelAvailability('Chat', false);
            Assert.areEqual(
                'Please log out of Omni-Channel before changing channel availability.',
                result,
                'Expected result to indicate that the user should log out of Omni-Channel'
            );
        }

        Test.stopTest();
    }

    /**
     * @description Method to negatively test setChannelAvailability method by throwing a DML Exception
     **/
    @IsTest
    static void unitSetChannelAvailabilityDmlExceptionTestNegative() {
        User specialist = SPECIALIST_USER;

        Id testServiceResourceSkillId = VATEST_IdFactory.get(Type.forName('ServiceResourceSkill'));

        PC_UserServicePresenceRepo mockUserServicePresenceRepo = (PC_UserServicePresenceRepo) new VATEST_StubBuilder(
                PC_UserServicePresenceRepo.class
            )
            .mockingMethodCall('getCurrentUserServicePresenceForRunningUser')
            .withParameterTypes()
            .returning(new List<UserServicePresence>())
            .defineStub();

        PC_ServiceResourceSkillRepo mockServiceResourceSkillRepo = (PC_ServiceResourceSkillRepo) new VATEST_StubBuilder(
                PC_ServiceResourceSkillRepo.class
            )
            .mockingMethodCall('getServiceResourceSkillsByLabel')
            .withParameterTypes(String.class)
            .withParameterValues('Chat')
            .returning(new List<ServiceResourceSkill>{ new ServiceResourceSkill(Id = testServiceResourceSkillId) })
            .defineStub();

        PC_ServiceResourceSkillRepo mockServiceResourceSkillRepoUnsafe = (PC_ServiceResourceSkillRepo) new VATEST_StubBuilder(
                PC_ServiceResourceSkillRepo.class
            )
            .mockingMethodCall('performDeleteUnsafe', List<ServiceResourceSkill>.class)
            .withParameterValues(
                new List<ServiceResourceSkill>{ new ServiceResourceSkill(Id = testServiceResourceSkillId) }
            )
            .throwingException(new DmlException('DML Exception Message'))
            .defineStub();

        PC_ChannelSelectionController.userPresenceRepo = mockUserServicePresenceRepo;
        PC_ChannelSelectionController.serviceResourceSkillRepo = mockServiceResourceSkillRepo;
        PC_ChannelSelectionControllerSysHelper.serviceResourceSkillRepo = mockServiceResourceSkillRepoUnsafe;

        Test.startTest();

        String exceptionMessage;
        System.runAs(specialist) {
            try {
                PC_ChannelSelectionController.setChannelAvailability('Chat', false);
            } catch (AuraHandledException caughtException) {
                exceptionMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        Assert.areEqual('DML Exception Message', exceptionMessage, 'Expected to have thrown a DmlException');
    }

    /**
     * @description Method to negatively test setChannelAvailability method by throwing a Query Exception
     **/
    @IsTest
    static void unitSetChannelAvailabilityQueryExceptionTestNegative() {
        User specialist = SPECIALIST_USER;

        PC_UserServicePresenceRepo mockUserServicePresenceRepo = (PC_UserServicePresenceRepo) new VATEST_StubBuilder(
                PC_UserServicePresenceRepo.class
            )
            .mockingMethodCall('getCurrentUserServicePresenceForRunningUser')
            .withParameterTypes()
            .throwingException(new QueryException('Query Exception Message'))
            .defineStub();

        PC_ChannelSelectionController.userPresenceRepo = mockUserServicePresenceRepo;

        Test.startTest();

        String exceptionMessage;
        System.runAs(specialist) {
            try {
                PC_ChannelSelectionController.setChannelAvailability('Chat', false);
            } catch (AuraHandledException caughtException) {
                exceptionMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        Assert.areEqual('Query Exception Message', exceptionMessage, 'Expected to have thrown a QueryException');
    }

    /**
     * @description Method to negatively test setChannelAvailability method by throwing a generic Exception
     **/
    @IsTest
    static void unitSetChannelAvailabilityGenericExceptionTestNegative() {
        User specialist = SPECIALIST_USER;

        PC_UserServicePresenceRepo mockUserServicePresenceRepo = (PC_UserServicePresenceRepo) new VATEST_StubBuilder(
                PC_UserServicePresenceRepo.class
            )
            .mockingMethodCall('getCurrentUserServicePresenceForRunningUser')
            .withParameterTypes()
            .throwingException(new PC_CustomException('Generic Exception Message'))
            .defineStub();

        PC_ChannelSelectionController.userPresenceRepo = mockUserServicePresenceRepo;

        Test.startTest();

        String exceptionMessage;
        System.runAs(specialist) {
            try {
                PC_ChannelSelectionController.setChannelAvailability('Chat', false);
            } catch (AuraHandledException caughtException) {
                exceptionMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        Assert.areEqual('Generic Exception Message', exceptionMessage, 'Expected to have thrown an Exception');
    }
}
