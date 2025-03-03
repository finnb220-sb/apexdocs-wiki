/**
 * @description Tests the VCR_LabRepo class
 * @author Booz Allen
 *
 * @see VCR_LabRepo for class being tested
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest
private with sharing class VCR_LabRepoTest {
    @IsTest
    private static void ensureCorrectDefaultInitialization() {
        Test.startTest();
        VCR_LabRepo labRepo = new VCR_LabRepo();
        Test.stopTest();

        Assert.isTrue(labRepo != null, 'Expected class to be initialized.');
        Assert.isTrue(VCR_LabRepo.patientService != null, 'Expected patientService to be initialized.');
    }

    @IsTest
    private static void unitGetLabsReturnsValidDataWhenMockedPositive() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCR_LabRepo.patientService = createPatientService(args, new VTC_DataModel());
        User vaVetUser = createTestUser();

        System.runAs(vaVetUser) {
            Test.startTest();
            VTC_DataModel labDataModel = (VTC_DataModel) new VCR_LabRepo().fetchLabs(args);
            Assert.isTrue(labDataModel != null, 'Expected valid non-null model to be returned.');
            Test.stopTest();
        }
    }

    private static VTC_PatientService createPatientService(Map<String, Object> args, Object returnValue) {
        return (VTC_PatientService) new VATEST_StubBuilder(VTC_PatientService.class)
            .mockingMethodCall('call')
            .withParameterTypes(String.class, Map<String, Object>.class)
            .withParameterValues('get_labs', args)
            .returning(returnValue)
            .defineStub();
    }

    private static User createTestUser() {
        return new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
    }
}
