/**
 * @author Kumar Balan
 * @group API - Bridg - Appointments
 * @description Controller class for VCC Appointments.
 */
public with sharing class VCC_AppointementController {
    /**
     * @description Fetches appointments
     * @param appointmentReqWrp
     *
     * @return
     */
    @AuraEnabled
    public static VCC_AppointmentResponseWrp getAppointments(VCC_AppointmentLightningRequestWrp appointmentReqWrp) {
        if (appointmentReqWrp == null) {
            throw new VCC_InternalException();
        }

        VCC_Workstream_Settings__mdt workstreamSettings = VCC_WorkstreamSettingsController.getWorkstreamSettings();
        VCC_BridgAppointmentsRQ appointmentRQ = new VCC_BridgAppointmentsRQ(
            VCC_QuerySelector.getContactNationalID(appointmentReqWrp.recordId),
            'USVHA',
            Integer.valueOf(workstreamSettings.VCC_Appointments_Duration__c)
        );
        appointmentRQ.assigningFacility = appointmentReqWrp.facility;

        Logger.debug('VCC_AppointmentsController Request: ' + JSON.serialize(appointmentRQ));
        Logger.saveLog();

        try {
            // Training Mode
            if (!Test.isRunningTest() && VCC_TrainingModeService.isTrainingModeEnabled()) {
                return getTrainingModeAppointments(appointmentReqWrp);
            }

            Logger.debug('VCC_AppointmentsController Request: ' + JSON.serialize(appointmentRQ));
            Logger.debug('Patient Requisition ' + VCC_QuerySelector.getContactNationalID(appointmentReqWrp.recordId));
            Logger.saveLog();

            // Live Service
            return VCC_Adapter_BridgToLWC.vccAppointment((new VCC_BridgClient(new Set<VCC_BaseClient.ClientOption>{})).appointments(appointmentRQ));
        } catch (Exception e) {
            return new VCC_AppointmentResponseWrp();
        }
    }

    @TestVisible
    private static VCC_AppointmentResponseWrp getTrainingModeAppointments(VCC_AppointmentLightningRequestWrp appointmentReqWrp) {
        if (appointmentReqWrp != null && appointmentReqWrp.recordId != null) {
            VCC_AppointmentResponseWrp appointmentResWrp = new VCC_AppointmentResponseWrp();
            appointmentResWrp.appointmentModal = (VCC_AppointmentModal) JSON.deserialize(
                VCC_TrainingModeService.getAppointmentsByAccountId(appointmentReqWrp.recordId),
                VCC_AppointmentModal.class
            );

            Logger.debug('VCC_AppointmentsController: ' + JSON.serialize(appointmentResWrp));
            Logger.saveLog();
            return appointmentResWrp;
        }

        return null;
    }
}
