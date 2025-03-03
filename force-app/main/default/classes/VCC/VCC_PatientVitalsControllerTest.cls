/**
 * @description VCC Patient Vitals Controller Test
 * @author Booz Allen
 *
 * @see VCC_PatientVitalsController for class being tested
 */
@IsTest
private with sharing class VCC_PatientVitalsControllerTest {
    @IsTest
    /**
     * @description functional test method to ensure initialization was successful
     */
    private static void unitEnsureCorrectDefaultInitializationPositive() {
        User vaVetUser = createTestUser();
        System.runAs(vaVetUser) {
            Test.startTest();
            VCC_PatientVitalsController vitalsController = new VCC_PatientVitalsController();
            Test.stopTest();

            Assert.isNotNull(vitalsController, 'Expected class to be initialized.');
            Assert.isNotNull(VCC_PatientVitalsController.vitalsRepo, 'Expected vitals Repo to be initialized.');
        }
    }

    @IsTest
    /**
     * @description unit test to Fetch vitals
     */
    private static void unitFetchVitalsPositive() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCC_PatientVitalsController.vitalsRepo = createVitalsRepo(args, new VTC_DataModel());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VTC_DataModel vitalsDataModel = (VTC_DataModel) VCC_PatientVitalsController.fetchVitals(args);
            Assert.isTrue(vitalsDataModel != null, 'Expected valid non-null model to be returned.');
        }
        Test.stopTest();
    }

    @IsTest
    /**
     * @description unit test to catch VTC Internal Exception with no retry command
     */
    private static void unitFetchVitalsVTCExceptionNoRetry() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCC_PatientVitalsController.vitalsRepo = createVitalsRepo(args, new VTC_InternalException());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                VCC_PatientVitalsController.fetchVitals(args);
                Assert.fail('Expected exception to be thrown.');
            } catch (AuraHandledException caughtException) {
                Assert.areEqual(
                    caughtException.getMessage(),
                    VCC_PatientVitalsController.NO_RETRY_CMD,
                    'Expected a NO_RETRY_CMD to be a part of exception thrown but got back ' +
                    caughtException.getMessage()
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    /**
     * @description unit test to catch VTC Internal Exception with retry command
     */
    private static void unitFetchVitalsVTCExceptionRetry() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCC_PatientVitalsController.vitalsRepo = createVitalsRepo(args, new VTC_LimitException());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                VCC_PatientVitalsController.fetchVitals(args);
                Assert.fail('Expected exception to be thrown.');
            } catch (AuraHandledException caughtException) {
                Assert.areEqual(
                    caughtException.getMessage(),
                    VCC_PatientVitalsController.RETRY_CMD,
                    'Expected a RETRY_CMD to be a part of exception thrown but got back ' + caughtException.getMessage()
                );
            }
        }
        Test.stopTest();
    }

    /**
     * @description Tests that the first invocation of the wired call to fetchHealthDataConfig returns null.
     */
    @IsTest
    private static void unitFetchHealthDataConfigReturnsPrematurelyOnFirstWireCallNegative() {
        User vaVetUser = createTestUser();
        VCR_HealthDataRepo.Model result;
        Test.startTest();
        System.runAs(vaVetUser) {
            result = VCC_PatientVitalsController.fetchHealthDataConfig(null);
        }
        Test.stopTest();
        Assert.isNull(result, 'Expected .fetchHealthDataConfig to return null when passed null input.');
    }

    /**
     * @description Tests that the first invocation of the wired call to fetchVitals returns null.
     */
    @IsTest
    private static void unitFetchVitalsReturnsPrematurelyOnFirstWireCallNegative() {
        User vaVetUser = createTestUser();
        VTC_DataModel result;
        Test.startTest();
        System.runAs(vaVetUser) {
            result = VCC_PatientVitalsController.fetchVitals(null);
        }
        Test.stopTest();
        Assert.isNull(result, 'Expected .fetchVitals to return null when passed null input.');
    }

    /**
     * @description Tests that when calling fetchVitals with an empty map fetchVitals returns null.
     */
    @IsTest
    private static void unitFetchVitalsReturnsPrematurelyWithEmptyArgsMapNegative() {
        User vaVetUser = createTestUser();
        VTC_DataModel result;
        Test.startTest();
        System.runAs(vaVetUser) {
            result = VCC_PatientVitalsController.fetchVitals(new Map<String, Object>());
        }
        Test.stopTest();
        Assert.isNull(result, 'Expected .fetchVitals to return null when passed null input.');
    }
    /**
     * @description Test the health data config positve
     */
    @IsTest
    private static void unitFetchHealthDataConfig() {
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

        VCC_PatientVitalsController.healthDataRepo = createHealthDataRepo(healthDataRepoModel);
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VCR_HealthDataRepo.Model healthDataConfig = (VCR_HealthDataRepo.Model) VCC_PatientVitalsController.fetchHealthDataConfig(
                'FAKE_ICN'
            );
            Assert.isTrue(healthDataConfig != null, 'Expected valid non-null model to be returned.');
        }
        Test.stopTest();
    }
    /**
     * @description method to build VCR_VitalsRepo stub mocking fetchVitals
     * @param args The arguments to pass to the provider
     * @param returnValue the object to be returned
     * @return `VCR_VitalsRepo`
     */
    private static VCR_VitalsRepo createVitalsRepo(Map<String, Object> args, Object returnValue) {
        return (VCR_VitalsRepo) new VATEST_StubBuilder(VCR_VitalsRepo.class)
            .mockingMethodCall('fetchVitals')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .returning(returnValue)
            .defineStub();
    }

    /**
     * @description method to build VCR_VitalsRepo stub
     * @param args The arguments to pass to the provider
     * @param returnException the exception to be returned
     * @return `VCR_VitalsRepo`
     */
    private static VCR_VitalsRepo createVitalsRepo(Map<String, Object> args, Exception returnException) {
        return (VCR_VitalsRepo) new VATEST_StubBuilder(VCR_VitalsRepo.class)
            .mockingMethodCall('fetchVitals')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .throwingException(returnException)
            .defineStub();
    }

    /**
     * @description method to create a test user
     * @return `User` returns a user to be used for testing
     */
    private static User createTestUser() {
        return new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
    }
    /**
     * @description create mock health data repo
     * @param returnValue - value that the mock should return
     * @return `VCR_HealthDataRepo` - mock of the health data repo
     */
    private static VCR_HealthDataRepo createHealthDataRepo(VCR_HealthDataRepo.Model returnValue) {
        return (VCR_HealthDataRepo) new VATEST_StubBuilder(VCR_HealthDataRepo.class)
            .mockingMethodCall('fetchHealthDataConfig')
            .withParameterTypes()
            .returning(returnValue)
            .mockingMethodCall('setPatientByICN')
            .withParameterTypes(String.class)
            .withParameterValues('FAKE_ICN')
            .returning()
            .defineStub();
    }
}
