public with sharing class VCC_PatientAllergy {
    @AuraEnabled
    public VCC_BridgRSCommon.HL72EntityIdentifier recordIdentifier { get; set; }
    @AuraEnabled
    public VCC_BridgRSCommon.PatientLite patient { get; set; }
    @AuraEnabled
    public VCC_BridgRSCommon.PointInTime observationTime { get; set; }
    @AuraEnabled
    public VCC_BridgRSCommon.HL72CodedElementLite agent { get; set; }
    @AuraEnabled
    public VCC_BridgRSCommon.HL72CodedElementLite allergyType { get; set; }
    @AuraEnabled
    public VCC_BridgRSCommon.HL72CodedElement gmrAllergyAgent { get; set; }
    @AuraEnabled
    public VCC_BridgRSCommon.HL72CodedElementLite informationSourceCategory { get; set; }
    @AuraEnabled
    public VCC_BridgRSCommon.HL72CodedElementLite mechanism { get; set; }
    @AuraEnabled
    public String status { get; set; }
    @AuraEnabled
    public String verified { get; set; }
    @AuraEnabled
    public List<VCC_BridgAllergyRS.ReactionObservationEvent> reaction { get; set; }
    @AuraEnabled
    public VCC_BridgAllergyRS.PractitionerParticipationLite verifier { get; set; }
    @AuraEnabled
    public VCC_BridgAllergyRS.PractitionerParticipationLite author { get; set; }
    @AuraEnabled
    public VCC_BridgAllergyRS.PractitionerParticipationLite errorEnterer { get; set; }
    @AuraEnabled
    public List<VCC_BridgAllergyRS.PractitionerParticipationLite> idBandMarker { get; set; }
    @AuraEnabled
    public List<VCC_BridgAllergyRS.PractitionerParticipationLite> chartMarker { get; set; }
    @AuraEnabled
    public List<VCC_BridgAllergyRS.AllergyCommentEvent> commentEvents { get; set; }
    @AuraEnabled
    public List<VCC_BridgAllergyRS.DrugClass> drugClass { get; set; }
    @AuraEnabled
    public List<VCC_BridgAllergyRS.DrugIngredient> drugIngredient { get; set; }
    @AuraEnabled
    public VCC_BridgRSCommon.HL72OrganizationIdentifier facilityIdentifier { get; set; }
    @AuraEnabled
    public List<VCC_BridgRSCommon.HL72Severity> severity { get; set; }
    @AuraEnabled
    public VCC_BridgRSCommon.HL72FacilityIdentifier recordSource { get; set; }
    @AuraEnabled
    public Integer recordVersion { get; set; }
    @AuraEnabled
    public VCC_BridgRSCommon.PointInTime recordUpdateTime { get; set; }
    @AuraEnabled
    public Boolean isMaxRecordsError { get; set; }

    public VCC_PatientAllergy() {
        this.recordIdentifier = new VCC_BridgRSCommon.HL72EntityIdentifier();
        this.patient = new VCC_BridgRSCommon.PatientLite();
        this.observationTime = new VCC_BridgRSCommon.PointInTime();
        this.agent = new VCC_BridgRSCommon.HL72CodedElementLite();
        this.allergyType = new VCC_BridgRSCommon.HL72CodedElementLite();
        this.gmrAllergyAgent = new VCC_BridgRSCommon.HL72CodedElement();
        this.informationSourceCategory = new VCC_BridgRSCommon.HL72CodedElementLite();
        this.mechanism = new VCC_BridgRSCommon.HL72CodedElementLite();
        this.reaction = new List<VCC_BridgAllergyRS.ReactionObservationEvent>();
        this.verifier = new VCC_BridgAllergyRS.PractitionerParticipationLite();
        this.author = new VCC_BridgAllergyRS.PractitionerParticipationLite();
        this.errorEnterer = new VCC_BridgAllergyRS.PractitionerParticipationLite();
        this.idBandMarker = new List<VCC_BridgAllergyRS.PractitionerParticipationLite>();
        this.chartMarker = new List<VCC_BridgAllergyRS.PractitionerParticipationLite>();
        this.commentEvents = new List<VCC_BridgAllergyRS.AllergyCommentEvent>();
        this.drugClass = new List<VCC_BridgAllergyRS.DrugClass>();
        this.drugIngredient = new List<VCC_BridgAllergyRS.DrugIngredient>();
        this.facilityIdentifier = new VCC_BridgRSCommon.HL72OrganizationIdentifier();
        this.recordSource = new VCC_BridgRSCommon.HL72FacilityIdentifier();
        this.severity = new List<VCC_BridgRSCommon.HL72Severity>();
        this.recordUpdateTime = new VCC_BridgRSCommon.PointInTime();
    }

    public VCC_PatientAllergy(VCC_BridgAllergyRS.IntoleranceCondition intoleranceCondition) {
        this.recordIdentifier = intoleranceCondition.recordIdentifier;
        this.patient = intoleranceCondition.patient;
        this.observationTime = intoleranceCondition.observationTime;
        this.agent = intoleranceCondition.agent;
        this.allergyType = intoleranceCondition.allergyType;
        this.gmrAllergyAgent = intoleranceCondition.gmrAllergyAgent;
        this.informationSourceCategory = intoleranceCondition.informationSourceCategory;
        this.mechanism = intoleranceCondition.mechanism;
        this.status = intoleranceCondition.status;
        this.verified = intoleranceCondition.verified;
        this.reaction = intoleranceCondition.reaction;
        this.verifier = intoleranceCondition.verifier;
        this.author = intoleranceCondition.author;
        this.errorEnterer = intoleranceCondition.errorEnterer;
        this.idBandMarker = intoleranceCondition.idBandMarker;
        this.chartMarker = intoleranceCondition.chartMarker;
        this.commentEvents = intoleranceCondition.commentEvents;
        this.drugClass = intoleranceCondition.drugClass;
        this.drugIngredient = intoleranceCondition.drugIngredient;
        this.facilityIdentifier = intoleranceCondition.facilityIdentifier;
        this.recordSource = intoleranceCondition.recordSource;
        this.recordVersion = intoleranceCondition.recordVersion;
        this.recordUpdateTime = intoleranceCondition.recordUpdateTime;
        this.severity = intoleranceCondition.severity;
    }
}
