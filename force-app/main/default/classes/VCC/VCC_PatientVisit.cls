/**
 * @description Internal representation of patient visit
 * @author Liberty
 * @since 1/5/2022
 */
@SuppressWarnings('PMD.ExcessivePublicCount, PMD.TooManyFields')
public with sharing class VCC_PatientVisit {
    @AuraEnabled
    public List<VCC_BridgVisitsRS.VisitDocument> documents;
    @AuraEnabled
    public List<VCC_BridgVisitsRS.VisitProvider> providers;
    @AuraEnabled
    public List<VCC_BridgVisitsRS.VisitMovement> movements;

    @AuraEnabled
    public String categoryCode { get; set; }
    @AuraEnabled
    public String categoryName { get; set; }
    @AuraEnabled
    public DateTime dateAndTime { get; set; }
    @AuraEnabled
    public String facilityCode { get; set; }
    @AuraEnabled
    public String facilityName { get; set; }
    @AuraEnabled
    public String localId { get; set; }
    @AuraEnabled
    public String locationName { get; set; }
    @AuraEnabled
    public String locationUid { get; set; }
    @AuraEnabled
    public String patientClassCode { get; set; }
    @AuraEnabled
    public String patientClassName { get; set; }
    @AuraEnabled
    public String stopCodeName { get; set; }
    @AuraEnabled
    public String stopCodeUid { get; set; }
    @AuraEnabled
    public String typeName { get; set; }
    @AuraEnabled
    public String uid { get; set; }
    @AuraEnabled
    public String current { get; set; }
    @AuraEnabled
    public String reasonName { get; set; }
    @AuraEnabled
    public String service { get; set; }
    @AuraEnabled
    public String specialty { get; set; }
    @AuraEnabled
    public VCC_BridgVisitsRS.VisitStay stay { get; set; }
    @AuraEnabled
    public String summary { get; set; }
    @AuraEnabled
    public String checkOut { get; set; }
    @AuraEnabled
    public String reasonUid { get; set; }
    @AuraEnabled
    public String roomBed { get; set; }

    public VCC_PatientVisit() {
        this.documents = new List<VCC_BridgVisitsRS.VisitDocument>();
        this.providers = new List<VCC_BridgVisitsRS.VisitProvider>();
        this.movements = new List<VCC_BridgVisitsRS.VisitMovement>();
        this.stay = new VCC_BridgVisitsRS.VisitStay();
    }

    public VCC_PatientVisit(VCC_BridgVisitsRS.VisitItem visit) {
        this.documents = visit.documents;
        this.providers = visit.providers;
        this.movements = visit.movements;

        this.categoryCode = visit.categoryCode;
        this.categoryName = visit.categoryName;

        this.dateAndTime = visit.dateTime_s != null
            ? DateTime.newInstance(
                  (visit.dateTime_s.length() > 3) ? Integer.valueOf(visit.dateTime_s.substring(0, 4)) : 0,
                  (visit.dateTime_s.length() > 5) ? Integer.valueOf(visit.dateTime_s.substring(4, 6)) : 0,
                  (visit.dateTime_s.length() > 7) ? Integer.valueOf(visit.dateTime_s.substring(6, 8)) : 0,
                  (visit.dateTime_s.length() > 9) ? Integer.valueOf(visit.dateTime_s.substring(8, 10)) : 0,
                  (visit.dateTime_s.length() > 11) ? Integer.valueOf(visit.dateTime_s.substring(10, 12)) : 0,
                  0
              )
            : null;

        this.facilityCode = visit.facilityCode;
        this.facilityName = visit.facilityName;
        this.localId = visit.localId;
        this.locationName = visit.locationName;
        this.locationUid = visit.locationUid;
        this.patientClassCode = visit.patientClassCode;
        this.patientClassName = visit.patientClassName;
        this.stopCodeName = visit.stopCodeName;
        this.stopCodeUid = visit.stopCodeUid;
        this.typeName = visit.typeName;
        this.uid = visit.uid;
        this.current = visit.current;
        this.reasonName = visit.reasonName;
        this.service = visit.service;
        this.specialty = visit.specialty;
        this.stay = visit.stay;
        this.summary = visit.summary;
        this.checkOut = visit.checkOut;
        this.reasonUid = visit.reasonUid;
        this.roomBed = visit.roomBed;
    }
}
