/**
 * @description Shared repository for Allergy data
 * @author Booz Allen
 *
 * @see VCR_AllergyRepoTest dedicated test for this class
 * @see VTC_PatientService Class responsible for handshaking between Lab Repo and VTC
 */
public inherited sharing class VCR_AllergyRepo {
    /**
     * @description - Static instance of the callable VTC Patient Service.
     */
    @TestVisible
    private static VTC_PatientService patientService = VTC_PatientService.instance;

    /**
     * @description Fetch Labs data for the given application & Patient (identified by icn) from the configured provider
     * @param args - The arguments to pass to the provider
     * @return VTC_DataModel - The data model containing the labs data
     */
    public VTC_DataModel fetchAllergies(Map<String, Object> args) {
        return (VTC_DataModel) patientService.call('get_allergies', args);
    }
}
