/**
 * @author Booz Allen Hamilton
 * @since 5/26/24
 * @description Unit tests for VCC_AppointmentUtilQueueable
 *
 * @see VCC_AppointmentUtilQueueable
 */
@IsTest
private class VCC_AppointmentUtilQueueableTest {
    private static User MOLLY_MIN_ACCESS;
    private static User VCC_APPT_SYS_ADMIN;
    private static User DR_HARRY_POTTER_USER;
    private static VCC_AppointmentUtilQueueable systemUnderTest = new VCC_AppointmentUtilQueueable();
    private static VCC_Appointment_Utilization_Config__mdt TEST_CONFIG = VCC_Appointment_Utilization_Config__mdt.getAll()
        .values()[0];

    static {
        MOLLY_MIN_ACCESS = VATEST_UserFactory.createMinAccessPersonaUser(false);
        MOLLY_MIN_ACCESS.TimeZoneSidKey = 'GMT';
        VCC_APPT_SYS_ADMIN = new VATEST_UserBuilder()
            .withUserProfile('System Administrator')
            .withStandardData()
            .setFields(User.TimeZoneSidKey, UserInfo.getTimeZone().getId())
            .withPermissionSet('VAHC_View_Appointment_Utilization')
            .build(true);
        DR_HARRY_POTTER_USER = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .setFields(User.TimeZoneSidKey, UserInfo.getTimeZone().getId())
            .setFields(User.FirstName, 'Harry')
            .setFields(User.FirstName, 'Potter')
            .build(false);
    }

    /**
     * @description Unit test that you can create an instance of Queueable with default (no-arg) ctor
     */
    @IsTest
    static void unitItConstructsDefaultCtorPositive() {
        Test.startTest();
        VCC_AppointmentUtilQueueable apptUtilQueueable;
        System.runAs(VCC_APPT_SYS_ADMIN) {
            systemUnderTest = new VCC_AppointmentUtilQueueable();
            Assert.isNotNull(
                systemUnderTest,
                'Expected a valid instance of VCC_AppointmentUtilQueueable for calculating Utilization for all VISNs & Providers'
            );
        }
        Test.stopTest();
    }

    /**
     * @description Unit test that you can create an instance of Queueable with a single VISN Name
     */
    @IsTest
    static void unitItConstructsWithVISNNamePositive() {
        String visnName = 'Test Visn A 1';
        Date startDate = Date.today().addDays(-31);
        Date endDate = Date.today();
        VCC_AppointmentUtilQueueable.AppointmentUtilizationData inputData = new VCC_AppointmentUtilQueueable.AppointmentUtilizationData(
            new List<String>{ visnName },
            startDate,
            endDate
        );
        createMockedService(inputData);

        Test.startTest();
        System.runAs(VCC_APPT_SYS_ADMIN) {
            systemUnderTest = new VCC_AppointmentUtilQueueable(visnName);
            Assert.isNotNull(systemUnderTest, 'Expected a valid instance of Queueable to be instantiated');
            Assert.isTrue(
                systemUnderTest.passthrough instanceof VCC_AppointmentUtilQueueableService,
                'Expected passthrough variable to be created and initialized to instance of service class'
            );
        }
        Test.stopTest();
    }
    /**
     * @description Unit test that you can create an instance of Queueable with a set of VISN Names
     */
    @IsTest
    static void unitItConstructsWithVISNNamesPositive() {
        List<String> visnNames = new List<String>{ 'Test Visn A 1', 'Test Visn A 2' };
        Date startDate = Date.today().addDays(-31);
        Date endDate = Date.today();
        VCC_AppointmentUtilQueueable.AppointmentUtilizationData inputData = new VCC_AppointmentUtilQueueable.AppointmentUtilizationData(
            visnNames,
            startDate,
            endDate
        );
        createMockedService(inputData);
        Test.startTest();
        System.runAs(VCC_APPT_SYS_ADMIN) {
            systemUnderTest = new VCC_AppointmentUtilQueueable(visnNames);
            Assert.isNotNull(systemUnderTest, 'Expected a valid instance of Queueable to be instantiated');
            Assert.isTrue(
                systemUnderTest.passthrough instanceof VCC_AppointmentUtilQueueableService,
                'Expected passthrough variable to be created and initialized to instance of service class'
            );
        }
        Test.stopTest();
    }

    /**
     * @description Unit test that you can create an instance of Queueable with a set of VISN Ids
     */
    @IsTest
    static void unitItConstructsWithVISNIdsPositive() {
        List<ServiceTerritoryMember> members = createTestData();
        ServiceTerritory visn = members[0].ServiceTerritory;

        Date startDate = Date.today().addDays(-31);
        Date endDate = Date.today();
        VCC_AppointmentUtilQueueable.AppointmentUtilizationData inputData = new VCC_AppointmentUtilQueueable.AppointmentUtilizationData(
            new List<ServiceTerritory>{ visn },
            startDate,
            endDate
        );
        createMockedService(inputData);

        Test.startTest();
        System.runAs(VCC_APPT_SYS_ADMIN) {
            systemUnderTest = new VCC_AppointmentUtilQueueable(visn);
            Assert.isNotNull(
                systemUnderTest,
                'Expected a valid instance of Queueable to be instantiated for List of Ids and default Dates'
            );
        }
        Test.stopTest();
    }

    /**
     * @description Unit test that you can create an instance of Queueable with no VISNs but Date values
     */
    @IsTest
    static void unitItConstructsWithDatesForAllVISNsPositive() {
        Date startDate = Date.today().addDays(-31);
        Date endDate = Date.today();
        VCC_AppointmentUtilQueueable.AppointmentUtilizationData inputData = new VCC_AppointmentUtilQueueable.AppointmentUtilizationData(
            new List<Id>(),
            startDate,
            endDate
        );
        VCC_AppointmentUtilQueueableService mockedService = createMockedService(inputData);

        Test.startTest();
        System.runAs(VCC_APPT_SYS_ADMIN) {
            systemUnderTest = new VCC_AppointmentUtilQueueable(startDate, endDate);
            Assert.isNotNull(
                systemUnderTest,
                'Expected a valid instance of Queueable to be instantiated for given Dates and defaulting to All VISNs'
            );
            Assert.areEqual(
                VCC_AppointmentUtilQueueable.memoizedService,
                mockedService,
                'Expected memoizedService to be initialized to instance of service class'
            );
        }
        Test.stopTest();
    }

    /**
     * @description Unit test that you can pass data through to next iteration of job
     */
    @IsTest
    static void unitExecuteWithPassthroughData() {
        Date startDate = Date.today().addDays(-31);
        Date endDate = Date.today();
        VCC_AppointmentUtilQueueable.AppointmentUtilizationData inputData = new VCC_AppointmentUtilQueueable.AppointmentUtilizationData(
            new List<Id>(),
            startDate,
            endDate
        );
        createMockedService(inputData);
        VCC_AppointmentUtilQueueableService passthroughMockedService;

        Test.startTest();
        System.runAs(VCC_APPT_SYS_ADMIN) {
            systemUnderTest = new VCC_AppointmentUtilQueueable(startDate, endDate);
            passthroughMockedService = createMockedService();
            // change mocked service to ensure we are executing the correct path
            systemUnderTest.passthrough = passthroughMockedService;
            systemUnderTest.execute();
            Assert.areEqual(
                VCC_AppointmentUtilQueueable.memoizedService,
                passthroughMockedService,
                'Expected service instance to be updated to instance from last iteration.'
            );
        }
        Test.stopTest();
    }

    /**
     * @description Unit test that you can create an instance of Queueable with no VISNs but Date values
     */
    @IsTest
    static void unitHasExitCriteriaBeenMetPositive() {
        Date startDate = Date.today().addDays(-31);
        Date endDate = Date.today();
        VCC_AppointmentUtilQueueable.AppointmentUtilizationData inputData = new VCC_AppointmentUtilQueueable.AppointmentUtilizationData(
            new List<Id>(),
            startDate,
            endDate
        );
        VCC_AppointmentUtilQueueableService mockedService = createMockedService(inputData);

        Test.startTest();
        System.runAs(VCC_APPT_SYS_ADMIN) {
            systemUnderTest = new VCC_AppointmentUtilQueueable(startDate, endDate);
            systemUnderTest.execute();
            Assert.areEqual(
                true,
                systemUnderTest.hasExitCriteriaBeenMet(),
                'Expected hasExitCriteriaBeenMet to return true.'
            );
        }
        Test.stopTest();
    }

    /**
     * @description Unit tests that when execute() fails with an exception, it is logged/handled properly.
     */
    @IsTest
    static void unitExecuteThrowExceptionNegative() {
        Date startDate = Date.today().addDays(-31);
        Date endDate = Date.today();
        VCC_AppointmentUtilQueueable.AppointmentUtilizationData inputData = new VCC_AppointmentUtilQueueable.AppointmentUtilizationData(
            new List<Id>(),
            startDate,
            endDate
        );

        VCC_AppointmentUtilQueueableService mockedService = createMockedServiceToThrowException(inputData);

        Test.startTest();
        System.runAs(VCC_APPT_SYS_ADMIN) {
            systemUnderTest = new VCC_AppointmentUtilQueueable();
            try {
                systemUnderTest.execute();
            } catch (Exception unexpectedExc) {
                Assert.isFalse(
                    true,
                    'Did not expect an Exception to be thrown - it should have been handled in execute method.'
                );
            }
        }
        Test.stopTest();
    }
    private static List<ServiceTerritoryMember> createTestData() {
        List<ServiceTerritoryMember> members = new List<ServiceTerritoryMember>();
        System.runAs(VCC_APPT_SYS_ADMIN) {
            ServiceResource provider = (ServiceResource) VATEST_SObjectFactory.createSObject(
                new ServiceResource(
                    Name = 'Dr Harry Potter',
                    RelatedRecordId = DR_HARRY_POTTER_USER.Id,
                    IsActive = true
                ),
                false
            );

            OperatingHours opHours = (OperatingHours) VATEST_SObjectFactory.createSObject(
                new OperatingHours(Name = 'VISN Operating Hours'),
                false
            );

            ServiceTerritory visn = (ServiceTerritory) VATEST_SObjectFactory.createSObject(
                new ServiceTerritory(Name = 'Test VISN A', IsActive = true, OperatingHoursId = opHours.Id),
                false
            );

            ServiceTerritoryMember member = (ServiceTerritoryMember) VATEST_SObjectFactory.createSObject(
                new ServiceTerritoryMember(
                    EffectiveStartDate = Date.today(),
                    EffectiveEndDate = Date.today().addYears(1),
                    ServiceTerritoryId = visn.Id,
                    ServiceResourceId = provider.Id,
                    ServiceTerritory = visn
                ),
                false
            );
            members.add(member);
        }
        return members;
    }

    private static VCC_AppointmentUtilQueueableService createMockedService() {
        VCC_AppointmentUtilQueueableService mockedService = (VCC_AppointmentUtilQueueableService) new VATEST_StubBuilder(
                VCC_AppointmentUtilQueueableService.class
            )
            .mockingMethodCall('execute')
            .withParameterTypes()
            .returning()
            .mockingMethodCall('hasExitCriteriaBeenMet')
            .withParameterTypes()
            .returning(true)
            .mockingMethodCall('setConfig')
            .withParameterTypes(VCC_Appointment_Utilization_Config__mdt.class)
            .withParameterValues(TEST_CONFIG)
            .returning()
            .defineStub();
        VCC_AppointmentUtilQueueable.memoizedService = mockedService;
        return mockedService;
    }

    private static VCC_AppointmentUtilQueueableService createMockedService(
        VCC_AppointmentUtilQueueable.AppointmentUtilizationData inputData
    ) {
        VCC_AppointmentUtilQueueableService mockedService = (VCC_AppointmentUtilQueueableService) new VATEST_StubBuilder(
                VCC_AppointmentUtilQueueableService.class
            )
            .mockingMethodCall('fetchData')
            .withParameterTypes(VCC_AppointmentUtilQueueable.AppointmentUtilizationData.class)
            .withParameterValues(inputData)
            .returning()
            .mockingMethodCall('execute')
            .withParameterTypes()
            .returning()
            .mockingMethodCall('hasExitCriteriaBeenMet')
            .withParameterTypes()
            .returning(true)
            .mockingMethodCall('setConfig')
            .withParameterTypes(VCC_Appointment_Utilization_Config__mdt.class)
            .withParameterValues(TEST_CONFIG)
            .returning()
            .defineStub();
        VCC_AppointmentUtilQueueable.memoizedService = mockedService;
        return mockedService;
    }

    private static VCC_AppointmentUtilQueueableService createMockedServiceToThrowException(
        VCC_AppointmentUtilQueueable.AppointmentUtilizationData inputData
    ) {
        VCC_AppointmentUtilQueueableService mockedService = (VCC_AppointmentUtilQueueableService) new VATEST_StubBuilder(
                VCC_AppointmentUtilQueueableService.class
            )
            .mockingMethodCall('setConfig')
            .withParameterTypes(VCC_Appointment_Utilization_Config__mdt.class)
            .withParameterValues(TEST_CONFIG)
            .returning()
            .mockingMethodCall('fetchData')
            .withParameterTypes(VCC_AppointmentUtilQueueable.AppointmentUtilizationData.class)
            .withParameterValues(inputData)
            .returning()
            .mockingMethodCall('execute')
            .withParameterTypes()
            .throwingException()
            .defineStub();
        VCC_AppointmentUtilQueueable.memoizedService = mockedService;
        return mockedService;
    }
}
