/**
 * @description Tests for VCR_ServiceAppointmentRepo class
 * @author Booz Allen Hamilton
 *
 * @see VCR_ServiceAppointmentRepo for class being tested
 */
@IsTest
private with sharing class VCR_ServiceAppointmentRepoTest {
    private static final Datetime JAN_FIRST_2024;
    private static final VCR_ServiceAppointmentRepo SYSTEM_UNDER_TEST;
    private static final User VAVET_BASE;
    private static final User SYSTEM_ADMIN;

    static {
        VAVET_BASE = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .withPermissionSets(
                new Set<String>{ 'VCC_VCV_Appointment_Viewer_Administrator', 'VCC_CreateEdit_Appointment' }
            )
            .build(true);
        Group baseUserGroup = [SELECT Id FROM Group WHERE DeveloperName = 'VAHC_Base_Users' LIMIT 1];
        GroupMember baseUserGroupMember = new GroupMember(UserOrGroupId = VAVET_BASE.Id, GroupId = baseUserGroup.Id);
        insert baseUserGroupMember;

        SYSTEM_ADMIN = new VATEST_UserBuilder()
            .withUserProfile('System Administrator')
            .withStandardData()
            .withPermissionSets(
                new Set<String>{ 'VCC_VCV_Appointment_Viewer_Administrator', 'VCC_CreateEdit_Appointment' }
            )
            .build(true);

        JAN_FIRST_2024 = Datetime.newInstanceGmt(2024, 1, 1);
        SYSTEM_UNDER_TEST = new VCR_ServiceAppointmentRepo();
    }

    @TestSetup
    private static void makeData() {
        Id minAccessPersonaUserId = VATEST_UserFactory.createMinAccessPersonaUser(true).Id;
        //Avoid mixed dml and avoid an error where test running user doesn't have a scheduler license.
        System.runAs(SYSTEM_ADMIN) {
            ServiceResource personWhoWorks = (ServiceResource) VATEST_SObjectFactory.createSObject(
                new ServiceResource(Name = 'personWhoWorks', IsActive = true, RelatedRecordId = minAccessPersonaUserId),
                true
            );
            Account patient = (Account) VATEST_SObjectFactory.createSObject(new Account(Name = 'Patient Patty'), true);
            ServiceTerritory placeInWhichTheyWork = (ServiceTerritory) VATEST_SObjectFactory.createSObject(
                new ServiceTerritory(
                    Name = 'VISN 1',
                    IsActive = true,
                    OperatingHoursId = VATEST_SObjectFactory.createSObject(
                            new OperatingHours(Name = 'Fake Operating hours'),
                            true
                        )
                        .Id
                ),
                true
            );
            VATEST_SObjectFactory.createSObject(
                new ServiceTerritoryMember(
                    EffectiveStartDate = JAN_FIRST_2024,
                    EffectiveEndDate = JAN_FIRST_2024.addYears(2).addDays(180),
                    ServiceTerritoryId = placeInWhichTheyWork.Id,
                    ServiceResourceId = personWhoWorks.Id
                ),
                true
            );
            List<ServiceAppointment> appointments = new List<ServiceAppointment>{
                new ServiceAppointment(
                    SchedStartTime = JAN_FIRST_2024,
                    SchedEndTime = JAN_FIRST_2024.addMinutes(30),
                    ServiceTerritoryId = placeInWhichTheyWork.Id,
                    ParentRecordId = patient.Id,
                    VCC_VISN_for_Appointment__c = placeInWhichTheyWork.Name
                )
            };
            new VCR_ServiceAppointmentRepo().doCreate(appointments);
            //Assign the service Resources

            List<AssignedResource> assignedResources = new List<AssignedResource>();
            for (ServiceAppointment appt : appointments) {
                assignedResources.add(
                    new AssignedResource(ServiceAppointmentId = appt.Id, ServiceResourceId = personWhoWorks.Id)
                );
            }
            insert as user assignedResources;
        }
    }

    /**
     * @description Test the initialization of the repo object.
     * Assert: Sets internal SObject
     */
    @IsTest
    private static void unitConstructorSetsInternalSObjectPositive() {
        VCR_ServiceAppointmentRepo repo;
        System.runAs(VAVET_BASE) {
            Test.startTest();
            repo = SYSTEM_UNDER_TEST;
            Test.stopTest();
        }
        Assert.areEqual(
            ServiceAppointment.SObjectType,
            repo.sObjectType,
            'Expected constructor to set the internal SObjectType to ServiceAppointment.'
        );
    }

    /**
     * @description Functional sad path test, for querying on a ServiceAppointments in a given date range
     * That are worked by non-expected ServiceTerritoryMembers. Tests that when there are appointments worked
     * at Service Territories represented in the territoryIds set but NOT by ServiceResources in the resourceIds Set
     * Nothing is returned
     * Assert: 0 appointments returned by query.
     */
    @IsTest
    private static void funcQueryFiltersByResourceIdsNegative() {
        System.runAs(VAVET_BASE) {
            List<ServiceTerritoryMember> members = [
                SELECT Id, ServiceResourceId, ServiceTerritoryId
                FROM ServiceTerritoryMember
            ];
            Set<Id> fakeResourceIds = new Set<Id>();
            Set<Id> realTerritoryIds = new Set<Id>();
            for (ServiceTerritoryMember member : members) {
                realTerritoryIds.add(member.ServiceTerritoryId);
            }

            //Add a fake Id to the Service Resource Id collection.
            fakeResourceIds.add(VATEST_SObjectFactory.createSObject(new ServiceResource()).Id);

            //Mocked date range
            VCC_DateRange range = new VCC_DateRange(JAN_FIRST_2024.addDays(-1), JAN_FIRST_2024.addDays(1));
            List<ServiceAppointment> resultWithFakeResourceIds = runGetServiceAppointmentsRelatedToTerritoryMembersInRangeTest(
                fakeResourceIds,
                realTerritoryIds,
                range
            );
            Assert.areEqual(0, resultWithFakeResourceIds.size(), 'Expected query to filter by resource Ids.');
        }
    }

    /**
     * @description Functional sad path test, for querying on a ServiceAppointments in a given date range
     * That are worked by non-expected ServiceTerritoryMembers. Tests that when there are appointments worked
     * by ServiceResources represented in the resourceIds set but NOT at Service Territories represented in the territoryIds Set
     * Nothing is returned
     * Assert: 0 appointments returned by query.
     */
    @IsTest
    private static void funcQueryFiltersByTerritoryIdsNegative() {
        System.runAs(VAVET_BASE) {
            List<ServiceTerritoryMember> members = [
                SELECT Id, ServiceResourceId, ServiceTerritoryId
                FROM ServiceTerritoryMember
            ];
            Set<Id> realResourceIds = new Set<Id>();
            Set<Id> fakeTerritoryIds = new Set<Id>();

            for (ServiceTerritoryMember member : members) {
                realResourceIds.add(member.ServiceResourceId);
            }

            //Add a fake Id to the Service Resource Object.
            fakeTerritoryIds.add(VATEST_SObjectFactory.createSObject(new ServiceTerritory()).Id);

            //Mocked date range
            VCC_DateRange range = new VCC_DateRange(JAN_FIRST_2024.addDays(-1), JAN_FIRST_2024.addDays(1));
            List<ServiceAppointment> resultWithFakeTerritoryIds = runGetServiceAppointmentsRelatedToTerritoryMembersInRangeTest(
                realResourceIds,
                fakeTerritoryIds,
                range
            );

            Assert.areEqual(0, resultWithFakeTerritoryIds.size(), 'Expected query to filter by territory Ids.');
        }
    }

    /**
     * @description Functional Sad path test that tests when querying on Appointments in a date range where there are none,
     * nothing is returned.
     * Assert: 0 Appointments returned.
     */
    @IsTest
    private static void funcQueryFiltersByDateRangeNegative() {
        List<ServiceTerritoryMember> members = [
            SELECT Id, ServiceResourceId, ServiceTerritoryId
            FROM ServiceTerritoryMember
        ];
        Set<Id> resourceIds = new Set<Id>();
        Set<Id> territoryIds = new Set<Id>();
        for (ServiceTerritoryMember member : members) {
            resourceIds.add(member.ServiceResourceId);
            territoryIds.add(member.ServiceTerritoryId);
        }

        System.runAs(VAVET_BASE) {
            //Mocked date range
            VCC_DateRange range = new VCC_DateRange(JAN_FIRST_2024.addDays(7), JAN_FIRST_2024.addDays(14));
            List<ServiceAppointment> result = runGetServiceAppointmentsRelatedToTerritoryMembersInRangeTest(
                resourceIds,
                territoryIds,
                range
            );

            Assert.areEqual(0, result.size(), 'Expected query to filter by date Range!.');
        }
    }
    /**
     * @description helper method to test runGetServiceAppointmentsRelatedToTerritoryMembersInRange
     * @param resourceIds set of resource IDs
     * @param territoryIds set of territory IDs
     * @param range 'VCC_DateRange' the date range to filter by
     * @return `List<ServiceAppointment>` the list of service appointments returned by the query
     */
    private static List<ServiceAppointment> runGetServiceAppointmentsRelatedToTerritoryMembersInRangeTest(
        Set<Id> resourceIds,
        Set<Id> territoryIds,
        VCC_DateRange range
    ) {
        List<ServiceAppointment> result;
        Test.startTest();
        {
            System.runAs(VAVET_BASE) {
                result = SYSTEM_UNDER_TEST.getServiceAppointmentsRelatedToTerritoryMembersInRange(
                    resourceIds,
                    territoryIds,
                    range
                );
            }
        }
        Test.stopTest();
        return result;
    }
    /**
     * @description Test the getQueryLocatorForServiceAppointments method
     * Positive test case
     * @see VCR_ServiceAppointmentRepo.getQueryLocatorForServiceAppointments
     */
    @IsTest
    private static void funcTestGetQueryLocatorForServiceAppointmentsPositive() {
        VCR_ServiceAppointmentRepo repo;
        Database.QueryLocator result;
        System.runAs(VAVET_BASE) {
            Test.startTest();
            repo = new VCR_ServiceAppointmentRepo();
            result = repo.getQueryLocatorForServiceAppointments(repo.getQueryStringForServiceAppointments());
            Test.stopTest();
        }
        Assert.isNotNull(
            result,
            'Expected the method getQueryLocatorForServiceAppointments to return a non-null object representing a query locator'
        );
    }
    /**
     * @description Test the getQueryLocatorForServiceAppointments method
     * Negative test case
     * @see VCR_ServiceAppointmentRepo.getQueryLocatorForServiceAppointments
     */
    @IsTest
    private static void funcTestGetQueryLocatorForServiceAppointmentsNegative() {
        VCR_ServiceAppointmentRepo repo;
        Database.QueryLocator result;
        Boolean isExceptionThrown = false;
        System.runAs(VAVET_BASE) {
            Test.startTest();
            try {
                repo = new VCR_ServiceAppointmentRepo();
                result = repo.getQueryLocatorForServiceAppointments(null);
            } catch (NullPointerException e) {
                isExceptionThrown = true;
            }
            Test.stopTest();
        }
        Assert.isTrue(
            isExceptionThrown && result == null,
            'Expected the method getQueryLocatorForServiceAppointments to throw a NullPointerException when the query string is null'
        );
    }
}
