@isTest
private with sharing class VCC_ImmunizationControllerTest {
    @IsTest
    private static void ensureCorrectDefaultInitialization() {
        User vaVetUser = createTestUser();
        System.runAs(vaVetUser) {
            Test.startTest();
            VCC_ImmunizationController immunizationsController = new VCC_ImmunizationController();
            Test.stopTest();

            Assert.isTrue(immunizationsController != null, 'Expected class to be initialized.');
            Assert.isTrue(
                VCC_ImmunizationController.healthDataRepo != null,
                'Expected healthDataRepo to be initialized'
            );
            Assert.isTrue(
                VCC_ImmunizationController.immunizationsRepo != null,
                'Expected immunizationsRepo to be initialized.'
            );
        }
    }

    @IsTest
    private static void unitFetchImmunizations() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCC_ImmunizationController.immunizationsRepo = createimmunizationsRepo(args, new VTC_DataModel());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VTC_DataModel immunizationsDataModel = (VTC_DataModel) VCC_ImmunizationController.fetchImmunizations(args);
            Assert.isTrue(immunizationsDataModel != null, 'Expected valid non-null model to be returned.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitFetchImmunizationsVTCExceptionNoRetry() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCC_ImmunizationController.immunizationsRepo = createimmunizationsRepo(args, new VTC_InternalException());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                VCC_ImmunizationController.fetchImmunizations(args);
                Assert.fail('Expected exception to be thrown.');
            } catch (Exception caughtException) {
                Assert.areEqual(
                    VCC_ImmunizationController.NO_RETRY_CMD,
                    caughtException.getMessage(),
                    'Expected NO_RETRY_CMD but got back: ' + caughtException.getMessage()
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitFetchImmunizationsVTCExceptionRetry() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCC_ImmunizationController.immunizationsRepo = createimmunizationsRepo(args, new VTC_LimitException());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                VCC_ImmunizationController.fetchImmunizations(args);
                Assert.fail('Expected exception to be thrown.');
            } catch (Exception caughtException) {
                Assert.areEqual(
                    VCC_ImmunizationController.RETRY_CMD,
                    caughtException.getMessage(),
                    'Expected RETRY_CMD but got back: ' + caughtException.getMessage()
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitFetchHealthDataConfig() {
        VCC_WorkstreamSettingsController.VCC_Model workstreamSettingsModel = new VCC_WorkstreamSettingsController.VCC_Model(
            'immunizations',
            Datetime.now(),
            Datetime.now(),
            12
        );

        Account patientAccount = new Account(Date_of_Birth__pc = '4/20/1999');
        VCR_HealthDataRepo.Model healthDataRepoModel = new VCR_HealthDataRepo.Model()
            .setAccountDOB(patientAccount)
            .setWorkstreamSettings(workstreamSettingsModel);

        VCC_ImmunizationController.healthDataRepo = createHealthDataRepo('immunizations', healthDataRepoModel);
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VCR_HealthDataRepo.Model healthDataConfig = (VCR_HealthDataRepo.Model) VCC_ImmunizationController.fetchHealthDataConfig(
                'fakeICN'
            );
            Assert.isTrue(healthDataConfig != null, 'Expected valid non-null model to be returned.');
        }
        Test.stopTest();
    }

    private static VCR_immunizationsRepo createimmunizationsRepo(Map<String, Object> args, Object returnValue) {
        return (VCR_immunizationsRepo) new VATEST_StubBuilder(VCR_immunizationsRepo.class)
            .mockingMethodCall('fetchImmunizations')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .returning(returnValue)
            .defineStub();
    }

    private static VCR_immunizationsRepo createimmunizationsRepo(Map<String, Object> args, Exception returnException) {
        return (VCR_immunizationsRepo) new VATEST_StubBuilder(VCR_immunizationsRepo.class)
            .mockingMethodCall('fetchImmunizations')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .throwingException(returnException)
            .defineStub();
    }

    private static User createTestUser() {
        return new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
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
}
