/**
 * @description Controller class for the vccClinicSearch LWC. This controller is used to return Clinics to the vccClinicSearch LWC
 * @author Booz Allen Hamilton
 * @since 3/21/2024
 * @group Object - VCC_Clinic__c
 */
public with sharing class VCC_ClinicSearchController {
    @TestVisible
    private static VCR_ClinicRepo clinicRepo {
        get {
            if (clinicRepo == null) {
                clinicRepo = new VCR_ClinicRepo();
            }
            return clinicRepo;
        }
        private set;
    }

    /**
     * @description This method utilizes the VTC framework to search for clinics by name and siteId.
     * @param clinicName The clinicName of the Clinic the User is searching for.
     * @param siteId The Id of the facility the user selected.
     * @return            `List<VTC_Record>`
     */
    @AuraEnabled(Cacheable=false)
    public static List<VTC_Record> getClinicsByName(String clinicName, String siteId) {
        if (String.isBlank(siteId) || String.isBlank(clinicName)) {
            throw VCC_ExceptionUtils.createAuraHandledException(
                'Invalid Request. Null/Empty request properties detected.'
            );
        }
        Map<String, Object> requestBodyArgs = new Map<String, Object>{
            'application' => 'VAHC',
            'vistaSiteId' => siteId,
            'name' => clinicName
        };
        try {
            return clinicRepo.getClinicsByName(requestBodyArgs);
        } catch (VTC_LimitException e) {
            Logger.error('Limit exception getting clinic information.', e);
            throw VTC_ExceptionUtils.createAuraHandledException(e.getMessage());
        } finally {
            Logger.saveLog();
        }
    }
}
