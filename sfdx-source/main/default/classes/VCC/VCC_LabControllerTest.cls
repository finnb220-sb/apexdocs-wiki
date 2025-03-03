/**
 * @description VCC Lab Controller Test
 * @author Booz Allen
 *
 * @see VCC_LabController for class being tested
 */
@IsTest
private with sharing class VCC_LabControllerTest {
    private static final String FAKE_ICN = 'fakeICN';

    @IsTest
    private static void ensureCorrectDefaultInitialization() {
        User vaVetUser = createTestUser();
        System.runAs(vaVetUser) {
            Test.startTest();
            VCC_LabController labController = new VCC_LabController();
            Test.stopTest();

            Assert.isTrue(labController != null, 'Expected class to be initialized.');
            Assert.isTrue(VCC_LabController.healthDataRepo != null, 'Expected healthDataRepo to be initialized');
            Assert.isTrue(VCC_LabController.labRepo != null, 'Expected labRepo to be initialized.');
        }
    }

    @IsTest
    private static void unitFetchLabs() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => FAKE_ICN };
        VCC_LabController.healthDataRepo = createHealthDataRepo('labs');
        VCC_LabController.labRepo = createLabRepo(args, new VTC_DataModel());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VTC_DataModel labsDataModel = (VTC_DataModel) VCC_LabController.fetchLabs(args);
            Assert.isTrue(labsDataModel != null, 'Expected valid non-null model to be returned.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitFetchLabsVTCExceptionNoRetry() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => FAKE_ICN };
        VCC_LabController.healthDataRepo = createHealthDataRepo('labs');
        VCC_LabController.labRepo = createLabRepo(args, new VTC_InternalException('Script-thrown exception'));
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                VCC_LabController.fetchLabs(args);
                Assert.fail('Expected exception to be thrown.');
            } catch (Exception caughtException) {
                Assert.areEqual(
                    caughtException.getMessage(),
                    VCC_LabController.NO_RETRY_CMD,
                    'Expected a NO_RETRY_CMD to be a part of exception thrown but got back ' +
                    caughtException.getMessage()
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitFetchLabsVTCExceptionRetry() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => FAKE_ICN };
        VCC_LabController.healthDataRepo = createHealthDataRepo('labs');
        VCC_LabController.labRepo = createLabRepo(args, new VTC_LimitException());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                VCC_LabController.fetchLabs(args);
                Assert.fail('Expected exception to be thrown.');
            } catch (Exception caughtException) {
                Assert.areEqual(
                    caughtException.getMessage(),
                    VCC_LabController.RETRY_CMD,
                    'Expected a RETRY_CMD to be a part of exception thrown but got back ' + caughtException.getMessage()
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitFetchHealthDataConfig() {
        VCC_LabController.healthDataRepo = createHealthDataRepo('labs');
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VCR_HealthDataRepo.Model healthDataConfig = (VCR_HealthDataRepo.Model) VCC_LabController.fetchHealthDataConfig(
                FAKE_ICN
            );
            Assert.isNotNull(healthDataConfig, 'Expected valid non-null model to be returned.');
        }
        Test.stopTest();
    }

    private static VCR_LabRepo createLabRepo(Map<String, Object> args, Object returnValue) {
        return (VCR_LabRepo) new VATEST_StubBuilder(VCR_LabRepo.class)
            .mockingMethodCall('fetchLabs')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .returning(returnValue)
            .defineStub();
    }

    private static VCR_LabRepo createLabRepo(Map<String, Object> args, Exception returnException) {
        return (VCR_LabRepo) new VATEST_StubBuilder(VCR_LabRepo.class)
            .mockingMethodCall('fetchLabs')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .throwingException(returnException)
            .defineStub();
    }

    private static VCR_HealthDataRepo createHealthDataRepo(String healthDataType) {
        VCC_WorkstreamSettingsController.VCC_Model workstreamSettingsModel = new VCC_WorkstreamSettingsController.VCC_Model(
            'labs',
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
