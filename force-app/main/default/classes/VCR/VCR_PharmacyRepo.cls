/**
 * @description Shared repository for Pharmacy data
 * @author Booz Allen
 */
public inherited sharing class VCR_PharmacyRepo {
    /**
     * @description Static instance of the callable VTC Patient Service.
     */
    @TestVisible
    private static VTC_PatientService patientService = VTC_PatientService.instance;
    private static String getTempAddress = 'get_temp_address';
    private static String getTempAddresses = 'get_temp_addresses';
    private static String getMailingAddress = 'get_mailing_addresses';
    private static String updateMailingAddress = 'update_mailing_addresses';

    /**
     * @description Get Temporary Address data for the given application & Patient (identified by icn) from the configured provider
     *  @param args - The arguments to pass to the provider, for example, if the string is 'icn' the object would be the actual icn value.
     *  @return VTC_RecordModel record model for singular temp address
     */
    public VTC_RecordModel getTemporaryAddress(Map<String, Object> args) {
        return (VTC_RecordModel) patientService.call(getTempAddress, args);
    }

    /**
     * @description Get Temporary Addresses data for the given application & Patient (identified by icn) from the configured provider
     *  @param args - The arguments to pass to the provider, for example, if the string is 'icn' the object would be the actual icn value.
     *  @return VTC_DataModel record for multiple temp addresses
     */
    public VTC_DataModel getTemporaryAddresses(Map<String, Object> args) {
        return (VTC_DataModel) patientService.call(getTempAddresses, args);
    }

    /**
     * @description Get Mailing Addresses data for the given application &
     * Patient (identified by icn) & Facilities (identified by facilityIds)
     * from the configured provider
     *  @param args - The arguments to pass to the provider, for example, if the string is 'icn' the object would be the actual icn value.
     *  @return VTC_DataModel data model used to return potential multiple mailing addresses.
     */
    public VTC_DataModel getMailingAddresses(Map<String, Object> args) {
        return (VTC_DataModel) patientService.call(getMailingAddress, args);
    }

    /**
     * @description Update Mailing Addresses data for the given application &
     * Patient (identified by icn) & Facilities (identified by facilityIds)
     * via the configured provider
     *  @param args - The arguments to pass to the provider are application, site, ssoToken
     *  @return VTC_DataModel data model used to return the update result of multiple address updates
     */
    public VTC_DataModel updateMailingAddresses(Map<String, Object> args) {
        return (VTC_DataModel) patientService.call(updateMailingAddress, args);
    }
}
