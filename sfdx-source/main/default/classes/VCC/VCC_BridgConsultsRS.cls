public with sharing class VCC_BridgConsultsRS extends VCC_BaseClient.BaseResponse {
    public List<ConsultsSite> sites;
    public Boolean isMaxRecordsError;

    public class ConsultsSite {
        public Boolean isMaxRecordsError;
        public ConsultsResults results;
        public VCC_BridgRSCommon.FpdsErrorSection errorSection;

        public ConsultsSite() {
            this.isMaxRecordsError = false;
            this.results = new ConsultsResults();
            this.errorSection = new VCC_BridgRSCommon.FpdsErrorSection();
        }
    }

    public class ConsultsResults {
        public String timeZone;
        public String version;
        public ConsultsConsults consults;

        public ConsultsResults() {
            this.consults = new ConsultsConsults();
        }
    }

    public class ConsultsConsults {
        public String total;
        public List<ConsultsConsult> consult;

        public ConsultsConsults() {
            this.consult = new List<ConsultsConsult>();
        }
    }

    public class ConsultsConsult {
        public ConsultsDocuments documents;
        public List<ConsultsActivities> requestProcessingActivity;
        public ConsultsReason reason;
        public ConsultsProvDx provDx;
        public ConsultsOrderID orderID;
        public ConsultsProcedure procedure;
        public ConsultsType type;
        public ConsultsRequested requested;
        public ConsultsProvider provider;
        public ConsultsUrgency urgency;
        public ConsultsService service;
        public ConsultsName name;
        public ConsultsId id;
        public ConsultsFacility facility;
        public ConsultsStatus status;
        public ConsultsResult result;

        public ConsultsConsult() {
            this.documents = new ConsultsDocuments();
            this.requestProcessingActivity = new List<ConsultsActivities>();
            this.reason = new ConsultsReason();
            this.provDx = new ConsultsProvDx();
            this.orderID = new ConsultsOrderID();
            this.procedure = new ConsultsProcedure();
            this.type = new ConsultsType();
            this.requested = new ConsultsRequested();
            this.provider = new ConsultsProvider();
            this.urgency = new ConsultsUrgency();
            this.service = new ConsultsService();
            this.name = new ConsultsName();
            this.id = new ConsultsId();
            this.facility = new ConsultsFacility();
            this.status = new ConsultsStatus();
            this.result = new ConsultsResult();
        }
    }

    public class ConsultsDocuments {
        public List<ConsultsDocument> documents;

        public ConsultsDocuments() {
            this.documents = new List<ConsultsDocument>();
        }
    }
    public class ConsultsDocument {
        public String id;
        public String localTitle;
        public String nationalTitle;
        public String vuid;
        public String content;
    }

    public class ConsultsActivities {
        public String activityEntryDate;
        public String activity;
        public String comment;
    }

    public class ConsultsReason {
        public String content;
    }
    public class ConsultsProvDx {
        public String value;
    }
    public class ConsultsOrderID {
        public String value;
    }
    public class ConsultsProcedure {
        public String value;
    }
    public class ConsultsType {
        public String value;
    }
    public class ConsultsRequested {
        public String value;
    }
    public class ConsultsProvider {
        public String taxonomyCode;
        public String code;
        public String service;
        public String name;
        public String classification;
        public String providerType;
        public String officePhone;
        public String analogPager;
        public String fax;
        public String email;
        public String specialization;
    }
    public class ConsultsUrgency {
        public String value;
    }
    public class ConsultsService {
        public String value;
    }
    public class ConsultsName {
        public String value;
    }
    public class ConsultsId {
        public String value;
    }
    public class ConsultsFacility {
        public String name;
        public String code;
    }
    public class ConsultsStatus {
        public String value;
    }
    public class ConsultsResult {
        public String result;
    }

    public VCC_BridgConsultsRS() {
        this.sites = new List<ConsultsSite>();
    }

    public VCC_BridgConsultsRS(VCC_BaseClient.BaseResponse baseResponse) {
        super(baseResponse);
        try {
            this.sites = ((VCC_BridgConsultsRS) JSON.deserialize(baseResponse.httpResponse.getBody().replace('"exception"', '"exception_s"'), VCC_BridgConsultsRS.class)).sites;

            if (baseResponse.httpResponse.getBody().contains('Exceeded Max')) {
                this.isMaxRecordsError = true;
            }
        } catch (Exception e) {
            this.exceptions.add(e);
        }
    }
}
