/**
 * @description Invocable method called from VCC_Review_New_Appointment_Subflow when creating new VCV Service Appointment
 * The subflow is called from New Appointment By Time and New Appointment By Provider.
 * @author Booz Allen Hamilton
 * @see VTC_CHROCreateVVSAppointmentRQ
 * @see VCC_Review_New_Appointment_Subflow
 * @justification InnerClassNamingConventions - Exception class
 */
public with sharing class VCC_CHROVVSAppointmentInvocable {
    /**
     * @description VTC_PatientService memoization. Getter returns a new instance if one does not exist, otherwise returns the existing instance.
     */
    public static VTC_PatientService patientService {
        get {
            return patientService = patientService ?? new VTC_PatientService();
        }
        set;
    }

    /**
     * @description Called from the Flow when scheduling a VCV Service Appointment.
     * @param flowInput - for Invocable method, it's bulkified, pass in a string from Flow, parameter must be List<String>
     * @return `List<String>` for Invocable method, must return a List
     */
    @InvocableMethod(Label='Create VVS Appointment Invocable' Description='Get VVS Link for Service Appointment')
    public static List<String> createVVSAppointment(List<String> flowInput) {
        try {
            Map<String, Object> vvsRQParams = (Map<String, Object>) JSON.deserializeUntyped(flowInput[0]);
            VTC_CHROCreateAppointmentModel model = (VTC_CHROCreateAppointmentModel) patientService.call(
                'create_vvs_appointment',
                vvsRQParams
            );
            return new List<String>{ model.url };
        } catch (Exception e) {
            Logger.error('Error getting VVS link: ' + e.getMessage() + ' | ' + e.getStackTraceString());
            throw new VCC_CHROVVSAppointmentInvocableException('Error getting VVS link: ' + e.getMessage());
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description Custom Exception to be thrown when there are issues with the VVS callout.
     * Exception can be caught by calling class or Flow fault path.
     * @see VCC_Review_New_Appointment_Subflow
     */
    @TestVisible
    @SuppressWarnings('PMD.ExtendedClassNamingConventionsRule')
    private class VCC_CHROVVSAppointmentInvocableException extends Exception {
    }
}
