public with sharing class VCC_ProblemModal extends VCC_WrapperWithKeyword {
    public class ProblemsSite {
        @AuraEnabled
        public ProblemsResults results;
        @AuraEnabled
        public Boolean isMaxRecordsError;
    }

    public class ProblemsResults {
        @AuraEnabled
        public String timeZone;
        //W-011235 change from Double to string
        @AuraEnabled
        public String version;
        @AuraEnabled
        public ProblemsProblems problems;
    }

    public class ProblemsProblems {
        //W-011235 change from integer to string
        @AuraEnabled
        public String total;
        @AuraEnabled
        public String version;
        @AuraEnabled
        public List<ProblemsProblem> problem;
    }

    public class ProblemsAcuity {
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String name;
    }

    public class ProblemsComments {
        @AuraEnabled
        public List<ProblemsComment> comment;
    }

    public class ProblemsComment {
        //W-011235 change from integer to string
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String entered {
            get;
            set {
                this.entered = String.valueOf(VCC_Util.getDateFromNumber(value));
            }
        }
        @AuraEnabled
        public String enteredBy;
        @AuraEnabled
        public String commentText;
    }

    public class ProblemsSctt {
        @AuraEnabled
        public String value;
    }

    public class ProblemsSctc {
        @AuraEnabled
        public String value;
    }

    public class ProblemsEntered {
        @AuraEnabled
        public String value {
            get;
            set {
                if (this.value == null) {
                    this.value = value;
                    this.enteredDate = VCC_Util.getDateFromNumber(value);
                    if (this.enteredDate != null) {
                        this.enteredDateStr = this.enteredDate.month() + '/' + this.enteredDate.day() + '/' + this.enteredDate.year();
                    }
                }
            }
        }

        @AuraEnabled
        public Date enteredDate;
        @AuraEnabled
        public String enteredDateStr;
    }

    public class ProblemsIcd {
        @AuraEnabled
        public String value;
    }

    public class ProblemsIcdd {
        @AuraEnabled
        public String value;
    }

    public class ProblemsSc {
        @AuraEnabled
        public String value;
    }

    public class ProblemsRemoved {
        @AuraEnabled
        public String value;
    }

    public class ProblemsProvider {
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String name;
    }

    public class ProblemsSctd {
        @AuraEnabled
        public String value;
    }

    public class ProblemsName {
        @AuraEnabled
        public String value;
    }

    public class ProblemsUnverified {
        @AuraEnabled
        public String value;
    }

    public class ProblemsLocation {
        @AuraEnabled
        public String value;
    }

    public class ProblemsCodingSystem {
        @AuraEnabled
        public String value;
    }

    public class ProblemsId {
        @AuraEnabled
        public String value;
    }

    public class ProblemsFacility {
        //W-011235 change from integer to string
        @AuraEnabled
        public string code;
        @AuraEnabled
        public String name;
    }

    public class ProblemsUpdated {
        @AuraEnabled
        public String value {
            get;
            set {
                if (this.value == null) {
                    this.value = value;
                    this.updatedDate = VCC_Util.getDateFromNumber(value);
                    if (this.updatedDate != null) {
                        this.updatedDateStr = this.updatedDate.month() + '/' + this.updatedDate.day() + '/' + this.updatedDate.year();
                    }
                }
            }
        }

        @AuraEnabled
        public Date updatedDate;
        @AuraEnabled
        public String updatedDateStr;
    }

    public class ProblemsStatus {
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String name;
    }

    public class ProblemsExposures {
        @AuraEnabled
        public List<ProblemsExposure> exposure;
    }

    public class ProblemsExposure {
        @AuraEnabled
        public String value;
    }

    public class ProblemsOnset {
        @AuraEnabled
        public String value {
            get;
            set {
                if (this.value == null) {
                    this.value = value;
                    this.onSetDate = VCC_Util.getDateFromNumber(value);
                    if (this.onSetDate != null) {
                        this.onSetDateStr = this.onSetDate.month() + '/' + this.onSetDate.day() + '/' + this.onSetDate.year();
                    }
                }
            }
        }

        @AuraEnabled
        public Date onSetDate;
        @AuraEnabled
        public String onSetDateStr;
    }

    public class ProblemsResolved {
        @AuraEnabled
        public String value;
    }

    public class ProblemsService {
        @AuraEnabled
        public String value;
    }

    public class ProblemsProblem {
        @AuraEnabled
        public ProblemsAcuity acuity;
        @AuraEnabled
        public ProblemsComments comments;
        @AuraEnabled
        public ProblemsSctt sctt;
        @AuraEnabled
        public ProblemsSctc sctc;
        @AuraEnabled
        public ProblemsEntered entered;
        @AuraEnabled
        public ProblemsIcd icd;
        @AuraEnabled
        public ProblemsIcdd icdd;
        @AuraEnabled
        public ProblemsSc sc;
        @AuraEnabled
        public ProblemsRemoved removed;
        @AuraEnabled
        public ProblemsProvider provider;
        @AuraEnabled
        public ProblemsSctd sctd;
        @AuraEnabled
        public ProblemsName name;
        @AuraEnabled
        public ProblemsUnverified unverified;
        @AuraEnabled
        public ProblemsLocation location;
        @AuraEnabled
        public ProblemsCodingSystem codingSystem;
        @AuraEnabled
        public ProblemsId id;
        @AuraEnabled
        public ProblemsFacility facility;
        @AuraEnabled
        public ProblemsUpdated updated;
        @AuraEnabled
        public ProblemsStatus status;
        @AuraEnabled
        public ProblemsExposures exposures;
        @AuraEnabled
        public ProblemsOnset onset;
        @AuraEnabled
        public ProblemsResolved resolved;
        @AuraEnabled
        public ProblemsService service;
    }

    @AuraEnabled
    public List<ProblemsSite> sites;
}
