/**
 * @description This class is used to perform database/http actions that need to occur when the user is scheduling an appointment for a patient.
 * @author Booz Allen Hamilton
 */
public with sharing class VCC_ScheduleAppointmentController {
    private final static String BOOKED = 'booked';

    /**
     * @description setting an instance of VCC_ScheduleAppointmentController to allow mocking its own methods in its test class.
     */
    @TestVisible
    private static VCC_ScheduleAppointmentController self {
        get {
            if (self == null) {
                self = new VCC_ScheduleAppointmentController();
            }
            return self;
        }
        private set;
    }

    @TestVisible
    /**
     * @description setting appointmentRepo for performing operations on the VCC_Appointment__c object
     */
    private static VCR_AppointmentRepo appointmentRepo {
        get {
            if (appointmentRepo == null) {
                appointmentRepo = new VCR_AppointmentRepo();
            }
            return appointmentRepo;
        }
        private set;
    }

    @TestVisible
    /**
     * @description setting clinicRepo for performing VTC Callouts on VTC_Clinic records
     */
    private static VCR_ClinicRepo clinicRepo {
        get {
            if (clinicRepo == null) {
                clinicRepo = new VCR_ClinicRepo();
            }
            return clinicRepo;
        }
        private set;
    }

    @TestVisible
    /**
     * @description setting appointmentRequestRepo for querying Appointment Request Records
     */
    private static VCR_AppointmentRequestRepo appointmentRequestRepo {
        get {
            if (appointmentRequestRepo == null) {
                appointmentRequestRepo = new VCR_AppointmentRequestRepo();
            }
            return appointmentRequestRepo;
        }
        private set;
    }

    /**
     * @description The object that holds parameters used for creating an Appointment
     */
    public class AppointmentParams {
        /**
         * @description contains the start date for the appointment.
         */
        @AuraEnabled
        public String start { get; set; }

        /**
         * @description contains the end date for the appointment.
         */
        @AuraEnabled
        public String xEnd { get; set; }

        /**
         * @description contains the provider internal entry number (IEN) for the appointment.
         */
        @AuraEnabled
        public String providerIEN { get; set; }

        /**
         * @description contains the provider name of the provider that requested the appointment.
         */
        @AuraEnabled
        public String providerName { get; set; }

        /**
         * @description contains the Facility' Code number associated with Appointment.
         */
        @AuraEnabled
        public String facilityStationId { get; set; }

        /**
         * @description contains the Facility's Station Name associated with Appointment.
         */
        @AuraEnabled
        public String facilityStationName { get; set; }

        /**
         * @description The Clinic internal entry number (IEN) associated with the appointment.
         */
        @AuraEnabled
        public String clinicIEN { get; set; }

        /**
         * @description The Clinic Name associated with the appointment.
         */
        @AuraEnabled
        public String clinicName { get; set; }

        /**
         * @description the Stop code Name of the Clinic
         */
        @AuraEnabled
        public String clinicStopCodeName { get; set; }

        /**
         * @description The Stop Code Number for the clinic.
         */
        @AuraEnabled
        public String clinicStopCodeNumber { get; set; }

        /**
         * @description Type of Eligibility for Scheduling the Appointment.
         */
        @AuraEnabled
        public String eligibilityOfVisit { get; set; }

        /**
         * @description The Type of Appointment Being Scheduled.
         */
        @AuraEnabled
        public String apptType { get; set; }

        /**
         * @description The Id of the Associated Appointment Request.
         */
        @AuraEnabled
        public String apptRequestId { get; set; }

        /**
         * @description The (External) Vista Id of the Associated Appointment Request.
         */
        @AuraEnabled
        public String apptRequestVistaId { get; set; }

        /**
         * @description The Id of the appointment after it's created
         */
        @AuraEnabled
        public String apptId { get; set; }

        /**
         * @description How long the appointment will last.
         */
        @AuraEnabled
        public Integer duration { get; set; }

        /**
         * @description The Salesforce Id for the Person Account.
         */
        @AuraEnabled
        public Id salesforcePatientId { get; set; }

        /**
         * @description The Salesforce Contact Id of the Patient.
         */
        @AuraEnabled
        public Id salesforceContactId { get; set; }

        /**
         * @description The Patient's integration control number (ICN).
         */
        @AuraEnabled
        public String patientICN { get; set; }

        /**
         * @description The internal entry number for the Patient file.
         */
        @AuraEnabled
        public String patientDFN { get; set; }

        /**
         * @description The Comment section content for the Appointment
         */
        @AuraEnabled
        public String note { get; set; }

        /**
         * @description Which Time Zone the appointment will take place.
         */
        @AuraEnabled
        public String timeZone { get; set; }
    }

    /**
     * @description This method is used to update an Appointment Request.
     * @param params - JSON string that provides parameters used to update Apppointment Request
     * @return Boolean indicating that the appointment request update was successful or not.
     * */
    @AuraEnabled
    public static Boolean closeApptRequest(String params) {
        if (String.isBlank(params)) {
            return false;
        }
        AppointmentParams appointmentParams = (AppointmentParams) JSON.deserialize(params, AppointmentParams.class);
        try {
            Database.UpsertResult appointmentRequestResult = self.upsertApptRequest(appointmentParams);
            return appointmentRequestResult.isSuccess();
        } catch (Exception e) {
            throw new AuraHandledException(
                'Failed to update appointment request.' + '\n' + 'Stack Trace: ' + e.getMessage()
            );
        }
    }

    /**
     * @description upsertApptRequest is a non-static method used to update the Appointment Request Status to Closed. It is
     * @param appointmentParams This property holds the appointment Id variable used to updated the associated appt request.
     * @return `Database.UpsertResult`
     */
    public Database.UpsertResult upsertApptRequest(AppointmentParams appointmentParams) {
        return appointmentRequestRepo.doUpsert(
            new VCC_AppointmentRequest__c(
                VCC_Current_Status__c = 'Closed',
                VCC_Disposition_Date__c = Date.today(),
                Id = (Id) appointmentParams?.apptRequestId
            )
        );
    }

    /**
     * @description This method is used to create an Appointment. It will implement the Custom Metadata
     * switch to determine whether to create Mock data, or live external data.
     * @param params - JSON string that provides parameters used to create an appointment and reserve timeslots. NOTE: This is a string due to limitations with @AuraEnabled properties not serializing the slotsToUpdate property.
     * I assume this is because it is a list of another inner object. I could not get it to serialize/deserialize correctly unless passing the parameters in as a String.
     * @return String the Id appointment created.
     * */
    @AuraEnabled
    public static String createAppointment(String params) {
        if (String.isBlank(params)) {
            return null;
        }

        try {
            AppointmentParams appointmentParams = (AppointmentParams) JSON.deserialize(params, AppointmentParams.class);
            Map<String, Object> createAppointmentParams = VCC_ScheduleAppointmentHelper.generateAppointmentParameters(
                appointmentParams
            );
            VTC_GenericModel genericModel = appointmentRepo.createAppointment(createAppointmentParams);
            if (genericModel?.status == 'ok') {
                appointmentParams.apptId = genericModel?.Id;
            }

            Database.UpsertResult appointmentResult = self.upsertAppointment(appointmentParams);
            String errorMessage = '';
            if (!appointmentResult.isSuccess()) {
                for (Database.Error dbError : appointmentResult.getErrors()) {
                    errorMessage += 'Error (' + dbError.getStatusCode() + '):' + dbError.getMessage() + '\r\n';
                }

                throw new AuraHandledException(
                    'Failed to create the appointment.' + '\n' + 'Stack Trace: ' + errorMessage
                );
            }
            return appointmentParams.apptId;
        } catch (Exception e) {
            throw new AuraHandledException(
                'Failed to create the appointment.' + '\n' + 'Stack Trace: ' + e.getMessage()
            );
        }
    }

    /**
     * @description upsertAppointment is a non-static TestVisible method used to create an appointment based on the Clinic and Time Slots the user selected.It is
     * non-static, TestVisible, and public to allow mocking this method in the test class.
     * @param appointmentParams This property contains all the necessary values for creating an appointemnt.
     * @return `Database.UpsertResult`
     */
    @TestVisible
    public Database.UpsertResult upsertAppointment(AppointmentParams appointmentParams) {
        return appointmentRepo.doUpsert(
            new VCC_Appointment__c(
                VCC_Appointment_Start__c = Datetime.valueOfGMT(appointmentParams?.start.replace('T', ' ')),
                VCC_Appointment_End__c = Datetime.valueOfGMT(appointmentParams?.xEnd.replace('T', ' ')),
                VCC_Appointment_Type__c = appointmentParams?.apptType,
                VCC_Patient__c = appointmentParams?.salesforcePatientId,
                VCC_Note__c = appointmentParams?.note,
                VCC_Eligibility_of_Visit__c = appointmentParams?.eligibilityOfVisit,
                VCC_Time_Zone__c = appointmentParams?.timeZone,
                VCC_Duration__c = appointmentParams?.duration,
                VCC_Clinic_Name__c = appointmentParams?.clinicName,
                VCC_Clinic_IEN__c = appointmentParams?.clinicIEN,
                VCC_Clinic_Stop_Code_Number__c = appointmentParams?.clinicStopCodeNumber,
                VCC_Facility_Station_Id__c = appointmentParams?.facilityStationId,
                VCC_Facility_Name__c = appointmentParams?.facilityStationName,
                VCC_Status__c = BOOKED,
                VCC_Appointment_Id__c = appointmentParams?.apptId,
                VCC_Appointment_Request_Id__c = appointmentParams?.apptRequestVistaId,
                VCC_Provider_Name__c = appointmentParams?.providerName
            )
        );
    }

    /**
     * @description  callIntegrationProcedure is responsible for invoking the integration procedure that
     * is responsible for auto-creating/closing the case for the appointment
     * @param params The appointment parameters that contain the necessary values for the integration procedure to run.
     */
    @AuraEnabled
    public static void callIntegrationProcedure(AppointmentParams params) {
        /* Initialize variables */
        String procedureName = 'Case_GetCreateCase';
        Map<String, Object> ipInput = new Map<String, Object>();
        Map<String, Object> ipOutput = new Map<String, Object>();
        Map<String, Object> ipOptions = new Map<String, Object>();

        //Populating input map for an Integration Procedure.
        ipInput.put('PatientId', params.salesforcePatientId);
        ipInput.put('PersonContactId', params.salesforceContactId);
        ipInput.put('ClinicStopCodeName', params.clinicStopCodeName);
        ipInput.put('ClinicStopCodeNumber', params.clinicStopCodeNumber);
        ipInput.put('ClinicName', params.clinicName);
        ipInput.put('CaseReason', 'Schedule Appointment');
        ipInput.put('siteId', params.facilityStationId);
        ipInput.put('appointment', new Map<String, Object>{ 'note' => params.note, 'id' => params.apptId });
        try {
            /* Call the IP via runIntegrationService*/
            ipOutput = (Map<String, Object>) omnistudio.IntegrationProcedureService.runIntegrationService(
                procedureName,
                ipInput,
                ipOptions
            );
            if (ipOutput.containsKey('error') && !String.isBlank((String) ipOutput.get('error'))) {
                throw new AuraHandledException((String) ipOutput.get('error'));
            }
        } catch (Exception error) {
            throw new AuraHandledException(error.getMessage());
        }
    }

    /**
     * @description performs needed steps to determine if the running user can schedule into the givin clinic at the given site and returns the result
     * @param clinicIen the clinic to check for access
     * @param vistaSiteId the site the clinic belongs too
     * @return `Boolean` true if user can schedule into clinic grid, false otherwise
     */
    @AuraEnabled
    public static Boolean runningUserCanScheduleIntoClinic(String clinicIen, String vistaSiteId) {
        switch on (new VCC_AppointmentSchedulingAccessCheck(vistaSiteId, clinicIen, clinicRepo)).getResult() {
            when ALLOWED {
                return true;
            }
            when DENIED {
                return false;
            }
            when else {
                return false;
            }
        }
    }

    /**
     * @description getAppointmentTypes returns a VTC_PicklistModel, which contains a list of VTC_SelectOption objects
     * @param appointmentRequestType Appointment Request Type which can be APPT, RTC, or PtCSch
     * @param vistaSiteId The VistA site to retrieve the Appointment Types
     * @return `List<VTC_SelectOption>` An object array that consists of a label and value property, which can be directly passed as an option to a lightning-combobox
     */
    @AuraEnabled
    public static List<VTC_SelectOption> getAppointmentTypes(String appointmentRequestType, String vistaSiteId) {
        if (String.isBlank(vistaSiteId)) {
            throw new IllegalArgumentException('Required argument missing [vistaSiteId]');
        }
        if (String.isBlank(appointmentRequestType)) {
            throw new IllegalArgumentException('Required argument missing [appointmentRequestType]');
        }
        Map<String, Object> args = new Map<String, Object>{ 'application' => 'VAHC', 'vistaSiteId' => vistaSiteId };
        try {
            List<VTC_SelectOption> options = appointmentRepo.getAppointmentTypes(appointmentRequestType, args)
                .selectOptions;
            return options;
        } catch (Exception error) {
            Logger.info('Arguments used in Request: ' + JSON.serialize(args));
            Logger.error('Exception getting appointment types', error);
            Logger.saveLog();
            throw VCC_ExceptionUtils.createAuraHandledException(error.getMessage());
        }
    }
}
