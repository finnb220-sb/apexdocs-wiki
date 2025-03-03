/**
 * @description VCR_AppointmentRepo is a repository class used to create VCC_Appointment records
 * @author Booz Allen Hamilton
 * @justification getQueryLocator uses SYSTEM_MODE to query VCC_Appointment__c records for the scheduled batch class.
 * The user that schedules the job will be System Admin but may not have all necessary object and field access.
 * Using a query run in SYSTEM_MODE solves this issue for the batch class to run successfully,
 * without having to grant additional permissions to the user that would not be needed beyond batch class.
 */
public inherited sharing class VCR_AppointmentRepo extends VTC_BaseRepo {
    /**
     * @description Constructor for VCR_AppointmentRepo.
     */
    public VCR_AppointmentRepo() {
        super(VCC_Appointment__c.sObjectType);
    }

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
     * @description upserts an appointment by external ID field VCC_Appointment_Id__c
     * @param appointment the appointment to upsert
     * @return `Database.UpsertResult` the upsert result
     */
    public Database.UpsertResult upsertAppointmentByAppointmentId(VCC_Appointment__c appointment) {
        return Database.upsert(
            appointment,
            VCC_Appointment__c.Fields.VCC_Appointment_Id__c,
            this.allOrNone,
            AccessLevel.USER_MODE
        );
    }

    /**
     * @description Calls va-teams-core-chro /svas/updateAppointment. By passing 'update_appointment' and the given application name into VTC_PatientService.call,
     * VTC_PatientService will query ZD_ApplicationConfiguration__mdt and construct a new instance of the client specified in the ZD_ApplicationConfiguration metadata.
     * @param siteId the VistA site id where the appointment exists
     * @param appointment the map containing appointment information
     * @param applicationName the application name
     * @return `VTC_RecordModel`
     */
    public VTC_RecordModel updateAppointment(String siteId, Map<String, Object> appointment, String applicationName) {
        return (VTC_RecordModel) patientService.call(
            'update_appointment',
            this.mapUpdateAppointmentArgs(siteId, appointment, applicationName)
        );
    }

    /**
     * @description Generates a map containing parameters for updating an Appointment
     * @param siteId the VistA site id where the appointment exists
     * @param appointment a map containing appointment information
     * @param applicationName the application name
     * @return `Map<String, Object>`
     */

    @TestVisible
    private Map<String, Object> mapUpdateAppointmentArgs(
        String siteId,
        Map<String, Object> appointment,
        String applicationName
    ) {
        return new Map<String, Object>{
            'siteId' => siteId,
            'application' => applicationName,
            'appointment' => appointment
        };
    }

    /**
     * @description  Retrieves a Patient's Scheduled Appointment Records That are Greater Than or Equal to Today.
     * @param patientId - Account Id to find appointment records associated to Patient.
     * @return `List<VCC_Appointment__c>` - List of Appointment Records to be used to compare against selected Time Slot Date.
     */
    public List<VCC_Appointment__c> getExistingAppointments(String patientId) {
        Map<String, Object> binds = new Map<String, Object>{ 'patientId' => patientId };
        String selectClause = 'SELECT VCC_Clinic_Name__c, VCC_Clinic_IEN__c, VCC_Patient__c, VCC_Time_Zone__c, VCC_Duration__c, VCC_Appointment_Start__c, VCC_Appointment_End__c, VCC_Status__c ';
        String fromClause = this.calculateFromClause();
        String whereClause = ' WHERE VCC_Patient__c = :patientId AND VCC_Appointment_Start__c >= TODAY AND VCC_Status__c = \'booked\'';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause;
        return this.fetch(query, binds);
    }

    /**
     * @description Calls va-teams-core-chro /svas/createAppointment endpoint to create an appointment record and returns a VTC_GenericModel record model. By passing 'create_appointment' and other parameters into VTC_PatientService.call,
     * VTC_PatientService will query ZD_ApplicationConfiguration__mdt and construct a new instance of the client specified in the ZD_ApplicationConfiguration metadata. An example of the map passed in
     * is shown below.
     * Map<String, Object>{
     *       'application' => 'VAHC',
     *       'vistaSiteId' => '984',
     *       'vistaSiteName' => 'DAYTSHR TEST LAB',
     *       'startDate' => '2024-08-01T18:00:00:00Z',
     *       'endDate' => '2024-08-01T19:00:00:00Z',
     *       'patientIcn' => '1015777398V425985',
     *       'patientDfn' => '5541234875',
     *       'clinicIen' => '3985',
     *       'clinicName' => 'DAYTSHR Clinic',
     *       'providerIEN' => '34117',
     *       'apptType' => 'REGULAR',
     *       'duration' => 60,
     *       'apptRequestId' => 'R98444220',
     *       'timeZone' => 'EASTERN',
     *       'note' => 'Test Note',
     *       'eligibilityOfVisit' => 'SC LESS THAN 50%'
     *   };
     * The application, vistaSiteId, startDate, endDate, and patientIcn or patientDfn are required.
     * @param params  The arguments for the callout request
     * @return `VTC_GenericModel`
     */
    public VTC_GenericModel createAppointment(Map<String, Object> params) {
        VTC_GenericModel model = (VTC_GenericModel) patientService.call('create_appointment', params);
        return model;
    }

    /**
     * @description Calls va-teams-core-chro /svas/appointments endpoint to fetch an appointment record and returns a VTC_Appointment record. By passing 'get_scheduling_appointments' and other parameters into VTC_PatientService.call,
     * VTC_PatientService will query ZD_ApplicationConfiguration__mdt and construct a new instance of the client specified in the ZD_ApplicationConfiguration metadata. An example of the map passed in
     * is shown below.
     * Map<String, Object>{
     *       'application' => 'VAHC',
     *       'vistaSiteId' => '984',,
     *       'startDate' =>  '2024-08-01T18:00:00:00Z',
     *       'endDate' => '2024-08-01T19:00:00:00Z',
     *       'patientIcn' => '1015777398V425985',,
     *       'patientDfn' => '5541234875',
     *       'clinicIen' => '3985'
     *   };
     * The application, vistaSiteId, startDate, and endDate are required.
     * @param params  The arguments for the callout request
     * @return `VTC_Appointment`
     */
    public VTC_Appointment getAppointment(Map<String, Object> params) {
        VTC_RecordModel model = (VTC_RecordModel) patientService.call('get_scheduling_appointments', params);
        VTC_Appointment appointment;
        if (!model?.records.isEmpty()) {
            appointment = (VTC_Appointment) model.records[0];
        }
        return appointment;
    }

    /**
     * @description Returns a string to be used in getQueryLocatorWithBinds.
     * @param dateTimeHoursAgo - DateTime value to compare records based on LastModifiedDate.
     * @return `String` - Query string for VCC_Appointment__c records that includes a filter for
     * LastModifiedDate in the WHERE clause.
     * @see VCC_AppointmentDataBatchDelete
     */
    public String getStaleApptQueryString(DateTime dateTimeHoursAgo) {
        if (dateTimeHoursAgo == null) {
            return null;
        } else {
            String selectClause = this.calculateSelectClause(this.defaultSelectFields);
            String fromClause = this.calculateFromClause();
            String whereClause = ' WHERE LastModifiedDate < :dateTimeHoursAgo';
            return selectClause + ' ' + fromClause + ' ' + whereClause;
        }
    }

    /**
     * @description Used from a scheduled batch class to clean up old/stale data.
     * Running user that schedules the batch class will be System Admin but
     * will not have all object/record/field access.
     * Do query in System Mode, so that permissions do not need to be granted to running user
     * that would not be required outside of the batch class.
     * @param query - Query string returned from getStaleApptQueryString.
     * @param bindParams - Map with the DateTime value to filter records based on LastModifiedDate.
     * @return `Database.QueryLocator` - List of <VCC_Appointment__c> records to return to start method of batch class.
     * These will be the old/stale records that meet criteria based on LastModifiedDate,
     * and will get deleted in the execute method of the batch class.
     * @see VCC_AppointmentDataSchedulable
     * @see VCC_AppointmentDataBatchDelete
     */
    public Database.QueryLocator getQueryLocator(String query, Map<String, Object> bindParams) {
        if ([SELECT Name, Id FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].Name != 'System Administrator') {
            throw new HandledException('Only System Administrators can run this query');
        }
        if (String.isBlank(query) || bindParams == null || bindParams.isEmpty()) {
            return null;
        } else {
            return Database.getQueryLocatorWithBinds(query, bindParams, AccessLevel.SYSTEM_MODE);
        }
    }

    /**
     * @description getAppointmentTypes returns a list of SelectOption objects (contained within VTC_PicklistModel) to be used as the "Appointment Type" picklist.
     * There are different endpoints whether it's an APPT or PtCSch, so we check the appointmentRequestType and then pass in
     * the action for that request type.  The action is used as the key for the ZD Custom Metadata.
     * @param appointmentRequestType Passed from ScheduleAppointment LWC -> Controller, Options include: APPT, RTC, or PtCSch
     * @param params Example: {"application": "VAHC", "vistaSiteId": "984"}
     * @return `VTC_PicklistModel` A model that includes a List<VTC_SelectOption> property. Holds an array of label and value pairs to be used in a picklist.
     * @see VTC_CHROClient
     */
    public VTC_PicklistModel getAppointmentTypes(String appointmentRequestType, Map<String, Object> params) {
        if (String.isBlank(appointmentRequestType)) {
            throw new IllegalArgumentException('Required argument missing [appointmentRequestType]');
        }
        if (appointmentRequestType == 'APPT' || appointmentRequestType == 'RTC') {
            return (VTC_PicklistModel) patientService.call('get_appointment_types', params);
        } else if (appointmentRequestType == 'PtCSch') {
            return (VTC_PicklistModel) patientService.call('get_recall_appointment_types', params);
        } else {
            Logger.error('Unknown Appointment Request Type: ' + appointmentRequestType);
            Logger.saveLog();
            throw new IllegalArgumentException('Unknown Appointment Request Type: ' + appointmentRequestType);
        }
    }
}
