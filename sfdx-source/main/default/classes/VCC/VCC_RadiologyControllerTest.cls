/**
 * @description Test for VCC_RadiologyController class.
 * @author Booz Allen
 *
 * @see VCC_RadiologyController for class being tested
 */
@IsTest
public with sharing class VCC_RadiologyControllerTest {
    private static final String FAKE_ICN = 'fakeICN';

    @IsTest
    private static void unitEnsureCorrectDefaultInitializationPositive() {
        User vaVetUser = createTestUser();
        System.runAs(vaVetUser) {
            Test.startTest();
            VCC_RadiologyController radiologyController = new VCC_RadiologyController();
            Test.stopTest();

            Assert.isTrue(radiologyController != null, 'Expected class to be initialized.');
            Assert.isTrue(VCC_RadiologyController.healthDataRepo != null, 'Expected healthDataRepo to be initialized');
            Assert.isTrue(VCC_RadiologyController.radiologyRepo != null, 'Expected radiologyRepo to be initialized.');
        }
    }

    @IsTest
    private static void unitFetchRadiology() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => FAKE_ICN };
        VCC_RadiologyController.radiologyRepo = createRadiologyRepo(args, new VTC_DataModel());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VTC_DataModel radiologyDataModel = (VTC_DataModel) VCC_RadiologyController.fetchRadiology(args);
            Assert.isTrue(radiologyDataModel != null, 'Expected valid non-null model to be returned.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitFetchHealthDataConfig() {
        VCC_WorkstreamSettingsController.VCC_Model workstreamSettingsModel = new VCC_WorkstreamSettingsController.VCC_Model(
            'radiology',
            Datetime.now(),
            Datetime.now(),
            12
        );

        Account patientAccount = new Account(Date_of_Birth__pc = '4/20/1999');
        VCR_HealthDataRepo.Model healthDataRepoModel = new VCR_HealthDataRepo.Model()
            .setAccountDOB(patientAccount)
            .setWorkstreamSettings(workstreamSettingsModel);

        VCC_RadiologyController.healthDataRepo = createHealthDataRepo('radiology', healthDataRepoModel);
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VCR_HealthDataRepo.Model healthDataConfig = (VCR_HealthDataRepo.Model) VCC_RadiologyController.fetchHealthDataConfig(
                FAKE_ICN
            );
            Assert.isNotNull(healthDataConfig, 'Expected valid non-null model to be returned.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitFetchRadiologyVTCExceptionNoRetry() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => FAKE_ICN };
        VCC_RadiologyController.radiologyRepo = createRadiologyRepo(
            args,
            new VTC_InternalException('Script-thrown exception')
        );
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                VCC_RadiologyController.fetchRadiology(args);
                Assert.fail('Expected exception to be thrown.');
            } catch (Exception caughtException) {
                Assert.areEqual(
                    caughtException.getMessage(),
                    VCC_RadiologyController.NO_RETRY_CMD,
                    'Expected a NO_RETRY_CMD to be a part of exception thrown but got back ' +
                    caughtException.getMessage()
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitFetchRadiologyVTCExceptionRetry() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => FAKE_ICN };
        VCC_RadiologyController.radiologyRepo = createRadiologyRepo(args, new VTC_LimitException());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                VCC_RadiologyController.fetchRadiology(args);
                Assert.fail('Expected exception to be thrown.');
            } catch (Exception caughtException) {
                Assert.areEqual(
                    caughtException.getMessage(),
                    VCC_RadiologyController.RETRY_CMD,
                    'Expected a RETRY_CMD to be a part of exception thrown but got back ' + caughtException.getMessage()
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitFetchHealthDataConfigGuardAgainstNullPositive() {
        User vaVetUser = createTestUser();

        VCC_WorkstreamSettingsController.VCC_Model workstreamSettingsModel = new VCC_WorkstreamSettingsController.VCC_Model(
            'radiology',
            Datetime.now(),
            Datetime.now(),
            12
        );

        Account patientAccount = new Account(Date_of_Birth__pc = '4/20/1999');
        VCR_HealthDataRepo.Model healthDataRepoModel = new VCR_HealthDataRepo.Model()
            .setAccountDOB(patientAccount)
            .setWorkstreamSettings(workstreamSettingsModel);
        Test.startTest();
        {
            System.runAs(vaVetUser) {
                healthDataRepoModel = VCC_RadiologyController.fetchHealthDataConfig(null);
            }
        }
        Test.stopTest();
        Assert.isNull(
            healthDataRepoModel,
            'Expected method \'fetchHealthDataConfig\' to guard against null or blank arguments and return null.'
        );
    }

    private static VCR_RadiologyRepo createRadiologyRepo(Map<String, Object> args, Object returnValue) {
        return (VCR_RadiologyRepo) new VATEST_StubBuilder(VCR_RadiologyRepo.class)
            .mockingMethodCall('fetchRadiology')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .returning(returnValue)
            .defineStub();
    }

    private static VCR_RadiologyRepo createRadiologyRepo(Map<String, Object> args, Exception returnException) {
        return (VCR_RadiologyRepo) new VATEST_StubBuilder(VCR_RadiologyRepo.class)
            .mockingMethodCall('fetchRadiology')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .throwingException(returnException)
            .defineStub();
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

    private static User createTestUser() {
        return new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
    }
}
