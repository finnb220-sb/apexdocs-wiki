/**
 * @description VCC Consult Controller Test
 * @author Booz Allen
 *
 * @see VCC_ConsultController for class being tested
 */
@IsTest
private with sharing class VCC_ConsultControllerTest {
    private static final String FAKE_ICN = 'fakeICN';

    @IsTest
    private static void ensureCorrectDefaultInitialization() {
        User vaVetUser = createTestUser();
        System.runAs(vaVetUser) {
            Test.startTest();
            VCC_ConsultController consultController = new VCC_ConsultController();
            Test.stopTest();

            Assert.isTrue(consultController != null, 'Expected class to be initialized.');
            Assert.isTrue(VCC_ConsultController.healthDataRepo != null, 'Expected healthDataRepo to be initialized');
            Assert.isTrue(VCC_ConsultController.consultRepo != null, 'Expected consultRepo to be initialized.');
        }
    }

    @IsTest
    private static void unitFetchConsults() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => FAKE_ICN };
        VCC_ConsultController.healthDataRepo = createHealthDataRepo('consults');
        VCC_ConsultController.consultRepo = createConsultRepo(args, new VTC_DataModel());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VTC_DataModel consultsDataModel = (VTC_DataModel) VCC_ConsultController.fetchConsults(args);
            Assert.isTrue(consultsDataModel != null, 'Expected valid non-null model to be returned.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitFetchConsultsVTCExceptionNoRetry() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => FAKE_ICN };
        VCC_ConsultController.healthDataRepo = createHealthDataRepo('consults');
        VCC_ConsultController.consultRepo = createConsultRepo(
            args,
            new VTC_InternalException('Script-thrown exception')
        );
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                VCC_ConsultController.fetchConsults(args);
                Assert.fail('Expected exception to be thrown.');
            } catch (Exception caughtException) {
                Assert.areEqual(
                    caughtException.getMessage(),
                    VCC_ConsultController.NO_RETRY_CMD,
                    'Expected a NO_RETRY_CMD to be a part of exception thrown but got back ' +
                    caughtException.getMessage()
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitFetchConsultsVTCExceptionRetry() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => FAKE_ICN };
        VCC_ConsultController.healthDataRepo = createHealthDataRepo('consults');
        VCC_ConsultController.consultRepo = createConsultRepo(args, new VTC_LimitException());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                VCC_ConsultController.fetchConsults(args);
                Assert.fail('Expected exception to be thrown.');
            } catch (Exception caughtException) {
                Assert.areEqual(
                    caughtException.getMessage(),
                    VCC_ConsultController.RETRY_CMD,
                    'Expected a RETRY_CMD to be a part of exception thrown but got back ' + caughtException.getMessage()
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitFetchHealthDataConfig() {
        VCC_ConsultController.healthDataRepo = createHealthDataRepo('consults');
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VCR_HealthDataRepo.Model healthDataConfig = (VCR_HealthDataRepo.Model) VCC_ConsultController.fetchHealthDataConfig(
                FAKE_ICN
            );
            Assert.isTrue(healthDataConfig != null, 'Expected valid non-null model to be returned.');
        }
        Test.stopTest();
    }

    private static VCR_ConsultRepo createConsultRepo(Map<String, Object> args, Object returnValue) {
        return (VCR_ConsultRepo) new VATEST_StubBuilder(VCR_ConsultRepo.class)
            .mockingMethodCall('fetchConsults')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .returning(returnValue)
            .defineStub();
    }

    private static VCR_ConsultRepo createConsultRepo(Map<String, Object> args, Exception returnException) {
        return (VCR_ConsultRepo) new VATEST_StubBuilder(VCR_ConsultRepo.class)
            .mockingMethodCall('fetchConsults')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .throwingException(returnException)
            .defineStub();
    }

    private static VCR_HealthDataRepo createHealthDataRepo(String healthDataType) {
        VCC_WorkstreamSettingsController.VCC_Model workstreamSettingsModel = new VCC_WorkstreamSettingsController.VCC_Model(
            'consults',
            Datetime.now(),
            Datetime.now(),
            12
        );

        Account patientAccount = new Account(Date_of_Birth__pc = '4/20/1999');
        VCR_HealthDataRepo.Model healthDataRepoModel = new VCR_HealthDataRepo.Model()
            .setAccountDOB(patientAccount)
            .setWorkstreamSettings(workstreamSettingsModel);

        return (VCR_HealthDataRepo) new VATEST_StubBuilder(VCR_HealthDataRepo.class)
            .mockingMethodCall('fetchHealthDataConfig')
            .withParameterTypes()
            .returning(healthDataRepoModel)
            .mockingMethodCall('setPatientByICN')
            .withParameterTypes(String.class)
            .withParameterValues(FAKE_ICN)
            .returning()
            .defineStub();
    }

    private static User createTestUser() {
        return new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
    }
}
