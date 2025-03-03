/**
 * @description Utilized for searching Medical Providers associated with Facilities.
 * @author Booz Allen Hamilton
 * @since  8/07/2024
 */
public with sharing class VCC_ProviderSearchController {
    @TestVisible
    /**
     * @description setting providerClinicRepo for querying Provider Clinic Assignment Records
     */
    private static VCR_ProviderRepo providerRepo {
        get {
            if (providerRepo == null) {
                providerRepo = new VCR_ProviderRepo();
            }
            return providerRepo;
        }
        private set;
    }
    /**
     * @description This method utilizes the VTC framework to search for Providers by name and siteId.
     * @param providerName The provider name is the Provider the User is searching for.
     * @param siteId The Id of the facility the user selected.
     * @return            `List<VTC_Record>`
     */
    @AuraEnabled(Cacheable=false)
    public static List<VTC_Record> searchProviders(String providerName, String siteId) {
        if (String.isBlank(siteId) || String.isBlank(providerName)) {
            throw VCC_ExceptionUtils.createAuraHandledException(
                'Invalid Request. Null/Empty request properties detected.'
            );
        }
        Map<String, Object> requestBodyArgs = new Map<String, Object>{
            'application' => 'VAHC',
            'vistaSiteId' => siteId,
            'name' => providerName
        };
        try {
            return providerRepo.searchProviders(requestBodyArgs);
        } catch (VTC_LimitException e) {
            Logger.error('Limit exception getting clinic information.', e);
            throw VTC_ExceptionUtils.createAuraHandledException(e.getMessage());
        } finally {
            Logger.saveLog();
        }
    }
}
