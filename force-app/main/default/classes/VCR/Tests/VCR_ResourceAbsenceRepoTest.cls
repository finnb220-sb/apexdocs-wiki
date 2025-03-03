/**
 * @description Test class for the VCR_ResourceAbsenceRepo
 * @see VCR_ResourceAbsenceRepo
 */
@IsTest
private class VCR_ResourceAbsenceRepoTest {
    private static VCR_ResourceAbsenceRepo systemUnderTest;
    private static final User MOLLY_MIN_ACCESS;
    private static final User SYDNEY_SYS_ADMIN;

    private static final DateTime JANUARY_FIRST_2024;

    static {
        JANUARY_FIRST_2024 = Datetime.newInstance(2024, 1, 1);
        MOLLY_MIN_ACCESS = VATEST_UserFactory.createMinAccessPersonaUser(false);
        MOLLY_MIN_ACCESS.TimeZoneSidKey = UserInfo.getTimeZone().getID();
        SYDNEY_SYS_ADMIN = new VATEST_UserBuilder()
            .withUserProfile('System Administrator')
            .withStandardData()
            .setFields(User.TimeZoneSidKey, UserInfo.getTimeZone().getID())
            .withPermissionSet('VCC_VCV_Appointment_Viewer_Administrator')
            .build(true);
    }

    @TestSetup
    static void makeData() {
        //Avoid mixed dml and avoid an error where test running user doesn't have a scheduler license.
        System.runAs(SYDNEY_SYS_ADMIN) {
            ServiceResource personWhoIsAbsent = (ServiceResource) VATEST_SObjectFactory.createSObject(
                new ServiceResource(
                    Name = 'personWhoIsAbsent',
                    IsActive = true,
                    RelatedRecordId = VATEST_UserFactory.createMinAccessPersonaUser(true).Id
                ),
                true
            );
            //Create one in range.
            List<ResourceAbsence> absences = new List<ResourceAbsence>{
                new ResourceAbsence(
                    Start = JANUARY_FIRST_2024,
                    End = JANUARY_FIRST_2024.addDays(1),
                    ResourceId = personWhoIsAbsent.Id
                )
            };
            //Create one out of range.
            absences.add(
                new ResourceAbsence(
                    Start = JANUARY_FIRST_2024.addYears(1),
                    End = JANUARY_FIRST_2024.addYears(1).addDays(1),
                    ResourceId = personWhoIsAbsent.Id
                )
            );
            new VCR_ResourceAbsenceRepo().doCreate(absences);
        }
    }

    /**
     * @description Tests the logic in the constructor.
     */
    @IsTest
    static void unitConstructorSetsSobjectTypePositive() {
        Test.startTest();
        {
            System.runAs(MOLLY_MIN_ACCESS) {
                systemUnderTest = new VCR_ResourceAbsenceRepo();
            }
        }
        Test.stopTest();
        Assert.areEqual(
            ResourceAbsence.SObjectType,
            systemUnderTest.SObjectType,
            'Expected constructor to set SObjectType.'
        );
    }

    /**
     * @description Functional test that tests the happy path of when the date ranges overlap exactly with an existing absence.
     * Assert: Correct number of absences are returned.
     * Assert: Expected Absence record is returned.
     */
    @IsTest
    static void funcGetAbsencesInRangePositive() {
        Set<Id> serviceResourceIds = new Map<Id, ServiceResource>([SELECT Id FROM ServiceResource]).keySet();
        List<ResourceAbsence> absences = new List<ResourceAbsence>();
        VCC_DateRange range = new VCC_DateRange(JANUARY_FIRST_2024, JANUARY_FIRST_2024.addDays(7));
        Test.startTest();
        {
            System.runAs(SYDNEY_SYS_ADMIN) {
                systemUnderTest = new VCR_ResourceAbsenceRepo();
                absences = systemUnderTest.getAbsencesInDateRangeForServiceResourcesInList(serviceResourceIds, range);
            }
        }
        Test.stopTest();
        Assert.areEqual(1, absences.size(), 'Expected Only one absence to be returned.');
        Assert.areEqual(
            JANUARY_FIRST_2024,
            absences.get(0).Start,
            'Expected absence with StartDate of January first to be returned!'
        );
        Assert.isTrue(
            serviceResourceIds.contains(absences.get(0).ResourceId),
            'Expected absence related to ServiceResource whose Id was passed in to be returned from query!'
        );
    }

    /**
     * @description  Functional test for when a querying with a date range that overlaps an existing absence, the absence is returned.
     * Assert: Correct number of absences are returned.
     * Assert: Expected Absence record is returned.
     */
    @IsTest
    static void funcGetAbsencesInRangeNegative() {
        Set<Id> serviceResourceIds = new Map<Id, ServiceResource>([SELECT Id FROM ServiceResource]).keySet();
        List<ResourceAbsence> absences = new List<ResourceAbsence>();
        VCC_DateRange range = new VCC_DateRange(JANUARY_FIRST_2024.addDays(-1), JANUARY_FIRST_2024.addDays(1));
        Test.startTest();
        {
            System.runAs(SYDNEY_SYS_ADMIN) {
                systemUnderTest = new VCR_ResourceAbsenceRepo();
                absences = systemUnderTest.getAbsencesInDateRangeForServiceResourcesInList(serviceResourceIds, range);
            }
        }
        Test.stopTest();
        Assert.areEqual(1, absences.size(), 'Expected Only one absence to be returned.');
        Assert.areEqual(
            JANUARY_FIRST_2024,
            absences.get(0).Start,
            'Expected absence with StartDate of January first to be returned!'
        );
        Assert.isTrue(
            serviceResourceIds.contains(absences.get(0).ResourceId),
            'Expected absence related to ServiceResource whose Id was passed in to be returned from query!'
        );
    }

    /**
     * @description Tests that a query with a date range that does not overlap with any absences, does not return records.
     * Assert: No absences returned
     */
    @IsTest
    static void funcGetAbsencesOutOfRangeNegative() {
        Set<Id> serviceResourceIds = new Map<Id, ServiceResource>([SELECT Id FROM ServiceResource]).keySet();
        List<ResourceAbsence> absences = new List<ResourceAbsence>();
        VCC_DateRange range = new VCC_DateRange(
            JANUARY_FIRST_2024.addYears(-1),
            JANUARY_FIRST_2024.addYears(-1).addDays(1)
        );
        Test.startTest();
        {
            System.runAs(SYDNEY_SYS_ADMIN) {
                systemUnderTest = new VCR_ResourceAbsenceRepo();
                absences = systemUnderTest.getAbsencesInDateRangeForServiceResourcesInList(serviceResourceIds, range);
            }
        }
        Test.stopTest();
        Assert.areEqual(0, absences.size(), 'Expected no absences to be returned.');
    }
}
