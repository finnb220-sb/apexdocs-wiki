/**
 * @description Tests the VCR_RadiologyRepo class
 * @author Booz Allen
 *
 * @see VCR_RadiologyRepo for class being tested
 */
@IsTest
private with sharing class VCR_RadiologyRepoTest {
    @IsTest
    private static void ensureCorrectDefaultInitialization() {
        User vaVetUser = createTestUser();
        System.runAs(vaVetUser) {
            Test.startTest();
            Assert.isNotNull(VCR_RadiologyRepo.patientService, 'Expected patientService to be initialized.');
            Test.stopTest();
        }
    }

    @IsTest
    private static void unitGetRadiologyReturnsValidDataWhenMockedPositive() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCR_RadiologyRepo.patientService = createPatientService(args, new VTC_DataModel());
        System.runAs(createTestUser()) {
            Test.startTest();
            VTC_DataModel radiologyDataModel = new VCR_RadiologyRepo().fetchRadiology(args);
            Assert.isNotNull(radiologyDataModel, 'Expected valid non-null model to be returned.');
            Test.stopTest();
        }
    }

    private static VTC_PatientService createPatientService(Map<String, Object> args, Object returnValue) {
        return (VTC_PatientService) new VATEST_StubBuilder(VTC_PatientService.class)
            .mockingMethodCall('call')
            .withParameterTypes(String.class, Map<String, Object>.class)
            .withParameterValues('get_radiology', args)
            .returning(returnValue)
            .defineStub();
    }

    private static User createTestUser() {
        return new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
    }
}
