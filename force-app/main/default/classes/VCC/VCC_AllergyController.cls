/**
 * @author Kumar Balan
 * @group API - Bridg - Allergy
 * @description Provides apex controller for Allergy UX.
 * @see `VCR_HealthDataRepo` to see the shape of the Health Data Config returned to LWC
 */
public with sharing class VCC_AllergyController {
    /**
     * @description Fetches allergies
     * @param allergyReqWrp
     * @return VCC_AllergyResponseWrp
     */
    @AuraEnabled
    public static VCC_AllergyResponseWrp getAllergy(VCC_AllergyLightningRequestWrp allergyReqWrp) {
        return new VCC_AllergyService().getAllergy(allergyReqWrp);
    }

    /**
     * @description instantiates a allergies health data repo
     */
    @TestVisible
    private static VCR_HealthDataRepo healthDataRepo {
        get {
            if (healthDataRepo == null) {
                healthDataRepo = new VCR_HealthDataRepo('allergies');
            }
            return healthDataRepo;
        }
        set;
    }

    /**
     * @description - Gets Patient birthyear, and workstream settings, primarily used for the "load more" functionality of this HDR LWC
     * @param icn - ICN to query org against
     * @return Returns patient birthyear, and workstream settings
     */
    @AuraEnabled(Cacheable=true)
    public static VCR_HealthDataRepo.Model fetchHealthDataConfig(String icn) {
        healthDataRepo.setPatientByICN(icn);
        return healthDataRepo.fetchHealthDataConfig();
    }
}
