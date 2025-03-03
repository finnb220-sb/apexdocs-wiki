/**
 * @description This class is used to return data to the vccScheduleAppointment lwc. It will either return Mock data from the VCC_Clinic_Schedule_Slot object, or it will return ClinicScheduleSlot data from an external api.
 * This will depend on a Custom metadata switch that will be implemented when the api is available to use. The VCC_Clinic_Schedule_Slot object represents Tim Slot availability for Clinics. The user will be able to select these
 * time slots, which appear in the vccCalendar component, and then create an appointment using the timeslot data (again, either a VCC_Appointment__c or an external Appointment record, depending on the switch).
 * @author Booz Allen Hamilton
 */
public with sharing class VCC_ScheduleAppointmentRequestController {
    private static final String APPLICATION = 'VAHC';

    @TestVisible
    /**
     * @description setting clinicSlotRepo for querying Time Slot Records
     */
    private static VCR_ClinicScheduleSlotRepo clinicSlotRepo {
        get {
            if (clinicSlotRepo == null) {
                clinicSlotRepo = new VCR_ClinicScheduleSlotRepo();
            }
            return clinicSlotRepo;
        }
        private set;
    }

    /**
     * @description setting clinicRepo for querying the Clinic record to relate to an Appointment
     */
    @TestVisible
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
     * @description setting appointmentRepo for querying Appointment Records
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
    @SuppressWarnings('PMD.DescriptionMustHaveText')
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
     * @description class that holds the parameters passed from the vccScheduleAppointmentRequest lwc.
     */
    public class TimeSlotParams {
        @AuraEnabled
        /**
         * @description Start Date Parameter for time slot
         */
        public Date startDate { get; set; }
        @AuraEnabled
        /**
         * @description Stop Date Parameter for time slot
         */
        public Date stopDate { get; set; }
        @AuraEnabled
        /**
         * @description Provider Unique Id Parameter
         */
        public String providerIEN { get; set; }
        @AuraEnabled
        /**
         * @description Facility Code End User has Selected.
         */
        public String facilityCode { get; set; }
        @AuraEnabled
        /**
         * @description List of Clinic IENs to identify time slots
         */
        public List<String> clinicIENList { get; set; }
        @AuraEnabled
        /**
         * @description Clinic IEN to identify time slots
         */
        public String clinicIEN { get; set; }
    }

    /**
     * @description Fetch Timeslots from The Scheduling DIP Endpoint, CHRONOS, Utilizing the VTC Framework
     * @param timeSlotParams - timeslot arguments to pass to the repo
     * @return VTC_RecordModel - The data model containing the timeslot data
     */
    @AuraEnabled(Cacheable=true)
    public static VTC_RecordModel fetchTimeslots(TimeslotParams timeSlotParams) {
        if (
            String.isBlank(timeSlotParams.facilityCode) ||
            String.isBlank(timeSlotParams.clinicIEN) ||
            timeSlotParams.startDate == null ||
            timeSlotParams.stopDate == null
        ) {
            throw VTC_ExceptionUtils.createAuraHandledException(
                'Invalid Request. Null/Empty request properties detected.'
            );
        }
        Map<String, Object> args = new Map<String, Object>{
            'application' => APPLICATION,
            'siteId' => timeSlotParams.facilityCode,
            'clinicIEN' => timeSlotParams.clinicIEN,
            'includeOriginal' => false,
            'startDate' => String.valueOf(timeSlotParams.startDate),
            'endDate' => String.valueOf(timeSlotParams.stopDate)
        };
        try {
            return clinicSlotRepo.fetchTimeslots(args);
        } catch (VTC_LimitException e) {
            Logger.error('VTC Limit exception getting timeslots for clinic Args: ' + JSON.serialize(args), e);
            throw VTC_ExceptionUtils.createAuraHandledException(e.getMessage());
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description This method is used to return VTC_Record to the vccClinicDetails lwc, which will be used for displaying Clinic Details.
     * @param siteId - The site/facility Id of the VistA site
     * @param clinicIEN - The IEN of the Clinic to retrieve
     * @return              `VTC_Record`
     */
    @AuraEnabled
    public static VTC_Record getClinicByIEN(String siteId, String clinicIEN) {
        if (String.isBlank(siteId) || String.isBlank(clinicIEN)) {
            throw VTC_ExceptionUtils.createAuraHandledException(
                'Invalid Request. Null/Empty request properties detected.'
            );
        }
        Map<String, Object> args = new Map<String, Object>{
            'application' => APPLICATION,
            'siteId' => siteId,
            'clinicIEN' => clinicIEN
        };
        try {
            return clinicRepo.getClinicByIEN(args);
        } catch (VTC_LimitException e) {
            Logger.info('Arguments used in Request: ' + JSON.serialize(args));
            Logger.error('Limit exception getting clinic information.', e);
            throw VTC_ExceptionUtils.createAuraHandledException(e.getMessage());
        } catch (Exception e) {
            Logger.info('Arguments used in Request: ' + JSON.serialize(args));
            Logger.error('Exception getting clinic information', e);
            throw VCC_ExceptionUtils.createAuraHandledException(e.getMessage());
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description This method utilizes the VTC framework to search for Clinics Associated to a Provider by Provider IEN and Vista SiteId.
     * @param timeSlotParams - timeslot arguments to pass to the repo
     * @return            `List<VTC_Record>`
     */
    @AuraEnabled(Cacheable=false)
    public static List<VTC_Record> getClinicsByProvider(TimeSlotParams timeSlotParams) {
        if (String.isBlank(timeSlotParams?.providerIEN) || String.isBlank(timeSlotParams?.facilityCode)) {
            throw VTC_ExceptionUtils.createAuraHandledException(
                'Invalid Request. Null/Empty request properties detected.'
            );
        }
        Map<String, Object> requestBodyArgs = new Map<String, Object>{
            'application' => APPLICATION,
            'vistaSiteId' => timeSlotParams.facilityCode,
            'queryIen' => timeSlotParams.providerIEN
        };
        try {
            return clinicRepo.getClinicsByProvider(requestBodyArgs);
        } catch (VTC_LimitException e) {
            Logger.error('VTC Limit exception getting clinics by provider Args: ' + JSON.serialize(requestBodyArgs), e);
            throw VTC_ExceptionUtils.createAuraHandledException(e.getMessage());
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description - Gets all active appointments associated with Patient.
     * @param patientId - patient id in salesforce used to find appoitments related to patient.
     * @return   `List<VCC_Appointment__c>`
     */
    @AuraEnabled
    public static List<VCC_Appointment__c> searchExistingAppointments(String patientId) {
        List<VCC_Appointment__c> existingApptList = appointmentRepo.getExistingAppointments(patientId);
        return existingApptList;
    }
}
