/**
 * @description Repository class for VCC_ProviderIIc and external VTC CHRONOS Provider records.
 * @author  Booz Allen Hamilton
 * @since  08/07/2024
 */
public with sharing class VCR_ProviderRepo {
    /**
     * @description - Static instance of the callable VTC Data Service.
     */
    @TestVisible
    private static VTC_PatientService patientService = VTC_PatientService.instance;

    /**
     * @description Returns a list of VTC_Record records based on the VTC_Provider model
     * @param requestBodyArgs  The arguments for the callout request (siteId and name)
     * @return `List<VTC_Record>`
     */
    public list<VTC_Record> searchProviders(Map<String, Object> requestBodyArgs) {
        VTC_RecordModel model = (VTC_RecordModel) patientService.call('search_providers', requestBodyArgs);
        List<VTC_Record> providerList;
        if (!model?.records.isEmpty()) {
            providerList = model.records;
        }
        return providerList;
    }
}
