/**
 * @description Test class for VCC_SchedulingOmniConnector
 * @author Booz Allen Hamilton
 * @see `VCC_SchedulingOmniConnector`
 */
@IsTest
private with sharing class VCC_SchedulingOmniConnectorTest {
    /**
     * @description memoized standard user
     */
    private static User standardUser {
        get {
            return standardUser = standardUser ??
                new VATEST_UserBuilder().withUserProfile('Standard User').withStandardData().build(true);
        }
        set;
    }

    /**
     * @description memoized msaUser
     */
    private static User msaUser {
        get {
            return msaUser = msaUser ??
                new VATEST_UserBuilder()
                    .withPermissionSet('VCC_Advanced_Medical_Support_Assistant')
                    .withPermissionSet('VAHC_Scheduling_User')
                    .withUserProfile('VAVET Base Profile')
                    .withStandardData()
                    .build(true);
        }
        set;
    }

    private static List<VCC_Appointment__c> getAppointmentsByAppointmentId(String appointmentId) {
        return [
            SELECT Id, VCC_Note__c, VCC_Appointment_Id__c
            FROM VCC_Appointment__c
            WHERE VCC_Appointment_Id__c = :appointmentId
            LIMIT 2
        ];
    }

    /**
     * @description tests that the property getter on VCC_SchedulingOmniConnector.appointmentRepo does not construct
     * a new instance of VCR_AppointmentRepo if one exists
     */
    @IsTest
    static void unitAppointmentRepoPropertyPositive() {
        System.runAs(msaUser) {
            Test.startTest();
            VCR_AppointmentRepo firstAppointmentRepo = VCC_SchedulingOmniConnector.appointmentRepo;
            VCR_AppointmentRepo secondAppointmentRepo = VCC_SchedulingOmniConnector.appointmentRepo;
            Assert.isTrue(
                firstAppointmentRepo === secondAppointmentRepo,
                'Expected both variables to reference the same appointmentRepo because the getter should return the previously constructed repo'
            );
            Test.stopTest();
        }
    }

    /**
     * @description tests that an exception is thrown when a null or invalid methodName is given
     */
    @IsTest
    static void unitInvokeMethodInvalidMethodNegative() {
        VCC_SchedulingOmniConnector schedulingOmniConnector = new VCC_SchedulingOmniConnector();
        Boolean result;
        System.runAs(msaUser) {
            Test.startTest();
            result = (Boolean) schedulingOmniConnector.call(
                new VCC_OmniRemoteAction.ArgTuple(
                    'rstlne',
                    new Map<String, Object>{
                        'input' => new Map<String, Object>(),
                        'output' => new Map<String, Object>(),
                        'options' => new Map<String, Object>()
                    }
                )
            );
            Test.stopTest();
        }
        Assert.isFalse(
            result,
            'Expected VCC_SchedulingOmniConnector.call() to return false given the method name does not match any switch conditions'
        );
    }

    /**
     * @description helper method to construct an ArgTuple with field/value pairs passed into updateAppointmentWithNlt
     * @param siteId a `String` indicating the site the appointment is scheduled at
     * @param appointment the appointment
     * @return `VCC_OmniRemoteAction.ArgTuple`
     */
    static VCC_OmniRemoteAction.ArgTuple createUpdateAppointmentWithNltArgTuple(
        String siteId,
        Map<String, Object> appointment
    ) {
        return new VCC_OmniRemoteAction.ArgTuple(
            'updateAppointmentWithNLT',
            new Map<String, Object>{
                'input' => new Map<String, Object>{
                    VCC_SchedulingOmniConnector.APPOINTMENT_KEY => appointment,
                    VCC_SchedulingOmniConnector.SITE_ID_KEY => siteId
                }, // input
                'output' => new Map<String, Object>{}, // output
                'options' => new Map<String, Object>{} // options
            }
        );
    }

    /**
     * @description stubs VCR_AppointmentRepo at VCC_SchedulingOmniConnector.appointmentRepo
     * @param mockedMethods a `List<VATEST_MockedMethod>` to add to the stub
     * @return `VATEST_Stub` the constructed stub
     */
    private static VATEST_Stub stubAppointmentRepo(List<VATEST_MockedMethod> mockedMethods) {
        VATEST_Stub appointmentRepoStub = new VATEST_Stub(VCR_AppointmentRepo.class, mockedMethods);
        VCC_SchedulingOmniConnector.appointmentRepo = (VCR_AppointmentRepo) appointmentRepoStub.createStub();
        return appointmentRepoStub;
    }

    /**
     * @description this test is a fully stubbed positive test for 'updateAppointmentWithNLT'.
     * After setup and test execution, it asserts that the output map contains "updatedAppointment" and that
     * updatedAppointment equals the mock return value
     */
    @IsTest
    static void unitUpdateAppointmentWithNltAllStubbedPositive() {
        // general test setup for VCC_SchedulingOmniConnector.updateAppointmentWithNLT
        String siteId = '123';
        String noteField = 'test note';
        String appointmentId = 'test id';
        Map<String, Object> appointment = new Map<String, Object>{
            VCC_SchedulingOmniConnector.NOTE_KEY => noteField,
            VCC_SchedulingOmniConnector.ID_KEY => appointmentId
        };
        Map<String, Object> appointmentMapWithNlt = (new VCC_SchedulingOmniConnector())
            .createNewAppointmentMapWithNlt(appointment);

        // VCR_AppointmentRepo.updateAppointment stub/mock set-up
        VTC_CHROAppointmentModel updateAppointmentReturnValue = new VTC_CHROAppointmentModel();
        VTC_Appointment mockAppointment = new VTC_Appointment();
        mockAppointment.note = (String) appointmentMapWithNlt.get(VCC_SchedulingOmniConnector.NOTE_KEY);
        mockAppointment.id = (String) appointmentMapWithNlt.get(VCC_SchedulingOmniConnector.ID_KEY);
        updateAppointmentReturnValue.records.add(mockAppointment);
        VATEST_MockedMethod mockedUpdateAppointment = VCR_AppointmentRepoTest.getMockedMethodUpdateAppointment()
            .withParameterValues(new List<Object>{ siteId, appointmentMapWithNlt, 'VAHC' })
            .returning(updateAppointmentReturnValue);

        // VCR_AppointmentRepo.upsertAppointmentByAppointmentId stub/mock set-up
        VATEST_MockedMethod mockedUpsertAppointmentByAppointmentId = VCR_AppointmentRepoTest.getMockedMethodUpsertAppointmentByAppointmentId()
            .withParameterValues(
                new List<Object>{
                    new VCC_Appointment__c(
                        VCC_Appointment_Id__c = (String) appointmentMapWithNlt.get(VCC_SchedulingOmniConnector.ID_KEY),
                        VCC_Note__c = (String) appointmentMapWithNlt.get(VCC_SchedulingOmniConnector.NOTE_KEY)
                    )
                }
            )
            .returning((Object) null);

        // mocking/stubbing VCR_AppointmentRepo
        stubAppointmentRepo(
            new List<VATEST_MockedMethod>{ mockedUpdateAppointment, mockedUpsertAppointmentByAppointmentId }
        );

        // create arg tuple and execute
        VCC_OmniRemoteAction.ArgTuple argTuple = createUpdateAppointmentWithNltArgTuple(siteId, appointment);
        System.runAs(msaUser) {
            Test.startTest();
            (new VCC_SchedulingOmniConnector()).call(argTuple);
            Test.stopTest();
        }

        Map<String, Object> updatedAppointment = (Map<String, Object>) argTuple.output.get('updatedAppointment');
        Assert.isNotNull(
            updatedAppointment,
            'Expected a non-null value in output map key "updatedAppointment" because the method should "return" it (aka add it to the output map)'
        );
        Assert.areEqual(
            appointmentMapWithNlt.get(VCC_SchedulingOmniConnector.NOTE_KEY),
            updatedAppointment.get(VCC_SchedulingOmniConnector.NOTE_KEY),
            'Expected output updatedApointment.note to equal the mocked value'
        );
        Assert.areEqual(
            appointmentMapWithNlt.get(VCC_SchedulingOmniConnector.ID_KEY),
            updatedAppointment.get(VCC_SchedulingOmniConnector.ID_KEY),
            'Expected output updatedApointment.id to equal the mocked value'
        );
    }

    /**
     * @description an integration test (but a mock callout response) same asserts as the stubbed test with
     * the addition of a query for the upserted record
     */
    @IsTest
    static void intgnUpdateAppointmentWithNltPositive() {
        // general test setup for VCC_SchedulingOmniConnector.updateAppointmentWithNLT
        String siteId = '123';
        String noteField = 'test note';
        String appointmentId = 'test id';
        Map<String, Object> appointment = new Map<String, Object>{
            VCC_SchedulingOmniConnector.NOTE_KEY => noteField,
            VCC_SchedulingOmniConnector.ID_KEY => appointmentId
        };
        Map<String, Object> appointmentMapWithNlt = (new VCC_SchedulingOmniConnector())
            .createNewAppointmentMapWithNlt(appointment);

        // callout mock setup
        VTC_CHROUpdateAppointmentRS updateAppointmentRs = new VTC_CHROUpdateAppointmentRS();
        updateAppointmentRs.note = (String) appointmentMapWithNlt.get(VCC_SchedulingOmniConnector.NOTE_KEY);
        updateAppointmentRs.id = (String) appointmentMapWithNlt.get(VCC_SchedulingOmniConnector.ID_KEY);
        Test.setMock(HttpCalloutMock.class, new VTC_CHROHttpCalloutMock(200, JSON.serialize(updateAppointmentRs)));

        // create arg tuple and execute
        VCC_OmniRemoteAction.ArgTuple argTuple = createUpdateAppointmentWithNltArgTuple(siteId, appointment);
        System.runAs(msaUser) {
            Test.startTest();
            (new VCC_SchedulingOmniConnector()).call(argTuple);
            Test.stopTest();
        }

        Map<String, Object> updatedAppointment = (Map<String, Object>) argTuple.output.get('updatedAppointment');
        Assert.isNotNull(updatedAppointment, 'Expected a non-null value from output map');
        List<VCC_Appointment__c> appointmentList = getAppointmentsByAppointmentId(appointmentId);
        Assert.areEqual(
            1,
            appointmentList.size(),
            'Expected one VCC_Appointment__c returned given updateAppointmentWithNlt performs an upsert'
        );
        VCC_Appointment__c upsertedAppointment = appointmentList[0];
        Assert.areEqual(
            (String) appointmentMapWithNlt.get(VCC_SchedulingOmniConnector.NOTE_KEY),
            upsertedAppointment.VCC_Note__c,
            'Expected appointment note with "#NLT#" to be upserted to the VCC_Note__c field upsertedAppointment'
        );
        Assert.areEqual(
            (String) appointmentMapWithNlt.get(VCC_SchedulingOmniConnector.ID_KEY),
            upsertedAppointment.VCC_Appointment_Id__c,
            'Expected test appointment ID value from local variable appointmentId to be upserted into the VCC_Appointment_Id__c field on upsertedAppointment'
        );
    }

    /**
     * @description tests that when run as a user without appropriate permissions, the dry-run insert will fail and execution will stop
     * before attempting to make the callout.
     *
     * Note: I tried to do this test w/o stubbing the appointment repo but kept getting an uncatchable exception with message:
     *  "Access to entity 'VCC_Appointment__c' denied"
     */
    @IsTest
    static void unitUpdateAppointmentStandardUserNegative() {
        String mockAppointmentId = 'appointmentId';
        VCC_Appointment__c appointmentForUpdate = new VCC_Appointment__c(VCC_Appointment_Id__c = mockAppointmentId);
        String mockExceptionMessage = 'Test';

        // VCR_AppointmentRepo.upsertAppointmentByAppointmentId stub/mock set-up
        VATEST_MockedMethod mockedUpsertAppointmentByAppointmentId = VCR_AppointmentRepoTest.getMockedMethodUpsertAppointmentByAppointmentId()
            .withParameterValues(new List<Object>{ appointmentForUpdate })
            .throwingException(new DmlException(mockExceptionMessage));

        // mocking/stubbing VCR_AppointmentRepo
        stubAppointmentRepo(new List<VATEST_MockedMethod>{ mockedUpsertAppointmentByAppointmentId });

        System.runAs(standardUser) {
            Test.startTest();
            try {
                (new VCC_SchedulingOmniConnector()).updateAppointment(appointmentForUpdate, null, null);
                Assert.fail('Expected an exception because the appointmentRepo was mocked/stubbed to do so');
            } catch (DmlException thrownDmlException) {
                Assert.areEqual(
                    mockExceptionMessage,
                    thrownDmlException.getMessage(),
                    'Expected that the caught exception message matches the expected mock exception message because it was specified when stubbed'
                );
            }
            Test.stopTest();
        }
    }

    /**
     * @description this test validates that, if the callout fails, no VCC_Appointment__c
     * record is created and the dry-run does not modify the original SObject in memory
     */
    @IsTest
    static void intgnUpdateAppointmentCalloutFailNegative() {
        String mockAppointmentId = 'appointmentId';
        String mockSiteId = 'siteId';
        Map<String, Object> appointmentMap = new Map<String, Object>{
            VCC_SchedulingOmniConnector.ID_KEY => mockAppointmentId
        };
        VCC_Appointment__c appointmentForUpdate = new VCC_Appointment__c(VCC_Appointment_Id__c = mockAppointmentId);
        VCC_Appointment__c clonedAppointmentForUpdate = appointmentForUpdate.clone(true, true, true, true);

        System.runAs(msaUser) {
            Test.startTest();
            try {
                (new VCC_SchedulingOmniConnector()).updateAppointment(appointmentForUpdate, appointmentMap, mockSiteId);
                Assert.fail(
                    'Expected TypeException because no callout mock was set intentionally to produce an exception'
                );
            } catch (TypeException thrownTypeException) {
                Assert.areEqual(
                    'Methods defined as TestMethod do not support Web service callouts',
                    thrownTypeException.getMessage(),
                    'Expected the OOTB TestMethod callout exception because the callout was intentionally not mocked to produce this exception'
                );
            }
            Test.stopTest();
        }

        Assert.areEqual(
            clonedAppointmentForUpdate,
            appointmentForUpdate,
            'Expected cloned VCC_Appointment__c SObject to match the original because VCC_SchedulingOmniConnector.updateAppointment ' +
            'should not have modified the original during its dry-run'
        );
        Assert.isTrue(
            getAppointmentsByAppointmentId(mockAppointmentId).isEmpty(),
            'Expected empty list from query because no appointments should have been inserted by the dry-run'
        );
    }

    /**
     * @description this test validates that, if the dry-run and callout succeed without error,
     * the appointment is successfully upserted
     */
    @IsTest
    static void intgnUpdateAppointmentPositive() {
        String mockAppointmentId = 'appointmentId';
        String mockSiteId = 'siteId';
        Map<String, Object> appointmentMap = new Map<String, Object>{
            VCC_SchedulingOmniConnector.ID_KEY => mockAppointmentId
        };
        VCC_Appointment__c appointmentForUpdate = new VCC_Appointment__c(VCC_Appointment_Id__c = mockAppointmentId);
        VCC_Appointment__c clonedAppointmentForUpdate = appointmentForUpdate.clone(true, true, true, true);

        // callout mock setup
        VTC_CHROUpdateAppointmentRS updateAppointmentRs = new VTC_CHROUpdateAppointmentRS();
        updateAppointmentRs.id = (String) appointmentMap.get(VCC_SchedulingOmniConnector.ID_KEY);
        Test.setMock(HttpCalloutMock.class, new VTC_CHROHttpCalloutMock(200, JSON.serialize(updateAppointmentRs)));

        System.runAs(msaUser) {
            Test.startTest();
            (new VCC_SchedulingOmniConnector()).updateAppointment(appointmentForUpdate, appointmentMap, mockSiteId);
            Test.stopTest();
        }

        Assert.areNotEqual(
            clonedAppointmentForUpdate,
            appointmentForUpdate,
            'Expected cloned appointment and original appointment to differ because the upsert sets the ID field after inserting'
        );
        Assert.isFalse(
            getAppointmentsByAppointmentId(mockAppointmentId).isEmpty(),
            'Expected non-empty list because dry-run and callout were successful'
        );
    }

    /**
     * @description positive test for private @TestVisible createNewAppointmentMapWithNlt
     * with expected input, asserts that the appointment ID is not modified and that appointment note
     * has #NLT# appended to the beginning.
     */
    @IsTest
    static void unitCreateNewAppointmentMapWithNltPositive() {
        VCC_SchedulingOmniConnector schedulingOmniConnector = new VCC_SchedulingOmniConnector();
        String mockId = 'mockId';
        String mockNote = 'mockNote';

        Map<String, Object> inputMap = new Map<String, Object>{
            VCC_SchedulingOmniConnector.ID_KEY => mockId,
            VCC_SchedulingOmniConnector.NOTE_KEY => mockNote
        };

        Map<String, Object> outputMap;
        System.runAs(msaUser) {
            outputMap = schedulingOmniConnector.createNewAppointmentMapWithNlt(inputMap);
        }

        Assert.isNotNull(outputMap, 'Expected outputMap to be non-null');
        Assert.areEqual(
            System.Label.VCC_ApptCommentNLT + ' ' + mockNote,
            (String) outputMap.get(VCC_SchedulingOmniConnector.NOTE_KEY),
            'Expected to find "#NLT#" added to the beginning of the mockNote value'
        );
        Assert.areEqual(
            mockId,
            (String) outputMap.get(VCC_SchedulingOmniConnector.ID_KEY),
            'Expected to find unaltered mockId because it is needed for an upsert'
        );
    }

    /**
     * @description negative test for private @TestVisible createNewAppointmentMapWithNlt
     * with null map input, asserts that a null pointer exception is thrown
     */
    @IsTest
    static void unitCreateNewAppointmentMapWithNltNullInputMapNegative() {
        VCC_SchedulingOmniConnector schedulingOmniConnector = new VCC_SchedulingOmniConnector();
        Map<String, Object> inputMap = null;

        Map<String, Object> outputMap;
        System.runAs(msaUser) {
            try {
                outputMap = schedulingOmniConnector.createNewAppointmentMapWithNlt(inputMap);
                Assert.fail('Expected a IllegalArgumentException because inputMap was null');
            } catch (IllegalArgumentException illegalArgumentException) {
                Assert.areEqual(
                    VCC_SchedulingOmniConnector.MISSING_APPOINTMENT_MAP_MESSAGE,
                    illegalArgumentException.getMessage(),
                    'Expected exception message to match that stored in VCC_SchedulingOmniConnector.MISSING_APPOINTMENT_MAP_MESSAGE because that is what is passed into the exception'
                );
            }
        }
    }

    /**
     * @description negative test for private @TestVisible createNewAppointmentMapWithNlt
     * with a map input with null values. asserts that #NLT# was added to the VCC_SchedulingOmniConnector.NOTE_KEY field and VCC_SchedulingOmniConnector.ID_KEY is still null
     */
    @IsTest
    static void unitCreateNewAppointmentMapWithNltNullMapValuesNegative() {
        VCC_SchedulingOmniConnector schedulingOmniConnector = new VCC_SchedulingOmniConnector();
        String mockId = null;
        String mockNote = null;
        Map<String, Object> inputMap = new Map<String, Object>{
            VCC_SchedulingOmniConnector.ID_KEY => mockId,
            VCC_SchedulingOmniConnector.NOTE_KEY => mockNote
        };

        Map<String, Object> outputMap;
        System.runAs(msaUser) {
            outputMap = schedulingOmniConnector.createNewAppointmentMapWithNlt(inputMap);
        }

        Assert.isNotNull(outputMap, 'Expected outputMap to be non-null');
        Assert.areEqual(
            System.Label.VCC_ApptCommentNLT + ' ',
            (String) outputMap.get(VCC_SchedulingOmniConnector.NOTE_KEY),
            'Expected to find "#NLT# " because mockNote is null'
        );
        Assert.isNull(
            outputMap.get(VCC_SchedulingOmniConnector.ID_KEY),
            'Expected null from outputMap.get(\'id\') because the input mockNote is null'
        );
    }
}
