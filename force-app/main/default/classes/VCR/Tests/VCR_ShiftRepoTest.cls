/**
 * @description Test Class for VCR_ShiftRepo
 * @author Booz Allen Hamilton
 *
 * @see VCR_ShiftRepo
 */
@IsTest
private with sharing class VCR_ShiftRepoTest {
    private static final User VAVET_BASE;
    private static final VCR_ShiftRepo SYSTEM_UNDER_TEST;
    private static final Datetime JAN_FIRST_2024;
    private static final Datetime JAN_FIRST_2025;
    private static final Datetime JAN_FIRST_2026;

    static {
        VAVET_BASE = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .setFields(User.TimeZoneSidKey, UserInfo.getTimeZone().getID())
            .withPermissionSets(
                new Set<String>{ 'VCC_VCV_Appointment_Viewer_Administrator', 'VCC_CreateEdit_Appointment' }
            )
            .build(true);
        SYSTEM_UNDER_TEST = new VCR_ShiftRepo();
        JAN_FIRST_2024 = Datetime.newInstanceGmt(2024, 1, 1);
        JAN_FIRST_2025 = JAN_FIRST_2024.addYears(1);
        JAN_FIRST_2026 = JAN_FIRST_2025.addYears(1);
    }

    @TestSetup
    static void makeTestData() {
        //Build Date Range and RRule
        String next180Days = 'RRULE:FREQ=DAILY;INTERVAL=1;COUNT=180;';

        System.runAs(new User(Id = UserInfo.getUserId())) {
            ServiceResource personWhoIsWorkingTheShift = (ServiceResource) VATEST_SObjectFactory.createSObject(
                new ServiceResource(Name = 'TestPerson', RelatedRecordId = VAVET_BASE.Id, IsActive = true),
                true
            );
            ServiceTerritory placeInWhichTheyWork = (ServiceTerritory) VATEST_SObjectFactory.createSObject(
                new ServiceTerritory(
                    Name = 'TestTerritory',
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
                    EffectiveEndDate = JAN_FIRST_2026.addDays(180),
                    ServiceTerritoryId = placeInWhichTheyWork.Id,
                    ServiceResourceId = personWhoIsWorkingTheShift.Id
                ),
                true
            );
            //Create shifts in the date range with the tested RRule
            List<Shift> shifts = new List<Shift>{
                new Shift(
                    StartTime = JAN_FIRST_2024,
                    EndTime = JAN_FIRST_2024.addHours(8),
                    ServiceResourceId = personWhoIsWorkingTheShift.Id,
                    ServiceTerritoryId = placeInWhichTheyWork.Id,
                    RecurrencePattern = next180Days,
                    Status = 'Confirmed',
                    Type = 'Recurring'
                )
            };
            //Create some non confirmed shifts.
            shifts.add(
                new Shift(
                    StartTime = JAN_FIRST_2026.addDays(1),
                    EndTime = JAN_FIRST_2026.addDays(1).addHours(8),
                    ServiceResourceId = personWhoIsWorkingTheShift.Id,
                    ServiceTerritoryId = placeInWhichTheyWork.Id,
                    RecurrencePattern = next180Days,
                    Type = 'Recurring',
                    Status = 'Tentative'
                )
            );
            new VCR_ShiftRepo().doCreate(shifts);

            List<ShiftShare> shiftShares = new List<ShiftShare>();
            shiftShares.add(
                new ShiftShare(ParentId = shifts[0].Id, UserOrGroupId = VAVET_BASE.Id, AccessLevel = 'Edit')
            );
            shiftShares.add(
                new ShiftShare(ParentId = shifts[0].Id, UserOrGroupId = VAVET_BASE.Id, AccessLevel = 'Edit')
            );
            insert shiftShares;
        }
    }

    /**
     * @description Constructor test, to ensure that the SObjectType of this repo is set. Arguably not needed, but why not.
     */
    @IsTest
    private static void unitConstructorSetsSObjectType() {
        System.runAs(VAVET_BASE) {
            Assert.areEqual(
                Shift.SObjectType,
                SYSTEM_UNDER_TEST.sObjectType,
                'Expected VCR_ShiftRepo to have an internal SObjectType of Shift.'
            );
        }
    }

    /**
     * @description Runs getConfirmedShiftsRelatedToServiceTerritoryMembersInDateRange and...
     * Assert: The expected number of shifts are returned.
     * Assert: The shift is confirmed.
     * Assert: That shift StartTime is the expected StartTime
     * Assert: That the shift is related to the correct ServiceResource and ServiceTerritory
     */
    @IsTest
    private static void funcGetConfirmedShiftsDoesNotReturnNonConfirmedShiftsNegative() {
        Set<Id> serviceResourceIds = new Map<Id, ServiceResource>([SELECT Id FROM ServiceResource]).keySet();
        Set<Id> serviceTerritoryIds = new Map<Id, ServiceTerritory>([SELECT Id FROM ServiceTerritory]).keySet();
        VCC_DateRange janToJan = new VCC_DateRange(JAN_FIRST_2026, JAN_FIRST_2026.addYears(1));
        List<Shift> result;
        Test.startTest();
        {
            System.runAs(VAVET_BASE) {
                result = SYSTEM_UNDER_TEST.getConfirmedShiftsRelatedToServiceTerritoryMembersInDateRange(
                    janToJan,
                    serviceTerritoryIds,
                    serviceResourceIds
                );
            }
        }
        Test.stopTest();

        Assert.areEqual(
            0,
            result.size(),
            'Expected Query to return no shifts, as there were no confirmed shifts in the given range.'
        );
    }

    /**
     * @description Runs getConfirmedShiftsRelatedToServiceTerritoryMembersInDateRange and...
     * Assert: The expected number of shifts are returned.
     * Assert: The shift is confirmed.
     * Assert: That shift StartTime is the expected StartTime
     * Assert: That the shift is related to the correct ServiceResource and ServiceTerritory
     */
    @IsTest
    private static void funcGetConfirmedShiftsFiltersByArgumentsAndByStatusPositive() {
        Set<Id> serviceResourceIds = new Map<Id, ServiceResource>([SELECT Id FROM ServiceResource]).keySet();
        Set<Id> serviceTerritoryIds = new Map<Id, ServiceTerritory>([SELECT Id FROM ServiceTerritory]).keySet();
        VCC_DateRange janToJan = new VCC_DateRange(JAN_FIRST_2024, JAN_FIRST_2025);
        List<Shift> result;
        Test.startTest();
        {
            System.runAs(VAVET_BASE) {
                result = SYSTEM_UNDER_TEST.getConfirmedShiftsRelatedToServiceTerritoryMembersInDateRange(
                    janToJan,
                    serviceTerritoryIds,
                    serviceResourceIds
                );
            }
        }
        Test.stopTest();

        Shift returnedShift = result.get(0);

        Assert.areEqual(1, result.size(), 'Expected Query to return the one Confirmed shift in range');
        Assert.areEqual(
            'Confirmed',
            returnedShift.Status,
            'Expected the query to only return Shifts that are Confirmed.'
        );
        Assert.areEqual(JAN_FIRST_2024, returnedShift.StartTime, 'Expected Query to return shift that was in range.');
        Assert.isTrue(
            serviceTerritoryIds.contains(returnedShift.ServiceTerritoryId),
            'Expected query to only return shifts related to a ServiceTerritory Passed in'
        );
        Assert.isTrue(
            serviceResourceIds.contains(returnedShift.ServiceResourceId),
            'Expected query to only return shifts related to a ServiceResource Passed in'
        );
    }

    /**
     * @description Given a date range that should only include a shift with a RecurrenceEndDate....
     * Runs getConfirmedShiftsRelatedToServiceTerritoryMembersInDateRange and...
     * Assert: The expected number of shifts are returned.
     * Assert: The shift is confirmed.
     * Assert: That shift StartTime is the expected StartTime
     * Assert: That the shift is related to the correct ServiceResource and ServiceTerritory
     */
    @IsTest
    private static void funcGetConfirmedShiftsByRecurrenceEndDatePositive() {
        Set<Id> serviceResourceIds = new Map<Id, ServiceResource>([SELECT Id FROM ServiceResource]).keySet();
        Set<Id> serviceTerritoryIds = new Map<Id, ServiceTerritory>([SELECT Id FROM ServiceTerritory]).keySet();
        VCC_DateRange janToJan = new VCC_DateRange(JAN_FIRST_2024.addDays(120), JAN_FIRST_2025);
        List<Shift> result;
        Test.startTest();
        {
            System.runAs(VAVET_BASE) {
                result = SYSTEM_UNDER_TEST.getConfirmedShiftsRelatedToServiceTerritoryMembersInDateRange(
                    janToJan,
                    serviceTerritoryIds,
                    serviceResourceIds
                );
            }
        }
        Test.stopTest();

        Shift returnedShift = result.get(0);

        Assert.areEqual(1, result.size(), 'Expected Query to return the one Confirmed shift in range');
        Assert.areEqual(
            'Confirmed',
            returnedShift.Status,
            'Expected the query to only return Shifts that are Confirmed.'
        );
        Assert.areEqual(JAN_FIRST_2024, returnedShift.StartTime, 'Expected Query to return shift that was in range.');
        Assert.isTrue(
            serviceTerritoryIds.contains(returnedShift.ServiceTerritoryId),
            'Expected query to only return shifts related to a ServiceTerritory Passed in'
        );
        Assert.isTrue(
            serviceResourceIds.contains(returnedShift.ServiceResourceId),
            'Expected query to only return shifts related to a ServiceResource Passed in'
        );
    }
}
