/**
 * @description         Test Class for TUC_ScheduleTeleEcQueuePause
 * @author              Booz Allen Hamilton
 * @see TUC_ScheduleTeleEcQueuePause
 **/
@IsTest
private with sharing class TUC_ScheduleTeleEcQueuePauseTest {
    private static TUC_ScheduleTeleEcQueuePause queuePauseSchedule;
    private static final String VISN_NAME = 'VISN 1';
    private static final String VISN_NUMBER_STRING = '1';
    private static final String QUEUE_TYPE = 'High Acuity';
    private static final String TEST_PAUSE_REASON = 'Provider unavailable- service at capacity'; //must match a Tele-EC Pause Reason, defined in the TUC_Pause_Reason__c field
    private static final String AFTER_HOURS_STRING = 'Tele-EC closed (after hours)';
    private static final String PAUSED_STRING = 'Paused';
    private static final String RESUMED_STRING = 'Resumed';
    private static final String OPERATING_HOURS_FINISH_STRING = ' Operating Hours';
    private static final String STANDARD_USER_TIMEZONE = 'America/Los_Angeles';
    private static final String EASTERN_TIMEZONE = 'America/New_York';
    private static OperatingHours operatingHours;
    private static final String OPERATING_HOURS_TYPE = 'Tele-EC';
    private static final String TEST_HOLIDAY_NAME = 'Test Holiday';
    private static WorkTypeGroup workTypeGroup;
    private static Time currentTime;
    private static Integer currentHour;
    private static Time startTime;
    private static Time endTime;
    private static Datetime currentDatetime = Datetime.now();
    private static final String RESUME_ONLY_STRING = 'Tele-EC Start Time Only';
    private static final String PAUSE_ONLY_STRING = 'Tele-EC End Time Only';
    private static final String DAY_OF_WEEK_FORMAT_STRING = 'EEEE';
    private static final String VISN_REPLACE_STRING = 'VISN ';
    private static final String EMPTY_STRING = '';
    private static final User TELEEC_DOCTOR_TEST_USER;
    static {
        TELEEC_DOCTOR_TEST_USER = new VATEST_UserBuilder()
            .withStandardData()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSet('TED_Medical_Provider_Group')
            .withPermissionSet('Tele_EC_Operating_Hours_Access')
            .build(true);
    }

    /**
     * @description - Sets up a standard data set for the test methods when called
     */
    private static void setup() {
        // Create test data
        VATEST_SObjectFactory.createSObject(
            operatingHours = (OperatingHours) new OperatingHours(
                Name = VISN_NAME + OPERATING_HOURS_FINISH_STRING,
                VCC_VISN__c = VISN_NAME,
                VCC_Operating_Hours_Type__c = OPERATING_HOURS_TYPE,
                TimeZone = STANDARD_USER_TIMEZONE
            ),
            true
        );
        VATEST_SObjectFactory.createSObject(
            workTypeGroup = (WorkTypeGroup) new WorkTypeGroup(Name = 'Virtual Clinic Visit'),
            true
        );
        currentHour = currentDatetime.hour();
        currentTime = Time.newInstance(currentHour, currentDatetime.minute(), 0, 0);

        TUC_VISN_Pause_Control__mdt mockMdtVisn1 = new TUC_VISN_Pause_Control__mdt();
        mockMdtVisn1.MasterLabel = VISN_NAME;
        mockMdtVisn1.TUC_Operating_Hours_Enabled__c = true;
        mockMdtVisn1.TUC_VISN__c = VISN_NAME;

        List<TUC_VISN_Pause_Control__mdt> mockList = new List<TUC_VISN_Pause_Control__mdt>{ mockMdtVisn1 };

        TUC_VISNPauseControlRepo stubRepo = (TUC_VISNPauseControlRepo) new VATEST_StubBuilder(
                TUC_VISNPauseControlRepo.class
            )
            .mockingMethodCall('getAllActiveTucVisnPauseControlRecords')
            .withParameterTypes()
            .returning(mockList)
            .defineStub();
        TUC_ScheduleTeleEcQueuePause.memoizedTucVisnPauseRepo = stubRepo; // dependency injected a fake implementation of the repo.
    }
    /**
     * @description Test method to validate proper instantiation of the TUC_ScheduleTeleEcQueuePause class.
     */
    @IsTest
    static void funcTUCScheduleTeleEcQueuePausePositive() {
        System.runAs(TELEEC_DOCTOR_TEST_USER) {
            Test.startTest();
            queuePauseSchedule = new TUC_ScheduleTeleEcQueuePause();
            Test.stopTest();
            Assert.isNotNull(queuePauseSchedule, 'Expected an instance of TUC_ScheduleTeleEcQueuePause to be created.');
        }
    }

    /**
     * @description - Sets up all the needed data to simulate creating a resumed escalation status record and tests accordingly
     */
    @IsTest
    static void funcExecuteResumeCreationPositive() {
        System.runAs(TELEEC_DOCTOR_TEST_USER) {
            setup();
            if (currentHour <= 22) {
                startTime = currentTime;
                endTime = currentTime.addHours(1);
            } else if (currentHour == 23) {
                startTime = currentTime;
                endTime = Time.newInstance(23, 59, 59, 0);
            }
            Tele_EC_Escalation_Status__c escalationStatusPrototype = new Tele_EC_Escalation_Status__c();
            escalationStatusPrototype.TUC_Status_Datetime__c = System.now();
            escalationStatusPrototype.TUC_VISN__c = VISN_NUMBER_STRING;
            escalationStatusPrototype.TUC_Is_Current_Status__c = true;
            escalationStatusPrototype.TUC_Queue_Type__c = QUEUE_TYPE;
            escalationStatusPrototype.TUC_Pause_Reason__c = TEST_PAUSE_REASON;
            escalationStatusPrototype.TUC_Status_Type__c = PAUSED_STRING; //pre-create a paused record for resume creation
            VATEST_SObjectFactory.createSObject(escalationStatusPrototype, true);
            VATEST_SObjectFactory.createSObject(
                new TimeSlot(
                    DayOfWeek = currentDatetime.format(DAY_OF_WEEK_FORMAT_STRING),
                    VCC_VISN__c = VISN_NAME,
                    OperatingHoursId = operatingHours.Id,
                    StartTime = startTime,
                    EndTime = endTime,
                    MaxAppointments = 1,
                    WorkTypeGroupId = workTypeGroup.Id
                ),
                true
            );

            queuePauseSchedule = new TUC_ScheduleTeleEcQueuePause();
            Test.startTest();
            queuePauseSchedule.execute(null);
            Test.stopTest();
            TUC_TeleEcEscalationStatusRepo testRepo = new TUC_TeleEcEscalationStatusRepo();
            List<Tele_EC_Escalation_Status__c> results = testRepo.getEscalationStatusWithVisnAndQueueType(
                VISN_NAME.replace(VISN_REPLACE_STRING, EMPTY_STRING),
                QUEUE_TYPE
            );

            Assert.areEqual(
                1,
                results.size(),
                'Expected single record to be returned but ' + results.size() + ' were returned'
            );
            Assert.areEqual(
                null,
                results.get(0).TUC_Pause_Reason__c,
                'Expected null string to be returned but was ' + results.get(0).TUC_Pause_Reason__c
            );
            Assert.areEqual(
                RESUMED_STRING,
                results.get(0).TUC_Status_Type__c,
                'Expected ' + RESUMED_STRING + ' to be returned but was ' + results.get(0).TUC_Status_Type__c
            );
        }
    }

    /**
     * @description - Sets up all the needed data to simulate creating a closed escalation status record and tests accordingly
     */
    @IsTest
    static void funcExecuteCloseCreationPositive() {
        System.runAs(TELEEC_DOCTOR_TEST_USER) {
            setup();
            startTime = currentTime;
            endTime = currentTime.addMinutes(1);
            VATEST_SObjectFactory.createSObject(
                new TimeSlot(
                    DayOfWeek = currentDatetime.format(DAY_OF_WEEK_FORMAT_STRING),
                    VCC_VISN__c = VISN_NAME,
                    OperatingHoursId = operatingHours.Id,
                    StartTime = startTime,
                    EndTime = endTime,
                    MaxAppointments = 1,
                    WorkTypeGroupId = workTypeGroup.Id
                ),
                true
            );

            queuePauseSchedule = new TUC_ScheduleTeleEcQueuePause();
            Test.startTest();
            queuePauseSchedule.execute(null);
            Test.stopTest();
            TUC_TeleEcEscalationStatusRepo testRepo = new TUC_TeleEcEscalationStatusRepo();
            List<Tele_EC_Escalation_Status__c> results = testRepo.getEscalationStatusWithVisnAndQueueType(
                VISN_NAME.replace(VISN_REPLACE_STRING, EMPTY_STRING),
                QUEUE_TYPE
            );

            Assert.areEqual(
                1,
                results.size(),
                'Expected single record to be returned but ' + results.size() + ' were returned'
            );
            Assert.areEqual(
                AFTER_HOURS_STRING,
                results.get(0).TUC_Pause_Reason__c,
                'Expected closed after hours to be returned but was ' + results.get(0).TUC_Pause_Reason__c
            );
            Assert.areEqual(
                PAUSED_STRING,
                results.get(0).TUC_Status_Type__c,
                'Expected ' + PAUSED_STRING + ' to be returned but was ' + results.get(0).TUC_Status_Type__c
            );
        }
    }

    /**
     * @description - Sets up all the needed data to simulate when neither start or end time are in-sequence and tests for no creation
     */
    @IsTest
    static void funcExecuteNoCreationNegative() {
        System.runAs(TELEEC_DOCTOR_TEST_USER) {
            setup();
            if (currentHour <= 12) {
                startTime = currentTime.addHours(1);
                endTime = currentTime.addHours(2);
            } else {
                startTime = currentTime.addHours(-2);
                endTime = currentTime.addHours(-1);
            }
            VATEST_SObjectFactory.createSObject(
                new TimeSlot(
                    DayOfWeek = currentDatetime.format(DAY_OF_WEEK_FORMAT_STRING),
                    VCC_VISN__c = VISN_NAME,
                    OperatingHoursId = operatingHours.Id,
                    StartTime = startTime,
                    EndTime = endTime,
                    MaxAppointments = 1,
                    WorkTypeGroupId = workTypeGroup.Id
                ),
                true
            );

            queuePauseSchedule = new TUC_ScheduleTeleEcQueuePause();
            Test.startTest();
            queuePauseSchedule.execute(null);
            Test.stopTest();

            TUC_TeleEcEscalationStatusRepo testRepo = new TUC_TeleEcEscalationStatusRepo();
            List<Tele_EC_Escalation_Status__c> results = testRepo.getEscalationStatusWithVisnAndQueueType(
                VISN_NAME.replace(VISN_REPLACE_STRING, EMPTY_STRING),
                QUEUE_TYPE
            );

            Assert.areEqual(
                0,
                results.size(),
                'Expected no records to be returned but ' + results.size() + ' were returned'
            );
        }
    }

    /**
     * @description - Sets up all the needed data to simulate a timezone difference and in-sequence and tests for positive creation
     */
    @IsTest
    static void unitTimezoneCreationPositive() {
        System.runAs(TELEEC_DOCTOR_TEST_USER) {
            setup();
            String testOperatingHourTimezone = EASTERN_TIMEZONE; //Set to New_York compared to running user LA to simulate time zone differences
            OperatingHours newOpHours;
            VATEST_SObjectFactory.createSObject(
                newOpHours = (OperatingHours) new OperatingHours(
                    Name = VISN_NAME + OPERATING_HOURS_FINISH_STRING,
                    VCC_VISN__c = VISN_NAME,
                    VCC_Operating_Hours_Type__c = OPERATING_HOURS_TYPE,
                    TimeZone = testOperatingHourTimezone
                ),
                true
            );
            if (currentHour <= 19) {
                startTime = currentTime.addHours(3); //we add 3 hours as that is the difference between LA and New York
                endTime = currentTime.addHours(4);
            } else if (currentHour == 20) {
                startTime = currentTime.addHours(3);
                endTime = Time.newInstance(23, 59, 59, 0);
            } else if (currentHour > 21) {
                //we want to reset the new Time variable if it goes over 24 hrs to simulate midnight rollovers
                startTime = Time.newInstance((currentHour - 21), currentDatetime.minute(), 0, 0);
                endTime = Time.newInstance((currentHour - 20), currentDatetime.minute(), 0, 0);
            }
            Tele_EC_Escalation_Status__c escalationStatusPrototype = new Tele_EC_Escalation_Status__c();
            escalationStatusPrototype.TUC_Status_Datetime__c = System.now();
            escalationStatusPrototype.TUC_VISN__c = VISN_NUMBER_STRING;
            escalationStatusPrototype.TUC_Is_Current_Status__c = true;
            escalationStatusPrototype.TUC_Queue_Type__c = QUEUE_TYPE;
            escalationStatusPrototype.TUC_Pause_Reason__c = TEST_PAUSE_REASON;
            escalationStatusPrototype.TUC_Status_Type__c = PAUSED_STRING; //pre-create a paused record for resume creation
            VATEST_SObjectFactory.createSObject(escalationStatusPrototype, true);
            VATEST_SObjectFactory.createSObject(
                new TimeSlot(
                    DayOfWeek = currentDatetime.format(DAY_OF_WEEK_FORMAT_STRING),
                    VCC_VISN__c = VISN_NAME,
                    OperatingHoursId = newOpHours.Id,
                    StartTime = startTime,
                    EndTime = endTime,
                    MaxAppointments = 1,
                    WorkTypeGroupId = workTypeGroup.Id
                ),
                true
            );

            queuePauseSchedule = new TUC_ScheduleTeleEcQueuePause();
            Test.startTest();
            queuePauseSchedule.execute(null);
            Test.stopTest();

            TUC_TeleEcEscalationStatusRepo testRepo = new TUC_TeleEcEscalationStatusRepo();
            List<Tele_EC_Escalation_Status__c> results = testRepo.getEscalationStatusWithVisnAndQueueType(
                VISN_NAME.replace(VISN_REPLACE_STRING, EMPTY_STRING),
                QUEUE_TYPE
            );

            Assert.areEqual(
                1,
                results.size(),
                'Expected single record to be returned but ' + results.size() + ' were returned'
            );
            Assert.areEqual(
                null,
                results.get(0).TUC_Pause_Reason__c,
                'Expected null string to be returned but was ' + results.get(0).TUC_Pause_Reason__c
            );
            Assert.areEqual(
                RESUMED_STRING,
                results.get(0).TUC_Status_Type__c,
                'Expected ' + RESUMED_STRING + ' to be returned but was ' + results.get(0).TUC_Status_Type__c
            );
        }
    }

    /**
     * @description - Sets up all the needed data to simulate a timezone difference and out of sequence, then tests accordingly for no creation
     */
    @IsTest
    static void unitTimezoneNoCreationNegative() {
        System.runAs(TELEEC_DOCTOR_TEST_USER) {
            setup();
            String testOperatingHourTimezone = EASTERN_TIMEZONE; //Set to New_York compared to running user LA to simulate time zone differences
            OperatingHours newOpHours;
            VATEST_SObjectFactory.createSObject(
                newOpHours = (OperatingHours) new OperatingHours(
                    Name = VISN_NAME + OPERATING_HOURS_FINISH_STRING,
                    VCC_VISN__c = VISN_NAME,
                    VCC_Operating_Hours_Type__c = OPERATING_HOURS_TYPE,
                    TimeZone = testOperatingHourTimezone
                ),
                true
            );
            if (currentHour <= 22) {
                startTime = currentTime;
                endTime = currentTime.addHours(1);
            } else if (currentHour == 23) {
                startTime = currentTime;
                endTime = Time.newInstance(23, 59, 59, 0);
            }
            VATEST_SObjectFactory.createSObject(
                new TimeSlot(
                    DayOfWeek = currentDatetime.format(DAY_OF_WEEK_FORMAT_STRING),
                    VCC_VISN__c = VISN_NAME,
                    OperatingHoursId = newOpHours.Id,
                    StartTime = startTime,
                    EndTime = endTime,
                    MaxAppointments = 1,
                    WorkTypeGroupId = workTypeGroup.Id
                ),
                true
            );

            queuePauseSchedule = new TUC_ScheduleTeleEcQueuePause();
            Test.startTest();
            queuePauseSchedule.execute(null);
            Test.stopTest();

            TUC_TeleEcEscalationStatusRepo testRepo = new TUC_TeleEcEscalationStatusRepo();
            List<Tele_EC_Escalation_Status__c> results = testRepo.getEscalationStatusWithVisnAndQueueType(
                VISN_NAME.replace(VISN_REPLACE_STRING, EMPTY_STRING),
                QUEUE_TYPE
            );

            Assert.areEqual(
                0,
                results.size(),
                'Expected no records to be returned but ' + results.size() + ' were returned'
            );
        }
    }

    /**
     * @description - Sets up all the needed data to simulate that today is a holiday and blocks creation
     */
    @IsTest
    static void unitHolidayCheckPositive() {
        System.runAs(TELEEC_DOCTOR_TEST_USER) {
            setup();
            String testOperatingHourTimezone = EASTERN_TIMEZONE; //Set to New_York compared to running user LA to simulate time zone differences
            OperatingHours newOpHours;
            VATEST_SObjectFactory.createSObject(
                newOpHours = (OperatingHours) new OperatingHours(
                    Name = VISN_NAME + OPERATING_HOURS_FINISH_STRING,
                    VCC_VISN__c = VISN_NAME,
                    VCC_Operating_Hours_Type__c = OPERATING_HOURS_TYPE,
                    TimeZone = testOperatingHourTimezone
                ),
                true
            );
            Holiday newHoliday;
            VATEST_SObjectFactory.createSObject(
                newHoliday = (Holiday) new Holiday(Name = TEST_HOLIDAY_NAME, ActivityDate = currentDatetime.date()),
                true
            );
            OperatingHoursHoliday newOpHoursHoliday;
            VATEST_SObjectFactory.createSObject(
                newOpHoursHoliday = (OperatingHoursHoliday) new OperatingHoursHoliday(
                    OperatingHoursId = newOpHours.Id,
                    HolidayId = newHoliday.Id
                ),
                true
            );

            queuePauseSchedule = new TUC_ScheduleTeleEcQueuePause();
            Test.startTest();
            queuePauseSchedule.execute(null);
            Test.stopTest();

            TUC_TeleEcEscalationStatusRepo testRepo = new TUC_TeleEcEscalationStatusRepo();
            List<Tele_EC_Escalation_Status__c> results = testRepo.getEscalationStatusWithVisnAndQueueType(
                VISN_NAME.replace(VISN_REPLACE_STRING, EMPTY_STRING),
                QUEUE_TYPE
            );

            Assert.areEqual(
                0,
                results.size(),
                'Expected no records to be returned but ' + results.size() + ' were returned'
            );
        }
    }

    /**
     * @description - Sets up all the needed data to simulate that today is a recurring holiday and blocks creation
     */
    @IsTest
    static void unitRecurringHolidayCheckPositive() {
        System.runAs(TELEEC_DOCTOR_TEST_USER) {
            setup();
            String testOperatingHourTimezone = EASTERN_TIMEZONE; //Set to New_York compared to running user LA to simulate time zone differences
            OperatingHours newOpHours;
            VATEST_SObjectFactory.createSObject(
                newOpHours = (OperatingHours) new OperatingHours(
                    Name = VISN_NAME + OPERATING_HOURS_FINISH_STRING,
                    VCC_VISN__c = VISN_NAME,
                    VCC_Operating_Hours_Type__c = OPERATING_HOURS_TYPE,
                    TimeZone = testOperatingHourTimezone
                ),
                true
            );
            Date currentDateLastYear = currentDatetime.date().addYears(-1);
            Holiday newHoliday;
            VATEST_SObjectFactory.createSObject(
                newHoliday = (Holiday) new Holiday(
                    Name = TEST_HOLIDAY_NAME,
                    ActivityDate = currentDateLastYear, //set this to last year
                    isRecurrence = true,
                    RecurrenceStartDate = currentDateLastYear,
                    RecurrenceDayOfMonth = currentDatetime.day(),
                    RecurrenceMonthOfYear = currentDateTime.format('MMMM'),
                    RecurrenceType = 'RecursYearly'
                ),
                true
            );
            OperatingHoursHoliday newOpHoursHoliday;
            VATEST_SObjectFactory.createSObject(
                newOpHoursHoliday = (OperatingHoursHoliday) new OperatingHoursHoliday(
                    OperatingHoursId = newOpHours.Id,
                    HolidayId = newHoliday.Id
                ),
                true
            );

            queuePauseSchedule = new TUC_ScheduleTeleEcQueuePause();
            Test.startTest();
            queuePauseSchedule.execute(null);
            Test.stopTest();

            TUC_TeleEcEscalationStatusRepo testRepo = new TUC_TeleEcEscalationStatusRepo();
            List<Tele_EC_Escalation_Status__c> results = testRepo.getEscalationStatusWithVisnAndQueueType(
                VISN_NAME.replace(VISN_REPLACE_STRING, EMPTY_STRING),
                QUEUE_TYPE
            );

            Assert.areEqual(
                0,
                results.size(),
                'Expected no records to be returned but ' + results.size() + ' were returned'
            );
        }
    }

    /**
     * @description - Sets up the time for a resume event and pause only time slot and tests that no creation occurred
     */
    @IsTest
    static void unitResumeTimePauseOnlyNoCreationPositive() {
        System.runAs(TELEEC_DOCTOR_TEST_USER) {
            setup();
            if (currentHour <= 22) {
                startTime = currentTime;
                endTime = currentTime.addHours(1);
            } else if (currentHour == 23) {
                startTime = currentTime;
                endTime = Time.newInstance(23, 59, 59, 0);
            }
            VATEST_SObjectFactory.createSObject(
                new TimeSlot(
                    DayOfWeek = currentDatetime.format(DAY_OF_WEEK_FORMAT_STRING),
                    VCC_VISN__c = VISN_NAME,
                    OperatingHoursId = operatingHours.Id,
                    StartTime = startTime,
                    EndTime = endTime,
                    MaxAppointments = 1,
                    WorkTypeGroupId = workTypeGroup.Id,
                    TUC_Schedule_Settings__c = PAUSE_ONLY_STRING
                ),
                true
            );

            queuePauseSchedule = new TUC_ScheduleTeleEcQueuePause();
            Test.startTest();
            queuePauseSchedule.execute(null);
            Test.stopTest();
            TUC_TeleEcEscalationStatusRepo testRepo = new TUC_TeleEcEscalationStatusRepo();
            List<Tele_EC_Escalation_Status__c> results = testRepo.getEscalationStatusWithVisnAndQueueType(
                VISN_NAME.replace(VISN_REPLACE_STRING, EMPTY_STRING),
                QUEUE_TYPE
            );

            Assert.areEqual(
                0,
                results.size(),
                'Expected no records to be returned but ' + results.size() + ' were returned'
            );
        }
    }

    /**
     * @description - Sets up the time for a pause event and resume only time slot and tests that no creation occurred
     */
    @IsTest
    static void unitPauseTimeResumeOnlyNoCreationPositive() {
        System.runAs(TELEEC_DOCTOR_TEST_USER) {
            setup();
            startTime = currentTime.addMinutes(-60);
            endTime = currentTime;
            VATEST_SObjectFactory.createSObject(
                new TimeSlot(
                    DayOfWeek = currentDatetime.format(DAY_OF_WEEK_FORMAT_STRING),
                    VCC_VISN__c = VISN_NAME,
                    OperatingHoursId = operatingHours.Id,
                    StartTime = startTime,
                    EndTime = endTime,
                    MaxAppointments = 1,
                    WorkTypeGroupId = workTypeGroup.Id,
                    TUC_Schedule_Settings__c = RESUME_ONLY_STRING
                ),
                true
            );

            queuePauseSchedule = new TUC_ScheduleTeleEcQueuePause();
            Test.startTest();
            queuePauseSchedule.execute(null);
            Test.stopTest();
            TUC_TeleEcEscalationStatusRepo testRepo = new TUC_TeleEcEscalationStatusRepo();
            List<Tele_EC_Escalation_Status__c> results = testRepo.getEscalationStatusWithVisnAndQueueType(
                VISN_NAME.replace(VISN_REPLACE_STRING, EMPTY_STRING),
                QUEUE_TYPE
            );

            Assert.areEqual(
                0,
                results.size(),
                'Expected no records to be returned but ' + results.size() + ' were returned'
            );
        }
    }
}
