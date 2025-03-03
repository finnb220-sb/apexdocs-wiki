public with sharing class VCC_BridgAppointmentsRS extends VCC_BaseClient.BaseResponse {
    public AppointmentsData appointmentsData;

    public Boolean isMaxRecordsError;

    public class AppointmentsData {
        public String templateId;
        public String requestId;
        public Patients patients;
        public VCC_BridgRSCommon.PathwaysErrorSection errorSection;

        public AppointmentsData() {
            this.patients = new Patients();
            this.errorSection = new VCC_BridgRSCommon.PathwaysErrorSection();
        }
    }

    public class Patients {
        List<AppointmentsDataPatient> patient;

        public Patients() {
            this.patient = new List<AppointmentsDataPatient>();
        }
    }

    public class AppointmentsDataPatient {
        public String requestedNationalId;
        public VCC_BridgRSCommon.RequestedResolvedIdentifiers requestedResolvedIdentifiers;
        public VCC_BridgRSCommon.RequestedExcludedIdentifiers requestedExcludedIdentifiers;
        public VCC_BridgRSCommon.ResultantIdentifiers resultantIdentifiers;
        public Appointments appointments;

        public AppointmentsDataPatient() {
            this.requestedResolvedIdentifiers = new VCC_BridgRSCommon.RequestedResolvedIdentifiers();
            this.requestedExcludedIdentifiers = new VCC_BridgRSCommon.RequestedExcludedIdentifiers();
            this.resultantIdentifiers = new VCC_BridgRSCommon.ResultantIdentifiers();
            this.appointments = new Appointments();
        }
    }

    public class Appointments {
        public List<Appointment> appointment;

        public Appointments() {
            this.appointment = new List<Appointment>();
        }
    }

    public class Appointment {
        public VCC_BridgRSCommon.HL72EntityIdentifier recordIdentifier;
        public VCC_BridgRSCommon.PatientLite patient;
        public VCC_BridgRSCommon.PointInTime appointmentDateTime;
        public VCC_BridgRSCommon.HospitalLocation location;
        public String locationPatientFriendlyName;
        public String clinicMeetsAtThisFacility;
        public String displayClinicApptToPatient;
        public String service; //[ MEDICINE, SURGERY, PSYCHIATRY, REHAB_MEDICINE, NEUROLOGY, NONE ]
        public String division;
        public String telephoneExtension;
        public VCC_BridgRSCommon.ProvidersType providers;
        public String other;
        public String allowDirectPatientScheduling;
        public VCC_BridgRSCommon.HL72CodedElementLite appointmentStatus;
        public VCC_BridgRSCommon.HL72CodedElementLite appointmentType;
        public VCC_BridgRSCommon.PointInTime ekgDateTime;
        public VCC_BridgRSCommon.PointInTime xrayDateTime;
        public VCC_BridgRSCommon.PointInTime labDateTime;
        public VCC_BridgRSCommon.HL72CodedElementLite status;
        public VCC_BridgRSCommon.HL72FacilityIdentifier recordSource;
        public Integer recordVersion;
        public VCC_BridgRSCommon.PointInTime recordUpdateTime;

        public Appointment() {
            this.recordIdentifier = new VCC_BridgRSCommon.HL72EntityIdentifier();
            this.appointmentStatus = new VCC_BridgRSCommon.HL72CodedElementLite();
            this.appointmentType = new VCC_BridgRSCommon.HL72CodedElementLite();
            this.status = new VCC_BridgRSCommon.HL72CodedElementLite();
            this.recordSource = new VCC_BridgRSCommon.HL72FacilityIdentifier();
            this.appointmentDateTime = new VCC_BridgRSCommon.PointInTime();
            this.ekgDateTime = new VCC_BridgRSCommon.PointInTime();
            this.xrayDateTime = new VCC_BridgRSCommon.PointInTime();
            this.labDateTime = new VCC_BridgRSCommon.PointInTime();
            this.recordUpdateTime = new VCC_BridgRSCommon.PointInTime();
            this.providers = new VCC_BridgRSCommon.ProvidersType();
            this.location = new VCC_BridgRSCommon.HospitalLocation();
            this.patient = new VCC_BridgRSCommon.PatientLite();
        }
    }

    public VCC_BridgAppointmentsRS() {
        this.appointmentsData = new AppointmentsData();
    }

    public VCC_BridgAppointmentsRS(VCC_BaseClient.BaseResponse baseResponse) {
        try {
            this.appointmentsData = ((VCC_BridgAppointmentsRS) JSON.deserialize(
                    baseResponse.httpResponse.getBody().replace('"exception"', '"exception_s"'),
                    VCC_BridgAppointmentsRS.class
                ))
                .appointmentsData;
            if (baseResponse.httpResponse.getBody().contains('Exceeded Max')) {
                this.isMaxRecordsError = true;
            }
        } catch (Exception e) {
            this.exceptions.add(e);
        }
    }
}
