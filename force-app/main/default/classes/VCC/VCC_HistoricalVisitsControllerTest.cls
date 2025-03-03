/**
 * @description Test for VCC_HistoricalVisitsController class.
 * @author Booz Allen
 *
 * @see VCC_HistoricalVisitsController for class being tested
 */
@IsTest
public with sharing class VCC_HistoricalVisitsControllerTest {
    private static final String FAKE_ICN = 'fakeICN';

    @IsTest
    private static void ensureCorrectDefaultInitialization() {
        User vaVetUser = createTestUser();
        System.runAs(vaVetUser) {
            Test.startTest();
            VCC_HistoricalVisitsController visitController = new VCC_HistoricalVisitsController();
            Test.stopTest();

            Assert.isTrue(visitController != null, 'Expected class to be initialized.');
            Assert.isTrue(
                VCC_HistoricalVisitsController.healthDataRepo != null,
                'Expected healthDataRepo to be initialized'
            );
            Assert.isTrue(VCC_HistoricalVisitsController.visitRepo != null, 'Expected visitRepo to be initialized.');
        }
    }

    @IsTest
    private static void unitFetchVisits() {
        Map<String, Object> args = new Map<String, Object>{ 'application' => 'VAHC', 'icn' => FAKE_ICN };
        VCC_HistoricalVisitsController.healthDataRepo = createHealthDataRepo('visits');
        VCC_HistoricalVisitsController.visitRepo = createVisitRepo(args, new VTC_DataModel());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VTC_DataModel visitsDataModel = (VTC_DataModel) VCC_HistoricalVisitsController.fetchVisits(args);
            Assert.isTrue(visitsDataModel != null, 'Expected valid non-null model to be returned.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitFetchHealthDataConfig() {
        VCC_HistoricalVisitsController.healthDataRepo = createHealthDataRepo('visits');
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VCR_HealthDataRepo.Model healthDataConfig = (VCR_HealthDataRepo.Model) VCC_HistoricalVisitsController.fetchHealthDataConfig(
                FAKE_ICN
            );
            Assert.isNotNull(healthDataConfig != null, 'Expected valid non-null model to be returned.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitFetchVisitsVTCExceptionNoRetry() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => FAKE_ICN };
        VCC_HistoricalVisitsController.healthDataRepo = createHealthDataRepo('visits');
        VCC_HistoricalVisitsController.visitRepo = createVisitRepo(
            args,
            new VTC_InternalException('Script-thrown exception')
        );
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                VCC_HistoricalVisitsController.fetchVisits(args);
                Assert.fail('Expected exception to be thrown.');
            } catch (Exception caughtException) {
                Assert.areEqual(
                    caughtException.getMessage(),
                    VCC_HistoricalVisitsController.NO_RETRY_CMD,
                    'Expected a NO_RETRY_CMD to be a part of exception thrown but got back ' +
                    caughtException.getMessage()
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitFetchVisitsVTCExceptionRetry() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => FAKE_ICN };
        VCC_HistoricalVisitsController.healthDataRepo = createHealthDataRepo('visits');
        VCC_HistoricalVisitsController.visitRepo = createVisitRepo(args, new VTC_LimitException());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                VCC_HistoricalVisitsController.fetchVisits(args);
                Assert.fail('Expected exception to be thrown.');
            } catch (Exception caughtException) {
                Assert.areEqual(
                    caughtException.getMessage(),
                    VCC_HistoricalVisitsController.RETRY_CMD,
                    'Expected a RETRY_CMD to be a part of exception thrown but got back ' + caughtException.getMessage()
                );
            }
        }
        Test.stopTest();
    }

    private static VCR_VisitRepo createVisitRepo(Map<String, Object> args, Object returnValue) {
        return (VCR_VisitRepo) new VATEST_StubBuilder(VCR_VisitRepo.class)
            .mockingMethodCall('fetchVisits')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .returning(returnValue)
            .defineStub();
    }

    private static VCR_VisitRepo createVisitRepo(Map<String, Object> args, Exception returnException) {
        return (VCR_VisitRepo) new VATEST_StubBuilder(VCR_VisitRepo.class)
            .mockingMethodCall('fetchVisits')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .throwingException(returnException)
            .defineStub();
    }

    private static VCR_HealthDataRepo createHealthDataRepo(String healthDataType) {
        VCC_WorkstreamSettingsController.VCC_Model workstreamSettingsModel = new VCC_WorkstreamSettingsController.VCC_Model(
            'visits',
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
