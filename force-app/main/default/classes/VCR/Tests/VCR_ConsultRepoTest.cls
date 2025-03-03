/**
 * @description Tests the VCR_ConsultRepo class
 * @author Booz Allen
 *
 * @see VCR_ConsultRepo for class being tested
 *
 * NOTE: Suppressing warning for PMD.ApexUnitTestClassShouldHaveRunAs as there is no need to use System.RunAs for the repository functional tests.
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest
private with sharing class VCR_ConsultRepoTest {
    @IsTest
    private static void unitTestGetConsultsReturnsValidDataWhenMockedPositive() {
        String action = 'get_consults';
        Map<String, Object> args = new Map<String, Object>{ 'application' => 'VAHC', 'icn' => 'fakeICN' };
        VTC_DataModel expected = new VTC_DataModel();

        VCR_ConsultRepo.patientService = (VTC_PatientService) new VATEST_StubBuilder(VTC_PatientService.class)
            .mockingMethodCall('call')
            .withParameterTypes(String.class, Map<String, Object>.class)
            .withParameterValues(action, args)
            .returning(expected)
            .defineStub();

        Test.startTest();
        VTC_DataModel consultDataModel = (VTC_DataModel) new VCR_ConsultRepo().fetchConsults(args);
        Test.stopTest();

        Assert.isTrue(consultDataModel != null, 'Expected valid non-null model to be returned.');
    }
}
