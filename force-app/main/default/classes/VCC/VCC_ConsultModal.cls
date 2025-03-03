/**
 * @author Kumar Balan
 * @group API - Bridg - Consults
 * @description VCC Consult Modal
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class VCC_ConsultModal extends VCC_WrapperWithKeyword {
    @AuraEnabled
    public List<Sites> sites;

    public class Sites {
        @AuraEnabled
        public Results results;
    }

    public class Results {
        @AuraEnabled
        public Consults consults;
    }

    public class Consults {
        @AuraEnabled
        public Integer total;
        @AuraEnabled
        public List<Consult> consult;
    }

    public class Consult {
        @AuraEnabled
        public Name name;
        @AuraEnabled
        public Facility facility;
        //@AuraEnabled
        //public Clinic clinic;
        @AuraEnabled
        public Requested requested;
        @AuraEnabled
        public Reason reason;
        @AuraEnabled
        public Provider provider;
        @AuraEnabled
        public Status status;
        @AuraEnabled
        public Urgency urgency;
        @AuraEnabled
        public Service service;
        @AuraEnabled
        public Documents documents;
        @AuraEnabled
        public List<RequestProcessingActivity> requestProcessingActivity;
        @AuraEnabled
        @SuppressWarnings('PMD.FieldNamingConventions')
        public VCC_ConsultId id;
    }

    public class Service {
        @AuraEnabled
        public string value;
    }

    public class Documents {
        @AuraEnabled
        public List<Document> document;
    }

    public class Document {
        @AuraEnabled
        public string localTitle;
    }

    public class RequestProcessingActivity {
        @AuraEnabled
        public string activityEntryDate;
        @AuraEnabled
        public string activity;
        @AuraEnabled
        public string comment;
    }

    public class Urgency {
        @AuraEnabled
        public string value;
    }

    public class Status {
        @AuraEnabled
        public string value;
    }

    public class Provider {
        @AuraEnabled
        public string name;
    }

    public class Reason {
        @AuraEnabled
        public string content;
    }

    public class Requested {
        @AuraEnabled
        public String value {
            get;
            set {
                if (this.value == null) {
                    this.value = value;
                    this.orderDate = VCC_Util.getDateFromNumber(value);
                    if (this.orderDate != null) {
                        this.orderDateStr = this.orderDate.month() + '/' + this.orderDate.day() + '/' + this.orderDate.year();
                    }
                }
            }
        }
        @AuraEnabled
        public Date orderDate;
        @AuraEnabled
        public String orderDateStr;
    }

    public class Facility {
        @AuraEnabled
        public string name;
    }

    public class Name {
        @AuraEnabled
        public string value;
    }
    /**
     * @description Consult Number value
     */
    public class VCC_ConsultId {
        @AuraEnabled
        public string value;
    }
}
