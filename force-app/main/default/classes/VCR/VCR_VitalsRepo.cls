/**
 * @description Shared repository for Vitals data
 * @author Booz Allen
 *
 * @see VCR_VitalsRepoTest dedicated test for this class
 * @see VTC_PatientService Class responsible for handshaking between Vitals Repo and VTC
 */
public inherited sharing class VCR_VitalsRepo {
    /**
     * @description - Static instance of the callable VTC Patient Service.
     */
    @TestVisible
    private static VTC_PatientService patientService = VTC_PatientService.instance;

    /**
     * @description Fetch Vitals data for the given application & Patient (identified by icn) from the configured provider
     * @param args - The arguments to pass to the provider
     * @return `VTC_DataModel` - The data model containing the vitals data
     */
    public VTC_DataModel fetchVitals(Map<String, Object> args) {
        return (VTC_DataModel) patientService.call('get_vitals', args);
    }
}
