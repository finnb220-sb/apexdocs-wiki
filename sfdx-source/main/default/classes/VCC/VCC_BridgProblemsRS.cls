public with sharing class VCC_BridgProblemsRS extends VCC_BaseClient.BaseResponse {
    public List<ProblemsSite> sites;

    public class ProblemsSite {
        public ProblemsResults results;
        public VCC_BridgRSCommon.FpdsErrorSection errorSection;
        public Boolean isMaxRecordsError;

        public ProblemsSite() {
            this.results = new ProblemsResults();
            this.errorSection = new VCC_BridgRSCommon.FpdsErrorSection();
            this.isMaxRecordsError = false;
        }
    }

    public class ProblemsResults {
        public String timeZone;
        public ProblemsProblems problems;
        public String version;

        public ProblemsResults() {
            this.problems = new ProblemsProblems();
        }
    }

    public class ProblemsProblems {
        public string total;
        public List<ProblemsProblem> problem;

        public ProblemsProblems() {
            this.problem = new List<ProblemsProblem>();
        }
    }

    public class ProblemsProblem {
        public ProblemsAcuity acuity;
        public ProblemsComments comments;
        public ProblemsSctt sctt;
        public ProblemsSctc sctc;
        public ProblemsEntered entered;
        public ProblemsIcd icd;
        public ProblemsIcdd icdd;
        public ProblemsSc sc;
        public ProblemsRemoved removed;
        public ProblemsProvider provider;
        public ProblemsSctd sctd;
        public ProblemsName name;
        public ProblemsUnverified unverified;
        public ProblemsLocation location;
        public ProblemsCodingSystem codingSystem;
        public ProblemsId id;
        public ProblemsFacility facility;
        public ProblemsUpdated updated;
        public ProblemsStatus status;
        public ProblemsExposures exposures;
        public ProblemsOnset onset;
        public ProblemsResolved resolved;
        public ProblemsService service;

        public ProblemsProblem() {
            this.acuity = new ProblemsAcuity();
            this.comments = new ProblemsComments();
            this.sctt = new ProblemsSctt();
            this.sctc = new ProblemsSctc();
            this.entered = new ProblemsEntered();
            this.icd = new ProblemsIcd();
            this.icdd = new ProblemsIcdd();
            this.sc = new ProblemsSc();
            this.removed = new ProblemsRemoved();
            this.provider = new ProblemsProvider();
            this.sctd = new ProblemsSctd();
            this.name = new ProblemsName();
            this.unverified = new ProblemsUnverified();
            this.location = new ProblemsLocation();
            this.codingSystem = new ProblemsCodingSystem();
            this.id = new ProblemsId();
            this.facility = new ProblemsFacility();
            this.facility = new ProblemsFacility();
            this.updated = new ProblemsUpdated();
            this.status = new ProblemsStatus();
            this.exposures = new ProblemsExposures();
            this.onset = new ProblemsOnset();
            this.resolved = new ProblemsResolved();
            this.service = new ProblemsService();
        }
    }

    public class ProblemsAcuity {
        public String code; //enum [ A, C ]
        public String name; //enum [ ACUTE, CHRONIC ]
    }
    public class ProblemsComments {
        public List<ProblemsComment> comment;

        public ProblemsComments() {
            this.comment = new List<ProblemsComment>();
        }
    }
    public class ProblemsSctt {
        public String value;
    }
    public class ProblemsSctc {
        public String value;
    }
    public class ProblemsEntered {
        public String value;
    }
    public class ProblemsIcd {
        public String value;
    }
    public class ProblemsIcdd {
        public String value;
    }
    public class ProblemsSc {
        public String value;
    }
    public class ProblemsRemoved {
        public String value;
    }
    public class ProblemsProvider {
        public String code;
        public String name;
    }
    public class ProblemsSctd {
        public String value;
    }
    public class ProblemsName {
        public String value;
    }
    public class ProblemsUnverified {
        public String value;
    }
    public class ProblemsLocation {
        public String value;
    }
    public class ProblemsCodingSystem {
        public String value; // enum [ ICD, 10D ]
    }
    public class ProblemsId {
        public String value;
    }
    public class ProblemsFacility {
        public String code; // enum [ A, I ]
        public String name; // enum [ ACTIVE, INACTIVE ]
    }
    public class ProblemsUpdated {
        public String value;
    }
    public class ProblemsStatus {
        public String code;
        public String name;
    }
    public class ProblemsExposures {
        public List<ProblemsExposure> exposure;

        public ProblemsExposures() {
            this.exposure = new List<ProblemsExposure>();
        }
    }
    public class ProblemsOnset {
        public String value;
    }
    public class ProblemsResolved {
        public String value;
    }
    public class ProblemsService {
        public String value;
    }

    public class ProblemsComment {
        public String id;
        public String entered;
        public String enteredBy;
        public String commentText;
    }

    public class ProblemsExposure {
        public String value; // Enum: [ AO, IR, PG, HNC, MST, CV, SHAD ]
    }

    public VCC_BridgProblemsRS() {
        this.sites = new List<ProblemsSite>();
    }

    public VCC_BridgProblemsRS(VCC_BaseClient.BaseResponse baseResponse) {
        super(baseResponse);
        try {
            this.sites = ((VCC_BridgProblemsRS) JSON.deserialize(baseResponse.httpResponse.getBody().replace('"exception"', '"exception_s"'), VCC_BridgProblemsRS.class)).sites;

            if (baseResponse.httpResponse.getBody().contains('Exceeded Max')) {
                this.sites[0].isMaxRecordsError = true;
            }
        } catch (Exception e) {
            this.exceptions.add(e);
        }
    }
}
