@SuppressWarnings('PMD.ExcessivePublicCount, PMD.TooManyFields, PMD.VariableNamingConventions')
public with sharing class VCC_BridgOrdersRS extends VCC_BaseClient.BaseResponse {
    public List<OrdersSite> sites;
    public Boolean isMaxRecordsError;

    public class OrdersSite {
        public OrdersResults results;
        public VCC_BridgRSCommon.FpdsErrorSection errorSection;

        public OrdersSite() {
            this.results = new OrdersResults();
            this.errorSection = new VCC_BridgRSCommon.FpdsErrorSection();
        }
    }

    public class OrdersResults {
        public String timeZone;
        public OrdersOrders orders;
        public String version;

        public OrdersResults() {
            this.orders = new OrdersOrders();
        }
    }

    public class OrdersOrders {
        public string total;
        public List<OrdersOrder> order;

        public OrdersOrders() {
            this.order = new List<OrdersOrder>();
        }
    }

    public class OrdersOrder {
        public OrdersResultID resultID;
        public OrdersStart start;
        public OrdersSigned signed;
        public OrdersEntered entered;
        public OrdersType type;
        public OrdersContent content;
        public OrdersSignatureStatus signatureStatus;
        public OrdersProvider provider;
        public OrdersSupplemental supplemental;
        public OrdersService service;
        public OrdersName name;
        public OrdersLocation location;
        public OrdersCodingSystem codingSystem;
        public OrdersId id;
        public OrdersFacility facility;
        public OrdersReleased released;
        public OrdersGroup group_s;
        public OrdersSigner signer;
        public OrdersStatus status;
        public OrdersDiscontinued discontinued;
        public OrdersStop stop;
        public OrdersVuid vuid;
        public OrdersAcknowledgements acknowledgements;

        public OrdersOrder() {
            this.resultID = new OrdersResultID();
            this.start = new OrdersStart();
            this.signed = new OrdersSigned();
            this.entered = new OrdersEntered();
            this.type = new OrdersType();
            this.content = new OrdersContent();
            this.signatureStatus = new OrdersSignatureStatus();
            this.provider = new OrdersProvider();
            this.supplemental = new OrdersSupplemental();
            this.service = new OrdersService();
            this.name = new OrdersName();
            this.location = new OrdersLocation();
            this.codingSystem = new OrdersCodingSystem();
            this.id = new OrdersId();
            this.facility = new OrdersFacility();
            this.released = new OrdersReleased();
            this.group_s = new OrdersGroup();
            this.signer = new OrdersSigner();
            this.status = new OrdersStatus();
            this.discontinued = new OrdersDiscontinued();
            this.stop = new OrdersStop();
            this.vuid = new OrdersVuid();
            this.acknowledgements = new OrdersAcknowledgements();
        }
    }

    public class OrdersResultID {
        public String value;
    }
    public class OrdersStart {
        public String value;
    }
    public class OrdersSigned {
        public String value;
    }
    public class OrdersEntered {
        public String value;
    }
    public class OrdersType {
        public String value;
    }
    public class OrdersContent {
        public String content;
    }
    public class OrdersSignatureStatus {
        /**
         * enum [ ON CHART w/written orders, ELECTRONIC, NOT SIGNED, NOT REQUIRED, \
         * ON CHART w/printed orders, NOT REQUIRED due to cancel/lapse, SERVICE CORRECTION to signed order,
         * DIGITALLY SIGNED, ON PARENT order ]
         */
        public String value;
    }
    public class OrdersProvider {
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
        public String Specialization;
    }
    public class OrdersSupplemental {
        public OrdersPendingMedFields pendingMedFields;
    }
    public class OrdersPendingMedFields {
        public String placeNumber;
        public String flag;
        public String flaggedDate;
        public String flaggedBy;
        public String flaggedReason;
        public String relatedInstitution;
    }
    public class OrdersService {
        public String value;
    }
    public class OrdersName {
        public String code;
        public String name;
    }
    public class OrdersLocation {
        public String code;
        public String name;
    }
    public class OrdersCodingSystem {
        public String code;
        public String name;
    }
    public class OrdersId {
        public String value;
    }
    public class OrdersFacility {
        public String code;
        public String name;
    }
    public class OrdersReleased {
        public String value;
    }
    public class OrdersGroup {
        public String value;
    }
    public class OrdersSigner {
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
    public class OrdersStatus {
        public String code;
        public String name;
        public String vuid;
    }
    public class OrdersDiscontinued {
        public String date_s;
        public String reason;
        public String by_s;
        public String byName;
    }
    public class OrdersStop {
        public String value;
    }
    public class OrdersVuid {
        public String value;
    }
    public class OrdersAcknowledgements {
        public List<OrdersAcknowledgement> acknowledgement;

        public OrdersAcknowledgements() {
            this.acknowledgement = new List<OrdersAcknowledgement>();
        }
    }
    public class OrdersAcknowledgement {
        public String code;
        public String name;
        public String date_s;
    }

    public VCC_BridgOrdersRS() {
        this.sites = new List<OrdersSite>();
    }

    public VCC_BridgOrdersRS(VCC_BaseClient.BaseResponse baseResponse) {
        super(baseResponse);
        try {
            this.sites = ((VCC_BridgOrdersRS) JSON.deserialize(
                    baseResponse.httpResponse.getBody()
                        .replace('"by"', '"by_s"')
                        .replace('"date"', '"date_s"')
                        .replace('"group"', '"group_s"')
                        .replace('"exception"', '"exception_s"'),
                    VCC_BridgOrdersRS.class
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
