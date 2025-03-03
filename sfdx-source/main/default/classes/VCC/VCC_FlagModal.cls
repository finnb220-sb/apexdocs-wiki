/**
 * @author Kumar Balan
 * @group API - Bridg - Flags
 * @description VCC Flag Modal
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class VCC_FlagModal extends VCC_WrapperWithKeyword {
    public class FlagsSite {
        @AuraEnabled
        public FlagsResults results;
    }

    @AuraEnabled
    public List<FlagsSite> sites;

    public class FlagsResults {
        @AuraEnabled
        public FlagsFlags flags;
        @AuraEnabled
        public String timeZone;
        @AuraEnabled
        public String version;
    }

    public class FlagsFlags {
        @AuraEnabled
        public String total;
        @AuraEnabled
        public List<FlagsFlag> flag;
    }

    public class FlagsFlag {
        @AuraEnabled
        public FlagsOrigSite origSite;
        @AuraEnabled
        public FlagsOwnSite ownSite;
        @AuraEnabled
        public FlagsApprovedBy approvedBy;
        @AuraEnabled
        public FlagsName name;
        @AuraEnabled
        public FlagsAssigned assigned;
        @AuraEnabled
        public FlagsId id;
        @AuraEnabled
        public FlagsCategory category;
        @AuraEnabled
        public FlagsType type;
        @AuraEnabled
        public FlagsContent content;
        @AuraEnabled
        public FlagsReviewDue reviewDue;
        @AuraEnabled
        public FlagsDocument document;
    }

    public class FlagsOrigSite {
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String name;
    }

    public class FlagsOwnSite {
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String name;
    }

    public class FlagsApprovedBy {
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String name;
    }

    public class FlagsName {
        @AuraEnabled
        public String value;
    }

    public class FlagsAssigned {
        @AuraEnabled
        public String value {
            get;
            set {
                if (this.value == null) {
                    this.value = value;
                    this.assignedDate = VCC_Util.getDateFromNumber(value);
                    this.assignedDateStr = this.assignedDate.month() + '/' + this.assignedDate.day() + '/' + this.assignedDate.year();
                }
            }
        }
        @AuraEnabled
        public Date assignedDate;
        @AuraEnabled
        public String assignedDateStr;
    }

    public class FlagsId {
        @AuraEnabled
        public String value;
    }

    public class FlagsCategory {
        @AuraEnabled
        public String value;
    }

    public class FlagsType {
        @AuraEnabled
        public String value;
    }

    public class FlagsContent {
        @AuraEnabled
        public String content;
    }

    public class FlagsReviewDue {
        @AuraEnabled
        public String value {
            get;
            set {
                if (this.value == null) {
                    this.value = value;
                    this.reviewDate = VCC_Util.getDateFromNumber(value);
                    this.reviewDateStr = this.reviewDate.month() + '/' + this.reviewDate.day() + '/' + this.reviewDate.year();
                }
            }
        }
        @AuraEnabled
        public Date reviewDate;
        @AuraEnabled
        public String reviewDateStr;
    }

    public class FlagsDocument {
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String name;
    }
}
