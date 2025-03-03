/**
 * @description Tests the VCR_AllergyRepo class
 * @author Booz Allen Hamilton
 *
 * @see VCR_AllergyRepo for class being tested
 */
@IsTest
private with sharing class VCR_AllergyRepoTest {
    @IsTest
    private static void ensureCorrectDefaultInitialization() {
        System.runAs(createTestUser()) {
            Test.startTest();
            Assert.isTrue(VCR_AllergyRepo.patientService != null, 'Expected patientService to be initialized.');
            Test.stopTest();
        }
    }

    @IsTest
    private static void unitGetAllergyReturnsValidDataWhenMockedPositive() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCR_AllergyRepo.patientService = createPatientService(args, new VTC_DataModel());
        System.runAs(createTestUser()) {
            Test.startTest();
            VTC_DataModel allergyDataModel = new VCR_AllergyRepo().fetchAllergies(args);
            Assert.isNotNull(allergyDataModel, 'Expected valid non-null model to be returned.');
            Test.stopTest();
        }
    }

    private static VTC_PatientService createPatientService(Map<String, Object> args, Object returnValue) {
        return (VTC_PatientService) new VATEST_StubBuilder(VTC_PatientService.class)
            .mockingMethodCall('call')
            .withParameterTypes(String.class, Map<String, Object>.class)
            .withParameterValues('get_allergies', args)
            .returning(returnValue)
            .defineStub();
    }

    private static User createTestUser() {
        return new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
    }
}
