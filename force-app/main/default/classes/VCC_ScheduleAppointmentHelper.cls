/**
 * @description This class is used to generate parameters needed for callouts when the user is scheduling an appointment for a patient.
 * @author Booz Allen Hamilton
 * @see VCC_ScheduleAppointmentController
 */
public with sharing class VCC_ScheduleAppointmentHelper {
    /**
     * @description  builds the map containing the parameters used to create an appointment
     * @param appointmentParams The appointment parameters that contain the necessary values needed to create an appointment.
     * @return `Map<String, Object>`
     */
    public static Map<String, Object> generateAppointmentParameters(
        VCC_ScheduleAppointmentController.AppointmentParams appointmentParams
    ) {
        return new Map<String, Object>{
            'application' => 'VAHC',
            'vistaSiteId' => appointmentParams?.facilityStationId,
            'vistaSiteName' => appointmentParams?.facilityStationName,
            'startDate' => appointmentParams?.start,
            'endDate' => appointmentParams?.xEnd,
            'patientIcn' => appointmentParams?.patientICN,
            'patientDfn' => appointmentParams?.patientDFN,
            'clinicIen' => appointmentParams?.clinicIEN,
            'clinicName' => appointmentParams?.clinicName,
            'providerIEN' => appointmentParams?.providerIEN,
            'apptType' => appointmentParams?.apptType,
            'duration' => appointmentParams?.duration,
            'apptRequestId' => appointmentParams?.apptRequestVistaId,
            'timeZone' => appointmentParams?.timeZone,
            'note' => appointmentParams?.note,
            'eligibilityOfVisit' => appointmentParams?.eligibilityOfVisit
        };
    }

    /**
     * @description  builds the map containing the parameters used to retrieve an appointment
     * @param appointmentParams The appointment parameters that contain the necessary values needed to retrieve an appointment.
     * @return `Map<String, Object>`
     */
    public static Map<String, Object> generateScheduledAppointmentParameters(
        VCC_ScheduleAppointmentController.AppointmentParams appointmentParams
    ) {
        return new Map<String, Object>{
            'application' => 'VAHC',
            'vistaSiteId' => appointmentParams?.facilityStationId,
            'startDate' => appointmentParams?.start,
            'endDate' => appointmentParams?.xEnd,
            'patientIcn' => appointmentParams?.patientICN,
            'patientDfn' => appointmentParams?.patientDFN,
            'clinicIen' => appointmentParams?.clinicIEN
        };
    }
}
