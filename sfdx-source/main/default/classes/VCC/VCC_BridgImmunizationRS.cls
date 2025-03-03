public with sharing class VCC_BridgImmunizationRS extends VCC_BaseClient.BaseResponse {
    public ImmunizationClinicalData clinicalData;
    public Boolean isMaxRecordsError;

    public class ImmunizationClinicalData {
        public String templateId;
        public String requestId;
        public Patients patients;
        public CdsImmunizationErrorSection errorSection;

        public ImmunizationClinicalData() {
            this.patients = new Patients();
            this.errorSection = new CdsImmunizationErrorSection();
        }
    }

    public class Patients {
        public List<ImmunizationClinicalDataPatient> patient;

        public Patients() {
            this.patient = new List<ImmunizationClinicalDataPatient>();
        }
    }

    public class ImmunizationClinicalDataPatient {
        public String requestedNationalId;
        public VCC_BridgRSCommon.RequestedResolvedIdentifiers requestedResolvedIdentifiers;
        public VCC_BridgRSCommon.RequestedExcludedIdentifiers requestedExcludedIdentifiers;
        public VCC_BridgRSCommon.ResultantIdentifiers resultantIdentifiers;
        public ImmunizationEvents immunizationEvents;

        public ImmunizationClinicalDataPatient() {
            this.requestedResolvedIdentifiers = new VCC_BridgRSCommon.RequestedResolvedIdentifiers();
            this.requestedExcludedIdentifiers = new VCC_BridgRSCommon.RequestedExcludedIdentifiers();
            this.resultantIdentifiers = new VCC_BridgRSCommon.ResultantIdentifiers();
            this.immunizationEvents = new ImmunizationEvents();
        }
    }

    public class ImmunizationEvents {
        public List<ImmunizationEvent> immunizationEvent;
    }

    public class ImmunizationEvent {
        public VCC_BridgRSCommon.HL72CodedElementLite contraIndication;
        public VCC_BridgRSCommon.PointInTime date_s;
        public VCC_BridgRSCommon.HL72EntityIdentifier recordIdentifier;
        public VCC_BridgRSCommon.VACode series;
        public ImmunizationSkinTestVisit visit;
        public VCC_BridgRSCommon.PatientLite patient;
        public Diagnosis diagnosis;
        public Diagnosis diagnosis2;
        public Diagnosis diagnosis3;
        public Diagnosis diagnosis4;
        public Diagnosis diagnosis5;
        public Diagnosis diagnosis6;
        public Diagnosis diagnosis7;
        public Diagnosis diagnosis8;
        public Integer recordVersion;
        public VCC_BridgRSCommon.PointInTime recordUpdateTime;
        public VCC_BridgRSCommon.HL72FacilityIdentifier recordSource;
        public VCC_BridgRSCommon.HL72CodedElementLite editedFlag;
        public String auditTrail;
        public String comments;
        public VCC_BridgRSCommon.HL72CodedElementLite verified;
        public VCC_BridgRSCommon.PractitionerLite orderingProvider;
        public Remarks remarks;
        public DataSource dataSource;
        public SoftwarePackage softwarePackage;
        public ReactionObservationEvents reactionObservationEvents;
        public AdministeredImmunization immunizationAdministered;
    }

    public class ImmunizationSkinTestVisit {
        public Comments comments;
        public VCC_BridgRSCommon.VACode serviceCategory;
        public VCC_BridgRSCommon.VACode status;
        public VCC_BridgRSCommon.PointInTime visitCheckOutDate;
        public VCC_BridgRSCommon.TimeInterval visitDate;
        public VCC_BridgRSCommon.HL72EntityIdentifier visitId;
        public VCC_BridgRSCommon.HL72EntityIdentifier cirnVisitId;
        public VCC_BridgRSCommon.PointInTime visitAdmitDate;
    }

    public class Comments {
        List<String> comments;

        public Comments() {
            this.comments = new List<String>();
        }
    }

    public class Diagnosis {
        public SnomedCodes snomedCodes;
        public IcdCodes icdCodes;

        public Diagnosis() {
            this.snomedCodes = new SnomedCodes();
            this.IcdCodes = new IcdCodes();
        }
    }

    public class SnomedCodes {
        public List<VCC_BridgRSCommon.VACode> snomedCode;

        public SnomedCodes() {
            this.snomedCode = new List<VCC_BridgRSCommon.VACode>();
        }
    }

    public class IcdCodes {
        public List<VCC_BridgRSCommon.VACode> icdCodes;

        public IcdCodes() {
            this.icdCodes = new List<VCC_BridgRSCommon.VACode>();
        }
    }

    public class Remarks {
        public List<String> remark;

        public Remarks() {
            this.remark = new List<String>();
        }
    }

    public class DataSource {
        public String sourceName;
    }

    public class SoftwarePackage {
        public String name;
    }

    public class ReactionObservationEvents {
        public List<VCC_BridgAllergyRS.ReactionObservationEvent> reactionObservationEvent;

        public ReactionObservationEvents() {
            this.reactionObservationEvent = new List<VCC_BridgAllergyRS.ReactionObservationEvent>();
        }
    }

    public class AdministeredImmunization {
        public String immunizationName;
        public String immunizationShortName;
    }

    public class CdsImmunizationErrorSection {
        public VCC_BridgRSCommon.Errors errors;
        public VCC_BridgRSCommon.FatalErrors fatalErrors;
        public VCC_BridgRSCommon.Warnings warnings;

        public CdsImmunizationErrorSection() {
            this.errors = new VCC_BridgRSCommon.Errors();
            this.fatalErrors = new VCC_BridgRSCommon.FatalErrors();
            this.warnings = new VCC_BridgRSCommon.Warnings();
        }
    }

    public VCC_BridgImmunizationRS() {
        this.clinicalData = new ImmunizationClinicalData();
    }

    public VCC_BridgImmunizationRS(VCC_BaseClient.BaseResponse baseResponse) {
        super(baseResponse);
        try {
            this.clinicalData = ((VCC_BridgImmunizationRS) JSON.deserialize(
                    baseResponse.httpResponse.getBody().replace('"date"', '"date_s"').replace('"exception"', '"exception_s"'),
                    VCC_BridgImmunizationRS.class
                ))
                .clinicalData;
            if (baseResponse.httpResponse.getBody().contains('Exceeded Max')) {
                this.isMaxRecordsError = true;
            }
        } catch (Exception e) {
            this.exceptions.add(e);
        }
    }
}
