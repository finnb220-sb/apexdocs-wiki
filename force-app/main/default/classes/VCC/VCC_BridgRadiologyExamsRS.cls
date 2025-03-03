public with sharing class VCC_BridgRadiologyExamsRS extends VCC_BaseClient.BaseResponse {
    public List<ExamSite> sites;
    public Boolean isMaxRecordsError;

    public class ExamSite {
        public ExamSiteResults results;
        public VCC_BridgRSCommon.FpdsErrorSection errorSection;

        public ExamSite() {
            this.results = new ExamSiteResults();
            this.errorSection = new VCC_BridgRSCommon.FpdsErrorSection();
        }
    }
    public class ExamSiteResults {
        public Exams radiologyExams;

        public ExamSiteResults() {
            this.radiologyExams = new Exams();
        }
    }
    public class Exams {
        public String total;
        public List<RadiologyExam> radiology;

        public Exams() {
            this.radiology = new List<RadiologyExam>();
        }
    }

    public class RadiologyExam {
        public RadiologyExamsDateTime dateTime_s;
        public RadiologyExamsImagingType imagingType;
        public RadiologyExamsName name;
        public RadiologyExamsHasImages hasImages;
        public RadiologyExamsLocation location;
        public RadiologyExamsId id;
        public RadiologyExamsCategory category;
        public RadiologyExamsFacility facility;
        public RadiologyExamsCase case_s;
        public RadiologyExamsDocuments documents;
        public RadiologyExamsType type;
        public RadiologyExamsProvider provider;
        public RadiologyExamsStatus status;
        public RadiologyExamsEncounter encounter;
        public RadiologyExamsInterpretation interpretation;
        public RadiologyExamsModifiers modifiers;
        public RadiologyExamsOrder order;
        public RadiologyExamsUrgency urgency;

        public RadiologyExam() {
            this.dateTime_s = new RadiologyExamsDateTime();
            this.imagingType = new RadiologyExamsImagingType();
            this.name = new RadiologyExamsName();
            this.hasImages = new RadiologyExamsHasImages();
            this.location = new RadiologyExamsLocation();
            this.id = new RadiologyExamsId();
            this.category = new RadiologyExamsCategory();
            this.facility = new RadiologyExamsFacility();
            this.case_s = new RadiologyExamsCase();
            this.documents = new RadiologyExamsDocuments();
            this.type = new RadiologyExamsType();
            this.provider = new RadiologyExamsProvider();
            this.status = new RadiologyExamsStatus();
            this.encounter = new RadiologyExamsEncounter();
            this.interpretation = new RadiologyExamsInterpretation();
            this.modifiers = new RadiologyExamsModifiers();
            this.order = new RadiologyExamsOrder();
            this.urgency = new RadiologyExamsUrgency();
        }
    }
    public class RadiologyExamsDateTime {
        public String value;
    }
    public class RadiologyExamsImagingType {
        public String code;
        public String name;
    }
    public class RadiologyExamsName {
        public String value;
    }
    public class RadiologyExamsHasImages {
        public String value;
    }
    public class RadiologyExamsLocation {
        public String code;
        public String name;
    }
    public class RadiologyExamsId {
        public String value;
    }
    public class RadiologyExamsCategory {
        public String value;
    }
    public class RadiologyExamsFacility {
        public String code;
        public String name;
    }
    public class RadiologyExamsCase {
        public String value;
    }
    public class RadiologyExamsDocuments {
        public List<RadiologyExamDocument> document;

        public RadiologyExamsDocuments() {
            this.document = new List<RadiologyExamDocument>();
        }
    }
    public class RadiologyExamDocument {
        public String nationalTitle;
        public String localTitle;
        public String id;
        public String vuid;
        public String status; //Enum: [ Verified, Released/NotVerified, Electronically Filed ]
        public Contentwrap content;
    }
    public class Contentwrap {
        public String content;
    }
    public class RadiologyExamsType {
        public String code;
        public String name;
    }
    public class RadiologyExamsProvider {
        public String taxonomyCode;
        public String code;
        public String service;
        public String name;
        public String specialization;
        public String analogPager;
        public String classification;
        public String providerType;
        public String officePhone;
        public String fax;
        public String email;
    }
    public class RadiologyExamsStatus {
        public String value; //enum: COMPLETE, CANCELLED, EXAMINED, WAITING FOR EXAM, CALLED FOR EXAM
    }
    public class RadiologyExamsEncounter {
        public String value;
    }
    public class RadiologyExamsInterpretation {
        public String value;
    }
    public class RadiologyExamsModifiers {
        public List<RadiologyExamModifier> modifier;
    }
    public class RadiologyExamModifier {
        public String code;
        public String name;
    }
    public class RadiologyExamsOrder {
        public String code;
        public String name;
    }
    public class RadiologyExamsUrgency {
        public String value;
    }

    public VCC_BridgRadiologyExamsRS() {
        this.sites = new List<ExamSite>();
    }

    public VCC_BridgRadiologyExamsRS(VCC_BaseClient.BaseResponse baseResponse) {
        super(baseResponse);
        try {
            this.sites = ((VCC_BridgRadiologyExamsRS) JSON.deserialize(
                    baseResponse.httpResponse.getBody().replace('"exception"', '"exception_s"').replace('"dateTime"', '"dateTime_s"').replace('"case"', '"case_s"'),
                    VCC_BridgRadiologyExamsRS.class
                ))
                .sites;

            if (baseResponse.httpResponse.getBody().contains('Exceeded Max')) {
                this.isMaxRecordsError = true;
            }
        } catch (Exception e) {
            this.exceptions.add(e);
        }
    }
}
