/**
 * @description Test class for VCR_ProviderRepo
 * @author Booz Allen Hamilton
 * @since  08/07/2024
 * @see VCR_ProviderRepo
 */
@IsTest
private class VCR_ProviderRepoTest {
    final static User MSA_USER = new VATEST_UserBuilder()
        .withPermissionSet('VCC_Advanced_Medical_Support_Assistant')
        .withPermissionSet('VAHC_Scheduling_User')
        .withUserProfile('VAVET Base Profile')
        .withStandardData()
        .build(true);

    /**
     * @description Test method that confirms that the getClinicByName method returns an expected Clinic.
     */
    @IsTest
    static void funcSearchProvidersPositive() {
        VTC_RecordModel stubModel = new VTC_RecordModel();
        VTC_Provider provider = new VTC_provider();
        stubModel.records.add((VTC_Record) provider);
        List<VTC_Record> providerRecordLst;
        System.runAs(MSA_USER) {
            Map<String, Object> args = new Map<String, Object>{
                'application' => 'VAHC',
                'vistaSiteId' => '984',
                'name' => 'test'
            };
            Test.startTest();
            VCR_ProviderRepo repo = new VCR_ProviderRepo();
            VCR_ProviderRepo.patientService = createPatientService('search_providers', args, stubModel);
            providerRecordLst = (List<VTC_Record>) repo.searchProviders(args);
            Test.stopTest();
        }
        Assert.isNotNull(providerRecordLst, 'Assertion failed; expected a valid VTC_Record to be returned');
    }

    /**
     * @description       This method is used to stub the VTC_DataService
     * @param action    The vtc endpoint to target
     * @param args        The arguments for the call
     * @param returnValue The model to return
     * @return            `VTC_DataService`
     */
    private static VTC_PatientService createPatientService(
        String action,
        Map<String, Object> args,
        Object returnValue
    ) {
        return (VTC_PatientService) new VATEST_StubBuilder(VTC_PatientService.class)
            .mockingMethodCall('call')
            .withParameterTypes(String.class, Map<String, Object>.class)
            .withParameterValues(action, args)
            .returning(returnValue)
            .defineStub();
    }
}
