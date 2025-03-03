/**
 * @author Booz Allen Hamilton
 * @since 5/20/24
 * @description Unit/Functional tests for VCR_OperatingHoursHolidayRepo
 * @see VCR_OperatingHoursHolidayRepo
 */
@IsTest
private class VCR_OperatingHoursHolidayRepoTest {
    final static User VCC_VCV_APPT_VIEW_ADMIN_USER;
    static {
        VCC_VCV_APPT_VIEW_ADMIN_USER = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSet('VCC_VCV_Appointment_Viewer_Administrator')
            .withStandardData()
            .build(true);
    }

    @IsTest
    static void unitItConstructsPositive() {
        Test.startTest();
        VCR_OperatingHoursHolidayRepo repo;
        System.runAs(VCC_VCV_APPT_VIEW_ADMIN_USER) {
            repo = new VCR_OperatingHoursHolidayRepo();
        }
        Test.stopTest();
        Assert.isNotNull(repo, 'Expected a valid instance of VCR_OperatingHoursHolidayRepo to be created.');
    }

    /**
     * @description Test happy path - retrieving OperatingHoursHolidays by Operating Hours Ids when records exist
     */
    @IsTest
    static void funcFetchByOpHoursIdPositive() {
        String visnName = 'VISN 1';
        OperatingHours opHours;
        Set<Id> relatedOpHoursIds = new Set<Id>();
        OperatingHoursHoliday opHoursHoliday;
        System.runAs(VCC_VCV_APPT_VIEW_ADMIN_USER) {
            opHours = (OperatingHours) VATEST_SObjectFactory.createSObject(
                new OperatingHours(Name = visnName + ' Operating Hours', VCC_VISN__c = visnName),
                true
            );
            relatedOpHoursIds.add(opHours.Id);
            Holiday firstOfTheMonthHoliday = (Holiday) VATEST_SObjectFactory.createSObject(
                new Holiday(
                    Name = 'August First Random Holiday',
                    IsRecurrence = true,
                    IsAllDay = true,
                    RecurrenceStartDate = Date.newInstance(2024, 8, 1),
                    RecurrenceType = 'RecursYearly',
                    RecurrenceDayOfMonth = 1,
                    RecurrenceMonthOfYear = 'August',
                    ActivityDate = Date.newInstance(2024, 8, 1)
                ),
                true
            );

            opHoursHoliday = (OperatingHoursHoliday) VATEST_SObjectFactory.createSObject(
                new OperatingHoursHoliday(
                    HolidayId = firstOfTheMonthHoliday.Id,
                    Holiday = firstOfTheMonthHoliday,
                    OperatingHoursId = opHours.Id,
                    OperatingHours = opHours
                ),
                true
            );
        }

        Test.startTest();
        VCR_OperatingHoursHolidayRepo repo;
        List<OperatingHoursHoliday> returnedOpHoursHolidays;
        System.runAs(VCC_VCV_APPT_VIEW_ADMIN_USER) {
            repo = new VCR_OperatingHoursHolidayRepo();
            returnedOpHoursHolidays = repo.fetchHolidaysForVISNOperatingHours(relatedOpHoursIds);
        }
        Test.stopTest();
        Assert.areEqual(
            1,
            returnedOpHoursHolidays.size(),
            'Expected only a single test record for our Operating Hours to be returned'
        );
        Assert.areEqual(
            opHoursHoliday.OperatingHoursId,
            returnedOpHoursHolidays[0].OperatingHoursId,
            'Expected our test record to have a reference to test Operating Hours record.'
        );
        Assert.areEqual(
            opHoursHoliday.HolidayId,
            returnedOpHoursHolidays[0].HolidayId,
            'Expected our test record to have a reference to test Holiday record.'
        );
    }

    /**
     * @description Test unhappy path - retrieving OperatingHoursHolidays by Operating Hours Ids when no records exist
     */
    @IsTest
    static void funcFetchByOpHoursIdNegative() {
        String visnName = 'VISN 1';
        OperatingHours opHours;
        Set<Id> relatedOpHoursIds = new Set<Id>();
        System.runAs(VCC_VCV_APPT_VIEW_ADMIN_USER) {
            opHours = (OperatingHours) VATEST_SObjectFactory.createSObject(
                new OperatingHours(Name = visnName + ' Operating Hours', VCC_VISN__c = visnName),
                true
            );
            relatedOpHoursIds.add(opHours.Id);
        }
        Test.startTest();
        VCR_OperatingHoursHolidayRepo repo;
        List<OperatingHoursHoliday> returnedOpHoursHolidays;
        System.runAs(VCC_VCV_APPT_VIEW_ADMIN_USER) {
            repo = new VCR_OperatingHoursHolidayRepo();
            returnedOpHoursHolidays = repo.fetchHolidaysForVISNOperatingHours(relatedOpHoursIds);
        }
        Test.stopTest();
        Assert.isNotNull(
            returnedOpHoursHolidays,
            'Expected an empty, not null list of OperatingHoursHolidays when no results found'
        );
        Assert.areEqual(
            0,
            returnedOpHoursHolidays.size(),
            'Expected list of OperatingHoursHolidays to be empty when no results found'
        );
    }
}
