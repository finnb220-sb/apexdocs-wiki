@SuppressWarnings('PMD.ExcessivePublicCount, PMD.TooManyFields, PMD.LocalVariableNamingConventions')
public with sharing class VCC_BridgAllergyRS extends VCC_BaseClient.BaseResponse {
    public ClinicalData clinicalData;
    public Boolean isMaxRecordsError;

    public class ClinicalData {
        public String templateId;
        public String requestId;
        public List<ClinicalDataPatient> patient;
        public VCC_BridgRSCommon.CdsErrorSection errorSection;

        public ClinicalData() {
            this.patient = new List<ClinicalDataPatient>();
            this.errorSection = new VCC_BridgRSCommon.CdsErrorSection();
        }
    }

    public class ClinicalDataPatient {
        public String requestedNationalId;
        public List<VCC_BridgRSCommon.HL72PersonIdentifier> requestedResolvedIdentifiers;
        public List<VCC_BridgRSCommon.HL72PersonIdentifier> requestedExcludedIdentifiers;
        public List<VCC_BridgRSCommon.HL72PersonIdentifier> resultantIdentifiers;
        public List<IntoleranceCondition> intoleranceConditions;
        public List<AllergyAssessment> allergyAssessments;

        public ClinicalDataPatient() {
            this.allergyAssessments = new List<AllergyAssessment>();
            this.intoleranceConditions = new List<IntoleranceCondition>();
            this.requestedResolvedIdentifiers = new List<VCC_BridgRSCommon.HL72PersonIdentifier>();
            this.requestedExcludedIdentifiers = new List<VCC_BridgRSCommon.HL72PersonIdentifier>();
            this.resultantIdentifiers = new List<VCC_BridgRSCommon.HL72PersonIdentifier>();
        }
    }

    public class PractitionerParticipationLite {
        public String comment;
        public VCC_BridgRSCommon.PointInTime time_s;
        public VCC_BridgRSCommon.PractitionerLite practitioner;

        public PractitionerParticipationLite() {
            this.time_s = new VCC_BridgRSCommon.PointInTime();
            this.practitioner = new VCC_BridgRSCommon.PractitionerLite();
        }
    }

    public class DrugIngredient {
        public VCC_BridgRSCommon.HL72CodedElementLite code;

        public DrugIngredient() {
            this.code = new VCC_BridgRSCommon.HL72CodedElementLite();
        }
    }

    public class DrugClass {
        public VCC_BridgRSCommon.HL72CodedElement code;

        public DrugClass() {
            this.code = new VCC_BridgRSCommon.HL72CodedElement();
        }
    }

    public class ReactionObservationEvent {
        public VCC_BridgRSCommon.PointInTime observationTime;
        public VCC_BridgRSCommon.HL72CodedElementLite reaction;
        public PractitionerParticipationLite author;

        public ReactionObservationEvent() {
            this.observationTime = new VCC_BridgRSCommon.PointInTime();
            this.reaction = new VCC_BridgRSCommon.HL72CodedElementLite();
            this.author = new PractitionerParticipationLite();
        }
    }

    public class AllergyCommentEvent {
        public VCC_BridgRSCommon.PointInTime date_s;
        public VCC_BridgRSCommon.PractitionerLite author;
        public VCC_BridgRSCommon.HL72CodedElementLite commentType;
        public List<String> comments;

        public AllergyCommentEvent() {
            this.date_s = new VCC_BridgRSCommon.PointInTime();
            this.author = new VCC_BridgRSCommon.PractitionerLite();
            this.commentType = new VCC_BridgRSCommon.HL72CodedElementLite();
            this.comments = new List<String>();
        }
    }

    public class IntoleranceCondition {
        public VCC_BridgRSCommon.HL72EntityIdentifier recordIdentifier;
        public VCC_BridgRSCommon.PatientLite patient;
        public VCC_BridgRSCommon.PointInTime observationTime;
        public VCC_BridgRSCommon.HL72CodedElementLite agent;
        public VCC_BridgRSCommon.HL72CodedElementLite allergyType;
        public VCC_BridgRSCommon.HL72CodedElement gmrAllergyAgent;
        public VCC_BridgRSCommon.HL72CodedElementLite informationSourceCategory;
        public VCC_BridgRSCommon.HL72CodedElementLite mechanism;
        public String status;
        public String verified;
        public List<ReactionObservationEvent> reaction;
        public PractitionerParticipationLite verifier;
        public PractitionerParticipationLite author;
        public PractitionerParticipationLite errorEnterer;
        public List<PractitionerParticipationLite> idBandMarker;
        public List<PractitionerParticipationLite> chartMarker;
        public List<AllergyCommentEvent> commentEvents;
        public List<DrugClass> drugClass;
        public List<DrugIngredient> drugIngredient;
        public VCC_BridgRSCommon.HL72OrganizationIdentifier facilityIdentifier;
        public VCC_BridgRSCommon.HL72FacilityIdentifier recordSource;
        public Integer recordVersion;
        public VCC_BridgRSCommon.PointInTime recordUpdateTime;
        public List<VCC_BridgRSCommon.HL72Severity> severity;

        public IntoleranceCondition() {
            this.recordIdentifier = new VCC_BridgRSCommon.HL72EntityIdentifier();
            this.patient = new VCC_BridgRSCommon.PatientLite();
            this.observationTime = new VCC_BridgRSCommon.PointInTime();
            this.agent = new VCC_BridgRSCommon.HL72CodedElementLite();
            this.allergyType = new VCC_BridgRSCommon.HL72CodedElementLite();
            this.gmrAllergyAgent = new VCC_BridgRSCommon.HL72CodedElement();
            this.informationSourceCategory = new VCC_BridgRSCommon.HL72CodedElementLite();
            this.mechanism = new VCC_BridgRSCommon.HL72CodedElementLite();
            this.reaction = new List<ReactionObservationEvent>();
            this.verifier = new PractitionerParticipationLite();
            this.author = new PractitionerParticipationLite();
            this.errorEnterer = new PractitionerParticipationLite();
            this.idBandMarker = new List<PractitionerParticipationLite>();
            this.chartMarker = new List<PractitionerParticipationLite>();
            this.commentEvents = new List<AllergyCommentEvent>();
            this.drugClass = new List<DrugClass>();
            this.drugIngredient = new List<DrugIngredient>();
            this.facilityIdentifier = new VCC_BridgRSCommon.HL72OrganizationIdentifier();
            this.recordSource = new VCC_BridgRSCommon.HL72FacilityIdentifier();
            this.recordUpdateTime = new VCC_BridgRSCommon.PointInTime();
            this.severity = new List<VCC_BridgRSCommon.HL72Severity>();
        }
    }

    public class AllergyAssessment {
        public VCC_BridgRSCommon.HL72EntityIdentifier recordIdentifier;
        public VCC_BridgRSCommon.PatientLite patient;
        public VCC_BridgRSCommon.PointInTime observationTime;
        public VCC_BridgRSCommon.HL72CodedElementLite assessmentValue;
        public String status;
        public PractitionerParticipationLite author;
        public VCC_BridgRSCommon.HL72FacilityIdentifier recordSource;
        public Integer recordVersion;
        public VCC_BridgRSCommon.PointInTime recordUpdateTime;

        public AllergyAssessment() {
            this.recordIdentifier = new VCC_BridgRSCommon.HL72EntityIdentifier();
            this.patient = new VCC_BridgRSCommon.PatientLite();
            this.observationTime = new VCC_BridgRSCommon.PointInTime();
            this.assessmentValue = new VCC_BridgRSCommon.HL72CodedElementLite();
            this.author = new PractitionerParticipationLite();
            this.recordSource = new VCC_BridgRSCommon.HL72FacilityIdentifier();
            this.recordUpdateTime = new VCC_BridgRSCommon.PointInTime();
        }
    }

    public VCC_BridgAllergyRS() {
        this.clinicalData = new ClinicalData();
    }

    public VCC_BridgAllergyRS(VCC_BaseClient.BaseResponse baseResponse) {
        super(baseResponse);
        System.debug('baseResponse after ------------>' + baseResponse);
        try {
            this.clinicalData = ((VCC_BridgAllergyRS) JSON.deserialize(
                    baseResponse.httpResponse.getBody().replace('"exception"', '"exception_s"').replace('"date"', '"date_s"').replace('"time"', '"time_s"'),
                    VCC_BridgAllergyRS.class
                ))
                .clinicalData;

            System.debug('Clinical Data ------------>' + this.clinicalData);

            if (baseResponse.httpResponse.getBody().contains('Exceeded Max')) {
                this.isMaxRecordsError = true;
            }
        } catch (Exception e) {
            this.exceptions.add(e);
        }
    }
}
