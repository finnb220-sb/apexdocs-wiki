/**
 * @author Kumar Balan
 * @group API - Bridg - Appointments
 * @description VCC Appoint Modal.
 */
@SuppressWarnings('PMD.ApexDoc, PMD.ExcessivePublicCount')
public inherited sharing class VCC_AppointmentModal extends VCC_WrapperWithKeyword {
    @AuraEnabled
    public AppointmentsData appointmentsData;

    public class AppointmentsData {
        @AuraEnabled
        public Patients patients;
    }

    public class Patients {
        @AuraEnabled
        public List<Patient> patient;
    }

    public class Patient {
        @AuraEnabled
        public Appointments appointments;
    }

    public class Appointments {
        @AuraEnabled
        public List<Appointment> appointment;
    }

    public class Appointment {
        @AuraEnabled
        public AppointmentDateTime appointmentDateTime;
        @AuraEnabled
        public Providers providers;
        @AuraEnabled
        public Location location;
        @AuraEnabled
        public AppointmentStatus appointmentStatus;

        @AuraEnabled
        public String other;
        @AuraEnabled
        public String service;
        @AuraEnabled
        public String division;

        @AuraEnabled
        public RecordIdentifier recordIdentifier;
    }

    public class RecordIdentifier {
        @AuraEnabled
        public string identity;
    }

    public class AppointmentStatus {
        @AuraEnabled
        public string displayText;
    }

    public class Providers {
        @AuraEnabled
        public List<Provider> provider;
    }

    public class Provider {
        @AuraEnabled
        public string displayName;
        @AuraEnabled
        public string nameTitle;
    }

    public class AppointmentDateTime {
        @AuraEnabled
        public Long literal {
            get;
            set {
                if (value != null) {
                    String timeValue = String.valueOf(value);
                    appointmentDateTimeStr =
                        timeValue.substring(4, 6) +
                        '/' +
                        timeValue.substring(6, 8) +
                        '/' +
                        timeValue.substring(0, 4) +
                        ' ' +
                        timeValue.substring(8, 10) +
                        ':' +
                        timeValue.substring(10, 12);
                    this.appointmentDateTime = Datetime.newInstance(
                        Integer.valueOf(timeValue.substring(0, 4)),
                        Integer.valueOf(timeValue.substring(4, 6)),
                        Integer.valueOf(timeValue.substring(6, 8)),
                        Integer.valueOf(timeValue.substring(8, 10)),
                        Integer.valueOf(timeValue.substring(10, 12)),
                        0
                    );
                }
                literal = value;
            }
        }

        @AuraEnabled
        public String appointmentDateTimeStr { get; set; }

        @AuraEnabled
        public DateTime appointmentDateTime { get; set; }
    }

    public class Location {
        @AuraEnabled
        public Identifier identifier;
        @AuraEnabled
        public Institution institution;
    }

    public class Identifier {
        @AuraEnabled
        public string name;
    }

    public class Institution {
        @AuraEnabled
        public string officialVAName;
        @AuraEnabled
        public Identifier identifier;
    }
}
