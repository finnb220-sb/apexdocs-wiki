/**
 * @description Repository class for external VTC Clinic records.
 * @author  Booz Allen Hamilton
 * @since  3/20/2024
 */
public inherited sharing class VCR_ClinicRepo {
    /**
     * @description - Static instance of the callable VTC Data Service.
     */
    @TestVisible
    private static VTC_PatientService patientService = VTC_PatientService.instance;

    /**
     * @description Returns a VTC_Record record based on the VTC_Clinic model
     * @param args  The arguments for the callout request (siteId and clinicIEN)
     * @return `VTC_Record`
     */
    public VTC_Record getClinicByIEN(Map<String, Object> args) {
        VTC_RecordModel model = (VTC_RecordModel) patientService.call('get_clinic_by_ien', args);
        VTC_Record clinic;
        if (!model?.records.isEmpty()) {
            clinic = model.records[0];
        }
        return clinic;
    }

    /**
     * @description Returns a list of VTC_Record records based on the VTC_Clinic model
     * @param requestBodyArgs  The arguments for the callout request (siteId and name)
     * @return `List<VTC_Record>`
     */
    public List<VTC_Record> getClinicsByName(Map<String, Object> requestBodyArgs) {
        VTC_RecordModel model = (VTC_RecordModel) patientService.call('get_clinic_by_name', requestBodyArgs);
        List<VTC_Record> clinicList;
        if (!model?.records.isEmpty()) {
            clinicList = model.records;
        }
        return clinicList;
    }
    /**
     * @description Returns a list of VTC_Record records based on the VTC_Clinic model
     * @param requestBodyArgs  The arguments for the callout request (siteId and queryIen)
     * @return `List<VTC_Record>`
     */
    public List<VTC_Record> getClinicsByProvider(Map<String, Object> requestBodyArgs) {
        VTC_RecordModel model = (VTC_RecordModel) patientService.call('get_clinics_by_provider', requestBodyArgs);
        List<VTC_Record> clinicList;
        if (!model?.records.isEmpty()) {
            clinicList = model.records;
        }
        return clinicList;
    }
}
