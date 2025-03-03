/**
 * @description This class provides functionality to fetch and manage alert data
 *              for a given application by extending the VTC_BaseRepo. It utilizes
 *              the VTC_PatientService to retrieve alert information.
 * @author Booz Allen
 * @see VTC_PatientService
 */
public virtual inherited sharing class VCR_AlertRepo {
    private static final String GET_ALERTS = 'get_alerts';
    /**
     * @description - Static instance of the callable VTC Patient Service.
     */
    @TestVisible
    private static VTC_PatientService patientService = VTC_PatientService.instance;

    /**
     * @description Fetch Alerts data for the given application
     * @param args - The arguments to pass to the provider
     * @return VTC_DataModel - The data model containing the alert data
     */
    public VTC_RecordModel fetchAlerts(Map<String, Object> args) {
        VTC_RecordModel model = (VTC_RecordModel) patientService.call(GET_ALERTS, args);
        return model;
    }
}
