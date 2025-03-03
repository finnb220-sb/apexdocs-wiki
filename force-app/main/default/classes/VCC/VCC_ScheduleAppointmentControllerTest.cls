/*
 * @description Test class for VCC_SchedulingAppointmentController
 * @author Booz Allen Hamilton
 * @see VCC_ScheduleAppointmentController
 */
@IsTest
public with sharing class VCC_ScheduleAppointmentControllerTest {
    private static final String TESTIEN = '4';
    private final static DateTime STARTDATE = DateTime.now();
    private final static DateTime ENDDATE = DateTime.now().addHours(1);

    final static User MSA_USER = new VATEST_UserBuilder()
        .setFields(
            new Map<Schema.SObjectField, Object>{
                User.LastName => 'last',
                User.Email => 'Testuser@test.example.com',
                User.Username => 'Testuser@test.example.com' + Crypto.getRandomInteger(),
                User.CompanyName => 'TEST',
                User.Title => 'title',
                User.Alias => 'alias',
                User.TimeZoneSidKey => UserInfo.getTimeZone().getID(),
                User.EmailEncodingKey => 'UTF-8',
                User.LanguageLocaleKey => 'en_US',
                User.LocaleSidKey => 'en_US'
            }
        )
        .withPermissionSet('VCC_Advanced_Medical_Support_Assistant')
        .withPermissionSet('VAHC_Scheduling_User')
        .withUserProfile('VAVET Base Profile')
        .build(true);

    final static User ADMIN = new VATEST_UserBuilder()
        .withUserProfile('System Administrator')
        .withStandardData()
        .build(true);

    /**
     * @description constructs a stub for VCR_ClinicRepo
     * @param args a `Map<String, Object>` containing the arguments to pass to the stubbed method
     * @param stubClinicRecord the stubbed record to return
     * @return `VCR_ClinicRepo` the constructed stub
     */
    private static VCR_ClinicRepo stubClinicRepo(Map<String, Object> args, VTC_Clinic stubClinicRecord) {
        VCR_ClinicRepo stubClinicRepo = (VCR_ClinicRepo) new VATEST_StubBuilder(VCR_ClinicRepo.class)
            .mockingMethodCall('getClinicByIEN', Map<String, Object>.class)
            .withParameterValues(args)
            .returning((VTC_Record) stubClinicRecord)
            .defineStub();
        return stubClinicRepo;
    }

    /**
     * @description Test method that confirms that the repo properties inject successfully.
     */
    @IsTest
    static void unitDidRepoInitializePositive() {
        Test.startTest();
        System.runAs(MSA_USER) {
            VCC_ScheduleAppointmentController.appointmentRepo = null;
            VCC_ScheduleAppointmentController.self = null;
        }
        Test.stopTest();
        Assert.isNotNull(
            VCC_ScheduleAppointmentController.appointmentRepo,
            'Assertion failed: appointmentRepo is null; Expected a non-null value for VCC_ScheduleAppointmentController.appointmentRepo'
        );
        Assert.isNotNull(
            VCC_ScheduleAppointmentController.self,
            'Assertion failed: self is null; Expected a non-null value for VCC_ScheduleAppointmentController.self'
        );
        Assert.isNotNull(
            VCC_ScheduleAppointmentController.clinicRepo,
            'Assertion failed: clinicRepo is null; Expected a non-null value for VCC_ScheduleAppointmentController.clinicRepo'
        );
    }

    /**
     * @description unitCreateAppointmentPositive test that given parameters to create an Appointment result in a successful insert.
     */
    @IsTest
    static void unitCreateAppointmentPositive() {
        String upsertResultStringAppointment = '{"id": 1' + ',' + '"success": true}';
        Database.UpsertResult resultAppointment = (Database.UpsertResult) JSON.deserialize(
            upsertResultStringAppointment,
            Database.UpsertResult.class
        );
        VCC_ScheduleAppointmentController.AppointmentParams apptParams = populateAppointmentParams();
        String apptParamsString = JSON.serialize(apptParams);

        VCC_Appointment__c appointmentToCreate = createTestAppointment(apptParams);

        VTC_GenericModel model = new VTC_GenericModel();
        model.status = 'ok';
        model.id = 'A9848100';

        Map<String, Object> createApptParams = VCC_ScheduleAppointmentHelper.generateAppointmentParameters(apptParams);

        VCR_AppointmentRepo stubAppointmentRepo = (VCR_AppointmentRepo) new VATEST_StubBuilder(
                VCR_AppointmentRepo.class
            )
            .mockingMethodCall('createAppointment', Map<String, Object>.class)
            .withParameterValues(createApptParams)
            .returning(model)
            .mockingMethodCall('doUpsert', SObject.class)
            .withParameterValues(appointmentToCreate)
            .returning(resultAppointment)
            .defineStub();

        String appointmentId;
        System.runAs(MSA_USER) {
            Test.startTest();
            VCC_ScheduleAppointmentController.appointmentRepo = stubAppointmentRepo;
            appointmentId = VCC_ScheduleAppointmentController.createAppointment(apptParamsString);
            Test.stopTest();
        }
        Assert.areEqual(
            'A9848100',
            appointmentId,
            'Assertion failed; Expected VCC_ScheduleAppointmentController to return a matching appointment Id.'
        );
    }

    /**
     * @description Test method that confirms that the code will return without executing if the createAppointment method is called with a null argument.
     */
    @IsTest
    static void unitCreateAppointmentWithNullArgumentNegative() {
        String appointmentId;
        System.runAs(MSA_USER) {
            Test.startTest();
            appointmentId = VCC_ScheduleAppointmentController.createAppointment(null);
            Test.stopTest();
            Assert.isNull(appointmentId, 'Assertion failed; expected appointmentId to be null.');
        }
    }

    /**
     * @description Test method that confirms that an AuraHandledException is thrown during the createAppointment method when there is a database error.
     */
    @IsTest
    static void unitCreateAppointmentNegative() {
        String upsertResultString = '{"id": 1' + ',' + '"success": false ,"errors" : []}';
        Database.UpsertResult result = (Database.UpsertResult) JSON.deserialize(
            upsertResultString,
            Database.UpsertResult.class
        );

        VCC_ScheduleAppointmentController.AppointmentParams apptParams = populateAppointmentParams();
        Map<String, Object> createApptParams = VCC_ScheduleAppointmentHelper.generateAppointmentParameters(apptParams);

        String apptParamsString = JSON.serialize(apptParams);

        VCC_Appointment__c appointmentToCreate = createTestAppointmentNullId(apptParams);

        VTC_GenericModel model = new VTC_GenericModel();
        model.status = 'error';

        VCR_AppointmentRepo stubAppointmentRepo = (VCR_AppointmentRepo) new VATEST_StubBuilder(
                VCR_AppointmentRepo.class
            )
            .mockingMethodCall('createAppointment', Map<String, Object>.class)
            .withParameterValues(createApptParams)
            .returning(model)
            .mockingMethodCall('doUpsert', SObject.class)
            .withParameterValues(appointmentToCreate)
            .returning(result)
            .defineStub();

        String appointmentId;

        System.runAs(MSA_USER) {
            Test.startTest();
            VCC_ScheduleAppointmentController.appointmentRepo = stubAppointmentRepo;
            try {
                appointmentId = VCC_ScheduleAppointmentController.createAppointment(apptParamsString);
                Assert.isNull(appointmentId, 'Assertion Failed; Expected appointmentId to be null');
            } catch (AuraHandledException error) {
                Assert.areEqual(
                    'Script-thrown exception',
                    error.getMessage(),
                    'Assertion failed; expected Script-thrown exception for the error message.'
                );
            }
            Test.stopTest();
        }
    }

    /**
     * @description Test method that confirms that the upsertAppintment method will update a VCC_Appointment__c record successfully.
     */
    @IsTest
    static void unitUpsertAppointmentPositive() {
        String upsertResultString = '{"id": 1' + ',' + '"success": true}';
        Database.UpsertResult result = (Database.UpsertResult) JSON.deserialize(
            upsertResultString,
            Database.UpsertResult.class
        );
        Database.UpsertResult upsertResult;

        System.runAs(MSA_USER) {
            VCC_ScheduleAppointmentController.AppointmentParams apptParams = populateAppointmentParams();
            apptParams.apptId = 'A9848100';

            VCC_Appointment__c appointmentToCreate = createTestAppointment(apptParams);

            VCR_AppointmentRepo stubAppointmentRepo = (VCR_AppointmentRepo) new VATEST_StubBuilder(
                    VCR_AppointmentRepo.class
                )
                .mockingMethodCall('doUpsert', SObject.class)
                .withParameterValues(appointmentToCreate)
                .returning(result)
                .defineStub();

            Test.startTest();

            VCC_ScheduleAppointmentController.appointmentRepo = stubAppointmentRepo;
            VCC_ScheduleAppointmentController controller = new VCC_ScheduleAppointmentController();
            upsertResult = controller.upsertAppointment(apptParams);
            Test.stopTest();
        }
        Assert.areEqual(
            true,
            upsertResult.success,
            'Assertion failed; Expected VCC_ScheduleAppointmentController.upsertAppointment to insert the Appointment successfully.'
        );
    }

    /**
     * @description Test Class for testing update of Appt Request
     */
    @IsTest
    static void unitCloseApptRequestPositive() {
        String upsertResultString = '{"id": 1' + ',' + '"success": true}';
        Database.UpsertResult apptRequestResult = (Database.UpsertResult) JSON.deserialize(
            upsertResultString,
            Database.UpsertResult.class
        );
        VCC_ScheduleAppointmentController.AppointmentParams apptParams = new VCC_ScheduleAppointmentController.AppointmentParams();
        apptParams.apptRequestId = VATEST_IdFactory.get('VCC_AppointmentRequest__c');
        String apptParamsString = JSON.serialize(apptParams);

        VCC_AppointmentRequest__c apptRequestToUpdate = (VCC_AppointmentRequest__c) VATEST_SObjectFactory.createSObject(
            new VCC_AppointmentRequest__c(
                VCC_Current_Status__c = 'Closed',
                VCC_Disposition_Date__c = Date.today(),
                Id = apptParams.apptRequestId
            ),
            null,
            false,
            false
        );

        VCR_AppointmentRequestRepo stubAppointmentRequestRepo = (VCR_AppointmentRequestRepo) new VATEST_StubBuilder(
                VCR_AppointmentRequestRepo.class
            )
            .mockingMethodCall('doUpsert', sObject.class)
            .withParameterValues(apptRequestToUpdate)
            .returning(apptRequestResult)
            .defineStub();

        Boolean appointmentRequestUpdateSuccessful;
        System.runAs(MSA_USER) {
            Test.startTest();
            VCC_ScheduleAppointmentController.appointmentRequestRepo = stubAppointmentRequestRepo;
            appointmentRequestUpdateSuccessful = VCC_ScheduleAppointmentController.closeApptRequest(apptParamsString);
            Test.stopTest();
        }
        Assert.areEqual(
            true,
            appointmentRequestUpdateSuccessful,
            'Assertion Failed; Expected VCC_ScheduleAppointmentController to return true since appointment parameters .'
        );
    }

    /**
     * @description Test method that confirms that the code will return without executing if the createAppointment method is called with a null argument.
     */
    @IsTest
    static void unitCloseApptRequestNullArgumentNegative() {
        Boolean apptRequestUpdateSuccessful;
        System.runAs(MSA_USER) {
            Test.startTest();
            apptRequestUpdateSuccessful = VCC_ScheduleAppointmentController.closeApptRequest(null);
            Test.stopTest();
            Assert.areEqual(
                false,
                apptRequestUpdateSuccessful,
                'Assertion Failed; expected apptRequestUpdateSuccessful to be false since appointment parameters are null.'
            );
        }
    }

    /**
     * @description Test Class for testing update of Appt Request
     */
    @IsTest
    static void unitCloseApptRequestNegative() {
        Id apptRequestId = VATEST_IdFactory.get('VCC_AppointmentRequest__c');
        String upsertResultString = '{"id": 1' + ',' + '"success": false ,"errors" : []}';
        Database.UpsertResult apptRequestResult = (Database.UpsertResult) JSON.deserialize(
            upsertResultString,
            Database.UpsertResult.class
        );
        VCC_ScheduleAppointmentController.AppointmentParams apptParams = new VCC_ScheduleAppointmentController.AppointmentParams();
        apptParams.apptRequestId = apptRequestId;
        String apptParamsString = JSON.serialize(apptParams);

        VCC_AppointmentRequest__c apptRequestToUpdate = (VCC_AppointmentRequest__c) VATEST_SObjectFactory.createSObject(
            new VCC_AppointmentRequest__c(
                VCC_Current_Status__c = 'Closed',
                VCC_Disposition_Date__c = Date.today(),
                Id = apptParams.apptRequestId
            ),
            null,
            false,
            false
        );

        VCR_AppointmentRequestRepo stubAppointmentRequestRepo = (VCR_AppointmentRequestRepo) new VATEST_StubBuilder(
                VCR_AppointmentRequestRepo.class
            )
            .mockingMethodCall('doUpsert', sObject.class)
            .withParameterValues(apptRequestToUpdate)
            .returning(apptRequestResult)
            .defineStub();

        Boolean appointmentRequestUpdateSuccessful;
        System.runAs(MSA_USER) {
            Test.startTest();
            VCC_ScheduleAppointmentController.appointmentRequestRepo = stubAppointmentRequestRepo;
            appointmentRequestUpdateSuccessful = VCC_ScheduleAppointmentController.closeApptRequest(apptParamsString);
            Test.stopTest();
        }
        Assert.areEqual(
            false,
            appointmentRequestUpdateSuccessful,
            'Assertion Failed; Expected VCC_ScheduleAppointmentController to return false since update did not occur.'
        );
    }

    /**
     * @description Test method that confirms that the upsertAppintment method will update a VCC_AppointmentRequest__c record successfully.
     */
    @IsTest
    static void unitUpsertApptRequestPositive() {
        String upsertResultString = '{"id": 1' + ',' + '"success": true, "errors" : []}';
        Database.UpsertResult result = (Database.UpsertResult) JSON.deserialize(
            upsertResultString,
            Database.UpsertResult.class
        );
        Database.UpsertResult upsertResult;

        System.runAs(MSA_USER) {
            VCC_ScheduleAppointmentController.AppointmentParams apptParams = new VCC_ScheduleAppointmentController.AppointmentParams();
            apptParams.apptRequestId = VATEST_IdFactory.get('VCC_AppointmentRequest__c');

            VCC_AppointmentRequest__c apptRequestToUpdate = (VCC_AppointmentRequest__c) VATEST_SObjectFactory.createSObject(
                new VCC_AppointmentRequest__c(
                    VCC_Current_Status__c = 'Closed',
                    VCC_Disposition_Date__c = Date.today(),
                    Id = apptParams.apptRequestId
                ),
                null,
                false,
                false
            );

            VCR_AppointmentRequestRepo stubAppointmentRequestRepo = (VCR_AppointmentRequestRepo) new VATEST_StubBuilder(
                    VCR_AppointmentRequestRepo.class
                )
                .mockingMethodCall('doUpsert', sObject.class)
                .withParameterValues(apptRequestToUpdate)
                .returning(result)
                .defineStub();

            Test.startTest();
            VCC_ScheduleAppointmentController.appointmentRequestRepo = stubAppointmentRequestRepo;
            VCC_ScheduleAppointmentController controller = new VCC_ScheduleAppointmentController();
            upsertResult = controller.upsertApptRequest(apptParams);
            Test.stopTest();
        }
        Assert.areEqual(
            true,
            upsertResult.success,
            'Assertion Failed; Expected VCC_ScheduleAppointmentController.upsertApptRequest to update the Appt Request successfully.'
        );
    }

    /**
     * @description Test method that confirms that the upsertAppintment method will not update a VCC_AppointmentRequest__c record successfully.
     */
    @IsTest
    static void unitUpsertApptRequestNegative() {
        String upsertResultString = '{"id": 1' + ',' + '"success": false, "errors" : []}';
        Database.UpsertResult result = (Database.UpsertResult) JSON.deserialize(
            upsertResultString,
            Database.UpsertResult.class
        );
        Database.UpsertResult upsertResult;

        System.runAs(MSA_USER) {
            Test.startTest();
            try {
                VCC_ScheduleAppointmentController.AppointmentParams apptParams = new VCC_ScheduleAppointmentController.AppointmentParams();
                apptParams.apptRequestId = VATEST_IdFactory.get('VCC_AppointmentRequest__c');

                VCC_AppointmentRequest__c apptRequestToUpdate = (VCC_AppointmentRequest__c) VATEST_SObjectFactory.createSObject(
                    new VCC_AppointmentRequest__c(
                        VCC_Current_Status__c = 'Closed',
                        VCC_Disposition_Date__c = Date.valueOf('1/1/1900'),
                        Id = apptParams.apptRequestId
                    ),
                    null,
                    false,
                    false
                );

                VCR_AppointmentRequestRepo stubAppointmentRequestRepo = (VCR_AppointmentRequestRepo) new VATEST_StubBuilder(
                        VCR_AppointmentRequestRepo.class
                    )
                    .mockingMethodCall('doUpsert', sObject.class)
                    .withParameterValues(apptRequestToUpdate)
                    .returning(result)
                    .defineStub();

                VCC_ScheduleAppointmentController.appointmentRequestRepo = stubAppointmentRequestRepo;
                VCC_ScheduleAppointmentController controller = new VCC_ScheduleAppointmentController();
                upsertResult = controller.upsertApptRequest(apptParams);
                Assert.fail('Exception expected');
            } catch (Exception error) {
                Assert.isNotNull(error.getMessage(), 'Assertion failed; expected Invalid date exception.');
                Assert.areEqual(
                    'Invalid date: 1/1/1900',
                    error.getMessage(),
                    'Assertion failed; exception message does not match.'
                );
            }
            Test.stopTest();
        }

    }

    /**
     * @description Test method that confirms that the Integration Procedure throws an exception if an error is returned.
     */
    @IsTest
    static void funcCallIntegrationProcedureNegative() {
        //Arrange
        Id personAccountRecordTypeId = Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
            .getRecordTypeInfosByDeveloperName()
            .get('PersonAccount')
            .getRecordTypeId();
        Id adminCaseRecordTypeId = Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
            .getRecordTypeInfosByDeveloperName()
            .get('VCC_Administrative')
            .getRecordTypeId();
        System.runAs(MSA_USER) {
            Account patient = (Account) VATEST_SObjectFactory.createSObject(
                new Account(FirstName = 'Billy', LastName = 'Test', RecordTypeId = personAccountRecordTypeId),
                null,
                false,
                true
            );
            Case caseToUpdate = (Case) VATEST_SObjectFactory.createSObject(
                new Case(
                    Subject = 'Administrative and Scheduling',
                    ContactId = patient.PersonContactId,
                    AccountId = patient.Id,
                    Status = 'Open',
                    RecordTypeId = adminCaseRecordTypeId
                ),
                null,
                false,
                true
            );
            Task testTask = (Task) VATEST_SObjectFactory.createSObject(
                new Task(
                    Subject = 'Call',
                    WhatId = caseToUpdate.Id,
                    WhoId = patient.PersonContactId,
                    OwnerId = MSA_USER.Id
                ),
                null,
                false,
                true
            );
            VCC_ScheduleAppointmentController.AppointmentParams apptParams = new VCC_ScheduleAppointmentController.AppointmentParams();
            //Set inputs for Integration Procedure
            apptParams.clinicName = 'Test Clinic';
            apptParams.salesforcePatientId = patient.Id;
            apptParams.salesforceContactId = patient.PersonContactId;
            apptParams.clinicStopCodeNumber = '1234';

            //Act
            Test.startTest();
            try {
                VCC_ScheduleAppointmentController.callIntegrationProcedure(apptParams);
            } catch (AuraHandledException error) {
                //Assert
                Assert.areEqual(
                    'Script-thrown exception',
                    error.getMessage(),
                    'Assertion failed; expected an error message that matches: Script-thrown exception'
                );
            }
            Test.stopTest();
        }
    }

    /**
     * @description Utility method that populates the AppointmentParams object that can be used in tests.
     * @return `VCC_ScheduleAppointmentController.AppointmentParams`
     */
    private static VCC_ScheduleAppointmentController.AppointmentParams populateAppointmentParams() {
        VCC_ScheduleAppointmentController.AppointmentParams apptParams = new VCC_ScheduleAppointmentController.AppointmentParams();
        apptParams.clinicIEN = TESTIEN;
        apptParams.clinicName = 'Test Clinic';
        apptParams.clinicStopCodeNumber = '323';
        apptParams.start = String.valueOf(STARTDATE);
        apptParams.xEnd = String.valueOf(ENDDATE);
        apptParams.apptType = 'Regular';
        apptParams.apptRequestId = 'R9848920';
        apptParams.apptRequestVistaId = 'R9848920';
        apptParams.providerIEN = null;
        apptParams.providerName = 'Test Provider';
        apptParams.patientDFN = '550063856';
        apptParams.patientICN = '1015698358V644983';
        apptParams.facilityStationId = '984';
        apptParams.facilityStationName = 'DAYTSHR';
        apptParams.note = 'Test Note';
        apptParams.eligibilityOfVisit = 'Service Connected 50%';
        apptParams.timeZone = 'EASTERN';
        apptParams.duration = 60;
        apptParams.apptId = null;
        apptParams.salesforcePatientId = null;
        return apptParams;
    }

    /**
     * @description given the access result is ALLOWED this test ensures the return value is "true"
     */
    @IsTest
    static void unitRunningUserCanScheduleIntoClinicTruePositive() {
        String mockSiteId = '123';
        String mockClinicIen = '456';
        String mockUserId = MSA_USER.Id;
        IAM_SSOi_Vista_Instance_to_User_DUZ__c mockUserDuz = new IAM_SSOi_Vista_Instance_to_User_DUZ__c();
        VTC_Clinic mockReturnClinic = new VTC_Clinic();
        mockReturnClinic.prohibitAccess = false;

        VCC_AppointmentSchedulingAccessCheckTest.doStubbing(mockUserId, mockUserDuz);
        VCR_ClinicRepo clinicRepoStub = stubClinicRepo(
            new Map<String, Object>{
                VCC_AppointmentSchedulingAccessCheck.SITE_ID_KEY => mockSiteId,
                VCC_AppointmentSchedulingAccessCheck.CLINIC_IEN_KEY => mockClinicIen,
                VCC_AppointmentSchedulingAccessCheck.APPLICATION_KEY => 'VAHC'
            },
            mockReturnClinic
        );
        Boolean result;
        System.runAs(MSA_USER) {
            Test.startTest();
            VCC_ScheduleAppointmentController.clinicRepo = clinicRepoStub;
            result = VCC_ScheduleAppointmentController.runningUserCanScheduleIntoClinic(mockClinicIen, mockSiteId);
            Test.stopTest();
        }

        Assert.isTrue(
            result,
            'Expected "true" because VCC_AppointmentSchedulingAccessCheck.getResult returned ALLOWED'
        );
    }

    /**
     * @description given the access result is ALLOWED this test ensures the return value is "false"
     */
    @IsTest
    static void unitRunningUserCanScheduleIntoClinicFalsePositive() {
        String mockSiteId = '123';
        String mockClinicIen = '456';
        String mockUserId = MSA_USER.Id;
        IAM_SSOi_Vista_Instance_to_User_DUZ__c mockUserDuz = new IAM_SSOi_Vista_Instance_to_User_DUZ__c();
        VTC_Clinic mockReturnClinic = new VTC_Clinic();
        mockReturnClinic.prohibitAccess = true;
        VCR_ClinicRepo clinicRepoStub = stubClinicRepo(
            new Map<String, Object>{
                VCC_AppointmentSchedulingAccessCheck.SITE_ID_KEY => mockSiteId,
                VCC_AppointmentSchedulingAccessCheck.CLINIC_IEN_KEY => mockClinicIen,
                VCC_AppointmentSchedulingAccessCheck.APPLICATION_KEY => 'VAHC'
            },
            mockReturnClinic
        );
        VCC_AppointmentSchedulingAccessCheckTest.doStubbing(mockUserId, mockUserDuz);

        Boolean result;
        System.runAs(MSA_USER) {
            Test.startTest();
            VCC_ScheduleAppointmentController.clinicRepo = clinicRepoStub;
            result = VCC_ScheduleAppointmentController.runningUserCanScheduleIntoClinic(mockClinicIen, mockSiteId);
            Test.stopTest();
        }

        Assert.isFalse(
            result,
            'Expected "false" because VCC_AppointmentSchedulingAccessCheck.getResult returned DENIED'
        );
    }
    private static VCC_Appointment__c createTestAppointment(
        VCC_ScheduleAppointmentController.AppointmentParams apptParams
    ) {
        // Return a new VCC_Appointment__c instance with the specified parameters
        return (VCC_Appointment__c) VATEST_SObjectFactory.createSObject(
            new VCC_Appointment__c(
                VCC_Appointment_Start__c = Datetime.valueOfGmt(apptParams.start.replace('T', ' ')),
                VCC_Appointment_End__c = Datetime.valueOfGmt(apptParams.xEnd.replace('T', ' ')),
                VCC_Appointment_Type__c = 'Regular',
                VCC_Patient__c = null,
                VCC_Note__c = 'Test Note',
                VCC_Eligibility_of_Visit__c = 'Service Connected 50%',
                VCC_Time_Zone__c = 'EASTERN',
                VCC_Duration__c = 60,
                VCC_Clinic_Name__c = apptParams.clinicName,
                VCC_Clinic_IEN__c = apptParams.clinicIEN,
                VCC_Clinic_Stop_Code_Number__c = apptParams.clinicStopCodeNumber,
                VCC_Facility_Station_Id__c = apptParams.facilityStationId,
                VCC_Facility_Name__c = apptParams.facilityStationName,
                VCC_Status__c = 'booked',
                VCC_Appointment_Id__c = 'A9848100',
                VCC_Appointment_Request_Id__c = 'R9848920',
                VCC_Provider_Name__c = 'Test Provider'
            ),
            null,
            false,
            false
        );
    }

    private static VCC_Appointment__c createTestAppointmentNullId(
        VCC_ScheduleAppointmentController.AppointmentParams apptParams
    ) {
        // Return a new VCC_Appointment__c instance with the specified parameters
        return (VCC_Appointment__c) VATEST_SObjectFactory.createSObject(
            new VCC_Appointment__c(
                VCC_Appointment_Start__c = Datetime.valueOfGmt(apptParams.start.replace('T', ' ')),
                VCC_Appointment_End__c = Datetime.valueOfGmt(apptParams.xEnd.replace('T', ' ')),
                VCC_Appointment_Type__c = 'Regular',
                VCC_Patient__c = null,
                VCC_Note__c = 'Test Note',
                VCC_Eligibility_of_Visit__c = 'Service Connected 50%',
                VCC_Time_Zone__c = 'EASTERN',
                VCC_Duration__c = 60,
                VCC_Clinic_Name__c = apptParams.clinicName,
                VCC_Clinic_IEN__c = apptParams.clinicIEN,
                VCC_Clinic_Stop_Code_Number__c = apptParams.clinicStopCodeNumber,
                VCC_Facility_Station_Id__c = apptParams.facilityStationId,
                VCC_Facility_Name__c = apptParams.facilityStationName,
                VCC_Status__c = 'booked',
                VCC_Appointment_Id__c = null,
                VCC_Appointment_Request_Id__c = 'R9848920',
                VCC_Provider_Name__c = 'Test Provider'
            ),
            null,
            false,
            false
        );
    }

    /**
     * @description unitGetAPPTAppointmentTypesPositive tests given a successful response from VTC for APPT Request Type,
     * an array of picklist options are returned.
     */
    @IsTest
    static void unitGetAPPTAppointmentTypesPositive() {
        String appointmentRequestType = 'APPT';
        VTC_PicklistModel model = new VTC_PicklistModel();
        List<VTC_SelectOption> optionsArray = new List<VTC_SelectOption>();
        VTC_SelectOption option = new VTC_SelectOption('REGULAR', 'REGULAR');
        optionsArray.add(option);
        model.selectOptions = optionsArray;
        Map<String, Object> args = new Map<String, Object>{ 'application' => 'VAHC', 'vistaSiteId' => '984' };
        VCR_AppointmentRepo stubAppointmentRepo = (VCR_AppointmentRepo) new VATEST_StubBuilder(
                VCR_AppointmentRepo.class
            )
            .mockingMethodCall('getAppointmentTypes', String.class, Map<String, Object>.class)
            .withParameterValues(appointmentRequestType, args)
            .returning(model)
            .defineStub();

        System.runAs(MSA_USER) {
            Test.startTest();
            VCC_ScheduleAppointmentController.appointmentRepo = stubAppointmentRepo;
            List<VTC_SelectOption> options = VCC_ScheduleAppointmentController.getAppointmentTypes('APPT', '984');
            Test.stopTest();
            Assert.areEqual(
                'REGULAR',
                options[0].label,
                'Expected label property of the first element in the options array to be "REGULAR"'
            );
        }
    }

    /**
     * @description unitGetPtCSchAppointmentTypesPositive tests given a successful response from VTC for PtCSch Request Type,
     * an array of picklist options are returned.
     */
    @IsTest
    static void unitGetPtCSchAppointmentTypesPositive() {
        String appointmentRequestType = 'PtCSch';
        VTC_PicklistModel model = new VTC_PicklistModel();
        List<VTC_SelectOption> optionsArray = new List<VTC_SelectOption>();
        VTC_SelectOption option = new VTC_SelectOption('FOLLOW-UP', 'FOLLOW-UP');
        optionsArray.add(option);
        model.selectOptions = optionsArray;
        Map<String, Object> args = new Map<String, Object>{ 'application' => 'VAHC', 'vistaSiteId' => '984' };
        VCR_AppointmentRepo stubAppointmentRepo = (VCR_AppointmentRepo) new VATEST_StubBuilder(
                VCR_AppointmentRepo.class
            )
            .mockingMethodCall('getAppointmentTypes', String.class, Map<String, Object>.class)
            .withParameterValues(appointmentRequestType, args)
            .returning(model)
            .defineStub();

        System.runAs(MSA_USER) {
            Test.startTest();
            VCC_ScheduleAppointmentController.appointmentRepo = stubAppointmentRepo;
            List<VTC_SelectOption> options = VCC_ScheduleAppointmentController.getAppointmentTypes('PtCSch', '984');
            Test.stopTest();
            Assert.areEqual(
                'FOLLOW-UP',
                options[0].label,
                'Expected label property of the first element in the options array to be "FOLLOW-UP"'
            );
        }
    }

    /**
     * @description unitGetAppointmentTypesNegative tests given an exception is thrown while calling VTC, the exceptions is caught and handled.
     */
    @IsTest
    static void unitGetAppointmentTypesNegative() {
        VTC_LimitException stubLimitException = new VTC_LimitException();
        Map<String, Object> args = new Map<String, Object>{ 'application' => 'VAHC', 'vistaSiteId' => '984' };
        VCR_AppointmentRepo stubAppointmentRepo = (VCR_AppointmentRepo) new VATEST_StubBuilder(
                VCR_AppointmentRepo.class
            )
            .mockingMethodCall('getAppointmentTypes', Map<String, Object>.class)
            .withParameterValues(args)
            .throwingException(stubLimitException)
            .defineStub();

        System.runAs(MSA_USER) {
            Test.startTest();
            try {
                VCC_ScheduleAppointmentController.appointmentRepo = stubAppointmentRepo;
                List<VTC_SelectOption> options = VCC_ScheduleAppointmentController.getAppointmentTypes('APPT', '984');
                Assert.fail(
                    'Expected an exception to be thrown. Instead received successful output of: ' +
                        '\n' +
                        JSON.serializePretty(options)
                );
            } catch (AuraHandledException auraError) {
                Assert.isInstanceOfType(
                    auraError,
                    AuraHandledException.class,
                    'Expected an AuraHandledException to be thrown'
                );
            }
            Test.stopTest();
        }
    }

    /**
     * @description unitGetAppointmentTypesIllegalArgumentVistaNegative tests given an exception is thrown while calling VTC, the exceptions is caught and handled.
     * This method tests when the vistaSiteId parameter is blank.
     */
    @IsTest
    static void unitGetAppointmentTypesIllegalArgumentVistaNegative() {
        System.runAs(MSA_USER) {
            Test.startTest();
            try {
                List<VTC_SelectOption> options = VCC_ScheduleAppointmentController.getAppointmentTypes('APPT', '');
                Assert.fail(
                    'Expected an exception to be thrown. Instead received successful output of: ' +
                        '\n' +
                        JSON.serializePretty(options)
                );
            } catch (IllegalArgumentException error) {
                Assert.isInstanceOfType(
                    error,
                    IllegalArgumentException.class,
                    'Expected an IllegalArgumentException to be thrown'
                );
            }
            Test.stopTest();
        }
    }

    /**
     * @description unitGetAppointmentTypesIllegalArgumentTypeNegative tests given an exception is thrown while calling VTC, the exceptions is caught and handled.
     * This method tests when the appointmentRequestType parameter is blank.
     */
    @IsTest
    static void unitGetAppointmentTypesIllegalArgumentTypeNegative() {
        System.runAs(MSA_USER) {
            Test.startTest();
            try {
                List<VTC_SelectOption> options = VCC_ScheduleAppointmentController.getAppointmentTypes('', '984');
                Assert.fail(
                    'Expected an exception to be thrown. Instead received successful output of: ' +
                        '\n' +
                        JSON.serializePretty(options)
                );
            } catch (IllegalArgumentException error) {
                Assert.isInstanceOfType(
                    error,
                    IllegalArgumentException.class,
                    'Expected an IllegalArgumentException to be thrown'
                );
            }
            Test.stopTest();
        }
    }
}
