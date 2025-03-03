/**
 * @description Test class for VCR_AppointmentRepo
 * @author Booz Allen Hamilton
 */
@IsTest
public with sharing class VCR_AppointmentRepoTest {
    final static User MSA_USER = new VATEST_UserBuilder()
        .withPermissionSet('VCC_Advanced_Medical_Support_Assistant')
        .withPermissionSet('VAHC_Scheduling_User')
        .withUserProfile('VAVET Base Profile')
        .withStandardData()
        .build(true);
    final static User ADMIN = new VATEST_UserBuilder()
        .withUserProfile('System Administrator')
        .withStandardData()
        .build(true);
    final static DateTime TODAY = DateTime.now();
    final static DateTime YESTERDAY = DateTime.now().addDays(-1);
    final static Id ACCOUNT_ID = VATEST_IdFactory.get('Account');
    private static final String QUERY_STRING = 'SELECT Id FROM VCC_Appointment__c  WHERE LastModifiedDate < :dateTimeHoursAgo';

    /**
     * @description get the VATEST_MockedMethod for VCR_AppointmentRepo updateAppointment
     * @return `VATEST_MockedMethod` for VCR_AppointmentRepo updateAppointment
     */
    public static VATEST_MockedMethod getMockedMethodUpdateAppointment() {
        return new VATEST_MockedMethod(
            new VATEST_MethodSignature(
                'updateAppointment',
                new List<Type>{ String.class, Map<String, Object>.class, String.class }
            )
        );
    }

    /**
     * @description get the VATEST_MockedMethod for VCR_AppointmentRepo upsertAppointmentByAppointmentId
     * @return `VATEST_MockedMethod` for VCR_AppointmentRepo upsertAppointmentByAppointmentId
     */
    public static VATEST_MockedMethod getMockedMethodUpsertAppointmentByAppointmentId() {
        return new VATEST_MockedMethod(
            new VATEST_MethodSignature('upsertAppointmentByAppointmentId', new List<Type>{ VCC_Appointment__c.class })
        );
    }

    /**
     * @description Test method that confirms the VCR_AppointmentRepo instantiates successfully.
     */
    @IsTest
    static void unitTestConstructorPositive() {
        Test.startTest();
        VCR_AppointmentRepo repo;
        System.runAs(MSA_USER) {
            repo = new VCR_AppointmentRepo();
        }
        Test.stopTest();
        Assert.isNotNull(repo, 'Expected constructor to properly instantiate a VCR_AppointmentRepo');
    }

    /**
     * @description Test method that confirms that the getExistingAppointment method returns expected Appointment record.
     */
    @IsTest
    static void funcTestSearchAppointmentsPositive() {
        List<VCC_Appointment__c> apptList;
        System.runAs(MSA_USER) {
            VCC_Appointment__c scheduledAppt1 = (VCC_Appointment__c) VATEST_SObjectFactory.createSObject(
                new VCC_Appointment__c(
                    VCC_Status__c = 'booked',
                    VCC_Appointment_Start__c = TODAY,
                    VCC_Patient__c = ACCOUNT_ID
                )
            );

            List<VCC_Appointment__c> schedAppts = new List<VCC_Appointment__c>();
            schedAppts.add(scheduledAppt1);
            String patientId = ACCOUNT_ID;

            VCR_AppointmentRepo stubAppointmentRepo = (VCR_AppointmentRepo) new VATEST_StubBuilder(
                    VCR_AppointmentRepo.class
                )
                .mockingMethodCall('getExistingAppointments', String.class)
                .withParameterValues(patientId)
                .returning(schedAppts)
                .defineStub();

            Test.startTest();
            VCR_AppointmentRepo repo = stubAppointmentRepo;
            apptList = repo.getExistingAppointments(patientId);
            Test.stopTest();
        }
        Assert.areEqual(
            1,
            apptList.size(),
            'Expected Only 1 Appointment should be returned since only 1 appt record start date was today'
        );
        Assert.areEqual('booked', apptList[0].VCC_Status__c, 'Expected Appointment Record status to be booked');
        Assert.areEqual(
            TODAY.date(),
            apptList[0].VCC_Appointment_Start__c.date(),
            'Expected Appointment Start Date to be today'
        );
    }

    /**
     * @description Test method that confirms that the getExistingAppointment method does not return expected Appointment record.
     */
    @IsTest
    static void funcTestSearchAppointmentsNegative() {
        Test.startTest();
        List<VCC_Appointment__c> apptList;
        System.runAs(MSA_USER) {
            VCR_AppointmentRepo repo = new VCR_AppointmentRepo();
            apptList = repo.getExistingAppointments(ACCOUNT_ID);
        }
        Test.stopTest();
        Assert.areEqual(0, apptList.size(), 'Expected an empty list');
    }

    /**
     * @description Test method that confirms that the mapUpdateAppointmentArgs method generates a map containing parameters.
     */
    @IsTest
    static void unitMapUpdateAppointmentArgsPositive() {
        String mockSiteId = '999';
        Map<String, Object> mockAppointment = new Map<String, Object>{};
        String mockApplicationName = 'SOME_APPLICATION';

        System.runAs(MSA_USER) {
            Test.startTest();
            Map<String, Object> mappedArgs = (new VCR_AppointmentRepo())
                .mapUpdateAppointmentArgs(mockSiteId, mockAppointment, mockApplicationName);
            Assert.isNotNull(mappedArgs, 'Expected non-null result from mapUpdateAppointmentArgs');
            Assert.areEqual(
                mockSiteId,
                mappedArgs.get('siteId'),
                'Expected value in variable "mockSiteId" to be mapped to "siteId"'
            );
            Assert.areEqual(
                mockAppointment,
                mappedArgs.get('appointment'),
                'Expected value in variable "mockAppointment" to be mapped to "appointment"'
            );
            Assert.areEqual(
                mockApplicationName,
                mappedArgs.get('application'),
                'Expected value in variable "mockApplicationName" to be mapped to "application"'
            );
            Test.stopTest();
        }
    }

    /**
     * @description Utility method that generates a stub object that can be used in tests.
     * @param args the map containing the parameters
     * @param returnValue the object to return
     * @return `VTC_PatientService`
     */
    private static VTC_PatientService createPatientService(Map<String, Object> args, Object returnValue) {
        return (VTC_PatientService) new VATEST_StubBuilder(VTC_PatientService.class)
            .mockingMethodCall('call')
            .withParameterTypes(String.class, Map<String, Object>.class)
            .withParameterValues('update_appointment', args)
            .returning(returnValue)
            .defineStub();
    }

    /**
     * @description Test method that updates an appointment record successfully.
     */
    @IsTest
    static void unitUpdateAppointmentPositive() {
        String mockSiteId = '999';
        Map<String, Object> mockAppointment = new Map<String, Object>{};
        String mockApplicationName = 'SOME_APPLICATION';

        VCR_AppointmentRepo.patientService = createPatientService(
            (new VCR_AppointmentRepo()).mapUpdateAppointmentArgs(mockSiteId, mockAppointment, mockApplicationName),
            new VTC_RecordModel()
        );

        System.runAs(MSA_USER) {
            Test.startTest();
            VTC_RecordModel updateAppointmentRecordModel = (new VCR_AppointmentRepo())
                .updateAppointment(mockSiteId, mockAppointment, mockApplicationName);
            Assert.isNotNull(updateAppointmentRecordModel, 'Expected non-null return value from updateAppointment');
            Test.stopTest();
        }
    }

    /**
     * @description Test method that confirms the createAppointment method runs successfully.
     */
    @IsTest
    static void unitCreateAppointmentPositive() {
        VCC_ScheduleAppointmentController.AppointmentParams apptParams = populateAppointmentParams();
        Map<String, Object> createApptParams = VCC_ScheduleAppointmentHelper.generateAppointmentParameters(apptParams);
        VTC_GenericModel model = new VTC_GenericModel();
        model.status = 'ok';

        VTC_PatientService stubPatientService = (VTC_PatientService) new VATEST_StubBuilder(VTC_PatientService.class)
            .mockingMethodCall('call')
            .withParameterTypes(String.class, Map<String, Object>.class)
            .withParameterValues('create_appointment', createApptParams)
            .returning(model)
            .defineStub();

        System.runAs(MSA_USER) {
            Test.startTest();
            VCR_AppointmentRepo.patientService = stubPatientService;
            VTC_GenericModel genericModel = (new VCR_AppointmentRepo()).createAppointment(createApptParams);
            Assert.isNotNull(genericModel, 'Expected non-null return value from createAppointment');
            Assert.areEqual('ok', genericModel.status, 'Expected a status from createAppointment');
            Test.stopTest();
        }
    }

    /**
     * @description Test method that confirms the getAppointment method runs successfully.
     */
    @IsTest
    static void unitGetAppointmentPositive() {
        VCC_ScheduleAppointmentController.AppointmentParams apptParams = populateAppointmentParams();
        Map<String, Object> scheduledApptParams = VCC_ScheduleAppointmentHelper.generateScheduledAppointmentParameters(
            apptParams
        );
        VTC_Appointment schedAppointment = new VTC_Appointment();
        schedAppointment.id = 'A9848100';
        schedAppointment.apptIen = '8100';
        schedAppointment.status = 'booked';

        VTC_RecordModel model = new VTC_RecordModel();
        model.records.add(schedAppointment);

        VTC_PatientService stubPatientService = (VTC_PatientService) new VATEST_StubBuilder(VTC_PatientService.class)
            .mockingMethodCall('call')
            .withParameterTypes(String.class, Map<String, Object>.class)
            .withParameterValues('get_scheduling_appointments', scheduledApptParams)
            .returning(model)
            .defineStub();

        System.runAs(MSA_USER) {
            Test.startTest();
            VCR_AppointmentRepo.patientService = stubPatientService;
            VTC_Appointment scheduledAppointment = (new VCR_AppointmentRepo()).getAppointment(scheduledApptParams);
            Assert.isNotNull(scheduledAppointment, 'Expected non-null return value from getAppointment');
            Assert.areEqual('booked', scheduledAppointment.status, 'Expected a status from getAppointment');
            Test.stopTest();
        }
    }

    /**
     * @description Utility method that populates the AppointmentParams object that can be used in tests.
     * @return `VCC_ScheduleAppointmentController.AppointmentParams`
     */
    private static VCC_ScheduleAppointmentController.AppointmentParams populateAppointmentParams() {
        VCC_ScheduleAppointmentController.AppointmentParams apptParams = new VCC_ScheduleAppointmentController.AppointmentParams();
        apptParams.clinicIEN = '4557';
        apptParams.start = String.valueOf(DateTime.now());
        apptParams.xEnd = String.valueOf(DateTime.now().addHours(1));
        apptParams.apptType = 'Regular';
        apptParams.apptRequestId = 'R9848920';
        apptParams.providerIEN = null;
        apptParams.patientDFN = '550063856';
        apptParams.patientICN = '1015698358V644983';
        apptParams.facilityStationId = '984';
        apptParams.note = 'Test Note';
        apptParams.eligibilityOfVisit = 'Service Connected 50%';
        apptParams.timeZone = 'EASTERN';
        apptParams.duration = 60;

        return apptParams;
    }

    /**
     * @description Positive test case for getStaleApptQueryString().
     * @see VCR_AppointmentRepo.getStaleApptQueryString()
     */
    @IsTest
    static void unitGetStaleApptQueryStringPositive() {
        DateTime dateTimeTwentyFourHoursAgo = Datetime.now().addHours(-24);
        System.runAs(ADMIN) {
            VCR_AppointmentRepo repo;
            String queryString;
            Test.startTest();
            repo = new VCR_AppointmentRepo();
            queryString = repo.getStaleApptQueryString(dateTimeTwentyFourHoursAgo);
            Test.stopTest();
            Assert.areEqual(
                QUERY_STRING,
                queryString,
                'Expected the getStaleApptQueryString() method to return the correct query string for VCC_Appointment__c including a WHERE clause for LastModifiedDate'
            );
        }
    }

    /**
     * @description Negative test case for getQueryLocator() that covers null query scenario.
     * @see VCR_AppointmentRepo.getQueryLocator()
     */
    @IsTest
    static void unitGetQueryLocatorNullQueryNegative() {
        DateTime dateTimeTwentyFourHoursAgo = Datetime.now().addHours(-24);
        Map<String, Object> bindParams = new Map<String, Object>{ 'dateTimeHoursAgo' => dateTimeTwentyFourHoursAgo };
        System.runAs(ADMIN) {
            VCR_AppointmentRepo repo;
            Database.QueryLocator queryLocator;
            Test.startTest();
            repo = new VCR_AppointmentRepo();
            queryLocator = repo.getQueryLocator(null, bindParams);
            Test.stopTest();
            Assert.isNull(
                queryLocator,
                'Expected the getQueryLocator() method to return null when queryString parameter is null but observed a different value for queryLocator.'
            );
        }
    }

    /**
     * @description Negative test case for getQueryLocator() that covers null bindParams scenario.
     * @see VCR_AppointmentRepo.getQueryLocator()
     */
    @IsTest
    static void unitGetQueryLocatorNullBindParamsNegative() {
        DateTime dateTimeTwentyFourHoursAgo = Datetime.now().addHours(-24);
        System.runAs(ADMIN) {
            VCR_AppointmentRepo repo;
            Database.QueryLocator queryLocator;
            Test.startTest();
            repo = new VCR_AppointmentRepo();
            queryLocator = repo.getQueryLocator(repo.getStaleApptQueryString(dateTimeTwentyFourHoursAgo), null);
            Test.stopTest();
            Assert.isNull(
                queryLocator,
                'Expected the getQueryLocator() method to return null when bind parameters are null but observed a different value for queryLocator.'
            );
        }
    }

    /**
     * @description Negative test case for getQueryLocator() that covers scenario if user is not admin.
     * @see VCR_AppointmentRepo.getQueryLocator()
     */
    @IsTest
    static void unitGetQueryLocatorUserIsNotAdminNegative() {
        DateTime dateTimeTwentyFourHoursAgo = Datetime.now().addHours(-24);
        Map<String, Object> bindParams = new Map<String, Object>{ 'dateTimeHoursAgo' => dateTimeTwentyFourHoursAgo };

        System.runAs(MSA_USER) {
            VCR_AppointmentRepo repo;
            Boolean isExceptionThrown = false;
            Database.QueryLocator queryLocator;
            Test.startTest();
            try {
                repo = new VCR_AppointmentRepo();
                queryLocator = repo.getQueryLocator(
                    repo.getStaleApptQueryString(dateTimeTwentyFourHoursAgo),
                    bindParams
                );
            } catch (HandledException handledException) {
                isExceptionThrown = true;
            }
            Test.stopTest();
            Assert.isNull(queryLocator, 'Expected the getQueryLocator() method to return null');
            Assert.isTrue(
                isExceptionThrown,
                'Expected the getQueryLocator() method to throw a HandledException when user is not an Admin but did not observe an exception.'
            );
        }
    }

    /**
     * @description Functional test that confirms correct stale VCC_Appointment__c record is returned
     * and a new record is not returned.
     * @see VCR_AppointmentRepo.getQueryLocator()
     */
    @IsTest
    static void funcGetStaleAppointmentsPositive() {
        List<VCC_Appointment__c> apptList = new List<VCC_Appointment__c>();
        Database.queryLocator locator;
        DateTime dateTimeTwentyFourHoursAgo = Datetime.now().addHours(-24);
        Set<Id> appointmentRecordIds = new Set<Id>();
        List<VCC_Appointment__c> apptsWithCreatedDate;

        System.runAs(ADMIN) {
            String backdatedJSON = '{"CreatedDate":"2023-01-01T15:00:00.000+0000","LastModifiedDate":"2023-01-02T15:00:00.000+0000"}';
            VCC_Appointment__c staleAppt = (VCC_Appointment__c) JSON.deserialize(
                backdatedJSON,
                VCC_Appointment__c.class
            );
            staleAppt.VCC_Status__c = 'booked';
            staleAppt.VCC_Appointment_Start__c = TODAY;
            apptList.add(staleAppt);

            VCC_Appointment__c newAppt = new VCC_Appointment__c();
            newAppt.VCC_Status__c = 'booked';
            newAppt.VCC_Appointment_Start__c = TODAY;
            apptList.add(newAppt);
            insert apptList;

            Test.startTest();
            VCR_AppointmentRepo repo = new VCR_AppointmentRepo();
            locator = repo.getQueryLocator(
                repo.getStaleApptQueryString(dateTimeTwentyFourHoursAgo),
                new Map<String, Object>{ 'dateTimeHoursAgo' => dateTimeTwentyFourHoursAgo }
            );
            Test.stopTest();

            if (locator != null) {
                Database.QueryLocatorIterator iterator = locator.iterator();
                while (iterator.hasNext()) {
                    VCC_Appointment__c appt = (VCC_Appointment__c) iterator.next();
                    appointmentRecordIds.add(appt.Id);
                }
                apptsWithCreatedDate = [
                    SELECT Id, CreatedDate
                    FROM VCC_Appointment__c
                    WHERE Id IN :appointmentRecordIds
                ];
            }
        }
        Assert.areEqual(
            1,
            apptsWithCreatedDate.size(),
            'Expected 1 record to be returned based on LastModifiedDate but observed a different record count.'
        );
        VCC_Appointment__c backdatedAppt = apptsWithCreatedDate[0];
        Assert.isTrue(
            backdatedAppt.CreatedDate < dateTimeTwentyFourHoursAgo,
            'Expected the backdatedAppt record to be the one returned based on LastModifiedDate but observed returned record with a newer CreatedDate.'
        );
    }

    private static List<VCC_Appointment__c> getAppointmentsByAppointmentId(String appointmentId) {
        return [SELECT Id, VCC_Note__c FROM VCC_Appointment__c WHERE VCC_Appointment_Id__c = :appointmentId LIMIT 2];
    }

    /**
     * @description tests that upsertAppointmentByAppointmentId inserts an appointment when no record with matches the VCC_Appointment_Id__c value
     */
    @IsTest
    static void permUpsertAppointmentByAppointmentIdInsertPositive() {
        String appointmentId = 'something';
        Assert.areEqual(
            0,
            getAppointmentsByAppointmentId(appointmentId).size(),
            'Expected zero initial VCC_Appointment__c records as a test pre-condition'
        );
        VCC_Appointment__c newAppointmentRecord = new VCC_Appointment__c(VCC_Appointment_Id__c = appointmentId);
        System.runAs(MSA_USER) {
            Test.startTest();
            (new VCR_AppointmentRepo()).upsertAppointmentByAppointmentId(newAppointmentRecord);
            Test.stopTest();
        }
        Assert.areEqual(
            1,
            getAppointmentsByAppointmentId(appointmentId).size(),
            'Expected VCC_Appointment__c record to be inserted because the appointment Id on the record does not yet exist on a record'
        );
    }

    /**
     * @description tests that upsertAppointmentByAppointmentId updates an existing appointment with matching a VCC_Appointment_Id__c value
     */
    @IsTest
    static void permUpsertAppointmentByAppointmentIdUpdatePositive() {
        String appointmentId = 'something';
        String appointmentNote = 'noteee';
        Assert.areEqual(
            0,
            getAppointmentsByAppointmentId(appointmentId).size(),
            'Expected zero initial VCC_Appointment__c records as a test pre-condition'
        );
        VCC_Appointment__c newAppointmentRecord = new VCC_Appointment__c(VCC_Appointment_Id__c = appointmentId);
        System.runAs(MSA_USER) {
            (new VCR_AppointmentRepo()).upsertAppointmentByAppointmentId(newAppointmentRecord);
        }
        Assert.areEqual(
            1,
            getAppointmentsByAppointmentId(appointmentId).size(),
            'Expected to find one VCC_Appointment__c record after upserting with an appointment ID that doesn\'t yet exist on a record'
        );
        System.runAs(MSA_USER) {
            Test.startTest();
            (new VCR_AppointmentRepo())
                .upsertAppointmentByAppointmentId(
                    new VCC_Appointment__c(VCC_Appointment_Id__c = appointmentId, VCC_Note__c = appointmentNote)
                );
            Test.stopTest();
        }
        List<VCC_Appointment__c> appointmentList = getAppointmentsByAppointmentId(appointmentId);
        Assert.areEqual(
            1,
            appointmentList.size(),
            'Expected no new VCC_Appointment__c records because the record upsert should have updated the record with the matching appointment ID'
        );
        Assert.areEqual(
            appointmentNote,
            appointmentList[0].VCC_Note__c,
            'Expected record field VCC_Note__c to be updated with value from local variable "appointmentNote" because it was added after the initial insert'
        );
    }

    /**
     * @description Test method that confirms the getAppointmentTypes method runs successfully when request type is 'APPT'.
     */
    @IsTest
    static void unitGetAPPTAppointmentTypesPositive() {
        Map<String, Object> args = new Map<String, Object>{ 'application' => 'VAHC', 'vistaSiteId' => '984' };
        VTC_PicklistModel model = new VTC_PicklistModel();
        VTC_PatientService stubPatientService = (VTC_PatientService) new VATEST_StubBuilder(VTC_PatientService.class)
            .mockingMethodCall('call')
            .withParameterTypes(String.class, Map<String, Object>.class)
            .withParameterValues('get_appointment_types', args)
            .returning(model)
            .defineStub();

        System.runAs(MSA_USER) {
            Test.startTest();
            VCR_AppointmentRepo.patientService = stubPatientService;
            VTC_PicklistModel picklistOptions = (new VCR_AppointmentRepo()).getAppointmentTypes('APPT', args);
            Assert.isNotNull(picklistOptions, 'Expected an instance of VTC_PicklistModel');
            Assert.areEqual(new List<VTC_SelectOption>(), model.selectOptions, 'Expected an empty list.');
            Test.stopTest();
        }
    }

    /**
     * @description Test method that confirms the getAppointmentTypes method runs successfully when request type is 'RTC'.
     */
    @IsTest
    static void unitGetRTCAppointmentTypesPositive() {
        Map<String, Object> args = new Map<String, Object>{ 'application' => 'VAHC', 'vistaSiteId' => '984' };
        VTC_PicklistModel model = new VTC_PicklistModel();
        VTC_PatientService stubPatientService = (VTC_PatientService) new VATEST_StubBuilder(VTC_PatientService.class)
            .mockingMethodCall('call')
            .withParameterTypes(String.class, Map<String, Object>.class)
            .withParameterValues('get_appointment_types', args)
            .returning(model)
            .defineStub();

        System.runAs(MSA_USER) {
            Test.startTest();
            VCR_AppointmentRepo.patientService = stubPatientService;
            VTC_PicklistModel picklistOptions = (new VCR_AppointmentRepo()).getAppointmentTypes('RTC', args);
            Assert.isNotNull(picklistOptions, 'Expected an instance of VTC_PicklistModel');
            Assert.areEqual(new List<VTC_SelectOption>(), model.selectOptions, 'Expected an empty list.');
            Test.stopTest();
        }
    }

    /**
     * @description Test method that confirms the getAppointmentTypes method runs successfully when request type is 'PtCSch'.
     */
    @IsTest
    static void unitGetPtCSchAPPTAppointmentTypesPositive() {
        Map<String, Object> args = new Map<String, Object>{ 'application' => 'VAHC', 'vistaSiteId' => '984' };
        VTC_PicklistModel model = new VTC_PicklistModel();
        VTC_PatientService stubPatientService = (VTC_PatientService) new VATEST_StubBuilder(VTC_PatientService.class)
            .mockingMethodCall('call')
            .withParameterTypes(String.class, Map<String, Object>.class)
            .withParameterValues('get_recall_appointment_types', args)
            .returning(model)
            .defineStub();

        System.runAs(MSA_USER) {
            Test.startTest();
            VCR_AppointmentRepo.patientService = stubPatientService;
            VTC_PicklistModel picklistOptions = (new VCR_AppointmentRepo()).getAppointmentTypes('PtCSch', args);
            Assert.isNotNull(picklistOptions, 'Expected an instance of VTC_PicklistModel');
            Assert.areEqual(new List<VTC_SelectOption>(), model.selectOptions, 'Expected an empty list.');
            Test.stopTest();
        }
    }

    /**
     * @description Test method that confirms the getAppointmentTypes method runs throws exception for
     * request type other than APPT, RTC, or PtCSch (in this test using 'Consult').
     */
    @IsTest
    static void unitGetConsultAppointmentTypesNegative() {
        Map<String, Object> args = new Map<String, Object>{ 'application' => 'VAHC', 'vistaSiteId' => '984' };
        Boolean exceptionThrown = false;
        String exceptionMessage;
        String expectedExceptionMessage = 'Unknown Appointment Request Type: Consult';
        VTC_PicklistModel picklistOptions;
        System.runAs(MSA_USER) {
            Test.startTest();
            try {
                picklistOptions = (new VCR_AppointmentRepo()).getAppointmentTypes('Consult', args);
            } catch (IllegalArgumentException illegalParamException) {
                exceptionThrown = true;
                exceptionMessage = illegalParamException.getMessage();
            }
            Assert.isTrue(
                exceptionThrown,
                'Expected custom exception to be thrown for unknown object but did not observe a custom exception.'
            );
            Assert.areEqual(
                expectedExceptionMessage,
                exceptionMessage,
                'Expected a certain error message but observed a different message'
            );
            Assert.isNull(picklistOptions, 'Expected an exception and not an instance of VTC_PicklistModel');
            Test.stopTest();
        }
    }

    /**
     * @description Test method that confirms the getAppointmentTypes method throws exception when appointmentRequestType is null.
     */
    @IsTest
    static void unitGetAppointmentTypesNullParameterNegative() {
        Map<String, Object> args = new Map<String, Object>{ 'application' => 'VAHC', 'vistaSiteId' => '984' };
        Boolean exceptionThrown = false;
        String exceptionMessage;
        String expectedExceptionMessage = 'Required argument missing [appointmentRequestType]';
        VTC_PicklistModel picklistOptions;
        System.runAs(MSA_USER) {
            Test.startTest();
            try {
                String nullAppointmentRequestType;
                picklistOptions = (new VCR_AppointmentRepo()).getAppointmentTypes(nullAppointmentRequestType, args);
            } catch (IllegalArgumentException illegalArgException) {
                exceptionThrown = true;
                exceptionMessage = illegalArgException.getMessage();
            }
            Assert.isTrue(
                exceptionThrown,
                'Expected custom exception to be thrown for unknown object but did not observe a custom exception.'
            );
            Assert.areEqual(
                expectedExceptionMessage,
                exceptionMessage,
                'Expected a certain error message but observed a different message'
            );
            Assert.isNull(picklistOptions, 'Expected an exception and not an instance of VTC_PicklistModel');
            Test.stopTest();
        }
    }
}
