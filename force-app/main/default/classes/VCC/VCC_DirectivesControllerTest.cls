/**
 * @description VCC Directives Controller Test
 * @author Booz Allen
 *
 * @see VCC_DirectivesController for class being tested
 */
@IsTest
private with sharing class VCC_DirectivesControllerTest {
    private static final String FAKE_ICN = 'fakeICN';

    @IsTest
    private static void ensureCorrectDefaultInitialization() {
        Test.startTest();
        User vaVetUser = createTestUser();
        System.runAs(vaVetUser) {
            VCC_DirectivesController directivesController = new VCC_DirectivesController();
            Assert.isTrue(directivesController != null, 'Expected class to be initialized.');
            Assert.isTrue(VCC_DirectivesController.healthDataRepo != null, 'Expected healthDataRepo to be initialized');
            Assert.isTrue(
                VCC_DirectivesController.directivesRepo != null,
                'Expected directivesRepo to be initialized.'
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitfetchDirectives() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => FAKE_ICN, 'max' => 200 };
        VCC_DirectivesController.directivesRepo = createDirectivesRepo(args, new VTC_DataModel());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VTC_DataModel directivesModel = (VTC_DataModel) VCC_DirectivesController.fetchDirectives(args);
            Assert.isTrue(directivesModel != null, 'Expected valid non-null model to be returned.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitfetchDirectivesVTCLimitException() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => FAKE_ICN };
        VCC_DirectivesController.directivesRepo = createDirectivesRepo(
            args,
            new VTC_LimitException('Script-thrown exception')
        );
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                VCC_DirectivesController.fetchDirectives(args);
                Assert.fail('Expected exception to be thrown.');
            } catch (Exception e) {
                Assert.areEqual('Script-thrown exception', e.getMessage(), 'Exception message should match.');
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitfetchDirectivesVTCException() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => FAKE_ICN };
        VCC_DirectivesController.directivesRepo = createDirectivesRepo(
            args,
            new VTC_InternalException('Script-thrown exception')
        );
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                VCC_DirectivesController.fetchDirectives(args);
                Assert.fail('Expected exception to be thrown.');
            } catch (Exception e) {
                Assert.areEqual('Script-thrown exception', e.getMessage(), 'Exception message should match.');
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitFetchHealthDataConfig() {
        VCC_WorkstreamSettingsController.VCC_Model workstreamSettingsModel = new VCC_WorkstreamSettingsController.VCC_Model(
            'directives',
            Datetime.now(),
            Datetime.now(),
            12
        );

        Account patientAccount = new Account(Date_of_Birth__pc = '4/20/1999');
        VCR_HealthDataRepo.Model healthDataRepoModel = new VCR_HealthDataRepo.Model()
            .setAccountDOB(patientAccount)
            .setWorkstreamSettings(workstreamSettingsModel);

        VCC_DirectivesController.healthDataRepo = createHealthDataRepo('directives', healthDataRepoModel);
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VCR_HealthDataRepo.Model healthDataConfig = (VCR_HealthDataRepo.Model) VCC_DirectivesController.fetchHealthDataConfig(
                FAKE_ICN
            );
            Assert.isTrue(healthDataConfig != null, 'Expected valid non-null model to be returned.');
        }
        Test.stopTest();
    }

    private static VCR_DirectivesRepo createDirectivesRepo(Map<String, Object> args, Object returnValue) {
        return (VCR_DirectivesRepo) new VATEST_StubBuilder(VCR_DirectivesRepo.class)
            .mockingMethodCall('getDirectives')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .returning(returnValue)
            .defineStub();
    }

    private static VCR_DirectivesRepo createDirectivesRepo(Map<String, Object> args, Exception returnException) {
        return (VCR_DirectivesRepo) new VATEST_StubBuilder(VCR_DirectivesRepo.class)
            .mockingMethodCall('getDirectives')
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
