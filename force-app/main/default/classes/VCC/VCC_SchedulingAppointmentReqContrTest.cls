/*
 * @description Test class for VCC_SchedulingAppointmentReqContrTest
 * @author Booz Allen Hamilton
 * @since  3/25/2024
 */
@isTest
private class VCC_SchedulingAppointmentReqContrTest {
    final static Date STARTDATE = Date.today().addMonths(-1);
    final static Date STOPDATE = Date.today().addMonths(1);
    final static DateTime APPT_STARTDATE = DateTime.now();
    final static String TESTIEN = '4';
    final static String PROVIDER_IEN = '5';
    final static String FACILITY_CODE = '984';
    final static User MSA_USER = new VATEST_UserBuilder()
        .withPermissionSet('VCC_Advanced_Medical_Support_Assistant')
        .withPermissionSet('VAHC_Scheduling_User')
        .withUserProfile('VAVET Base Profile')
        .withStandardData()
        .build(true);

    /**
     * @description Test method that confirms that the clinicSlotRepo property injects successfully.
     */
    @isTest
    static void unitDidRepoInitialize() {
        Test.startTest();
        System.runAs(MSA_USER) {
            VCC_ScheduleAppointmentRequestController.clinicSlotRepo = null;
            VCC_ScheduleAppointmentRequestController.clinicRepo = null;
            VCC_ScheduleAppointmentRequestController.appointmentRepo = null;
            VCC_ScheduleAppointmentRequestController.appointmentRequestRepo = null;
        }
        Test.stopTest();
        Assert.isNotNull(
            VCC_ScheduleAppointmentRequestController.clinicSlotRepo,
            'Assertion failed: clinicSlotRepo is null; Expected a non-null value for VCC_ScheduleAppointmentRequestController.clinicSlotRepo'
        );
        Assert.isNotNull(
            VCC_ScheduleAppointmentRequestController.appointmentRepo,
            'Assertion failed: appointmentRepo is null; Expected a non-null value for VCC_ScheduleAppointmentRequestController.appointmentRepo'
        );
        Assert.isNotNull(
            VCC_ScheduleAppointmentRequestController.appointmentRequestRepo,
            'Assertion failed: appointmentRepo is null; Expected a non-null value for VCC_ScheduleAppointmentRequestController.appointmentRepo'
        );
        Assert.isNotNull(
            VCC_ScheduleAppointmentRequestController.clinicRepo,
            'Assertion failed: clinicRepo is null; Expected a non-null value for VCC_ScheduleAppointmentRequestController.clinicRepo'
        );
    }

    /**
     * @description Test method that confirms that the getExistingAppointments method can successfully be run by an MSA user
     */
    @isTest
    static void unitGetExistingAppointmentsPositive() {
        List<VCC_Appointment__c> apptList = new List<VCC_Appointment__c>{
            new VCC_Appointment__c(
                VCC_Status__c = 'Scheduled',
                VCC_Appointment_Start__c = APPT_STARTDATE,
                VCC_Patient__c = VATEST_IdFactory.get('Account')
            )
        };

        VCR_AppointmentRepo stubApptRepo = (VCR_AppointmentRepo) new VATEST_StubBuilder(VCR_AppointmentRepo.class)
            .mockingMethodCall('getExistingAppointments', String.class)
            .withParameterValues(apptList[0].VCC_Patient__c)
            .returning(apptList)
            .defineStub();
        Test.startTest();
        System.runAs(MSA_USER) {
            VCC_ScheduleAppointmentRequestController.appointmentRepo = stubapptRepo;
            VCC_ScheduleAppointmentRequestController.searchExistingAppointments(apptList[0].VCC_Patient__c);
        }
        Test.stopTest();
        Assert.areEqual(
            1,
            apptList.size(),
            'Assertion Passes; expected getExistingAppointments to return a list of size 1.'
        );
        Assert.areEqual(
            'Scheduled',
            apptList[0].VCC_Status__c,
            'Assertion Passes; expected Status values to be Scheduled.'
        );
        Assert.areEqual(
            APPT_STARTDATE.date(),
            apptList[0].VCC_Appointment_Start__c.date(),
            'Assertion Passes; expected Date Values to match'
        );
    }
    /**
     * @description  Negative Test method that confirms that the getExistingAppointments method can be run by an MSA user.
     */
    @isTest
    static void unitGetExistingAppointmentsNegative() {
        List<VCC_Appointment__c> apptList = new List<VCC_Appointment__c>();
        Id accountId = VATEST_IdFactory.get('Account');

        VCR_AppointmentRepo stubApptRepo = (VCR_AppointmentRepo) new VATEST_StubBuilder(VCR_AppointmentRepo.class)
            .mockingMethodCall('getExistingAppointments', String.class)
            .withParameterValues(accountId)
            .returning(apptList)
            .defineStub();
        Test.startTest();
        System.runAs(MSA_USER) {
            VCC_ScheduleAppointmentRequestController.appointmentRepo = stubapptRepo;
            VCC_ScheduleAppointmentRequestController.searchExistingAppointments(accountId);
        }
        Test.stopTest();
        Assert.isTrue(apptList.isEmpty(), 'Assertion Passes; expected getExistingAppointments to return empty list.');
    }

    /**
     * @description Test method that confirms that a VTC_RecordModel is returned
     * when timeslotParams are entered to fetchTimeslots
     */
    @IsTest
    static void unitFetchTimeslotsPositive() {
        VCC_ScheduleAppointmentRequestController.TimeSlotParams timeSlotParams = new VCC_ScheduleAppointmentRequestController.TimeSlotParams();
        timeSlotParams.startDate = STARTDATE;
        timeSlotParams.stopDate = STOPDATE;
        timeSlotParams.clinicIEN = TESTIEN;
        timeSlotParams.facilityCode = FACILITY_CODE;

        VTC_Timeslot stubTimeslotRecord = new VTC_Timeslot();
        VTC_RecordModel recordModel = new VTC_RecordModel();
        stubTimeslotRecord.id = '1';
        recordModel.records.add(stubTimeslotRecord);
        Map<String, Object> args = new Map<String, Object>{
            'application' => 'VAHC',
            'siteId' => timeSlotParams.facilityCode,
            'clinicIEN' => timeSlotParams.clinicIEN,
            'includeOriginal' => false,
            'startDate' => String.valueOf(timeSlotParams.startDate),
            'endDate' => String.valueOf(timeSlotParams.stopDate)
        };
        VCR_ClinicScheduleSlotRepo stubClinicSlotRepo = (VCR_ClinicScheduleSlotRepo) new VATEST_StubBuilder(
                VCR_ClinicScheduleSlotRepo.class
            )
            .mockingMethodCall('fetchTimeslots', Map<String, Object>.class)
            .withParameterValues(args)
            .returning((VTC_RecordModel) recordModel)
            .defineStub();
        Test.startTest();
        VTC_RecordModel recordModelTest;
        System.runAs(MSA_USER) {
            VCC_ScheduleAppointmentRequestController.clinicSlotRepo = stubClinicSlotRepo;
            recordModelTest = (VTC_RecordModel) VCC_ScheduleAppointmentRequestController.fetchTimeslots(timeSlotParams);
        }
        Test.stopTest();
        Assert.isNotNull(recordModelTest, 'Assertion failed; Expected recordModelTest to be not null');
        Assert.isNotNull(recordModelTest.records, 'Assertion failed; Expected records to be not null');
        Assert.isTrue(
            !recordModelTest.records.isEmpty(),
            'Assertion failed; expected a record inside the records list'
        );
        Assert.isNotNull(recordModelTest.records[0].vtcId, 'Assertion failed; expected a vtcId property');
    }
    /**
     * @description Test method that confirms that an exception is thrown when empty properties are passed as the request argument
     */
    @IsTest
    static void unitFetchTimeslotsEmptyPropertiesNegative() {
        VCC_ScheduleAppointmentRequestController.TimeSlotParams timeSlotParams = new VCC_ScheduleAppointmentRequestController.TimeSlotParams();
        Test.startTest();
        VTC_RecordModel timeslotRecordModel;
        System.runAs(MSA_USER) {
            try {
                timeslotRecordModel = (VTC_RecordModel) VCC_ScheduleAppointmentRequestController.fetchTimeslots(
                    timeSlotParams
                );
                Assert.fail('Test failed; expected an exception to be thrown.');
            } catch (AuraHandledException auraError) {
                Assert.areEqual(
                    'Invalid Request. Null/Empty request properties detected.',
                    auraError.getMessage(),
                    'Assertion failed; expected error message to be Invalid Request. Null/Empty request properties detected.'
                );
            }
        }
        Test.stopTest();
    }
    /**
     * @description Test method that confirms that a VTC_LimitException is caught
     */
    @IsTest
    static void unitFetchTimeslotsLimitExceptionNegative() {
        VTC_LimitException stubLimitException = new VTC_LimitException();
        stubLimitException.setMessage('Timeout Exception');

        VCC_ScheduleAppointmentRequestController.TimeSlotParams timeSlotParams = new VCC_ScheduleAppointmentRequestController.TimeSlotParams();
        timeSlotParams.startDate = STARTDATE;
        timeSlotParams.stopDate = STOPDATE;
        timeSlotParams.clinicIEN = TESTIEN;
        timeSlotParams.facilityCode = FACILITY_CODE;

        Map<String, Object> args = new Map<String, Object>{
            'application' => 'VAHC',
            'siteId' => timeSlotParams.facilityCode,
            'clinicIEN' => timeSlotParams.clinicIEN,
            'includeOriginal' => false,
            'startDate' => String.valueOf(timeSlotParams.startDate),
            'endDate' => String.valueOf(timeSlotParams.stopDate)
        };
        VCR_ClinicScheduleSlotRepo stubClinicSlotRepo = (VCR_ClinicScheduleSlotRepo) new VATEST_StubBuilder(
                VCR_ClinicScheduleSlotRepo.class
            )
            .mockingMethodCall('fetchTimeslots', Map<String, Object>.class)
            .withParameterValues(args)
            .throwingException(stubLimitException)
            .defineStub();
        Test.startTest();
        VTC_RecordModel timeslotRecordModel;
        System.runAs(MSA_USER) {
            VCC_ScheduleAppointmentRequestController.clinicSlotRepo = stubClinicSlotRepo;
            try {
                timeslotRecordModel = (VTC_RecordModel) VCC_ScheduleAppointmentRequestController.fetchTimeslots(
                    timeSlotParams
                );
                Assert.fail('Test failed; expected an exception to be thrown.');
            } catch (AuraHandledException auraError) {
                Assert.areEqual(
                    'Timeout Exception',
                    auraError.getMessage(),
                    'Assertion failed; expected error message to be Timeout Exception'
                );
            }
            Test.stopTest();
        }
    }

    /**
     * @description Test method that confirms that a VTC_Clinic record is returned
     * when a Facility Code and IEN is passed to getClinicByIEN
     */
    @IsTest
    static void unitGetClinicByIENPositive() {
        VTC_Clinic stubClinicRecord = new VTC_Clinic();
        stubClinicRecord.id = '1';
        Map<String, Object> args = new Map<String, Object>{
            'application' => 'VAHC',
            'siteId' => FACILITY_CODE,
            'clinicIEN' => TESTIEN
        };
        VCR_ClinicRepo stubClinicRepo = (VCR_ClinicRepo) new VATEST_StubBuilder(VCR_ClinicRepo.class)
            .mockingMethodCall('getClinicByIEN', Map<String, Object>.class)
            .withParameterValues(args)
            .returning((VTC_Record) stubClinicRecord)
            .defineStub();
        Test.startTest();
        VTC_Clinic clinicRecord;
        System.runAs(MSA_USER) {
            VCC_ScheduleAppointmentRequestController.clinicRepo = stubClinicRepo;
            clinicRecord = (VTC_Clinic) VCC_ScheduleAppointmentRequestController.getClinicByIEN(FACILITY_CODE, TESTIEN);
        }
        Test.stopTest();
        Assert.areEqual('1', clinicRecord.id, 'Assertion failed; expected a string value of 1 in the id property');
    }

    /**
     * @description Test method that confirms that an exception is thrown when empty properties are passed as the request argument
     */
    @IsTest
    static void unitGetClinicByIENEmptyPropertiesNegative() {
        Test.startTest();
        VTC_Clinic clinicRecord;
        System.runAs(MSA_USER) {
            try {
                clinicRecord = (VTC_Clinic) VCC_ScheduleAppointmentRequestController.getClinicByIEN('', '');
                Assert.isTrue(false, 'Test failed; expected an exception to be thrown.');
            } catch (AuraHandledException auraError) {
                Assert.areEqual(
                    'Invalid Request. Null/Empty request properties detected.',
                    auraError.getMessage(),
                    'Assertion failed; expected error message to be Invalid Request. Null/Empty request properties detected.'
                );
            }
        }
        Test.stopTest();
    }

    /**
     * @description Test method that confirms that an exception is thrown when null properties are passed as the request argument
     */
    @IsTest
    static void unitGetClinicByIENNullPropertiesNegative() {
        Test.startTest();
        VTC_Clinic clinicRecord;
        System.runAs(MSA_USER) {
            try {
                clinicRecord = (VTC_Clinic) VCC_ScheduleAppointmentRequestController.getClinicByIEN(null, null);
                Assert.isTrue(false, 'Test failed; expected an exception to be thrown.');
            } catch (AuraHandledException auraError) {
                Assert.areEqual(
                    'Invalid Request. Null/Empty request properties detected.',
                    auraError.getMessage(),
                    'Assertion failed; expected error message to be Invalid Request. Null/Empty request properties detected.'
                );
            }
        }
        Test.stopTest();
    }

    /**
     * @description Test method that confirms that a VTC_LimitException is caught
     */
    @IsTest
    static void unitGetClinicByIENLimitExceptionNegative() {
        VTC_LimitException stubLimitException = new VTC_LimitException();
        stubLimitException.setMessage('Timeout Exception');
        Map<String, Object> args = new Map<String, Object>{
            'application' => 'VAHC',
            'siteId' => FACILITY_CODE,
            'clinicIEN' => TESTIEN
        };
        VCR_ClinicRepo stubClinicRepo = (VCR_ClinicRepo) new VATEST_StubBuilder(VCR_ClinicRepo.class)
            .mockingMethodCall('getClinicByIEN', Map<String, Object>.class)
            .withParameterValues(args)
            .throwingException(stubLimitException)
            .defineStub();
        Test.startTest();
        VTC_Clinic clinicRecord;
        System.runAs(MSA_USER) {
            VCC_ScheduleAppointmentRequestController.clinicRepo = stubClinicRepo;
            try {
                clinicRecord = (VTC_Clinic) VCC_ScheduleAppointmentRequestController.getClinicByIEN(
                    FACILITY_CODE,
                    TESTIEN
                );
                Assert.fail('Test failed; expected an exception to be thrown.');
            } catch (AuraHandledException auraError) {
                Assert.areEqual(
                    'Timeout Exception',
                    auraError.getMessage(),
                    'Assertion failed; expected error message to be Timeout Exception'
                );
            }
        }
        Test.stopTest();
    }

    /**
     * @description Test method that confirms that all other types of Exceptions will be caught
     */
    @IsTest
    static void unitGetClinicByIENExceptionNegative() {
        TestException stubException = new TestException();
        stubException.setMessage('Invalid Request');
        Map<String, Object> args = new Map<String, Object>{
            'application' => 'VAHC',
            'siteId' => FACILITY_CODE,
            'clinicIEN' => TESTIEN
        };
        VCR_ClinicRepo stubClinicRepo = (VCR_ClinicRepo) new VATEST_StubBuilder(VCR_ClinicRepo.class)
            .mockingMethodCall('getClinicByIEN', Map<String, Object>.class)
            .withParameterValues(args)
            .throwingException(stubException)
            .defineStub();
        Test.startTest();
        VTC_Clinic clinicRecord;
        System.runAs(MSA_USER) {
            VCC_ScheduleAppointmentRequestController.clinicRepo = stubClinicRepo;
            try {
                clinicRecord = (VTC_Clinic) VCC_ScheduleAppointmentRequestController.getClinicByIEN(
                    FACILITY_CODE,
                    TESTIEN
                );
                Assert.fail('Test failed; expected an exception to be thrown.');
            } catch (AuraHandledException auraError) {
                Assert.areEqual(
                    'Invalid Request',
                    auraError.getMessage(),
                    'Assertion failed; expected error message to be Invalid Request'
                );
            }
        }
        Test.stopTest();
    }

    /**
     * @description Test method that confirms that a List of VTC_Clinic records are returned
     * when a Facility Code and Provider IEN are passed to getClinicsByProvider
     */
    @IsTest
    static void unitGetClinicsByProviderPositive() {
        List<VTC_Record> recordList = new List<VTC_Record>();
        VTC_Clinic stubClinicRecord = new VTC_Clinic();
        stubClinicRecord.vtcId = '1';
        recordList.add(stubClinicRecord);

        VCC_ScheduleAppointmentRequestController.TimeSlotParams timeSlotParams = new VCC_ScheduleAppointmentRequestController.TimeSlotParams();
        timeSlotParams.providerIEN = PROVIDER_IEN;
        timeSlotParams.facilityCode = FACILITY_CODE;

        Map<String, Object> requestBodyArgs = new Map<String, Object>{
            'application' => 'VAHC',
            'queryIen' => timeSlotParams.providerIEN,
            'vistaSiteId' => timeSlotParams.facilityCode
        };

        VCR_ClinicRepo stubClinicRepo = (VCR_ClinicRepo) new VATEST_StubBuilder(VCR_ClinicRepo.class)
            .mockingMethodCall('getClinicsByProvider', Map<String, Object>.class)
            .withParameterValues(requestBodyArgs)
            .returning((List<VTC_Record>) recordList)
            .defineStub();

        Test.startTest();
        List<VTC_Record> clinicRecordList;
        System.runAs(MSA_USER) {
            VCC_ScheduleAppointmentRequestController.clinicRepo = stubClinicRepo;
            clinicRecordList = (List<VTC_Record>) VCC_ScheduleAppointmentRequestController.getClinicsByProvider(
                timeSlotParams
            );
        }
        Test.stopTest();

        Assert.isNotNull(clinicRecordList, 'Assertion failed; expected clinicRecordList to not be null');
        Assert.isNotNull(clinicRecordList[0].vtcId, 'Assertion failed; expected vtcId to not be null');
        Assert.areEqual(
            clinicRecordList[0].vtcId,
            recordList[0].vtcId,
            'Assertion failed; expected clinicRecordList and recordList vtcIds to match'
        );
    }
    /**
     * @description Test method that confirms that an exception is thrown when empty properties are passed as the request argument
     */
    @IsTest
    static void unitGetClinicsByProviderEmptyPropertiesNegative() {
        Test.startTest();
        List<VTC_Clinic> clinicRecordList;
        VCC_ScheduleAppointmentRequestController.TimeSlotParams timeSlotParams = new VCC_ScheduleAppointmentRequestController.TimeSlotParams();

        System.runAs(MSA_USER) {
            try {
                clinicRecordList = (List<VTC_Clinic>) VCC_ScheduleAppointmentRequestController.getClinicsByProvider(
                    timeSlotParams
                );
                Assert.fail('Test failed; expected an exception to be thrown.');
            } catch (AuraHandledException auraError) {
                Assert.areEqual(
                    'Invalid Request. Null/Empty request properties detected.',
                    auraError.getMessage(),
                    'Assertion failed; expected error message to be Invalid Request. Null/Empty request properties detected.'
                );
            }
        }
        Test.stopTest();
    }

    /**
     * @description Test method that confirms that a VTC_LimitException is caught
     */
    @IsTest
    static void unitGetClinicsByProviderLimitExceptionNegative() {
        VTC_LimitException stubLimitException = new VTC_LimitException();
        stubLimitException.setMessage('Timeout Exception');

        VCC_ScheduleAppointmentRequestController.TimeSlotParams timeSlotParams = new VCC_ScheduleAppointmentRequestController.TimeSlotParams();
        timeSlotParams.providerIEN = PROVIDER_IEN;
        timeSlotParams.facilityCode = FACILITY_CODE;
        Map<String, Object> requestBodyArgs = new Map<String, Object>{
            'application' => 'VAHC',
            'queryIen' => timeSlotParams.providerIEN,
            'vistaSiteId' => timeSlotParams.facilityCode
        };
        VCR_ClinicRepo stubClinicRepo = (VCR_ClinicRepo) new VATEST_StubBuilder(VCR_ClinicRepo.class)
            .mockingMethodCall('getClinicsByProvider', Map<String, Object>.class)
            .withParameterValues(requestBodyArgs)
            .throwingException(stubLimitException)
            .defineStub();

        Test.startTest();
        List<VTC_Record> clinicRecordList;
        System.runAs(MSA_USER) {
            VCC_ScheduleAppointmentRequestController.clinicRepo = stubClinicRepo;
            try {
                clinicRecordList = (List<VTC_Clinic>) VCC_ScheduleAppointmentRequestController.getClinicsByProvider(
                    timeSlotParams
                );
                Assert.fail('Test failed; expected an exception to be thrown.');
            } catch (AuraHandledException auraError) {
                Assert.areEqual(
                    'Timeout Exception',
                    auraError.getMessage(),
                    'Assertion failed; expected error message to be Timeout Exception'
                );
            }
        }
        Test.stopTest();
    }

    public class TestException extends Exception {
    }
}
