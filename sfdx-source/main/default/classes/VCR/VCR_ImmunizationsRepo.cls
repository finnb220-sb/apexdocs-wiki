/**
 * @description Shared repository for Visit data
 * @author Booz Allen
 * @see VCR_ImmunizationsRepoTest dedicated test for this class
 * @see VTC_PatientService Class responsible for handshaking between Immunizations Repo and VTC
 */
public inherited sharing class VCR_ImmunizationsRepo {
    /**
     * @description - Static instance of the callable VTC Patient Service.
     */
    @TestVisible
    private static VTC_PatientService patientService = VTC_PatientService.instance;

    /**
     *  @description Fetch Immunizations data for the given application & Patient (identified by icn) from the configured provider
     *  @param args - The arguments to pass to the provider
     *  @return VTC_DataModel - The data model containing the immunizations data
     */
    public VTC_DataModel fetchImmunizations(Map<String, Object> args) {
        return (VTC_DataModel) patientService.call('get_immunizations', args);
    }
}
