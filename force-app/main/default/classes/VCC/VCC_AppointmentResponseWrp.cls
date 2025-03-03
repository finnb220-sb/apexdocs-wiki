/**
 * @author Kumar Balan
 * @group API - Bridg - Appointments
 * @description VCC wrapper for appointment response.
 */
public inherited sharing class VCC_AppointmentResponseWrp extends VCC_BaseResponseWrp {
    /**
     * @description Property for mapping appointment model to the appointment modal.
     */
    @AuraEnabled
    public VCC_AppointmentModal appointmentModal { get; set; }
}
