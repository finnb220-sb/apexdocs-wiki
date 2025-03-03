/**
 * @description Tests the VCR_VisitRepo class
 * @author Booz Allen
 *
 * @see VCR_VisitRepo for class being tested
 */
@IsTest
private with sharing class VCR_VisitRepoTest {
    @IsTest
    private static void ensureCorrectDefaultInitialization() {
        System.runAs(createTestUser()) {
            Test.startTest();
            Assert.isNotNull(VCR_VisitRepo.patientService, 'Expected patientService to be initialized.');
            Test.stopTest();
        }
    }

    @IsTest
    private static void fetchVisits() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCR_VisitRepo.patientService = createPatientService(args, new VTC_DataModel());
        System.runAs(createTestUser()) {
            Test.startTest();
            VTC_DataModel visitDataModel = new VCR_VisitRepo().fetchVisits(args);
            Assert.isNotNull(visitDataModel, 'Expected valid non-null model to be returned.');
            Test.stopTest();
        }
    }

    private static VTC_PatientService createPatientService(Map<String, Object> args, Object returnValue) {
        return (VTC_PatientService) new VATEST_StubBuilder(VTC_PatientService.class)
            .mockingMethodCall('call')
            .withParameterTypes(String.class, Map<String, Object>.class)
            .withParameterValues('get_visits', args)
            .returning(returnValue)
            .defineStub();
    }

    private static User createTestUser() {
        return new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
    }
}
