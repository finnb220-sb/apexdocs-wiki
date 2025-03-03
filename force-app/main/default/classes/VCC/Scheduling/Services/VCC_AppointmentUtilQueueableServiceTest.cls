/**
 * @author Booz Allen Hamilton
 * @since 5/26/24
 * @description Unit tess for VCC_AppointmentUtilQueueableService
 * @see VCC_AppointmentUtilQueueableService
 */
@IsTest
private class VCC_AppointmentUtilQueueableServiceTest {
    private static final User MOLLY_MIN_ACCESS;
    private static final User VCC_APPT_ADMIN;
    private static final User DR_HARRY_POTTER_USER;
    private static final User DR_HERMIONE_GRAINGER_USER;
    private static final User DR_RONALD_WEASLEY_USER;
    private static VCC_AppointmentUtilQueueableService systemUnderTest;
    private static final VCC_Appointment_Utilization_Config__mdt TEST_CONFIG;
    // Repeating Rule pattern for 180 recurring daily shift. @see VCC_RepeatingRule for details/context.
    private static final String RRULE_FOR_NEXT_180_DAYS = 'RRULE:FREQ=DAILY;INTERVAL=1;COUNT=180;';

    static {
        MOLLY_MIN_ACCESS = VATEST_UserFactory.createMinAccessPersonaUser(false);
        // System Admin profile is required to create Appointment Utilization records
        VCC_APPT_ADMIN = new VATEST_UserBuilder()
            .withUserProfile('System Administrator')
            .withPermissionSet('VAHC_View_Appointment_Utilization')
            .withPermissionSet('VCC_VCV_Appointment_Viewer_Administrator')
            .withStandardData()
            .setFields(User.TimeZoneSidKey, UserInfo.getTimeZone().getId())
            .build(true);
        DR_HARRY_POTTER_USER = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .setFields(User.TimeZoneSidKey, UserInfo.getTimeZone().getId())
            .setFields(User.FirstName, 'Harry')
            .setFields(User.FirstName, 'Potter')
            .withPermissionSet('VCC_VCV_Appointment_Viewer_Administrator')
            .build(true);
        DR_HERMIONE_GRAINGER_USER = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .setFields(User.TimeZoneSidKey, UserInfo.getTimeZone().getId())
            .setFields(User.FirstName, 'Hermione')
            .setFields(User.FirstName, 'Grainger')
            .withPermissionSet('VCC_VCV_Appointment_Viewer_Administrator')
            .build(true);
        DR_RONALD_WEASLEY_USER = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .setFields(User.TimeZoneSidKey, UserInfo.getTimeZone().getID())
            .setFields(User.FirstName, 'Ronald')
            .setFields(User.FirstName, 'Weasley')
            .withPermissionSet('VCC_VCV_Appointment_Viewer_Administrator')
            .build(true);
        TEST_CONFIG = new VCC_Appointment_Utilization_Config__mdt(
            Max_Number_of_Days_to_Process__c = 31,
            Queueable_Batch_Size__c = 15
        );
    }
    private static List<ServiceTerritoryMember> createTestData() {
        return createTestData(true, UserInfo.getTimeZone());
    }

    private static List<ServiceTerritoryMember> createTestData(TimeZone territoryTimeZone) {
        return createTestData(true, territoryTimeZone);
    }

    /**
     * @description Create test data for use in our unit tests. We are creating the following set of data
     * ServiceResource - Health care providers (Medical Doctors, Nurses, etc)
     * ServiceTerritory - Within VA context, these are referred to as VISNs and are health facilities
     * ServiceTerritoryMember - Junction object between a ServiceResource (Provider) & a ServiceTerritory (VISN)
     *
     * @param blnCreateMultipleMemberPerVisn `Boolean` If true, create more than 1 ServiceTerritoryMember
     *  for each VISN, false means we only create a single junction object - useful for creating mocks
     * @param territoryTimeZone `TimeZone` TimeZone to assign to Territories - needs to be different than current user.
     * @return `List<ServiceTerritoryMember>` List of ServiceTerritoryMembers, 1 for each Provider-VISN combination
     *  created in test method
     */
    private static List<ServiceTerritoryMember> createTestData(
        Boolean blnCreateMultipleMemberPerVisn,
        TimeZone territoryTimeZone
    ) {
        List<ServiceTerritoryMember> members = new List<ServiceTerritoryMember>();
        System.runAs(VCC_APPT_ADMIN) {
            // Health Providers that work at various VISNs (VA Health Facilities)
            List<ServiceResource> providers = new List<ServiceResource>();
            providers.add(
                (ServiceResource) VATEST_SObjectFactory.createSObject(
                    new ServiceResource(
                        Name = 'Dr Harry Potter',
                        RelatedRecordId = DR_HARRY_POTTER_USER.Id,
                        IsActive = true
                    ),
                    false
                )
            );
            providers.add(
                (ServiceResource) VATEST_SObjectFactory.createSObject(
                    new ServiceResource(
                        Name = 'Dr Hermione Grainger',
                        RelatedRecordId = DR_HERMIONE_GRAINGER_USER.Id,
                        IsActive = true
                    ),
                    false
                )
            );
            providers.add(
                (ServiceResource) VATEST_SObjectFactory.createSObject(
                    new ServiceResource(
                        Name = 'Dr Ronald Weasley',
                        RelatedRecordId = DR_RONALD_WEASLEY_USER.Id,
                        IsActive = true
                    ),
                    false
                )
            );
            for (ServiceResource provider : providers) {
                provider.Id = null;
            }
            insert providers;

            OperatingHours opHours = (OperatingHours) VATEST_SObjectFactory.createSObject(
                new OperatingHours(Name = 'VISN Operating Hours', TimeZone = territoryTimeZone.toString()),
                true
            );

            List<ServiceTerritory> visns = (List<ServiceTerritory>) VATEST_SObjectFactory.createSObjects(
                new ServiceTerritory(Name = 'Test VISN A', IsActive = true, OperatingHoursId = opHours.Id),
                4,
                true
            );

            Integer testYear = Date.today().year();
            Integer testMonth = Date.today().month();
            Integer lastDayOfMonth = Date.today().addMonths(7).addDays(-1).day();

            for (ServiceTerritory visn : visns) {
                Boolean blnFirstIteration = true;
                for (ServiceResource provider : providers) {
                    if (!blnCreateMultipleMemberPerVisn && !blnFirstIteration) {
                        continue;
                    }
                    blnFirstIteration = false;
                    ServiceTerritoryMember member = (ServiceTerritoryMember) VATEST_SObjectFactory.createSObject(
                        new ServiceTerritoryMember(
                            EffectiveStartDate = Date.newInstance(testYear, testMonth, 1),
                            EffectiveEndDate = Date.newInstance(testYear, testMonth + 6, lastDayOfMonth),
                            ServiceTerritoryId = visn.Id,
                            ServiceTerritory = visn,
                            ServiceResourceId = provider.Id,
                            ServiceResource = provider
                        ),
                        false
                    );
                    members.add(member);
                    member.Id = null; //empty out fake Id
                }
                testYear++;
            }
            insert members;

            List<Shift> shifts = new List<Shift>();
            for (ServiceTerritoryMember member : members) {
                Datetime startTime = member.EffectiveStartDate;
                shifts.add(
                    new Shift(
                        StartTime = startTime.addHours(9), // startTime of Shift is start of work-day
                        EndTime = startTime.addHours(17), // endTime is end of workday
                        ServiceResourceId = member.ServiceResourceId,
                        ServiceTerritoryId = member.ServiceTerritoryId,
                        RecurrencePattern = RRULE_FOR_NEXT_180_DAYS,
                        RecurrenceEndDate = startTime.addDays(180).date(),
                        Status = 'Confirmed',
                        Type = 'Recurring'
                    )
                );
            }
            insert shifts;
        }
        return members;
    }
    private static void createMockedRepo(
        List<String> visnNames,
        List<Id> visnIds,
        List<ServiceTerritoryMember> members
    ) {
        Iterator<ServiceTerritoryMember> membersIterator = members.iterator();

        VCR_ServiceTerritoryMemberRepo mockedRepo = (VCR_ServiceTerritoryMemberRepo) new VATEST_StubBuilder(
                VCR_ServiceTerritoryMemberRepo.class
            )
            .mockingMethodCall('fetchMembersIteratorByVisnNames')
            .withParameterTypes(List<String>.class)
            .withParameterValues(visnNames)
            .returning(membersIterator)
            .defineStub();
        VCC_AppointmentUtilQueueableService.memoizedTerritoryMemberRepo = mockedRepo;
    }

    /**
     * @description Verify that the constructor initializes the instance successfully
     */
    @IsTest
    static void unitItConstructsPositive() {
        Test.startTest();
        System.runAs(MOLLY_MIN_ACCESS) {
            systemUnderTest = new VCC_AppointmentUtilQueueableService();
        }
        Test.stopTest();
        Assert.isNotNull(
            VCC_AppointmentUtilQueueableService.service,
            'Expected the constructor to successfully initialize the AppointmentUtilizationService'
        );
    }

    /**
     * @description Verify that the memoized repo is initialized correctly
     */
    @IsTest
    static void unitRepoIsInitializedPositive() {
        Test.startTest();
        Assert.isNull(
            VCC_AppointmentUtilQueueableService.memoizedTerritoryMemberRepo,
            'Expected memoized repo instance to be null prior to being initialized'
        );
        System.runAs(MOLLY_MIN_ACCESS) {
            Assert.isNotNull(
                VCC_AppointmentUtilQueueableService.territoryMemberRepo,
                'Expected repo to be initialized when it is first accessed.'
            );
        }
        Test.stopTest();
        Assert.isNotNull(
            VCC_AppointmentUtilQueueableService.memoizedTerritoryMemberRepo,
            'Expected memoized repo instance to be initialized after initializing repo variable'
        );
    }

    /**
     * @description Verify that we fetch data correctly for given set of VISN names.
     * NOTE: This needs to be a functional test as it is not possible to stub-out Iterable/Iterator
     *     interfaces using the Test.setStub() (known limitation with Apex stubbing).
     *     See thread here: https://salesforce.stackexchange.com/questions/229817/test-createstub-for-class-which-returns-batchable-in-method
     */
    @IsTest
    static void funcFetchDataForVisnNamesPositive() {
        List<ServiceTerritoryMember> members;
        System.runAs(VCC_APPT_ADMIN) {
            members = createTestData();
        }
        List<String> visnNames = new List<String>();
        for (ServiceTerritoryMember member : members) {
            visnNames.add(member.ServiceTerritory.Name);
        }
        VCC_AppointmentUtilQueueable.AppointmentUtilizationData data = new VCC_AppointmentUtilQueueable.AppointmentUtilizationData(
            visnNames,
            Date.today(),
            Date.today().addDays(31)
        );
        Test.startTest();
        System.runAs(VCC_APPT_ADMIN) {
            systemUnderTest = new VCC_AppointmentUtilQueueableService();
            systemUnderTest.setConfig(TEST_CONFIG);
            systemUnderTest.fetchData(data);
        }
        Test.stopTest();
        Assert.isFalse(
            systemUnderTest.hasExitCriteriaBeenMet(),
            'Expected there to be records to process after fetching the matching ServiceTerritoryMember records.'
        );
    }

    /**
     * @description Test method to fetch data based on a given set of VISN Ids
     */
    @IsTest
    static void funcFetchDataForVisnIdsPositive() {
        List<ServiceTerritoryMember> members;
        System.runAs(VCC_APPT_ADMIN) {
            members = createTestData();
        }
        List<ServiceTerritory> visns = new List<ServiceTerritory>();
        for (ServiceTerritoryMember member : members) {
            visns.add(member.ServiceTerritory);
        }
        VCC_AppointmentUtilQueueable.AppointmentUtilizationData data = new VCC_AppointmentUtilQueueable.AppointmentUtilizationData(
            visns,
            Date.today(),
            Date.today().addDays(31)
        );
        Test.startTest();
        System.runAs(VCC_APPT_ADMIN) {
            systemUnderTest = new VCC_AppointmentUtilQueueableService();
            systemUnderTest.setConfig(TEST_CONFIG);
            systemUnderTest.fetchData(data);
        }
        Test.stopTest();
        Assert.isFalse(
            systemUnderTest.hasExitCriteriaBeenMet(),
            'Expected there to be records to process after fetching the matching ServiceTerritoryMember records.'
        );
    }

    /**
     * @description Test fetching data for all VISNs
     */
    @IsTest
    static void funcFetchDataForAllVISNsPositive() {
        List<ServiceTerritoryMember> members;
        System.runAs(VCC_APPT_ADMIN) {
            members = createTestData();
        }
        VCC_AppointmentUtilQueueable.AppointmentUtilizationData data = new VCC_AppointmentUtilQueueable.AppointmentUtilizationData(
            (List<ServiceTerritory>) null,
            Date.today(),
            Date.today().addDays(31)
        );
        Test.startTest();
        System.runAs(VCC_APPT_ADMIN) {
            systemUnderTest = new VCC_AppointmentUtilQueueableService();
            systemUnderTest.setConfig(TEST_CONFIG);
            systemUnderTest.fetchData(data);
            Assert.isFalse(
                systemUnderTest.hasExitCriteriaBeenMet(),
                'Expected there to be records to process after fetching the matching ServiceTerritoryMember records.'
            );
        }
        Test.stopTest();
    }

    /**
     * @description INTEGRATION test for Appointment Utilization
     *
     *  Due to an inability to fix issue with stubbed version of method not matching runtime/invocation. So for now, in the interest of getting this done
     *  until I can get another pair of eyes to look at it with me, I am going to make this an integration test, not just a functional test
     */
    @IsTest
    static void intgExecutePositive() {
        List<ServiceTerritoryMember> members;
        System.runAs(VCC_APPT_ADMIN) {
            members = createTestData();
        }
        Date startDate = Date.today();
        Date endDate = startDate.addDays(1);
        VCC_DateRange dates = new VCC_DateRange(startDate, endDate);
        dates.endDateTime = dates.endDateTime.addMinutes(-1);
        VCC_AppointmentUtilQueueable.AppointmentUtilizationData data = new VCC_AppointmentUtilQueueable.AppointmentUtilizationData(
            (List<ServiceTerritory>) null,
            startDate,
            endDate
        );
        Test.startTest();
        System.runAs(VCC_APPT_ADMIN) {
            systemUnderTest = new VCC_AppointmentUtilQueueableService();
            systemUnderTest.setConfig(TEST_CONFIG);
            systemUnderTest.fetchData(data);
            systemUnderTest.execute();
            Assert.isTrue(
                systemUnderTest.hasExitCriteriaBeenMet(),
                'Expected all records to be processed when `execute()` was performed.'
            );
        }
        Test.stopTest();
        Assert.areEqual(
            3,
            [SELECT COUNT() FROM VCC_Appointment_Utilization__c],
            'Expected an VCC_Appointment_Utilization__c record to be created for each of our ServiceTerritoryMember records with Shifts in the Date Range.'
        );
    }

    /**
     * @description INTEGRATION test for Appointment Utilization when we are running a subsequent iteration
     *
     *  Due to an inability to fix issue with stubbed version of method not matching runtime/invocation. So for now, in the interest of getting this done
     *  until I can get another pair of eyes to look at it with me, I am going to make this an integration test, not just a functional test
     */
    @IsTest
    static void intgExecuteForNextIterationsPositive() {
        List<ServiceTerritoryMember> members;
        System.runAs(VCC_APPT_ADMIN) {
            members = createTestData();
        }
        TEST_CONFIG.Queueable_Batch_Size__c = 5;
        Date startDate = Date.today();
        Date endDate = startDate.addDays(1);
        VCC_DateRange dates = new VCC_DateRange(startDate, endDate);
        dates.endDateTime = dates.endDateTime.addMinutes(-1);
        VCC_AppointmentUtilQueueable.AppointmentUtilizationData data = new VCC_AppointmentUtilQueueable.AppointmentUtilizationData(
            (List<ServiceTerritory>) null,
            startDate,
            endDate
        );
        systemUnderTest = new VCC_AppointmentUtilQueueableService();
        systemUnderTest.setConfig(TEST_CONFIG);
        Test.startTest();
        System.runAs(VCC_APPT_ADMIN) {
            // records 0 - 4
            systemUnderTest.fetchData(data);
            systemUnderTest.execute();
            Assert.isFalse(
                systemUnderTest.hasExitCriteriaBeenMet(),
                'Expected there to still be records remaining due to small batch size when `execute()` was performed.'
            );
            Assert.areEqual(
                5,
                systemUnderTest.position,
                'Expected position to be 5 after processing first batch of records.'
            );

            // records 5 - 9
            systemUnderTest.execute();
            Assert.isFalse(
                systemUnderTest.hasExitCriteriaBeenMet(),
                'Expected there to still be records remaining due to small batch size when `execute()` was performed.'
            );
            Assert.areEqual(
                10,
                systemUnderTest.position,
                'Expected position to be 10 after processing second batch of records.'
            );

            // records 10 - 12
            systemUnderTest.execute();
            Assert.isTrue(
                systemUnderTest.hasExitCriteriaBeenMet(),
                'Expected all records to be processed as we have processed 3 batches for 12 records with batch size = 5 for `execute()`.'
            );
        }
        Test.stopTest();
        Assert.areEqual(
            3,
            [SELECT COUNT() FROM VCC_Appointment_Utilization__c],
            'Expected an VCC_Appointment_Utilization__c record to be created for each of our ServiceTerritoryMember records with Shifts in the Date Range.'
        );
    }

    /**
     * @description INTEGRATION test for Appointment Utilization - testing that when we query for all VISNs within
     *  Users TimeZone, that VISNs in other TimeZones are not returned
     *
     */
    @IsTest
    static void intgExecuteNegative() {
        List<ServiceTerritoryMember> members;
        System.runAs(VCC_APPT_ADMIN) {
            members = createTestData(TimeZone.getTimeZone('GMT'));
        }
        Date startDate = Date.today();
        Date endDate = startDate.addDays(1);
        VCC_DateRange dates = new VCC_DateRange(startDate, endDate);
        dates.endDateTime = dates.endDateTime.addMinutes(-1);
        VCC_AppointmentUtilQueueable.AppointmentUtilizationData data = new VCC_AppointmentUtilQueueable.AppointmentUtilizationData(
            (List<ServiceTerritory>) null,
            startDate,
            endDate
        );
        Test.startTest();
        System.runAs(VCC_APPT_ADMIN) {
            systemUnderTest = new VCC_AppointmentUtilQueueableService();
            systemUnderTest.setConfig(TEST_CONFIG);
            systemUnderTest.fetchData(data);
            systemUnderTest.execute();
            Assert.isTrue(
                systemUnderTest.hasExitCriteriaBeenMet(),
                'Expected exit criteria to be met as there are no matching records.'
            );
        }
        Test.stopTest();
        Assert.areEqual(
            0,
            [SELECT COUNT() FROM VCC_Appointment_Utilization__c],
            'Expected NO VCC_Appointment_Utilization__c records to since OperatingHours are in a different TimeZone.'
        );
    }

    // This is currently not in use but I am keeping it here for future use if/when we can figure out how to mock out the service class correctly
    private static void createMockedService(List<ServiceTerritoryMember> members, VCC_DateRange dateRange) {
        VCC_AppointmentUtilQueueableService.service = (VCC_AppointmentUtilizationService) new VATEST_StubBuilder(
                VCC_AppointmentUtilizationService.class
            )
            .mockingMethodCall('calculateUtilizationForTerritoryMembersInRange')
            .withParameterTypes(List<ServiceTerritoryMember>.class, VCC_DateRange.class)
            .withParameterValues(members, dateRange)
            .returning()
            .defineStub();
    }
}
