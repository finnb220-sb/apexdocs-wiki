/**
 * @description Repo class for retrieving Discharge Summaries from VTC.
 *
 * @see VCC_DischargeSummaryController
 * @see VTC_DataModel
 */
public inherited sharing class VCR_DischargeSummaryRepo {
    @TestVisible
    private static final String DISCHARGE_SUMMARY_ACTION = 'get_discharge_summaries';
    /**
     * @description - Singleton  of the callable VTC Patient Service. Used to make callouts via VTC
     */
    @TestVisible
    private static VTC_PatientService patientService {
        get {
            patientService = patientService ?? new VTC_PatientService();
            return patientService;
        }
        set;
    }

    /**
     * @description Fetch Discharge Summary data for the given application & Patient (identified by icn) from the configured provider
     * @param args - The arguments to pass to the provider
     * @return `VTC_DataModel` - The data model containing the labs data
     */
    public VTC_DataModel fetchDischargeSummary(Map<String, Object> args) {
        return (VTC_DataModel) patientService.call(DISCHARGE_SUMMARY_ACTION, args);
    }
}
