/**
 * @description Repository class for the Directives Data
 * @author Booz Allen
 * @since   2024
 * @see VCR_DirectivesRepoTest for test
 * @see VTC_PatientService for VTC_DataModel callout
 */
public inherited sharing class VCR_DirectivesRepo {
    /**
     * @description Static instance of the callable VTC Patient Service.
     */
    @TestVisible
    private static VTC_PatientService patientService = VTC_PatientService.instance;

    /**
     * @description Fetch Directives data for the given application & Patient (identified by icn) from the configured provider
     * @param args - The arguments to pass to the provider ICN/National Id, max number to return, start date and end date of data to return
     * @return VTC_DataModel - The data model containing the labs data
     */
    public VTC_DataModel getDirectives(Map<String, Object> args) {
        return (VTC_DataModel) patientService.call('get_notes', args);
    }
}
