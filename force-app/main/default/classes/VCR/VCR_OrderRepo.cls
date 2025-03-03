/**
 * @description Shard repo for order data of patients
 * @author      Booz Allen
 * @since       2024
 *
 * @see VCR_OrderRepoTest dedicated test for this class
 * @see VTC_PatientService Class responsible for handshaking between repo and VTC
 */
public inherited sharing class VCR_OrderRepo {
    /**
     * @description - Static instance of the callable VTC Patient Service.
     */
    @TestVisible
    private static VTC_PatientService patientService = VTC_PatientService.instance;

    /**
     * @description fetch order data for the given application & Patient (identified by icn) from the configured provider
     * @param args - The arguments to pass to the provider
     * @return `VTC_DataModel` - The data model containing the order data
     */
    public VTC_DataModel fetchOrders(Map<String, Object> args) {
        return (VTC_DataModel) patientService.call('get_orders', args);
    }

    /**
     * @description fetch order data with pharmacy (includes flagged data) for the given application & Patient (identified by icn) from the configured provider
     * @param args - The arguments to pass to the provider
     * @return `VTC_DataModel` - The data model containing the order data
     */
    public VTC_DataModel fetchOrdersWithPharmacy(Map<String, Object> args) {
        return (VTC_DataModel) patientService.call('get_orders_with_pharmacy', args);
    }
}
