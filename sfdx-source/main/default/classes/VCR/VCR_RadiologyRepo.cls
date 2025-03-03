/**
 * @description Shared repository for Radiology data
 * @author Booz Allen
 * @see VCR_RadiologyRepoTest dedicated test for this class
 * @see VTC_PatientService Class responsible for handshaking between Lab Repo and VTC
 */
public inherited sharing class VCR_RadiologyRepo {
    /**
     * @description - Static instance of the callable VTC Patient Service.
     */
    @TestVisible
    private static VTC_PatientService patientService = VTC_PatientService.instance;

    /**
     *  @description Fetch Radiology data for the given application & Patient (identified by icn) from the configured provider
     *  @param args - The arguments to pass to the provider
     *  @return VTC_DataModel - The data model containing the radiology data
     */
    public VTC_DataModel fetchRadiology(Map<String, Object> args) {
        return (VTC_DataModel) patientService.call('get_radiology', args);
    }
}
