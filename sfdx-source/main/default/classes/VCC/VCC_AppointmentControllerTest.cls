/**
 * @description VCC Appointments Controller Test
 * @author Booz Allen
 *
 * @see VCC_AppointmentController for class being tested
 */
@IsTest
private with sharing class VCC_AppointmentControllerTest {
    @IsTest
    private static void unitFetchAppointments() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCC_AppointmentController.appointmentsRepo = createAppointmentsRepo(args, new VTC_DataModel());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VTC_DataModel appointmentsDataModel = (VTC_DataModel) VCC_AppointmentController.fetchAppointments(args);
            Assert.isTrue(appointmentsDataModel != null, 'Expected valid non-null model to be returned.');
            Assert.isTrue(
                VCC_AppointmentController.healthDataRepo != null,
                'Expected healthDataRepo to be initialized'
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitFetchHealthDataConfig() {
        VCC_WorkstreamSettingsController.VCC_Model workstreamSettingsModel = new VCC_WorkstreamSettingsController.VCC_Model(
            'appointments',
            Datetime.now(),
            Datetime.now(),
            12
        );

        Account patientAccount = new Account(Date_of_Birth__pc = '4/20/1999');
        VCR_HealthDataRepo.Model healthDataRepoModel = new VCR_HealthDataRepo.Model()
            .setAccountDOB(patientAccount)
            .setWorkstreamSettings(workstreamSettingsModel);

        VCC_AppointmentController.healthDataRepo = createHealthDataRepo('appointments', healthDataRepoModel);
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VCR_HealthDataRepo.Model healthDataConfig = (VCR_HealthDataRepo.Model) VCC_AppointmentController.fetchHealthDataConfig(
                'fakeICN'
            );
            Assert.isTrue(healthDataConfig != null, 'Expected valid non-null model to be returned.');
        }
        Test.stopTest();
    }

    private static VCR_HealthDataRepo createHealthDataRepo(
        String healthDataType,
        VCR_HealthDataRepo.Model returnValue
    ) {
        return (VCR_HealthDataRepo) new VATEST_StubBuilder(VCR_HealthDataRepo.class)
            .mockingMethodCall('fetchHealthDataConfig')
            .withParameterTypes()
            .returning(returnValue)
            .mockingMethodCall('setPatientByICN')
            .withParameterTypes(String.class)
            .withParameterValues('fakeICN')
            .returning()
            .defineStub();
    }

    @IsTest
    private static void unitFetchAppointmentsVTCExceptionNoRetry() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCC_AppointmentController.appointmentsRepo = createAppointmentsRepo(args, new VTC_InternalException());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                VCC_AppointmentController.fetchAppointments(args);
                Assert.fail('Expected exception to be thrown.');
            } catch (Exception caughtException) {
                Assert.areEqual(
                    VCC_AppointmentController.NO_RETRY_CMD,
                    caughtException.getMessage(),
                    'Expected NO_RETRY_CMD but got back: ' + caughtException.getMessage()
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitFetchAppointmentsVTCExceptionRetry() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCC_AppointmentController.appointmentsRepo = createAppointmentsRepo(args, new VTC_LimitException());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                VCC_AppointmentController.fetchAppointments(args);
                Assert.fail('Expected exception to be thrown.');
            } catch (Exception caughtException) {
                Assert.areEqual(
                    VCC_AppointmentController.RETRY_CMD,
                    caughtException.getMessage(),
                    'Expected RETRY_CMD but got back: ' + caughtException.getMessage()
                );
            }
        }
        Test.stopTest();
    }

    private static VCR_AppointmentsRepo createAppointmentsRepo(Map<String, Object> args, Object returnValue) {
        return (VCR_AppointmentsRepo) new VATEST_StubBuilder(VCR_AppointmentsRepo.class)
            .mockingMethodCall('fetchAppointments')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .returning(returnValue)
            .defineStub();
    }

    private static VCR_AppointmentsRepo createAppointmentsRepo(Map<String, Object> args, Exception returnException) {
        return (VCR_AppointmentsRepo) new VATEST_StubBuilder(VCR_AppointmentsRepo.class)
            .mockingMethodCall('fetchAppointments')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .throwingException(returnException)
            .defineStub();
    }

    private static User createTestUser() {
        return new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
    }
}
