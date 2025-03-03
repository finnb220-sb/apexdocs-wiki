/**
 * @description Test for VCC_ProblemController class.
 * @author Booz Allen
 *
 * @see VCC_ProblemController
 */
@IsTest
private with sharing class VCC_ProblemControllerTest {
    private static final String FAKE_ICN = 'fakeICN';

    @IsTest
    private static void ensureCorrectDefaultInitialization() {
        User vaVetUser = createTestUser();
        System.runAs(vaVetUser) {
            Test.startTest();
            VCC_ProblemController problemController = new VCC_ProblemController();
            Test.stopTest();

            Assert.isTrue(problemController != null, 'Expected class to be initialized.');
            Assert.isTrue(VCC_ProblemController.healthDataRepo != null, 'Expected healthDataRepo to be initialized');
            Assert.isTrue(VCC_ProblemController.problemRepo != null, 'Expected problemRepo to be initialized.');
        }
    }

    @IsTest
    private static void unitFetchProblems() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => FAKE_ICN };
        VCC_ProblemController.problemRepo = createProblemRepo(args, new VTC_DataModel());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VTC_DataModel problemsDataModel = (VTC_DataModel) VCC_ProblemController.fetchProblems(args);
            Assert.isTrue(problemsDataModel != null, 'Expected valid non-null model to be returned.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitFetchProblemsVTCExceptionNoRetry() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => FAKE_ICN };
        VCC_ProblemController.problemRepo = createProblemRepo(args, new VTC_InternalException());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                VCC_ProblemController.fetchProblems(args);
                Assert.fail('Expected exception to be thrown.');
            } catch (Exception caughtException) {
                Assert.areEqual(
                    VCC_ProblemController.NO_RETRY_CMD,
                    caughtException.getMessage(),
                    'Expected NO_RETRY_CMD but got back: ' + caughtException.getMessage()
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitFetchProblemsVTCExceptionRetry() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => FAKE_ICN };
        VCC_ProblemController.problemRepo = createProblemRepo(args, new VTC_LimitException());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                VCC_ProblemController.fetchProblems(args);
                Assert.fail('Expected exception to be thrown.');
            } catch (Exception caughtException) {
                Assert.areEqual(
                    VCC_ProblemController.RETRY_CMD,
                    caughtException.getMessage(),
                    'Expected RETRY_CMD but got back: ' + caughtException.getMessage()
                );
            }
        }
        Test.stopTest();
    }

    private static VCR_ProblemRepo createProblemRepo(Map<String, Object> args, Object returnValue) {
        return (VCR_ProblemRepo) new VATEST_StubBuilder(VCR_ProblemRepo.class)
            .mockingMethodCall('fetchProblems')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .returning(returnValue)
            .defineStub();
    }

    private static VCR_ProblemRepo createProblemRepo(Map<String, Object> args, Exception returnException) {
        return (VCR_ProblemRepo) new VATEST_StubBuilder(VCR_ProblemRepo.class)
            .mockingMethodCall('fetchProblems')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .throwingException(returnException)
            .defineStub();
    }

    private static User createTestUser() {
        return new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
    }

    @IsTest
    private static void unitFetchHealthDataConfig() {
        VCC_WorkstreamSettingsController.VCC_Model workstreamSettingsModel = new VCC_WorkstreamSettingsController.VCC_Model(
            'problems',
            Datetime.now(),
            Datetime.now(),
            12
        );

        Account patientAccount = new Account(Date_of_Birth__pc = '4/20/1999');
        VCR_HealthDataRepo.Model healthDataRepoModel = new VCR_HealthDataRepo.Model()
            .setAccountDOB(patientAccount)
            .setWorkstreamSettings(workstreamSettingsModel);

        VCC_ProblemController.healthDataRepo = createHealthDataRepo('problems', healthDataRepoModel);
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VCR_HealthDataRepo.Model healthDataConfig = (VCR_HealthDataRepo.Model) VCC_ProblemController.fetchHealthDataConfig(
                FAKE_ICN
            );
            Assert.isNotNull(healthDataConfig, 'Expected valid non-null model to be returned.');
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
            .withParameterValues(FAKE_ICN)
            .returning()
            .defineStub();
    }
}
