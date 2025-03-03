/**
 * @description OmniStudio remote action for Scheduling
 * @author Booz Allen Hamilton
 */
public with sharing class VCC_SchedulingOmniConnector extends VCC_OmniRemoteAction {
    private static final String VAHC_APP_NAME = 'VAHC';
    private static final String CALL_EXCEPTION_LOG_MESSAGE_TEMPLATE = 'Exception occurred while executing method "{0}"';
    @TestVisible
    private static final String MISSING_APPOINTMENT_MAP_MESSAGE = 'Map<String, Object> appointment is null. Unable to add #NLT# tag to appointment comments';

    // various map keys
    @TestVisible
    private static final String APPOINTMENT_KEY = 'appointment';
    @TestVisible
    private static final String UPDATED_APPOINTMENT_KEY = 'updatedAppointment';
    @TestVisible
    private static final String ID_KEY = 'id';
    @TestVisible
    private static final String SITE_ID_KEY = 'siteId';
    @TestVisible
    private static final String NOTE_KEY = 'note';

    @TestVisible // exception thrown in call() when argTuple.methodName doesn't match any switch conditions
    private static final String METHOD_DOES_NOT_EXIST_MESSAGE = 'Method does not exist';

    /**
     * @description memoization of VCR_AppointmentRepo
     */
    @TestVisible
    public static VCR_AppointmentRepo appointmentRepo {
        get {
            return appointmentRepo = appointmentRepo ?? new VCR_AppointmentRepo();
        }
        private set;
    }

    /**
     * @description Implementation of VCC_OmniRemoteAction.call(String, ArgTuple). Given a method name and
     * OmniStudio args (input, output, and options) execute the apex associated with the method name, passing in the args (or not, up to you).
     * @param argTuple the OmniStudio args (input, output, and options)
     * @return `Object` Boolean result of call(). true being success, false otherwise.
     */
    @TestVisible
    protected override Object call(VCC_OmniRemoteAction.ArgTuple argTuple) {
        Boolean result = true;
        try {
            switch on argTuple?.methodName {
                when 'updateAppointmentWithNLT' {
                    this.updateAppointmentWithNLT(argTuple);
                }
                when else {
                    throw new IllegalArgumentException(METHOD_DOES_NOT_EXIST_MESSAGE);
                }
            }
        } catch (Exception anyThrownException) {
            Logger.error(
                String.format(CALL_EXCEPTION_LOG_MESSAGE_TEMPLATE, new List<String>{ argTuple?.methodName ?? 'null' }),
                anyThrownException
            );
            Logger.saveLog();
            result = false;
        }
        return result;
    }

    /**
     * @description adds "No Later Than" tag (#NLT#) to the beginning of an appointment comment
     * @param argTuple the OmniStudio args (input, output, options).
     * The input map must have two fields, "appointment", and "siteId".
     *  - "siteId" is the vista site the appointment belongs to
     *  - "appointment" is another Map<String, Object> that has at least an "id" field (external Id) and optional "note" field (see VTC_CHROUpdateAppointmentRQ)
     */
    @TestVisible
    private void updateAppointmentWithNLT(VCC_OmniRemoteAction.ArgTuple argTuple) {
        // create new appointment map with #NLT# prefix
        Map<String, Object> appointmentMapWithNlt = createNewAppointmentMapWithNlt(
            (Map<String, Object>) argTuple.input.get(APPOINTMENT_KEY)
        );
        // create new VCC_Appointment__c object with #NLT# prefix
        VCC_Appointment__c appointmentForUpsert = new VCC_Appointment__c(
            VCC_Appointment_Id__c = (String) appointmentMapWithNlt.get(ID_KEY),
            VCC_Note__c = (String) appointmentMapWithNlt.get(NOTE_KEY)
        );

        VTC_Appointment updatedAppointment = this.updateAppointment(
            appointmentForUpsert,
            appointmentMapWithNlt,
            (String) argTuple.input.get(SITE_ID_KEY)
        );

        // return updatedAppointment
        argTuple.output.put(
            UPDATED_APPOINTMENT_KEY,
            // round-trip serialize/deserialize was needed to avoid an error from the integration procedure "Type cannot be serialized"
            JSON.deserializeUntyped(JSON.serialize(updatedAppointment))
        );
    }

    @TestVisible
    private VTC_Appointment updateAppointment(
        VCC_Appointment__c appointmentSObject,
        Map<String, Object> appointmentMap,
        String siteId
    ) {
        // dry-run upsert of our local VCC_Appointment__c record with the given appointment ID
        SavePoint beforeUpsertSavePoint = Database.setSavepoint();
        appointmentrepo.upsertAppointmentByAppointmentId(
            // cloning to ensure no impact the original object in memory
            appointmentSObject.clone(true, true, true, true)
        );
        Database.rollback(beforeUpsertSavePoint);
        Database.releaseSavepoint(beforeUpsertSavePoint);

        //update the appointment via chronos API
        VTC_RecordModel appointmentRecordModel = appointmentRepo.updateAppointment(
            siteId,
            appointmentMap,
            VAHC_APP_NAME
        );

        // real upsert after successful dry-run and API call
        appointmentrepo.upsertAppointmentByAppointmentId(appointmentSObject);

        return (VTC_Appointment) appointmentRecordModel?.records?.get(0);
    }

    @TestVisible
    private Map<String, Object> createNewAppointmentMapWithNlt(Map<String, Object> appointment) {
        if (appointment == null) {
            throw new IllegalArgumentException(MISSING_APPOINTMENT_MAP_MESSAGE);
        }
        return new Map<String, Object>{
            ID_KEY => appointment.get(ID_KEY),
            NOTE_KEY => System.Label.VCC_ApptCommentNLT +
            ' ' +
            (appointment.get(NOTE_KEY) ?? '')
        };
    }
}
