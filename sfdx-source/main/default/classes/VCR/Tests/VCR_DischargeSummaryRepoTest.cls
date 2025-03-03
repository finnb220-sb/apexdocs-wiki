/**
 * @description Test class for the VCR_DischargeSummary Repo.
 *
 * @see VCR_DischargeSummaryRepo
 */
@IsTest
private class VCR_DischargeSummaryRepoTest {
    @IsTest
    static void unitItCallsPatientServicePositive() {
        VATEST_StubTuple patientServiceStubTuple = new VATEST_StubBuilder(VTC_PatientService.class)
            .mockingMethodCall('call')
            .withParameterTypes(String.class, Map<String, Object>.class)
            .withParameterValues(VCR_DischargeSummaryRepo.DISCHARGE_SUMMARY_ACTION, new Map<String, Object>())
            .returning(new VTC_DataModel())
            .defineStubTuple();
        VCR_DischargeSummaryRepo.patientService = (VTC_PatientService) patientServiceStubTuple.stubbedClass;
        VTC_DataModel result;
        User vaVetUser = new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
        Test.startTest();
        System.runAs(vaVetUser) {
            result = new VCR_DischargeSummaryRepo().fetchDischargeSummary(new Map<String, Object>());
        }
        Test.stopTest();

        Assert.isNotNull(result, 'Expected non null response to be returned from patient service!');
        Assert.isTrue(
            patientServiceStubTuple.assertAllMockedMethodsWereCalled(),
            'Expected \'fetchDischargeSummary\' to call the  patientService.call() method.'
        );
    }
}
