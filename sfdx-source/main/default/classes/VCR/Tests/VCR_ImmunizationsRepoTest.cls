/**
 * @description Tests the VCR_ImmunizationsRepo class
 * @author Booz Allen
 *
 * @see VCR_ImmunizationsRepo for class being tested
 */
@IsTest
private with sharing class VCR_ImmunizationsRepoTest {
    @IsTest
    private static void ensureCorrectDefaultInitialization() {
        System.runAs(createTestUser()) {
            Test.startTest();
            Assert.isNotNull(VCR_ImmunizationsRepo.patientService, 'Expected patientService to be initialized.');
            Test.stopTest();
        }
    }

    @IsTest
    private static void unitGetImmunizationsReturnsValidDataWhenMockedPositive() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCR_ImmunizationsRepo.patientService = createPatientService(args, new VTC_DataModel());
        System.runAs(createTestUser()) {
            Test.startTest();
            VTC_DataModel immunizationsDataModel = new VCR_ImmunizationsRepo().fetchImmunizations(args);
            Assert.isNotNull(immunizationsDataModel, 'Expected valid non-null model to be returned.');
            Test.stopTest();
        }
    }

    private static VTC_PatientService createPatientService(Map<String, Object> args, Object returnValue) {
        return (VTC_PatientService) new VATEST_StubBuilder(VTC_PatientService.class)
            .mockingMethodCall('call')
            .withParameterTypes(String.class, Map<String, Object>.class)
            .withParameterValues('get_immunizations', args)
            .returning(returnValue)
            .defineStub();
    }

    private static User createTestUser() {
        return new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
    }
}
