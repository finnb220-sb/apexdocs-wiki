/**
 * @author Booz Allen Hamilton
 * @since 5/21/24
 * @description Repository for VCC_Appointment_Slot_Config__mdt
 *
 * Does not extend base repo since custom metadata is not an sObject.
 * @see VCC_AppointmentUtilizationService
 */
public inherited sharing class VCR_AppointmentSlotConfigRepo {
    /**
     * @description Wrapper around getAll() so that we can stub/mock.
     *
     * @return `Map<String, VCC_Appointment_Slot_Config__mdt>` map of Appointment Slot Duration (in minutes) keyed off VISN Names.
     */
    public Map<String, VCC_Appointment_Slot_Config__mdt> fetchAppointmentSlotConfigs() {
        return VCC_Appointment_Slot_Config__mdt.getAll();
    }
}
