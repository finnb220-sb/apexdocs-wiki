/**
 * @description Unit test for VCC_AppointmentUtilSchedulable
 * @author Booz Allen Hamilton
 * @see VCC_AppointmentUtilSchedulable
 */
@IsTest
private class VCC_AppointmentUtilSchedulableTest {
    static VCC_AppointmentUtilSchedulable systemUnderTest;
    private static final String RUN_NIGHTLY_AT_MIDNIGHT = '0 0 0 * * ? *';
    private static final String USER_LAST_NAME = 'VCCApptUtilSchedTest';

    /**
     * @description Setup test data for testing.
     */
    @TestSetup
    static void buildData() {
        new VATEST_UserBuilder()
            .withUserProfile('System Administrator')
            .withStandardData()
            .setFields(User.TimeZoneSidKey, UserInfo.getTimeZone().getID())
            .setFields(User.LastName, USER_LAST_NAME)
            .withPermissionSet('VCC_VCV_Appointment_Viewer_Administrator')
            .withPermissionSet('VAHC_View_Appointment_Utilization')
            .build(true);
    }

    private static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = :USER_LAST_NAME LIMIT 1];
    }

    /**
     * @description Verify that we can create an instance of the Schedulable class setting schedule to our desired value
     */
    @IsTest
    static void unitItConstructsPositive() {
        User testUser = getTestUser();
        VCC_Appointment_Utilization_Config__mdt config = new VCC_Appointment_Utilization_Config__mdt(
            Default_Cron_Schedule__c = RUN_NIGHTLY_AT_MIDNIGHT
        );
        Test.startTest();
        System.runAs(testUser) {
            systemUnderTest = new VCC_AppointmentUtilSchedulable(config);
        }
        Test.stopTest();
        Assert.isNotNull(
            systemUnderTest,
            'Expected a valid instance of `VCC_AppointmentUtilSchedulable` to be created.'
        );
        Assert.areEqual(
            RUN_NIGHTLY_AT_MIDNIGHT,
            systemUnderTest.schedule,
            'Expected schedule variable to be initialized in ctor.'
        );
    }

    /**
     * @description Verify that we can create an instance of the Schedulable class when the input is invalid
     */
    @IsTest
    static void unitItConstructsNullConfigNegative() {
        User testUser = getTestUser();
        Test.startTest();
        System.runAs(testUser) {
            systemUnderTest = new VCC_AppointmentUtilSchedulable(null);
        }
        Test.stopTest();
        Assert.isNotNull(
            systemUnderTest,
            'Expected a valid instance of `VCC_AppointmentUtilSchedulable` to be created when invalid input given.'
        );
        Assert.areEqual(
            RUN_NIGHTLY_AT_MIDNIGHT,
            systemUnderTest.schedule,
            'Expected schedule variable to be initialized to default value when config value is missing.'
        );
    }

    /**
     * @description Verify that we can create an instance of the Schedulable class when the Cron Schedule field is invalid
     */
    @IsTest
    static void unitItConstructsNullScheduleFieldNegative() {
        VCC_Appointment_Utilization_Config__mdt config = new VCC_Appointment_Utilization_Config__mdt();

        User testUser = getTestUser();
        Test.startTest();
        System.runAs(testUser) {
            systemUnderTest = new VCC_AppointmentUtilSchedulable(config);
        }
        Test.stopTest();
        Assert.isNotNull(
            systemUnderTest,
            'Expected a valid instance of `VCC_AppointmentUtilSchedulable` to be created when config it is missing the Default_Cron_Schedule value.'
        );
        Assert.areEqual(
            RUN_NIGHTLY_AT_MIDNIGHT,
            systemUnderTest.schedule,
            'Expected schedule variable to be initialized to default value when config field Default_Cron_Schedule is missing.'
        );
    }

    /**
     * @description Verify that we can create an instance of the Schedulable class setting schedule to our desired value
     */
    @IsTest
    static void unitRunNowPositive() {
        User testUser = getTestUser();
        VCC_Appointment_Utilization_Config__mdt config = new VCC_Appointment_Utilization_Config__mdt(
            Default_Cron_Schedule__c = RUN_NIGHTLY_AT_MIDNIGHT
        );
        Id jobId;
        Test.startTest();
        System.runAs(testUser) {
            systemUnderTest = new VCC_AppointmentUtilSchedulable(config);
            jobId = systemUnderTest.runNow();
        }
        Test.stopTest();
        Assert.isNotNull(
            jobId,
            'Expected a valid jobId to be returned for a one-off instance of our `VCC_AppointmentUtilSchedulable` job.'
        );
    }

    @IsTest
    static void unitRunDefaultSchedulePositive() {
        User testUser = getTestUser();
        VCC_Appointment_Utilization_Config__mdt config = new VCC_Appointment_Utilization_Config__mdt(
            Default_Cron_Schedule__c = RUN_NIGHTLY_AT_MIDNIGHT
        );
        Id jobId;
        Test.startTest();
        System.runAs(testUser) {
            systemUnderTest = new VCC_AppointmentUtilSchedulable(config);
            jobId = systemUnderTest.runDefaultSchedule();
        }
        Test.stopTest();
        Assert.isNotNull(
            jobId,
            'Expected a valid jobId to be returned for our default scheduled `VCC_AppointmentUtilSchedulable` job.'
        );
        Assert.areEqual(
            1,
            [
                SELECT COUNT()
                FROM CronTrigger
                WHERE Id = :jobId
            ],
            'Expected to find an instance of `CronTrigger` for our scheduled job.'
        );
    }

    @IsTest
    static void unitRunDefaultScheduleForVisnNamesPositive() {
        User testUser = getTestUser();
        VCC_Appointment_Utilization_Config__mdt config = new VCC_Appointment_Utilization_Config__mdt(
            Default_Cron_Schedule__c = RUN_NIGHTLY_AT_MIDNIGHT
        );
        Id jobId;
        List<String> visnNames = new List<String>{ 'VISN 1', 'VISN 2' };
        Test.startTest();
        System.runAs(testUser) {
            systemUnderTest = new VCC_AppointmentUtilSchedulable(config);
            jobId = systemUnderTest.runDefaultSchedule(visnNames);
        }
        Test.stopTest();
        Assert.isNotNull(
            jobId,
            'Expected a valid jobId to be returned for our default scheduled `VCC_AppointmentUtilSchedulable` job.'
        );
        Assert.areEqual(
            1,
            [
                SELECT COUNT()
                FROM CronTrigger
                WHERE Id = :jobId
            ],
            'Expected to find an instance of `CronTrigger` for our scheduled job.'
        );

        Assert.areEqual(
            visnNames,
            systemUnderTest.visnNames,
            'Expected visnNames on Schedulable class to be initialized.'
        );
    }

    @IsTest
    static void unitRunDefaultScheduleForVisnIdsPositive() {
        User testUser = getTestUser();
        VCC_Appointment_Utilization_Config__mdt config = new VCC_Appointment_Utilization_Config__mdt(
            Default_Cron_Schedule__c = RUN_NIGHTLY_AT_MIDNIGHT
        );
        Id jobId;
        List<Id> visnIds = new List<Id>{ VATEST_IdFactory.get(ServiceTerritory.SObjectType) };
        Test.startTest();
        System.runAs(testUser) {
            systemUnderTest = new VCC_AppointmentUtilSchedulable(config);
            jobId = systemUnderTest.runDefaultSchedule(visnIds);
        }
        Test.stopTest();
        Assert.isNotNull(
            jobId,
            'Expected a valid jobId to be returned for our default scheduled `VCC_AppointmentUtilSchedulable` job.'
        );
        Assert.areEqual(
            1,
            [
                SELECT COUNT()
                FROM CronTrigger
                WHERE Id = :jobId
            ],
            'Expected to find an instance of `CronTrigger` for our scheduled job.'
        );

        Assert.areEqual(visnIds, systemUnderTest.visnIds, 'Expected visnIds on Schedulable class to be initialized.');
    }
}
