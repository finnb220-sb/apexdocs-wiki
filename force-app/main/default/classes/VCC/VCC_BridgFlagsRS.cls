public with sharing class VCC_BridgFlagsRS extends VCC_BaseClient.BaseResponse {
    public List<FlagSite> sites;

    public class FlagSite {
        public FlagsResults results;
        public VCC_BridgRSCommon.FpdsErrorSection errorSection;

        public FlagSite() {
            this.results = new FlagsResults();
            this.errorSection = new VCC_BridgRSCommon.FpdsErrorSection();
        }
    }

    public class FlagsResults {
        public FlagsFlags flags;
        public string timeZone;
        public string version;

        public FlagsResults() {
            this.flags = new FlagsFlags();
        }
    }

    public class FlagsFlags {
        public String total;
        public List<FlagsFlag> flag;

        public FlagsFlags() {
            this.flag = new List<FlagsFlag>();
        }
    }

    public class FlagsFlag {
        public FlagsOrigSite origSite;
        public FlagsOwnSite ownSite;
        public FlagsApprovedBy approvedBy;
        public FlagsName name;
        public FlagsAssigned assigned;
        public FlagsId id;
        public FlagsCategory category;
        public FlagsType type;
        public FlagsContent content;
        public FlagsReviewDue reviewDue;
        public FlagsDocument document;

        public FlagsFlag() {
            this.origSite = new FlagsOrigSite();
            this.ownSite = new FlagsOwnSite();
            this.approvedBy = new FlagsApprovedBy();
            this.name = new FlagsName();
            this.assigned = new FlagsAssigned();
            this.id = new FlagsId();
            this.category = new FlagsCategory();
            this.type = new FlagsType();
            this.content = new FlagsContent();
            this.reviewDue = new FlagsReviewDue();
            this.document = new FlagsDocument();
        }
    }

    public class FlagsOrigSite {
        public String code;
        public String name;
    }

    public class FlagsOwnSite {
        public String code;
        public String name;
    }

    public class FlagsApprovedBy {
        public String code;
        public String name;
    }

    public class FlagsName {
        public String value;
    }

    public class FlagsAssigned {
        public String value;
    }

    public class FlagsId {
        public String value;
    }

    public class FlagsCategory {
        public String value;
    }

    public class FlagsType {
        public String value;
    }

    public class FlagsContent {
        public String content;
    }

    public class FlagsReviewDue {
        public String value;
    }

    public class FlagsDocument {
        public String code;
        public String name;
    }

    public VCC_BridgFlagsRS() {
        this.sites = new List<FlagSite>();
    }

    public VCC_BridgFlagsRS(VCC_BaseClient.BaseResponse baseResponse) {
        super(baseResponse);
        try {
            this.sites = ((VCC_BridgFlagsRS) JSON.deserialize(baseResponse.httpResponse.getBody().replace('"exception"', '"exception_s"'), VCC_BridgFlagsRS.class)).sites;
        } catch (Exception e) {
            this.exceptions.add(e);
        }
    }
}
