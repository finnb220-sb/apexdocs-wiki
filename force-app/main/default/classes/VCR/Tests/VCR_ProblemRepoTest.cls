/**
 * @description Tests the VCR_ProblemRepo class
 * @author Booz Allen
 *
 * @see VCR_ProblemRepo for class being tested
 */
@IsTest
private with sharing class VCR_ProblemRepoTest {
    @IsTest
    private static void ensureCorrectDefaultInitialization() {
        User vaVetUser = createTestUser();

        System.runAs(vaVetUser) {
            Test.startTest();
            Assert.isNotNull(VCR_ProblemRepo.patientService, 'Expected patientService to be initialized.');
            Test.stopTest();
        }
    }

    @IsTest
    private static void unitGetProblemReturnsValidDataWhenMockedPositive() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCR_ProblemRepo.patientService = createPatientService(args, new VTC_DataModel());
        System.runAs(createTestUser()) {
            Test.startTest();
            VTC_DataModel problemDataModel = new VCR_ProblemRepo().fetchProblems(args);
            Assert.isNotNull(problemDataModel, 'Expected valid non-null model to be returned.');
            Test.stopTest();
        }
    }

    private static VTC_PatientService createPatientService(Map<String, Object> args, Object returnValue) {
        return (VTC_PatientService) new VATEST_StubBuilder(VTC_PatientService.class)
            .mockingMethodCall('call')
            .withParameterTypes(String.class, Map<String, Object>.class)
            .withParameterValues('get_problems', args)
            .returning(returnValue)
            .defineStub();
    }

    private static User createTestUser() {
        return new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
    }
}
