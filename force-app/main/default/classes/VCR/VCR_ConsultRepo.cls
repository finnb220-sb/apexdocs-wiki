/**
 * @description Shared repository for Consult data
 * @author Booz Allen
 * @see VCR_ConsultRepoTest dedicated test for this class
 * @see VTC_PatientService Class responsible for handshaking between Consult Repo and VTC
 */
public inherited sharing class VCR_ConsultRepo {
    /**
     * @description - Static instance of the callable VTC Patient Service.
     */
    @TestVisible
    private static VTC_PatientService patientService = VTC_PatientService.instance;

    /**
     * @description Fetch Consults data for the given application & Patient (identified by icn) from the configured provider
     * @param args - The arguments to pass to the provider
     * @return VTC_DataModel - The data model containing the labs data
     */
    public VTC_DataModel fetchConsults(Map<String, Object> args) {
        return (VTC_DataModel) patientService.call('get_consults', args);
    }
}
