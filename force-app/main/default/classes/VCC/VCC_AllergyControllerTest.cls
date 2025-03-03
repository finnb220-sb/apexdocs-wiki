/**
 * @author Kumar Balan
 * @group Test Classes
 * @description Test for VCC_AllergyController class.
 * @see VCC_AllergyController
 */
@isTest
private with sharing class VCC_AllergyControllerTest {
    private static final String FAKE_ICN = 'fakeICN';

    /**
     * @description test setup for VCC_AllergyControllerTest class
     */
    @TestSetup
    private static void setupTestDataUser() {
        new VATEST_UserBuilder()
            .withPermissionSet('VCC_Advanced_Medical_Support_Assistant')
            .withPermissionSet('VAHC_Test_Data_Import')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
    }

    /**
     * @description creates an account
     * @return List<Account> returns list of accounts
     */
    private static List<Account> createAccount() {
        Account acc = new Account(Name = 'Patient1');
        List<Account> accList = new List<Account>();
        accList.add(acc);
        insert accList;
        return accList;
    }

    /**
     * @description tests for correct default initialization of VCC_AllergyController
     */
    @IsTest
    private static void ensureCorrectDefaultInitialization() {
        User vaVetUser = [SELECT Id FROM User WHERE Email = 'Testuser@test.example.com'][0];
        System.runAs(vaVetUser) {
            Test.startTest();
            VCC_AllergyController allergyController = new VCC_AllergyController();
            Test.stopTest();

            Assert.isTrue(allergyController != null, 'Expected class to be initialized.');
            Assert.isTrue(VCC_AllergyController.healthDataRepo != null, 'Expected healthDataRepo to be initialized');
        }
    }

    /**
     * @description tests for return of non-null VCR_HealthDataRepo.Model
     */
    @IsTest
    private static void unitFetchHealthDataConfig() {
        VCC_WorkstreamSettingsController.VCC_Model workstreamSettingsModel = new VCC_WorkstreamSettingsController.VCC_Model(
            'allergies',
            Datetime.now(),
            Datetime.now(),
            12
        );

        Account patientAccount = new Account(Date_of_Birth__pc = '4/20/1999');
        VCR_HealthDataRepo.Model healthDataRepoModel = new VCR_HealthDataRepo.Model()
            .setAccountDOB(patientAccount)
            .setWorkstreamSettings(workstreamSettingsModel);

        VCC_AllergyController.healthDataRepo = createHealthDataRepo('allergies', healthDataRepoModel);
        User vaVetUser = [SELECT Id FROM User WHERE Email = 'Testuser@test.example.com'][0];

        Test.startTest();
        System.runAs(vaVetUser) {
            VCR_HealthDataRepo.Model healthDataConfig = (VCR_HealthDataRepo.Model) VCC_AllergyController.fetchHealthDataConfig(
                FAKE_ICN
            );
            Assert.isTrue(healthDataConfig != null, 'Expected valid non-null model to be returned.');
        }
        Test.stopTest();
    }

    private static VCR_AllergyRepo createAllergyRepo(Map<String, Object> args, Object returnValue) {
        return (VCR_AllergyRepo) new VATEST_StubBuilder(VCR_AllergyRepo.class)
            .mockingMethodCall('fetchAllergies')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .returning(returnValue)
            .defineStub();
    }

    private static VCR_AllergyRepo createAllergyRepo(Map<String, Object> args, Exception returnException) {
        return (VCR_AllergyRepo) new VATEST_StubBuilder(VCR_AllergyRepo.class)
            .mockingMethodCall('fetchAllergies')
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

    /**
     * @description Test for the controller class.
     */
    @isTest
    static void getAllergy() {
        User vaVetUser = [SELECT Id FROM User WHERE Email = 'Testuser@test.example.com'][0];
        Test.setMock(HttpCalloutMock.class, new VCC_HttpMock());
        System.runAs(vaVetUser) {
            List<Account> acclist = createAccount();
            Test.startTest();
            VCC_AllergyLightningRequestWrp allergyReqWrp = new VCC_AllergyLightningRequestWrp();
            allergyReqWrp.recordId = acclist[0].Id;
            allergyReqWrp.facility = '613';
            allergyReqWrp.startDate = '1950-01-01';
            allergyReqWrp.endDate = '2050-01-01';
            VCC_allergyService.enviornment = 'PROD';
            VCC_allergyResponseWrp allergyResWrp = VCC_AllergyController.getAllergy(allergyReqWrp);
            Assert.AreNotEqual(202, allergyResWrp.statusCode, 'Failed to retrieve from PROD environment');

            VCC_AllergyService.enviornment = 'TEST';
            allergyResWrp = VCC_AllergyController.getAllergy(allergyReqWrp);
            Assert.AreNotEqual(202, allergyResWrp.statusCode, 'Failed to retrieve from TEST environment');

            Test.stopTest();
        }
    }
}
