/**
 * @description Repository class for the VCC_Clinic_Schedule_Slot__c object and external ClinicScheduleSlot records.
 * @author  Booz Allen Hamilton
 * @since  3/20/2024
 * @see VTC_PatientService
 * @see VCR_ClinicScheduleSlotTest
 */
public with sharing class VCR_ClinicScheduleSlotRepo {
    /**
     * @description - Static instance of the callable VTC Patient Service.
     */
    @TestVisible
    private static VTC_PatientService patientService = VTC_PatientService.instance;

    /**
     * @description Fetches timeslot data From CHRONOS Endpoint scheduleByDateRange.
     *  utilizes the get_timeslots ZD_ApplicationConfiguration__mdt record
     *  for pointing VTC to the CHRONOS Provider and callout the scheduleByDateRange endpoint
     * @param args - The arguments to pass to the CHRO provider
     * @return VTC_RecordModel - The record model containing the timeslot data
     */
    public VTC_RecordModel fetchTimeslots(Map<String, Object> args) {
        return (VTC_RecordModel) patientService.call('get_timeslots', args);
    }
}
